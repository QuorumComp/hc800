; ftstep - stepping probe for the byte accesses through the hub pointer.
;
; Fills a buffer through (ft+) stores and walks it back through (ft+)
; loads, comparing every byte against its expected position; then does
; one store and one load with an explicit walk-back to pin the
; non-stepping contract; then reads through the two hub-byte loads that
; move to $08/$09 when the rows gain the step.  A step missed in either
; direction shows up as a mismatch, and a cursor that steps twice lands
; off the pattern.  Per-byte comparison rather than a summed checksum:
; strictly stronger, and it names no register that FT shares.  The
; failure counter must print $0000.  An ordinary image program, so the
; same source builds and runs identically on the emulator and the board.
;
; One source, two encoders.  The assembler spells these accesses natively,
; so the default build emits exactly the bytes the FINAL=1 branch
; hand-encodes (byte-identical, verified 2026-11-13).  FINAL=1 is the
; independent witness: the DB bytes pin $22-$27 stores, $2A-$2F loads,
; $28/$29 hub loads and $61/$69 DI/EI without trusting the assembler.
;
; Three register-discipline traps shaped this file, all of them the
; machine being right and the program being wrong:
;
;  * Every compare goes through Check, which parks the cursor on the FT
;    stack first: CMP writes F - the flag byte, the high half of the
;    cursor - and a CMP against a byte register routes through T, the
;    low half.  The save must not name a pair: LD BC,FT would overwrite
;    the B being compared.
;  * The tests run inline as macros, not as JAL subroutines: JAL stores
;    the return address in HL, and the counter lives in HL.
;  * The counter is staged through memory before the final print: the
;    print macros are pusha/popa-wrapped, but a callee's LD R16 writes
;    the shared stack-top cell, so nothing inside survives to be
;    restored - HL especially, since the wrapped JAL rewrites it.

		INCLUDE	"lowlevel/hc800.i"
		INCLUDE	"lowlevel/rc800.i"
		INCLUDE	"stdlib/stream.i"
		INCLUDE	"stdlib/string.i"
		INCLUDE	"stdlib/syscall.i"

; Stepped FT accesses.  idx is the opcode's r8 field: 2=B 3=C 4=D 5=E
; 6=H 7=L - the byte-register cells of the two stepping rows.
StepStore:	MACRO	;reg,idx
		IF	_FTSTEP_FINAL
		DB	$20+(\2)		; native: store through FT and step it
		ELSE
		ld	(ft+),\1		; assembler spelling: same native byte
		ENDC
		ENDM

StepLoad:	MACRO	;reg,idx
		IF	_FTSTEP_FINAL
		DB	$28+(\2)		; native: load through FT and step it
		ELSE
		ld	\1,(ft+)		; assembler spelling: same native byte
		ENDC
		ENDM

; The hub-byte loads: the two accesses that cannot step.
LoadF:	MACRO
		IF	_FTSTEP_FINAL
		DB	$28			; LD F,(FT) lives at $28
		ELSE
		ld	f,(ft)		; assembler spelling: same native byte
		ENDC
		ENDM

LoadT:	MACRO
		IF	_FTSTEP_FINAL
		DB	$29			; LD T,(FT) lives at $29
		ELSE
		ld	t,(ft)		; assembler spelling: same native byte
		ENDC
		ENDM

Check:	MACRO	;reg,expected - count one failure unless reg = expected
		push	ft		; CMP rewrites both halves of FT: F directly, T by synthesis
		cmp	\1,\2
		j/eq	.ck\@
		add	hl,1
.ck\@		pop	ft
		ENDM

		SECTION	"Code",CODE

; Sixteen bytes of $01..$10 stored through FT as the cursor, then loaded
; back through it and compared one by one.  The walked cursor must end at
; exactly Buffer+16.
TestStepWalk:	MACRO
		ld	ft,Buffer
		ld	b,$01
		ld	c,16
.fill
		StepStore	b,2
		add	b,1
		dj	c,.fill

		ld	ft,Buffer
		StepLoad	b,2
		Check	b,$01
		StepLoad	c,3
		Check	c,$02
		StepLoad	d,4
		Check	d,$03
		StepLoad	e,5
		Check	e,$04
		StepLoad	b,2
		Check	b,$05
		StepLoad	c,3
		Check	c,$06
		StepLoad	d,4
		Check	d,$07
		StepLoad	e,5
		Check	e,$08
		StepLoad	b,2
		Check	b,$09
		StepLoad	c,3
		Check	c,$0A
		StepLoad	d,4
		Check	d,$0B
		StepLoad	e,5
		Check	e,$0C
		StepLoad	b,2
		Check	b,$0D
		StepLoad	c,3
		Check	c,$0E
		StepLoad	d,4
		Check	d,$0F
		StepLoad	e,5
		Check	e,$10
		ld	bc,Buffer+16	; the cursor walked the whole buffer and no further
		cmp	ft,bc		; CMP FT,R16 is native and sets the codes - SUB FT,R16 writes none
		j/eq	.walkdone
		add	hl,1
.walkdone
		ENDM

; One store and one load with an explicit walk-back: the stepped access
; plus SUB FT,1 is the plain contract by hand - the byte lands at the
; address FT held, FT ends where it started, and the second read sees
; the same byte.
TestPlainContract:	MACRO
		ld	ft,Plain
		ld	b,$7E
		StepStore	b,2
		add	ft,-1
		StepLoad	c,3
		add	ft,-1
		Check	c,$7E
		StepLoad	d,4		; reads the same byte again - FT stood still twice
		add	ft,-1
		Check	d,$7E
		ld	bc,Plain	; and the cursor is back where it began
		cmp	ft,bc
		j/eq	.plaindone
		add	hl,1
.plaindone
		ENDM

; The hub-byte loads cannot step - the byte is a half of the pointer it
; reads through - so they stay plain when the rows gain the step, and
; move to $08/$09.  Each check pins the address the load reads through:
; the byte below the wanted one is $00, so a stepping load shows up as a
; zero, not a false pass.  The loaded F must be copied to T before the
; compare: CMP writes F, the byte under test.
TestHubByteLoad:	MACRO
		ld	ft,Hub+$34
		LoadF			; F <- [$4034] = $EF
		ld	t,f
		cmp	t,$EF
		j/eq	.h1
		add	hl,1
.h1
		ld	ft,Hub+1
		LoadT			; T <- [$4001] = $CD
		cmp	t,$CD
		j/eq	.h2
		add	hl,1
.h2
		ENDM

Entry::
		ld	hl,0		; failure counter: every failed check adds one here
		IF	_FTSTEP_FINAL
		DB	$61			; di - native encoding, under RETI
		DB	$69			; ei - under DI
		ELSE
		di			; assembler spelling: same $61/$69 bytes
		ei
		ENDC
		TestStepWalk
		TestPlainContract
		TestHubByteLoad

		ld	de,Counter	; stage the counter: the print below eats every register.
		ld	t,l		; Stores carry only hub bytes through a general pair, and
		ld	(de+),t		; none through FT at all - so the counter rides T via DE.
		ld	t,h
		ld	(de+),t
		MPrintString <"ftstep failures expect $0000 = $">
		ld	ft,Counter	; reload the staged counter through FT
		StepLoad	l,7		; loads may name any byte register through FT
		StepLoad	h,6
		ld	ft,hl
		jal	StreamHexWordOut
		MNewLine
		sys	KExit

		SECTION	"Data",DATA_S
Buffer		DS	16
Plain		DS	1
Counter		DS	2
Hub:
		DB	$AB,$CD
		DS	$32
		DB	$EF			; Hub+$34
		DS	$0B
