		INCLUDE	"blockdevice.i"

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
		SECTION	"BlockDeviceRead",CODE
BlockDeviceRead:
		push	hl

		push	ft	
		add	ft,bdev_Read
		ld	l,(ft)
		add	ft,1
		ld	h,(ft)
		pop	ft
		jal	(hl)

		pop	hl
		jal	(hl)
