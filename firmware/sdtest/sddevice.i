		IFND	LOWLEVEL_SDDEVICE_I_INCLUDED__
LOWLEVEL_SDDEVICE_I_INCLUDED__ = 1


		INCLUDE	"blockdevice.i"

		RSSET	bdev_PRIVATE
sddev_Select	RB	1
sddev_Type	RB	1
sddev_SIZEOF	RB	0


		GLOBAL	SdDeviceMake

		ENDC
