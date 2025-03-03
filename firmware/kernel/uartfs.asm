		INCLUDE	"lowlevel/rc800.i"
		INCLUDE	"lowlevel/uart.i"
		INCLUDE	"stdlib/string.i"

		INCLUDE	"error.i"
		INCLUDE	"filesystems.i"
		INCLUDE	"uartfs.i"
		INCLUDE	"uart_commands.i"
		INCLUDE	"uart_commands_disabled.i"


		RSSET	fs_PRIVATE
ufs_SIZEOF	RB	0

		RSSET	dir_PRIVATE
udir_Index	RW	1
udir_SIZEOF	RB	0

	IF udir_SIZEOF>dir_SIZEOF
		FAIL	"udir_SIZEOF too large"
	ENDC


; ---------------------------------------------------------------------------
; -- Initialize UART filesystem
; --
		SECTION	"UartInitialize",CODE
UartInitialize:
		push	bc-hl

		jal	ComIdentify
		j/ne	.exit

		ld	bc,UartVolume
		ld	de,.fs
		ld	f,.fs_end-.fs
.copy		lco	t,(de)
		ld	(bc),t
		add	de,1
		add	bc,1
		dj	f,.copy

		ld	f,FLAGS_EQ
.exit
		pop	bc-hl
		j	(hl)

.fs		DB	4,"uart",0,0,0,0,0,0,0,0,0,0,0
		DB	0,0,0,0,0,0,0,0
		DB	$FF
		DW	$0000
		DW	uartOpen
		DW	uartClose
		DW	uartRead
		DW	uartOpenDir
		DW	uartReadDir
		DW	uartCloseDir
.fs_end

	IF .fs_end-.fs~=ufs_SIZEOF
		FAIL	"UART filesystem template size mismatch ({.fs_end-.fs} vs {ufs_SIZEOF})"
	ENDC


; ---------------------------------------------------------------------------
; -- Open file over UART. file_Flags, file_Error and file_Length are filled
; -- in.
; --
; -- Inputs:
; --   ft - file name path
; --   bc - file struct
; --   de - pointer to filesystem struct
; --
; -- Output:
; --    t - Error code
; --    f - "eq" if success
; --
		SECTION	"UartOpen",CODE
uartOpen:	
		push	bc-hl

		MDebugPrint <"uartOpen entry\n">
		MDebugMemory bc,file_SIZEOF

		ld	bc,uartFile1
		ld	de,ft

		jal	StringCopy
		jal	sendStatFileCommand

		jal	ComSyncResponse
		j/ne	.done

		jal	UartByteInSync
		j/ne	.timeout

		pop	bc
		push	bc
		add	bc,file_Flags
		ld	(bc),t

		add	bc,file_Length-file_Flags
		ld	de,4
		jal	UartMemoryInSync
		sub	bc,file_Length
		j/ne	.timeout

		ld	t,ERROR_SUCCESS
		j	.done

.timeout	ld	t,ERROR_TIMEOUT
.done		add	bc,file_Error
		ld	(bc),t
		cmp	t,ERROR_SUCCESS

		pop	bc-hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Close file
; --
; -- Inputs:
; --   ft - pointer to file struct
; --
		SECTION	"UartClose",CODE
uartClose:
		MDebugPrint <"uartClose\n">
		j	(hl)


; ---------------------------------------------------------------------------
; -- Close directory
; --
; -- Inputs:
; --   ft - pointer to directory struct
; --
		SECTION	"UartCloseDir",CODE
uartCloseDir:
		MDebugPrint <"uartCloseDir\n">
		j	(hl)


; ---------------------------------------------------------------------------
; -- Read from file offset
; --
; -- Inputs:
; --   ft - bytes to read
; --   bc - pointer to file struct
; --   de - destination pointer (data segment)
; --
; -- Output:
; --   ft - bytes read
; --
		SECTION	"UartRead",CODE
uartRead:
		MDebugPrint <"uartRead entry\n">

		push	bc-hl

		; send command

		push	ft

		ld	t,COMMAND_LOAD_FILE
		jal	ComSendCommand

		push	bc
		ld	bc,uartFile1
		jal	ComSendDataString
		pop	bc

		push	de
		add	bc,file_Offset
		ld	de,4
		jal	UartMemoryOutSync
		sub	bc,file_Offset
		pop	de

		pop	ft
		jal	UartWordOutSync

		; read response

		jal	ComSyncResponse
		j/ne	.error

		push	bc
		jal	UartWordInSync
		ld	ft,bc
		ld	hl,ft
		pop	bc

		tst	hl
		j/eq	.error

		push	bc

		; de <- hl
		; bc <- de
		; ft <- bc

		exg	ft,hl
		exg	ft,de
		exg	ft,bc

		; ft = file struct
		; bc = memory
		; de = length

		jal	UartMemoryInSync

		pop	bc
		j/ne	.error

		add	bc,file_Error
		ld	t,ERROR_SUCCESS
		ld	(bc),t

		ld	ft,de
		j	.exit

