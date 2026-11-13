; lcostep - stepping probe for the code and I/O byte rows (lco-step).
;
; Walks a code-space table through the three native stepped LCO cells, walks
; the video plane-0 scroll window through the stepped LIO cells in both
; directions (the registers read back what they were written, so the walk is
; pinned by device state, not just by the pointer), pins the synthesized-
; plain contract with explicit walk-backs, checks the two FT exception cells
; that must not step, checks the hub loads at $28/$29, and finishes by
; executing $08: that cell is deliberately illegal, so the kernel's
; illegal-instruction fail screen is the terminal pass marker.
;
; The counter line must print $0000; then the fail screen.  An ordinary image
; program, so the same source builds and runs identically on emulator and
; board.  Both fail screens name their faulting address.
;
; All lco-step cells are hand-encoded DB bytes, like ftstep's FINAL mode:
; the raw bytes pin $0D-$0F code loads, $31-$33 I/O stores, $35-$37 I/O
; loads, the $0C/$34 exceptions, the $28/$29 hub loads and the illegal $08
; without trusting the assembler at all.
;
; Register discipline inherited from ftstep, the machine being right and the
; program being wrong:
;
;  * Every compare goes through Check, which counts failures by leaking one
;    FT register-stack slot: the FT stack depth at the end IS the tally, so
;    no general pair needs to stay free for it - HL itself walks as a cursor
;    in one test, and CMP writes F, the flag byte, the high half of FT.
;  * The tests run inline as macros, not as JAL subroutines: JAL overwrites
;    the HL cursor some tests ride.  Where a failed cursor check applies,
;    the leak happens the same way Check does it.
;  * The counter is staged through memory before the final print: the print
;    macros are pusha/popa-wrapped and eat every register.
;
; The I/O window is plane 0's four scroll registers ($0511-$0514): writable,
; readable, and restoring zeros leaves the console exactly as it was.  The
; H registers keep only the bits they store (hPosH bits 1:0, vPosH bit 0), so
; the test values are chosen to survive the round trip.  RAM at $0511 carries
; a sentinel around the whole I/O sequence: a store that forgot the io
; qualifier lands on the sentinel and shows up as a mismatch.

		INCLUDE	"lowlevel/hc800.i"
		INCLUDE	"lowlevel/rc800.i"
		INCLUDE	"stdlib/stream.i"
		INCLUDE	"stdlib/string.i"
		INCLUDE	"stdlib/syscall.i"

; The native cells by their encodings.  reg is the pair named by
; the opcode's r16 field: 1=BC 2=DE 3=HL.
LcoStep:	MACRO	;reg,idx
		DB	$0C+(\2)		; lco t,(r16+): load a code byte, step the pair
		ENDM

LioStore:	MACRO	;reg,idx
		DB	$30+(\2)		; lio (r16+),t: store T to the device, step
		ENDM

LioLoad:	MACRO	;reg,idx
		DB	$34+(\2)		; lio t,(r16+): load from the device, step
		ENDM

Check:	MACRO	;reg,expected - count one failure unless reg = expected
		push	ft		; CMP rewrites both halves of FT: F directly, T by synthesis
		cmp	\1,\2
		j/ne	.ck\@		; failure: LEAK the slot - the FT stack depth is the tally
		pop	ft
.ck\@		ENDM

		SECTION	"Code",CODE

; The code-space table every LCO walk reads: sixteen bytes of $01..$10, in
; the CODE section so the loads ride the code qualifier.  A missed step
; repeats a byte, a double step skips one, and a load that lost the code
; qualifier reads RAM instead - where these addresses hold the program's own
; data, not this pattern.
TestLcoWalk:	MACRO
		ld	bc,LcoTable	; the BC cell walks the whole table
		LcoStep	bc,1
		Check	t,$01
		LcoStep	bc,1
		Check	t,$02
		LcoStep	bc,1
		Check	t,$03
		LcoStep	bc,1
		Check	t,$04
		LcoStep	bc,1
		Check	t,$05
		LcoStep	bc,1
		Check	t,$06
		LcoStep	bc,1
		Check	t,$07
		LcoStep	bc,1
		Check	t,$08
		LcoStep	bc,1
		Check	t,$09
		LcoStep	bc,1
		Check	t,$0A
		LcoStep	bc,1
		Check	t,$0B
		LcoStep	bc,1
		Check	t,$0C
		LcoStep	bc,1
		Check	t,$0D
		LcoStep	bc,1
		Check	t,$0E
		LcoStep	bc,1
		Check	t,$0F
		LcoStep	bc,1
		Check	t,$10
		ld	ft,LcoTable+16	; the cursor ended exactly past the table
		cmp	ft,bc
		j/eq	.w1		; pass skips the leak: failed cursor lands push a slot
		push	ft
