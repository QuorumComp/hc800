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

.print_dir	ld	bc,dirInfo+dir_Flags
		ld	t,(bc)
		and	t,DFLAG_DIR
		cmp	t,0
		j/eq	.not_dir
		MPrintString "     [DIR] "
		j	.dir_done
.not_dir
		ld	bc,dirInfo+dir_Length
		MLoad32	ft,(bc)

		MPush32 ft
		jal	DecimalLongWidth
		neg	t
		add	t,10
		ld	e,t
		pop	ft
.spaces		MPrintChar ' '
		dj	e,.spaces		

		jal	StreamDecimalLongOut
		MPrintChar ' '

.dir_done
		MPrintChar '"'
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
