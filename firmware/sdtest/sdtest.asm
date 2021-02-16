		INCLUDE	"lowlevel/hc800.i"
		INCLUDE	"lowlevel/math.i"
		INCLUDE	"lowlevel/rc800.i"

		INCLUDE	"stdlib/stream.i"
		INCLUDE	"stdlib/syscall.i"

		INCLUDE	"sd.i"

		SECTION	"SDTest",CODE

Entry::
		jal	SdInit
		j/ne	.fail

		ld	bc,SdType
		ld	t,(bc)
		jal	StreamHexByteOut
		MNewLine

		ld	bc,sectorNumber
		ld	de,sectorData
		jal	SdReadSingleBlock

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

		SECTION	"Data",DATA
sectorNumber:	MInt32	0

		SECTION	"Sector",BSS
sectorData:	DS	512
