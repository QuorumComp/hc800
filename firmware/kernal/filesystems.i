	IFND	FILESYSTEMS_I_INCLUDED_

FILESYSTEMS_I_INCLUDED_ = 1

		INCLUDE	"stdlib/syscall.i"


		GLOBAL	FileInitialize
		GLOBAL	FileOpen
		GLOBAL	FileRead
		GLOBAL	FileReadByte
		GLOBAL	FileSkip
		GLOBAL	FileClose
		GLOBAL	DirectoryOpen
		GLOBAL	DirectoryRead

		RSRESET
fs_Label	RB	MAX_LABEL_LENGTH
fs_Volume	RB	MAX_VOLUME_NAME_LENGTH
fs_BlockDevice	RB	1	; $FF if not blockdevice

; ---------------------------------------------------------------------------
; -- Open file. file_Flags, file_Error and file_Length are filled in.
; --
; -- Inputs:
; --   ft - pointer to filesystem struct
; --   bc - pointer to file struct
; --   de - pointer to filename (Pascal string)
; --
; -- Output:
; --    t - Error code
; --    f - "eq" if success
; --
fs_Open		RW	1

; ---------------------------------------------------------------------------
; -- Close file
; --
; -- Inputs:
; --   bc - pointer to file struct
; --
; -- Output:
; --    t - Error code
; --    f - "eq" if success
; --
fs_Close	RW	1

; ---------------------------------------------------------------------------
; -- Read from file offset
; --
; -- Inputs:
; --   ft - bytes to read
; --   bc - pointer to file struct
; --   de - destination pointer (data segment)
; --
; -- Output:
; --   ft - bytes actually read
; --
fs_Read		RW	1

; ---------------------------------------------------------------------------
; -- Open directory
; --
; -- Inputs:
; --   bc - pointer to directory struct
; --
; -- Output:
; --    f - "eq" if directory could be opened. Directory struct is filled in
; --        with information on first file
; --
fs_OpenDir	RW	1

; ---------------------------------------------------------------------------
; -- Read next file information from directory
; --
; -- Inputs:
; --   bc - pointer to directory struct
; --
; -- Output:
; --    f - "eq" if next file information could be retrieved. Directory
; --        struct is filled in with information on file.
; --        "ne" when no more files present.
; --
fs_ReadDir	RW	1

fs_PRIVATE	RB	0


	IF	fs_Open~=volinf_Free
		FAIL	"First three members of filesystem and volume info structures must have the same size"
	ENDC

	ENDC