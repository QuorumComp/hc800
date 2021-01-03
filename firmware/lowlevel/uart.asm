		INCLUDE	"uart.i"
		INCLUDE	"hc800.i"
		INCLUDE	"nexys3.i"
		INCLUDE	"rc800.i"

		GLOBAL	VideoIsVBlankEdge


; --
; -- Read byte asynchronously from UART
; --
; -- Outputs:
; --    f - "eq" condition if data available
; --    t - byte read
; --
		SECTION	"UartByteIn",CODE
UartByteIn:
		push	bc/hl

		jal	UartCanRead
		j/ne	.done

		ld	b,IO_UART_BASE
		ld	c,IO_UART_DATA
		lio	t,(bc)

.done		pop	bc/hl
		j	(hl)


; --
; -- Read byte synchronously from UART
; --
; -- Outputs:
; --    f - "eq" condition if byte read, "ne" if timeout
; --    t - byte read
; --
		SECTION	"UartByteInSync",CODE
UartByteInSync:
		push	bc/hl

		ld	b,TIMEOUT_FRAMES
.wait_frame	jal	UartByteIn
		j/eq	.done

		jal	VideoIsVBlankEdge
		sub/eq	b,1
		cmp	b,0
		j/nz	.wait_frame

		ld	f,FLAGS_NE

.done		pop	bc/hl
		j	(hl)


; --
; -- Determine if data is available to read
; --
; -- Outputs:
; --    f - "eq" condition if data is available
; --
		SECTION	"UartCanRead",CODE
UartCanRead:
		push	bc

		ld	b,IO_UART_BASE
		ld	c,IO_UART_STATUS
		lio	t,(bc)
		not	t
		and	t,IO_UART_STATUS_READ
		cmp	t,0

		pop	bc
		j	(hl)


; --
; -- Read unsigned word from UART
; --
; -- Outputs:
; --    f - "eq" condition if word read
; --   bc - word
; --
		SECTION	"UartWordInSync",CODE
UartWordInSync:
		push	hl

		jal	UartByteInSync
		j/ne	.done
		ld	c,t

		jal	UartByteInSync
		ld	b,t

.done		pop	hl
		j	(hl)


; --
; -- Write unsigned word to UART
; --
; -- Inputs:
; --   ft - word
; --
		SECTION	"UartWordOutSync",CODE
UartWordOutSync:
		pusha

		jal	UartByteOutSync
		ld	t,f
		jal	UartByteOutSync

		popa
		j	(hl)


; --
; -- Write byte to UART
; --
; -- Inputs:
; --    t - Byte to write
; --
		SECTION	"UartByteOutSync",CODE
UartByteOutSync:
		pusha	

		jal	UartWaitWrite

		ld	b,IO_UART_BASE
		ld	c,IO_UART_DATA
		lio	(bc),t

		popa
		j	(hl)


; --
; -- Wait for UART write
; --
		SECTION	"UartWaitWrite",CODE
UartWaitWrite:
		pusha

		ld	b,IO_UART_BASE
		ld	c,IO_UART_STATUS
.wait		lio	t,(bc)
		and	t,IO_UART_STATUS_WRITE
		cmp	t,0
		j/z	.wait

		popa
		j	(hl)
		