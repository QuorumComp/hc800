		INCLUDE	"lowlevel/hc800.i"
		INCLUDE	"lowlevel/math.i"
		INCLUDE	"lowlevel/rc800.i"
		INCLUDE	"lowlevel/stack.i"

		INCLUDE	"stdlib/stream.i"
		INCLUDE	"stdlib/string.i"
		INCLUDE	"stdlib/syscall.i"

		SECTION	"SDTest",CODE

Entry::
		MStackInit 1024

		MNewLine

.fail
		sys	KExit

.string		DC_STR	<"/this/is//a/test/">


		END
		
listRootDirectory:
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

		MStackAlloc 512
		ld	de,ft		; de = sector data

		ld	ft,mbrDevice
		ld	bc,sectorNumber
		jal	BlockDeviceRead

		ld	ft,de
		ld	bc,ft
		jal	printFiles

		MStackFree 512

		popa
		j	(hl)

; bc = sector data
printFiles:
		pusha

		ld	f,16
.loop		jal	printFile
		add	bc,32
		dj	f,.loop

		popa
		j	(hl)


printFile:
		pusha

		add	bc,$0B
		ld	t,(bc)
		cmp	t,$0F
		j/eq	.exit
		sub	bc,$0B

		ld	t,(bc)
		add	bc,1

		cmp	t,0
		j/eq	.exit
		cmp	t,$E5
		j/eq	.exit

		cmp	t,$05
		ld/eq	t,$E5

		ld	f,8
.name		sys	KCharacterOut
		ld	t,(bc)
		add	bc,1
		dj	f,.name

		push	ft
		ld	t,'.'
		sys	KCharacterOut
		pop	ft			

		ld	f,3
.ext		sys	KCharacterOut
		ld	t,(bc)
		add	bc,1
		dj	f,.ext

		MNewLine

.exit		popa
		j	(hl)

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

		jal	StreamMemoryDump

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
mbrDevice	DS	mbrdev_SIZEOF
sdDevice	DS	sddev_SIZEOF
fat32		DS	fs_Fat32_SIZEOF
