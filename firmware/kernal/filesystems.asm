		INCLUDE	"lowlevel/math.i"
		INCLUDE	"lowlevel/memory.i"
		INCLUDE	"lowlevel/rc800.i"
		INCLUDE	"lowlevel/stack.i"

		INCLUDE	"stdlib/stream.i"
		INCLUDE	"stdlib/string.i"
		INCLUDE	"stdlib/syscall.i"

		INCLUDE	"blockdevice.i"
		INCLUDE	"error.i"
		INCLUDE	"fat32.i"
		INCLUDE	"filesystems.i"
		INCLUDE	"uartfs.i"

		INCLUDE	"uart_commands.i"
		INCLUDE	"uart_commands_disabled.i"

MAX_VOLUMES = 10
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

		ld	de,totalvolumes
		ld	t,(de)
		exg	f,t

		MDebugPrint <"- 1\n">

		cmp	t,f
		j/geu	.invalid

		add	t,t
		ld	f,0
		add	ft,volumes

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

		ld	bc,volumes
		ld	de,fat32volumes

.next_blockdevice
		jal	mountFat
		j/ne	.no_fat

		; success, store volume pointer

		MDebugPrint <"Mounted FAT32 volume\n">

		jal	.storeFsPointer

		MDebugMemory de,fat32_SIZEOF
		add	de,fat32_SIZEOF

.no_fat		add	t,1
		cmp	t,TOTAL_BLOCKDEVICES
		j/ne	.next_blockdevice

		ld	de,UartVolume
		jal	.storeFsPointer

		; de - UART volume, set as current

		ld	ft,currentFs
		ld	(ft),e
		add	ft,1
		ld	(ft),d

		; initialize current path

		ld	ft,currentPath
		ld	b,1
		ld	(ft),b
		add	ft,1
		ld	b,'/'
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

		ld	hl,totalvolumes
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

		; get volume
		ld	ft,currentFs
		ld	e,(ft)
		add	ft,1
		ld	d,(ft)
		push	de

		MDebugHexWord de
		MDebugNewLine

		; set volume pointer in file struct
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

		; get volume
		ld	c,(ft)
		add	ft,1
		ld	b,(ft)

		; get close function
		ld	ft,bc
		add	ft,fs_Close
		ld	l,(ft)
		add	ft,1
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

		push	ft
		add	bc,file_Offset
		ld	ft,bc
		MLoad32	bc,(ft)
		pop	ft

		jal	MathAdd_32_32
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
		MDebugPrint <"FileRead entry ">
		MDebugStacks

		push	bc-hl

		push	ft-bc
		; get volume
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

		MDebugPrint <"FileRead fail ">
		MDebugStacks

		j	(hl)

