		INCLUDE	"lowlevel/math.i"
		INCLUDE	"lowlevel/memory.i"
		INCLUDE	"lowlevel/rc800.i"

		INCLUDE	"stdlib/stream.i"
		INCLUDE	"stdlib/string.i"
		INCLUDE	"stdlib/syscall.i"

		INCLUDE	"blockdevice.i"
		INCLUDE	"fat32.i"
		INCLUDE	"filesystems.i"
		INCLUDE	"uartfs.i"

		INCLUDE	"uart_commands.i"
		INCLUDE	"uart_commands_disabled.i"

MAX_FILESYSTEMS = 10
MAX_FAT_VOLUMES = 3

; -- Get block device information
; --    t - volume index
; --   bc - volume information structure
; -- Outputs:
; --    f - "eq" condition if volume exists and information structure filled
; --        "ne" condition when volume index and further indices do not exist
		SECTION	"SysGetVolume",CODE
SysGetVolume::
		push	bc-de

		MDebugPrint <"SysGetVolume\n">

		ld	f,t

		ld	de,totalFilesystems
		ld	t,(de)
		exg	f,t

		MDebugPrint <"- 1\n">

		cmp	t,f
		j/geu	.invalid

		add	t,t
		ld	f,0
		add	ft,filesystems

		MDebugHexWord ft
		MDebugNewLine

		ld	e,(ft)
		add	ft,1
		ld	d,(ft)

		MDebugHexWord de
		MDebugNewLine

		MDebugPrint <"- 2\n">

		ld	f,fs_Open
.copy_names	ld	t,(de)
		ld	(bc),t
		add	de,1
		add	bc,1
		dj	f,.copy_names

		ld	f,FLAGS_EQ

.exit		MDebugPrint <"- exit\n">

		pop	bc-hl
		reti

.invalid	ld	f,FLAGS_NE
		j	.exit


; ---------------------------------------------------------------------------
; -- Initialize file subsystem
; --
		SECTION "FileInitialize",CODE
FileInitialize:
		pusha

		jal	UartInitialize

		ld	t,0	; t - device identifier

		ld	bc,filesystems
		ld	de,fat32Filesystems

.next_blockdevice
		jal	mountFat
		j/ne	.no_fat

		; success, store filesystem pointer

		MDebugPrint <"Mounted FAT32 volume\n">

		jal	.storeFsPointer

		add	de,fs_Fat32_SIZEOF

.no_fat		add	t,1
		cmp	t,TOTAL_BLOCKDEVICES
		j/ne	.next_blockdevice

		ld	de,UartFilesystem
		jal	.storeFsPointer

		; de - UART filesystem, use as root

		ld	ft,rootFs
		ld	(ft),e
		add	ft,1
		ld	(ft),d

		; initialize root

		ld	ft,rootPath
		ld	b,0
		ld	(ft),b

		popa
		j	(hl)

.storeFsPointer
		push	ft/de/hl

		; store pointer in table

		exg	ft,bc
		ld	(ft),e
		add	ft,1
		ld	(ft),d
		add	ft,1
		exg	ft,bc

		; create volume name

		add	de,fs_Volume
		ld	t,2
		ld	(de),t
		add	de,1
		ld	t,'v'
		ld	(de),t
		add	de,1

		ld	hl,totalFilesystems
		ld	t,(hl)
		add	t,'0'
		ld	(de),t

		add	t,1-'0'
		ld	(hl),t

		pop	ft/de/hl
		j	(hl)


; t  - device identifier
; de - file system structure
mountFat:
		push	ft/bc/hl

		jal	BlockDeviceGet
		j/ne	.fail

		jal	Fat32FsMake
		j/ne	.fail

		pop	ft
		add	de,fs_BlockDevice
		ld	(de),t
		sub	de,fs_BlockDevice

		ld	f,FLAGS_EQ
		j	.exit

.fail		pop	ft
		ld	f,FLAGS_NE
