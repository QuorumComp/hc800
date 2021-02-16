		INCLUDE	"lowlevel/hc800.i"
		INCLUDE	"lowlevel/rc800.i"

		INCLUDE	"stdlib/stream.i"
		INCLUDE	"stdlib/syscall.i"

		INCLUDE	"sd.i"


CMD8_PATTERN:	EQU	$AA	;pattern for CMD08
CMD8_VOLTAGES:	EQU	$01	;3.3V
CMD8_CRC:	EQU	$87

BLOCKLEN:	EQU	512

HCS:		EQU	$40	;high capacity supported

REPLY_IDLE:		EQU	$01
REPLY_ERASE_RESET	EQU	$02
REPLY_ILLEGAL_COMMAND	EQU	$04
REPLY_CRC_ERROR		EQU	$08
REPLY_ERASE_SEQ_ERROR	EQU	$10
REPLY_ADDRESS_ERROR	EQU	$20
REPLY_PARAMETER_ERROR	EQU	$40

REPLY_ERRORS		EQU	REPLY_ILLEGAL_COMMAND|REPLY_CRC_ERROR|REPLY_ERASE_SEQ_ERROR|REPLY_ADDRESS_ERROR|REPLY_PARAMETER_ERROR

SELECT:		MACRO
		ld	b,IO_SDCARD_BASE
		ld	c,IO_SD_STATUS
		ld	t,IO_STAT_SELECT
		lio	(bc),t
		ENDM

		; b is assumed to be IO_SDCARD_BASE
DESELECT:	MACRO
		push	ft
		ld	t,0
		lio	(bc),t
		pop	ft
		ENDM

	IF 1
		PURGE	MPrintString
MPrintString:	MACRO
		ENDM

		PURGE	MNewLine
MNewLine:	MACRO
		ENDM

MHexByteOut:	MACRO
		ENDM
	ELSE
MHexByteOut:	MACRO
		push	hl
		jal	StreamHexByteOut
		pop	hl
		ENDM
	ENDC




; ---------------------------------------------------------------------------
; -- Read block from SD card (CMD17)
; --
; -- Inputs:
; --   bc - pointer to 32 bit block number
; --   de - pointer to destination
; --
; -- Returns:
; --    f - "eq" condition if success
; --
		SECTION	"SdReadSingleBlock",CODE
SdReadSingleBlock:	
		push	bc-hl

		exg	ft,bc
		exg	ft,de
		exg	ft,hl

		; hl = pointer to dest
		; de = pointer to black number

		SELECT

		ld	c,IO_SD_DATA
		ld	t,17|$40	;CMD17
		lio	(bc),t

		push	hl
		jal	sdSendBlockNumber
		jal	sdInFirst
		pop	hl
		j/ne	.error

		LDLOOP	de,1000
.wait_packet	lio	t,(bc)
		MHexByteOut
		cmp	t,$FF
		j/ne	.got_packet
		DELAY	100
		dj	e,.wait_packet	
		dj	d,.wait_packet	

.got_packet	cmp	t,$FE
		j/ne	.error

		MPrintString <"  do read\n">

		ld	e,BLOCKLEN/8
.read_loop	REPT	8
		lio	t,(bc)
		ld	(hl),t
		add	hl,1
		ENDR
		dj	e,.read_loop

		MPrintString <"  did read\n">

		; CRC
		lio	t,(bc)
		nop
		nop
		lio	t,(bc)

		ld	f,FLAGS_EQ

.error		DESELECT

		pop	bc-hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- Initialize SD card, determine type
; --
; -- Returns:
; --    t - card type
; --    f - "eq" condition if initialized
; --
		SECTION	"SdInit",CODE
SdInit:		push	bc-hl

		jal	sdGoIdleState
		cmp	t,REPLY_IDLE
		j/ne	.handle_status

		jal	sdSendIfCond
		j/eq	.v2_card

		jal	sdInitV1
		j	.handle_status

.v2_card	jal	sdInitV2

.handle_status	j/ne	.fail
		ld	d,t
		jal	sdSetBlockLen512
		ld	t,d
		j/eq	.store

.fail		ld	t,SDTYPE_NONE
.store		ld	bc,SdType
		ld	(bc),t

		pop	bc-hl
		j	(hl)


; ---------------------------------------------------------------------------
; -- PRIVATE FUNCTIONS
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; -- Send block number
; --
; -- Inputs:
; --   	b - IO_SDCARD_BASE
; --   de - pointer to block number
; --

sdSendBlockNumber:
		MPrintString <"sdSendBlockNumber\n">

		pusha

		ld	c,IO_SD_DATA

		add	de,3

		ld	ft,SdType
		ld	t,(ft)
		cmp	t,SDTYPE_V2_HC
		j/eq	.hc

		; standard capacity, send blockNumber*512

		sub	de,1
		ld	l,2
.sc_arg		ld	t,(de)
		exg	f,t
		sub	de,1
		ld	t,(de)
		ls	ft,1
		exg	f,t
		lio	(bc),t
		dj	l,.sc_arg

		ld	t,(de)
		ls	ft,1
		lio	(bc),t

		ld	l,2
.sc_term	ld	t,0
		lio	(bc),t
		dj	l,.sc_term

		j	.done

		; high capacity, send blockNumber

.hc		ld	l,4
.hc_arg		ld	t,(de)
		sub	de,1
		lio	(bc),t
		dj	l,.hc_arg

		ld	t,0	;CRC
		lio	(bc),t

.done		popa
		j	(hl)


