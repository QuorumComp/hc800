	IFND	STRING_I_INCLUDED_

STRING_I_INCLUDED_ = 1

STRING_SIZE	EQU	256

DS_STR:	MACRO	;maxLength
	DS	1+(\1)
	ENDM

DC_STR:	MACRO	;string
	DB	\1.length
	DB	\1
	ENDM

	GLOBAL	StringClear
	GLOBAL	StringTrimRight
	GLOBAL	StringAppendChar
	GLOBAL	DigitToAscii

	ENDC