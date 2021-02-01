		INCLUDE	"lowlevel/rc800.i"
		INCLUDE	"lowlevel/uart.i"
		INCLUDE	"stdlib/string.i"
		INCLUDE	"filesystems.i"
		INCLUDE	"uart_commands.i"
		INCLUDE	"uartfs.i"

		SECTION	"UartFilesystem",CODE

UartFilesystem:
		DW	uartName
		DW	uartOpen
		DW	uartClose
		DW	uartRead

uartName:	DC_STR	"uart"


; ---------------------------------------------------------------------------
; -- Open file over UART. file_Flags, file_Error and file_Length are filled
; -- in.
; --
; -- Inputs:
; --   bc - pointer to file struct
; --   de - pointer to filename (Pascal string)
; --
; -- Output:
; --    t - Error code
; --    f - "eq" if success
; --
		SECTION	"UartOpen",CODE
uartOpen:	
		push	bc-hl

		push	bc
		ld	bc,uartFile1
		jal	StringCopy
		jal	sendStatFileCommand
		pop	bc

		jal	ComSyncResponse
		j/ne	.done

		jal	UartByteInSync
		j/ne	.timeout

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
		pop	bc

		push	bc

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
.exit
		pop	hl
		j	(hl)



		SECTION	"UartFiles",BSS

uartFile1:	DS_STR

