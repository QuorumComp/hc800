		INCLUDE	"lowlevel/hc800.i"
		INCLUDE	"lowlevel/math.i"
		INCLUDE	"lowlevel/rc800.i"

		INCLUDE	"stdlib/stream.i"
		INCLUDE	"stdlib/syscall.i"

		INCLUDE	"sd.i"
		INCLUDE	"uart_commands.i"

; ---------------------------------------------------------------------------
; -- SD card driver (SPI mode)
; ---------------------------------------------------------------------------
;
; CLOCKS
;   IO_SD_SELECT selects one card and one SPI rate:
;     bits 1:0  card, one-hot (card 0 = 1, card 1 = 2; 0 = none)
;     bit  2    slow clock, 13.5 MHz / 64 = 211 kHz
;     bit  3    fast clock, 13.5 MHz /  4 = 3.375 MHz
;   The controller only clocks while a card is selected and a shift is in
;   progress. The RTL enforces one-hot card selection.
;
;   The SD spec requires 100-400 kHz for the power-up clocks and for CMD0,
;   CMD8, CMD55 and ACMD41. Initialisation ends when ACMD41 reports the card
;   ready; CMD58 and CMD16 may then run fast, but are kept slow here.
;
; INITIALISATION (SdInit)
;   SdInit
;     sdResetCard       select slow, ~40 ms supply settle, 80 clocks of $FF
;     sdGoIdleState     CMD0 -> R1 (retried up to 3 times)
;     sdSendIfCond      CMD8 -> R7; success means a V2 card
;     sdSendOpCond      CMD55 + ACMD41 until R1 bit0 = 0 (ready)
;       V1 -> sdInitV1
;       V2 -> sdInitV2 -> sdReadCcsBit -> sdReadOcr (CMD58) -> CCS
;     sdSetBlockLen512  CMD16, standard-capacity cards only; SDHC/SDXC use
;                       a fixed 512-byte block length
;   The resulting type is stored in SdType. sdDeselect releases the card
;   (release byte, wait, select = 0); it is called after CMD0, after CMD58,
;   after CMD16 and after each block read. CMD8 and the ACMD41 loop leave
;   the card selected until the next one.
;
; BLOCK READ (SdReadSingleBlock)
;   select fast, CMD17, block number, R1, $FE token, 512 data bytes, CRC,
;   deselect.
;
; TIMING POLICY
;   Slow paths poll the busy bit before every access (WAIT_READY), so they
;   are correct at either clock.
;   The one fixed-delay path is the 512-byte read loop. It relies on the
;   body outlasting one fast-clock byte: 32 bus clocks = four instructions
;   (the CPU takes 4 CPU clocks = 8 bus clocks per instruction), and the
;   extra nop makes five, leaving one instruction of margin.
;   Do not shorten that loop, and do not use it at the slow clock, where a
;   byte is 64 instructions long.
;
; REGISTER INTERFACE
;   IO_SD_DATA    read: returns the previously received byte and starts the
;                 next shift; write: sends a byte and starts a shift
;   IO_SD_STATUS  bit0 = shift in progress; bit1 = card detect
;   IO_SD_SELECT  see CLOCKS above
;
;   An access to IO_SD_DATA while a shift is in progress is ignored by the
;   controller (a read then returns a partially shifted byte), which is why
;   every access polls or waits long enough first.
; ---------------------------------------------------------------------------

;	PURGE	_DEBUG
;_DEBUG = 0

; -- Set to 1 to enable SD card detection, 0 to report no card present.
SD_ENABLED	EQU	1


CMD0_CRC	EQU	$95

CMD8_PATTERN:	EQU	$AA	;pattern for CMD08
CMD8_VOLTAGES:	EQU	$01	;3.3V
CMD8_CRC:	EQU	$87

BLOCKLEN:	EQU	512

HCS:		EQU	$40	;high capacity supported

REPLY_IDLE		EQU	$01
REPLY_ERASE_RESET	EQU	$02
REPLY_ILLEGAL_COMMAND	EQU	$04
REPLY_CRC_ERROR		EQU	$08
REPLY_ERASE_SEQ_ERROR	EQU	$10
REPLY_ADDRESS_ERROR	EQU	$20
REPLY_PARAMETER_ERROR	EQU	$40