.w1
		ld	de,LcoTable	; the DE cell walks its own pair
		LcoStep	de,2
		Check	t,$01
		LcoStep	de,2
		Check	t,$02
		LcoStep	de,2
		Check	t,$03
		LcoStep	de,2
		Check	t,$04
		ld	ft,LcoTable+4
		cmp	ft,de
		j/eq	.w2
		push	ft		; failed cursor end: leak a tally slot
.w2
		ld	hl,LcoTable+8	; the HL cell starts mid-table: the pair moves, not the offset
		LcoStep	hl,3
		Check	t,$09
		LcoStep	hl,3
		Check	t,$0A
		LcoStep	hl,3
		Check	t,$0B
		LcoStep	hl,3
		Check	t,$0C
		ld	ft,LcoTable+12
		cmp	ft,hl
		j/eq	.w3
		push	ft		; failed cursor end: leak a tally slot
.w3
		ENDM

; Four stepped stores down the scroll window, four stepped loads back up
; the same walk.  The values are chosen so each register reads back exactly
; what was written; if the step is missed anywhere the walk stacks writes on
; one register and the read-back mismatches.  The RAM sentinel at $0511
; proves the stores rode the io qualifier.
TestLioWalk:	MACRO
		ld	bc,$0511	; a sentinel in RAM at the window's address...
		ld	t,$5A
		ld	(bc),t		; ...through the synthesized plain store
		ld	b,$05
		ld	c,$11
		ld	t,$A5
		LioStore	bc,1	; hPosL <- $A5, pair steps
		ld	t,$03
		LioStore	bc,1	; hPosH <- $03 (only bits 1:0 are kept)
		ld	t,$5C
		LioStore	bc,1	; vPosL <- $5C, pair steps
		ld	t,$01
		LioStore	bc,1	; vPosH <- $01 (only bit 0 is kept)
		ld	ft,$0515	; the store walk ended one past the window
		cmp	ft,bc
		j/eq	.i1
		push	ft		; failed cursor end: leak a tally slot
.i1
		ld	bc,$0511	; the RAM sentinel survived: the stores went to the device
		ld	t,(bc)
		Check	t,$5A
		ld	b,$05
		ld	c,$11
		LioLoad	bc,1
		Check	t,$A5
		LioLoad	bc,1
		Check	t,$03
		LioLoad	bc,1
		Check	t,$5C
		LioLoad	bc,1
		Check	t,$01
		ld	ft,$0515	; and so did the load walk
		cmp	ft,bc
		j/eq	.i2
		push	ft		; failed cursor end: leak a tally slot
.i2
		ld	b,$05	; zero the window back out: the console must be
		ld	c,$11	; pristine no matter what happens next - in the
		ld	t,0	; control runs the very next test traps to the
		LioStore	bc,1	; kernel's fail screen, and a scrolled plane
		LioStore	bc,1	; would paint it invisibly off the top edge
		LioStore	bc,1
		LioStore	bc,1
		ENDM

; The synthesized-plain contract by hand: stepped access plus SUB R16,1 is
; the plain access - the byte comes from the address the pair held, the
; pair ends where it started, and a second read sees the same byte again.
; This is what the assembler emits for the plain spellings, so the probe
; pins the contract in both spaces.
TestPlainContract:	MACRO
		ld	b,$05
		ld	c,$11
		ld	t,$7E
		LioStore	bc,1	; park a known byte in hPosL
		ld	b,$05
		ld	c,$11
		LioLoad	bc,1
		sub	bc,1
		Check	t,$7E
		LioLoad	bc,1		; reads the same device byte again...
		sub	bc,1		; ...the pair ends exactly where it began
		Check	t,$7E
		ld	ft,$0511
		cmp	ft,bc
		j/eq	.p1
		push	ft		; failed cursor end: leak a tally slot
