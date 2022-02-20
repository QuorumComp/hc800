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

		ld	f,fs_CommonSize
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

		MDebugPrint <"FileInitialize\n">

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

		MDebugMemory de,fat32_SIZEOF
		add	de,fat32_SIZEOF

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
		pusha

		MDebugPrint <"mountFat\n">

		jal	BlockDeviceGet
		j/ne	.fail

		MDebugPrint <" - got block device\n">

		jal	Fat32FsMake
		j/ne	.fail

		pop	ft
		add	de,fs_DeviceId
		ld	(de),t

		ld	ft,bc
		add	de,fs_BlockDevice-fs_DeviceId
		ld	(de),t
		add	de,1
		ld	t,f
		ld	(de),t

		pop	bc-hl
		ld	f,FLAGS_EQ
		j	(hl)

.fail		popa
		ld	f,FLAGS_NE
		j	(hl)


; ---------------------------------------------------------------------------
; -- Open file
; --
; -- Inputs:
; --   ft - file name path
; --   bc - file struct
; --
; -- Outputs:
; --    t - Error code
; --    f - "eq" if success
; --
		SECTION	"FileOpen",CODE
FileOpen:
		pusha

		MDebugPrint <"FileOpen\n">

		; clear file handle structure
		ld	de,file_SIZEOF
		ld	t,0
		jal	SetMemory

		; get filesystem
		ld	ft,rootFs
		ld	e,(ft)
		add	ft,1
		ld	d,(ft)
		push	de

		MDebugHexWord de
		MDebugNewLine

		; set filesystem pointer in file struct
		ld	ft,bc
		ld	(ft),e
		add	ft,1
		ld	(ft),d

		; get open function
		add	de,fs_Open+1
		ld	t,(de)
		ld	f,t
		sub	de,1
		ld	t,(de)
		sub	de,fs_Open
		ld	hl,ft

		MDebugHexWord hl
		MDebugNewLine

		pop	ft/bc
		jal	(hl)

		pop	de/hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Close file
; --
; -- Inputs:
; --   ft - file struct
; --
		SECTION	"FileClose",CODE
FileClose:
		pusha

		MDebugPrint <"FileClose\n">

		; get filesystem
		ld	c,(ft)
		add	ft,1
		ld	b,(ft)

		; get close function
		ld	ft,bc
		add	ft,fs_Close
		ld	l,(ft)
		sub	ft,1
		ld	h,(ft)

		pop	ft
		jal	(hl)

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
		SECTION	"FileSkip",CODE
FileSkip:
		push	bc-hl

		MZeroExtend ft
		add	bc,file_Offset
		jal	MathLoadLong
		MMove32	bc,ft

		jal	MathAdd_32_32
		pop	bc
		pop	bc

		jal	MathStoreLong

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

		push	ft

		add	bc,file_Error
		ld	t,(bc)
		cmp	t,ERROR_SUCCESS
		j/eq	.no_error

		swap	ft
		popa
		j	(hl)

