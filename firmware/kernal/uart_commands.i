	IFND	COMMANDS_I_INCLUDED_

COMMANDS_I_INCLUDED_ = 1

COMMAND_IDENTIFY	EQU	0
COMMAND_LOAD_FILE	EQU	1
COMMAND_REQUEST_CHAR	EQU	2
COMMAND_PRINT_CHAR	EQU	3
COMMAND_STAT_FILE	EQU	4
COMMAND_READ_DIR	EQU	5

			RSRESET
ERROR_SUCCESS		RB	1
ERROR_NOT_AVAILABLE	RB	1
ERROR_FORMAT		RB	1
ERROR_PROTOCOL		EQU	$FE
ERROR_TIMEOUT		EQU	$FF

		PURGE	MDebugPrint

MDebugPrint:	MACRO
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
		ENDM

MDebugPrintR:	MACRO	;register
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
		ENDM

MDebugNewLine:	MACRO
		pusha
		ld	t,10
		jal	ComPrintChar
		popa
		ENDM

MDebugHexWord:	MACRO	;register
		pusha
		IF	"\1".lower.compareto("ft")~=0
		ld	ft,\1
		ENDC
		jal	ComPrintHexWord
		popa
		ENDM

MDebugHexLong:	MACRO	;register
		MDebugHexWord \1
		swap	\1
		MDebugHexWord \1
		swap	\1
		ENDM

MDebugHexByte:	MACRO	;register
		pusha
	IF	"\1".lower.compareto("t")~=0
		ld	t,\1
	ENDC
		jal	ComPrintHexByte
		popa
		ENDM

MDebugRegisters: MACRO
		pusha
		push	hl
		jal	ComPrintRegisters
		popa
		ENDM

MDebugStacks:	MACRO
		pusha
		jal	ComPrintStackPointers
		popa
		ENDM

MDebugMemory:	MACRO	;memory,size
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
		ENDM

	GLOBAL	ComIdentify
	GLOBAL	ComLoadFile
	GLOBAL	ComSendLoadFileString
	GLOBAL	ComReadFile
	GLOBAL	ComRequestChar
	GLOBAL	ComDumpMemory
	GLOBAL	ComPrintStackPointers
	GLOBAL	ComPrintHexByte
	GLOBAL	ComPrintHexWord
	GLOBAL	ComPrintChar
	GLOBAL	ComPrintCodeChars
	GLOBAL	ComSendCommand
	GLOBAL	ComSendDataString
	GLOBAL	ComReadDataString
	GLOBAL	ComSyncResponse
	GLOBAL	ComPrintRegisters



	ENDC