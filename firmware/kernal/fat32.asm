		INCLUDE	"lowlevel/math.i"
		INCLUDE	"lowlevel/rc800.i"
		INCLUDE	"lowlevel/stack.i"

		INCLUDE	"kernal/error.i"
		INCLUDE	"kernal/filesystems.i"

		INCLUDE	"blockdevice.i"
		INCLUDE	"fat32.i"

		INCLUDE	"uart_commands.i"
		INCLUDE	"uart_commands_disabled.i"

FAT32_BOOT_SIG		EQU	$29

BPB_SECTORS_PER_CLUSTER	EQU	$0D
BPB_FAT_BASE		EQU	$0E
BPB_TOTAL_FAT_SECTORS	EQU	$10
BPB_FAT_SIZE32		EQU	$24
BPB_ROOT_CLUSTER	EQU	$2C

BS_BOOT_SIG32		EQU	$42
BS_LABEL		EQU	$47
BS_FSTYPE32		EQU	$52
BS_BOOT_RECORD_SIG	EQU	$1FE

BS_LABEL_SIZEOF		EQU	11

ATTR_READONLY		EQU	$01
ATTR_HIDDEN		EQU	$02
ATTR_SYSTEM		EQU	$04
ATTR_LABEL		EQU	$08
ATTR_DIRECTORY		EQU	$10
ATTR_ARCHIVE		EQU	$20
ATTR_DEVICE		EQU	$40

DIRENT_NAME		EQU	$00
DIRENT_EXT		EQU	$08
DIRENT_ATTR		EQU	$0B
DIRENT_LENGTH		EQU	$1C
DIRENT_SIZEOF		EQU	32

DIRENTS_PER_SECTOR	EQU	512/DIRENT_SIZEOF

			RSSET	dir_PRIVATE
udir_File		RB	2
udir_SIZEOF		RB	0

			RSSET	file_PRIVATE
ufile_RootCluster	RB	4
ufile_Cluster		RB	4
ufile_SectorIndex	RB	1
ufile_SectorData	RB	2
ufile_RemainingBytes	RB	2	; remaining bytes to read in SectorData
ufile_SIZEOF		RB	0


; ---------------------------------------------------------------------------
; -- Make FAT32 file system jump table
; --
; -- Inputs:
; --   bc - pointer to block device structure
; --   de - pointer to FAT32 filesystem structure
; --
; -- Returns:
; --    f - "eq" condition if success
; --
		SECTION	"Fat32FsMake",CODE
Fat32FsMake:
		MDebugPrint <"Fat32FsMake enter\n">
		push	bc-hl

		MStackAlloc 512
		ld	de,ft	; de = volume boot record

		jal	loadVolumeBootRecord
		j/ne	.exit

		jal	checkFat32
		j/ne	.exit

		MDebugPrint <"FAT32 found\n">

		ld	ft,de
		ld	bc,ft	; bc = volume boot record
		swap	de	; restore fs structure
		jal	fillFsStruct
		MDebugMemory de,32
		swap	de	; put fs structure back in place

		ld	f,FLAGS_EQ

.exit		MStackFree 512
		pop	bc-hl
		j	(hl)


Fat32Change:
		SECTION	"Fat32FsMake",CODE


; ---------------------------------------------------------------------------
; -- Fill FAT32 filesystem structure
; --
; -- Inputs:
; --   bc - pointer to volume boot record
; --   de - pointer to FAT32 filesystem structure
; --
		SECTION	"fillFsStruct",CODE
fillFsStruct:
		pusha

		add	de,fs_Open
		ld	hl,.template
		ld	f,fs_PRIVATE-fs_Open
.copy_template	lco	t,(hl)
		ld	(de),t
		add	hl,1
		add	de,1
		dj	f,.copy_template

		; copy volume label
		add	de,fs_Label+BS_LABEL_SIZEOF+1-fs_PRIVATE
		add	bc,BS_LABEL+BS_LABEL_SIZEOF
		ld	l,BS_LABEL_SIZEOF
.find_label_end	sub	bc,1
		sub	de,1
		ld	t,(bc)
		cmp	t,' '
		j/ne	.label_end_found
		dj	l,.find_label_end
		j	.no_label
.label_end_found
		push	hl
		ld	(de),t
		j	.label_copy_entry
