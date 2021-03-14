	IFND	COMMANDS_DISABLED_I_INCLUDED_

COMMANDS_DISABLED_I_INCLUDED_ = 1

	INCLUDE	"uart_commands.i"

		PURGE	MDebugPrint
MDebugPrint:	MACRO
		ENDM

		PURGE	MDebugPrintR
MDebugPrintR:	MACRO	;register
		ENDM

		PURGE	MDebugNewLine
MDebugNewLine:	MACRO
		ENDM

		PURGE	MDebugHexWord
MDebugHexWord:	MACRO	;register
		ENDM

		PURGE	MDebugRegisters
MDebugRegisters: MACRO
		ENDM

		PURGE	MDebugMemory
MDebugMemory:	MACRO	;memory,size
		ENDM


	ENDC