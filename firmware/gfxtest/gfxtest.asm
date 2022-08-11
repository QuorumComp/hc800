		INCLUDE	"lowlevel/hc800.i"
		INCLUDE	"lowlevel/memory.i"
		INCLUDE	"lowlevel/scancodes.i"

		INCLUDE	"stdlib/syscall.i"

		SECTION	"Code",CODE

Entry::
		ld	t,0
		ld	bc,bss_Start
		ld	de,bss_End-bss_Start
		jal	SetMemory

		ld	b,IO_VIDEO_BASE

		ld	c,IO_VIDEO_CONTROL
		ld	t,IO_VID_CTRL_P0EN
		lio	(bc),t

		ld	c,IO_VID_PLANE0_CONTROL
		ld	t,IO_PLANE_CTRL_LORES|IO_PLANE_CTRL_TEXT|IO_PLANE_CTRL_PAL0
		lio	(bc),t

		; handle keypress

.wait_char	sys	KCharacterIn
		j/z	.wait_char

		cmp	t,'h'
		j/eq	.key_hires

		cmp	t,'l'
		j/eq	.key_lores

		cmp	t,KEY_LEFT
		j/eq	.key_left
		cmp	t,KEY_RIGHT
		j/eq	.key_right

		cmp	t,KEY_UP
		j/eq	.key_up
		cmp	t,KEY_DOWN
		j/eq	.key_down

		cmp	t,KEY_ESCAPE
		j/eq	.key_escape

		j	.wait_char

.key_lores
		ld	t,IO_PLANE_CTRL_LORES|IO_PLANE_CTRL_TEXT|IO_PLANE_CTRL_PAL0
		j	.set_control

.key_hires
		ld	t,IO_PLANE_CTRL_HIRES|IO_PLANE_CTRL_TEXT|IO_PLANE_CTRL_PAL0

.set_control
		ld	b,IO_VIDEO_BASE
		ld	c,IO_VID_PLANE0_CONTROL
		lio	(bc),t
		j	.wait_char

.key_escape
		sys	KExit


.key_left
		ld	bc,scrollX
		ld	ft,(bc+)
		add	ft,1
		j	.update_scrollx

.key_right
		ld	bc,scrollX
		ld	ft,(bc+)
		sub	ft,1

.update_scrollx	
		ld	(-bc),ft

		ld	b,IO_VIDEO_BASE

		ld	c,IO_VID_PLANE0_HSCROLLL
		lio	(bc),t

		exg	f,t
		ld	c,IO_VID_PLANE0_HSCROLLH
		lio	(bc),t

		J	.wait_char

.key_up
		ld	bc,scrollY
		ld	ft,(bc+)
		add	ft,1
		j	.update_scrolly

.key_down
		ld	bc,scrollY
		ld	ft,(bc+)
		sub	ft,1

.update_scrolly
		ld	(-bc),ft

		ld	b,IO_VIDEO_BASE

		ld	c,IO_VID_PLANE0_VSCROLLL
		lio	(bc),t

		exg	f,t
		ld	c,IO_VID_PLANE0_VSCROLLH
		lio	(bc),t

		ld	ft,.wait_char
		j	(ft)


		SECTION	"Vars",BSS_S
bss_Start:
scrollX:	DS	2
scrollY:	DS	2
bss_End: