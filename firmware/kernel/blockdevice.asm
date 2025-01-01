		INCLUDE	"lowlevel/rc800.i"

		INCLUDE	"stdlib/stream.i"
		INCLUDE	"stdlib/string.i"
		INCLUDE	"stdlib/syscall.i"

		INCLUDE	"blockdevice.i"
		INCLUDE	"mbr.i"
		INCLUDE	"sddevice.i"
		INCLUDE	"uart_commands.i"

		INCLUDE	"uart_commands_disabled.i"

BYTES_PER_SECTOR = 512
SECTOR_HEAP_SIZE = 8

MAX_PARTITIONS = 3

; -- Get block device information
; --    t - block device identifier
; --   bc - block device information structure
; -- Outputs:
; --    f - "eq" condition if device exists and information structure filled
		SECTION	"SysGetBlockDevice",CODE
SysGetBlockDevice::
		push	ft-de

		exg	ft,bc
		ld	de,ft
		exg	ft,bc

		; de - syscall block device information structure

		jal	BlockDeviceGet
		j/ne	.fail

		; bc - kernel device structure
		; de - syscall block device information structure

		ld	t,1
		ld	(de),t

		exg	de,ft
		exg	bc,ft

		; ft - kernel device structure
		; bc - syscall block device structure

		add	bc,bdinf_Size-bdinf_Valid
		jal	BlockDeviceSize

		pop	ft
		push	ft
		
		; ft = ft*5
		ld	f,0
		ld	de,ft
		ls	ft,2
		add	ft,de

		add	ft,.device_names
		ld	de,ft

		add	bc,bdinf_Name-bdinf_Size

		ld	f,5
.copy_name	lco	t,(de)
		ld	(bc),t
		add	de,1
		add	bc,1
		dj	f,.copy_name

		popa
		ld	f,FLAGS_EQ

		reti

.fail		ld	t,0
		ld	(de),t	; clear bdinf_Valid

		popa
		ld	f,FLAGS_NE

		reti

.device_names	DB	3,"sda",0
		DB	4,"sda0"
		DB	4,"sda1"
		DB	4,"sda2"
		DB	3,"sdb",0
		DB	4,"sdb0"
		DB	4,"sdb1"
		DB	4,"sdb2"

; ---------------------------------------------------------------------------
; -- Initialize block devices
; --
		SECTION	"BlockDeviceInit",CODE
BlockDeviceInit:
		pusha

		MDebugPrint <"Init sector heap\n">
		ld	bc,sectors

		ld	ft,freeSectors
		ld	(ft+),c
		ld	(ft),b
	
		ld	l,SECTOR_HEAP_SIZE-1
.sector_heap_loop
		ld	ft,bc
		add	bc,BYTES_PER_SECTOR
		ld	(ft+),c
		ld	(ft),b
		dj	l,.sector_heap_loop
		ld	ft,bc
		ld	c,0
		ld	(ft+),c
		ld	(ft),c

		MDebugPrint <"Init sda\n">

		ld	bc,blockDevicePointers
		ld	d,0
		jal	.init_devices

		MDebugPrint <"Init sdb\n">

		add	bc,4*2
		ld	d,1
		jal	.init_devices

		MDebugPrint <"Block devices initialized\n">

		popa
		j	(hl)

.init_devices
		; bc - block device pointers
		; d - sd card index

		pusha

		jal	.next_device
		exg	ft,bc

		; ft - block device pointers
		; bc - sd device structure

		push	ft

		ld	t,d
		jal	SdDeviceMake
		j/eq	.sd_ok

		pop	ft
		popa
		j	(hl)

.sd_ok	
		MDebugPrint <"SD card present, find partitions\n">

		pop	ft

		; ft - block device pointers
		; bc - sd device structure

		exg	ft,bc
		ld	de,ft

		; bc - block device pointers
		; de - sd device structure

		ld	t,0

.init_loop	push	ft
		jal	.next_device
		push	bc
		ld	bc,ft
		pop	ft

		;MDebugPrint <"Call MakeMbrPartitionDevice ">
		;MDebugNewLine
		;MDebugStacks
		push	ft
		jal	MakeMbrPartitionDevice
		;MDebugMemory bc,mbrdev_SIZEOF
		pop	ft
		;MDebugPrint <"After MakeMbrPartitionDevice ">
		;MDebugNewLine
		;MDebugStacks

		pop	bc
		
		add	t,1
		cmp	t,MAX_PARTITIONS
		j/ne	.init_loop

