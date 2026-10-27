		INCLUDE	"lowlevel/hc800.i"
		INCLUDE "lowlevel/memory.i"
		INCLUDE "lowlevel/nexys3.i"
		INCLUDE	"lowlevel/rc800.i"

		INCLUDE	"main.i"
		INCLUDE	"mmu.i"
		INCLUDE "text.i"
		INCLUDE	"video.i"
		INCLUDE "uart_commands.i"

Debug:		MACRO
		pusha
		ld	ft,\1
		jal	SetHexSegments
		popa
		ENDM

		SECTION "Init",CODE[0],ROOT
		ld	ft,Init
		j	(ft)

		SECTION "Checksum",CODE[7],ROOT
		DB	0

		SECTION "Interrupt",CODE[$28],ROOT
		pusha
		ld	hl,Interrupt
		j	(hl)


		; Reserve the zero page so a null pointer has a defined, harmless
		; target. ROOT keeps it linked even if nothing references it; the
		; startup clear zeroes [0,$4000), so these bytes start at zero.
		SECTION	"ZeroPage",BSS[0],ROOT
nullPage:	DS	2


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


