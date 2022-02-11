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

		ld	ft,dirInfo
		ld	bc,path
		sys	KOpenDirectory
		j/ne	.error

.print_dir	ld	bc,dirInfo+dir_Filename
		jal	StreamBssStringOut
		MNewLine

		ld	ft,dirInfo
		sys	KReadDirectory
		j/eq	.print_dir

.error		popa
		sys	KExit


		SECTION	"Variables",BSS_S
dirInfo		DS	dir_SIZEOF


		SECTION	"Data",DATA_S
path		DC_STR	<".">
