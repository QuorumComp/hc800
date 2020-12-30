		INCLUDE	"hc800.i"

		INCLUDE	"commands.i"
		INCLUDE	"main.i"
		INCLUDE	"memory.i"
		INCLUDE	"uart.i"
		INCLUDE "video.i"
		INCLUDE "video_common.i"

MPrintString:	MACRO
		j	.skip\@
.string\@	DB	\1
.skip\@		pusha
		ld	t,.skip\@-.string\@
		ld	bc,.string\@
		jal	TextCodeStringOut
		popa
		ENDM

MPrintStringAt:	MACRO
		j	.skip\@
.string\@	DB	\3
.skip\@		pusha
		ld	b,\1
		ld	c,\2
		jal	TextSetCursor
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

		MLoadFile "kernal.bin",$4000

		MPrintString <", ">

		push	ft
		ld	ft,bc
		jal	TextHexWordOut
		MPrintString " bytes loaded."
		pop	ft

		j/z	.done

		MPrintString " Failure."

.done		MNewline
		pop	bc-hl
		j	(hl)

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
; -- Show spinner
; --
Spin:		pusha
		pop	bc

		ld	t,c
		add	t,1
		and	t,3
		ld	c,t
		push	bc

		ld	ft,.spin
		add	ft,bc
		lco	t,(ft)
		ld	f,0
		jal	TextWideCharOut

		ld	b,-1
		ld	c,0
		jal	TextMoveCursor

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

		ld	b,IO_CHIPSET_BASE
		ld	c,IO_CHP_ICTRL_REQUEST
		lio	t,(bc)
		ld	f,IO_INT_VBLANK
		and	t,f
		lio	(bc),t
		cmp	t,0
		not	f

		pop	bc-hl
		j	(hl)
