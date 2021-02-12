		INCLUDE	"lowlevel/hc800.i"

		INCLUDE	"stdlib/stream.i"
		INCLUDE	"stdlib/syscall.i"

		SECTION	"Monitor",CODE

Entry::
		MPrintString <"CMD0 ">
		jal	sdGoIdleState
		jal	StreamHexByteOut

		MNewLine

		sys	KExit

sdGoIdleState:
		push	hl

		jal	sdSelectOn

		ld	t,$00|$40	;CMD0
		jal	sdOut

		; argument, stuff bits
		ld	t,$00
		jal	sdOut
		jal	sdOut
		jal	sdOut
		jal	sdOut

		; CRC
		ld	t,$95
		jal	sdOut

		jal	sdInReply

		jal	sdSelectOff

		pop	hl
		j	(hl)

; t = byte
; f = "eq" ok
sdInReply:
		push	bc-hl

		ld	c,100
.loop		jal	sdIn
		ld	b,t
		and	t,$80
		cmp	t,$80
		j/eq	.done
		dj	c,.loop

.done		ld	t,b

		pop	bc-hl
		j	(hl)
		

sdIn:
		push	bc-hl

		jal	sdWait

		ld	b,IO_SDCARD_BASE

		ld	c,IO_SD_STATUS
		lio	t,(bc)
		or	t,IO_STAT_IN_ACTIVE
		lio	(bc),t

		jal	sdWait

		ld	c,IO_SD_DATA
		lio	t,(bc)

		pop	bc-hl
		j	(hl)


sdOut:
		pusha

		jal	sdWait

		ld	b,IO_SDCARD_BASE
		ld	c,IO_SD_DATA
		lio	(bc),t

		jal	sdWait

		popa
		j	(hl)


sdWait:
		pusha

		ld	b,IO_SDCARD_BASE
		ld	c,IO_SD_STATUS

.wait		lio	t,(bc)
		and	t,IO_STAT_IN_ACTIVE|IO_STAT_OUT_ACTIVE
		cmp	t,0
		j/ne	.wait

		popa
		j	(hl)





sdSelectOn:
		pusha

		ld	b,IO_SDCARD_BASE
		ld	c,IO_SD_STATUS

		lio	t,(bc)
		or	t,IO_STAT_SELECT
		lio	(bc),t

		popa
		j	(hl)

sdSelectOff:
		pusha

		ld	b,IO_SDCARD_BASE
		ld	c,IO_SD_STATUS

		lio	t,(bc)
		ld	t,~IO_STAT_SELECT
		lio	(bc),t

		popa
		j	(hl)