REPLY_ERRORS		EQU	REPLY_ILLEGAL_COMMAND|REPLY_CRC_ERROR|REPLY_ERASE_SEQ_ERROR|REPLY_ADDRESS_ERROR|REPLY_PARAMETER_ERROR

; -- Select the current card and the fast SPI clock (3.375 MHz).
SELECT:		MACRO
		ld	bc,SdSelect
		ld	t,(bc)
		or	t,IO_SEL_FAST_CLOCK
		ld	b,IO_SDCARD_BASE
		ld	c,IO_SD_SELECT
		lio	(bc),t
		ENDM

; -- Select the current card and the slow SPI clock (211 kHz).
SELECT_SLOW:	MACRO
		ld	bc,SdSelect
		ld	t,(bc)
		or	t,IO_SEL_SLOW_CLOCK
		ld	b,IO_SDCARD_BASE
		ld	c,IO_SD_SELECT
		lio	(bc),t
		ENDM

; -- Wait for the controller to finish shifting the current byte.
; -- Requires b = IO_SDCARD_BASE. Clobbers c, t and the flags.
WAIT_READY:	MACRO
		ASSERTF	IO_STAT_ACTIVE==FLAGS_CARRY,"IO_STAT_ACTIVE and FLAGS_CARRY must be equal"
		ld	c,IO_SD_STATUS
.wait\@		lio	t,(bc)
		ld	f,t
		j/cs	.wait\@		; IO_STAT_ACTIVE set?
		ENDM

; -- Same, but preserves the FT pair (for callers holding a value in FT).
WAIT_READY_KEEP_FT:	MACRO
		push	ft
		WAIT_READY
		pop	ft
		ENDM

	IF _DEBUG
MScreenByteOut:	MACRO
		push	hl
		jal	StreamHexByteOut
		pop	hl
		ENDM
MScreenNewLine:	MACRO
		MNewLine
		ENDM
	ELSE
MScreenByteOut:	MACRO
		ENDM
MScreenNewLine:	MACRO
		ENDM
	ENDC


; ---------------------------------------------------------------------------
; -- Reset SD card controller
; --
; -- Clock: selects slow (via sdResetCard).
; --
		SECTION	"SdResetController",CODE
SdResetController:
	IF SD_ENABLED
		pusha
		jal	sdResetCard
		popa
	ENDC

		j	(hl)


; ---------------------------------------------------------------------------
; -- Get total number of blocks (CMD9)
; --
; -- Inputs:
; --   bc - pointer to 32 bit block number
; --
; -- Returns:
; --    f - "eq" condition if success
; --
; -- Clock: selects fast; the response and CSD reads poll, so they tolerate either clock.
; --
		SECTION	"SdGetTotalBlocks",CODE
SdGetTotalBlocks:
		MDebugPrint <"SdGetTotalBlocks\n">
		
	IF ~SD_ENABLED

		ld	f,FLAGS_NE
		j	(hl)

	ELSE

		push	bc/de/hl

		SELECT

		WAIT_READY
		ld	c,IO_SD_DATA
		ld	t,9|$40		;CMD9
		lio	(bc),t

		jal	sdFinalBits5	;arg, CRC

		jal	sdInFirst
		j/ne	.error

		jal	sdInPacket
		j/ne	.error

		; 16 bytes

		lio	t,(bc)
		MScreenByteOut
		and	t,$C0
		cmp	t,0
		j/eq	.v1

		cmp	t,$40
		j/ne	.error

.v2		jal	.handle_v2
		j	.done

.v1		jal	.handle_v1

.done		MScreenNewLine
		ld	f,FLAGS_EQ

.error		ld	b,IO_SDCARD_BASE
		jal	sdDeselect
		pop	bc/de/hl
		j	(hl)

.handle_v2	push	hl
		MDebugPrint <"CSD v2\n">

		; 13 bits []
		; shift 19

		jal	sdSkipBytes8

		lio	t,(bc)
		MScreenByteOut
		and	t,$1F	; 60:56
		exg	f,t
		WAIT_READY_SAVE_FT
		lio	t,(bc)	; 55:48
		MScreenByteOut

		ls	ft,3
		push	ft

		jal	sdSkipBytes4
		jal	sdInLast

		ld	ft,0
		swap	ft	; ft:ft' 13 bits << 19

		pop	bc
		jal	MathStoreLong

		pop	hl
		j	(hl)