.error		add	bc,file_Error
		ld	(bc),t
		ld	ft,0

.exit		pop	bc-hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Send stat file command
; --
; -- Inputs:
; --   bc - file name (Pascal string, data segment)
; --
; -- Returns:
; --    t - error code, 0 is success
; --    f - "eq" condition if success
; --
		SECTION "SendStatFileCommand",CODE
sendStatFileCommand:
		push	hl

		jal	ComIdentify
		j/ne	.exit

		ld	t,COMMAND_STAT_FILE
		jal	ComSendCommand

		jal	ComSendDataString

		ld	t,ERROR_SUCCESS
		ld	f,FLAGS_EQ

.exit		pop	hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Open directory
; --
; -- Inputs:
; --   ft - pointer to directory struct
; --   bc - path
; --   de - pointer to filesystem struct
; --
; -- Output:
; --    f - "eq" if directory could be opened. Directory struct is filled in
; --        with information on first file
; --
		SECTION "UartOpenDir",CODE
uartOpenDir:
		pusha

		MDebugPrint <"uartOpenDir ">
		MDebugRegisters
		MDebugMemory bc,16

		ld	ft,bc
		ld	de,ft
		ld	bc,uartDir1 
		jal	StringCopy

		pop	ft
		push	ft

		; clear file index
		add	ft,udir_Index
		ld	b,0
		ld	(ft),b
		add	ft,1
		ld	(ft),b

		pop	de
		ld	ft,de
		ld	bc,ft
		pop	ft

		MDebugPrint <"call uartReadDir\n">
		MDebugRegisters
		jal	uartReadDir
		MDebugRegisters

		pop	bc/hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Read next file information from directory
; --
; -- Inputs:
; --   ft - pointer to directory struct
; --   bc - pointer to filesystem struct
; --
; -- Output:
; --    f - "eq" if next file information could be retrieved. Directory
; --        struct is filled in with information on file.
; --        "ne" when no more files present.
; --
		SECTION "UartReadDir",CODE
uartReadDir:
		pusha

		MDebugPrint "uartReadDir entry\n"

		ld	d,ERROR_SUCCESS
		add	ft,dir_Error
		ld	(ft),d

		; fetch index
		add	ft,udir_Index+1-dir_Error
		ld	d,(ft)
		sub	ft,1
		ld	e,(ft)

		; increment index and store
		add	de,1
		ld	(ft),e
		add	ft,1
		ld	(ft),d
		sub	de,1

		; send read dir command
		ld	ft,de
		ld	bc,uartDir1
		jal	sendReadDirCommand

		; read response
		jal	ComSyncResponse
		j/ne	.error

		;MDebugPrint "uartReadDir 2\n"

		; filename
		pop	ft
		push	ft

		ld	bc,ft
		add	bc,dir_Filename
		jal	ComReadDataString
		j/ne	.error

		;MDebugPrint "uartReadDir 1\n"

		; directory flag
		jal	UartByteInSync
		j/ne	.error

		and	t,FFLAG_DIR
		ld	b,t
		pop	ft
		add	ft,dir_Flags
		ld	(ft),b

		; file length

		ld	bc,ft
		add	bc,dir_Length-dir_Flags
		ld	de,4
		jal	UartMemoryInSync

.exit		pop	bc-hl
		MDebugPrint <"uartReadDir exit\n">
		j	(hl)

.error		MDebugPrint <"uartReadDir error\n">
		ld	b,t
		pop	ft
		add	ft,dir_Error
		ld	(ft),b
		ld	f,FLAGS_NE
		j	.exit


; ---------------------------------------------------------------------------
; -- Send read directory command
; --
; -- Inputs:
; --   ft - index
; --   bc - path name (Pascal string, data segment)
; --
; -- Returns:
; --    t - error code, 0 is success
; --    f - "eq" condition if success
; --
		SECTION "SendReadDirCommand",CODE
sendReadDirCommand:
		MDebugPrint <"sendReadDirCommand entry, path=">
		MDebugPrintR bc
		MDebugNewLine
		MDebugMemory bc,16

		push	bc-hl

		ld	de,ft

		jal	ComIdentify
		j/ne	.exit
		MDebugPrint <"sendReadDirCommand 1\n">
		MDebugRegisters

		ld	t,COMMAND_READ_DIR
		jal	ComSendCommand
		;MDebugPrint <"sendReadDirCommand 2\n">
		;MDebugRegisters

		ld	ft,de
		jal	UartWordOutSync

		;MDebugPrint <"sendReadDirCommand 3\n">
		;MDebugRegisters
		jal	ComSendDataString

		ld	t,ERROR_SUCCESS
		ld	f,FLAGS_EQ

.exit		pop	bc-hl
		;MDebugPrint <"sendReadDirCommand exit\n">
		;MDebugRegisters
		j	(hl)	


		SECTION	"UartFiles",BSS

uartFile1:	DS_STR
uartDir1:	DS_STR
UartVolume:	DS	ufs_SIZEOF

