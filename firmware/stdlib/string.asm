		INCLUDE	"string.i"

; --
; -- Clear a string (set it to the empty string)
; --
; -- Inputs:
; --   bc - pointer to string
; --
		SECTION	"StringClear",CODE
StringClear:
		push	ft

		ld	t,0
		ld	(bc),t

		pop	ft
		j	(hl)


; --
; -- Trim white space off string end
; --
; -- Inputs:
; --   bc - pointer to string
; --
		SECTION	"StringTrimRight",CODE
StringTrimRight:
		push	ft
		push	bc

		ld	t,(bc)
		ld	f,0
		add	ft,bc
		ld	bc,ft

.find		ld	t,(bc)
		sub	bc,1
		cmp	t,' '
		j/leu	.find

		ld	ft,bc
		pop	bc
		sub	ft,bc
		add	t,1
		ld	(bc),t

		pop	ft
		j	(hl)


; --
; -- Append character to end of string
; --
; -- Inputs:
; --    t - character to append
; --   bc - pointer to string
; --
; -- Outputs:
; --    t - new string length
; --
		SECTION	"StringAppendChar",CODE
StringAppendChar:
		push	bc/de

		ld	d,t
		ld	t,(bc)
		add	t,1
		ld	(bc),t
		ld	f,0
		add	ft,bc
		ld	bc,ft
		ld	t,d
		ld	(bc),t

		pop	bc/de
		j	(hl)


; --
; -- Convert digit (any base) to ASCII
; --
; -- Inputs:
; --    t - digit
; --
; -- Outputs:
; --    t - character
; --
		SECTION	"DigitToAscii",CODE
DigitToAscii:
		cmp	t,10
		j/ltu	.decimal
		add	t,'A'-10
		j	(hl)
.decimal	add	t,'0'
		j	(hl)
