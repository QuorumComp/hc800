		INCLUDE	"lowlevel/math.i"

		INCLUDE	"stdlib/stream.i"
		INCLUDE	"stdlib/syscall.i"

		SECTION	"Monitor",CODE

Entry::
		ld	ft,$0102
		ld	bc,.op1
		jal	MathMultiplyUnsigned_32x16_p32
		jal	.print_bc

		ld	ft,31245
		jal	StreamDecimalWordOut
		MNewLine

	IF 0
		ld	bc,.op1
		ld	de,.op2
		jal	MathAdd_32_32

		jal	.print_bc

		ld	bc,.op1
		ld	t,17
		jal	MathShift_32

		jal	.print_bc
	ENDC

		sys	KExit

.print_bc	push	hl
		ld	d,4
		add	bc,3
.loop		ld	t,(bc)
		sub	bc,1
		jal	StreamHexByteOut
		dj	d,.loop
		MNewLine
		pop	hl
		j	(hl)


.op1	MInt32	$0403FF01
.op2	MInt32	$040302FF
