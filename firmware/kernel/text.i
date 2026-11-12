		INCLUDE	ONCE

FLASH:		MACRO
		pusha
		ld	d,255
		ld	ft,$8000
		ld	c,(ft+)		; the pair ascends: FT ends one past it
		ld	b,(ft+)
		sub	ft,2		; back to the low byte, where each pass starts
.loop\@		add	bc,1
		ld	(ft+),c
		ld	(ft+),b
		sub	ft,2		; same address every pass, as before
		dj	d,.loop\@
		popa
		ENDM

CHARS_PER_LINE	EQU	90
LINES_ON_SCREEN	EQU	30

ATTRIBUTES_BASE	EQU	$C000

		RSRESET
csr_X:		RB	1
csr_Y:		RB	1
csr_Attribute:	RB	1
csr_SIZEOF:	RB	0

	GLOBAL	TextInitialize
	GLOBAL	TextClearScreen
	GLOBAL	TextMoveCursor
	GLOBAL	TextSetAttributes
	GLOBAL	TextSetWideChar
	GLOBAL	TextWideCharOut
	GLOBAL	TextDeleteCharacterAtCursor
	GLOBAL	TextDeleteCharacter
	GLOBAL	TextInsertEmptyCharacter
	GLOBAL	TextScrollLinesDown
	GLOBAL	TextScrollLinesUp
	GLOBAL	TextGetCharacterAt
	GLOBAL	TextSetCharacterAt
	GLOBAL	TextGetCursor
	GLOBAL	TextSetCursor
	GLOBAL	TextSetAttributesAtCursor
	GLOBAL	TextGetAttributePointer

	GLOBAL	VideoCursor
