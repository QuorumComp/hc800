		INCLUDE	ONCE

		RSRESET
bdev_Read	RW	1
bdev_Write	RW	1
bdev_Size	RW	1
bdev_PRIVATE	RB	0

		GLOBAL	BlockDeviceInit
		GLOBAL	BlockDeviceGet
		GLOBAL	BlockDeviceRead
		GLOBAL	BlockDeviceSize

		GLOBAL	BlockAllocSector
		GLOBAL	BlockFreeSector
