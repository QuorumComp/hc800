		INCLUDE	"lowlevel/hc800.i"
		INCLUDE	"lowlevel/rc800.i"

		INCLUDE	"blockdevice.i"
		INCLUDE	"sd.i"
		INCLUDE	"sddevice.i"
		INCLUDE	"uart_commands.i"

		INCLUDE	"uart_commands_disabled.i"


; ---------------------------------------------------------------------------
; -- Make SD block device structure
; --
; -- Inputs:
; --    t - device index, 0 or 1
; --   bc - pointer to block device structure to fill in
; --
; -- Returns:
; --    f - "eq" condition if success
; --
		SECTION	"SdDeviceMake",CODE
SdDeviceMake:
		push	bc-hl

		MDebugPrint <"SdDeviceMake ">
		MDebugHexWord ft
		MDebugPrint <" ">
		MDebugHexWord bc
		MDebugNewline

		ld	d,t
		ld	t,IO_STAT_SELECT0
		ls	ft,d
		ld	de,SdSelect
		ld	(de),t

		add	bc,sddev_Select
		ld	(bc),t

		jal	SdInit
		j/ne	.exit

		add	de,SdType-SdSelect
		ld	t,(de)
		add	bc,sddev_Type-sddev_Select
		ld	(bc),t

		; copy function pointers to structure

		ld	de,.template
		add	bc,bdev_Read-sddev_Type
		ld	f,.templateEnd-.template
.template_loop	lco	t,(de)
		ld	(bc),t
		add	de,1
		add	bc,1
		dj	f,.template_loop

		ld	f,FLAGS_EQ

.exit		pop	bc-hl
		j	(hl)


.template	DW	readBlock
		DW	writeBlock
		DW	getSize
.templateEnd


writeBlock:
		push	hl

		jal	setSdVariables
		jal	SdWriteSingleBlock
		
		pop	hl
		j	(hl)

; ---------------------------------------------------------------------------
; -- Read block from device
; --
; -- Inputs:
; --   ft - pointer to block device structure
; --   bc - pointer to block number
; --   de - pointer to destination
; --
; -- Returns:
; --    f - "eq" condition if success
; --
readBlock:
		push	hl

		jal	setSdVariables
		jal	SdReadSingleBlock
		
		pop	hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Get device size
; --
; -- Inputs:
; --   ft - pointer to block device structure
; --   bc - pointer to size in blocks
; --
; -- Returns:
; --    f - "eq" condition if success
; --
getSize:
		push	bc

		ld	t,$FF
		ld	f,4
.loop		ld	(bc),t
		add	bc,1
		dj	f,.loop

		ld	f,FLAGS_NE

		pop	bc
		j	(hl)



setSdVariables:
		pusha

		add	ft,sddev_Select
		ld	b,(ft)
		add	ft,sddev_Type-sddev_Select
		ld	c,(ft)

		ld	ft,SdSelect
		ld	(ft),b
		ld	ft,SdType
		ld	(ft),c

		popa
		j	(hl)
