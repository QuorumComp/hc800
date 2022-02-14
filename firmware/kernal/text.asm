		INCLUDE	"lowlevel/hc800.i"
		INCLUDE	"lowlevel/memory.i"
		INCLUDE	"lowlevel/math.i"

		INCLUDE	"stdlib/stream.i"

		INCLUDE	"text.i"


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
		jal	textGetCursorAttributePointer
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


; --
; -- Delete character at cursor position
; --
		SECTION	"TextDeleteCharacterAtCursor",CODE
TextDeleteCharacterAtCursor:
		pusha

		jal	TextGetCursor
		j	deleteCharEntry

; --
; -- Delete character at position
; --
; -- Inputs:
; --    f - X
; --    t - Y
; --
TextDeleteCharacter:
		pusha

deleteCharEntry:
		push	ft
		jal	TextGetAttributePointer
		ld	bc,ft
		add	bc,2
		pop	ft

		ld	t,CHARS_PER_LINE
		sub	t,f
		add	t,t
		ld	f,t			; f = bytes to copy

.loop		ld	t,(bc)
		sub	bc,2
		ld	(bc),t
		add	bc,3
		dj	f,.loop

		ld	ft,VideoCursor+csr_Attribute
		ld	t,(ft)
		sub	bc,2
		ld	(bc),t
		add	bc,1
		ld	t,0
		ld	(bc),t

		popa
		j	(hl)



; --
; -- Insert empty character
; --
; -- Inputs:
; --    f - X
; --    t - Y
; --
		SECTION	"TextInsertEmptyCharacter",CODE
TextInsertEmptyCharacter:
		pusha

		ld	hl,ft

		add	t,ATTRIBUTES_BASE>>8
		ld	b,t
		ld	c,CHARS_PER_LINE*2-3

		ld	t,CHARS_PER_LINE-1
		sub	t,h
		cmp	t,0
		j/z	.clear
		add	t,t
		ld	f,t

.loop		ld	t,(bc)
		add	bc,2
		ld	(bc),t
		sub	bc,3
		dj	f,.loop

.clear		ld	ft,VideoCursor+csr_Attribute
		ld	t,(ft)

		add	bc,1
		ld	(bc),t
		add	bc,1
		ld	t,0
		ld	(bc),t

		popa
		j	(hl)


; --
; -- Insert empty line
; --
; -- Inputs:
; --    t - Y of line to insert
; --
		SECTION	"TextScrollLinesDown",CODE
TextScrollLinesDown:
		pusha

		cmp	t,LINES_ON_SCREEN
		j/geu	.exit

		ld	f,t
		ld	t,LINES_ON_SCREEN
		sub	t,f
		ld	b,t

		; b = lines to copy

		ld	ft,ATTRIBUTES_BASE+(LINES_ON_SCREEN-1)*256
		ld	hl,ft
		ld	de,ft
		sub	d,1
		j	.loop_entry

.loop		ld	f,CHARS_PER_LINE*2
.attr_loop	ld	t,(de)
		add	de,1
		ld	(hl),t
		add	hl,1
		dj	f,.attr_loop

		sub	d,1
		ld	e,0
		sub	h,1
		ld	l,0
.loop_entry	dj	b,.loop

		ld	de,VideoCursor+csr_Attribute
		ld	t,(de)
		ld	d,t
		ld	e,0

		ld	f,CHARS_PER_LINE
.clear_loop	ld	t,e
		ld	(hl),t
		add	hl,1
		ld	t,d
		ld	(hl),t
		add	hl,1
		dj	f,.clear_loop

.exit		popa
		j	(hl)


; --
; -- Scroll lines up
; --
; -- Inputs:
; --    t - Y of line to remove, the rest will be moved up
; --
		SECTION	"TextScrollLinesUp",CODE
