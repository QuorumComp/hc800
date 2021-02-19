		INCLUDE	"lowlevel/hc800.i"
		INCLUDE	"lowlevel/rc800.i"

		INCLUDE	"blockdevice.i"
		INCLUDE	"sd.i"
		INCLUDE	"sddevice.i"

		RSSET	bdev_PRIVATE
bdev_Select	RB	1
bdev_Type	RB	1


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

		ld	d,t
		ld	t,IO_STAT_SELECT0
		ls	ft,d
		ld	de,SdSelect
		ld	(de),t

		add	bc,bdev_Select
		ld	(bc),t

		jal	SdInit
		j/ne	.exit

		ld	ft,SdType
		ld	d,(ft)

		ld	ft,bc

		ld	bc,readBlock
		add	ft,bdev_Read-bdev_Select
		ld	(ft),c
		add	ft,1
		ld	(ft),b

		ld	bc,writeBlock
		add	ft,bdev_Write-(bdev_Read+1)
		ld	(ft),c
		add	ft,1
		ld	(ft),b

		ld	bc,getSize
		add	ft,bdev_Size-(bdev_Write+1)
		ld	(ft),c
		add	ft,1
		ld	(ft),b

		add	ft,bdev_Type-(bdev_Size+1)
		ld	(ft),d

		ld	f,FLAGS_EQ

.exit		pop	bc-hl
		j	(hl)


writeBlock:
		push	hl

		jal	setSdVariables
		jal	SdWriteSingleBlock
		
		pop	hl
		j	(hl)

readBlock:
		push	hl

		jal	setSdVariables
		jal	SdReadSingleBlock
		
		pop	hl
		j	(hl)


getSize:
		pusha

		ld	t,$FF
		ld	f,4
.loop		ld	(bc),t
		add	bc,1
		dj	f,.loop

		popa
		j	(hl)



setSdVariables:
		pusha

		add	ft,bdev_Select
		ld	b,(ft)
		add	ft,bdev_Type-bdev_Select
		ld	c,(ft)

		ld	ft,SdSelect
		ld	(ft),b
		ld	ft,SdType
		ld	(ft),c

		popa
		j	(hl)