.handle_v1	push	hl

		MDebugPrint <"CSD v1\n">
		jal	sdSkipBytes4

		; READ_BL_LEN [83:80]
		lio	t,(bc)
		and	t,$0F
		sub	t,9	; map block length to shift factor
		ld	f,0
		ld	hl,ft

		; C_SIZE [73:62]
		lio	t,(bc)
		and	t,$03
		ld	f,t
		WAIT_READY_SAVE_FT
		lio	t,(bc)
		ls	ft,2
		ld	de,ft
		WAIT_READY_SAVE_FT
		lio	t,(bc)
		ld	f,0
		ls	ft,2
		ld	t,d
		exg	f,t
		or	t,e
		ld	de,ft	; de = C_SIZE, 12 bits
		add	de,1

		; C_SIZE_MULT [49:47]

		lio	t,(bc)
		and	t,$03
		ld	f,t
		WAIT_READY_SAVE_FT
		lio	t,(bc)
		rs	ft,7	; ft = C_SIZE_MULT
		add	ft,2
		add	ft,hl	; ft = shift amount for C_SIZE
		ld	bc,ft

		push	bc
		jal	sdSkipBytes5
		jal	sdInLast
		pop	bc

		push	ft
		ld	ft,0

		; ft:ft' = C_SIZE
		; bc = shift amount for C_SIZE
		; bc' = pointer to size

		jal	MathShiftLeft_32
		pop	bc
		jal	MathStoreLong

		pop	hl
		j	(hl)

	ENDC

; ---------------------------------------------------------------------------
; -- Write block to SD card (CMD17)
; --
; -- Inputs:
; --   bc - pointer to 32 bit block number
; --   de - pointer to destination
; --
; -- Returns:
; --    f - "eq" condition if success
; --
; -- Clock: not implemented; does not touch the controller.
; --
		SECTION	"SdWriteSingleBlock",CODE
SdWriteSingleBlock:
		ld	f,FLAGS_NE
		j	(hl)



; ---------------------------------------------------------------------------
; -- Read block from SD card (CMD17)
; --
; -- Inputs:
; --   ft:ft' - block number (consumed)
; --   de - pointer to destination
; --
; -- Returns:
; --    f - "eq" condition if success
; --
; -- Clock: selects fast; the 512-byte loop relies on fast-clock timing.
; --
		SECTION	"SdReadSingleBlock",CODE
SdReadSingleBlock:
		MDebugPrint <"SdReadSingleBlock\n">

	IF SD_ENABLED==0
		ld	f,FLAGS_NE
		pop	ft
		j	(hl)
	ELSE
		pusha

		SELECT

		WAIT_READY
		ld	c,IO_SD_DATA
		ld	t,17|$40	;CMD17
		lio	(bc),t

		ld	ft,SdType
		push	de
		ld	d,(ft)
		pop	ft		; FT popped
		jal	sdSendBlockNumber
		pop	de

		jal	sdInFirst
		j/eq	.first_ok
		jal	.error

.first_ok	jal	sdInPacket
		j/eq	.packet_ok
		jal	.error

.packet_ok	MDebugPrint <"  do read\n">

		ld	c,IO_SD_DATA

		; Each data access clocks one SPI byte. An access that lands while a
		; shift is active returns a partially shifted byte and starts no new
		; shift, so the body must outlast one byte time. Fast clock: 4 bus
		; clocks/bit = 32 bus clocks/byte. CPU: 4 CPU clocks (8 bus clocks)
		; per instruction, so a byte is exactly four instructions. These five
		; instructions are 40 bus clocks: one instruction of margin.
		; Do not shorten this loop, and do not use it at the slow clock,
		; where a byte is 64 instructions long.
		
 		MLDLoop	hl,BLOCKLEN
.read_loop
		lio	t,(bc)
		ld	(de),t
		add	de,1
		nop
		dj	l,.read_loop
		dj	h,.read_loop

		MDebugPrint <"  did read\n">

		; Discard CRC
		ld	l,2