.exit		pop	bc/hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Open file
; --
; -- Inputs:
; --   bc - file struct
; --   de - file name path
; --
; -- Outputs:
; --    t - Error code
; --    f - "eq" if success
; --
		SECTION	"FileOpen",CODE
FileOpen:
		push	bc-hl

		MDebugPrint <"FileOpen ">
		MDebugPrintR de
		MDebugNewLine

		; clear file handle structure
		push	de
		ld	de,file_SIZEOF
		ld	t,0
		jal	SetMemory
		pop	de

		; get filesystem
		ld	ft,rootFs
		ld	l,(ft)
		add	ft,1
		ld	h,(ft)

		MDebugHexWord hl
		MDebugNewLine

		; set filesystem pointer in file struct
		ld	ft,bc
		ld	(ft),l
		add	ft,1
		ld	(ft),h

		; get open function
		add	hl,fs_Open+1
		ld	t,(hl)
		exg	f,t
		sub	hl,1
		ld	t,(hl)

		MDebugHexWord ft
		MDebugNewLine

		jal	(ft)

		pop	bc-hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Close file
; --
; -- Inputs:
; --   bc - file struct
; --
		SECTION	"FileClose",CODE
FileClose:
		push	bc-hl

		MDebugPrint <"FileClose\n">

		; get filesystem
		ld	ft,bc
		ld	c,(ft)
		add	ft,1
		ld	b,(ft)

		; get close function
		add	bc,fs_Close+1
		ld	t,(bc)
		exg	f,t
		sub	bc,1
		ld	t,(bc)

		jal	(ft)

		ld	t,ERROR_SUCCESS
		ld	f,FLAGS_EQ

		pop	bc-hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Skip ahead in file
; --
; -- Inputs:
; --   ft - bytes to skip
; --   bc - pointer to file struct
; --
; -- Output:
; --    t - Error code
; --    f - "eq" if success
; --
		SECTION	"FileRead",CODE
FileSkip:
		push	bc-hl

		jal	MathLoadOperand16U

		add	bc,file_Offset
		jal	MathAdd_32_Operand

		ld	t,ERROR_SUCCESS
		ld	f,FLAGS_EQ

		pop	bc-hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Read from file offset
; --
; -- Inputs:
; --   ft - bytes to read
; --   bc - pointer to file struct
; --   de - destination pointer (data segment)
; --
; -- Output:
; --    t - Error code
; --    f - "eq" if success
; --
		SECTION	"FileRead",CODE
FileRead:
		push	bc-hl

		MDebugPrint <"FileRead ">
		MDebugHexWord ft
		MDebugNewLine

		push	ft-bc
		; get filesystem
		ld	ft,bc
		ld	c,(ft)
		add	ft,1
		ld	b,(ft)

		; get read function
		add	bc,fs_Read+1
		ld	t,(bc)
		exg	f,t
		sub	bc,1
		ld	t,(bc)
		ld	hl,ft

		pop	ft-bc
		jal	(hl)

		jal	MathLoadOperand16U

		add	bc,file_Error
		ld	t,(bc)
		cmp	t,ERROR_SUCCESS
		j/ne	.exit

		add	bc,file_Offset-file_Error
		jal	MathAdd_32_Operand

		ld	t,ERROR_SUCCESS
		ld	f,FLAGS_EQ

.exit		pop	bc-hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Read byte from file offset
; --
; -- Inputs:
; --   bc - pointer to file struct
; --
; -- Output:
; --    t - byte
; --    f - "eq" if success
; --
		SECTION	"FileReadByte",CODE
FileReadByte:
		push	bc-hl

		ld	ft,1
		ld	de,readBuffer
		jal	FileRead

		ld	t,(de)

		pop	bc-hl
		j	(hl)


			SECTION	"FilesystemVars",BSS
fat32Filesystems:	DS	fs_Fat32_SIZEOF*MAX_FAT_VOLUMES
filesystems:		DS	MAX_FILESYSTEMS*2
totalFilesystems:	DS	1
readBuffer:		DS	2
rootFs:			DS	2
rootPath:		DS_STR
filePath:		DS_STR

