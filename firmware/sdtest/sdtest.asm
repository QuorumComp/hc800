		INCLUDE	"lowlevel/hc800.i"
		INCLUDE	"lowlevel/math.i"
		INCLUDE	"lowlevel/rc800.i"
		INCLUDE	"lowlevel/stack.i"

		INCLUDE	"stdlib/stream.i"
		INCLUDE	"stdlib/string.i"
		INCLUDE	"stdlib/syscall.i"

		INCLUDE	"blockdevice.i"
		INCLUDE	"fat32.i"
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
		ld	de,fat32
		jal	Fat32FsMake
		j/ne	.fail

		;jal	printVBR

		jal	printFat32

		jal	printRootSector

		MNewLine

.fail
		sys	KExit

.string		DC_STR	<"/this/is//a/test/">

; bc = cluster/result
; de = fat32 structure
clusterToSector:
		pusha
		ld	ft,-2
		jal	MathLoadOperand16S

		jal	MathAdd_32_Operand

		add	de,fs_ClusterToSector
		ld	t,(de)
		ld	t,3
		jal	MathShift_32

		add	de,fs_DataBase-fs_ClusterToSector
		jal	MathAdd_32_32
		
		popa
		j	(hl)

printStringArray:
		pusha

.next		ld	t,(bc)
		cmp	t,0
		j/eq	.done
		ld	t,'"'
		sys	KCharacterOut
		jal	StreamBssStringOut
		ld	t,'"'
		sys	KCharacterOut
		ld	t,(bc)
		ld	f,0
		add	ft,1
		add	ft,bc
		ld	bc,ft
		MNewLine
		j	.next

.done		popa
		j	(hl)



printFat32:
		pusha
		ld	bc,fat32+fs_ClusterToSector
		ld	e,fs_Fat32_SIZEOF-fs_ClusterToSector
.loop		ld	t,(bc)
		add	bc,1
		jal	StreamHexByteOut
		dj	e,.loop
		MNewLine
		popa
		j	(hl)
	

printRootSector:
		pusha
		ld	de,fat32+fs_RootCluster
		ld	bc,sectorNumber
		REPT 4
		ld	t,(de)
		ld	(bc),t
		add	de,1
		add	bc,1
		ENDR
		ld	bc,sectorNumber
		ld	de,fat32
		jal	clusterToSector
		jal	printSector
		popa
		j	(hl)

printVBR:	pusha
		ld	bc,sectorNumber
		ld	t,0
		ld	(bc),t
		add	bc,1
		ld	(bc),t
		add	bc,1
		ld	(bc),t
		add	bc,1
		ld	(bc),t
		jal	printSector
		popa
		j	(hl)


printSector:	pusha

		ld	bc,sectorNumber+3
		ld	f,4
.print_long	ld	t,(bc)
		jal	StreamHexByteOut
		sub	bc,1
		dj	f,.print_long
		MNewLine


		MStackAlloc 512
		ld	de,ft		; de = sector data

		ld	ft,mbrDevice
		ld	bc,sectorNumber
		jal	BlockDeviceRead

		ld	ft,de
		ld	bc,ft

		ld	d,16
.line		ld	e,32
.loop		ld	t,(bc)
		add	bc,1
		jal	StreamHexByteOut
		dj	e,.loop
		ld	t,' '
		sys	KCharacterOut
		sub	bc,32
		ld	e,32
.char_loop	ld	t,(bc)
		add	bc,1
		cmp	t,' '
		ld/ltu	t,'.'
		sys	KCharacterOut
		dj	e,.char_loop
		MNewLine
		dj	d,.line

		MStackFree 512

		popa
		j	(hl)


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
fat32		DS	fs_Fat32_SIZEOF
