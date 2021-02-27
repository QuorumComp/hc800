	IFND	LOWLEVEL_FAT32_I_INCLUDED__

LOWLEVEL_FAT32_I_INCLUDED__ = 1

		INCLUDE	"kernal/filesystems.i"

			RSSET	fs_PRIVATE
fs_ClusterToSector	RB	1	; amount to shift sector number
fs_RootCluster		RB	4
fs_FatBase		RB	2
fs_DataBase		RB	4
fs_Fat32_SIZEOF		RB	0

		GLOBAL	Fat32FsMake
		
	ENDC
