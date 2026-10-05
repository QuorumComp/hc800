		INCLUDE	ONCE

		INCLUDE	"kernel/filesystems.i"

		GLOBAL	Fat32FsMake

			RSSET	fs_PRIVATE
fat32_ClusterToSector	RB	1	; amount to shift sector number
fat32_RootCluster	RB	4
fat32_FatBase		RB	2
fat32_DataBase		RB	4
fat32_SIZEOF		RB	0
