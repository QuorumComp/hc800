		INCLUDE	"math.i"
		INCLUDE	"video.i"
		INCLUDE	"stream.i"

		SECTION	"Video",CODE

; --
; -- Delete character at cursor position
; --
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
; -- Get character at coordinate
; --
; -- Inputs:
; --    f - X
; --    t - Y
; --
; -- Outputs:
; --   ft - Character
; --
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
TextSetAttributesAtCursor:
		pusha

		ld	t,c
		and	t,b
		ld	c,t

		jal	TextGetCursorAttributePointer
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


TextPushAttributes:
		pusha

		pop	ft
		ld	de,ft

		ld	bc,VideoCursor+csr_Attribute
		ld	t,(bc)
		ld	f,0
		push	ft
		ld	ft,de
		push	ft

		popa
		j	(hl)


TextPopAttributes:
		push	bc-hl

		ld	de,ft

		pop	ft
		ld	bc,VideoCursor+csr_Attribute
		ld	(bc),t

		ld	ft,de

		pop	bc-hl
		j	(hl)

; --
; -- Print value as decimal
; --
; -- Inputs:
; --   ft - value to print
; --
TextDecimalWordOut:
		pusha

		ld	de,ft
		tst	de
		j/z	.print_zero

		ld	ft,de
		jal	.recurse
		j	.exit

.print_zero	ld	t,0
		jal	StreamDigitOut

.exit		popa
		j	(hl)

.recurse
		pusha

		ld	de,ft
		tst	de
		j/z	.recurse_done

		ld	ft,10
		push	de
		ld	de,0
		jal	UnsignedDivide

		jal	.recurse

		ld	ft,de
		jal	StreamDigitOut

.recurse_done	popa
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

		ld	b,ATTRIBUTES_BASE>>8
		add	t,b
		exg	f,t
		add	t,t

		pop	bc
		j	(hl)


