		INCLUDE	"lowlevel/math.i"
		INCLUDE	"lowlevel/rc800.i"
		INCLUDE	"lowlevel/stack.i"

		INCLUDE	"stdlib/stream.i"
		INCLUDE	"stdlib/syscall.i"

		INCLUDE	"blockdevice.i"
		INCLUDE	"mbr.i"
		INCLUDE	"uart_commands.i"

		INCLUDE	"uart_commands_disabled.i"

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

		MDebugPrint <"MakeMbrPartitionDevice enter ">
		MDebugHexWord ft
		MDebugPrint <" ">
		MDebugHexWord bc
		MDebugPrint <" ">
		MDebugHexWord de
		MDebugNewLine

		MStackAlloc 512
		exg	ft,de
		exg	ft,bc

		; ft = block device to fill in
		; ft' = partition index
		; bc = block device
		; de = sector buffer

		push	ft

		; block number 0
		ld	ft,0
		push	ft

		; ft:ft' - block number
		; ft'' - block device to fill in
		; ft''' - partition index

		MDebugPrint <"  - load MBR\n">
		;MDebugStacks
		jal	BlockDeviceRead
		j/eq	.read_mbr_ok
		ld	hl,.fail_popa_ft
		j	(hl)
.read_mbr_ok
		;MDebugStacks

		pop	ft  ; restore block device

		MDebugPrint <"  - loaded MBR\n">

		exg	ft,bc
		; bc = block device to fill in
		; de = sector buffer

		; check signature

		;MDebugPrint <"  - check signature\n">

		add	de,510
		ld	t,(de)
		cmp	t,$55
		j/ne	.fail_popa
		add	de,1
		ld	t,(de)
		cmp	t,$AA
		j/ne	.fail_popa
		add	de,mbr_Partition0-511

		;MDebugPrint <"  - mbr signature ok\n">

		; point to partition entry

		pop	ft ; restore partition index

		ld	f,0
		ls	ft,4
		add	ft,de
		ld	de,ft	; de = partition entry

		; check status

		ld	t,(de)
		and	t,$7F
		cmp	t,0
		j/ne	.fail_pop_bc_to_hl

		;MDebugPrint <"  - partition ok\n">

		; check type

		add	de,part_Type
		ld	t,(de)
		;jal	ComPrintHexByte
		cmp	t,TYPE_FAT32_LBA
		j/ne	.fail_pop_bc_to_hl

		MDebugPrint <"  - partition is FAT32\n">

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

		; bc has now been popped

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
		add	bc,mbrdev_Sectors-(mbrdev_Offset+4)
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

		sub	bc,bdev_Read+.templateEnd-.template
		pop	de/hl

		ld	f,FLAGS_EQ
		j	.exit

.fail_popa_ft2	pop	ft
.fail_popa_ft	pop	ft
.fail_popa	pop	ft
.fail_pop_bc_to_hl
		MDebugPrint <"MakeMbrPartitionDevice failed\n">
		ld	f,FLAGS_NE
		pop	bc-hl
.exit
		MDebugPrint <"MakeMbrPartitionDevice exit ">
		MDebugHexWord ft
		MDebugPrint <" ">
		MDebugHexWord bc
		MDebugPrint <" ">
		MDebugHexWord de
		MDebugNewLine

		MStackFree 512
		j	(hl)

.template	DW	mbrRead
		DW	mbrWrite
		DW	mbrSize
.templateEnd


mbrWrite:
		ld	f,FLAGS_NE
		j	(hl)

; ---------------------------------------------------------------------------
; -- Get device size
; --
; -- Inputs:
; --   ft - pointer to block device structure
; --   bc - pointer to size in blocks
; --
; -- Returns:
; --    f - "eq" condition if success
; --
		SECTION	"MbrSize",CODE
mbrSize:
		pusha

		push	bc

		ld	bc,ft
		add	bc,mbrdev_Sectors
		jal	MathLoadLong

		pop	bc
		jal	MathStoreLong

		popa
		ld	f,FLAGS_EQ
		j	(hl)


; ---------------------------------------------------------------------------
; -- Read block from device
; --
; -- Inputs:
; --   ft:ft' - block number (consumed)
; --   bc - pointer to block device structure
; --   de - pointer to destination
; --
; -- Returns:
; --    f - "eq" condition if success
; --
		SECTION	"MbrReadBlock",CODE
mbrRead:
		pusha

		ld	ft,bc
		add	ft,mbrdev_Offset
		MPush32	bc,(ft)

		pop	ft
		jal	MathAdd_32_32
		pop	bc
		pop	bc

		; ft:ft' = block number
		; bc - pointer to block device structure
		; de - pointer to destination

		push	ft
		add	bc,mbrdev_Underlying+1
		ld	t,(bc)
		sub	bc,1
		exg	f,t
		ld	t,(bc)
		ld	bc,ft
		pop	ft

		; ft:ft' = block number
		; bc = underlying block device
		; de = destination

		jal	BlockDeviceRead

		pop	bc-hl
		j	(hl)
