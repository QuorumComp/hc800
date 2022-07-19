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


			RSSET	dir_PRIVATE
udir_Cluster		RB	4
udir_FileIndex		RB	2
udir_SIZEOF		RB	0

			RSSET	file_PRIVATE
ufile_RootCluster	RB	4
ufile_Cluster		RB	4
ufile_SectorIndex	RB	1
ufile_SectorData	RB	2
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

		; clear file index
		add	ft,udir_Cluster
		add	de,fat32_RootCluster
		MCopy	ft,de,4

		add	ft,udir_FileIndex-udir_Cluster
		ld	b,0
		ld	(ft+),b
		ld	(ft),b

		; bc <- filesystem
		sub	de,fat32_RootCluster
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
		MDebugPrint "dirRead\n"
		MDebugMemory ft,32
		pusha
		ld	de,ft

		; TODO: move to next cluster if done with current

		; ft <- file index
.next_file_index
		add	de,udir_FileIndex+1
		ld	t,(de)
		ld	f,t
		sub	de,1
		ld	t,(de)	; ft = file index

		rs	ft,4	; 16 entries per sector

		ld	hl,ft	; hl = sector# in cluster
		push	hl
		add	de,udir_Cluster-udir_FileIndex
		MLoad32	ft,(de)
		jal	clusterToSector
		pop	hl

		exg	bc,hl
		push	bc
		ld	bc,0
		jal	MathAdd_32_32
		pop	bc

		; ft:ft' = sector number

		pop	bc
		push	bc
		push	ft
		add	bc,fs_BlockDevice+1
		ld	t,(bc)
		ld	f,t
		sub	bc,1
		ld	t,(bc)
		ld	bc,ft

		; bc = block device

		MStackAlloc 512
		ld	de,ft
		pop	ft

		jal	BlockDeviceRead
		j/ne	.read_fail

		MDebugMemory de,32

		pop	ft
		push	ft
		ld	bc,ft

		add	bc,dir_Error
		ld	t,ERROR_SUCCESS
		ld	(bc),t

		add	bc,udir_FileIndex-dir_Error
		ld	t,(bc)
		and	t,$F
		ld	f,0
		ls	ft,5
		add	ft,de
		ld	de,ft	; de = dir entry

		ld	t,(de)
		cmp	t,0
		j/ne	.not_end

		; we have reached the end
.read_fail
		popa
		ld	f,FLAGS_NE
		MStackFree 512
		j	(hl)

.not_end	; increment file index
		ld	ft,(bc+)
		add	ft,1
		ld	(-bc),ft
		add	bc,dir_Flags-udir_FileIndex

		ld	t,(de)
		cmp	t,$E5
		j/eq	.skip_file

		; check attributes
		ld	t,0
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
		MStackFree 512
		ld	ft,bc
		sub	ft,dir_Flags
		ld	de,ft
		pop	bc
		push	bc
		ld	hl,.next_file_index
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
		MStackFree 512
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
		jal	findFile
		j/eq	.found

		ld	f,FLAGS_NE
		j	.exit

.found		ld	f,FLAGS_EQ
.exit		
		MStackFree 512		
		pop	bc-hl
		j	(hl)

fileClose:
		ld	f,FLAGS_EQ
		j	(hl)

fileRead:
		ld	f,FLAGS_EQ
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
; --   f  - "eq" if file found
; --   ft - pointer into sector buffer
; --
		SECTION	"findFile",CODE
findFile:
		push	bc-hl

		push	ft

		add	de,fat32_ClusterToSector
		ld	t,(de)
		ld	l,t
		ld	ft,1
		ls	ft,l
		ld	l,t	; l - sectors per cluster

		push	ft
		add	de,fat32_RootCluster-fat32_ClusterToSector
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

		j/ne	.no_more_entries

		pop	ft
		j	.loop

.no_more_entries
		pop	ft	; remove 
		ld	f,FLAGS_NE

