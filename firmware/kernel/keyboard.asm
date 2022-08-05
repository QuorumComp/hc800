		INCLUDE	"lowlevel/hc800.i"
		INCLUDE	"lowlevel/memory.i"
		INCLUDE	"lowlevel/rc800.i"
		INCLUDE	"lowlevel/scancodes.i"

		INCLUDE	"stdlib/stream.i"

		INCLUDE	"keyboard.i"

MATRIX_SIZE	EQU	128/8

		RSRESET
key_Ascii	RB	1
key_Counter	RB	1
key_SIZEOF	RB	0

REPEAT_INITIAL	EQU	20
REPEAT_SUB	EQU	3


		SECTION	"Keyboard",CODE


KeyboardInitialize:
		pusha

		ld	bc,KeyboardMatrix
		ld	de,MATRIX_SIZE+key_SIZEOF
		ld	t,0
		jal	SetMemory

		popa
		j	(hl)


; --
; -- VBlank service routine
; --
KeyboardVBlank:
		ld	bc,KeyRepeat+key_Counter
		ld	t,(bc)
		cmp	t,0
		j/z	.done
		sub	t,1
		ld	(bc),t

.done		j	(hl)


; --
; -- Read character from keyboard
; --
; -- Output:
; --    f - "nz" condition if character available
; --    t - ASCII character
; --
KeyboardRead:
		push	bc-hl

		ld	b,IO_KEYBOARD_BASE
		ld	c,IO_KEYBOARD_STATUS

		lio	t,(bc)
		cmp	t,0
		j/z	.repeat

		add	c,IO_KEYBOARD_DATA-IO_KEYBOARD_STATUS
		lio	t,(bc)

;		jal	StreamHexByteOut

		jal	updateMatrix

		cmp	t,0
		j/lt	.make

		jal	repeatStop

		ld	f,FLAGS_Z
		j	.exit

.repeat		jal	repeatKey
		j	.test_t

.make		and	t,$7F
		jal	scanCodeToAscii
		j/z	.exit

		jal	setupAsciiRepeat

.test_t		cmp	t,0

.exit		pop	bc-hl
		j	(hl)

; --
; -- Test if key is down
; --
; -- Inputs:
; --    t - scancode to test (no make/break flag)
; --
; -- Outputs:
; --    f - "nz" condition if key down
; --
isKeyDown:
		push	bc/de

		push	ft
		and	t,$7
		ld	e,t	; e = bit #
		ld	t,$01
		ls	ft,e
		ld	e,t	; e = bit mask
		pop	ft

		ld	f,0
		rs	ft,3	; t = byte index
		ld	bc,KeyboardMatrix
		add	ft,bc
		ld	t,(ft)
		and	t,e
		cmp	t,0

		pop	bc/de
		j	(hl)

; --
; -- Update keyboard matrix
; --
; -- Inputs:
; --    t - scan code including make/break bit
; --
updateMatrix:
		pusha

		push	ft
		and	t,$7
		ld	h,t	; h = bit #
		pop	ft

		push	ft

		ld	l,0
		cmp	t,0
		ld/lt	l,1	; l = bit value (make = $01 / break = $00)
		ld	t,l
		ls	ft,h
		ld	l,t	; l = bit mask

		ld	ft,$00FE
		ls	ft,h
		or	t,f
		ld	e,t	; e = remove bit mask

		pop	ft

		and	t,$7F
		ld	f,0
		rs	ft,3	; t = byte index

		ld	bc,KeyboardMatrix
		add	ft,bc
		ld	bc,ft
		ld	t,(bc)
		and	t,e
		or	t,l
		ld	(bc),t

		popa
		j	(hl)

; --
; -- Repeat last ASCII code
; --
; -- Outputs:
; --    t - ASCII (zero if no key)
; --
repeatKey:
		push	hl

		ld	hl,KeyRepeat+key_Counter
		ld	t,(hl)
		cmp	t,0
		j/nz	.no_repeat

		ld	t,REPEAT_SUB
		ld	(hl),t

		sub	hl,1
		ld	t,(hl)
		j	.repeat

.no_repeat	ld	t,0
.repeat		pop	hl
		j	(hl)


; --
; -- Stop repeating keys
; --
repeatStop:
		push	ft/hl

		ld	hl,KeyRepeat
		ld	t,0
		ld	(hl),t

		pop	ft/hl
		j	(hl)


; --
; -- Setup key repeating
; --
; -- Inputs:
; --    t - ASCII code
; --
setupAsciiRepeat:
		push	ft/hl

		jal	isAsciiRepeating
		ld/nz	t,0

		ld	hl,KeyRepeat
		ld	(hl),t
		add	hl,1
		ld	t,REPEAT_INITIAL
		ld	(hl),t

		pop	ft/hl
		j	(hl)


; --
; -- Determine if key is a repeating key
; --
; -- Inputs:
; --    t - ASCII code
; --
; -- Outputs:
; --    f - "z" condition if repeating key
; --
isAsciiRepeating:
		push	bc/de

		ld	de,.keys
		ld	b,t
		ld	c,.keys_end-.keys

.check		lco	t,(de)
		add	de,1
		cmp	t,b
		j/eq	.done
		dj	c,.check

.done		pop	bc/de
		j	(hl)

.keys		DB	KEY_LEFT
		DB	KEY_RIGHT
		DB	KEY_UP
		DB	KEY_DOWN
		DB	KEY_DELETE
		DB	KEY_BACKSPACE
		DB	' '
.keys_end