.label_copy	sub	bc,1
		sub	de,1
		ld	t,(bc)
		ld	(de),t
.label_copy_entry
		dj	l,.label_copy
		pop	hl
		sub	de,1
		ld	t,l
		ld	(de),t
.no_label
		MDebugMemory de,16
		; determine how much to shift a cluster number to get sector

		add	bc,BPB_SECTORS_PER_CLUSTER-BS_LABEL
		add	de,fat32_ClusterToSector-fs_Label
		ld	t,(bc)
		ld	f,0
		jal	MathLog2_16
		ld	(de),t

		; get root directory cluster

		add	bc,BPB_ROOT_CLUSTER-BPB_SECTORS_PER_CLUSTER
		add	de,fat32_RootCluster-fat32_ClusterToSector
		jal	.copy4

		; get FAT base cluster

		add	bc,BPB_FAT_BASE-BPB_ROOT_CLUSTER
		add	de,fat32_FatBase-fat32_RootCluster
		jal	.copy2

		; calculate data base
		sub	bc,BPB_FAT_BASE
		jal	.calcDataBase

		swap	de	; get fs structure
		add	de,fat32_DataBase

		; this pops one FT too many, the popa at the end of this function is therefore on bc-hl
		MPop32	(de),ft

		sub	de,fat32_DataBase
		swap	de

		pop	bc-hl
		j	(hl)

.copy2		pusha
		ld	f,2
		j	.copy_loop
.copy4		pusha
		ld	f,4
.copy_loop	ld	t,(bc)
		ld	(de),t
		add	bc,1
		add	de,1
		dj	f,.copy_loop
		popa
		j	(hl)

.template	DW	fileOpen
		DW	fileClose
		DW	fileRead
		DW	dirOpen
		DW	dirRead
.template_end

		; -- Calc data base cluster
		; -- bc - volume boot record
		; --
		; BPB_FAT_BASE(2) + BPB_FAT_SIZE32(4)*BPB_TOTAL_FAT_SECTORS(1)
.calcDataBase:
		push	bc-hl

		ld	ft,bc
		ld	de,ft

		add	de,BPB_TOTAL_FAT_SECTORS
		ld	t,(de)
		ld	f,0
		ld	bc,ft

		add	de,BPB_FAT_SIZE32-BPB_TOTAL_FAT_SECTORS
		MLoad32	ft,(de)

		jal	MathMultiplyUnsigned_32x16_p32

		push	ft
		add	de,BPB_FAT_BASE+1-BPB_FAT_SIZE32
		ld	t,(de)
		ld	f,t
		sub	de,1
		ld	t,(de)
		ld	bc,ft
		pop	ft

		MZeroExtend bc
		jal	MathAdd_32_32
		pop	bc

		pop	bc-hl
		j	(hl)




; ---------------------------------------------------------------------------
; -- Open a directory for iterating
; --
; -- Inputs:
; --   ft - pointer to directory struct
; --   bc - path
; --   de - pointer to filesystem struct
; --
; -- Output:
; --    f - "eq" if directory could be opened. Directory struct is filled in
; --        with information on first file
; --
dirOpen:
		pusha

		ld	bc,ft

		; clear file index
		jal	BlockAllocSector
		add	bc,udir_File
		ld	(bc),ft

		ld	bc,ft ; bc - file struct

		add	de,fat32_RootCluster
		MLoad32	ft,(de)
		sub	de,fat32_RootCluster

		jal	openFileSector

		ld	ft,de
		ld	bc,ft
		pop	ft
		jal	dirRead

		pop	bc-hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Read next file information from directory
; --
; -- Inputs:
; --   ft - pointer to directory struct
; --   bc - pointer to filesystem struct
; --
; -- Output:
; --    f - "eq" if next file information could be retrieved. Directory
; --        struct is filled in with information on file.
; --        "ne" when no more files present.
; --
		SECTION "Fat32DirRead",CODE
dirRead:
		pusha

		ld	de,ft

		; bc <- file struct
