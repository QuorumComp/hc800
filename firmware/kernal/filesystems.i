	IFND	FILESYSTEMS_I_INCLUDED_

FILESYSTEMS_I_INCLUDED_ = 1


		GLOBAL	FileInitialize
		GLOBAL	FileOpen
		GLOBAL	FileRead
		GLOBAL	FileReadByte
		GLOBAL	FileSkip
		GLOBAL	FileClose

		RSRESET
file_System	RW	1
file_Length	RB	4
file_Offset	RB	4
file_Error	RB	1
file_Flags	RB	1
file_Private	RB	4
file_SIZEOF	RB	0

FFLAG_DIR	EQU	$01


		RSRESET
fs_Name		RW	1

; ---------------------------------------------------------------------------
; -- Open file. file_Flags, file_Error and file_Length are filled in.
; --
; -- Inputs:
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

fs_SIZEOF	RB	0

	ENDC