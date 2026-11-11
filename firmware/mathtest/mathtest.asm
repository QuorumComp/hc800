		INCLUDE	"lowlevel/math.i"
		INCLUDE	"lowlevel/hc800.i"
		INCLUDE	"lowlevel/rc800.i"

		INCLUDE	"stdlib/stream.i"
		INCLUDE	"stdlib/string.i"
		INCLUDE	"stdlib/syscall.i"

		SECTION	"Monitor",CODE

Entry::
		;jal	TestPick
		;jal	TestStringDrop
		;jal	TestStringCompare
		jal	TestStow
		jal	TestRegisterLocals
		jal	TestStackPointer
		jal	TestCompare
		jal	TestPrint
		jal	TestShift
		jal	TestAdd
		jal	TestSub
		jal	TestMul
		jal	TestDiv
		jal	TestDivEdge

		sys	KExit


TestPick:
		pusha

		MPrintString <"PICK expect $ABCD = $">
		ld	ft,$ABCD
		push	ft
		ld	ft,$5678
		push	ft
		ld	ft,$1234

		pick	ft,2
		jal	StreamHexWordOut
		MNewLine

		pop	ft
		pop	ft

		popa
		j	(hl)

TestStow:
		pusha

		MPrintString <"STOW expect $ABCD = $">
		ld	bc,$ABCD
		stow	bc,4		; BC stack entry 4 <- $ABCD
		ld	bc,$1234	; the register changes, the entry does not
		pick	bc,4		; BC <- entry 4
		ld	ft,bc
		jal	StreamHexWordOut
		MNewLine

		popa
		j	(hl)

TestRegisterLocals:
		pusha

		MPrintString <"locals expect $0006 = $">
		ld	bc,$0000
		ld	ft,$FFFF
		jal	local_rmw
		jal	StreamHexWordOut
		MNewLine

		MPrintString <"locals expect $555D = $">
		ld	bc,$1111
		ld	ft,$2222
		jal	local_rmw
		jal	StreamHexWordOut
		MNewLine

		popa
		j	(hl)

; --
; -- local_rmw
; --   Demonstrates register-stack locals: store the first argument in a
; --   local, update a second local in place, then run an FT-only operation
; --   on it and write it back.
; --
; -- Inputs:
; --   FT: x
; --   BC: y
; --
; -- Outputs:
; --   FT: ((x + 4) << 1) + y
; --
		SECTION "local_rmw",CODE
local_rmw:
		push	de
		ld	de,0
		push	de
		push	de
		; depth 0 = scratch, 1 = local 1, 2 = local 2, 3 = caller DE

		ld	de,ft
		stow	de,2

		pick	de,2
		add	de,4
		stow	de,1

		pick	de,1
		exg	ft,de
		ls	ft,1
		add	ft,bc
		exg	ft,de
		stow	de,1

		pick	de,1
		ld	ft,de

		pop	de
		pop	de
		pop	de
		j	(hl)

TestStackPointer:
		pusha

		MPrintString <"SP rewind expect $0055 = $">
		ld	ft,$00AA
		push	ft
		ld	ft,$0055
		push	ft
		ld	c,RC8_SP_FT
		ld	t,$FD
		lcr	(c),t
		jal	StreamHexWordOut
		MNewLine

		MPrintString <"SP rewind expect $00AA = $">
		ld	c,RC8_SP_FT
		ld	t,$FE
		lcr	(c),t
		jal	StreamHexWordOut
		MNewLine

		MPrintString <"SP same expect $5678 = $">
		ld	d,$56
		ld	e,$78
		ld	c,RC8_SP_DE
		lcr	t,(c)          ; T = SP_DE
		lcr	(c),t          ; write it back unchanged
		ld	ft,de
		jal	StreamHexWordOut
		MNewLine

		MPrintString <"SP push/pop expect $00AA = $">
		ld	ft,$00AA
		push	ft
		pop	ft
		jal	StreamHexWordOut
		MNewLine

		popa
		j	(hl)

