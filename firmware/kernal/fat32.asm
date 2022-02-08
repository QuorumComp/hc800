		INCLUDE	"lowlevel/math.i"
		INCLUDE	"lowlevel/rc800.i"
		INCLUDE	"lowlevel/stack.i"

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
.copy_template	ld	t,(hl)
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
		add	de,fs_ClusterToSector-fs_Label
		ld	t,(bc)
		ld	f,0
		jal	MathLog2_16
		ld	(de),t

		; get root directory cluster

		add	bc,BPB_ROOT_CLUSTER-BPB_SECTORS_PER_CLUSTER
		add	de,fs_RootCluster-fs_ClusterToSector
		jal	.copy4

		; get FAT base cluster

		add	bc,BPB_FAT_BASE-BPB_ROOT_CLUSTER
		add	de,fs_FatBase-fs_RootCluster
		jal	.copy2

		; calculate data base
		sub	bc,BPB_FAT_BASE
		jal	.calcDataBase

		swap	de	; get fs structure
		add	de,fs_DataBase

		; this pops one FT too many, the popa at the end of this function is therefore on bc-hl
		MPop32	(de),ft

		sub	de,fs_DataBase
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
; --   bc - FAT32 directory structure to fill in
; --   de - pointer to path
; --
dirOpen:
		MStackAlloc 
		jal	followPath


; ---------------------------------------------------------------------------
; -- Read next file information from directory
; --
; -- Inputs:
; --   bc - pointer to directory struct
; --
; -- Output:
; --    f - "eq" if next file information could be retrieved. Directory
; --        struct is filled in with information on file.
; --        "ne" when no more files present.
; --
		SECTION "Fat32DirRead",CODE
dirRead:
		j	(hl)


; ---------------------------------------------------------------------------
; -- Follow a file path
; --
; -- Inputs:
; --   ft - 32 byte working buffer
; --   bc - pointer to path
; --   de - FAT32 directory structure to fill in
; --
followPath:
		pusha

		popa
		j	(hl)


fileOpen:
		ld	f,FLAGS_EQ
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


		SECTION	"Fat32Vars",BSS
fs:		DS	2
sectorDirty:	DS	1
sectorData:	DS	512