.crc_loop
		WAIT_READY
		ld	c,IO_SD_DATA
		lio	t,(bc)
		dj	l,.crc_loop

		ld	f,FLAGS_EQ

.error		jal	sdDeselect

		pop	bc/de/hl
		j	(hl)
	ENDC


; ---------------------------------------------------------------------------
; -- Initialize SD card, determine type
; --
; -- Returns:
; --    f - "eq" condition if initialized
; --
; -- Clock: each step selects its own clock; initialisation steps are slow.
; --
		SECTION	"SdInit",CODE
SdInit:		push	bc/de/hl

		IF SD_ENABLED
		ld	b,IO_SDCARD_BASE

		; Power-up clocks with both cards deselected; self-contained so
		; SdInit does not depend on a caller-side controller reset.
		jal	sdResetCard

		; CMD0 is accepted in SPI mode, but a card that was left in an
		; unknown state (warm restart) may need a second attempt after
		; the failed transaction has been deselected again.
		ld	e,3
.retry_idle	push	de
		jal	sdGoIdleState
		pop	de
		cmp	t,REPLY_IDLE
		j/eq	.idle_ok
		dj	e,.retry_idle
		j	.fail

.idle_ok	jal	sdSendIfCond
		j/eq	.v2_card

		jal	sdInitV1
		j	.handle_status

.v2_card	jal	sdInitV2

.handle_status	j/ne	.fail
		; SDHC/SDXC use a fixed 512-byte block length; CMD16 is not
		; supported there and a strict card may reject it.
		cmp	t,SDTYPE_V2_HC
		j/eq	.store
		ld	d,t
		jal	sdSetBlockLen512
		ld	t,d
		j/eq	.store
		ELSE
		; SD driver disabled: report no card present
		ld	f,FLAGS_NE
		ENDC

.fail		ld	t,SDTYPE_NONE
		MDebugPrint <"SdInit - no card\n">
.store		ld	bc,SdType
		ld	(bc),t

		cmp	t,SDTYPE_NONE
		not	f		; invert eq/ne

		pop	bc/de/hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- PRIVATE FUNCTIONS
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; -- Reset card
; --
; -- Inputs:
; --       b  - IO_SDCARD_BASE
; --
; -- Clock: selects slow; polls each byte, so correct at either clock.
; --
		SECTION	"sdResetCard",CODE
sdResetCard:	
		MDebugPrint <"sdResetCard\n">
		pusha

		; Power-up clocks must actually reach the card. The board gates
		; the SD clock off while the card is deselected, so select the
		; current card (CS low) while sending the >=74 initial clocks.
		SELECT_SLOW

		; Selecting the card also enables its supply on the MEGA65, so
		; allow for the ramp and the SD spec's 1 ms start-up before the
		; first clock. Two calls because MDelay's loop count is a byte-pair.
		MDelay	20000
		MDelay	20000

		ld	d,10	; 10 * 8 bits = 80 cycles. At least 74.

.next_byte
		ld	c,IO_SD_DATA
		ld	t,$FF
		lio	(bc),t

		WAIT_READY

		dj	d,.next_byte

		popa
		j	(hl)


; ---------------------------------------------------------------------------
; -- Deselect the card and release its DO line
; --
; -- Inputs:
; --       b  - IO_SDCARD_BASE
; --
; -- Clock: any clock; polls before and after the release byte. Leaves select = 0.
; --
		SECTION	"sdDeselect",CODE
sdDeselect:
		pusha

		; Let the previous byte shift finish, send one release byte while the
		; card is still selected, wait for it, then deassert the card select.
		ld	c,IO_SD_STATUS
.wait_prev	lio	t,(bc)
		and	t,IO_STAT_ACTIVE
		cmp	t,IO_STAT_ACTIVE
		j/eq	.wait_prev

		ld	c,IO_SD_DATA
		ld	t,$FF
		lio	(bc),t

		ld	c,IO_SD_STATUS
.wait_dummy	lio	t,(bc)
		and	t,IO_STAT_ACTIVE
		cmp	t,IO_STAT_ACTIVE
		j/eq	.wait_dummy

		; Deselect both cards (and stop the clocks). Safe here: no shift
		; is active, so clearing the clock-select bits cannot stall one.
		ld	t,0
		ld	c,IO_SD_SELECT
		lio	(bc),t

		popa
		j	(hl)


