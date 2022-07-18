		INCLUDE	"stdlib/stream.i"
		INCLUDE	"stdlib/string.i"
		INCLUDE	"stdlib/syscall.i"

		SECTION	"Code",CODE

Entry::
		pusha

		ld	ft,path
		sys	KGetCommandLine

		; find first argument, skip executable name
		ld	bc,path
		ld	t,(bc)
		ld	f,0
		add	ft,bc
		add	ft,1
		ld	bc,ft

		ld	t,(bc)
		cmp	t,0
		j/ne	.path_argument

		MSetAttribute VATTR_ITALIC
		MPrintString <"Error: No filename specified\n">
		MClearAttribute VATTR_ITALIC
		popa
		sys	KExit

.path_argument

		popa
		sys	KExit


		SECTION	"Variables",BSS_S
path		DS	STRING_SIZE

