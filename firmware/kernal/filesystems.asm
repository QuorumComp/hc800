		INCLUDE	"lowlevel/math.i"

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
		ld	t,(bc)
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

		MDebugPrintR de
		MDebugNewline

		ld	f,fs_SIZEOF
		ld	t,0
.clear		ld	(bc),t
		add	bc,1
		dj	f,.clear
		sub	bc,fs_SIZEOF

		MDebugPrint <"FileOpen.1\n">

		; get filesystem
		ld	ft,rootFs
		ld	l,(ft)
		add	ft,1
		ld	h,(ft)

		MDebugHexWord hl

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
		SECTION	"FileClose",CODE
FileRead:
		pusha

		; get filesystem
		ld	ft,bc
		ld	l,(ft)
		add	ft,1
		ld	h,(ft)

		; get read function
		add	ft,fs_Read
		ld	l,(ft)
		add	ft,1
		ld	h,(ft)

		pop	ft
		jal	(hl)

		ld	bc,ft
		jal	MathLoadOperand16U

		add	bc,file_Offset
		jal	MathAdd_32_Operand

		pop	bc-hl
		j	(hl)


		SECTION	"Filesystems",DATA
filesystems:	DW	UartFilesystem

		SECTION	"FilesystemVars",BSS
rootFs:		DS	2
rootPath:	DS_STR
filePath:	DS_STR