TestCompare:
		pusha

		MPrintString <"$EDCBA988 cmp $1234568 = $">
		MLoad32	ft,$EDCBA988
		MLoad32	bc,$1234568
		jal	MathCompareLong
		ld	t,f
		jal	StreamHexByteOut
		MNewLine

		MPrintString <"$EDCB0000 cmp $EDBC0000 = $">
		MLoad32	ft,$EDCB0000
		MLoad32	bc,$EDCB0000
		jal	MathCompareLong
		ld	t,f
		jal	StreamHexByteOut
		MNewLine

		MPrintString <"$EDCB0001 cmp $EDBC0000 = $">
		MLoad32	ft,$EDCB0001
		MLoad32	bc,$EDCB0000
		jal	MathCompareLong
		ld	t,f
		jal	StreamHexByteOut
		MNewLine

		MPrintString <"$EDCB0000 cmp $EDBC0001 = $">
		MLoad32	ft,$EDCB0000
		MLoad32	bc,$EDCB0001
		jal	MathCompareLong
		ld	t,f
		jal	StreamHexByteOut
		MNewLine

		popa
		j	(hl)

TestStringDrop:
		pusha

		ld	bc,testString
		jal	StringClear

		ld	bc,testString
		ld	de,{ DC_STR "/DropSlash" }
		jal	StringAppendDataString

		ld	t,1
		ld	bc,testString
		jal	StringDropLeft

		MPrintString <"Expect DropSlash: ">
		ld	bc,testString
		jal	StreamBssStringOut
		MNewLine

		popa
		j	(hl)


TestStringCompare:
		pusha	

		ld	ft,{ DC_STR "test1" }
		ld	bc,{ DC_STR "test2" }
		jal	.test

		ld	ft,{ DC_STR "test2" }
		ld	bc,{ DC_STR "test1" }
		jal	.test

		ld	ft,{ DC_STR "test" }
		ld	bc,{ DC_STR "tested" }
		jal	.test

		ld	ft,{ DC_STR "tested" }
		ld	bc,{ DC_STR "test" }
		jal	.test

		ld	ft,{ DC_STR "test" }
		ld	bc,{ DC_STR "test" }
		jal	.test

		popa
		j	(hl)

.test
		push	ft/bc/hl
		jal	StringCompare
		ld	de,.equal
		ld/ltu	de,.ltu
		ld/gtu	de,.gtu

		pop	ft
		ld	bc,ft
		jal	StreamDataStringOut

		ld	ft,de
		ld	bc,ft
		jal	StreamDataStringOut

		pop	bc
		jal	StreamDataStringOut
		MNewLine

		pop	hl
		j	(hl)

.equal		DC_STR	" is equal to "
.ltu		DC_STR	" is less than "
.gtu		DC_STR	" is greater than "

TestPrint:
		pusha

		MPush32	ft,3124567890
		MPrintString <"Expect 3124567890 = ">
		jal	StreamDecimalLongOut
		MNewLine
		; StreamDecimalLongOut consumes the ft:ft' parameter; no pops
		; here - extra pops would underflow the FT stack

		popa
		j	(hl)

TestDiv:
		pusha

		MPrintString <"0x12345678 / 0x7654 = (unsigned, expect 3E50:2762) ">
		MPush32	ft,$12345678
		ld	bc,$7654
		jal	MathDivideUnsigned_32by16_q16_r16
		jal	StreamHexWordOut
		MPrintChar ':'
		pop	ft
		jal	StreamHexWordOut
		pop	ft
		MNewLine

		MPrintString <"0xFEDCBA98 / 0x87654 = (unsigned, expect 000104C0:00001E1E) ">
		MPush32	ft,$FEDCBA98
		MPush32	bc,$87654
		jal	MathDivideUnsigned_32by32_q32_r32
		jal	StreamHexLongOut
		MPrintChar ':'
		pop	ft
		pop	ft
		jal	StreamHexLongOut
		pop	ft
		pop	bc
		pop	bc
		MNewLine

		; signed divides: C99 truncates the quotient toward zero and
		; keeps the remainder on the dividend's side of zero, so a
		; negative dividend must give a negative remainder.

		MPrintString <"-7 / 2 = (signed, expect FFFF:FFFD) ">
		MPush32	ft,$FFFFFFF9
		ld	bc,2
		jal	MathDivideSigned_32by16_q16_r16
		jal	StreamHexWordOut
		MPrintChar ':'
		pop	ft
		jal	StreamHexWordOut
		pop	ft
		MNewLine

		MPrintString <"-7 / -2 = (signed, expect FFFF:0003) ">
		MPush32	ft,$FFFFFFF9
		ld	bc,$FFFE
		jal	MathDivideSigned_32by16_q16_r16
		jal	StreamHexWordOut
		MPrintChar ':'
		pop	ft
		jal	StreamHexWordOut
		pop	ft
		MNewLine

		MPrintString <"7 / -2 = (signed, expect 0001:FFFD) ">
		MPush32	ft,$00000007
		ld	bc,$FFFE
		jal	MathDivideSigned_32by16_q16_r16
		jal	StreamHexWordOut
		MPrintChar ':'
		pop	ft
		jal	StreamHexWordOut
		pop	ft
		MNewLine

		MPrintString <"-100 / 7 = (signed, expect FFFE:FFF2) ">
		MPush32	ft,$FFFFFF9C
		ld	bc,7
		jal	MathDivideSigned_32by16_q16_r16
		jal	StreamHexWordOut
		MPrintChar ':'
		pop	ft
		jal	StreamHexWordOut
		pop	ft
		MNewLine

		MPrintString <"100 / -7 = (signed, expect 0002:FFF2) ">
		MPush32	ft,$00000064
		ld	bc,$FFF9
		jal	MathDivideSigned_32by16_q16_r16
		jal	StreamHexWordOut
		MPrintChar ':'
		pop	ft
		jal	StreamHexWordOut
		pop	ft
		MNewLine

		MPrintString <"-1000000 / 333 = (signed, expect FFFF:F445) ">
		MPush32	ft,$FFF0BDC0
		ld	bc,$014D
		jal	MathDivideSigned_32by16_q16_r16
		jal	StreamHexWordOut
		MPrintChar ':'
		pop	ft
		jal	StreamHexWordOut
		pop	ft
		MNewLine

		popa
		j	(hl)