.no_error	add	bc,file_Offset-file_Error
		ld	ft,bc
		MPush32	bc,(ft)

		ld	ft,0	; zero extend bytes read (in ft')

		jal	MathAdd_32_32
		pop	bc
		pop	bc
		jal	MathStoreLong

		ld	t,ERROR_SUCCESS
		ld	f,FLAGS_EQ

		pop	bc-hl

		MDebugPrint <"FileRead success ">
		MDebugStacks

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
		MDebugPrint <"DirectoryOpen\n">
		MDebugStacks
		pusha

		;MDebugRegisters

		; clear directory structure
		push	ft-bc
		ld	bc,ft
		ld	de,dir_SIZEOF
		ld	t,0
		jal	SetMemory
		pop	ft-bc

		MStackAlloc STRING_SIZE
		exg	ft,bc
		jal	getVolumeAndComponentsFromPath
		j/eq	.found_volume

		MDebugPrint <"File system not found\n">

		pop	ft
		add	ft,dir_Error

		ld	b,ERROR_NOT_AVAILABLE
		ld	(ft),b

		ld	f,FLAGS_NE
		j	.exit
		
.found_volume
		pop	ft
		ld	de,ft	; de = volume
		pop	ft	; ft = directory struct
		push	ft
		
		;MDebugMemory ft,16

		; set volume pointer in directory struct
		ld	(ft),e
		add	ft,1
		ld	(ft),d

		; get open function
		ld	ft,de
		add	ft,fs_OpenDir
		ld	l,(ft)
		add	ft,1
		ld	h,(ft)

		pop	ft

		;MDebugRegisters
		MDebugStacks
		jal	(hl)
		MDebugStacks

.exit		MStackFree STRING_SIZE
		pop	bc-hl
		MDebugStacks
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

		; get volume
		ld	c,(ft)
		add	ft,1
		ld	b,(ft)

		; get read function
		ld	ft,bc
		add	ft,fs_ReadDir
		ld	l,(ft)
		add	ft,1
		ld	h,(ft)

		pop	ft
		MDebugRegisters

		jal	(hl)

		pop	bc-hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Remove component from path. Path may end with a slash. The last
; -- component is removed up until the next to last slash, which is included
; --
; -- Inputs:
; --   ft - path, may end with slash
; --
		SECTION	"PathRemoveComponent",CODE
PathRemoveComponent:
		pusha

		ld	de,ft

		ld	t,(de)
		cmp	t,0
		j/eq	.done

		ld	f,0
		add	ft,de

		ld	e,(ft)
		cmp	e,'/'
		j/ne	.remove

		; remove slash
		ld	t,(de)
		sub	t,1
		ld	(de),t

.remove		ld	ft,de
		ld	b,'/'
		jal	StringReverseChar
		j/ne	.not_found

		; remove last component by adjusting length
		pop	ft
		sub	ft,de
		ld	(de),t
		j	.done

.not_found	; no slash found, add one
		ld	f,0
		ld	t,(de)
		add	t,1
		ld	(de),t
		add	ft,de
		ld	b,'/'
		ld	(ft),b

.done		popa
		j	(hl)


; ---------------------------------------------------------------------------
; -- Append component to path. A slash will be inserted between path and 
; -- component if path does not end with a slash
; --
; -- Inputs:
; --   ft - path, may end with slash
; --   bc - component, must not start with slash
; --
		SECTION	"PathAppend",CODE
PathAppend:
		pusha

		ld	e,(ft)
		ld	d,0
		add	ft,de

		ld	e,(ft)
		cmp	e,'/'
		j/eq	.append

		; add slash

		pop	ft
		push	ft-bc
		ld	bc,ft
		ld	t,'/'
		jal	StringAppendChar
		pop	bc

.append		jal	StringAppendString

		popa
		j	(hl)


; --
; -- Private functions
; --

; ---------------------------------------------------------------------------
; -- Determine path components from path, without volume
; --
; -- Inputs:
; --   ft - source pointer to path
; --   bc - dest pointer to path components
; --
; -- Outputs:
; --    f - "eq" if found
; --  ft' - pointer to character or non existant if f "ne"
; --
		SECTION	"getVolumeAndComponentsFromPath",CODE
getVolumeAndComponentsFromPath:
		push	bc-hl
		ld	de,ft

		jal	getVolumeFromPath
		j/ne	.exit

		MStackAlloc STRING_SIZE
		ld	bc,ft
		ld	ft,de
		jal	getComponentsFromPath




		MStackFree STRING_SIZE
		ld	f,FLAGS_EQ

.exit		pop	bc-hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Normalize path, removing parent directory indicators as necessary
; --
; -- Inputs:
; --   ft - source pointer to path components, must start with slash
; --   bc - dest pointer to path components
; --
		SECTION	"normalizePathComponents",CODE
normalizePathComponents:
		pusha

		

		popa
		j	(hl)


; ---------------------------------------------------------------------------
; -- Determine path components from path, without volume
; --
; -- Inputs:
; --   ft - source pointer to path
; --   bc - dest pointer to path components
; --
		SECTION	"getComponentsFromPath",CODE
getComponentsFromPath:
		MDebugPrint <"getComponentsFromPath entry\n">
		MDebugStacks

		pusha

		;MDebugPrint <"getComponentsFromPath entry\n">
		;MDebugRegisters

		push	ft
		ld	t,0
		ld	(bc),t
		pop	ft

		ld	de,ft	; de = source pointer
		ld	t,(de)
		add	de,1
		ld	l,t	; l = source len
		MDebugRegisters
		
		cmp	l,0
		j/eq	.empty

		ld	t,(de)
		cmp	t,'/'
		j/ne	.not_absolute

		; path of the form '/...'
		MDebugPrint <"path of the form '/...'\n">

		ld	ft,de
		push	ft
		j	.copy_absolute

.empty		ld	t,'/'
		jal	StringAppendChar
		popa
		j	(hl)

.not_absolute
		ld	t,(de)
		cmp	t,':'
		j/eq	.volume

		; path of the form '...'
		MDebugPrint <"path of the form '...'\n">

		push	de
		ld	de,currentPath
		jal	StringCopy

		ld	t,'/'
		jal	StringAppendChar

		pop	de
		ld	ft,de
		j	.copy_absolute
		
.volume
		; path of the form ':volume...'
		MDebugPrint <"path of the form ':volume...'\n">
		;MDebugRegisters

		push	bc/hl
		ld	t,l
		ld	c,t
		ld	b,'/'
		ld	ft,de
		jal	MemoryCharN
		pop	bc/hl

		j/eq	.copy_absolute

		; path of the form ':volume'
		MDebugPrint <"path of the form ':volume'\n">

		ld	t,'/'
		jal	StringAppendChar
		j	.done

.copy_absolute
		; path of the form ':volume/...'
		MDebugPrint <"path of the form '[:volume]/...'\n">
		;MDebugRegisters

		; ft' = location of first /
		pop	ft
		push	ft

		;MDebugPrint <"path of the form ':volume/...'\n">
		;MDebugRegisters

		sub	ft,de	; ft = length of volume name

		; adjust length
		sub	t,l
		neg	t
		ld	d,t

		pop	ft

		; ft = src
		; bc = dest
		; d = length
		;MDebugMemory ft,32

		exg	bc,ft

		;MDebugRegisters

		jal	StringAppendChars

.done		popa
		;MDebugStacks
		;MDebugMemory bc,32
		MDebugPrint <" - exit\n">
		j	(hl)

; ---------------------------------------------------------------------------
; -- Determine to which volume a path belongs
; --
; -- Inputs:
; --   ft - source pointer to path
; --
; -- Outputs:
; --    f - "eq" if found
; --  ft' - pointer to character or non existant if f "ne"
; --
		SECTION	"getVolumeFromPath",CODE
getVolumeFromPath:
		push	bc-hl

		;MDebugPrint <"getVolumeFromPath entry\n">
		;MDebugPrint <" - source: ">
		;MDebugHexWord ft
		;MDebugNewLine

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

		; MDebugPrint <"getVolumeFromPath determine volume name length\n">

		; find position of / character

		push	bc
		ld	t,e
		exg	ft,bc
		ld	b,'/'
		jal	MemoryCharN
		pop	bc
		j/eq	.found_slash
		ld	t,e
		j	.found_length
.found_slash	pop	ft
		sub	ft,bc
		;MDebugPrint <" - found slash\n">
.found_length
		; bc = start of volume name
		; t = length

		ld	d,t
		ld	ft,totalvolumes
		ld	e,(ft)	; e = total volumes
		ld	hl,volumes

		;MDebugPrint <"getVolumeFromPath find volume\n">

.check_volume_loop
		ld	t,(hl)
		exg	f,t
		add	hl,1
		ld	t,(hl)
		exg	f,t
		add	hl,1

		push	ft/hl
		jal	checkvolumeMatch
		pop	hl
		j/eq	.match
		pop	ft

		dj	e,.check_volume_loop

		; not found
		;MDebugPrint <"getVolumeFromPath exit: no match\n">

		pop	bc-hl
		ld	ft,FLAGS_NE
		j	(hl)

.match		; ft' - file system
		pop	bc-hl
		ld	f,FLAGS_EQ

		;MDebugPrint <"getVolumeFromPath exit: found match\n">
		j	(hl)

.current_fs	ld	bc,currentFs+1
		ld	t,(bc)
		exg	f,t
		sub	bc,1
		ld	t,(bc)

		push	ft
		ld	f,FLAGS_EQ

		;MDebugPrint <"getVolumeFromPath exit: use current fs\n">

		pop	bc-hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Check volume name match
; --
; -- Inputs:
; --   ft - volume
; --   bc - name
; --    d - name length
; --
; -- Outputs:
; --    f = "eq" if match
; --
		SECTION	"checkvolumeMatch",CODE
checkvolumeMatch:
		;MDebugPrint <"checkvolumeMatch entry\n">
		;MDebugStacks
		;MDebugMemory bc,16
		;MDebugRegisters
		push	bc-hl

		ld	hl,ft
		ld	e,2

.check_string
		ld	t,(hl)
		cmp	t,d
		j/ne	.skip

		push	hl
		add	hl,1
		ld	ft,hl
		;MDebugMemory hl,16
		jal	MemoryCompareN
		pop	hl
		j/eq	.found

.skip		add	hl,fs_Volume
		dj	e,.check_string

		ld	t,FLAGS_NE
.found		pop	bc-hl
		j	(hl)


		SECTION	"volumeVars",BSS
fat32volumes:	DS	fat32_SIZEOF*MAX_FAT_VOLUMES
volumes:	DS	MAX_VOLUMES*2
totalvolumes:	DS	1
readBuffer:	DS	2
currentFs:	DS	2
currentPath:	DS_STR
filePath:	DS_STR

