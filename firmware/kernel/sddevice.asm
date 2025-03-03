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

		MDebugPrint <"SdDeviceMake card $">
		MDebugHexByte t
		MDebugNewLine

		ld	d,t
		ld	t,IO_SEL_CARD0
		ls	ft,d
		ld	de,SdSelect
		ld	(de),t

		add	bc,sddev_Select
		ld	(bc),t

		;MDebugPrint <"sddev_Select address ">		
		;MDebugHexWord bc
		;MDebugNewLine

		jal	SdInit
		j/ne	.exit

		MDebugPrint <"Card present\n">

		add	de,SdType-SdSelect
		ld	t,(de)
		add	bc,sddev_Type-sddev_Select
		ld	(bc),t

		; copy function pointers to structure

		ld	de,.template
		add	bc,bdev_Read-sddev_Type
		ld	f,.templateEnd-.template
.template_loop	lco	t,(de)
		add	de,1
		ld	(bc+),t
		dj	f,.template_loop

		ld	f,FLAGS_EQ

.exit
		MDebugPrint <"SdInit done\n">

		pop	bc-hl
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
; --   ft:ft' - block number (consumed)
; --   bc - pointer to block device structure
; --   de - pointer to destination
; --
; -- Returns:
; --    f - "eq" condition if success
; --
readBlock:
		push	hl

		MDebugPrint <"SD readBlock ">
		MDebugHexLong ft
		MDebugPrint <" ">
		MDebugHexWord bc
		MDebugPrint <" ">
		MDebugHexWord de
		MDebugNewLine

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



; ---------------------------------------------------------------------------
; -- Read block from device
; --
; -- Inputs:
; --   bc - pointer to block device structure
; --
; -- Returns:
; --    f - "eq" condition if success
; --
setSdVariables:
		pusha

		ld	ft,bc

 		add	ft,sddev_Select
		MDebugPrint <"sddev_Select address ">		
		MDebugHexWord ft
		MDebugNewLine
		ld	b,(ft)
		add	ft,sddev_Type-sddev_Select
		ld	c,(ft)

		ld	ft,SdSelect
		ld	(ft),b
		ld	ft,SdType
		ld	(ft),c

		popa
		j	(hl)
