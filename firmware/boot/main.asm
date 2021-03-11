		INCLUDE	"lowlevel/hc800.i"
		INCLUDE	"lowlevel/memory.i"
		INCLUDE	"lowlevel/rc800.i"
		INCLUDE	"lowlevel/uart.i"

		INCLUDE	"commands.i"
		INCLUDE	"main.i"
		INCLUDE "text.i"

MPrintString:	MACRO
		j	.skip\@
.string\@	DB	\1
.skip\@		pusha
		ld	t,.skip\@-.string\@
		ld	bc,.string\@
		jal	TextCodeStringOut
		popa
		ENDM

MNewline:	MACRO
		pusha
		jal	TextNewline
		popa
		ENDM

		SECTION	"Main",CODE
Main:
		MPrintString "HC800 Boot ROM"
		MNewline

.wait_uart	jal	WaitUart

		jal	LoadKernal
		j/ne	.wait_uart

		jal	CheckKernal
		j/ne	.wait_uart

		sys	0


; --
; -- Load kernal into kernal bank
; --
; -- Returns:
; --    f - "z" condition if success
; --
LoadKernal:
		push	bc-hl

		ld	bc,$4000
		ld	de,$4000
		ld	t,0
		jal	SetMemory

		MPrintString "Loading kernal"
		ld	t,.kernal_length
		ld	bc,.kernal_name
		ld	de,$4000
		jal	ComLoadFile

		MPrintString <", ">

		push	ft
		MPrintString "$"
		ld	ft,bc
		jal	TextHexWordOut
		MPrintString " bytes loaded."
		pop	ft

		j/z	.done

		MPrintString " Failure."

.done		MNewline
		pop	bc-hl
		j	(hl)

.kernal_name	DB	"kernal.bin"
.kernal_length	EQU	@-.kernal_name

; --
; -- Check if kernal is a valid kernal
; --
; -- Returns:
; --    f - "z" condition if success
; --    t - error code
; --
CheckKernal:
		push	bc-hl

		ld	bc,$4000
		LDLOOP	de,$4000
		ld	ft,0
.checksum	ld	t,(bc)
		add	bc,1
		add	t,f
		ld	f,t
		dj	e,.checksum
		dj	d,.checksum

		; t equals zero (ERROR_SUCCESS) if checksum match
		cmp	t,0
		j/eq	.done

.ident_false	MPrintString "Kernal checksum mismatch. Failure."
		MNewline
		ld	t,ERROR_PROTOCOL
		ld	f,FLAGS_NE
.done
		pop	bc-hl
		j	(hl)

.ident		DB	"HC8!"


; --
; -- Wait for UART host to appear
; --
WaitUart:
		pusha
		MPrintString "Waiting for UART host ... "

		ld	bc,0	; spin index
.wait		jal	Spin
		jal	EmptyReceiveBuffer
		jal	ComIdentify
		j/ne	.wait

		MPrintString "found"
		MNewline

		popa
		j	(hl)


; --
; -- Show spinner.
; --
; -- Inputs:
; --   bc - spinner value
; --
; -- Outputs:
; --   bc - new spinner value
; --
Spin:		push	ft/de/hl

		ld	ft,bc
		add	c,1
		push	bc

		and	t,3
		add	ft,.spin
		lco	t,(ft)
		ld	f,0
		jal	TextWideCharOut

		jal	TextMoveCursorBack

		popa
		j	(hl)

.spin		DB	'-\\|/'


; --
; -- Clear out the reciever buffer
; --
EmptyReceiveBuffer:
		pusha

		ld	b,5
.more		jal	UartByteIn
		j/eq	.more
		jal	VideoIsVBlankEdge
		j/ne	.more
		dj	b,.more

		popa
		j	(hl)


; --
; -- Determine if VBlank has been encountered
; --
; -- Returns:
; --    f - "eq" condition if VBlank happened since last call
; --
VideoIsVBlankEdge:
		push	hl

		ld	h,IO_ICTRL_BASE
		ld	l,IO_ICTRL_REQUEST
		lio	t,(hl)
		and	t,IO_INT_VBLANK
		lio	(hl),t
		cmp	t,IO_INT_VBLANK

		pop	hl
		j	(hl)
