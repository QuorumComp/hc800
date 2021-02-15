		INCLUDE	"lowlevel/hc800.i"
		INCLUDE	"lowlevel/rc800.i"

		INCLUDE	"stdlib/stream.i"
		INCLUDE	"stdlib/syscall.i"

CMD8_PATTERN:	EQU	$AA	;pattern for CMD08
CMD8_VOLTAGES:	EQU	$01	;3.3V
CMD8_CRC:	EQU	$87

HCS:		EQU	$40	;high capacity supported

REPLY_IDLE:		EQU	$01
REPLY_ERASE_RESET	EQU	$02
REPLY_ILLEGAL_COMMAND	EQU	$04
REPLY_CRC_ERROR		EQU	$08
REPLY_ERASE_SEQ_ERROR	EQU	$10
REPLY_ADDRESS_ERROR	EQU	$20
REPLY_PARAMETER_ERROR	EQU	$40

REPLY_ERRORS		EQU	REPLY_ILLEGAL_COMMAND|REPLY_CRC_ERROR|REPLY_ERASE_SEQ_ERROR|REPLY_ADDRESS_ERROR|REPLY_PARAMETER_ERROR

		; b is assumed to be IO_SDCARD_BASE
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

		SECTION	"SDTest",CODE

Entry::
		jal	sdInit
		sys	KExit

sdInit:
		push	hl

		jal	sdGoIdleState
		cmp	t,REPLY_IDLE
		j/ne	.handle_status

		jal	sdSendIfCond
		j/eq	.v2_card

		jal	sdInitV1
		j	.handle_status

.v2_card	jal	sdInitV2

.handle_status	ld	t,1
		ld/ne	t,0

		ld	bc,sdPresent
		ld	(bc),t

		pop	hl
		j	(hl)

sdInitV1:
		MPrintString <"V1 card\n">

		ld	d,HCS
		jal	sdSendOpCond

		ld	bc,sdIsSDHC
		ld	t,0
		ld	(bc),t
.fail
		j	(hl)

sdInitV2:
		push	hl

		MPrintString <"V2 card\n">

		ld	d,HCS
		jal	sdSendOpCond
		j/ne	.fail

		jal	sdReadCcsBit
		j/ne	.fail

		ld	bc,sdIsSDHC
		ld	(bc),t

		cmp	t,0
		j/eq	.standard

		; high capacity
		MPrintString <"High capacity (SDHC)\n">
		j	.done

.standard	MPrintString <"Standard capacity\n">
.done		ld	f,FLAGS_EQ

.fail
		pop	hl
		j	(hl)


; -- Returns:
; --   t - ccs bit (0 or 1)
; --   f - "ne" = fail
sdReadCcsBit:
		push	hl

		jal	sdReadOcr
		j/ne	.fail

		ld	t,d
		and	t,$40	;t = CCS bit
		pop	de

		ld	f,0
		rs	ft,6
		ld	f,FLAGS_EQ

.fail		pop	hl
		j	(hl)

; -- Return:
; --    f - "eq" if OK
; --   de - top (d=31:24, e=23:16), next(d=15:8, e=7:0)
sdReadOcr:
		push	hl

		SELECT

		ld	c,IO_SD_DATA
		ld	t,58|$40	;CMD58
		lio	(bc),t

		jal	sdStuffBits5

		jal	sdInFirst
		j/ne	.fail

		ld	c,IO_SD_DATA
		ld	t,(bc)
		ld	e,t
		nop
		ld	t,(bc)
		ld	d,t
		push	de

		ld	t,(bc)
		ld	e,t
		nop
		ld	t,(bc)
		ld	d,t

.fail		DESELECT

		pop	hl
		j	(hl)

; -- Inputs:
; --   d - HCS or zero
; -- Return:
; --   f - "eq" if OK
sdSendOpCond:
		push	ft/hl

.idle		jal	sdAppCommand
		j/ne	.fail

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
		j/ne	.idle

.fail		pop	hl
		j	(hl)

; -- Return:
; --   f - "eq" if OK
; --   t - pattern
sdAppCommand:
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

; -- Return:
; --   f - "eq" if OK
; --   t - pattern
sdSendIfCond:
		push	hl

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
		pop	hl
		j	(hl)

sdGoIdleState:
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

; t = byte
; f = "eq" ok
sdInFirst:
		ld	c,IO_SD_STATUS
		ld	t,IO_STAT_IN_ACTIVE|IO_STAT_SELECT
		lio	(bc),t

		ld	f,100
.loop		ld	c,IO_SD_DATA
		lio	t,(bc)
		ld	d,t
		and	t,$80
		cmp	t,$00
		j/eq	.done
		dj	f,.loop
		ld	f,FLAGS_NE
		j	.exit

.done		ld	t,REPLY_ERRORS
		and	t,d
		cmp	t,0	; set success flag
		ld	t,d

.exit		j	(hl)
		

sdInLast:
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
		

sdIn:
		ld	c,IO_SD_STATUS
		ld	t,IO_STAT_IN_ACTIVE|IO_STAT_SELECT
		lio	(bc),t
		ld	c,IO_SD_DATA
		lio	t,(bc)

		j	(hl)


sdStuffBits5:
		; argument, stuff bits
		ld	f,5
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
sdPresent	DS	1
sdIsSDHC	DS	1
