		INCLUDE	"lowlevel/hc800.i"

		INCLUDE	"mmu.i"


; ---------------------------------------------------------------------------
; -- Set default kernel MMU configurations
; --
		SECTION "MmuInitialize",CODE
MmuInitialize:
		pusha

		ld	de,.mmuDataLoad
		ld	f,.mmuDataLoadEnd-.mmuDataLoad
		ld	t,MMU_CFG_LOAD
		jal	internalMmuSetConfigCode

		ld	de,.mmuDataKernel
		ld	f,.mmuDataKernelEnd-.mmuDataKernel

		ld	t,MMU_CFG_CLIENT
		jal	internalMmuSetConfigCode
		ld	t,MMU_CFG_SPARE
		jal	internalMmuSetConfigCode
		ld	t,MMU_CFG_KERNAL
		jal	internalMmuSetConfigCode

		ld	t,MMU_CFG_KERNAL
		jal	MmuActivateConfig

		ld	b,IO_MMU_BASE
		ld	c,IO_MMU_CHARGEN
		ld	t,$08
		lio	(bc),t	; chargen

		popa
		j	(hl)

.mmuDataKernel:	DB	MMU_CFG_HARVARD		; config bits
		DB	$01,$81,$82,$83		; code banks
		DB	$80,$81,BANK_PALETTE,BANK_ATTRIBUTE	; data banks
		DB	$01,$80			; system code/data
.mmuDataKernelEnd:

.mmuDataLoad:	DB	MMU_CFG_HARVARD|MMU_CFG_DATA_48K ; config bits
		DB	$01,$81,$82,$83		; code banks
		DB	$80,$00,$00,$00		; data banks
		DB	$01,$80			; system code/data
.mmuDataLoadEnd:


; ---------------------------------------------------------------------------
; -- Activate MMU configuration
; --
		SECTION "MmuActivateConfig",CODE
MmuActivateConfig:
		pusha

		ld	b,IO_MMU_BASE
		ld	c,IO_MMU_ACTIVE_INDEX
		lio	(bc),t

		popa
		j	(hl)


; ---------------------------------------------------------------------------
; -- Load MMU configuration
; --
; -- Inputs:
; --    t - MMU configuration index
; --   de - configuration, 9 bytes of data (config, 4x code, 4x data)
; --
		SECTION "MmuSetConfigCode",CODE
MmuSetConfigCode:
		pusha

		ld	f,MMU_CONFIG_SIZE
		j	internalMmuSetConfigCode\.enter

; ---------------------------------------------------------------------------
; -- Load MMU configuration
; --
; -- Inputs:
; --    f - length of config data
; --    t - MMU configuration index
; --   de - configuration
; --
internalMmuSetConfigCode:
		pusha
.enter
		ld	b,IO_MMU_BASE
		ld	c,IO_MMU_UPDATE_INDEX
		lio	(bc),t

		ld	c,IO_MMU_CONFIGURATION
.loop		lco	t,(de)
		add	de,1
		lio	(bc),t
		add	c,1
		dj	f,.loop

		popa
		j	(hl)


; ---------------------------------------------------------------------------
; -- Load MMU configuration
; --
; -- Inputs:
; --    t - MMU configuration index
; --   de - configuration, 9 bytes of data (config, 4x code, 4x data)
; --
		SECTION "MmuSetConfigData",CODE
MmuSetConfigData:
		pusha

		ld	f,MMU_CONFIG_SIZE
		j	internalMmuSetConfigData\.enter

; ---------------------------------------------------------------------------
; -- Load MMU configuration
; --
; -- Inputs:
; --    f - length of config data
; --    t - MMU configuration index
; --   de - configuration
; --
internalMmuSetConfigData:
		pusha
.enter
		ld	b,IO_MMU_BASE
		ld	c,IO_MMU_UPDATE_INDEX
		lio	(bc),t

		ld	c,IO_MMU_CONFIGURATION
.loop		ld	t,(de)
		add	de,1
		lio	(bc),t
		add	c,1
		dj	f,.loop

		popa
		j	(hl)