; ---------------------------------------------------------------------------
; -- Send block number
; --
; -- Inputs:
; --   ft:ft' - block number (consumed)
; --       b  - IO_SDCARD_BASE
; --       d  - SD type
; --
; -- Clock: caller's clock; both the argument bytes (sdSendInt32) and the
; -- CRC byte poll, so any clock. Currently called from SdReadSingleBlock
; -- with the fast clock selected.
; --
sdSendBlockNumber:
		MDebugPrint <"sdSendBlockNumber ">
		MDebugHexLong ft
		MDebugNewLine

		pusha

		ld	c,IO_SD_DATA
		cmp	d,SDTYPE_V2_HC
		j/eq	.hc
		pop	ft

		; standard capacity, send blockNumber*512
		ld	b,9
		jal	MathShiftLeft_32

		MDebugPrint <"sdSendBlockNumber byte ">
		MDebugHexLong ft
		MDebugNewLine

		ld	b,IO_SDCARD_BASE
		j	.continue

.hc		pop	ft
.continue
		MDebugPrint <"sdSendBlockNumber block ">
		MDebugHexLong ft
		MDebugNewLine

		jal	sdSendInt32

		WAIT_READY
		ld	c,IO_SD_DATA
		ld	t,$01	; CRC
		lio	(bc),t

		pop	bc/de/hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Set block length to 512 bytes (CMD16)
; --
; -- Inputs:
; --   	b - IO_SDCARD_BASE
; --
; -- Returns:
; --    t - card type
; --    f - "eq" condition if initialized
; -- Clock: selects slow (CMD16 may legally run fast after ACMD41, but slow is conservative).
; --
		SECTION	"sdSetBlockLen512",CODE
sdSetBlockLen512:
		MDebugPrint <"sdSetBlockLen512\n">

		push	de/hl

		SELECT_SLOW

		ld	de,.bytes
		jal	sdSendBytes6_Slow

		jal	sdInFirst

		jal	sdDeselect

		pop	de/hl
		j	(hl)

.bytes		DB	16|$40,0,0,BLOCKLEN>>8,0,1


; ---------------------------------------------------------------------------
; -- Send 32 bit integer to card
; --
; -- Inputs:
; --   ft:ft' - integer to send (consumed)
; --       b - IO_SDCARD_BASE
; --
; -- Clock: caller's clock; polls before each byte, so any clock.
; -- WAIT_READY_KEEP_FT preserves the value still held in FT.
; --
sdSendInt32:
		push	bc

		WAIT_READY_KEEP_FT
		ld	c,IO_SD_DATA
		exg	f,t
		lio	(bc),t

		WAIT_READY_KEEP_FT
		ld	c,IO_SD_DATA
		exg	f,t
		lio	(bc),t

		WAIT_READY_KEEP_FT
		ld	c,IO_SD_DATA
		pop	ft
		exg	f,t
		lio	(bc),t

		WAIT_READY_KEEP_FT
		ld	c,IO_SD_DATA
		exg	f,t
		lio	(bc),t

		pop	bc
		j	(hl)


; ---------------------------------------------------------------------------
; -- Send six bytes to SD card assuming the slow frequency
; --
; -- Inputs:
; --   de - pointer to six bytes in code segment
; -- Clock: caller's clock. Called from sdSetBlockLen512, sdSendIfCond and
; -- sdGoIdleState, all of which select slow; polls before each byte.
; --
		SECTION	"sdSendBytes",CODE
sdSendBytes6_Slow:
		MDebugPrint <"sdSendBytes6_Slow\n">
		pusha

		ld	l,6
.loop
		WAIT_READY

		ld	c,IO_SD_DATA
		lco	t,(de+)
		lio	(bc),t

		dj	l,.loop

		popa
		j	(hl)


; ---------------------------------------------------------------------------
; -- Skip bytes from SD card
; --
; -- Clock: caller's clock. Called only from SdGetTotalBlocks (fast);
; -- polls before each read.
; --
		SECTION	"sdSkipBytes",CODE
sdSkipBytes4:
		pusha
		ld	l,4
		j	sdSkipBytes6\.entry