.no_error	ld	ft,0	; zero extend bytes read (in ft')

		add	bc,file_Offset-file_Error
		push	bc

		jal	MathLoadLong
		MMove32	bc,ft

		jal	MathAdd_32_32
		pop	bc
		pop	bc
		pop	bc
		jal	MathStoreLong

		ld	t,ERROR_SUCCESS
		ld	f,FLAGS_EQ

		pop	bc-hl
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


; ---------------------------------------------------------------------------
; -- Open directory
; --
; -- Inputs:
; --   ft - pointer to directory struct
; --   bc - path
; --
; -- Output:
; --    f - "eq" if directory could be opened. Directory struct is filled in
; --        with information on first file
; --
		SECTION	"DirectoryOpen",CODE
DirectoryOpen:
		pusha

		MDebugPrint <"DirectoryOpen\n">

		; clear directory structure
		push	ft
		ld	bc,ft
		ld	de,dir_SIZEOF
		ld	t,0
		jal	SetMemory
		pop	ft

		; get filesystem
		jal	getFileSystemFromPath
		ld	e,(ft)
		add	ft,1
		ld	d,(ft)

		; set filesystem pointer in directory struct
		ld	ft,bc
		ld	(ft),e
		add	ft,1
		ld	(ft),d

		; get open function
		ld	ft,de
		add	ft,fs_OpenDir
		ld	l,(ft)
		add	ft,1
		ld	h,(ft)

		pop	ft/bc
		MDebugMemory de,32
		jal	(hl)
		MDebugMemory de,32
		

		pop	de/hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Read next file information from directory
; --
; -- Inputs:
; --   ft - pointer to directory struct
; --
; -- Output:
; --    f - "eq" if next file information could be retrieved. Directory
; --        struct is filled in with information on file.
; --        "ne" when no more files present.
; --
		SECTION	"DirectoryRead",CODE
DirectoryRead:
		pusha

		MDebugPrint <"DirectoryRead\n">

		; get filesystem
		ld	c,(ft)
		add	ft,1
		ld	b,(ft)

		; get read function
		ld	ft,bc
		add	ft,fs_ReadDir
		ld	l,(ft)
		add	ft,1
		ld	h,(ft)
		sub	ft,fs_ReadDir

		pop	ft
		MDebugMemory bc,32
		jal	(hl)
		MDebugMemory bc,32

		pop	bc-hl
		j	(hl)


; --
; -- Private functions
; --


; ---------------------------------------------------------------------------
; -- Determine to which volume a path belongs
; --
; -- Inputs:
; --   ft - pointer to path
; --
; -- Output:
; --   ft - volume
; --
		SECTION	"getFileSystemFromPath",CODE
getFileSystemFromPath:
		push	bc-hl

		ld	bc,ft

		ld	t,(bc)
		ld	e,t	; e = remaining chars
		add	bc,1

		cmp	e,0
		j/eq	.current_fs

		ld	t,(bc)
		cmp	t,':'
		j/ne	.current_fs

		add	bc,1
		sub	e,1

		push	bc	
		; bc' = start of volume name

.find_end	cmp	e,0
		j/eq	.found_end
		ld	t,(bc)
		cmp	t,'/'
		j/eq	.found_end
		add	bc,1
		sub	e,1
		j	.find_end

.found_end	; bc = end of volume name
		ld	ft,bc
		pop	bc
		sub	ft,bc
		ld	d,t	; d = volume name length

		ld	ft,totalFilesystems
		ld	e,(ft)	; e = total filesystems
		ld	hl,filesystems
		j	.loop_entry

.check_filesystem
		ld	t,(hl)
		exg	f,t
		add	hl,1
		ld	t,(hl)
		exg	f,t
		add	hl,1

		push	ft/hl
		jal	check_filesystem_match
		j/eq	.match

.loop_entry	dj	e,.check_filesystem

		; not found

		popa
		pop	hl
		ld	ft,0
		j	(hl)

.match		popa
		pop	hl
		j	(hl)

.current_fs	pop	bc-hl
		j	(hl)

; -- Check filesystem name match
; --
; -- Inputs:
; --   ft - filesystem
; --   bc - name
; --    d - name length
; --
; -- Outputs:
; --    f = "eq" if match

check_filesystem_match
		push	bc-hl
		ld	hl,ft

		ld	e,2

.check_string	ld	t,(hl)
		cmp	t,d
		j/ne	.check_done

		pusha
		add	hl,1

.check_char	ld	t,(hl)
		add	hl,1
		ld	f,t
		ld	t,(bc)
		add	bc,1

		cmp	t,f
		j/ne	.no_match
		dj	d,.check_char

		popa
		ld	t,FLAGS_EQ
		j	.exit

.no_match	popa

.check_done	add	hl,fs_Volume
		dj	e,.check_string

		ld	t,FLAGS_NE
.exit		pop	bc-hl
		j	(hl)


			SECTION	"FilesystemVars",BSS
fat32Filesystems:	DS	fat32_SIZEOF*MAX_FAT_VOLUMES
filesystems:		DS	MAX_FILESYSTEMS*2
totalFilesystems:	DS	1
readBuffer:		DS	2
rootFs:			DS	2
rootPath:		DS_STR
filePath:		DS_STR

