		INCLUDE	"lowlevel/rc800.i"

		INCLUDE	"stdlib/stream.i"
		INCLUDE	"stdlib/syscall.i"

		INCLUDE	"blockdevice.i"
		INCLUDE	"mbr.i"
		INCLUDE	"sddevice.i"

MAX_PARTITIONS = 3

; ---------------------------------------------------------------------------
; -- Initialize block devices
; --
		SECTION	"BlockDeviceRead",CODE
BlockDeviceInit:
		pusha

		ld	bc,blockDevicePointers
		ld	d,0
		jal	.init_devices

		add	bc,4*2
		ld	d,1
		jal	.init_devices

		;MPrintString <"Block devices initialized\n">

		popa
		j	(hl)

.init_devices
		; bc - block device pointers
		; d - sd card index

		pusha

		jal	.init_sd
		j/eq	.sd_ok
		popa
		j	(hl)

.sd_ok		lco	t,(bc)
		exg	f,t
		add	bc,1
		lco	t,(bc)
		exg	f,t
		add	bc,1

		ld	de,ft
		ld	t,0
.init_loop	push	ft
		jal	.init_mbr
		pop	ft
		add	bc,2
		add	t,1
		cmp	t,MAX_PARTITIONS
		j/ne	.init_loop

		popa
		j	(hl)


;  t - partition index
; bc - pointer to block device pointer
; de - pointer to underlying device
.init_mbr	pusha

		;MPrintString <"Init MBR\n">

		push	ft

		; get device structure
		lco	t,(bc)
		exg	f,t
		add	bc,1
		lco	t,(bc)
		exg	f,t

		; ft - block device to fill in

		ld	bc,ft
		pop	ft

		; --    t - partition index, 0 to 3
		; --   bc - pointer to block device structure to fill in
		; --   de - underlying block device

		jal	MakeMbrPartitionDevice

		;MPrintString <"  - done\n">

		j	.device_done

		; bc - block device pointers
		; d - sd card index
.init_sd	push	bc-hl

		;MPrintString <"Init SD\n">

		; get device structure
		lco	t,(bc)
		exg	f,t
		add	bc,1
		lco	t,(bc)
		exg	f,t

		pusha
		jal	StreamHexWordOut
		MNewLine
		popa

		ld	bc,ft
		ld	t,d

		jal	SdDeviceMake

.device_done	pop	bc-hl
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
		SECTION	"BlockDeviceRead",CODE
BlockDeviceRead:
		push	hl

		push	ft	
		add	ft,bdev_Read
		ld	l,(ft)
		add	ft,1
		ld	h,(ft)

		pop	ft

		jal	(hl)

		pop	hl
		jal	(hl)


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
		cmp	t,TOTAL_BLOCKDEVICES
		j/ltu	.fail

		add	t,t
		ld	f,0
		add	ft,blockDevicePointers
		ld	bc,ft

		lco	t,(bc)
		add	bc,1
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
		j	(hl)

.fail		ld	f,FLAGS_NE
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
