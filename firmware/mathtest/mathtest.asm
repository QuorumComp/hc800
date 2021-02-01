		INCLUDE	"lowlevel/math.i"

		INCLUDE	"stdlib/stream.i"
		INCLUDE	"stdlib/syscall.i"

		SECTION	"Monitor",CODE

Entry::
		ld	bc,.op1
		ld	de,.op2
		jal	MathAdd_32_32

		ld	d,4
.loop		ld	t,(bc)
		add	bc,1
		jal	StreamHexByteOut
		dj	d,.loop

		sys	KExit

.op1	DB	$01,$FF,$03,$04
.op2	DB	$FF,$02,$03,$04