.exit		popa
		j	(hl)

; bc - device pointers
.next_device	lco	t,(bc)
		exg	f,t
		add	bc,1
		lco	t,(bc)
		exg	f,t
		add	bc,1
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
		SECTION	"BlockDeviceRead",CODE
BlockDeviceRead:
		MDebugPrint <"BlockDeviceRead call ">
		MDebugRegisters
		
		push	bc/hl

		exg	ft,bc
		add	ft,bdev_Read
		ld	hl,(ft+)
		sub	ft,bdev_Read+1
		exg	ft,bc

		MDebugStacks
		MDebugMemory bc,8

		jal	(hl)

		pop	bc/hl

		MDebugPrint <"BlockDeviceRead exit ">
		MDebugStacks

		j	(hl)


; ---------------------------------------------------------------------------
; -- Get block device size
; --
; -- Inputs:
; --   ft - pointer to block device structure
; --   bc - pointer to size in blocks (4 bytes)
; --
; -- Returns:
; --    f - "eq" condition if success
; --
		SECTION	"BlockDeviceSize",CODE
BlockDeviceSize:
		push	hl

		push	ft
		add	ft,bdev_Size
		ld	l,(ft)
		add	ft,1
		ld	h,(ft)

		pop	ft

		jal	(hl)

		pop	hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Get block device structure
; --
; -- Inputs:
; --    t - block device identifier
; --
; -- Returns:
; --    f - "eq" condition if success
; --   bc - block device structure
; --
BlockDeviceGet:
		push	de

		cmp	t,TOTAL_BLOCKDEVICES
		j/geu	.fail

		add	t,t
		ld	f,0
		add	ft,blockDevicePointers+1
		ld	bc,ft

		lco	t,(bc)
		sub	bc,1
		exg	f,t
		lco	t,(bc)

		ld	bc,ft

		; is Read function pointer NULL?

		ld	d,(ft)
		add	ft,1
		ld	t,(ft)
		or	t,d
		cmp	t,0
		j/eq	.fail

		ld	f,FLAGS_EQ
		pop	de
		j	(hl)

.fail		ld	f,FLAGS_NE
		pop	de
		j	(hl)


; ---------------------------------------------------------------------------
; -- Allocate a sector from the sector heap
; --
; -- Returns:
; --   ft - pointer to block or null if failure
; --
		SECTION	"BlockAllocSector",CODE
BlockAllocSector:
		push	bc-de

		ld	de,freeSectors
		ld	ft,(de)
		push	ft

		ld	bc,ft
		ld	ft,(bc)
		ld	(de),ft

		pop	ft-de
		j	(hl)
		

; ---------------------------------------------------------------------------
; -- Return a sector to the sector heap
; --
; -- Input:
; --   ft - pointer to block
; --
		SECTION	"BlockFreeSector",CODE
BlockFreeSector:
		pusha

		ld	bc,ft

		ld	de,freeSectors
		ld	ft,(de)
		ld	(bc),ft
		ld	ft,bc
		ld	(de),ft

		popa
		j	(hl)


		SECTION	"BlockDevicesList",CODE
blockDevicePointers:
		DW	sda
		DW	sda0
		DW	sda1
		DW	sda2
		DW	sdb
		DW	sdb0
		DW	sdb1
		DW	sdb2
TOTAL_DEVICES	EQU	(@-blockDevicePointers)/2


		SECTION	"BlockDevices",BSS
sda:		DS	sddev_SIZEOF
sda0:		DS	mbrdev_SIZEOF
sda1:		DS	mbrdev_SIZEOF
sda2:		DS	mbrdev_SIZEOF
sdb:		DS	sddev_SIZEOF
sdb0:		DS	mbrdev_SIZEOF
sdb1:		DS	mbrdev_SIZEOF
sdb2:		DS	mbrdev_SIZEOF
sectors:	DS	BYTES_PER_SECTOR*SECTOR_HEAP_SIZE
freeSectors:	DS	2
