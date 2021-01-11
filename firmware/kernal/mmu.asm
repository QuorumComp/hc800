		INCLUDE	"lowlevel/hc800.i"

		INCLUDE	"mmu.i"


		SECTION "MMU",CODE
MmuInitialize:
		push	hl

		jal	MmuInitializeClient

		ld	de,.mmuData03
		ld	f,.mmuDataEnd03-.mmuData03

		ld	b,IO_MMU_BASE
		ld	c,0
.loop		lco	t,(de)
		add	de,1
		lio	(bc),t
		add	c,1
		dj	f,.loop

		pop	hl
		j	(hl)

.mmuData03:	DB	$03			; update index
		DB	MMU_CONFIG_HARVARD	; config bits
		DB	$01,$81,$82,$83		; code banks
		DB	$80,$81,BANK_PALETTE,BANK_ATTRIBUTE	; data banks
		DB	$01,$80			; system code/data
		DB	$03			; active index
		DB	$08			; chargen
.mmuDataEnd03:


MmuInitializeClient:
		pusha

		ld	t,2
.next_config	push	ft
		jal	.copy
		pop	ft
		dj	t,.next_config

		popa
		j	(hl)

.copy		ld	b,IO_MMU_BASE
		ld	c,IO_MMU_UPDATE_INDEX
		lio	(bc),t

		ld	de,.mmuData02
		ld	f,.mmuDataEnd02-.mmuData02
		ld	c,IO_MMU_CONFIGURATION
.loop		lco	t,(de)
		add	de,1
		lio	(bc),t
		add	c,1
		dj	f,.loop

		j	(hl)

.mmuData02	DB	MMU_CONFIG_HARVARD	; config bits
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


