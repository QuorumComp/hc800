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

		sys	KExit

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

		jal	sdInReply

		DESELECT

		pop	hl
		j	(hl)

; t = byte
; f = "eq" ok
sdInReply:
		push	bc-hl

		ld	b,IO_SDCARD_BASE
		ld	c,IO_SD_DATA
		ld	f,100
.loop		lio	t,(bc)
		ld	d,t
		and	t,$80
		cmp	t,$00
		j/eq	.done
		dj	f,.loop

.done		ld	t,d

		pop	bc-hl
		j	(hl)
		