; --
; -- TestDivEdge
; --   The divisions the drivers above cannot ask for.  A dividend wider than 32 bits is
; --   out of the machine now, so what is left to reach by hand is the two cases with no
; --   arithmetic answer and the one division whose two readings disagree: the same
; --   operands, taken once from the unsigned ports and once from the signed ones, give
; --   different numbers and different status bytes.  The signed overflow is here too, and
; --   so is what it publishes - the two's complement wrap, flagged rather than zeroed.
; --
; --   Reading a lane does not disturb anything on this device, so a line can print the
; --   status byte and then the results without re-running the operation.  The bytes come
; --   out least significant first, because lane 0 is the least significant byte of a
; --   value; the expectation strings are written in that order.

TestDivEdge:
		pusha

		MPrintString <"$DEADBEEF / $F0000000 expect status 01 q 00 00 00 00 r EF BE AD DE: ">
		ld	bc,.case_high
		jal	EdgeDiv
		MNewLine

		; The plain C shape (`u32 / u32` in the top half): the old loop had this wrong.
		MPrintString <"$FFFFFFFF / $FFFFFFFF expect status 01 q 01 00 00 00 r 00 00 00 00: ">
		ld	bc,.case_equal
		jal	EdgeDiv
		MNewLine

		MPrintString <"$DEADBEEF / 0 expect status 03 q 00 00 00 00 r 00 00 00 00: ">
		ld	bc,.case_zero
		jal	EdgeDiv
		MNewLine

		; INT32_MIN / -1 read unsigned: an ordinary division, defined and unflagged.
		MPrintString <"$80000000 / -1 unsigned expect status 01 q 00 00 00 00 r 00 00 00 80: ">
		ld	bc,.case_overflow_raw
		jal	EdgeDiv
		MNewLine

		; The same operands read signed: no quotient fits the signed range, the status
		; byte says so, and the value published is the wrap a software divider lands on.
		MPrintString <"$80000000 / -1 signed expect status 09 q 00 00 00 80 r 00 00 00 00: ">
		ld	bc,.case_overflow_signed
		jal	EdgeDiv
		MNewLine

		; Sign convention: magnitudes, then the quotient negated when the
		; operand signs differ and the remainder following the dividend.
		; INT32_MIN is the largest magnitude a signed divisor has.

		MPrintString <"-1 / $80000000 expect status 01 q 00 00 00 00 r FF FF FF FF: ">
		ld	bc,.case_signed
		jal	EdgeDiv
		MNewLine

		popa
		j	(hl)

; Each line: divisor (4, least significant first), dividend (4, least significant
; first), then the offsets of the status byte and of the two result ports to read.
; The dividends are $DEADBEEF, whose bytes least-significant-first are EF,BE,AD,DE
; - writing them in reading order swaps the middle two and makes the case print a
; remainder that does not match its own banner.

.case_high	DB	$00,$00,$00,$F0,$EF,$BE,$AD,$DE
		DB	IO_MATH_STATUS,IO_MATH_QUOTIENT,IO_MATH_REMAINDER

.case_equal	DB	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
		DB	IO_MATH_STATUS,IO_MATH_QUOTIENT,IO_MATH_REMAINDER

