		INCLUDE	"commands.i"
		INCLUDE	"rc800.i"
		INCLUDE	"hc800.i"
		INCLUDE "memory.i"
		INCLUDE "nexys3.i"
		INCLUDE "text.i"
		INCLUDE	"main.i"

		IMPORT	VBlankHandler

Debug:		MACRO
		pusha
		ld	ft,\1
		jal	SetHexSegments
		popa
		ENDM

		SECTION "Init",CODE[0]
		ld	ft,Init
		j	(ft)

		SECTION "NMI",CODE[$8]
		ld	t,$08
		ld	de,Fail
		j	(de)

		SECTION "Interrupt",CODE[$10]
		pusha
		ld	hl,Interrupt
		j	(hl)

		SECTION "IllegalInstruction",CODE[$18]
		ld	t,$18
		ld	de,Fail
		j	(de)

		SECTION "StackOverflow",CODE[$20]
		ld	t,$20
		ld	de,Fail
		j	(de)

		SECTION "IllegalIrq",CODE[$28]
		ld	t,$28
		ld	de,Fail
		j	(de)

		SECTION "Ident",CODE[$100]
Ident:		DB	"HC8!"


		SECTION "Fail",CODE
Fail:
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
Init:
		jal	InitializeMMU

		pop	hl
		ld	hl,Main
		push	hl
		reti


		SECTION "MMU",CODE
InitializeMMU:
		push	hl

		ld	de,.mmuData02
		ld	f,.mmuDataEnd02-.mmuData02
		jal	.copy

		ld	de,.mmuData03
		ld	f,.mmuDataEnd03-.mmuData03

		pop	hl

.copy		ld	b,IO_MMU_BASE
		ld	c,0
.loop		lco	t,(de)
		add	de,1
		lio	(bc),t
		add	c,1
		dj	f,.loop

		j	(hl)

.mmuData03
		DB	$03			; update index
		DB	MMU_CONFIG_HARVARD	; config bits
		DB	$01,$81,$82,$83		; code banks
		DB	$80,$81,BANK_PALETTE,BANK_ATTRIBUTE	; data banks
		DB	$01,$80			; system code/data
		DB	$03			; active index
		DB	$08			; chargen
.mmuDataEnd03

.mmuData02
		DB	$02			; update index
		DB	MMU_CONFIG_HARVARD	; config bits
		DB	BANK_CLIENT_CODE+0	; code banks
		DB	BANK_CLIENT_CODE+1
		DB	BANK_CLIENT_CODE+2
		DB	BANK_CLIENT_CODE+3
		DB	BANK_CLIENT_DATA+0	; data banks
		DB	BANK_CLIENT_DATA+1
		DB	BANK_CLIENT_DATA+2
		DB	BANK_CLIENT_DATA+3
		DB	$01,$80			; system code/data
.mmuDataEnd02


		SECTION "InterruptHandler",CODE

Interrupt:
		ld	b,IO_ICTRL_BASE
		ld	c,IO_CHP_ICTRL_HANDLE
		lio	t,(bc)
		ld	d,t

		and	t,IO_INT_VBLANK
		cmp	t,0
		j/z	.no_vblank
		jal	VBlankHandler
.no_vblank

		ld	c,IO_CHP_ICTRL_REQUEST
		ld	t,d
		lio	(bc),t

		popa
		reti		


