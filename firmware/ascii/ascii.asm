		INCLUDE	"syscall.i"
		INCLUDE	"stream.i"

		SECTION	"Code",CODE

Entry::
		; Draw headline

		ld	t,' '
		ld	b,3
.spaces		sys	KCharacterOut
		MSetColor 1
		dj	b,.spaces

		ld	e,0
		ld	d,16
.numbers	ld	t,' '
		sys	KCharacterOut
		ld	t,e
		jal	StreamDigitOut
		add	e,1
		dj	d,.numbers
		MSetColor 0
		MNewLine

		ld	e,$20
.next_line
		ld	t,' '
		sys	KCharacterOut

		; draw left hand column
		ld	t,e
		MSetColor 1
		jal	StreamHexByteOut
		MSetColor 0

		; draw 16 characters
.next_char	ld	t,' '
		sys	KCharacterOut
		ld	t,e
		sys	KCharacterOut
		add	e,1
		ld	t,15
		and	t,e
		cmp	t,0
		j/nz	.next_char

		MNewLine

		cmp	e,0
		j/nz	.next_line

		sys	KExit
