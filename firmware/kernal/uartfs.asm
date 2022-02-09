		INCLUDE	"lowlevel/rc800.i"
		INCLUDE	"lowlevel/uart.i"
		INCLUDE	"stdlib/string.i"
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
		pusha

		ld	bc,UartFilesystem
		ld	de,.fs
		ld	f,.fs_end-.fs
.copy		lco	t,(de)
		ld	(bc),t
		add	de,1
		add	bc,1
		dj	f,.copy

		popa
		j	(hl)

.fs		DB	4,"uart",0,0,0,0,0,0,0,0,0,0,0
		DB	0,0,0,0,0,0,0,0
		DB	$FF
		DW	uartOpen
		DW	uartClose
		DW	uartRead
		DW	uartOpenDir
		DW	uartReadDir
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

		MDebugPrint <"uart:Open ">
		MDebugPrintR de
		MDebugNewLine

		ld	bc,uartFile1
		ld	de,ft

		jal	StringCopy
		jal	sendStatFileCommand

		jal	ComSyncResponse
		j/ne	.done

		jal	UartByteInSync
		j/ne	.timeout

		add	de,file_Flags
		ld	(de),t

		add	de,file_Length-file_Flags
		ld	ft,de
		ld	bc,ft
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
; --   bc - pointer to file struct
; --
; -- Output:
; --    t - Error code
; --    f - "eq" if success
; --
		SECTION	"UartClose",CODE
uartClose:
		ld	f,FLAGS_EQ
		ld	t,ERROR_SUCCESS
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
; --   bc - pointer to directory struct
; --   de - path
; --
; -- Output:
; --    f - "eq" if directory could be opened. Directory struct is filled in
; --        with information on first file
; --
		SECTION "UartOpenDir",CODE
uartOpenDir:
		push	bc-hl

		ld	bc,uartDir1
		jal	StringCopy

		pop	bc
		add	bc,udir_Index

		ld	t,0
		ld	(bc),t
		add	bc,1
		ld	(bc),t

		sub	bc,udir_Index+1

		jal	uartReadDir

		pop	de-hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Read next file information from directory
; --
; -- Inputs:
; --   bc - pointer to directory struct
; --
; -- Output:
; --    f - "eq" if next file information could be retrieved. Directory
; --        struct is filled in with information on file.
; --        "ne" when no more files present.
; --
		SECTION "UartReadDir",CODE
uartReadDir:
		push	bc-hl

		ld	t,ERROR_SUCCESS
		add	bc,dir_Error
		ld	(bc),t

		; fetch index
		add	bc,udir_Index+1-dir_Error
		ld	t,(bc)
		exg	f,t
		sub	bc,1
		ld	t,(bc)

		; increment index and store
		push	ft
		add	ft,1
		ld	(bc),t
		add	bc,1
		exg	f,t
		ld	(bc),t
		pop	ft

		; send read dir command
		ld	bc,uartDir1
		jal	sendReadDirCommand

		; read response
		jal	ComSyncResponse
		j/ne	.error

		; filename
		pop	bc
		push	bc

		add	bc,dir_Filename
		jal	ComReadDataString
		j/ne	.error

		; directory flag
		jal	UartByteInSync
		j/ne	.error

		add	bc,dir_Flags-dir_Filename
		and	t,FFLAG_DIR
		ld	(bc),t

		; file length

		add	bc,dir_Length-dir_Flags
		ld	de,4
		jal	UartMemoryInSync

.exit		pop	bc-hl
		j	(hl)

.error		pop	bc
		push	bc
		add	bc,dir_Error
		ld	(bc),t
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
		push	bc-hl

		ld	de,ft

		jal	ComIdentify
		j/ne	.exit

		ld	t,COMMAND_READ_DIR
		jal	ComSendCommand

		ld	ft,de
		jal	UartWordOutSync

		jal	ComSendDataString

		ld	t,ERROR_SUCCESS
		ld	f,FLAGS_EQ

.exit		pop	bc-hl
		j	(hl)


		SECTION	"UartFiles",BSS

uartFile1:	DS_STR
uartDir1:	DS_STR
UartFilesystem:	DS	ufs_SIZEOF

