		INCLUDE	"stdlib/string.i"
		INCLUDE	"stdlib/syscall.i"

		INCLUDE	"editor.i"
		INCLUDE	"error.i"
		INCLUDE	"text.i"


; --
; -- Print error description to attached terminal
; --
; -- Inputs:
; --    t - error code
; --
		SECTION	"PrintError",CODE
ErrorPrintDescription:
		cmp	t,ERROR_last
		ld/gtu	t,ERROR_last
		
		pusha

		ld	b,VATTR_ITALIC
		ld	c,VATTR_ITALIC
		jal	TextSetAttributes

		ld	ft,{ DC_STR <"Error "> }
		jal	ScreenStringOut

		pop	ft
		push	ft
		jal	ScreenHexByteOut

		ld	ft,{ DC_STR <": "> }
		jal	ScreenStringOut

		pop	ft
		ld	f,0
		ls	ft,1
		add	ft,descriptions+1
		ld	hl,ft

		lco	t,(hl)
		ld	f,t
		sub	hl,1
		lco	t,(hl)

		jal	ScreenStringOut

		ld	b,VATTR_ITALIC
		ld	c,0
		jal	TextSetAttributes

		ld	t,10
		jal	ScreenCharacterOut

		pop	bc-hl
		j	(hl)


		SECTION	"ErrorDescriptions",DATA

error00:	DC_STR	<"Protocol">
error01:	DC_STR	<"Timeout">
error02:	DC_STR	<"Success">
error03:	DC_STR	<"Not available">
error04:	DC_STR	<"Format">
errorUnknown:	DC_STR	<"Unknown">

descriptions:	DW	error00
		DW	error01
		DW	error02
		DW	error03
		DW	error04
		DW	errorUnknown

