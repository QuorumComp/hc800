	IFND	VIDEO_COMMON_I_INCLUDED_

VIDEO_COMMON_I_INCLUDED_ = 1

CHARS_PER_LINE	EQU	90
LINES_ON_SCREEN	EQU	30

ATTRIBUTES_BASE	EQU	$C000

		RSRESET
csr_X:		RB	1
csr_Y:		RB	1
csr_Attribute:	RB	1
csr_SIZEOF:	RB	0

	GLOBAL	VideoCursor

	GLOBAL	TextInitialize
	GLOBAL	TextClearScreen
	GLOBAL	TextMoveCursor
	GLOBAL	TextSetAttributes
	GLOBAL	TextSetWideChar
	GLOBAL	TextWideCharOut
	GLOBAL	TextGetCursorAttributePointer


	ENDC