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

		ld	bc,dirInfo
		ld	de,path
		sys	KOpenDirectory
		j/ne	.error

.print_dir	add	bc,dir_Filename
		jal	StreamBssStringOut
		MNewLine

		sub	bc,dir_Filename
		sys	KReadDirectory
		j/eq	.print_dir

.error		popa
		sys	KExit


		SECTION	"Variables",BSS_S
dirInfo		DS	dir_SIZEOF


		SECTION	"Data",DATA_S
path		DC_STR	<".">
