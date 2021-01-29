		INCLUDE	"lowlevel/uart.i"
		INCLUDE	"stdlib/string.i"
		INCLUDE	"uart_commands.i"

IDENT_NONCE	EQU	$1234


; -- Print value as hexadecimal
; --
; -- Inputs:
; --   ft - value to print
		SECTION	"ComPrintHexWord",CODE
ComPrintHexWord:
		pusha

		exg	f,t
		jal	ComPrintHexByte
		exg	f,t
		jal	ComPrintHexByte

		popa
		j	(hl)


; -- Print value as hexadecimal
; --
; -- Inputs:
; --    t - value to print
		SECTION	"ComPrintHexByte",CODE
ComPrintHexByte:
		pusha

		ld	f,0
		rs	ft,4
		jal	ComPrintDigit

		ld	t,d
		and	t,$F
		jal	ComPrintDigit

		popa
		j	(hl)

; --
; -- Print single digit
; --
; --    t - digit ($0-$F)
; --
		SECTION	"ComPrintDigit",CODE
ComPrintDigit:
		pusha

		jal	DigitToAscii
		jal	ComPrintChar

		popa
		j	(hl)

; --
; -- Print character to attached terminal
; --
; -- Inputs:
; --    t - character
; --
; -- Outputs:
; --    f - "eq" condition if success
; --
		SECTION	"ComPrintChar",CODE
ComPrintChar:
		pusha

		ld	t,COMMAND_PRINT_CHAR
		jal	ComSendCommand

		pop	ft
		jal	UartByteOutSync

		jal	ComSyncResponse

		pop	bc-hl
		j	(hl)

; --
; -- Request character from attached terminal
; --
; -- Outputs:
; --    f - "eq" condition if success
; --    t - character
; --
		SECTION "ComRequestChar",CODE
ComRequestChar:
		push	bc-hl

		ld	t,COMMAND_REQUEST_CHAR
		jal	ComSendCommand

		jal	ComSyncResponse
		j/ne	.done

		jal	UartByteInSync

.done		pop	bc-hl
		j	(hl)

; --
; -- Attempts to identify UART file server
; --
; -- Returns:
; --    t - error code, 0 is success
; --    f - "eq" condition if success
; --
		SECTION "ComIdentify",CODE
ComIdentify:
		push	bc-hl

		jal	comSendIdentify
		jal	comReadIdentify

		pop	bc-hl
		j	(hl)


; --
; -- Send load file command
; --
; -- Inputs:
; --   bc - file name (Pascal string, data segment)
; --
		SECTION "ComSendLoadFileString",CODE
ComSendLoadFileString:
		pusha

		ld	t,COMMAND_LOAD_FILE
		jal	ComSendCommand

		ld	t,(bc)
		add	bc,1
		ld	f,0
		jal	UartWordOutSync		; filename length

		ld	f,t
.write_string	ld	t,(bc)
		jal	UartByteOutSync
		add	bc,1
		dj	f,.write_string

		ld	ft,0
		jal	UartWordOutSync		; offset
		jal	UartWordOutSync		; offset
		jal	UartWordOutSync		; length
		jal	UartWordOutSync		; length

		popa
		j	(hl)

; --
; -- Read protocol response, return error code
; --
; -- Outputs:
; --	f - "eq" condition if success
; --    t - error code, 0 = success
; --
		SECTION "ComSyncResponse",CODE
ComSyncResponse:
		push	bc-hl

		jal	UartByteInSync
		j/ne	.timeout

		cmp	t,'!'
		j/ne	.protocol_error

		jal	UartByteInSync
		j	.done

.protocol_error	ld	t,ERROR_PROTOCOL
		j	.done	

.timeout	ld	t,ERROR_TIMEOUT

.done		cmp	t,0
		pop	bc-hl
		j	(hl)


; --
; -- Send command byte
; --
; -- Inputs:
; --    t - command
; --
		SECTION "SendCommand",CODE
ComSendCommand:
		pusha

		ld	f,'?'
		exg	f,t
		jal	UartWordOutSync

		popa
		j	(hl)


; --
; -- Send string in UART format
; --
; -- Inputs:
; --   bc - Pascal string
; --
ComSendDataString:
		pusha

		ld	f,0
		ld	t,(bc)
		add	bc,1
		jal	UartWordOutSync		; filename length

		ld	f,t
.write_string	ld	t,(bc)
		jal	UartByteOutSync
		add	bc,1
		dj	f,.write_string

		popa
		j	(hl)


; --
; -- Internal functions
; --

; --
; -- Receive file
; --
; -- Inputs:
; --   de - destination
; --
; -- Outputs:
; --    t - error code (0 = success)
; --    f - "eq" condition if success
; --   bc - bytes read
; --
		SECTION "ComReadFile",CODE
comReadFile:
		push	de-hl

		jal	ComSyncResponse
		j/ne	.done

		jal	UartWordInSync
		j/ne	.timeout

		ld	ft,bc
		push	ft

.loop		jal	UartByteInSync
		j/ne	.timeout_pop
		ld	(de),t
		add	de,1
		sub	bc,1
		tst	bc
		j/nz	.loop

		pop	ft
		ld	bc,ft
		ld	t,ERROR_SUCCESS
		j	.done

.timeout_pop	pop	ft
		sub	ft,bc
		ld	bc,ft

.timeout	ld	t,ERROR_TIMEOUT

.done		cmp	t,0
		pop	de-hl
		j	(hl)


; --
; -- Send load file command
; --
; -- Inputs:
; --    t - file name length
; --   bc - file name (code segment)
; --
		SECTION "ComSendLoadFile",CODE
comSendLoadFile:
		pusha

		push	ft
		ld	t,COMMAND_LOAD_FILE
		jal	ComSendCommand
		pop	ft

		; t - already filename length
		ld	f,0
		jal	UartWordOutSync		; filename length

		ld	f,t
.write_string	lco	t,(bc)
		jal	UartByteOutSync
		add	bc,1
		dj	f,.write_string

		ld	ft,0
		jal	UartWordOutSync		; offset
		jal	UartWordOutSync		; offset
		jal	UartWordOutSync		; length
		jal	UartWordOutSync		; length

		popa
		j	(hl)

; -- Outputs:
; --    t - error code, 0 = success
; --    f - "eq" if success
		SECTION "ReadIdentify",CODE
comReadIdentify:
		push	bc-hl

		jal	ComSyncResponse
		j/ne	.done

		jal	UartWordInSync
		j/ne	.timeout

		ld	ft,~IDENT_NONCE
		cmp	bc
		j/ne	.protocol

		ld	t,ERROR_SUCCESS
		j	.test

.protocol	ld	t,ERROR_PROTOCOL
		j	.test

.timeout	ld	t,ERROR_TIMEOUT

.test		cmp	t,0
.done		pop	bc-hl
		j	(hl)


		SECTION "SendIdentify",CODE
comSendIdentify:
		pusha

		ld	t,COMMAND_IDENTIFY
		jal	ComSendCommand

		ld	ft,IDENT_NONCE
		jal	UartWordOutSync

		popa
		j	(hl)
