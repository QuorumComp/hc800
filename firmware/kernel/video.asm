		INCLUDE	"lowlevel/hc800.i"
		INCLUDE	"lowlevel/memory.i"

		INCLUDE	"editor.i"
		INCLUDE	"keyboard.i"
		INCLUDE	"video.i"


PALETTE_BASE	EQU	$8000

; --
; -- Determine if VBlank has been encountered
; --
; -- Returns:
; --    f - "eq" condition if VBlank happened since last call
; --
		SECTION	"VideoIsVBlankEdge",CODE
VideoIsVBlankEdge:
		push	bc/hl

		ld	bc,isVBlank
		ld	t,(bc)
		cmp	t,0
		not	f
		ld	t,0
		ld	(bc),t

		pop	bc/hl
		j	(hl)


		SECTION	"VBlankHandler",CODE
VBlankHandler:
		pusha

		ld	bc,isVBlank
		ld	t,$FF
		ld	(bc),t

		jal	ScreenVBlank
		jal	KeyboardVBlank

	IF 0
		ld	bc,Count
		ld	t,(bc)
		ld	f,0
		jal	SetHexSegments
		inc	t
		ld	(bc),t
	ENDC

		popa
		j	(hl)


		SECTION	"EnableVBlank",CODE
EnableVBlank:
		pusha

		ld	b,IO_ICTRL_BASE
		ld	c,IO_ICTRL_ENABLE
		ld	t,$7F
		lio	(bc),t
		ld	c,IO_ICTRL_REQUEST
		lio	(bc),t

		ld	c,IO_ICTRL_ENABLE
		ld	t,IO_INT_SET|IO_INT_VBLANK
		lio	(bc),t

		popa
		j	(hl)


; --
; -- Load palette
; --
		SECTION	"InitializePalette",CODE
InitializePalette:
		pusha

		ld	bc,PALETTE_BASE
		ld	de,.palette
		ld	ft,.paletteEnd-.palette
		jal	CopyCode

		popa
		j	(hl)

.palette	DRGB	$0D,$05,$00
		DRGB	$1F,$1B,$16
		DRGB	$0D,$05,$00
		DRGB	$1F,$0D,$05

; 00000  00100  01001  01101  10010  10110  11011  11111
; $00,   $05,   $09,   $0D,   $12,   $16,   $1B,   $1F

; 0000  01010  10101  11111
; $00,  $0A,   $15,   $1F

.paletteEnd


		SECTION	"VideoVars",BSS
isVBlank:	DS	1
