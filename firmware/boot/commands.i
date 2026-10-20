		INCLUDE	ONCE

			RSRESET
ERROR_PROTOCOL		RB	1
ERROR_TIMEOUT		RB	1
ERROR_SUCCESS		RB	1
ERROR_NOT_AVAILABLE	RB	1
ERROR_FORMAT		RB	1
ERROR_last		RB	0

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

	GLOBAL	ComIdentify
	GLOBAL	ComLoadFile
	GLOBAL	ComSendLoadFileString
	GLOBAL	ComReadFile
	GLOBAL	ComRequestChar
	GLOBAL	ComPrintHexByte
	GLOBAL	ComPrintCodeChars
	GLOBAL	ComPrintChar
	GLOBAL	ComSyncResponse
