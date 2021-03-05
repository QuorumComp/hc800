		INCLUDE	"lowlevel/math.i"
		INCLUDE	"lowlevel/rc800.i"
		INCLUDE	"lowlevel/stack.i"

		INCLUDE	"stdlib/stream.i"
		INCLUDE	"stdlib/syscall.i"

		INCLUDE	"blockdevice.i"
		INCLUDE	"mbr.i"

TYPE_FAT32_LBA	EQU	$0C

		RSRESET
part_Status	RB	1
part_StartCHS	RB	3
part_Type	RB	1
part_EndCHS	RB	3
part_StartLBA	RB	4
part_Sectors	RB	4
part_SIZEOF	RB	0

		RSSET	$1BE
mbr_Partition0	RB	part_SIZEOF
mbr_Partition1	RB	part_SIZEOF
mbr_Partition2	RB	part_SIZEOF
mbr_Partition3	RB	part_SIZEOF

; ---------------------------------------------------------------------------
; -- Make MBR partition structure
; --
; -- Inputs:
; --    t - partition index, 0 to 3
; --   bc - pointer to block device structure to fill in
; --   de - underlying block device
; --
; -- Returns:
; --    f - "eq" condition if success
; --
		SECTION	"MakeMbrPartitionDevice",CODE
MakeMbrPartitionDevice:
		pusha

		;MPrintString <"MakeMbrPartitionDevice\n">
		pusha
		ld	ft,bc
		jal	StreamHexWordOut
		MNewLine
		popa

		; zero block number variable

		ld	bc,blockNumber
		ld	t,0
		ld	(bc),t
		add	bc,1
		ld	(bc),t
		add	bc,1
		ld	(bc),t
		add	bc,1
		ld	(bc),t
		sub	bc,3

		MStackAlloc 512
		exg	ft,de

		; ft = underlying device
		; bc = blockNumber
		; de = sector buffer

		;MPrintString <"  - load MBR\n">
		jal	BlockDeviceRead
		;MPrintString <"  - loaded MBR\n">
		j/ne	.fail_popa

		; check signature

		add	de,510
		ld	t,(de)
		cmp	t,$55
		j/ne	.fail_popa
		add	de,1
		ld	t,(de)
		cmp	t,$AA
		j/ne	.fail_popa
		add	de,mbr_Partition0-511

		;MPrintString <"  - mbr signature ok\n">

		; point to partition entry

		pop	ft
		ld	f,0
		ls	ft,4
		add	ft,de
		ld	de,ft	; de = partition entry

		; ft has been popped

		; check status

		ld	t,(de)
		and	t,$7F
		cmp	t,0
		j/ne	.fail_pop_bc_to_hl

		;MPrintString <"  - partition ok\n">

		; check type

		add	de,part_Type
		ld	t,(de)
		cmp	t,TYPE_FAT32_LBA
		j/ne	.fail_pop_bc_to_hl

		; copy underlying pointer to structure

		pop	bc
		swap	de	; get underlying device pointer
		ld	ft,de
		add	bc,mbrdev_Underlying
		ld	(bc),t
		exg	f,t
		add	bc,1
		ld	(bc),t
		swap	de	; restore partition pointer

		; bc have now been popped

		; copy offset to structure

		add	bc,mbrdev_Offset-(mbrdev_Underlying+1)
		add	de,part_StartLBA-part_Type
		ld	f,4
.offset_loop	ld	t,(de)
		ld	(bc),t
		add	de,1
		add	bc,1
		dj	f,.offset_loop

		; copy size to structure

		add	de,part_Sectors-(part_StartLBA+4)
		ld	f,4
.size_loop	ld	t,(de)
		ld	(bc),t
		add	de,1
		add	bc,1
		dj	f,.size_loop

		; copy function pointers to structure

		add	bc,bdev_Read-(mbrdev_Sectors+4)
		ld	de,.template
		ld	f,.templateEnd-.template
.template_loop	lco	t,(de)
		ld	(bc),t
		add	de,1
		add	bc,1
		dj	f,.template_loop

		sub	bc,bdev_Size+1
		pop	de/hl
		ld	f,FLAGS_EQ
		j	.exit

.fail_popa	pop	ft
.fail_pop_bc_to_hl
		ld	f,FLAGS_NE
		pop	bc-hl
.exit		MStackFree 512
		j	(hl)


.template	DW	mbrRead
		DW	mbrWrite
		DW	mbrSize
.templateEnd


mbrWrite:
		ld	f,FLAGS_NE
		j	(hl)

mbrSize:
		ld	f,FLAGS_NE
		j	(hl)

; ---------------------------------------------------------------------------
; -- Read block from device
; --
; -- Inputs:
; --   ft - pointer to block device structure
; --   bc - pointer to block number
; --   de - pointer to destination
; --
; -- Returns:
; --    f - "eq" condition if success
; --
		SECTION	"ReadBlock",CODE
mbrRead:
		pusha

		ld	de,blockNumber
		ld	f,4
.copy_number	ld	t,(bc)
		ld	(de),t
		add	bc,1
		add	de,1
		dj	f,.copy_number

		sub	de,4
		pop	ft
		add	ft,mbrdev_Offset
		exg	ft,de
		exg	ft,bc

		; bc = blockNumber
		; de = mbrdev_Offset

		jal	MathAdd_32_32

		add	de,mbrdev_Underlying+1-mbrdev_Offset
		ld	t,(de)
		sub	de,1
		exg	f,t
		ld	t,(de)

		; ft = underlying block device
		; bc = blockNumber
		
		pop	de

		; de = destination

		jal	BlockDeviceRead

		pop	bc/hl
		j	(hl)


		SECTION "MbrVars",BSS
blockNumber:	DS	4
	