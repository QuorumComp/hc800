		INCLUDE	"commands.i"
		INCLUDE	"uart.i"

COMMAND_IDENTIFY	EQU	0
COMMAND_LOAD_FILE	EQU	1
COMMAND_REQUEST_CHAR	EQU	2
COMMAND_PRINT_CHAR	EQU	3

		SECTION	"Commands",CODE

		IFND	BOOT

; -- Print value as hexadecimal
; --
; -- Inputs:
; --    t - value to print
		SECTION	"ComPrintHexByte",CODE
ComPrintHexByte:
		pusha

		ld	d,t

		ld	f,0
		ld	e,4
		rs	ft,e
		jal	ComPrintDigit

		ld	t,$F
		and	t,d
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

		jal	digitToAscii
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
		SECTION	"PrintChar",CODE
ComPrintChar:
		pusha

		ld	t,COMMAND_PRINT_CHAR
		jal	sendCommand

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
		SECTION "RequestChar",CODE
ComRequestChar:
		push	bc-hl

		ld	t,COMMAND_REQUEST_CHAR
		jal	sendCommand

		jal	ComSyncResponse
		j/ne	.done

		jal	UartByteInSync

.done		pop	bc-hl
		j	(hl)

		ENDC

; --
; -- Load file into memory
; --
; -- Inputs:
; --    t - file name length
; --   bc - file name
; --   de - destination
; --
; -- Outputs:
; --    t - error code, 0 is success
; --    f - "z" condition if success
; --   bc - bytes read
; --
		SECTION "LoadFile",CODE
ComLoadFile:
		push	hl

		push	ft
		jal	ComIdentify
		pop	ft

		jal	ComSendLoadFile
		jal	ComReadFile

		pop	hl
		j	(hl)


; --
; -- Attempts to identify UART file server
; -- Returns:
; --    t - error code, 0 is success
; --    f - "eq" condition if success
; --
		SECTION "Identify",CODE
ComIdentify:
		push	bc-hl

		jal	sendIdentify
		jal	readIdentify

		pop	bc-hl
		j	(hl)


; --
; -- Send load file command
; --
; -- Inputs:
; --   bc - file name (Pascal string, data segment)
; --
		SECTION "SendLoadFileString",CODE
ComSendLoadFileString:	pusha

		ld	t,COMMAND_LOAD_FILE
		jal	sendCommand

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
		jal	UartWordOutSync		; length

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
		SECTION "ReadFile",CODE
ComReadFile:
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
		SECTION "SendLoadFile",CODE
ComSendLoadFile:
		pusha

		push	ft
		ld	t,COMMAND_LOAD_FILE
		jal	sendCommand
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
		SECTION "SyncResponse",CODE
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

; -- Outputs:
; --    t - error code, 0 = success
; --    f - "eq" if success
		SECTION "ReadIdentify",CODE
readIdentify:
		push	bc-hl

		jal	ComSyncResponse
		j/ne	.done

		jal	UartWordInSync
		j/ne	.timeout

		ld	ft,~$1234
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
sendIdentify:
		pusha

		ld	t,COMMAND_IDENTIFY
		jal	sendCommand

		ld	ft,$1234
		jal	UartWordOutSync

		popa
		j	(hl)


; --
; -- Send command byte
; --
; -- Inputs:
; --    t - command
; --
		SECTION "SendCommand",CODE
sendCommand:
		pusha

		ld	f,'?'
		exg	f,t
		jal	UartWordOutSync

		popa
		j	(hl)


; --
; -- Convert digit (any base) to ASCII
; --
; -- Inputs:
; --    t - digit
; --
; -- Outputs:
; --    t - character
; --
		SECTION	"DigitToAscii",CODE
digitToAscii:
		cmp	t,10
		j/ltu	.decimal
		ld	f,'A'-10
		j	.next
.decimal	ld	f,'0'
.next		add	t,f

		j	(hl)

