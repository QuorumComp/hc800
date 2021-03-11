		INCLUDE	"lowlevel/hc800.i"
		INCLUDE	"lowlevel/nexys3.i"
		INCLUDE	"lowlevel/rc800.i"

		INCLUDE	"stdlib/string.i"

		INCLUDE	"kernal/keyboard.i"

		INCLUDE	"editor.i"
		INCLUDE	"main.i"
		INCLUDE	"mmu.i"
		INCLUDE	"text.i"
		INCLUDE	"uart_commands.i"
		INCLUDE	"video.i"

		IMPORT	SysExecuteCommandLine
		IMPORT	SysExit
		IMPORT	SysGetBlockDevice

SET_MMU_KERNAL	MACRO
		ld	b,IO_MMU_BASE
		ld	c,IO_MMU_ACTIVE_INDEX

		ld	t,MMU_INDEX_PUSH|MMU_CFG_KERNAL
		lio	(bc),t
		ENDM

RESTORE_MMU_CFG	MACRO
		ld	b,IO_MMU_BASE
		ld	c,IO_MMU_ACTIVE_INDEX

		ld	t,MMU_INDEX_POP
		lio	(bc),t
		ENDM


KVector:	MACRO
		CNOP	0,8
		push	hl
		ld	hl,\1
		j	(hl)
		ENDM


		SECTION "SysCall",CODE[$40],ROOT

		KVector	reset
		KVector	clearScreen
		KVector	textSetAttributes
		KVector	charOut
		KVector	SysExecuteCommandLine
		KVector	SysExit
		KVector debugCharOut
		KVector charIn
		KVector SysGetBlockDevice


		SECTION "DebugCharOut",CODE
debugCharOut:
		jal	ComPrintChar

		pop	hl
		reti


		SECTION "CharOut",CODE
charOut:
		push	ft-de

		push	ft
		SET_MMU_KERNAL
		pop	ft

		jal	ScreenCharacterOut

		RESTORE_MMU_CFG
		popa
		reti


		SECTION "CharIn",CODE
charIn:
		jal	KeyboardRead
		pop	hl
		reti


		SECTION "SetAttribute",CODE
textSetAttributes:
		jal	TextSetAttributes
		pop	hl
		reti


		SECTION "ClearScreen",CODE
clearScreen:
		push	ft-de
		SET_MMU_KERNAL

		jal	ScreenInitialize

		RESTORE_MMU_CFG
		popa
		reti


		SECTION "reset",CODE
reset:
		ld	b,IO_MMU_BASE
		ld	c,IO_MMU_UPDATE_INDEX
		ld	t,MMU_CFG_KERNAL
		lio	(bc),t

		ld	t,$00
		ld	c,IO_MMU_CONFIGURATION
		lio	(bc),t
		ld	c,IO_MMU_CODE_BANK0
		lio	(bc),t
		ld	c,IO_MMU_DATA_BANK0
		lio	(bc),t

		pop	hl
		ld	hl,0
		reti


