		INCLUDE	"video.i"
		INCLUDE	"video_common.i"

		SECTION	"Video",CODE

; --
; -- Print value as hexadecimal
; --
; -- Inputs:
; --   ft - value to print
; --
TextHexWordOut:
		pusha

		exg	f,t
		jal	TextHexByteOut
		exg	f,t
		jal	TextHexByteOut

		popa
		j	(hl)


; --
; -- Print value as hexadecimal
; --
; -- Inputs:
; --    t - value to print
; --
TextHexByteOut:
		pusha

		ld	d,t

		ld	f,0
		ld	e,4
		rs	ft,e
		jal	TextDigitOut

		ld	t,$F
		and	t,d
		jal	TextDigitOut

		popa
		j	(hl)


; --
; -- Set cursor to start of next line
; --
TextNewline:	pusha

		ld	bc,VideoCursor+csr_X

		ld	t,0
		ld	(bc),t
		
		add	bc,csr_Y-csr_X
		ld	t,(bc)
		add	t,1
		ld	(bc),t

		cmp	t,LINES_ON_SCREEN
		j/ltu	.done

		; scroll screen

.done
		popa
		j	(hl)


; --
; -- Print string from code bank
; --
; -- Inputs:
; --   bc - String
; --    t - Length
; --
TextCodeStringOut:
		pusha

		cmp	t,0
		j/z	.done
		ld	d,t
.loop		lco	t,(bc)
		add	bc,1
		ld	f,0
		jal	TextWideCharOut
		dj	d,.loop
.done
		popa
		j	(hl)


; --
; -- Print single digit
; --
; --    t - digit ($0-$F)
; --
TextDigitOut:
		pusha

		ld	f,0
		add	ft,.hex
		lco	t,(ft)
		ld	f,0
		jal	TextWideCharOut

		popa
		j	(hl)

.hex		DB	"0123456789ABCDEF"


