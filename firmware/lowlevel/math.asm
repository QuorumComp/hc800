		INCLUDE	"hc800.i"
		INCLUDE	"math.i"

; --
; -- Multiply two integers
; --
; -- Inputs:
; --   ft - integer #1
; --   de - integer #2
; --
; -- Outputs:
; --   de:ft - 32 bit result
; --
		SECTION	"SignedMultiply",CODE
SignedMultiply:
		push	bc

		ld	b,IO_MATH_BASE
		ld	c,IO_MATH_X

		exg	f,t
		lio	(bc),t
		exg	f,t
		lio	(bc),t

		add	c,1

		ld	t,d
		lio	(bc),t
		ld	t,e
		lio	(bc),t

		ld	c,IO_MATH_OPERATION
		ld	t,MATH_OP_SIGNED_MUL
		lio	(bc),t

		nop
		ld	c,IO_MATH_Z

		lio	t,(bc)
		ld	e,t
		lio	t,(bc)
		ld	d,t

		lio	t,(bc)
		exg	f,t
		lio	t,(bc)
		exg	f,t

		pop	bc
		j	(hl)


DIVIDE:		MACRO
		push	bc

		ld	b,IO_MATH_BASE
		ld	c,IO_MATH_Y

		exg	f,t
		lio	(bc),t
		exg	f,t
		lio	(bc),t

		add	c,1

		ld	t,d
		lio	(bc),t
		ld	t,e
		lio	(bc),t

		pop	de

		ld	t,d
		lio	(bc),t
		ld	t,e
		lio	(bc),t

		ld	c,IO_MATH_OPERATION
		ld	t,\1
		lio	(bc),t

		nop
		ld	c,IO_MATH_Y

		lio	t,(bc)
		ld	e,t
		lio	t,(bc)
		ld	d,t

		sub	c,1

		lio	t,(bc)
		exg	f,t
		lio	t,(bc)
		exg	f,t

		pop	bc
		j	(hl)
		ENDM


; --
; -- Divide two integers
; --
; -- Inputs:
; --   ft   - divisor
; --   de*2 - dividend (2*16 bit, high word on top)
; --
; -- Outputs:
; --   ft - quotient
; --   de - remainder
; --
		SECTION	"UnsignedDivide",CODE
UnsignedDivide:
		DIVIDE	MATH_OP_UNSIGNED_DIV

; --
; -- Divide two integers
; --
; -- Inputs:
; --   ft   - divisor
; --   de*2 - dividend (2*16 bit, high word on top)
; --
; -- Outputs:
; --   ft - quotient
; --   de - remainder
; --
		SECTION	"SignedDivide",CODE
SignedDivide:
		DIVIDE	MATH_OP_SIGNED_DIV
