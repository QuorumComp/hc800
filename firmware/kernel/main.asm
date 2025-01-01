		INCLUDE	"lowlevel/hc800.i"
		INCLUDE	"lowlevel/math.i"
		INCLUDE	"lowlevel/memory.i"
		INCLUDE	"lowlevel/nexys3.i"
		INCLUDE	"lowlevel/stack.i"
		INCLUDE	"lowlevel/uart.i"

		INCLUDE	"stdlib/stream.i"
		INCLUDE	"stdlib/string.i"
		INCLUDE	"stdlib/syscall.i"

		INCLUDE	"blockdevice.i"
		INCLUDE	"editor.i"
		INCLUDE	"error.i"
		INCLUDE	"filesystems.i"
		INCLUDE	"keyboard.i"
		INCLUDE	"main.i"
		INCLUDE	"mmu.i"
		INCLUDE "sd.i"
		INCLUDE "text.i"
		INCLUDE "video.i"

		INCLUDE	"uart_commands.i"
		INCLUDE	"uart_commands_disabled.i"


		SECTION	"Main",CODE
Main:
		di

		; initialize kernel BSS to zeroes

		ld	bc,$0000
		ld	de,$4000
		ld	t,0
		jal	SetMemory

		jal	initializeMemory
		
		MStackInit 4096,BSS

		MDebugStacks
		MDebugPrint <"Initialize palette\n">
		jal	InitializePalette
		MDebugPrint <"Initialize keyboard\n">
		jal	KeyboardInitialize
		MDebugPrint <"Initialize text\n">
		jal	TextInitialize
		;MDebugPrint <"Initialize SD controller\n">
		;jal	SdResetController
		MDebugPrint <"Initialize block devices\n">
		jal	BlockDeviceInit
		MDebugPrint <"Initialize file systems\n">
		jal	FileInitialize
		MDebugStacks

		MDebugPrint <"Initialization done\n">

		sys	KClearScreen

		MPrintString "\n /// Quorum Computing HC800 ///\n"

		jal	printBoard

		MPrintString " RAM  : "
		ld	de,totalBanks
		ld	t,(de)
		ld	f,0
		ls	ft,4
		jal	StreamDecimalWordOut
		MPrintString " KiB\n"

		jal	EnableVBlank

		ei

.read_line
		jal	printReadyPrompt

		MStackAlloc STRING_SIZE
		ld	bc,ft

		MSetColor 2
		jal	ScreenEditLine
		MSetColor 0

	IF 0
		; print command line to screen
		ld	t,'"'
		sys	KCharacterOut
		jal	StreamBssStringOut
		ld	t,'"'
		sys	KCharacterOut
		ld	t,10
		sys	KCharacterOut
	ENDC

		ld	t,(bc)
		cmp	t,0
		j/eq	.read_line

		sys	KExecute
		j/eq	.no_error
		jal	ErrorPrintDescription
.no_error
		MStackFree STRING_SIZE
		;j	.read_line
		ld	hl,.read_line
		j	(hl)

printReadyPrompt:
		MSetAttribute VATTR_BOLD
		MPrintString "\nReady.\n"
		MClearAttribute VATTR_BOLD

		j	(hl)



initializeMemory:
		pusha

		ld	b,IO_MMU_BASE
		ld	c,IO_MMU_UPDATE_INDEX
		ld	t,MMU_CFG_KERNEL
		lio	(bc),t
		ld	c,IO_MMU_ACTIVE_INDEX
		lio	(bc),t

		; To determine the amount of free RAM:
		; 1. Write zeroes to four bytes of each possible 16 KiB bank
		; 2. For each bank:
		; 2.1. Check the four bytes are zero.
		; 2.2. Write a patten of $FF, $C3, $AA, $55 to the four bytes.
		; 2.3. Check the four bytes are the expected values.
		; 2.4. If 2.1 or 2.3 fails, this bank is invalid, the previous bank is the last one

		ld	de,$5000
		ld	c,IO_MMU_DATA_BANK1

		; Step 1

		ld	h,$80
.clear_loop	ld	t,h
		lio	(bc),t

		ld	t,0
		ld	(de+),t
		ld	(de+),t
		ld	(de+),t
		ld	(de),t
		ld	e,$00

		add	h,1
		cmp	h,0
		j/ne	.clear_loop

		; Step 2

		ld	h,$80
.bank_loop
		ld	b,IO_MMU_BASE
		ld	c,IO_MMU_DATA_BANK1
		ld	t,h
		lio	(bc),t

		; Step 2.1 - 2.4
		ld	bc,.pattern
		ld	de,$5000
		ld	l,4
.step_loop
		; Step 2.1, is it zero?
		ld	t,(de)
		cmp	t,0
		j/ne	.found_end

		; Step 2.2, store pattern byte
		lco	t,(bc)
		add	bc,1
		ld	(de),t

		; Step 2.3, read back pattern byte
		ld	f,t
		ld	t,(de+)
		cmp	f
		j/ne	.found_end

		; next byte
		dj	l,.step_loop

		; next bank
		add	h,1
		cmp	h,0
		j/nz	.bank_loop

.found_end	; h = last valid bank + 1

		sub	h,$80
		ld	t,h

		; t = number of valid banks

		ld	de,totalBanks
		ld	(de),t

		popa
		j	(hl)

.pattern	DB	$FF,$C3,$AA,$55

printBoard:
		pusha

		MPrintString " Board: "

		ld	b,IO_BOARD_ID_BASE
		ld	c,IO_BID_DESCRIPTION
		ld	d,128
.find_length	lio	t,(bc)
		cmp	t,0
		j/lt	.found_string
		dj	d,.find_length
		j	.not_found

.found_string	and	t,$7F
		ld	d,t
.next_char	ld	f,0
		lio	t,(bc)
		sys	KCharacterOut
		dj	d,.next_char
		j	.done

.not_found	MPrintString "Unknown"

.done		MNewLine
		popa
		j	(hl)


		SECTION	"Vars",BSS
totalBanks:	DS	1
commandLine:	DS	CHARS_PER_LINE*2+1	; max length of command line (two lines of characters plus length byte)
