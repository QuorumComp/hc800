		INCLUDE	"lowlevel/math.i"
		INCLUDE	"lowlevel/hc800.i"
		INCLUDE	"lowlevel/rc800.i"

; ---------------------------------------------------------------------------
; -- mcheck: the device helpers in lowlevel/math.asm, driven without a kernel.
; --
; -- The firmware self-test (mathtest) prints through the kernel console, which needs a
; -- mounted volume it can open just to load; this program runs on the bare cosim model
; -- instead, where the machine control page at $FF00 is the console and $FF01 the exit
; -- port.  Every case prints its result as eight hex digits and then a verdict character
; -- - 'K' when the number matches the expectation set up before its call, '!' when it
; -- does not, 'S' when the helper left the FT stack at the wrong depth - and the exit code
; -- is the number of failures.  Build and run it with make / make run.
; --
; -- Expectations are not data behind the call, which is the shape a call with a pushed
; -- return address would allow: a call to an absolute address is synthesized as loading the
; -- address into HL and jumping to it, which pushes nothing and returns by jumping to HL -
; -- so execution runs straight into whatever follows the call, and the address register is
; -- itself the first thing a callee needs.  Both the value and its expectation therefore
; -- live in memory cells, and the report keeps its own return address on the FT stack while
; -- it reads them.
; --
; -- The vectors are the ones mathtest carries, plus the ones only the lane map makes
; -- interesting: the signed result ports, where a divide's answer is not the unsigned one
; -- negated; a zero divisor; and the signed overflow, whose published quotient is the
; -- two's complement wrap.
; --
; -- MSpBefore records the FT stack pointer in E, and MSpCheck, run after the helper's
; -- result has been taken off the stack, compares how far the pointer moved against the
; -- depth the routine's contract promises: $00 balanced, $FF one word pushed, $FE two.
; -- The check is inline because PUSH moves the pointer, so a subroutine of its own would
; -- measure itself.
; --
; -- LCR reads its index from C and returns in T, which clobbers FT - the pair the operand
; -- and the result both live in - so MSpBefore parks the register cell on the FT stack
; -- first and corrects the reading for that push, and MSpCheck runs only once TakePair
; -- has moved the result out and left FT as scratch, correcting for the cell that popped.
; -- Flags ride in F, inside FT, so neither macro may restore the pair across a CMP.

		SECTION	"mcheck",CODE

MSpBefore:	MACRO
		push	bc			; the parameter survives the C the read needs
		push	ft			; park the operand: the LCR below writes T
		ld	c,RC8_SP_FT
		lcr	t,(c)
		add	t,1			; the PUSH above moved the pointer down one
		ld	e,t
		pop	ft
		pop	bc
		ENDM

MSpCheck:	MACRO	; want
		ld	c,RC8_SP_FT
		lcr	t,(c)
		sub	t,e
		sub	t,1			; TakePair popped a cell, so the
		cmp	t,\1
		j/eq	.spok\@
		ld	t,'S'
		jal	Putch
		jal	CountFail
.spok\@:
		ENDM

; -- TakePair: the helper left a pair in FT:FT', high cell in the register.  Park it in
; -- memory as Val[0..3], least significant byte first - and pop both cells so the next
; -- case starts from a clean stack.  Report cannot be handed the value in HL, because the
; -- synthesized call writes HL on its way in, which is why it goes to memory at all;
; -- note that LD (HL),FT writes T at (HL) and F above it, so the high cell belongs at
; -- Val+2 and the low one at Val+0.

TakePair:	MACRO
		ld	hl,Val+2
		ld	(hl),ft
		pop	ft
		ld	hl,Val+0
		ld	(hl),ft
		ENDM

; -- SetExp: the expected result, most significant byte first, parked in memory for
; -- Report.  It cannot ride along behind the call as data, because a synthesized call
; -- returns by jumping to HL - the byte after the LD L - and so runs straight into
; -- whatever follows it.

SetExp:	MACRO	; msb, b1, b0, lsb
		ld	hl,Exp+3
		ld	t,\1
		ld	(hl),t
		ld	hl,Exp+2
		ld	t,\2
		ld	(hl),t
		ld	hl,Exp+1
		ld	t,\3
		ld	(hl),t
		ld	hl,Exp+0
		ld	t,\4
		ld	(hl),t
		ENDM

; -- DropCell: the helpers that answer with two pairs leave the deeper one two cells down,
; -- so after the first TakePair the register still holds the low cell of the pair already
; -- taken; one more pop reaches the next pair's high cell.

DropCell:	MACRO
		pop	ft
		ENDM

