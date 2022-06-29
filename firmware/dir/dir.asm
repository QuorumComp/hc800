		INCLUDE	"lowlevel/hc800.i"
		INCLUDE	"lowlevel/math.i"
		INCLUDE	"lowlevel/rc800.i"
		INCLUDE	"lowlevel/stack.i"

		INCLUDE	"stdlib/stream.i"
		INCLUDE	"stdlib/string.i"
		INCLUDE	"stdlib/syscall.i"

		SECTION	"Directory",CODE

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

		ld	bc,currentPath

.path_argument
		; bc = path
		ld	ft,dirInfo
		sys	KOpenDirectory
		j/eq	.print_dir

		ld	bc,dirInfo+dir_Error
		ld	t,(bc)
		sys	KPrintError
		j	.done

.print_dir	MPrintChar '"'
		ld	bc,dirInfo+dir_Filename
		jal	StreamBssStringOut
		MPrintChar '"'
		MNewLine

		ld	ft,dirInfo
		sys	KReadDirectory
		j/eq	.print_dir

.done		popa
		sys	KExit


		SECTION	"Variables",BSS_S
dirInfo		DS	dir_SIZEOF
path		DS	STRING_SIZE


		SECTION	"Data",DATA_S
currentPath	DC_STR	<"./">