sdSkipBytes5:
		pusha
		ld	l,5
		j	sdSkipBytes6\.entry

sdSkipBytes8:
		pusha
		ld	l,8
		j	sdSkipBytes6\.entry

sdSkipBytes6:
		pusha
		ld	l,6
.entry
.loop		WAIT_READY
		ld	c,IO_SD_DATA
		lio	t,(bc)
		MScreenByteOut
		dj	l,.loop

		popa
		j	(hl)

; ---------------------------------------------------------------------------
; -- Initialize V1 card
; --
; -- Inputs:
; --   	b - IO_SDCARD_BASE
; --
; -- Returns:
; --    t - card type
; --    f - "eq" condition if initialized
; --
; -- Clock: slow (via sdSendOpCond).
; --
		SECTION	"sdInitV1",CODE
sdInitV1:
		MDebugPrint <"sdInitV1\n">
		push	de/hl

		ld	d,HCS
		jal	sdSendOpCond

		ld	t,SDTYPE_V1

		pop	de/hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Initialize V2 card
; --
; -- Inputs:
; --   	b - IO_SDCARD_BASE
; --
; -- Returns:
; --    t - card type
; --    f - "eq" condition if initialized
; -- Clock: slow (via sdSendOpCond and sdReadOcr).
; --
		SECTION	"sdInitV2",CODE
sdInitV2:
		MDebugPrint <"sdInitV2\n">
		push	de/hl

		ld	d,HCS
		jal	sdSendOpCond
		j/ne	.fail

		jal	sdReadCcsBit
		j/ne	.fail

		cmp	t,0
		ld	t,SDTYPE_V2_HC
		ld/eq	t,SDTYPE_V2
		ld	f,FLAGS_EQ

		MDebugPrint <"sdInitV2 - success\n">

.fail		pop	de/hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Read CCS (card capacity) bit
; --
; -- Inputs:
; --   	b - IO_SDCARD_BASE
; --
; -- Returns:
; --    t - ccs bit (0 or 1)
; --    f - "eq" condition if successful
; --
; -- Clock: slow (via sdReadOcr).
; --
		SECTION	"sdReadCcsBit",CODE
sdReadCcsBit:
		MDebugPrint <"sdReadCcsBit\n">
		push	hl

		jal	sdReadOcr
		pop	de	;discard lower 16 bits of result
		j/ne	.fail

		ld	t,d
		and	t,$40	;t = CCS bit

		ld	f,0
		rs	ft,6
		ld	f,FLAGS_EQ

.fail		pop	hl
		j	(hl)

; ---------------------------------------------------------------------------
; -- Read OCR register
; --
; -- Inputs:
; --   	b - IO_SDCARD_BASE
; --
; -- Returns:
; --    f - "eq" if OK
; --   de - top (d=15:8, e=7:0), next(d=31:24, e=23:16)
; -- Clock: selects slow (CMD58 is post-ACMD41, so fast would also be legal).
; --
		SECTION	"sdReadOcr",CODE
sdReadOcr:
		MDebugPrint <"sdReadOcr\n">
		push	hl

		SELECT_SLOW

		WAIT_READY
		ld	c,IO_SD_DATA
		ld	t,58|$40	;CMD58
		lio	(bc),t

		jal	sdFinalBits5

		jal	sdInFirst
		j/ne	.fail

		WAIT_READY
		ld	c,IO_SD_DATA
		lio	t,(bc)

		ld	d,t
		WAIT_READY
		ld	c,IO_SD_DATA
		lio	t,(bc)

		ld	e,t
		push	de
		WAIT_READY
		ld	c,IO_SD_DATA
		lio	t,(bc)
		ld	d,t

		jal	sdInLast
		ld	e,t

		ld	t,0		; success marker
		j	.exit

.fail		ld	t,1		; failure marker

.exit		jal	sdDeselect
		cmp	t,0		; set eq flag if successful, after deselect
		pop	hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Perform ACMD41 (SEND_OP_COND)
; --
; -- Inputs:
; --   	b - IO_SDCARD_BASE
; --    d - HCS or zero
; --
; -- Returns:
; --   f - "eq" if OK
; -- Clock: slow (CMD55 selects slow; the ACMD41 bytes poll).
; --
		SECTION	"sdSendOpCond",CODE