Entry::
		ld	hl,Fails
		ld	t,0
		ld	(hl),t			; failure count; BC/DE/HL belong to the helpers

		; -- multiply: 32 x 16, 16 x 16 in both readings, 32 x 32 in both readings

		MPush32	ft,$00018602
		ld	bc,$0002
		MSpBefore
		jal	MathMultiplyUnsigned_32x16_p32
		TakePair
		MSpCheck $00
		SetExp	$00,$03,$0C,$04
		jal	Report

		ld	ft,$1234
		ld	bc,$2345
		MSpBefore
		jal	MathMultiplyUnsigned_16x16_p32
		TakePair
		MSpCheck $FF
		SetExp	$02,$82,$04,$04
		jal	Report

		ld	ft,$9234
		ld	bc,$2345
		MSpBefore
		jal	MathMultiplyUnsigned_16x16_p32
		TakePair
		MSpCheck $FF
		SetExp	$14,$24,$84,$04
		jal	Report

		ld	ft,$9234
		ld	bc,$2345
		MSpBefore
		jal	MathMultiplySigned_16x16_p32
		TakePair
		MSpCheck $FF
		SetExp	$F0,$DF,$84,$04
		jal	Report

		ld	ft,$9234
		ld	bc,$A345
		MSpBefore
		jal	MathMultiplySigned_16x16_p32
		TakePair
		MSpCheck $FF
		SetExp	$27,$C5,$84,$04
		jal	Report

		MPush32	ft,$12345678
		MPush32	bc,$9ABCDEF0
		MSpBefore
		jal	MathMultiplyUnsigned_32x32_p32
		TakePair
		MSpCheck $00
		SetExp	$24,$2D,$20,$80
		jal	Report

		MPush32	ft,$FFFFFFFF
		MPush32	bc,$7FFFFFFF
		MSpBefore
		jal	MathMultiplySigned_32x32_p32
		TakePair
		MSpCheck $00
		SetExp	$80,$00,$00,$01
		jal	Report

		; -- divide, unsigned: 32 by 16 leaves the remainder in FT and the quotient
		; -- in FT'; 32 by 32 leaves the remainder in ft:ft' and the quotient in
		; -- ft'':ft''', so each of those reports twice.

		MPush32	ft,$12345678
		ld	bc,$7654
		MSpBefore
		jal	MathDivideUnsigned_32by16_q16_r16
		TakePair
		MSpCheck $00
		SetExp	$3E,$50,$27,$62
		jal	Report

		MPush32	ft,$FEDCBA98
		MPush32	bc,$00087654
		MSpBefore
		jal	MathDivideUnsigned_32by32_q32_r32
		TakePair
		MSpCheck $FE
		SetExp	$00,$01,$04,$C0
		jal	Report
		DropCell
		TakePair
		SetExp	$00,$00,$1E,$1E
		jal	Report

		; The plain C shape the old software loop got wrong: both operands in the
		; top half of the range.

		MPush32	ft,$FFFFFFFF
		MPush32	bc,$FFFFFFFF
		MSpBefore
		jal	MathDivideUnsigned_32by32_q32_r32
		TakePair
		MSpCheck $FE
		SetExp	$00,$00,$00,$00
		jal	Report
		DropCell
		TakePair
		SetExp	$00,$00,$00,$01
		jal	Report

		; A zero divisor answers zero everywhere and says so in the status byte.

		MPush32	ft,$DEADBEEF
		MPush32	bc,$00000000
		MSpBefore
		jal	MathDivideUnsigned_32by32_q32_r32
		TakePair
		MSpCheck $FE
		SetExp	$00,$00,$00,$00
		jal	Report
		DropCell
		TakePair
		SetExp	$00,$00,$00,$00
		jal	Report

		; -- divide by 16, signed: C99 truncates the quotient toward zero and keeps
		; -- the remainder on the dividend's side of zero, so a negative dividend
		; -- must give a negative remainder.

		MPush32	ft,$FFFFFFF9		; -7 / 2
		ld	bc,$0002
		MSpBefore
		jal	MathDivideSigned_32by16_q16_r16
		TakePair
		MSpCheck $00
		SetExp	$FF,$FF,$FF,$FD
		jal	Report

		MPush32	ft,$FFFFFFF9		; -7 / -2
		ld	bc,$FFFE
		MSpBefore
		jal	MathDivideSigned_32by16_q16_r16
		TakePair
		MSpCheck $00
		SetExp	$FF,$FF,$00,$03
		jal	Report

		MPush32	ft,$00000007		; 7 / -2
		ld	bc,$FFFE
		MSpBefore
		jal	MathDivideSigned_32by16_q16_r16
		TakePair
		MSpCheck $00
		SetExp	$00,$01,$FF,$FD
		jal	Report

		MPush32	ft,$FFF0BDC0		; -1000000 / 333
		ld	bc,$014D
		MSpBefore
		jal	MathDivideSigned_32by16_q16_r16
		TakePair
		MSpCheck $00
		SetExp	$FF,$FF,$F4,$45
		jal	Report

		; -1000000 / 7: read unsigned, these operands give a quotient near 2^32, so
		; this case can only pass by taking the answer from the signed ports.

		MPush32	ft,$FFF0BDC0
		ld	bc,$0007
		MSpBefore
		jal	MathDivideSigned_32by16_q16_r16
		TakePair
		MSpCheck $00
		SetExp	$FF,$FF,$D1,$F7
		jal	Report

		; INT32_MIN / -1: the signed overflow, whose published quotient is the wrap.
		; The two halves this helper reports are zero either way, which is worth
		; saying out loud - the case pins that the overflow answers at all, and
		; mathtest is where the published value itself is checked.

		MPush32	ft,$80000000
		ld	bc,$FFFF
		MSpBefore
		jal	MathDivideSigned_32by16_q16_r16
		TakePair
		MSpCheck $00
		SetExp	$00,$00,$00,$00
		jal	Report

		; -- verdict: the failure count as two hex digits, then the exit port

		ld	hl,Fails
		ld	t,(hl)
		jal	Puthex
		ld	hl,Fails
		ld	t,(hl)
		ld	de,$FF01
		lio	(de),t
.halt		j	.halt


; -- Report: prints Val as eight hex digits, most significant first, then 'K' when it
; -- matches Exp and '!' plus one failure otherwise.  Both the value and the expectation
; -- are read from memory, and every read needs HL as the pointer - so the return address
; -- goes on the FT stack for the duration, which is also why the value could not simply
; -- be handed over in a register: the synthesized call writes HL before the callee can
; -- look at it.
; --
ValBytes:	MACRO
		ld	hl,Val+3
		ld	t,(hl)
		jal	Puthex
		ld	hl,Val+2
		ld	t,(hl)
		jal	Puthex
		ld	hl,Val+1
		ld	t,(hl)
		jal	Puthex
		ld	hl,Val+0
		ld	t,(hl)
		jal	Puthex
		ENDM

		SECTION	"mcheck.out",CODE

Report:
		push	hl			; the return, across the reads below
		ValBytes
		ld	hl,Exp+3			; the comparison walks the same order
		ld	t,(hl)
		ld	d,t			; the expectation byte, then the value
		ld	hl,Val+3
		ld	t,(hl)
		cmp	t,d
		j/ne	.bad
		ld	hl,Exp+2
		ld	t,(hl)
		ld	d,t
		ld	hl,Val+2
		ld	t,(hl)
		cmp	t,d
		j/ne	.bad
		ld	hl,Exp+1
		ld	t,(hl)
		ld	d,t
		ld	hl,Val+1
		ld	t,(hl)
		cmp	t,d
		j/ne	.bad
		ld	hl,Exp+0
		ld	t,(hl)
		ld	d,t
		ld	hl,Val+0
		ld	t,(hl)
		cmp	t,d
		j/ne	.bad
		ld	t,'K'
		jal	Putch
		pop	hl			; the callees above all hand HL back
		j	(hl)
.bad:
		ld	t,'!'
		jal	Putch
		jal	CountFail
		pop	hl
		j	(hl)

; -- CountFail: one more failure, preserving everything
; --
		SECTION	"mcheck.fail",CODE

CountFail:
		push	bc/de/hl
		ld	hl,Fails
		ld	t,(hl)
		add	t,1
		ld	(hl),t
		pop	bc/de/hl
		j	(hl)


; --
; -- Puthex32: DE:HL as eight hex digits, most significant first
; -- Puthex: T as two hex digits; Putch: T to the console port
; --
		SECTION	"mcheck.hex",CODE

Puthex32:
		pusha
		ld	t,d
		jal	Puthex
		ld	t,e
		jal	Puthex
		ld	t,h
		jal	Puthex
		ld	t,l
		jal	Puthex
		popa
		j	(hl)

Puthex:
		pusha
		ld	d,t
		ld	f,0
		rs	ft,4
		jal	Putdigit
		ld	t,$F
		and	t,d
		jal	Putdigit
		popa
		j	(hl)

Putdigit:
		pusha				; JAL leaves the return address in HL, so the
					; POPa below has to hand it back: a J (HL) sitting
					; directly after a JAL would jump to itself
		cmp	t,10
		j/ltu	.decimal
		add	t,'A'-10
		jal	Putch
		popa
		j	(hl)
.decimal:
		add	t,'0'
		jal	Putch
		popa
		j	(hl)

Putch:
		push	de
		ld	de,$FF00
		lio	(de),t
		pop	de
		j	(hl)


		SECTION	"mcheck.vars",BSS_S

Fails:		DS	1
Val:		DS	4
Exp:		DS	4
