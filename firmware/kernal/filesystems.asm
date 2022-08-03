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
		push	ft
		add	de,fs_DeviceId
		ld	(de),t

		ld	ft,bc
		add	de,fs_BlockDevice-fs_DeviceId
		ld	(de),t
		add	de,1
		ld	t,f
		ld	(de),t

		popa
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
		MDebugStacks

		; clear file handle structure
		ld	de,file_SIZEOF
		ld	t,0
		jal	SetMemory

		MStackAlloc STRING_SIZE
		ld	bc,ft
		pop	ft
		jal	getVolumeAndComponentsFromPath
		j/eq	.found_volume

		pop	bc-hl
		j	.free

.found_volume
		MDebugStacks
		; get volume
		pop	ft
		ld	de,ft

		MDebugHexWord de
		MDebugNewLine

		; set volume pointer in file struct
		swap	bc

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

		swap	bc
		ld	ft,bc
		pop	bc

		MDebugRegisters

		jal	(hl)

		pop	de/hl
.free		MStackFree STRING_SIZE
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
		;MDebugStacks
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

		MDebugPrint <"Volume not found\n">

		pop	ft
		add	ft,dir_Error

		ld	b,ERROR_NOT_AVAILABLE
		ld	(ft),b

		ld	f,FLAGS_NE
		j	.exit
		
.found_volume
		MDebugPrint <"Found volume\n">
		;MDebugMemory bc,32

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
		MDebugMemory bc,16

		;MDebugRegisters
		;MDebugStacks
		jal	(hl)
		;MDebugStacks

.exit		MStackFree STRING_SIZE
		pop	bc-hl
		MDebugPrint <"DirectoryOpen exit\n">
		MDebugStacks
		MDebugRegisters
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
		MDebugMemory ft,16

		; bc <- volume (file system structure )
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
; -- Close directory scan object
; --
; -- Inputs:
; --   ft - pointer to directory struct
; --
		SECTION	"DirectoryClose",CODE
DirectoryClose:
		pusha

		MDebugPrint <"DirectoryClose\n">
		MDebugMemory ft,16

		; bc <- volume (file system structure )
		ld	c,(ft)
		add	ft,1
		ld	b,(ft)

		; get read function
		ld	ft,bc
		add	ft,fs_CloseDir
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
		;MDebugPrint <"PathRemoveComponent entry\n">
		pusha

		ld	de,ft

		;MDebugMemory de,16

		ld	t,(de)
		cmp	t,0
		j/eq	.done

		ld	f,0
		add	ft,de

		;MDebugRegisters

		ld	b,(ft)
		cmp	b,'/'
		j/ne	.no_remove

		; remove slash
		ld	t,(de)
		sub	t,1
		ld	(de),t

.no_remove	;MDebugPrint <"Find slash\n">
		ld	ft,de
		ld	b,'/'
		;MDebugRegisters
		jal	StringReverseChar
		;MDebugRegisters
		j/ne	.not_found

		; remove last component by adjusting length
		;MDebugPrint <"Remove last component\n">

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
		;MDebugPrint <"PathRemoveComponent exit\n">
		j	(hl)


; ---------------------------------------------------------------------------
; -- Append component to path. A slash will be inserted between path and 
; -- component if path does not end with a slash
; --
; -- Inputs:
; --   ft - destination path string, may end with slash
; --   bc - component chars, must not start with slash
; --    d - number of chars to append
; --
		SECTION	"PathAppendChars",CODE
PathAppendChars:
		pusha

		ld	e,(ft)
		ld	d,0
		add	ft,de

		ld	e,(ft)
		cmp	e,'/'
		j/eq	.append

		; add slash

		pop	ft
		push	ft
		ld	bc,ft
		ld	t,'/'
		jal	StringAppendChar

.append		pop	ft-de
		jal	StringAppendChars

		pop	hl
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

		ld	t,(bc)
		add	bc,1
		ld	d,t

		pop	ft
		jal	PathAppendChars

		pop	bc-hl
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
		MDebugPrint <"getVolumeAndComponentsFromPath entry\n">
		;MDebugStacks

		push	bc-hl
		ld	de,ft

		jal	getVolumeFromPath
		j/ne	.exit

		;MDebugStacks

		MStackAlloc STRING_SIZE
		ld	bc,ft
		ld	ft,de
		jal	getComponentsFromPath
		MDebugPrint <"Components: ">
		MDebugMemory bc,$40
		;swap	ft
		;MDebugRegisters
		;swap	ft
		;MDebugStacks

		ld	ft,bc
		swap	bc
		jal	normalizePathComponents
		MDebugMemory bc,16
		;swap	ft
		;MDebugRegisters
		;swap	ft
		;MDebugStacks

		swap	bc

		MStackFree STRING_SIZE
		ld	f,FLAGS_EQ

.exit		pop	bc-hl
		MDebugPrint <"getVolumeAndComponentsFromPath exit\n">
		;MDebugStacks
		j	(hl)


; ---------------------------------------------------------------------------
; -- Normalize path, removing parent directory indicators as necessary
; --
; -- Inputs:
; --   ft - source pointer to path components string, must start with slash
; --   bc - dest pointer to path components string
; --
		SECTION	"normalizePathComponents",CODE
