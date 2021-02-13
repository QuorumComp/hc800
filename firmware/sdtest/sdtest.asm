		INCLUDE	"lowlevel/hc800.i"

		INCLUDE	"stdlib/stream.i"
		INCLUDE	"stdlib/syscall.i"

		; b is assumed to be IO_SDCARD_BASE
SELECT:		MACRO
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
		MPrintString <"CMD0 ">
		jal	sdGoIdleState
		jal	StreamHexByteOut
		MNewLine

		MPrintString <"CMD8 ">
		jal	sdSendIfCond
		jal	StreamHexByteOut
		MNewLine

		sys	KExit

sdSendIfCond:
		push	hl

		ld	b,IO_SDCARD_BASE
		SELECT

		ld	c,IO_SD_DATA
		ld	t,$08|$40	;CMD0
		lio	(bc),t

		; argument
		nop
		ld	t,$00
		lio	(bc),t		;arg[31:24]
		nop
		nop
		lio	(bc),t		;arg[23:16]
		nop
		ld	t,$01		;arg[15:12] arg[11:8]=1,3.3VCC
		lio	(bc),t		;arg[15:8]
		nop
		ld	t,$AA
		lio	(bc),t		;arg[7:0]
		nop
		ld	t,$87
		lio	(bc),t		;CRC

		jal	sdInReply1
		jal	sdIn		;R7[31:24]
		jal	sdIn		;R7[23:16]
		jal	sdIn		;R7[15:8]
		jal	sdIn		;R7[7:0] echo

		DESELECT

		pop	hl
		j	(hl)

sdGoIdleState:
		push	hl

		ld	b,IO_SDCARD_BASE
		SELECT

		ld	c,IO_SD_DATA
		ld	t,$00|$40	;CMD0
		lio	(bc),t

		; argument, stuff bits
		ld	f,4
		ld	t,$00
.arg		lio	(bc),t
		nop
		dj	f,.arg

		; CRC
		ld	t,$95
		lio	(bc),t

		jal	sdInReply1	;R1

		DESELECT

		pop	hl
		j	(hl)

; t = byte
; f = "eq" ok
sdInReply1:
		ld	f,100
.loop		ld	c,IO_SD_STATUS
		ld	t,IO_STAT_IN_ACTIVE|IO_STAT_SELECT
		lio	(bc),t
		ld	c,IO_SD_DATA
		nop
		lio	t,(bc)
		ld	d,t
		and	t,$80
		cmp	t,$00
		j/eq	.done
		dj	f,.loop

.done		ld	t,d

		j	(hl)
		

sdIn:
		ld	c,IO_SD_STATUS
		ld	t,IO_STAT_IN_ACTIVE|IO_STAT_SELECT
		lio	(bc),t
		ld	c,IO_SD_DATA
		nop
		lio	t,(bc)

		j	(hl)
		


