		INCLUDE	"lowlevel/hc800.i"
		INCLUDE	"lowlevel/math.i"
		INCLUDE	"lowlevel/rc800.i"
		INCLUDE	"lowlevel/stack.i"

		INCLUDE	"stdlib/stream.i"
		INCLUDE	"stdlib/syscall.i"

		INCLUDE	"blockdevice.i"
		INCLUDE	"mbr.i"
		INCLUDE	"sddevice.i"

		SECTION	"SDTest",CODE

Entry::
		MStackInit 1024

		ld	t,1
		ld	bc,sdDevice
		jal	SdDeviceMake
		j/ne	.fail

		ld	t,0
		ld	bc,mbrDevice
		ld	de,sdDevice
		jal	MakeMbrPartitionDevice
		j/ne	.fail

		ld	bc,mbrDevice
		ld	f,bdev_SIZEOF
.dev_loop	ld	t,(bc)
		add	bc,1
		jal	StreamHexByteOut
		dj	f,.dev_loop
		MNewLine

		MStackAlloc 512
		ld	de,ft		; de = sector data

		ld	ft,mbrDevice
		ld	bc,sectorNumber
		jal	BlockDeviceRead

		ld	ft,de
		ld	bc,ft

;		add	bc,$1BE

		ld	d,16
.line		ld	e,32
.loop		ld	t,(bc)
		add	bc,1
		jal	StreamHexByteOut
		dj	e,.loop
		MNewLine
		dj	d,.line

		MStackFree 512

.fail
		sys	KExit


printBc:	push	hl
		ld	d,4
		add	bc,3
.loop		ld	t,(bc)
		sub	bc,1
		jal	StreamHexByteOut
		dj	d,.loop
		MNewLine
		pop	hl
		j	(hl)

		SECTION	"Data",DATA
sectorNumber:	MInt32	0

		SECTION	"Sector",BSS
mbrDevice	DS	bdev_SIZEOF
sdDevice	DS	bdev_SIZEOF
