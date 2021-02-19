		INCLUDE	"lowlevel/hc800.i"
		INCLUDE	"lowlevel/math.i"
		INCLUDE	"lowlevel/rc800.i"

		INCLUDE	"stdlib/stream.i"
		INCLUDE	"stdlib/syscall.i"

		INCLUDE	"blockdevice.i"
		INCLUDE	"sddevice.i"

		SECTION	"SDTest",CODE

Entry::
		ld	t,1
		ld	bc,sdDevice
		jal	SdDeviceMake
		j/ne	.fail

		ld	ft,sdDevice
		ld	bc,sectorNumber
		ld	de,sectorData
		jal	BlockDeviceRead

		ld	bc,sectorData
		ld	d,16
.line		ld	e,32
.loop		ld	t,(bc)
		add	bc,1
		jal	StreamHexByteOut
		dj	e,.loop
		MNewLine
		dj	d,.line

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
sdDevice	DS	bdev_SIZEOF
sectorData:	DS	512
