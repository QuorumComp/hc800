	IFND	COMMANDS_I_INCLUDED_

COMMANDS_I_INCLUDED_ = 1

COMMAND_IDENTIFY	EQU	0
COMMAND_LOAD_FILE	EQU	1
COMMAND_REQUEST_CHAR	EQU	2
COMMAND_PRINT_CHAR	EQU	3
COMMAND_STAT_FILE	EQU	4

			RSRESET
ERROR_SUCCESS		RB	1
ERROR_NOT_AVAILABLE	RB	1
ERROR_FORMAT		RB	1
ERROR_PROTOCOL		EQU	$FE
ERROR_TIMEOUT		EQU	$FF

MDebugPrint:	MACRO
		pusha
		j	.skip\@
.string\@	DB	\1
.skip\@		ld	d,.skip\@-.string\@
		ld	bc,.string\@
.next\@		lco	t,(bc)
		add	bc,1
		jal	ComPrintChar
		j/ne	.error\@
		dj	d,.next\@
.error\@	popa
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

MDebugNewline:	MACRO
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

MDebugRegisters: MACRO
		pusha
		pusha

		pop	ft
		jal	ComPrintHexWord
		ld	t,' '
		jal	ComPrintChar

		pop	bc
		ld	ft,bc
		jal	ComPrintHexWord
		ld	t,' '
		jal	ComPrintChar

		pop	de
		ld	ft,de
		jal	ComPrintHexWord
		ld	t,' '
		jal	ComPrintChar

		pop	hl
		ld	ft,hl
		jal	ComPrintHexWord
		ld	t,10
		jal	ComPrintChar

		popa
		ENDM

MDebugMemory:	MACRO	;memory,size
		pusha
	IF	"\1".lower.compareto("de")==0
		ld	ft,\1
		ld	bc,ft
	ELSE
		IF	"\1".lower.compareto("bc")~=0
			ld	bc,\1
		ENDC
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
	GLOBAL	ComPrintHexByte
	GLOBAL	ComPrintHexWord
	GLOBAL	ComPrintChar
	GLOBAL	ComSendCommand
	GLOBAL	ComSendDataString
	GLOBAL	ComSyncResponse



	ENDC