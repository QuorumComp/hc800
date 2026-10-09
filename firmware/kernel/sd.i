		INCLUDE	ONCE

; --
; -- Set to 1 to enable SD card detection, 0 to report no card present.
; -- When 0, SdInit skips the physical probe and the rest of the
; -- block-device / FAT32 code runs normally but finds no SD devices.
; --
SD_ENABLED	EQU	1

SDTYPE_NONE	EQU	0
SDTYPE_V1	EQU	1
SDTYPE_V2	EQU	2
SDTYPE_V2_HC	EQU	3

		GLOBAL	SdResetController
		GLOBAL	SdInit
		GLOBAL	SdGetTotalBlocks
		GLOBAL	SdReadSingleBlock
		GLOBAL	SdWriteSingleBlock

		GLOBAL	SdType
		GLOBAL	SdSelect
