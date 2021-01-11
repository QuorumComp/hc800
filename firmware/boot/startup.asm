		INCLUDE	"lowlevel/rc800.i"
		INCLUDE	"lowlevel/hc800.i"
		INCLUDE "lowlevel/memory.i"
		
		INCLUDE "text.i"
		INCLUDE	"main.i"

PALETTE_BASE	EQU	$8000

		SECTION "Reset",CODE[0]
Entry::		di

		ld	ft,0
		ld	bc,0
		ld	de,0
		ld	hl,0

		; Set stack upper and lower bound

		ld	c,RC8_SP_HIGH
		ld	t,RC8_STACK_SIZE-1
		lcr	(c),t
		ld	c,RC8_SP_LOW
		ld	t,0
		lcr	(c),t

		; Set stack pointers. This will also change register contents, so don't rely on anything

		ld	c,RC8_SP_FT
		ld	t,255
		lcr	(c),t

		ld	c,RC8_SP_BC
		ld	t,255
		lcr	(c),t

		ld	c,RC8_SP_DE
		ld	t,255
		lcr	(c),t

		ld	c,RC8_SP_HL
		ld	t,255
		lcr	(c),t

		; Stack initialization done

		jal	InitializeMMU
		jal	InitializePalette
		jal	TextInitialize
		jal	ClearIrq

		ld	ft,Main
		j	(ft)


; --
; -- Load palette
; --
InitializePalette:
		pusha

		ld	bc,PALETTE_BASE
		ld	de,.palette
		ld	ft,.paletteEnd-.palette
		jal	CopyCode

		popa
		j	(hl)

.palette	DRGB	$00,$00,$09
		DRGB	$1F,$1F,$1F
.paletteEnd


; --
; -- Stop IRQ and clear requests
; --
ClearIrq:
		ld	b,IO_ICTRL_BASE
		ld	c,IO_ICTRL_ENABLE
		ld	t,$7F
		lio	(bc),t
		ld	c,IO_ICTRL_REQUEST
		lio	(bc),t

		j	(hl)

; --
; -- Set MMU to a config suitable for loading kernal
; --
InitializeMMU:
		ld	b,IO_MMU_BASE
		ld	c,0
		ld	de,.mmuData
		ld	f,.mmuDataEnd-.mmuData

.copy
		lco	t,(de)
		add	de,1
		lio	(bc),t
		add	c,1
		dj	f,.copy

		j	(hl)

.mmuData
		DB	$03			; update index
		DB	MMU_CONFIG_HARVARD	; config bits
		DB	$00,$00,$80,$80		; code banks
		DB	$80,$01,BANK_PALETTE,BANK_ATTRIBUTE	; data banks
		DB	$01,$01			; system code/data
		DB	$03			; active index
		DB	$08			; chargen
.mmuDataEnd