.next_file_entry
		add	de,udir_File
		ld	ft,(de+)
		ld	bc,ft

		; alloc 32 bytes
		MStackAlloc 32
		ld	de,ft

		; read 32 bytes
		ld	ft,32

		; --   ft - bytes to read
		; --   bc - pointer to file struct
		; --   de - destination pointer (data segment)

		jal	fileRead
		cmp	f,0
		j/ne	.read_fail
		cmp	t,32
		j/ne	.read_fail

		pop	ft
		push	ft
		ld	bc,ft

		; check entry, read again if not valid entry

		ld	t,(de)
		cmp	t,0
		j/ne	.not_end

		; we have reached the end
.read_fail
		popa
		ld	f,FLAGS_NE
		MStackFree 32
		j	(hl)

.not_end	ld	t,(de)
		cmp	t,$E5
		j/eq	.skip_file

		; check attributes
		ld	t,0
		add	bc,dir_Flags
		ld	(bc),t

		add	de,DIRENT_ATTR
		ld	t,(de)
		and	t,ATTR_DIRECTORY
		cmp	t,0
		j/eq	.not_dir
		ld	t,DFLAG_DIR
		ld	(bc),t
.not_dir
		ld	t,(de)
		sub	de,DIRENT_ATTR
		and	t,ATTR_HIDDEN|ATTR_LABEL
		cmp	t,0
		j/eq	.attr_ok

.skip_file
		MStackFree 32
		ld	ft,bc
		sub	ft,dir_Flags
		ld	de,ft
		pop	bc
		push	bc
		ld	hl,.next_file_entry
		j	(hl)
.attr_ok

		add	bc,dir_Filename+1-dir_Flags
		push	bc
		ld	f,8
.copy_name	ld	t,(de+)
		ld	(bc+),t
		dj	f,.copy_name
.find_space_1	ld	t,(-bc)
		cmp	t,' '
		j/eq	.find_space_1
		add	bc,1
		ld	t,'.'
		ld	(bc+),t
		ld	f,3
.copy_extension	ld	t,(de+)
		ld	(bc+),t
		dj	f,.copy_extension
.find_space_2	ld	t,(-bc)
		cmp	t,' '
		j/eq	.find_space_2
		cmp	t,'.'
		add/ne	bc,1
		ld	ft,bc
		pop	bc
		sub	ft,bc
		ld	(-bc),t	; name length

		add	bc,dir_Length-dir_Filename
		add	de,DIRENT_LENGTH-DIRENT_ATTR

		MPush32 ft,(de)
		MPop32	(bc),ft

		popa
		ld	f,FLAGS_EQ
		MStackFree 32
		j	(hl)


; ---------------------------------------------------------------------------
; -- Open file. file_Flags, file_Error and file_Length are filled in.
; --
; -- Inputs:
; --   ft - file name path
; --   bc - file struct
; --   de - pointer to filesystem struct
; --
; -- Output:
; --    t - Error code
; --    f - "eq" if success
; --
fileOpen:
		push	bc-hl

		MDebugMemory ft,16

		push	ft
		MStackAlloc 512
		ld	bc,ft
		pop	ft

		; --   ft - file name path
		; --   bc - sector buffer
		; --   de - pointer to filesystem struct
;		jal	findFile
;		j/eq	.found

		ld	f,FLAGS_NE
		ld	t,ERROR_NOT_AVAILABLE
		j	.exit

.found		ld	f,FLAGS_EQ
.exit		
		MStackFree 512		
		pop	bc-hl
		j	(hl)

fileClose:
		ld	f,FLAGS_EQ
		j	(hl)

; ---------------------------------------------------------------------------
; -- Read from file offset
; --
; -- Inputs:
; --   ft - bytes to read
; --   bc - pointer to file struct
; --   de - destination pointer (data segment)
; --
; -- Output:
; --   ft - bytes actually read
; --
fileRead:
		pusha
		push	ft

		; --
		; -- Read from first sector
		; --
.read_next
		add	bc,ufile_RemainingBytes
		ld	ft,(bc+)
		ld	hl,ft
		pop	ft
		push	ft
		cmp	ft,hl
		j/leu	.enough_in_first
		ld	ft,hl
		j	.found_to_read
.enough_in_first
		pop	ft
		push	ft
