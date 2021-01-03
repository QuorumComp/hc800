		INCLUDE	"lowlevel/math.i"

		INCLUDE	"kernal/syscall.i"

		INCLUDE	"stream.i"
		INCLUDE	"string.i"

; -- Write data to stream out
; --
; -- Inputs:
; --   bc - pointer to code/data
; --   de - number of bytes to write
		SECTION	"StreamDataOut",CODE
StreamDataOut:
		pusha
		tst	de
		j/z	.exit
		sub	de,1
		add	d,1
		add	e,1
.next		lco	t,(bc)
		add	bc,1
		sys	KCharacterOut
		dj	e,.next
		dj	d,.next
.exit		popa
		j	(hl)


; -- Write data string to stream out
; --
; -- Inputs:
; --   bc - pointer to std string
		SECTION	"StreamDataStringOut",CODE
StreamDataStringOut:
		pusha
		lco	t,(bc)
		cmp	t,0
		j/z	.exit
		ld	d,t
.next		add	bc,1
		lco	t,(bc)
		sys	KCharacterOut
		dj	d,.next
.exit		popa
		j	(hl)


; -- Write bss string to stream out
; --
; -- Inputs:
; --   bc - pointer to std string
		SECTION	"StreamBssStringOut",CODE
StreamBssStringOut:
		pusha
		ld	t,(bc)
		cmp	t,0
		j/z	.exit
		ld	d,t
.next		add	bc,1
		ld	t,(bc)
		sys	KCharacterOut
		dj	d,.next
.exit		popa
		j	(hl)


; -- Print value as hexadecimal
; --
; -- Inputs:
; --   ft - value to print
		SECTION	"StreamHexWordOut",CODE
StreamHexWordOut:
		pusha

		exg	f,t
		jal	StreamHexByteOut
		exg	f,t
		jal	StreamHexByteOut

		popa
		j	(hl)


; -- Print value as hexadecimal
; --
; -- Inputs:
; --    t - value to print
		SECTION	"StreamHexByteOut",CODE
StreamHexByteOut:
		pusha

		ld	d,t

		ld	f,0
		ld	e,4
		rs	ft,e
		jal	StreamDigitOut

		ld	t,$F
		and	t,d
		jal	StreamDigitOut

		popa
		j	(hl)

; -- Print single digit
; --
; --    t - digit ($0-$F)
		SECTION	"StreamDigitOut",CODE
StreamDigitOut:
		pusha

		jal	DigitToAscii
		sys	KCharacterOut

		popa
		j	(hl)



; -- Print value as decimal
; --
; -- Inputs:
; --   ft - value to print
		SECTION	"StreamDecimalWordOut",CODE
StreamDecimalWordOut:
		pusha

		ld	de,ft
		tst	de
		j/z	.print_zero

		ld	ft,de
		jal	.recurse
		j	.exit

.print_zero	ld	t,0
		jal	StreamDigitOut

.exit		popa
		j	(hl)

.recurse
		pusha

		ld	de,ft
		tst	de
		j/z	.recurse_done

		ld	ft,10
		push	de
		ld	de,0
		jal	UnsignedDivide

		jal	.recurse

		ld	ft,de
		jal	StreamDigitOut

.recurse_done	popa
		j	(hl)


