		INCLUDE	"lowlevel/commands.i"
		INCLUDE	"lowlevel/hc800.i"
		INCLUDE	"lowlevel/nexys3.i"
		INCLUDE	"lowlevel/rc800.i"
		INCLUDE	"lowlevel/uart.i"

		INCLUDE	"stdlib/string.i"

		INCLUDE	"kernal/keyboard.i"

		INCLUDE	"editor.i"
		INCLUDE	"mmu.i"
		INCLUDE	"text.i"

CFG_VIDEO	EQU	$03
CFG_LOAD	EQU	$02

SET_MMU_CFG	MACRO
		ld	b,IO_MMU_BASE
		ld	c,IO_MMU_ACTIVE_INDEX

		ld	t,MMU_INDEX_PUSH|(\1)
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


		SECTION "SysCall",CODE[$40]

		KVector	Reset
		KVector	clearScreen
		KVector	textSetAttributes
		KVector	charOut
		KVector	executeCommandLine
		KVector	exit
		KVector debugCharOut
		KVector charIn


		SECTION "DebugCharOut",CODE
debugCharOut:
		jal	ComPrintChar

		pop	hl
		reti


		SECTION "CharOut",CODE
charOut:
		push	ft-de

		push	ft
		SET_MMU_CFG CFG_VIDEO
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
		SET_MMU_CFG CFG_VIDEO

		jal	ScreenInitialize

		RESTORE_MMU_CFG
		popa
		reti


		SECTION "Reset",CODE
Reset::
		ld	b,IO_MMU_BASE
		ld	c,IO_MMU_UPDATE_INDEX
		ld	t,CFG_VIDEO
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


		SECTION "ExecuteCommandLine",CODE
executeCommandLine:
		;MDebugPrint <"KExecuteCommandLine\n">

		push	bc-de

		push	bc
		ld	b,IO_MMU_BASE
		ld	c,IO_MMU_ACTIVE_INDEX
		ld	t,CFG_LOAD
		lio	(bc),t
		ld	c,IO_MMU_UPDATE_INDEX
		lio	(bc),t

		ld	c,IO_MMU_DATA_BANK1
		ld	t,BANK_CLIENT_DATA
		lio	(bc),t
		pop	bc

		ld	ft,bc
		ld	de,ft
		jal	copyCommandLine

		; try .com suffix

		ld	de,.comSuffix
		jal	readFileWithSuffix
		j/ne	.not_com

		jal	MmuInitializeClientCom
		j	.got_file

		; try .exe suffix
.not_com
		ld	de,.exeSuffix
		jal	readFileWithSuffix
		j/ne	.error

		;MDebugPrint <"- MmuInitializeClient\n">
		jal	MmuInitializeClientExe

.got_file
		pop	bc-de

		; top of hl stack is return address

		;MDebugPrint <"- jump\n">

		ld	hl,0
		push	hl	;push HL for reti pop
		reti

.error		push	ft

		MSetDataBank 1,$81

		ld	b,IO_MMU_BASE
		ld	c,IO_MMU_ACTIVE_INDEX
		ld	t,CFG_VIDEO
		lio	(bc),t
		ld	c,IO_MMU_UPDATE_INDEX
		lio	(bc),t

		popa
		reti

.comSuffix	DC_STR	".com"
.exeSuffix	DC_STR	".exe"


		SECTION "Exit",CODE
exit:
		di

		ld	b,IO_ICTRL_BASE
		ld	c,IO_ICTRL_ENABLE
		ld	t,$7F
		lio	(bc),t
		ld	c,IO_ICTRL_ENABLE
		ld	t,IO_INT_VBLANK|IO_INT_SET
		lio	(bc),t

		ld	b,IO_MMU_BASE
		ld	c,IO_MMU_ACTIVE_INDEX
		ld	t,CFG_VIDEO
		lio	(bc),t

		jal	MmuInitializeClientExe

		ei

		pop	hl	; discard KVector saved hl

		pop	hl	; discard hl saved by SYS
		pop	hl	; pop return address
		reti


; -- Inputs:
; --   de - suffix string
		SECTION "ReadFile",CODE
readFileWithSuffix:
		push	de/hl

		ld	bc,$4100
		ld	de,$4000
		jal	StringCopy

		pop	de
		jal	StringAppendDataString

		ld	bc,$4100
		jal	ComSendLoadFileString

		jal	readFile

		pop	hl
		j	(hl)


		SECTION "ReadFile",CODE
readFile:
		push	de-hl

		jal	ComSyncResponse
		j/ne	.done

		jal	UartWordInSync
		j/ne	.timeout

		MSetDataBank 1,BANK_CLIENT_CODE

.next_bank	tst	bc
		j/z	.done
		push	bc
		ld	ft,$4000
		cmp	bc
		j/ge	.got_size
		ld	bc,ft
.got_size	jal	.read_bytes
		j/nz	.done
		ld	ft,bc
		pop	bc
		sub	ft,bc
		ld	bc,ft
		MIncDataBank 1
		j	.next_bank

.done		pop	de-hl
		j	(hl)

.read_bytes	push	bc/hl
		ld	de,$4000
.next_byte	jal	UartByteInSync
		j/ne	.timeout_pop
		ld	(de),t
		add	de,1
		sub	bc,1
		tst	bc
		j/nz	.next_byte

		pop	ft
		ld	bc,ft
		ld	t,ERROR_SUCCESS
		j	.bytes_done

.timeout_pop	pop	ft
		sub	ft,bc
		ld	bc,ft

.timeout	ld	t,ERROR_TIMEOUT

.bytes_done	cmp	t,0
		pop	bc/hl
		j	(hl)


; --
; -- Copy and tokenize command line to first client data bank
; --
; -- Inputs:
; --   de - command line (Pascal string)
; --
copyCommandLine:
		push	hl

		ld	bc,$4000	; bc = destination

		ld	t,(de)
		add	de,1
		ld	l,t		; l = string length

		cmp	l,0
		j/z	.arguments_done
.skip_spaces	ld	t,(de)
		cmp	t,' '
		j/ne	.skipped_spaces
		add	de,1
		dj	l,.skip_spaces
		j	.arguments_done

.skipped_spaces	push	bc
		ld	t,0
		ld	(bc),t
		add	bc,1

.copy_chars	ld	t,(de)
		cmp	t,' '
		j/eq	.set_length
		add	de,1
		ld	(bc),t
		add	bc,1
		dj	l,.copy_chars

.set_length	ld	ft,bc
		push	ft
		pop	bc
		sub	ft,bc
		sub	t,1
		ld	(bc),t
		pop	ft
		ld	bc,ft
		cmp	l,0
		j/nz	.skip_spaces

.arguments_done	ld	t,0
		ld	(bc),t

		pop	hl
		j	(hl)