.found_to_read
		; ft - bytes to read from first sector
		; hl - remaining bytes in sector
		pusha
		exg	ft,hl
		sub	ft,hl
		ld	(-bc),ft	; adjust remaining in structure
		popa

		push	ft

		add	bc,ufile_SectorData-(ufile_RemainingBytes+1)
		ld	ft,(bc+)
		add	ft,512
		sub	ft,hl
		ld	bc,ft	; bc <- source

		pop	ft
		ld	hl,ft

		; adjust number of bytes to read
		pop	ft
		sub	ft,hl
		push	ft

		; loop adjust
		tst	hl
		j/eq	.skip_copy
		sub	hl,1
		add	h,1
		add	l,1

.copy_bytes_1	ld	t,(bc+)
		ld	(de+),t
		dj	l,.copy_bytes_1
		dj	h,.copy_bytes_1
.skip_copy
		; --
		; -- Cache next sector
		; --
		pop	bc
		push	bc
		add	bc,ufile_RemainingBytes
		ld	ft,(bc+)
		tst	ft
		j/ne	.dont_read_next

		add	bc,file_System-(ufile_RemainingBytes+1)
		ld	ft,(bc)
		exg	ft,bc

		; --   ft - file structure
		; --   bc - pointer to filesystem structure

		j @+2
		jal	readNextFileSector

.dont_read_next
		pop	ft
		push	ft
		tst	ft
		j/eq	.done

		pop	bc
		push	bc
		j	.read_next
.done
		pop	ft
		ld	bc,ft	; bc = left to read
		pop	ft
		sub	ft,bc	; ft = total read
		pop	bc-hl
		j	(hl)

; ---------------------------------------------------------------------------
; -- Read volume boot record
; --
; -- Inputs:
; --   bc - pointer to block device structure
; --   de - pointer to destination
; --
		SECTION	"loadVolumeBootRecord",CODE
loadVolumeBootRecord:
		push	hl

		MDebugPrint <"loadVolumeBootRecord\n">

		; load volume boot record

		ld	ft,0
		push	ft
		jal	BlockDeviceRead

		pop	hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Check if sector is FAT32 volume boot record
; --
; -- Inputs:
; --   de - pointer to VBR
; --
		SECTION	"checkFat32",CODE
checkFat32:	push	bc-hl

		MDebugPrint <"checkFat32\n">

		add	de,BS_BOOT_RECORD_SIG
		ld	t,(de)
		cmp	t,$55
		j/ne	.exit

		add	de,1
		ld	t,(de)
		cmp	t,$AA
		j/ne	.exit

		add	de,BS_BOOT_SIG32-(BS_BOOT_RECORD_SIG+1)
		ld	t,(de)
		cmp	t,FAT32_BOOT_SIG
		j/ne	.exit

		add	de,BS_FSTYPE32-BS_BOOT_SIG32
		ld	bc,.signature
		ld	l,8
.sigloop	lco	t,(bc)
		ld	h,t
		ld	t,(de)
		cmp	t,h
		j/ne	.exit
		add	bc,1
		add	de,1
		dj	l,.sigloop

.exit		pop	bc-hl
		j	(hl)

.signature	DB	"FAT32   "


; ---------------------------------------------------------------------------
; -- Convert cluster number to sector number
; --
; -- Inputs:
; --   ft:ft' - cluster (consumed)
; --   bc     - pointer to filesystem structure
; --
; -- Outputs:
; --   ft:ft' - sector
; --
clusterToSector:
		pusha

		; move bc to de, restore cluster#
		ld	ft,bc
		ld	de,ft
		pop	ft

		MLoad32 bc,-2
		jal	MathAdd_32_32
		pop	bc

		; load cluster-to-sector 
		push	ft
		add	de,fat32_ClusterToSector
		ld	t,(de)
		ld	b,t
		pop	ft
		jal	MathShiftLeft_32

		add	de,fat32_DataBase-fat32_ClusterToSector
		MLoad32	bc,(de)
		jal	MathAdd_32_32
		pop	bc
		
		pop	bc-hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Find file
; --
; -- Inputs:
; --   ft - file name path
; --   bc - sector buffer
; --   de - pointer to filesystem struct
; --
; -- Output:
; --   f   - "eq" if file found
; --   ft' - pointer into sector buffer if found
; --
	IF 0

		SECTION	"findFile",CODE
findFile:
		pusha

		add	de,fat32_RootCluster
		MLoad32	ft,(de)
		sub	de,fat32_RootCluster

