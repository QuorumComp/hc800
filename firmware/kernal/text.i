	IFND	TEXT_I_INCLUDED_

FLASH:		MACRO
		pusha
		ld	d,255
		ld	ft,$8000
		ld	c,(ft)
		add	ft,1
		ld	b,(ft)
.loop\@		add	bc,1
		ld	(ft),b
		sub	ft,1
		ld	(ft),c
		add	ft,1
		dj	d,.loop\@
		popa
		ENDM

VIDEO_EXT_I_INCLUDED_ = 1

VATTR_ITALIC	EQU	$08
VATTR_BOLD	EQU	$04
VATTR_UNDERLINE	EQU	$02

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



	ENDC