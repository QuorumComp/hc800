		INCLUDE	"lowlevel/hc800.i"

		INCLUDE	"stdlib/stream.i"
		INCLUDE	"stdlib/syscall.i"

		SECTION	"Code",CODE

Entry::
		; Draw headline

		MPrintString <"Scroll test\nUse cursor keys, escape to exit\n">

		ld	b,IO_VIDEO_BASE
		ld	c,IO_VID_PLANE0_HSCROLLH
		lio	t,(bc)
		ld	f,t
		add	c,IO_VID_PLANE0_HSCROLLL-IO_VID_PLANE0_HSCROLLH
		lio	t,(bc)
		ld	de,ft	; scroll pos

.loop		ld	ft,de
		jal	StreamDecimalWordOut

		MPrintString <"    ",KEY_HOME>

.char_in	sys	KCharacterIn
		j/z	.char_in

		cmp	t,KEY_ESCAPE
		j/eq	.exit

		cmp	t,KEY_LEFT
		sub/eq	de,1

		cmp	t,KEY_RIGHT
		add/eq	de,1

		cmp	t,KEY_F1
		j/ne	.no_res

		ld	b,IO_VIDEO_BASE
		ld	c,IO_VID_PLANE0_CONTROL
		lio	t,(bc)
		xor	t,IO_PLANE_CTRL_HIRES
		lio	(bc),t

.no_res		ld	b,IO_VIDEO_BASE
		ld	c,IO_VID_PLANE0_HSCROLLL
		ld	ft,de
		lio	(bc),t
		add	c,IO_VID_PLANE0_HSCROLLH-IO_VID_PLANE0_HSCROLLL
		ld	t,f
		lio	(bc),t

		j	.loop

.exit		sys	KExit
