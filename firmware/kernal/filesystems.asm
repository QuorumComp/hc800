		INCLUDE	"lowlevel/math.i"
		INCLUDE	"lowlevel/memory.i"

		INCLUDE	"stdlib/string.i"

		INCLUDE	"filesystems.i"
		INCLUDE	"uart_commands.i"
		INCLUDE	"uartfs.i"

TOTAL_FILESYSTEMS = 1


; ---------------------------------------------------------------------------
; -- Initialize file subsystem
; --
		SECTION "FileInitialize",CODE
FileInitialize:
		pusha

		ld	bc,filesystems+1
		lco	t,(bc)
		exg	f,t
		sub	bc,1
		lco	t,(bc)
		ld	bc,ft

		; bc - first filesystem

		ld	ft,rootFs
		ld	(ft),c
		add	ft,1
		ld	(ft),b

		; initialize root

		ld	ft,rootPath
		ld	b,0
		ld	(ft),b

		popa
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
		SECTION	"FileOpen",CODE
FileOpen:
		push	bc-hl

		push	de
		ld	de,file_SIZEOF
		ld	t,0
		jal	SetMemory
		pop	de

		MDebugPrint <"FileOpen.1\n">

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
		push	bc
		ld	ft,hl
		ld	bc,ft
		add	bc,fs_Open+1
		lco	t,(bc)
		exg	f,t
		sub	bc,1
		lco	t,(bc)
		ld	hl,ft
		pop	bc

		MDebugPrint <"FileOpen.2\n">
		jal	(hl)

		MDebugPrint <"FileOpen.3\n">

		ld	de,file_SIZEOF
		jal	ComDumpMemory

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
		ld	l,(ft)
		add	ft,1
		ld	h,(ft)

		; get close function
		add	ft,fs_Close
		ld	l,(ft)
		add	ft,1
		ld	h,(ft)

		jal	(hl)
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

		MDebugPrint <"FileRead.1\n">

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

		MDebugPrint <"FileRead.2\n">

		ld	bc,ft
		jal	MathLoadOperand16U

		MDebugPrint <"FileRead.3\n">

		add	bc,file_Offset
		jal	MathAdd_32_Operand

		MDebugPrint <"FileRead.4\n">

		sub	bc,file_Offset
		ld	de,file_SIZEOF
		jal	ComDumpMemory

		pop	bc-hl
		j	(hl)


		SECTION	"Filesystems",DATA
filesystems::	DW	UartFilesystem

		SECTION	"FilesystemVars",BSS
rootFs:		DS	2
rootPath:	DS_STR
filePath:	DS_STR

