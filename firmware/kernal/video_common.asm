		INCLUDE	"video_common.i"
		INCLUDE	"memory.i"
		INCLUDE	"hc800.i"
		INCLUDE	"nexys3.i"

		SECTION	"VideoCommon",CODE

; --
; -- Initialize text mode
; --
		SECTION	"TextInitialize",CODE
TextInitialize:
		pusha

		ld	b,IO_VIDEO_BASE
		ld	c,IO_VID_PLANE0_CONTROL
		ld	t,IO_PLANE_CTRL_TEXT|IO_PLANE_CTRL_HIRES|IO_PLANE_CTRL_ENABLE
		lio	(bc),t

		ld	b,$FF
		ld	c,$00
		jal	TextSetAttributes
		jal	TextClearScreen

		popa
		j	(hl)


; --
; -- Move cursor
; --
; -- Inputs:
; --  b - delta X
; --  c - delta Y
; --
		SECTION	"TextMoveCursor",CODE
TextMoveCursor:
		pusha

		ld	de,VideoCursor+csr_X

		cmp	b,0
		j/z	.move_y

		ld	t,(de)
		add	t,b
		cmp	t,0
		j/ge	.x_positive

		; wrap to previous line and move up
		add	de,csr_Y-csr_X
		ld	t,(de)
		sub	de,1
		cmp	t,0
		j/z	.move_y
		ld	t,CHARS_PER_LINE-1
		sub	c,1

.x_positive	ld	(de),t
		cmp	t,CHARS_PER_LINE
		j/ltu	.move_y

		add	de,1
		ld	t,(de)
		sub	de,1
		cmp	t,LINES_ON_SCREEN-1
		j/ne	.x_wrap
		ld	t,CHARS_PER_LINE-1
		ld	(de),t
		j	.move_y

.x_wrap		ld	t,0
		ld	(de),t
		add	c,1

.move_y		cmp	c,0
		j/z	.done

		add	de,1
		ld	t,(de)
		add	t,c
		cmp	t,0
		j/ge	.y_positive
		ld	t,0
.y_positive	ld	(de),t
		cmp	t,LINES_ON_SCREEN
		j/lt	.done

		ld	t,LINES_ON_SCREEN-1
		ld	(de),t

.done		popa
		j	(hl)


; --
; -- Clear text screen. Fills screen with current attribute and tile 0
; --
		SECTION	"TextClearScreen",CODE
TextClearScreen:
		pusha

		ld	bc,VideoCursor+csr_X
		push	bc

		add	bc,csr_Attribute-csr_X
		ld	t,(bc)
		exg	f,t
		ld	t,0

		ld	bc,ATTRIBUTES_BASE
		ld	de,ATTRIBUTES_SIZEOF/2
		jal	SetMemoryWords

		; Set cursor position

		pop	bc

		ld	t,0
		ld	(bc),t	;csr_X

		add	bc,csr_Y-csr_X
		ld	(bc),t	;csr_Y

		popa
		j	(hl)

; --
; -- Set current text attribute
; --
; -- Inputs:
; --    b - mask of bits to affect
; --    c - new bits
; --
		SECTION	"TextSetAttributes",CODE
TextSetAttributes:
		pusha

		ld	t,b
		not	t
		ld	b,t
		ld	de,VideoCursor+csr_Attribute
		ld	t,(de)
		and	t,b
		or	t,c
		ld	(de),t

		popa
		j	(hl)


; Outputs:
;   ft - Attribute pointer
		SECTION	"TextGetCursorAttributePointer",CODE
TextGetCursorAttributePointer:
		push	bc

		ld	bc,VideoCursor+csr_Y
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
		SECTION	"TextWideChar",CODE
TextSetWideChar:
		pusha

		ld	de,ft
		jal	TextGetCursorAttributePointer
		exg	de,ft

		; de = attributes address

		ld	(de),t
		add	de,1
		ld	bc,VideoCursor+csr_Attribute
		ld	t,(bc)
		or	t,f
		ld	(de),t

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

		jal	TextSetWideChar

		; move cursor in X direction
		ld	b,1
		ld	c,0
		jal	TextMoveCursor

		popa
		j	(hl)


		SECTION	"TextVariables",BSS

VideoCursor:	DS	csr_SIZEOF