.loop		jal	findFileInCluster
		j/eq	.found
		j/ltu	.no_more_entries

		push	bc

		ld	ft,de
		ld	bc,ft
		pop	ft

		jal	getNextCluster
		pop	bc

		j/ne	.no_more_clusters

		pop	ft
		j	.loop

.no_more_clusters
		popa
		ld	f,FLAGS_NE
		j	(hl)		

.no_more_entries
		pop	ft
		pop	ft
		popa
		ld	f,FLAGS_NE
		j	(hl)		

.found		pop	bc-hl
		j	(hl)		




; -- Inputs:
; --   ft:ft' - cluster
; --   ft''   - file name path
; --   bc     - sector buffer
; --   de     - pointer to filesystem struct
; --
; -- Output:
; --   f   - "ltu" (no more entries), "eq" (found)
; --   ft' - present when found, pointer into sector buffer
; --   ft'':ft''' - cluster
; --   ft'''' - filename path
findFileInCluster
		push	bc-hl

		MPush32	ft
		push	ft/bc
		ld	ft,de
		ld	bc,ft
		pop	ft
		jal	clusterToSector
		pop	bc

		; ft:ft' - sector

		push	ft
		add	de,fat32_ClusterToSector
		ld	t,(de)
		ld	l,t
		ld	ft,1
		ls	ft,l
		ld	l,t	; l - sectors per cluster
		sub	de,fat32_ClusterToSector
		pop	ft

.sector_loop	MPush32	ft
		push	hl
		jal	findFileInSector
		pop	hl
		j/eq	.found_file
		pop	ft
		push	hl
		jal	MathInc_32
		pop	hl
		dj	l,.sector_loop

		popa

		ld	f,FLAGS_NE
		j	(hl)

.found_file	pop	bc-hl
		j	(hl)


; -- Inputs:
; --   ft:ft' - sector (consumed)
; --   ft''   - file name path
; --   bc     - filesystem 
; --   de     - sector buffer
; -- Outputs:
; --   f   - "eq" if file found
; --   ft' - pointer into sector buffer, present if found

findFileInSector
		push	bc-hl

		push	ft/bc
		ld	ft,bc
		add	ft,fs_BlockDevice
		ld	bc,(ft)
		pop	ft

		; bc - block device
		; bc' - filesystem

		jal	BlockDeviceRead
		pop	bc

		ld	l,DIRENTS_PER_SECTOR

		; Check first character in name

.file_loop	ld	t,(de)
		cmp	t,0
		j/eq	.end_of_directory

		cmp	t,$E5
		j/eq	.skip_file

		; check attributes
		add	de,DIRENT_ATTR
		ld	t,(de)
		sub	de,DIRENT_ATTR
		and	t,ATTR_HIDDEN|ATTR_LABEL
		cmp	t,0
		j/ne	.skip_file

		pop	ft
		ld	h,(ft+)	; name length
		ld	bc,ft

		ld	t,(bc+)
		ld	f,t
		ld	t,(de+)
		cmp	f,t


.skip_file	add	de,DIRENT_SIZEOF
		dj	l,.next_file
	

		pop	bc-hl
		j	(hl)
	ENDC

; ---------------------------------------------------------------------------
; -- Open file by root cluster
; --
; -- Inputs:
; --   ft:ft' - root cluster (consumed)
; --   bc     - file struct
; --   de     - pointer to filesystem struct
; --
; -- Output:
; --    t - Error code
; --    f - "eq" if success
; --
		SECTION	"openFileSector",CODE
openFileSector:
		push	bc-hl

		exg	ft,de
		ld	(bc),ft	; file_System
		exg	ft,de

		add	bc,ufile_RootCluster
		swap	ft
		ld	(bc+),ft
		add	bc,1
		swap	ft
		ld	(bc+),ft
		add	bc,1

		; ufile_Cluster
		swap	ft
		ld	(bc+),ft
		add	bc,1
		pop	ft
		ld	(bc+),ft
		add	bc,1

		; ufile_SectorIndex
		ld	(bc+),t

		jal	BlockAllocSector
		; ufile_SectorData
		ld	(bc+),ft
		add	bc,1

		ld	ft,0
		; ufile_RemainingBytes
		ld	(bc+),ft

		pop	bc-hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Read sector from file
