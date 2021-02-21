		INCLUDE	"lowlevel/hc800.i"
		INCLUDE "lowlevel/memory.i"
		INCLUDE "lowlevel/nexys3.i"
		INCLUDE	"lowlevel/rc800.i"

		INCLUDE	"main.i"
		INCLUDE	"mmu.i"
		INCLUDE "text.i"
		INCLUDE "uart_commands.i"

		IMPORT	VBlankHandler

Debug:		MACRO
		pusha
		ld	ft,\1
		jal	SetHexSegments
		popa
		ENDM

		SECTION "Init",CODE[0],ROOT
		ld	ft,Init
		j	(ft)

		SECTION "NMI",CODE[$8],ROOT
		ld	t,$08
		ld	de,FailEntry
		j	(de)

		SECTION "IllegalIrq",CODE[$10],ROOT
		ld	t,$10
		ld	de,FailEntry
		j	(de)

		SECTION "IllegalInstruction",CODE[$18],ROOT
		ld	t,$18
		ld	de,FailEntry
		j	(de)

		SECTION "StackOverflow",CODE[$20],ROOT
		ld	t,$20
		ld	de,FailEntry
		j	(de)

		SECTION "Interrupt",CODE[$28],ROOT
		pusha
		ld	hl,Interrupt
		j	(hl)

		SECTION "Ident",CODE[$100],ROOT
Ident:		DB	"HC8!"


		SECTION "FailEntry",CODE
FailEntry:
		di
		push	hl
		jal	ComPrintHexByte
		MDebugPrint <" vector crashed at ">
		pop	hl
		ld	ft,hl
		ld	de,ft
		ld	t,d
		jal	ComPrintHexByte
		ld	t,e
		jal	ComPrintHexByte
		ld	t,10
		jal	ComPrintChar

		ld	f,$FF
		jal	SetHexSegments
.spin		j	.spin


		SECTION "Startup",CODE
Init::
		jal	MmuInitialize

		pop	hl
		ld	hl,Main
		push	hl
		reti


		SECTION "InterruptHandler",CODE

Interrupt:
		ld	b,IO_ICTRL_BASE
		ld	c,IO_ICTRL_HANDLE
		lio	t,(bc)
		ld	d,t

		and	t,IO_INT_VBLANK
		cmp	t,0
		j/z	.no_vblank
		jal	VBlankHandler
.no_vblank

		ld	c,IO_ICTRL_REQUEST
		ld	t,d
		lio	(bc),t

		popa
		reti		


