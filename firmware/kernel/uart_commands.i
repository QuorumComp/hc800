		INCLUDE	ONCE


COMMAND_IDENTIFY	EQU	0
COMMAND_LOAD_FILE	EQU	1
COMMAND_REQUEST_CHAR	EQU	2
COMMAND_PRINT_CHAR	EQU	3
COMMAND_STAT_FILE	EQU	4
COMMAND_READ_DIR	EQU	5

		PURGE	MDebugPrint
MDebugPrint:	MACRO
	IF _DEBUG
		PUSHS
		SECTION "DebugStrings",CODE
.string\@	DB	\1
.skip\@
		POPS
		pusha
		ld	t,.skip\@-.string\@
		ld	bc,.string\@
		jal	ComPrintCodeChars
		popa
	ENDC
		ENDM

		PURGE	MDebugPrintR
MDebugPrintR:	MACRO	;register
	IF _DEBUG
		IF	"\1".lower.compareto("hl")==0
			FAIL "Register HL is an invalid argument"
		ENDC
		pusha
		ld	t,(\1)
		ld	l,t
		add	\1,1
.next\@		ld	t,(\1)
		add	\1,1
		push	hl
		jal	ComPrintChar
		pop	hl
		j/ne	.error\@
		dj	l,.next\@
.error\@	popa
	ENDC
		ENDM

		PURGE	MDebugNewLine
MDebugNewLine:	MACRO
	IF _DEBUG
		pusha
		ld	t,10
		jal	ComPrintChar
		popa
	ENDC
		ENDM

		PURGE	MDebugHexWord
MDebugHexWord:	MACRO	;register
	IF _DEBUG
		pusha
		IF	"\1".lower.compareto("ft")~=0
		ld	ft,\1
		ENDC
		jal	ComPrintHexWord
		popa
	ENDC
		ENDM

		PURGE	MDebugHexLong
MDebugHexLong:	MACRO	;register
	IF _DEBUG
		MDebugHexWord \1
		swap	\1
		MDebugHexWord \1
		swap	\1
	ENDC
		ENDM

		PURGE	MDebugHexByte
MDebugHexByte:	MACRO	;register
	IF _DEBUG
		pusha
		IF	"\1".lower.compareto("t")~=0
		ld	t,\1
		ENDC
		jal	ComPrintHexByte
		popa
	ENDC
		ENDM

		PURGE	MDebugRegisters
MDebugRegisters: MACRO
	IF _DEBUG
		push	hl
		jal	ComPrintRegisterOverview
		pop	hl
	ENDC
		ENDM

		PURGE	MDebugMemory
MDebugMemory:	MACRO	;memory,size
	IF _DEBUG
		pusha
		IF	"\1".lower.compareto("bc")~=0
			IF	"\1".lower.compareto("ft")~=0
				ld	ft,\1
			ENDC
			ld	bc,ft
		ENDC
		ld	de,\2
		jal	ComDumpMemory
		popa
	ENDC
		ENDM


	GLOBAL	ComIdentify
	GLOBAL	ComLoadFile
	GLOBAL	ComSendLoadFileString
	GLOBAL	ComReadFile
	GLOBAL	ComRequestChar
	GLOBAL	ComDumpMemory
	GLOBAL	ComPrintHexByte
	GLOBAL	ComPrintHexWord
	GLOBAL	ComPrintChar
	GLOBAL	ComPrintCodeChars
	GLOBAL	ComSendCommand
	GLOBAL	ComSendDataString
	GLOBAL	ComReadDataString
	GLOBAL	ComSyncResponse
	GLOBAL	ComPrintRegisterOverview
