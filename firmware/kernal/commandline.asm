		INCLUDE	"lowlevel/hc800.i"
		INCLUDE	"lowlevel/rc800.i"
		INCLUDE	"lowlevel/uart.i"

		INCLUDE	"stdlib/string.i"

		INCLUDE	"filesystems.i"
		INCLUDE	"mmu.i"
		INCLUDE	"uart_commands.i"
		INCLUDE	"video.i"


		SECTION "ExecuteCommandLine",CODE
SysExecuteCommandLine::
		;MDebugPrint <"KExecuteCommandLine\n">

		push	bc-de

		push	bc
		ld	b,IO_MMU_BASE
		ld	c,IO_MMU_ACTIVE_INDEX
		ld	t,MMU_CFG_CLIENT
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
		ld	t,MMU_CFG_KERNAL
		lio	(bc),t
		ld	c,IO_MMU_UPDATE_INDEX
		lio	(bc),t

		popa
		reti

.comSuffix	DC_STR	".com"
.exeSuffix	DC_STR	".exe"


		SECTION "Exit",CODE
SysExit::
		di

		ld	b,IO_ICTRL_BASE
		ld	c,IO_ICTRL_ENABLE
		ld	t,$7F
		lio	(bc),t
		ld	c,IO_ICTRL_ENABLE
		ld	t,IO_INT_VBLANK|IO_INT_SET
		lio	(bc),t

		ld	b,IO_VIDEO_BASE
		ld	c,IO_VIDEO_CONTROL
		ld	t,IO_VID_CTRL_P0EN
		lio	(bc),t

		ld	c,IO_VID_PLANE0_CONTROL
		ld	t,IO_PLANE_CTRL_HIRES|IO_PLANE_CTRL_TEXT
		lio	(bc),t

		ld	t,0
		ld	c,IO_VID_PLANE0_HSCROLLL
		lio	(bc),t
		ld	c,IO_VID_PLANE0_HSCROLLH
		lio	(bc),t
		ld	c,IO_VID_PLANE0_VSCROLLL
		lio	(bc),t
		ld	c,IO_VID_PLANE0_VSCROLLH
		lio	(bc),t

		ld	b,IO_MMU_BASE
		ld	c,IO_MMU_ACTIVE_INDEX
		ld	t,MMU_CFG_KERNAL
		lio	(bc),t

		jal	MmuInitializeClientExe
		jal	InitializePalette

		ei

		pop	hl	; discard KVector saved hl

		pop	hl	; discard hl saved by SYS
		pop	hl	; pop return address

		ld	f,FLAGS_Z	; signal ok
		reti


; -- Inputs:
; --   de - suffix string
		SECTION "ReadFile",CODE
readFileWithSuffix:
		push	bc-hl

		push	de
		ld	bc,$4100
		ld	de,$4000
		jal	StringCopy
		pop	de

		jal	StringAppendDataString

		ld	bc,exeFileHandle
		ld	de,$4100
		jal	FileOpen
		j/ne	.error

		jal	readFile
		j/ne	.error

		jal	FileClose

.error		pop	bc-de
		j	(hl)


		SECTION "ReadFile",CODE
readFile:	push	bc-hl

		MSetDataBank 1,BANK_CLIENT_CODE

.next_bank	ld	ft,$4000
		ld	de,ft
		ld	bc,exeFileHandle
		jal	FileRead

		ld	hl,ft

		add	bc,file_Error
		ld	t,(bc)
		cmp	t,ERROR_SUCCESS
		j/ne	.exit

		ld	ft,hl
		cmp	ft,de
		j/ltu	.success

		MIncDataBank 1
		j	.next_bank

.success	ld	t,ERROR_SUCCESS
		cmp	t,0
.exit		pop	bc-hl
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


		SECTION	"CommandlineVars",BSS
exeFileHandle:	DS	file_SIZEOF