.case_zero	DB	$00,$00,$00,$00,$EF,$BE,$AD,$DE
		DB	IO_MATH_STATUS,IO_MATH_QUOTIENT,IO_MATH_REMAINDER

.case_overflow_raw	DB	$FF,$FF,$FF,$FF,$00,$00,$00,$80
		DB	IO_MATH_STATUS,IO_MATH_QUOTIENT,IO_MATH_REMAINDER

.case_overflow_signed	DB	$FF,$FF,$FF,$FF,$00,$00,$00,$80
		DB	IO_MATH_STATUS_SIGNED,IO_MATH_QUOTIENT_SIGNED,IO_MATH_REMAINDER_SIGNED

.case_signed	DB	$00,$00,$00,$80,$FF,$FF,$FF,$FF
		DB	IO_MATH_STATUS_SIGNED,IO_MATH_QUOTIENT_SIGNED,IO_MATH_REMAINDER_SIGNED


; --
; -- EdgeDiv
; --   One MATH coprocessor division, driven straight from a table so that the cases the
; --   drivers cannot ask for are still asked.  Prints the status byte of the family whose
; --   result ports the line names, then four quotient bytes and four remainder bytes.
; --
; -- Inputs:
; --   bc - 11 bytes, as the table above describes them
; --
		SECTION	"EdgeDiv",CODE
EdgeDiv:
		pusha

		ld	d,IO_MATH_BASE

		; X: the divisor, lane 0 first.  DJ counts in F, which is safe here: only
		; CMP writes the flags implicitly, and nothing in the loop is CMP.
		ld	e,IO_MATH_X
		ld	f,4
.edgeX:		ld	t,(bc)
		lio	(de+),t
		add	bc,1
		dj	f,.edgeX

		; Y: the dividend.  The lane walk leaves DE at the next group, and the last
		; write of this one is what starts the run.
		ld	f,4
.edgeY:		ld	t,(bc)
		lio	(de+),t
		add	bc,1
		dj	f,.edgeY

		; Poll rather than guess: a run is 32 cycles.  LD F,T puts the byte on the
		; condition lanes, the carry lane is readiness, so the loop spins while the
		; carry is clear.  Writing F leaves T alone, so the status byte is still
		; there to print.
		ld	t,(bc)
		ld	e,t
.edgePoll:	lio	t,(de)
		ld	f,t
		j/cc	.edgePoll

		jal	StreamHexByteOut

		MPrintString <" q">
		add	bc,1
		ld	t,(bc)
		ld	e,t
		lio	t,(de+)
		jal	StreamHexByteOut
		lio	t,(de+)
		jal	StreamHexByteOut
		lio	t,(de+)
		jal	StreamHexByteOut
		lio	t,(de+)
		jal	StreamHexByteOut

		MPrintString <" r">
		add	bc,1
		ld	t,(bc)
		ld	e,t
		lio	t,(de+)
		jal	StreamHexByteOut
		lio	t,(de+)
		jal	StreamHexByteOut
		lio	t,(de+)
		jal	StreamHexByteOut
		lio	t,(de+)
		jal	StreamHexByteOut

		popa
		j	(hl)

TestMul:
		pusha

		MPrintString <"0x00018602 * 0x0002 = (unsigned, expect 00030C04) ">
		ld	ft,$8602
		push	ft
		ld	ft,$0001
		ld	bc,$0002
		jal	MathMultiplyUnsigned_32x16_p32
		jal	StreamHexLongOut
		MNewLine
		pop	ft

		MPrintString <"0x1234 * 0x2345 = (unsigned, expect 02820404) ">
		ld	ft,$1234
		ld	bc,$2345
		jal	MathMultiplyUnsigned_16x16_p32
		jal	StreamHexLongOut
		MNewLine
		pop	ft

		MPrintString <"0x9234 * 0x2345 = (unsigned, expect 14248404) ">
		ld	ft,$9234
		ld	bc,$2345
		jal	MathMultiplyUnsigned_16x16_p32
		jal	StreamHexLongOut
		MNewLine
		pop	ft

		MPrintString <"0x9234 * 0x2345 = (signed, expect F0DF8404) ">
		ld	ft,$9234
		ld	bc,$2345
		jal	MathMultiplySigned_16x16_p32
		jal	StreamHexLongOut
		MNewLine
		pop	ft

		MPrintString <"0x9234 * 0xA345 = (signed, expect 27C58404) ">
		ld	ft,$9234
		ld	bc,$A345
		jal	MathMultiplySigned_16x16_p32
		jal	StreamHexLongOut
		MNewLine
		pop	ft

		popa
		j	(hl)


