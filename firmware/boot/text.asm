		INCLUDE	"lowlevel/hc800.i"
		INCLUDE	"lowlevel/memory.i"

		INCLUDE	"text.i"

		RSRESET
csr_X:		RB	1
csr_Y:		RB	1
csr_SIZEOF:	RB	0

; --
; -- Initialize text mode
; --
		SECTION	"TextInitialize",CODE
TextInitialize:
		pusha

		ld	b,IO_VIDEO_BASE

		ld	c,IO_VIDEO_CONTROL
		ld	t,IO_VID_CTRL_P0EN
		lio	(bc),t

		ld	c,IO_VID_PLANE0_CONTROL
		ld	t,IO_PLANE_CTRL_TEXT|IO_PLANE_CTRL_HIRES
		lio	(bc),t

		jal	TextClearScreen

		popa
		j	(hl)


; --
; -- Print value as hexadecimal
; --
; -- Inputs:
; --   ft - value to print
; --
		SECTION	"TextHexWordOut",CODE
TextHexWordOut:
		pusha

		exg	f,t
		jal	TextHexByteOut
		exg	f,t
		jal	TextHexByteOut

		popa
		j	(hl)


; --
; -- Set cursor to start of next line
; --
		SECTION	"TextNewline",CODE
TextNewline:	pusha

		ld	bc,videoCursor+csr_X

		ld	t,0
		ld	(bc),t
		
		add	bc,csr_Y-csr_X
		ld	t,(bc)
		add	t,1
		cmp	t,LINES_ON_SCREEN
		ld/geu	t,0
		ld	(bc),t

		popa
		j	(hl)


; --
; -- Print string from code bank
; --
; -- Inputs:
; --   bc - String
; --    t - Length
; --
		SECTION	"TextCodeStringOut",CODE
TextCodeStringOut:
		pusha

		cmp	t,0
		j/z	.done
		ld	d,t
.loop		lco	t,(bc)
		add	bc,1
		ld	f,0
		jal	TextWideCharOut
		dj	d,.loop
.done
		popa
		j	(hl)


; --
; -- Move cursor back one character
; --
		SECTION	"TextMoveCursor",CODE
TextMoveCursorBack:
		pusha

		ld	de,videoCursor+csr_X
		ld	t,(de)
		cmp	t,0
		j/z	.skip

		sub	t,1
		ld	(de),t

.skip		popa
		j	(hl)


; --
; -- Move cursor forward one character
; --
		SECTION	"TextMoveCursorForward",CODE
TextMoveCursorForward:
		pusha

		ld	de,videoCursor+csr_X
		ld	t,(de)
		cmp	t,CHARS_PER_LINE
		j/geu	.skip

		add	t,1
		ld	(de),t

.skip		popa
		j	(hl)


; --
; -- Clear text screen. Fills screen with attribute 0 and tile 0
; --
		SECTION	"TextClearScreen",CODE
TextClearScreen:
		pusha

		ld	bc,ATTRIBUTES_BASE
		ld	de,ATTRIBUTES_SIZEOF/2
		ld	ft,0
		jal	SetMemoryWords

		; Set cursor position

		ld	bc,videoCursor+csr_X
		ld	t,0
		ld	(bc),t	;csr_X

		add	bc,csr_Y-csr_X
		ld	(bc),t	;csr_Y

		popa
		j	(hl)

; --
; -- Print single character
; --
; -- Inputs:
; --   ft - Character
; --
		SECTION	"TextWideCharOut",CODE
TextWideCharOut:
		pusha

		jal	textSetWideChar
		jal	TextMoveCursorForward

		popa
		j	(hl)


; --
; -- Private functions
; --


; --
; -- Get current cursor attribute point
; --
; -- Outputs:
; --   ft - Attribute pointer
; --
		SECTION	"textGetCursorAttributePointer",CODE
textGetCursorAttributePointer:
		push	bc

		ld	bc,videoCursor+csr_Y
		ld	t,(bc)
		ld	f,ATTRIBUTES_BASE>>8
		add	t,f
		exg	f,t
		add	bc,csr_X-csr_Y
		ld	t,(bc)
		add	t,t

		pop	bc
		j	(hl)



; --
; -- Print single character
; --
; -- Inputs:
; --   ft - Character
; --
		SECTION	"textSetWideChar",CODE
textSetWideChar:
		pusha

		ld	de,ft
		jal	textGetCursorAttributePointer
		exg	de,ft

		; de = attributes address

		ld	(de),t
		add	de,1
		ld	t,0
		ld	(de),t

		popa
		j	(hl)

; --
; -- Print value as hexadecimal
; --
; -- Inputs:
; --    t - value to print
; --
		SECTION	"TextHexByteOut",CODE
TextHexByteOut:
		pusha

		ld	d,t

		ld	f,0
		rs	ft,4
		jal	textDigitOut

		ld	t,$F
		and	t,d
		jal	textDigitOut

		popa
		j	(hl)


; --
; -- Print single digit
; --
; --    t - digit ($0-$F)
; --
		SECTION	"textDigitOut",CODE
textDigitOut:
		pusha

		jal	textDigitToAscii
		ld	f,0
		jal	TextWideCharOut

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
		SECTION	"textDigitToAscii",CODE
textDigitToAscii:
		cmp	t,10
		j/ltu	.decimal
		add	t,'A'-10
		j	(hl)
.decimal	add	t,'0'
		j	(hl)



		SECTION	"TextVariables",BSS

videoCursor:	DS	csr_SIZEOF