sdSendOpCond:
		MDebugPrint <"sdSendOpCond\n">

		push	de/hl

		ld	e,0	;loop count = 256

.idle		jal	sdAppCommand
		j/ne	.done

		WAIT_READY
		ld	c,IO_SD_DATA
		ld	t,41|$40	;ACMD41
		lio	(bc),t

		WAIT_READY
		ld	c,IO_SD_DATA
		ld	t,d
		lio	(bc),t

		jal	sdFinalBits4

		jal	sdInFirst
		and	t,REPLY_IDLE
		cmp	t,0
		j/eq	.done

		MDelay	2000

		dj	e,.idle

.done		pop	de/hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Perform CMD55 (APP_COMMAND)
; --
; -- Inputs:
; --   	b - IO_SDCARD_BASE
; --
; -- Returns:
; --    f - "eq" if OK
; -- Clock: selects slow.
; --
		SECTION	"sdAppCommand",CODE
sdAppCommand:
		MDebugPrint <"sdAppCommand\n">
		push	hl

		SELECT_SLOW

		WAIT_READY
		ld	c,IO_SD_DATA
		ld	t,55|$40	;CMD55
		lio	(bc),t

		; argument
		jal	sdFinalBits5

		jal	sdInFirst

		pop	hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Perform CMD8 (SEND_IF_COND)
; --
; -- Inputs:
; --   	b - IO_SDCARD_BASE
; --
; -- Returns:
; --   f - "eq" if OK
; --   t - pattern
; -- Clock: selects slow.
; --
		SECTION	"sdSendIfCond",CODE
sdSendIfCond:
		MDebugPrint <"sdSendIfCond\n">
		push	de/hl

		SELECT_SLOW

		ld	de,.bytes
		jal	sdSendBytes6_Slow

		jal	sdInFirst
		j/ne	.fail

		WAIT_READY
		ld	c,IO_SD_DATA
		lio	t,(bc)		;R7[31:24]

		WAIT_READY
		ld	c,IO_SD_DATA
		lio	t,(bc)		;R7[23:16]

		WAIT_READY
		ld	c,IO_SD_DATA
		lio	t,(bc)		;R7[15:8]
		and	t,CMD8_VOLTAGES
		ld	d,t		;d = voltage mask

		jal	sdInLast	;R7[7:0]

		cmp	d,CMD8_VOLTAGES
		j/ne	.fail

		cmp	t,CMD8_PATTERN
.fail
		pop	de/hl
		j	(hl)


.bytes		DB	8|$40,$00,$00,CMD8_VOLTAGES,CMD8_PATTERN,CMD8_CRC


; ---------------------------------------------------------------------------
; -- Perform CMD0 (GO_IDLE_STATE)
; --
; -- Inputs:
; --   	b - IO_SDCARD_BASE
; --
; -- Returns:
; --    f - "eq" condition if success
; -- Clock: selects slow.
; --
		SECTION	"sdGoIdleState",CODE
sdGoIdleState:
		MDebugPrint <"sdGoIdleState\n">
		push	hl

		SELECT_SLOW

		ld	de,.bytes
		jal	sdSendBytes6_Slow

		jal	sdInFirst_GoIdle	;R1

		jal	sdDeselect

		pop	hl
		j	(hl)

.bytes		DB	0|$40,0,0,0,0,CMD0_CRC


; ---------------------------------------------------------------------------
; -- Fetch first reply byte (R1)
; --
; -- Inputs:
; --   	b - IO_SDCARD_BASE
; --
; -- Returns:
; --    f - "eq" condition if success
; --    t - byte
; -- Clock: caller's clock; polls before each read. Called fast from
; -- SdReadSingleBlock and SdGetTotalBlocks, slow from sdSetBlockLen512,
; -- sdReadOcr, sdSendOpCond, sdAppCommand and sdSendIfCond.
; --
		SECTION	"sdInFirst",CODE
sdInFirst:
		MDebugPrint <"sdInFirst\n">
		push	de/hl

		ld	e,100
.loop		WAIT_READY
		ld	c,IO_SD_DATA
		lio	t,(bc)
		MScreenByteOut
		ld	d,t
		and	t,$80
		cmp	t,$00
		j/eq	.done
		dj	e,.loop
		ld	f,FLAGS_NE
		j	.exit