; --
; -- Inputs:
; --   ft - file structure
; --   bc - pointer to filesystem structure
; --
readNextFileSector:
		pusha

		; read sector
		add	ft,ufile_SectorIndex
		ld	l,(ft)	; l = sector index

		add	bc,fat32_ClusterToSector
		ld	t,(bc)
		sub	bc,fat32_ClusterToSector
		ld	h,t	; h = cluster to sector
		ld	ft,1
		ls	ft,h	; ft = sectors per cluster
		ld	h,0

		cmp	ft,hl
		j/ne	.not_next_cluster

		; move to next cluster
		pop	ft
		push	ft
		add	ft,ufile_Cluster
		ld	de,ft
		; ft:ft' <- current cluster
		MLoad32 ft,(de)
		pop	bc		; bc = file system
		push	bc
		jal	getNextCluster
		j/ne	.file_end

		pop	ft
		MPop32	(de),ft

		; zero sector index
		pop	ft
		push	ft
		add	ft,ufile_SectorIndex
		ld	b,0
		ld	(ft),b	; sector index = 0

		popa
		j	readNextFileSector

.file_end	; TODO
		j	@+2

.not_next_cluster
		pop	ft
		push	ft
		ld	de,ft
		add	de,ufile_Cluster
		MLoad32 ft,(de)
		; ft:ft' = cluster
		
		jal	clusterToSector

		add	de,ufile_SectorIndex-ufile_Cluster
		push	ft
		ld	t,(de)
		ld	f,0
		ld	bc,ft
		add	t,1
		ld	(de),t	; inc sector index
		pop	ft
		push	bc
		ld	bc,0
		jal	MathAdd_32_32
		pop	bc
		; ft:ft' - sector

		pop	bc
		push	bc
		add	bc,fs_BlockDevice+1
		push	ft
		ld	ft,(-bc)
		ld	bc,ft
		; bc - block device

		add	de,ufile_SectorData-ufile_SectorIndex
		ld	ft,de
		ld	de,(ft)
		pop	ft
		; de - destination
		jal	BlockDeviceRead

		pop	ft
		push	ft
		add	ft,ufile_RemainingBytes
		ld	bc,512
		ld	(ft+),bc

		popa
		j	(hl)


; ---------------------------------------------------------------------------
; -- Get next cluster number for file
; --
; -- Inputs:
; --   ft:ft' - cluster (consumed)
; --   bc     - pointer to filesystem structure
; --
; -- Output:
; --   f        - "eq" if next cluster was found
; --   ft':ft'' - present if cluster was found
; --
getNextCluster:
		push	bc-hl

		swap	ft
		ld	hl,ft	; hl = cluster
		push	hl
		swap	ft

		push	bc
		ld	b,7
		jal	MathShiftRight_32
		pop	bc
		; ft:ft' = FAT sector index

		push	ft
		add	bc,fat32_FatBase+1
		ld	ft,(-bc)
		ld	bc,ft
		push	bc
		ld	bc,0
		pop	ft
		; bc:bc' - FAT base

		jal	MathAdd_32_32
		pop	bc
		; ft:ft' - FAT sector 
		
		push	ft
		pop	bc
		push	bc
		add	bc,fs_BlockDevice+1
		ld	ft,(-bc)
		ld	bc,ft
		; bc - block device

		MStackAlloc 512
		ld	de,ft
		; de - sector data
		pop	ft

		jal	BlockDeviceRead
		pop	hl
		j/ne	.read_fail

		ld	ft,hl
		and	t,$7F
		ld	f,0
		ls	ft,2
		add	ft,de
		ld	de,ft
		MLoad32	ft,(de)

		; Check if end marker
		MPush32 ft
		exg	f,t
		cmp	f,$FF
		j/ne	.not_end1
		and	t,$0F
		cmp	t,$0F
		j/ne	.not_end1
		pop	ft
		cmp	f,$FF
		j/ne	.not_end2
		cmp	t,$F0
		j/ltu	.not_end2

		pop	ft
		pop	ft
.read_fail		
		ld	f,FLAGS_NE
		j	.exit

.not_end1	pop	ft
.not_end2	ld	f,FLAGS_EQ
.exit
		MStackFree	512

		pop	bc-hl
		j	(hl)
