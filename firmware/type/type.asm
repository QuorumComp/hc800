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
		ld	ft,bc
		ld	bc,file

		sys	KOpenFile
		j/ne	.error

		ld	bc,file
		ld	de,char
.loop		ld	ft,1
		sys	KReadFile
		j/ne	.done

		ld	t,(de)
		sys	KCharacterOut
		j	.loop

.done		ld	ft,file
		sys	KCloseFile

		popa
		sys	KExit


.error		sys	KPrintError
		popa	
		sys	KExit



		SECTION	"Variables",BSS_S
path		DS	STRING_SIZE
file		DS	file_SIZEOF
char		DS	1