; --
; -- Convert scancode to ASCII, taking modifier keys into account
; --
; -- Inputs:
; --    t - scancode (no make/break flag)
; --
; -- Outputs:
; --    t - ASCII character
; --    f - "nz" condition if character valid
; --
scanCodeToAscii:
		push	hl

		cmp	t,$60
		j/ltu	.valid_key
		ld	f,FLAGS_Z
		j	.exit

.valid_key	jal	getKeyboardState

		ld	f,0
		add	ft,bc
		lco	t,(ft)
		cmp	t,0

.exit		pop	hl
		j	(hl)

; --
; -- Get current keyboard modifier state
; --
; -- Outputs:
; --   bc - table
; --
getKeyboardState:
		push	ft/hl

		jal	getExtendShiftState
		j/nz	.extendShift

		jal	getShiftState
		j/nz	.shift

		jal	getSymbolShiftState
		j/nz	.symbol

		jal	getCapsLockState
		j/nz	.capsLock

		jal	getExtendState
		j/nz	.extend

		ld	bc,.table_00

.done		pop	ft/hl
		j	(hl)

.shift		ld	bc,.table_01
		j	.done

.symbol		ld	bc,.table_02
		j	.done

.capsLock	ld	bc,.table_03
		j	.done

.extend		ld	bc,.table_04
		j	.done

.extendShift	ld	bc,.table_05
		j	.done


.table_00	; Regular
		DB	$00, $01, $02, $00, $04, $05, $06, $00, $08, $09, $0A, $00, $00, $00, $0E, $00
		DB	$10, $00, $12, $13, $14, $15, $16, $17, $18, $19, $00, $1B, $1C, $1D, $00, $00
		DB	' ', $00, '"', $00, $00, $00, $00, $00, $00, $00, $00, $00, ',', $00, '.', '/'
		DB	'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', $00, ';', $00, $00, $00, $00
		DB	$00, 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o'
		DB	'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', $00, $00, $00, $00, $00

.table_01	; + Shift
		DB	$00, $00, $02, $00, $00, $00, $06, $00, $04, $00, $0A, $00, $00, $00, $0E, $00
		DB	$10, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		DB	' ', $00, 147, $00, $00, $00, $00, $00, $00, $00, $00, $00, 145, $00, 133, '?'
		DB	'_', '!', '@', '#', '$', '%', '&', '\'', '(', ')', $00, ':', $00, $00, $00, $00
		DB	$00, 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O'
		DB	'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', $00, $00, $00, $00, $00

.table_02	; + Symbol
		DB	$00, $00, $02, $00, $00, $00, $06, $00, $08, $00, $0A, $00, $00, $00, $0E, $00
		DB	$10, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		DB	' ', $00, 148, $00, $00, $00, $00, $00, $00, $00, $00, $00, 146, $00, 149, $00
		DB	'_', 161, '@', '#', 162, 137, '&', '`', '(', ')', $00, ';', $00, $00, $00, $00
		DB	$00, '~', '*', '?', '\\', 128, '\{', '\}', '^', 191, '-', '+', '=', $B1, 247, $B0
		DB	182, 187, '<', '|', '>', ']', '/', 171, 163, '[', ':', $00, $00, $00, $00, $00

.table_03	; Caps lock
		DB	$00, $00, $02, $00, $00, $00, $06, $00, $08, $00, $0A, $00, $00, $00, $0E, $00
		DB	$10, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		DB	' ', $00, '"', $00, $00, $00, $00, $00, $00, $00, $00, $00, ',', $00, '.', $00
		DB	'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', $00, ';', $00, $00, $00, $00
		DB	$00, 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O'
		DB	'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', $00, $00, $00, $00, $00

.table_04	; Extend
		DB	$00, $00, $01, $00, $00, $00, $05, $00, $0C, $00, $0A, $00, $00, $00, $06, $00
		DB	$01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		DB	$00, $00, $A8, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		DB	$BA, $B9, $B2, $B3, '4', '5', '6', '7', '8', '9', $00, $00, $00, $00, $00, $00
		DB	$00, $E5, 'B', $E7, $F0, $E9, 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', $F1, $F8
		DB	'P', $E6, 'R', $DF, $DE, $FC, 'V', 'W', 'X', $FF, $9E, $00, $00, $00, $00, $00

.table_05	; Extend+shift
		DB	$00, $00, $01, $00, $00, $00, $05, $00, $0C, $00, $0A, $00, $00, $00, $06, $00
		DB	$01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		DB	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		DB	$BA, $B9, $B2, $B3, '4', '5', '6', '7', '8', '9', $00, $00, $00, $00, $00, $00
		DB	$00, $C5, 'B', $C7, $D0, $C9, 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', $D1, $D8
		DB	'P', $C6, 'R', $DF, $FE, $DC, 'V', 'W', 'X', $9F, $8E, $00, $00, $00, $00, $00


getShiftState:
		push	hl

		ld	t,KEY_LSHIFT
		jal	isKeyDown
		j/nz	.down

		ld	t,KEY_RSHIFT
		jal	isKeyDown

.down
		pop	hl
		j	(hl)


getExtendShiftState:
		push	hl

		jal	getShiftState
		j/z	.not_down

		ld	t,KEY_EXTEND
		jal	isKeyDown

.not_down	pop	hl
		j	(hl)


getSymbolShiftState:
		ld	t,KEY_SYM_SHIFT
		j	getCommonState

getExtendState:
		ld	t,KEY_EXTEND
		j	getCommonState

getCapsLockState:
		ld	t,KEY_CAPS_LOCK

getCommonState	push	hl
		jal	isKeyDown

		pop	hl
		j	(hl)


		SECTION	"KeyboardVars",BSS

KeyboardMatrix:	DS	128/8
KeyRepeat:	DS	key_SIZEOF
