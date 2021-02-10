		INCLUDE	"lowlevel/hc800.i"
		INCLUDE	"lowlevel/rc800.i"
		INCLUDE	"lowlevel/uart.i"

		INCLUDE	"stdlib/string.i"
		INCLUDE	"stdlib/stream.i"

		INCLUDE	"filesystems.i"
		INCLUDE	"mmu.i"
		INCLUDE	"uart_commands.i"
		INCLUDE	"video.i"

HUNK_MMU	EQU	0
HUNK_END	EQU	1
HUNK_DATA	EQU	2


		SECTION "ExecuteCommandLine",CODE
SysExecuteCommandLine::
		push	bc-de

		ld	ft,bc
		ld	de,ft
		jal	tokenizeCommandLine

		ld	t,MMU_CFG_LOAD|MMU_INDEX_PUSH
		jal	MmuActivateConfig

		jal	readExecutable

		push	ft
		ld	t,MMU_INDEX_POP
		jal	MmuActivateConfig
		pop	ft
		j/ne	.error

		; top of hl stack is return address

		ld	t,MMU_CFG_CLIENT
		jal	MmuActivateConfig

		ld	hl,0
		push	hl	;push HL for reti pop
		reti

.error		pop	hl
		reti


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

		ld	t,MMU_CFG_KERNAL
		jal	MmuActivateConfig
		jal	MmuInitialize

		jal	InitializePalette

		ei

		pop	bc-de

		pop	hl	; discard KVector saved hl

		pop	hl	; discard hl saved by SYS
		pop	hl	; pop return address

		ld	f,FLAGS_Z	; signal ok
		reti


; -- Inputs:
; --   de - commandline
		SECTION "readExecutable",CODE
readExecutable:
		push	bc-hl

		ld	bc,exeFileHandle
		jal	FileOpen
		j/ne	.error

		jal	readFile
		j/ne	.error

		jal	FileClose

.error		pop	bc-hl
		j	(hl)


; -- Inputs:
; --   bc - file handle
		SECTION "ReadFile",CODE
readFile:	push	bc-hl

		jal	readHeader
		j/ne	.error

.next_hunk	jal	readHunk
		j/eq	.next_hunk
		cmp	t,ERROR_SUCCESS

.error		pop	bc-hl
		j	(hl)


; -- Inputs:
; --   bc - file handle
		SECTION "ReadHunk",CODE
readHunk:
		push	bc-hl

		jal	FileReadByte	; hunk type
		j/ne	.exit

		ld	e,t		; e = hunk type

		jal	FileReadByte
		j/ne	.exit
		ld	d,t
		jal	FileReadByte
		j/ne	.exit
		exg	f,t
		ld	t,d		; ft = length

		exg	ft,de

		cmp	t,HUNK_MMU
		j/ne	.not_mmu
		jal	readHunkMmu
		j	.exit
.not_mmu
		cmp	t,HUNK_END
		j/ne	.not_end
		ld	t,ERROR_SUCCESS
		ld	f,FLAGS_NZ
		j	.exit
.not_end

		cmp	t,HUNK_DATA
		j/ne	.not_data
		jal	readHunkData
		j	.exit
.not_data
		; unknown hunk
		ld	ft,de
		jal	FileSkip

		ld	t,ERROR_SUCCESS
		ld	f,FLAGS_Z

.exit		pop	bc-hl
		j	(hl)

; -- Inputs:
; --   bc - file handle
; --   de - hunk length
		SECTION "ReadHunkData",CODE
readHunkData:
		push	bc-hl

		jal	FileReadByte
		j/ne	.exit

		; set data bank

		push	ft
		ld	h,IO_MMU_BASE
		ld	l,IO_MMU_UPDATE_INDEX
		ld	t,MMU_CFG_LOAD
		lio	(hl),t
		pop	ft
		add	l,IO_MMU_DATA_BANK3-IO_MMU_UPDATE_INDEX
		lio	(hl),t

		;MDebugMemory exeFileHandle,file_SIZEOF

		; load data

		sub	de,1
		ld	ft,de	; bytes to read
		ld	de,$4000
		jal	FileRead

.exit		pop	bc-hl
		j	(hl)


; -- Read MMU hunk
; -- Inputs:
; --   bc - file handle
readHunkMmu:
		push	bc-hl

		ld	ft,MMU_CONFIG_SIZE
		ld	de,mmuConfig
		jal	FileRead
		j/ne	.error

		ld	t,(de)
		or	t,MMU_CFG_SYS_HARVARD
		ld	(de),t

		ld	t,MMU_CFG_CLIENT
		jal	MmuSetConfigData

.error		pop	bc-hl
		j	(hl)


; -- Read header and check if it is 'UC'
; -- Inputs:
; --   bc - file handle
readHeader:
		push	de/hl

		jal	FileReadByte
		j/ne	.exit
		ld	d,t
		jal	FileReadByte
		j/ne	.exit
		ld	e,t

		sub	de,'UC'
		tst	de
		ld	t,ERROR_FORMAT

.exit		pop	de/hl
		j	(hl)

; --
; -- Copy and tokenize command line to first client data bank
; --
; -- Inputs:
; --   de - command line (Pascal string)
; --
tokenizeCommandLine:
		pusha

		ld	ft,de
		ld	bc,ft

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

		popa
		j	(hl)


		SECTION	"CommandlineVars",BSS
exeFileHandle:	DS	file_SIZEOF
mmuConfig:	DS	MMU_CONFIG_SIZE
