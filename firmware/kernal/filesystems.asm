		INCLUDE	"lowlevel/math.i"
		INCLUDE	"lowlevel/memory.i"
		INCLUDE	"lowlevel/rc800.i"

		INCLUDE	"stdlib/string.i"

		INCLUDE	"blockdevice.i"
		INCLUDE	"fat32.i"
		INCLUDE	"filesystems.i"
		INCLUDE	"uart_commands.i"
		INCLUDE	"uartfs.i"

MAX_FILESYSTEMS = 10
MAX_FAT_VOLUMES = 3

; ---------------------------------------------------------------------------
; -- Initialize file subsystem
; --
		SECTION "FileInitialize",CODE
FileInitialize:
		pusha

		ld	t,0
		push	ft

		; t - device identifier
		; t' - total filesystems

		ld	bc,filesystems
		ld	de,fat32Filesystems

.next_blockdevice
		jal	mountFat
		j/ne	.no_fat

		; success, store filesystem pointer

		jal	.storeFsPointer

		swap	ft
		add	t,1	; increase total filesystems
		swap	ft

.no_fat		add	t,1
		cmp	t,TOTAL_BLOCKDEVICES
		j/ne	.next_blockdevice

		ld	de,UartFilesystem
		jal	.storeFsPointer

		; restore total number of filesystems and store

		pop	ft
		ld	bc,totalFilesystems
		ld	(bc),t

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
		exg	ft,bc
		ld	(ft),e
		add	ft,1
		ld	(ft),d
		add	ft,1
		exg	ft,bc

		j	(hl)


; t  - device identifier
; de - file system structure
mountFat:
		push	bc/hl

		jal	BlockDeviceGet
		j/ne	.fail

		jal	Fat32FsMake

.fail		pop	bc/hl
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

		; set filesystem pointer in file struct
		ld	ft,bc
		ld	(ft),l
		add	ft,1
		ld	(ft),h

		; get open function
		add	hl,fs_Open+1
		lco	t,(hl)
		exg	f,t
		sub	hl,1
		lco	t,(hl)

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

		; get filesystem
		ld	ft,bc
		ld	c,(ft)
		add	ft,1
		ld	b,(ft)

		; get close function
		add	bc,fs_Close+1
		lco	t,(bc)
		exg	f,t
		sub	bc,1
		lco	t,(bc)

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

		push	ft-bc
		; get filesystem
		ld	ft,bc
		ld	c,(ft)
		add	ft,1
		ld	b,(ft)

		; get read function
		add	bc,fs_Read+1
		lco	t,(bc)
		exg	f,t
		sub	bc,1
		lco	t,(bc)
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

