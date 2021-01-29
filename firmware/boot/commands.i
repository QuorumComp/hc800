	IFND	COMMANDS_I_INCLUDED_

COMMANDS_I_INCLUDED_ = 1

			RSRESET
ERROR_SUCCESS		RB	1
ERROR_NOT_AVAILABLE	RB	1
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

	GLOBAL	ComIdentify
	GLOBAL	ComLoadFile
	GLOBAL	ComSendLoadFileString
	GLOBAL	ComReadFile
	GLOBAL	ComRequestChar
	GLOBAL	ComPrintHexByte
	GLOBAL	ComPrintChar
	GLOBAL	ComSyncResponse



	ENDC