normalizePathComponents:
		;MDebugPrint <"normalizePathComponents entry\n">
		;MDebugRegisters

		pusha

		push	ft
		ld	t,0
		ld	(bc),t
		pop	ft

		ld	e,(ft)	; e = length of source
		add	ft,1	; ft = first slash of path component

.next		add	ft,1	; skip slash
		sub	e,1

		jal	findComponentRange

		;   ft  - start
		;   ft' - one past last char of component (slash, new start)
		ld	bc,ft
		pop	ft
		ld	hl,ft
		sub	ft,bc	; t = length of component

		push	ft

		; adjust remaining length
		exg	t,e
		sub	t,e
		ld	e,t

		pop	ft

		cmp	t,0
		j/eq	.slash_only

		; check for parent (..)
		; must be exactly 2 characters long, filenames may start with ..

		cmp	t,2
		j/ne	.not_parent

		; it's 2 chars, maybe parent (..)

		ld	t,(bc)
		cmp	t,'.'
		j/ne	.not_parent

		add	bc,1
		ld	t,(bc)
		sub	bc,1
		cmp	t,'.'
		j/ne	.not_parent

		; is parent

		push	hl

		swap	bc
		ld	ft,bc
		swap	bc
		jal	PathRemoveComponent

		pop	hl
		j	.slash_only

.not_parent
		; t = length of component
		; bc = component chars, must not start with slash
		; bc' = dest pointer
		; hl = end of of component

		ld	d,t
		swap	bc
		ld	ft,bc
		swap	bc

		; ft = destination path string, may end with slash
		; bc = component chars, must not start with slash
		; bc' = dest pointer
		;  d = number of chars to append

		push	hl
		jal	PathAppendChars
		pop	hl

.slash_only	cmp	e,0
		j/eq	.done

		ld	ft,hl
		pop	bc
		push	bc

		j	.next

.done		popa
		;MDebugPrint <"normalizePathComponents exit\n">
		;MDebugRegisters
		j	(hl)

; input:
;   ft - source
;    e - length
; output:
;   ft  - start
;   ft' - end
findComponentRange:
		push	bc-hl

		exg	de,ft
		ld	c,t
		ld	ft,de

		ld	b,'/'
		jal	MemoryCharN
		j/eq	.found_slash

		; no slash, must be last component
		; set up registers for append
		ld	ft,de
		push	ft
		ld	b,0
		add	ft,bc
		swap	ft

		pop	bc-hl
		j	(hl)

.found_slash	ld	ft,de
		pop	bc-hl
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
		;MDebugPrint <"getComponentsFromPath entry\n">
		;MDebugStacks

		pusha

		push	ft
		ld	t,0
		ld	(bc),t
		pop	ft

		ld	de,ft	; de = source pointer
		ld	t,(de)
		add	de,1
		ld	h,0
		ld	l,t	; hl = source len
		
		tst	hl
		j/eq	.empty

		ld	t,(de)
		cmp	t,'/'
		j/ne	.not_absolute

		MDebugPrint <"path of the form '/...'\n">

		j	.copy_range

.empty		ld	t,'/'
		jal	StringAppendChar
		popa
		j	(hl)

.not_absolute
		ld	t,(de)
		cmp	t,':'
		j/eq	.volume

		MDebugPrint <"path of the form '...'\n">

		push	de/hl
		ld	de,currentPath
		;MDebugMemory bc,16
		;MDebugMemory de,16
		jal	StringCopy
		pop	de/hl
		;MDebugMemory bc,16

		j	.copy_range
		
.volume
		MDebugPrint <"path of the form ':volume...'\n">

		push	bc/hl
		ld	t,l
		ld	c,t
		ld	b,'/'
		ld	ft,de
		jal	MemoryCharN
		pop	bc/hl
		j/ne	.only_volume

		pop	ft	; remove flags
		exg	de,ft
		sub	ft,de
		add	ft,hl
		ld	hl,ft
		j	.copy_range

.only_volume
		MDebugPrint <"path of the form ':volume'\n">
		ld	t,'/'
		jal	StringAppendChar
		popa
		j	(hl)

.copy_range
		;MDebugPrint <"path of the form '[:volume]/...'\n">

		; hl = length
		; de = start range

		ld	ft,hl
		exg	f,t
		exg	ft,de

		; ft = src
		; bc = dest
		; d = length

		;MDebugRegisters

		exg	bc,ft

		jal	StringAppendChars

.done		popa
		MDebugPrint <"getComponentsFromPath exit\n">
		MDebugMemory ft,16
		MDebugMemory bc,16
		;MDebugStacks
		j	(hl)

; ---------------------------------------------------------------------------
; -- Determine to which volume a path belongs
; --
; -- Inputs:
; --   ft - source pointer to path
; --
; -- Outputs:
; --    t - error code
; --    f - "eq" if found
; --  when f is "ne":
; --   ft' - pointer to character or non existant if f "ne"
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
		ld	f,FLAGS_NE
		ld	t,ERROR_NOT_AVAILABLE
		j	(hl)

.current_fs	ld	bc,currentFs+1
		ld	t,(bc)
		exg	f,t
		sub	bc,1
		ld	t,(bc)

		MDebugPrint <"getVolumeFromPath exit: use current fs ">
		MDebugRegisters
		push	ft

.match		ld	f,FLAGS_EQ
		ld	t,ERROR_SUCCESS

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

