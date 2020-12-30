	IFND	VIDEO_EXT_I_INCLUDED_

	INCLUDE	"video_common.i"

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
	GLOBAL	TextPushAttributes
	GLOBAL	TextPopAttributes
	GLOBAL	TextDecimalWordOut
	GLOBAL	TextGetAttributePointer

	ENDC