TestAdd:
		pusha

		MPush32	ft,$12345678
		MPush32	bc,$FEDCBA98
		jal	MathAdd_32_32
		pop	bc
		pop	bc

		MPrintString "0x12345678 + 0xFEDCBA98 = (expect 11111110) "
		jal	StreamHexLongOut
		MNewLine

		MPush32	bc,$F3E2F1E0
		jal	MathAdd_32_32
		pop	bc
		pop	bc

		MPrintString "0x11111110 + 0xF3E2F1E0 = (expect 04F402F0) "
		jal	StreamHexLongOut
		MNewLine

		popa
		j	(hl)


TestSub:
		pusha

		MPush32	ft,$12345678
		MPush32	bc,$FEDCBA98
		jal	MathSub_32_32
		pop	bc
		pop	bc

		MPrintString "0x12345678 - 0xFEDCBA98 = (expect 13579BE0) "
		jal	StreamHexLongOut
		MNewLine

		MPush32	bc,$F3E2F1E0
		jal	MathSub_32_32
		pop	bc
		pop	bc

		MPrintString "0x13579BE0 - 0xF3E2F1E0 = (expect 1F74AA00) "
		jal	StreamHexLongOut
		MNewLine

		popa
		j	(hl)


TestShift:
		pusha

		; test right shift

		MPush32	ft,$1235ABCD
		ld	b,5
		jal	MathShiftRight_32

		MPrintString "0x1235ABCD >> 5 = (expect 0091AD5E) "
		jal	StreamHexLongOut
		MNewLine

		ld	b,17
		jal	MathShiftRight_32

		MPrintString "0x0091AD5E >> 17 = (expect 00000048) "
		jal	StreamHexLongOut
		MNewLine

		pop	ft
		pop	ft

		; test left shift

		MPush32	ft,$1235ABCD
		ld	b,5
		jal	MathShiftLeft_32
		MPrintString "0x1235ABCD << 5 = (expect 46B579A0) "
		jal	StreamHexLongOut
		MNewLine

		MPush32	ft,$1234ABCD
		ld	b,9
		jal	MathShiftLeft_32
		MPrintString "0x1234ABCD << 9 = (expect 69579A00) "
		jal	StreamHexLongOut
		MNewLine

		MPush32	ft,$46B579A0
		ld	b,17
		jal	MathShiftLeft_32
		MPrintString "0x46B579A0 << 17 = (expect F3400000) "
		jal	StreamHexLongOut
		MNewLine

		pop	ft
		pop	ft

		; The wide shifts: at 16 and above the answer is one word of the input
		; moved to the far end with the other end zeroed - a right shift keeps
		; the high word, a left shift keeps the low one.  A value under 65536
		; cannot tell a routine that does that from one that quietly drops a
		; word, so these operands have both halves busy, and 31 is the largest
		; shift the 32-bit shape has an answer for.

		MPush32	ft,$0001ABCD
		ld	b,16
		jal	MathShiftRight_32
		MPrintString "0x0001ABCD >> 16 = (expect 00000001) "
		jal	StreamHexLongOut
		MNewLine
		pop	ft

		MPush32	ft,$FFFF0000
		ld	b,17
		jal	MathShiftRight_32
		MPrintString "0xFFFF0000 >> 17 = (expect 00007FFF) "
		jal	StreamHexLongOut
		MNewLine
		pop	ft

		MPush32	ft,$FFFFFFFF
		ld	b,31
		jal	MathShiftRight_32
		MPrintString "0xFFFFFFFF >> 31 = (expect 00000001) "
		jal	StreamHexLongOut
		MNewLine
		pop	ft

		MPush32	ft,$0000FFFF
		ld	b,16
		jal	MathShiftLeft_32
		MPrintString "0x0000FFFF << 16 = (expect FFFF0000) "
		jal	StreamHexLongOut
		MNewLine
		pop	ft

		MPush32	ft,$FFFFFFFF
		ld	b,17
		jal	MathShiftLeft_32
		MPrintString "0xFFFFFFFF << 17 = (expect FFFE0000) "
		jal	StreamHexLongOut
		MNewLine
		pop	ft

		MPush32	ft,$12345679
		ld	b,31
		jal	MathShiftLeft_32
		MPrintString "0x12345679 << 31 = (expect 80000000) "
		jal	StreamHexLongOut
		MNewLine
		pop	ft

		popa
		j	(hl)


		SECTION	"Vars",BSS_S
testString:	DS_STR
