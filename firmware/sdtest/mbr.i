	IFND	LOWLEVEL_MBR_I_INCLUDED__
LOWLEVEL_MBR_I_INCLUDED__ = 1

	INCLUDE	"blockdevice.i"

			RSSET	bdev_PRIVATE
mbrdev_Underlying	RW	1
mbrdev_Offset		RB	4		
mbrdev_Sectors		RB	4		
mbrdev_SIZEOF		RB	0


	GLOBAL	MakeMbrPartitionDevice

	ENDC