; ---------------------------------------------------------------------------
; -- Set block length to 512 bytes
; --
; -- Inputs:
; --   	b - IO_SDCARD_BASE
; --
; -- Returns:
; --    t - card type
; --    f - "eq" condition if initialized
; --
		SECTION	"sdSetBlockLen512",CODE
sdSetBlockLen512:
		MPrintString <"sdSetBlockLen512\n">

		push	hl

		SELECT

		ld	c,IO_SD_DATA
		ld	t,16|$40	;CMD16
		lio	(bc),t

		jal	sdStuffBits2

		ld	t,BLOCKLEN>>8
		lio	(bc),t

		jal	sdStuffBits2

		jal	sdInFirst

		DESELECT

		pop	hl
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
		SECTION	"sdInitV1",CODE
sdInitV1:
		MPrintString <"sdInitV1\n">
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
; --
		SECTION	"sdInitV2",CODE
sdInitV2:
		MPrintString <"sdInitV2\n">
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
; --    f - "ne" = fail
; --
		SECTION	"sdReadCcsBit",CODE
sdReadCcsBit:
		MPrintString <"sdReadCcsBit\n">
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
; --
		SECTION	"sdReadOcr",CODE
sdReadOcr:
		MPrintString <"sdReadOcr\n">
		push	hl

		SELECT

		ld	c,IO_SD_DATA
		ld	t,58|$40	;CMD58
		lio	(bc),t

		jal	sdStuffBits5

		jal	sdInFirst
		j/ne	.fail

		ld	c,IO_SD_DATA
		lio	t,(bc)
		ld	d,t
		nop
		lio	t,(bc)
		ld	e,t
		push	de

		lio	t,(bc)
		ld	d,t

		jal	sdInLast
		ld	e,t

.fail		DESELECT

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
; --
		SECTION	"sdSendOpCond",CODE
sdSendOpCond:
		MPrintString <"sdSendOpCond\n">

		push	de/hl

		ld	e,0	;loop count = 256

.idle		jal	sdAppCommand
		j/ne	.done

		ld	c,IO_SD_DATA
		ld	t,41|$40	;ACMD41
		lio	(bc),t

		nop
		ld	t,d
		lio	(bc),t

		jal	sdStuffBits4

		jal	sdInFirst
		and	t,REPLY_IDLE
		cmp	t,0
		j/eq	.done

		DELAY	2000

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
; --
		SECTION	"sdAppCommand",CODE
sdAppCommand:
		MPrintString <"sdAppCommand\n">
		push	hl

		SELECT

		ld	c,IO_SD_DATA
		ld	t,55|$40	;CMD55
		lio	(bc),t

		; argument
		jal	sdStuffBits5

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
; --
		SECTION	"sdSendIfCond",CODE
sdSendIfCond:
		MPrintString <"sdSendIfCond\n">
		push	de/hl

		SELECT

		ld	c,IO_SD_DATA
		ld	t,8|$40		;CMD8
		lio	(bc),t

		; argument
		nop
		ld	t,$00
		lio	(bc),t		;arg[31:24]
		nop
		nop
		lio	(bc),t		;arg[23:16]
		nop
		ld	t,CMD8_VOLTAGES	;arg[15:12] arg[11:8]=1,3.3VCC
		lio	(bc),t		;arg[15:8]
		nop
		ld	t,CMD8_PATTERN
		lio	(bc),t		;arg[7:0]
		nop
		ld	t,CMD8_CRC
		lio	(bc),t		;CRC

		jal	sdInFirst

		lio	t,(bc)		;R7[31:24]

		nop
		nop
		lio	t,(bc)		;R7[23:16]

		nop
		nop
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


; ---------------------------------------------------------------------------
; -- Perform CMD0 (GO_IDLE_STATE)
; --
; -- Inputs:
; --   	b - IO_SDCARD_BASE
; --
; -- Returns:
; --    f - "eq" condition if success
; --
		SECTION	"sdGoIdleState",CODE
sdGoIdleState:
		MPrintString <"sdGoIdleState\n">
		push	hl

		SELECT

		ld	c,IO_SD_DATA
		ld	t,0|$40		;CMD0
		lio	(bc),t

		jal	sdStuffBits4

		; CRC
		ld	t,$95
		lio	(bc),t

		jal	sdInFirst	;R1

		DESELECT

		pop	hl
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
; --
		SECTION	"sdInFirst",CODE
sdInFirst:
		MPrintString <"sdInFirst\n">
		push	de/hl

		ld	c,IO_SD_STATUS
		ld	t,IO_STAT_IN_ACTIVE|IO_STAT_SELECT
		lio	(bc),t

		ld	f,100
.loop		ld	c,IO_SD_DATA
		lio	t,(bc)
		MHexByteOut
		ld	d,t
		and	t,$80
		cmp	t,$00
		j/eq	.done
		dj	f,.loop
		ld	f,FLAGS_NE
		j	.exit

.done		MNewLine
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
; --
		SECTION	"sdInLast",CODE
sdInLast:
		MPrintString <"sdInLast\n">
		ld	c,IO_SD_STATUS
		ld	t,IO_STAT_SELECT
		lio	(bc),t

		ld	c,IO_SD_DATA
		lio	t,(bc)

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
		SECTION	"sdStuffBits",CODE
sdStuffBits5:
		; argument, stuff bits
		ld	f,5
		j	sdStuffBits4\.entry
sdStuffBits2:
		; argument, stuff bits
		ld	f,2
		j	sdStuffBits4\.entry
sdStuffBits4:
		; argument, stuff bits
		ld	f,4
.entry		ld	t,$00
.arg		lio	(bc),t
		nop
		dj	f,.arg

		j	(hl)



		SECTION	"SdCardVars",BSS
SdType:		DS	1
