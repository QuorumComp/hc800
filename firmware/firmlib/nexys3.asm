		INCLUDE	"nexys3.i"

; -- Check if buttons are pressed
; -- 
; -- Inputs:
; --   t - button mask
; --
; -- Outputs:
; --   f - "z" condition if all buttons in mask are down
		SECTION	"CheckButtons",CODE

CheckButtons:
		push	bc-hl

		ld	d,t
		ld	b,IO_NEXYS3_BASE
		ld	c,IO_NEXYS3_BUTTONS
		lio	t,(bc)
		and	t,d
		cmp	d

		pop	bc-hl
		j	(hl)


; -- Set hex segments
; -- 
; -- Inputs:
; --   ft - value to set
		SECTION	"SetHexSegments",CODE
SetHexSegments:
		pusha

		ld	b,IO_NEXYS3_BASE
		ld	c,IO_NEXYS3_HEX_LOWER
		lio	(bc),t
		add	c,1
		exg	f,t
		lio	(bc),t

		popa
		j	(hl)


