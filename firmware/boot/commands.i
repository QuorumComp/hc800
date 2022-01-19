	IFND	COMMANDS_I_INCLUDED_

COMMANDS_I_INCLUDED_ = 1

			RSRESET
ERROR_SUCCESS		RB	1
ERROR_NOT_AVAILABLE	RB	1
ERROR_PROTOCOL		EQU	$FE
ERROR_TIMEOUT		EQU	$FF

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

	GLOBAL	ComIdentify
	GLOBAL	ComLoadFile
	GLOBAL	ComSendLoadFileString
	GLOBAL	ComReadFile
	GLOBAL	ComRequestChar
	GLOBAL	ComPrintHexByte
	GLOBAL	ComPrintCodeChars
	GLOBAL	ComPrintChar
	GLOBAL	ComSyncResponse



	ENDC