TextScrollLinesUp:
		pusha

		cmp	t,0
		j/lt	.exit

		push	ft

		sub	t,LINES_ON_SCREEN-1
		neg	t
		ld	b,t

		; b = lines to copy

		pop	ft
		ld	f,ATTRIBUTES_BASE>>8
		add	t,f
		ld	f,t
		ld	t,0

		ld	hl,ft
		ld	de,ft
		add	d,1

.loop		ld	f,CHARS_PER_LINE*2
.attr_loop	ld	t,(de)
		add	de,1
		ld	(hl),t
		add	hl,1
		dj	f,.attr_loop

		add	d,1
		ld	e,0
		add	h,1
		ld	l,0
		dj	b,.loop

		ld	t,0
		ld	f,CHARS_PER_LINE*2
.clear_loop	ld	(hl),t
		add	hl,1
		dj	f,.clear_loop

.exit		popa
		j	(hl)


; --
; -- Get character at coordinate
; --
; -- Inputs:
; --    f - X
; --    t - Y
; --
; -- Outputs:
; --   ft - Character
; --
		SECTION	"TextGetCharacterAt",CODE
TextGetCharacterAt:
		push	bc-hl

		jal	TextGetAttributePointer
		ld	bc,ft

		add	bc,1
		ld	t,(bc)
		sub	bc,1
		and	t,$01
		exg	f,t
		ld	t,(bc)
		
		pop	bc-hl
		j	(hl)


; --
; -- Set character at coordinate
; --
; -- Inputs:
; --   ft - character
; --    b - X
; --    c - Y
; --
		SECTION	"TextSetCharacterAt",CODE
TextSetCharacterAt:
		pusha

		ld	de,ft

		ld	ft,bc
		jal	TextGetAttributePointer
		ld	bc,ft

		ld	t,e
		ld	(bc),t
		add	bc,1

		ld	ft,VideoCursor+csr_Attribute
		ld	t,(ft)
		or	t,d
		ld	(bc),t
		
		popa
		j	(hl)


; --
; -- Get cursor coordinate
; --
; -- Outputs:
; --    f - X
; --    t - Y
; --
		SECTION	"TextGetCursor",CODE
TextGetCursor:
		push	bc-hl

		ld	bc,VideoCursor+csr_X
		ld	t,(bc)
		exg	f,t
		add	bc,1
		ld	t,(bc)

		pop	bc-hl
		j	(hl)


; --
; -- Move cursor
; --
; -- Inputs:
; --    b - X
; --    c - Y
; --
		SECTION	"TextSetCursor",CODE
TextSetCursor:
		pusha

		ld	de,VideoCursor+csr_X

		ld	t,b
		ld	(de),t
		add	de,1

		ld	t,c
		ld	(de),t

		popa
		j	(hl)


; --
; -- Set attributes at cursor
; --
; -- Inputs:
; --    b - mask of bits to affect
; --    c - new bits
; --
		SECTION	"TextSetAttributesAtCursor",CODE
TextSetAttributesAtCursor:
		pusha

		ld	t,c
		and	t,b
		ld	c,t

		jal	textGetCursorAttributePointer
		add	t,1
		
		ld	de,ft
		ld	t,b
		not	t
		ld	b,t
		ld	t,(de)
		
		and	t,b
		or	t,c
		ld	(de),t

		popa
		j	(hl)


; --
; -- Get pointer to attribute map at coordinate
; --
; -- Inputs:
; --    f - X
; --    t - Y
; --
; -- Outputs:
; --   ft - Attribute pointer
; --
TextGetAttributePointer:
		push	bc

		add	t,ATTRIBUTES_BASE>>8
		exg	f,t
		add	t,t

		pop	bc
		j	(hl)



; ---------------------------------------------------------------------------
; -- Private functions
; ---------------------------------------------------------------------------

; --
; -- Return the pointer to the attribute under the cursor
; --
; -- Outputs:
; --   ft - Attribute pointer
; --
		SECTION	"textGetCursorAttributePointer",CODE
textGetCursorAttributePointer:
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




		SECTION	"TextVariables",BSS

VideoCursor:	DS	csr_SIZEOF