.done		MScreenNewLine
		ld	t,REPLY_ERRORS
		and	t,d
		cmp	t,0	; set success flag
		ld	t,d

.exit		pop	de/hl
		j	(hl)
		

; ---------------------------------------------------------------------------
; -- Fetch first reply byte (R1)
; --
; -- Inputs:
; --   	b - IO_SDCARD_BASE
; --
; -- Returns:
; --    f - "eq" condition if success
; --    t - byte
; -- Clock: selects slow itself.
; --
		SECTION	"sdInFirst",CODE
sdInFirst_GoIdle:
		MDebugPrint <"sdInFirst_GoIdle\n">
		push	de/hl

		ld	ft,SdSelect
		ld	t,(ft)
		or	t,IO_SEL_SLOW_CLOCK
		ld	c,IO_SD_SELECT
		lio	(bc),t

		ld	e,100
.loop		WAIT_READY
		ld	c,IO_SD_DATA
		lio	t,(bc)
		ld	d,t
		cmp	t,REPLY_IDLE
		j/eq	.done
		dj	e,.loop
		ld	f,FLAGS_NE
		j	.exit

.done		MScreenNewLine

		MDebugHexByte d
		MDebugNewLine
		ld	t,REPLY_ERRORS
		and	t,d
		cmp	t,0	; set success flag
		ld	t,d

.exit		pop	de/hl
		j	(hl)
		

; ---------------------------------------------------------------------------
; -- Fetch last reply byte, disable hardware fetch circuit
; --
; -- Inputs:
; --   	b - IO_SDCARD_BASE
; --
; -- Returns:
; --    f - "eq" condition if success
; --    t - byte
; -- Clock: caller's clock; polls. Called fast from SdGetTotalBlocks and
; -- slow from sdReadOcr and sdSendIfCond.
; --
		SECTION	"sdInLast",CODE
sdInLast:
		WAIT_READY
		ld	c,IO_SD_DATA
		lio	t,(bc)
		MScreenByteOut

		push	ft

		ld	c,IO_SD_STATUS
		ld	t,0
		lio	(bc),t

		pop	ft

		j	(hl)
		

; ---------------------------------------------------------------------------
; -- Send a number of zero bytes to the SD card
; --
; -- Inputs:
; --   	b - IO_SDCARD_BASE
; --
; -- Clock: caller's clock; polls before each byte. sdFinalBits5 is called
; -- fast from SdGetTotalBlocks and slow from sdReadOcr and sdAppCommand;
; -- sdFinalBits4 from sdSendOpCond (slow)
; --
		SECTION	"sdFinalBits",CODE
sdFinalBits5:
		; argument, stuff bits
		push	hl
		ld	l,5-1
		j	sdFinalBits4\.entry
sdFinalBits4:
		; argument, stuff bits
		push	hl
		ld	l,4-1
.entry		; l contains the number of bytes to write - 1 to account for final CRC
.arg		WAIT_READY
		ld	c,IO_SD_DATA
		ld	t,$00
		lio	(bc),t
		dj	l,.arg
		WAIT_READY
		ld	c,IO_SD_DATA
		ld	t,$01
		lio	(bc),t

		pop	hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Get packet start ($FE byte)
; --
; -- Inputs:
; --   	b - IO_SDCARD_BASE
; --
; -- Returns:
; --    f - "eq" condition if success
; --
; -- Clock: caller's clock; polls before each read. Called fast from
; -- SdReadSingleBlock and SdGetTotalBlocks.
; --
		SECTION	"sdInPacket",CODE
sdInPacket:	push	de/hl

		MLDLoop	de,1000
.wait_packet	WAIT_READY
		ld	c,IO_SD_DATA
		lio	t,(bc)
		MScreenByteOut
		cmp	t,$FF
		j/ne	.got_packet
		MDelay	100
		dj	e,.wait_packet	
		dj	d,.wait_packet	

.got_packet	cmp	t,$FE

		MScreenNewLine

		pop	de/hl
		j	(hl)


		SECTION	"SdCardVars",BSS
SdSelect:	DS	1
SdType:		DS	1
