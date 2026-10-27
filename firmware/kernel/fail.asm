		INCLUDE	"lowlevel/hc800.i"
		INCLUDE	"lowlevel/memory.i"
		INCLUDE	"lowlevel/nexys3.i"
		INCLUDE	"lowlevel/rc800.i"

		INCLUDE	"stdlib/stream.i"
		INCLUDE	"stdlib/string.i"

		INCLUDE	"mmu.i"
		INCLUDE	"text.i"
		INCLUDE	"video.i"
		INCLUDE	"uart_commands.i"


; --
; -- Fatal fault handling: the four fault vectors, the register dump,
; -- and the red-on-black fail screen.  Everything here runs in interrupt
; -- mode (the CPU enters fault handling with the interrupt state set and
; -- only leaves it on RETI, which the screen never performs).  Fetches
; -- and LCO resolve through the system code bank - the kernel code this
; -- unit lives in - so the messages are read from CODE with LCO; plain
; -- LD is the system data bank (main RAM) and must not be pointed at
; -- code space here.
; --
; -- Each vector stub leaves its vector byte in T and jumps to
; -- FailEntry through DE.  FailEntry dumps the fault over UART, then
; -- switches on the vector byte to pick the message string, and hands
; -- string pointer and faulting address to the screen.
; --

		SECTION "NMI",CODE[$8],ROOT
		ld	t,$08
		ld	de,FailEntry
		j	(de)

		SECTION "IllegalIrq",CODE[$10],ROOT
		ld	t,$10
		ld	de,FailEntry
		j	(de)

		SECTION "IllegalInstruction",CODE[$18],ROOT
		ld	t,$18
		ld	de,FailEntry
		j	(de)

		SECTION "StackOverflow",CODE[$20],ROOT
		ld	t,$20
		ld	de,FailEntry
		j	(de)


; --
; -- FailEntry: dump the vector byte and the faulting address over UART,
; -- then switch on the vector byte for the message string.  The stubs
; -- leave it in T; the register stacks are safe here - the faulting push
; -- was discarded, and wrapped pushes only clobber the dead program's
; -- oldest cells.
; --
; -- Inputs:
; --   t  - vector byte ($08, $10, $18 or $20)
; --   hl - faulting address (the entry saved the cancelled instruction's
; --        address here)
; --
		SECTION "FailEntry",CODE
FailEntry:
		di
		ld	f,0
		push	ft			; the selection below loads BC through T
		push	hl
		jal	ComPrintHexByte		; T = vector byte
		MDebugPrint <" vector crashed at ">
		pop	hl
		ld	ft,hl
		ld	de,ft			; DE = faulting address: FailScreen
						; prints it after the screen init
		exg	f,t			; T = high byte; ComPrintHexByte
		jal	ComPrintHexByte		; preserves FT (pusha/popa), so the
		exg	f,t			; second swap sees the original
		jal	ComPrintHexByte		; high:low split
		ld	t,10
		jal	ComPrintChar

		ld	f,$FF
		jal	SetHexSegments
		pop	ft			; T = vector byte again

		cmp	t,$08
		ld	bc,msgNmi
		j/eq	.selected
		cmp	t,$10
		ld	bc,msgInterrupt
		j/eq	.selected
		cmp	t,$18
		ld	bc,msgInstruction
		j/eq	.selected
		ld	bc,msgOverflow		; also catches anything unmatched
.selected:
		; fall through to the fail screen

; --
; -- Fatal fault screen: initializes the text screen with a black
; -- background and red foreground (attribute nibble $04 selects the
; -- palette pair 4=black / 5=red: the hardware paints glyph pixels
; -- with N^1 and the background with N), prints the fault message and
; -- the faulting address centered on the screen, and spins - terminal,
; -- never RETI: the cancelled instruction would fault again.  Even a
; -- stack-overflow fault left the other three stacks usable here: the
; -- faulting push was discarded, and wrapped pushes only clobber the
; -- dead program's oldest cells.
; --
; -- Inputs:
; --   bc - message string (code space), selected by FailEntry
; --   de - faulting address (FailEntry copies it out of HL, which the
; --        interrupt entry saved there and its JAL overwrites again)
; --

		; A fault can strike with any bank mapped: enter the
		; kernel configuration so the code, palette and attribute
		; windows sit where the text routines expect them.
		pusha
		ld	b,IO_MMU_BASE
		ld	c,IO_MMU_ACTIVE_INDEX
		ld	t,MMU_INDEX_PUSH|MMU_CFG_KERNEL
		lio	(bc),t
		popa

		; Screen in red on black.  The string pointer is parked
		; on the BC register stack first: the attribute call
		; claims BC, and every routine below is pusha/popa, so
		; nothing else needs saving across them.
		push	bc
		jal	InitializePalette
		jal	TextInitialize
		ld	b,$F0
		ld	c,$04
		jal	TextSetAttributes
		jal	TextClearScreen
		pop	bc			; message pointer back

		; Center the line: message + " at $" + 4 hex digits.
		; The cursor call takes its arguments in BC, so the string
		; pointer rides on the register stack across it.
		push	bc
		lco	t,(bc)			; message length
		add	t,5+4
		ld	f,t
		ld	t,CHARS_PER_LINE
		sub	t,f
		ld	f,0
		rs	ft,1
		ld	b,t
		ld	c,LINES_ON_SCREEN/2
		jal	TextSetCursor
		pop	bc			; string pointer back
		ld	ft,bc
		jal	outString			; message
		ld	ft,msgAt
		jal	outString
		ld	t,d			; faulting address
		jal	outHexByte
		ld	t,e
		jal	outHexByte
.spin		j	.spin


; -- Emit a length-prefixed string through the raw text console -
; -- not the editor's ScreenStringOut, whose insertions land in the
; -- editor line model and only reach the screen on a VBlank render.
; -- Inputs: ft - string in code space (read with LCO: this runs in
; -- interrupt mode, where plain LD is the data bank).  Preserves the
; -- cursor.
; --
; -- pusha/popa is not decoration: JAL parks the return address in HL, so
; -- a routine that calls out through HL has to keep the caller's address
; -- on the stack across its own calls.  TextWideCharOut is pusha/popa
; -- itself, so the loop needs no further saving.
outString:
		pusha
		ld	bc,ft
		lco	t,(bc)			; length
		ld	e,t
		add	bc,1
.loop		lco	t,(bc)
		add	bc,1
		ld	f,0
		jal	TextWideCharOut
		dj	e,.loop
		popa
		j	(hl)

; -- Emit one byte as two hex digits.  Inputs: t - byte.
outHexByte:
		pusha
		ld	d,t
		ld	f,0
		rs	ft,4
		jal	outDigit
		ld	t,$F
		and	t,d
		jal	outDigit
		popa
		j	(hl)

outDigit:
		pusha
		jal	DigitToAscii
		ld	f,0
		jal	TextWideCharOut
		popa
		j	(hl)


		; The fault messages, read from code space with LCO -
		; see the unit header; FailEntry's switch maps the
		; vector byte onto these.
		SECTION "FailMessages",CODE
msgNmi:		DC_STR	<"NMI">
msgInterrupt:	DC_STR	<"Illegal Interrupt">
msgInstruction:
		DC_STR	<"Illegal Instruction">
msgOverflow:	DC_STR	<"Stack Overflow">
msgAt:		DC_STR	<" at $">
