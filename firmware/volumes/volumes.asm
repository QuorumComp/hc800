		INCLUDE	"lowlevel/hc800.i"
		INCLUDE	"lowlevel/math.i"
		INCLUDE	"lowlevel/rc800.i"
		INCLUDE	"lowlevel/stack.i"

		INCLUDE	"stdlib/stream.i"
		INCLUDE	"stdlib/string.i"
		INCLUDE	"stdlib/syscall.i"

		SECTION	"SDTest",CODE

Entry::
		MSetColor 1
		MPrintString <"Volume  Mount point      Device  \n">
		MSetColor 0

		jal	listVolumes
		sys	KExit

listVolumes:
		pusha

		ld	bc,volumeInfo
		ld	d,0

.loop		ld	t,d
		sys	KGetVolume
		j/ne	.done

		jal	printVolume

		add	d,1
		j	.loop

.done		popa
		j	(hl)


printVolume:
		pusha

		ld	bc,volumeInfo+volinf_Name
		jal	StreamBssStringOut

		ld	t,9
		sys	KCharacterOut

		add	bc,volinf_Label-volinf_Name
		jal	StreamBssStringOut

		ld	t,(bc)
		sub	t,17
		neg	t
		ld	d,t
.spaces		ld	t,' '
		sys	KCharacterOut
		dj	d,.spaces

		add	bc,volinf_BlockDevice-volinf_Label
		ld	t,(bc)
		cmp	t,$FF
		j/eq	.done

		ld	bc,deviceInfo
		sys	KGetBlockDevice
		j/ne	.done

		add	bc,bdinf_Name
		jal	StreamBssStringOut

.done
		MNewLine

		popa
		j	(hl)


		SECTION	"Variables",BSS_S
deviceInfo	DS	bdinf_SIZEOF
volumeInfo	DS	volinf_SIZEOF
