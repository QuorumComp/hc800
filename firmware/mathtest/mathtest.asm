		INCLUDE	"lowlevel/math.i"
		INCLUDE	"lowlevel/rc800.i"

		INCLUDE	"stdlib/stream.i"
		INCLUDE	"stdlib/syscall.i"

		SECTION	"Monitor",CODE

Entry::
		jal	TestPrint
		jal	TestShift
		jal	TestAdd
		jal	TestMul
		jal	TestDiv

		sys	KExit


TestPrint:
		pusha

		MPush32	ft,3124567890
		MPrintString <"Expect 3124567890 = ">
		jal	StreamDecimalLongOut
		MNewLine
		pop	ft
		pop	ft

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
		MPrintString "0x46B579A0 << 17 = (expect 0ABC0000) "
		jal	StreamHexLongOut
		MNewLine

		pop	ft
		pop	ft

		popa
		j	(hl)