.found		pop	bc-hl
		j	(hl)		




; -- Inputs:
; --   ft:ft' - cluster (consumed)
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
		push	ft
		ld	f,FLAGS_LTU
		j	(hl)

		jal	clusterToSector

		; ft:ft' - sector
		; bc - filesystem 
		; de - sector buffer

		push	hl
.sector_loop	MPush32	ft
		jal	.find_file_in_sector
		pop	hl
		j/eq	.found_file
		pop	ft
		jal	MathInc_32
		dj	l,.sector_loop

		ld	f,FLAGS_NE

.found_file	pop	bc-hl
		j	(hl)


; -- Inputs:
; --   ft:ft' - sector (consumed)
; --   bc     - filesystem 
; --   de     - sector buffer
; -- Outputs:
; --   f   - "eq" if file found
; --   ft' - pointer into sector buffer, present if found

.find_file_in_sector
		push	ft/bc
		ld	ft,bc
		add	ft,fs_BlockDevice
		ld	bc,(ft)
		pop	ft

		; bc - block device
		; bc' - filesystem

		jal	BlockDeviceRead

		ld	l,16 ; max file entries per sector
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
		pusha

		add	bc,ufile_RootCluster
		ld	(bc+),ft
		add	bc,1
		pop	ft
		ld	(bc+),ft
		add	bc,1

		ld	ft,0

		; ufile_CLuster
		ld	(bc+),ft
		add	bc,1
		ld	(bc+),ft
		add	bc,1

		; ufile_SectorIndex
		ld	(bc+),t

		jal	BlockAllocSector
		; ufile_SectorData
		ld	(bc),ft

		popa
		j	(hl)


; ---------------------------------------------------------------------------
; -- Read sector from file
; --
; -- Inputs:
; --   ft - file structure
; --   bc - pointer to filesystem structure
; --   de - destination
; --
readFileSector:
		pusha

		; read sector
		add	ft,ufile_SectorIndex
		ld	l,(ft)	; l = sector index

		add	bc,fat32_ClusterToSector
		ld	t,(bc)
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
		j	readFileSector

.file_end	; TODO
		j	@+2

.not_next_cluster
		sub	bc,fat32_ClusterToSector

		pop	ft
		push	ft
		ld	de,ft
		add	de,ufile_Cluster
		MLoad32 ft,(de)
		; ft:ft' = cluster
		
		jal	clusterToSector

		add	de,ufile_SectorIndex-ufile_Cluster
		ld	t,(de)
		ld	f,0
		ld	bc,ft
		push	bc
		ld	bc,0

		jal	MathAdd_32_32
		; ft:ft' - sector

		pop	bc
		push	bc
		add	bc,fs_BlockDevice+1
		push	ft
		ld	ft,(-bc)
		ld	bc,ft
		pop	ft
		; bc - block device

		pop	de
		push	de
		; de - destination
		jal	BlockDeviceRead

		popa
		j	(hl)


; ---------------------------------------------------------------------------
; -- Get next cluster number for file
; --
; -- Inputs:
; --   ft:ft' - cluster
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
		swap	ft

		ld	de,ft

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
		; bc:bc' - FAT base

		jal	MathAdd_32_32
		; ft:ft' - FAT sector 
		
		push	ft
		pop	bc
		push	bc
		add	bc,fs_BlockDevice+1
		ld	ft,(-bc)
		ld	bc,ft
		pop	ft
		; bc - block device

		MStackAlloc 512
		ld	de,ft
		; de - sector data

		push	hl
		jal	BlockDeviceRead
		pop	hl
		j/ne	.exit

.exit		ld	ft,hl
		and	t,$7F
		ld	f,0
		ls	ft,2
		add	ft,de
		ld	de,ft
		MLoad32	ft,(de)

		; TODO: Check if end marker

		push	ft
		ld	f,FLAGS_EQ

		MStackFree	512

		pop	bc-hl
		j	(hl)