.p1
		ld	b,$05
		ld	c,$11
		ld	t,0
		LioStore	bc,1	; restore the console scroll
		ld	bc,LcoTable
		LcoStep	bc,1
		sub	bc,1
		Check	t,$01
		LcoStep	bc,1
		sub	bc,1
		Check	t,$01		; same code byte twice, pointer net-stationary
		ld	ft,LcoTable
		cmp	ft,bc
		j/eq	.p2
		push	ft		; failed cursor end: leak a tally slot
.p2
		ENDM

; The two FT exception cells: the loaded byte IS T, a half of the pointer a
; step would install, so these cells must not step.  The I/O side is fully
; self-pinning: hPosL is set to $11 first, so the delivered byte equals the
; pointer's low half, the pointer is byte-identical after the load, and any
; step at all walks off the $11 onto neighbouring scroll values.  The code
; side can only pin delivery - the load necessarily rewrites the pointer's
; low half with the delivered byte, so the cursor's fate there is pinned in
; RTL simulation instead.  EXG parks halves for the compares; CMP writes the
; very byte under test.
TestFtExceptions:	MACRO
		ld	b,$05
		ld	c,$11
		ld	t,$11
		LioStore	bc,1	; hPosL <- $11: the byte equals the pointer's low half
		ld	ft,$0511
		DB	$34			; lio t,(ft): T <- device[$0511] = $11
		Check	t,$11		; delivery...
		DB	$34			; ...and FT is (F<<8)|$11 = $0511 again: the same
		Check	t,$11		; address reads again iff the cell never stepped
		exg	t,f
		Check	t,$05		; the high half of the pointer survived untouched
		ld	b,$05
		ld	c,$11
		ld	t,0
		LioStore	bc,1	; restore hPosL

		ld	ft,LcoTable+8	; the code side: the $09 byte under the pointer.  Only
		DB	$0C			; delivery is pinnable here - the load necessarily
		Check	t,$09		; rewrites the pointer's low half with its own value,
		ENDM			; and the cursor's fate is pinned in RTL simulation.

; The hub loads: $28 = LD F,(FT), $29 = LD T,(FT), the r=0/r=1 exception
; cells of the stepped hub load row.  F's trip through EXG makes it
; comparable - CMP writes the byte under test.
TestHubHome:	MACRO
		ld	ft,HubBytes
		DB	$28			; ld f,(ft) -> F = $EF
		exg	t,f
		Check	t,$EF
		ld	ft,HubBytes+1
		DB	$29			; ld t,(ft) -> T = $CD
		Check	t,$CD
		ENDM

Entry::
		TestLcoWalk
		TestLioWalk
		TestPlainContract
		TestFtExceptions
		TestHubHome

		; The counter lives in the FT register stack: every failed check
		; leaves one leaked PUSH behind, so the depth is the count.  HL
		; cannot hold the sum across TestLcoWalk - the HL cell's own walk
		; makes HL the cursor - and the four stacks are independent, so
		; the leak counts even while BC, DE or HL ride pointers.
		ld	c,RC8_SP_FT
		lcr	t,(c)		; T = FT stack pointer ($FF - depth)
		ld	l,t
		ld	h,0
		ld	ft,$00FF
		sub	ft,hl		; FT = failures = $FF - SP

		ld	de,Counter	; stage the counter: the print below eats every register.
		ld	(de+),t		; low byte first (T is the low half of FT), high via EXG
		exg	t,f
		ld	(de+),t
		exg	t,f
		MPrintString <"lcostep failures expect $0000 = $">
		ld	ft,Counter	; reload the staged counter through FT
		DB	$2F			; ld l,(ft+) - stepped hub loads may name any byte register
		DB	$2E			; ld h,(ft+)
		ld	ft,hl
		jal	StreamHexWordOut
		MNewLine

		; The terminal witness: $08 is deliberately illegal and must trap
		; to the kernel's illegal-instruction vector, painting the red
		; fail screen over this line.  The key gate keeps the counter
		; readable until the operator is ready for the screen.
		MPrintString <"press any key for the $08 trap test">
.wait_key	sys	KCharacterIn
		j/z	.wait_key
		DB	$08
		sys	KExit

LcoTable	DB	$01,$02,$03,$04,$05,$06,$07,$08
		DB	$09,$0A,$0B,$0C,$0D,$0E,$0F,$10

		SECTION	"Data",DATA_S
Counter		DS	2
HubBytes	DB	$EF,$CD
