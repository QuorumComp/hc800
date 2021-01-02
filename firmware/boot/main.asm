		INCLUDE	"hc800.i"

		INCLUDE	"commands.i"
		INCLUDE	"main.i"
		INCLUDE	"memory.i"
		INCLUDE	"uart.i"
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

		ld	bc,$4100
		ld	de,.ident
		ld	h,4

.ident_loop	ld	t,(bc)
		add	bc,1
		ld	f,t
		lco	t,(de)
		add	de,1
		cmp	t,f
		j/ne	.ident_false
		dj	h,.ident_loop
		ld	t,ERROR_SUCCESS
		j	.done

.ident_false	MPrintString "Kernal missing ident. Failure."
		MNewline
		ld	t,ERROR_PROTOCOL
.done
		cmp	t,0
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
		push	bc-hl

		ld	b,IO_ICTRL_BASE
		ld	c,IO_CHP_ICTRL_REQUEST
		lio	t,(bc)
		ld	f,IO_INT_VBLANK
		and	t,f
		lio	(bc),t
		cmp	t,0
		not	f

		pop	bc-hl
		j	(hl)
