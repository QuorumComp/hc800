		INCLUDE	"lowlevel/hc800.i"
		INCLUDE	"lowlevel/memory.i"
		INCLUDE	"lowlevel/nexys3.i"
		INCLUDE	"lowlevel/rc800.i"
		INCLUDE	"lowlevel/scancodes.i"

		INCLUDE	"stdlib/string.i"
		INCLUDE	"stdlib/syscall.i"

		INCLUDE	"editor.i"
		INCLUDE	"keyboard.i"
		INCLUDE	"text.i"

		INCLUDE	"uart_commands.i"
		INCLUDE	"uart_commands_disabled.i"

		IMPORT	ResetWhenCombo

		SECTION	"Editor",CODE

ScreenInitialize:
		pusha
		jal	TextClearScreen
		jal	InitializeLines

		ld	t,0
		ld	bc,isInsert
		ld	(bc),t

		popa
		j	(hl)

; -- Invoke screen editor and copy entered line
; --
; -- Input:
; --   bc - Destination line buffer. Must be at least 207 bytes. Result is a Pascal string.
ScreenEditLine:
		pusha

		push	bc

		ld	bc,isInsert
		ld	t,(bc)
		push	ft
		ld	t,1
		ld	(bc),t

		jal	restartCursor
.loop		jal	handleKeyboardInput
		j/z	.done
		jal	blinkCursor
		j	.loop

.done		pop	bc
		jal	copyAcceptedLine

		ld	bc,isInsert
		ld	t,(bc)
		j/z	.is_insert

		ld	t,0
		ld	(bc),t

.is_insert	jal	keyReturn

		pop	ft
		ld	bc,isInsert
		ld	(bc),t

		popa
		j	(hl)

copyAcceptedLine:
		push	hl

		; bc = string
		jal	StringClear
		push	bc

		jal	getVirtualCursorPos
		push	ft
		ld	f,0
		jal	TextGetAttributePointer
		ld	de,ft
		pop	ft

		; de - attribute pointer

		ld	f,0
		add	ft,lineLengths
		ld	h,(ft)

		; h - line length

		; skip spaces
.skip		cmp	h,0
		j/eq	.line_done
		push	hl
		jal	.getNextCharacter
		pop	hl
		sub	h,1
		cmp	t,' '
		j/leu	.skip

		; done skipping spaces
		; t - next character
		; h - remaining line length
		pop	bc
		add	bc,1
		push	bc

.copy		ld	(bc+),t
		MDebugHexByte t

		;pusha
		;ld	bc,0
		;MDebugMemory bc,8
		;popa

		cmp	h,0
		j/z	.line_done
		push	hl
		jal	.getNextCharacter
		pop	hl
		sub	h,1
		j	.copy

.line_done
		MDebugNewLine
		; length byte

		ld	ft,bc
		pop	bc
		sub	ft,bc
		sub	bc,1
		ld	(bc),t

		MDebugMemory bc,8

		jal	StringTrimRight

		pop	hl
		j	(hl)

; -- Inputs:
; --   de - attribute pointer
; --
; -- Outputs:
; --   de - attribute pointer, next character
; --    t - character
.getNextCharacter:
		ld	t,(de)
		add	de,2
		cmp	e,CHARS_PER_LINE*2
		j/leu	.done
		ld	e,0
		add	d,1
.done		cmp	t,' '
		ld/ltu	t,' '
		j	(hl)


InitializeLines:
		pusha

		ld	bc,lineLengths
		ld	de,LINES_ON_SCREEN
		ld	t,0
		jal	SetMemory

		popa
		j	(hl)

; --
; -- Read keyboard and handle key press
; --
; -- Outputs:
; --    f - "z" condition if RETURN pressed
; --
handleKeyboardInput:
		push	hl

		jal	KeyboardRead
		j/z	.exit_f

.char_out	push	ft
		jal	insertCharacter
		pop	ft
		cmp	t,KEY_RETURN
		j	.exit

.exit_f		ld	f,FLAGS_NZ
.exit		pop	hl
		j	(hl)

insertCharacter:
		push	hl

		jal	commonCharacterOut
		jal	restartCursor

		pop	hl
		j	(hl)

; --
; -- Print data string
; --
; -- Inputs:
; --   ft - string
; --
ScreenStringOut:
		pusha

		ld	bc,ft
		lco	t,(bc)
		ld	d,t
		add	bc,1

		add	d,1
		j	.start
.loop		lco	t,(bc)
		add	bc,1
		jal	ScreenCharacterOut
.start		dj	d,.loop

		popa
		j	(hl)

		SECTION	"ScreenHexWordOut",CODE
ScreenHexWordOut:
		pusha

		exg	f,t
		jal	ScreenHexByteOut
		exg	f,t
		jal	ScreenHexByteOut

		popa
		j	(hl)


; -- Print value as hexadecimal
; --
; -- Inputs:
; --    t - value to print
		SECTION	"ScreenHexByteOut",CODE
ScreenHexByteOut:
		pusha

		ld	d,t

		ld	f,0
		rs	ft,4
		jal	ScreenDigitOut

		ld	t,$F
		and	t,d
		jal	ScreenDigitOut

		popa
		j	(hl)

; -- Print single digit
; --
; --    t - digit ($0-$F)
		SECTION	"ScreenDigitOut",CODE
ScreenDigitOut:
		pusha

		jal	DigitToAscii
		jal	ScreenCharacterOut

		popa
		j	(hl)




; --
; -- Print character
; --
; -- Inputs:
; --   t - character (incl. control codes)
; --
		SECTION	"ScreenCharacter",CODE
ScreenCharacterOut:
		pusha

		cmp	t,KEY_RETURN
		j/eq	.linefeed

		jal	commonCharacterOut
		j	.exit

.linefeed	jal	keyReturn

.exit		popa
		j	(hl)

commonCharacterOut:
		pusha

		cmp	t,' '
		j/geu	.print_char

		; control char
		add	t,t
		ld	b,0
		ld	c,t
		add	bc,.control_jump+1

		lco	t,(bc)
		sub	bc,1
		exg	f,t
		lco	t,(bc)
		ld	bc,ft

		tst	bc
		j/z	.exit

		jal	(bc)
		j	.exit

.print_char	ld	f,0
		jal	insertCharacterAtCursor

.exit		popa
		j	(hl)

.control_jump
		DW	0
		DW	keyHome
		DW	keyLeft
		DW	0
		DW	keyDelete
		DW	KeyEnd
		DW	keyRight
		DW	0
		DW	keyBackspace
		DW	keyTab
		DW	0 ;keyReturn
		DW	0
		DW	keyFormFeed
		DW	0
		DW	keyDown
		DW	0
		DW	keyUp
		DW	0
		DW	keyF1
		DW	keyF2
		DW	keyF3
		DW	keyF4
		DW	keyF5
		DW	keyF6
		DW	keyF7
		DW	keyF8
		DW	0
		DW	keyEscape
		DW	keyF9
		DW	keyF10
		DW	keyF11
		DW	keyF12
		
moveCursor:
		pusha

		jal	hideCursor

		jal	TextGetCursor
		add	t,c
		exg	f,t
		add	t,b

		; f = new y
		; t = new x

		push	ft
		ld	d,0

		cmp	t,0
		j/ge	.left_ok
		add	t,CHARS_PER_LINE
		ld	d,-1	; move y up
		j	.check_y
.left_ok	cmp	t,CHARS_PER_LINE
		j/lt	.check_y
		sub	t,CHARS_PER_LINE
		ld	d,1	; move y down

.check_y	ld	b,t	; save new x pos

		pop	ft
		exg	f,t
		add	t,d

		cmp	t,0
		j/ge	.no_scroll_down

		jal	scrollScreenDown
		ld	t,0
		j	.exit

.no_scroll_down	cmp	t,LINES_ON_SCREEN
		j/lt	.exit		; skip if cursor doesn't move down

		jal	scrollScreenUp
		ld	t,LINES_ON_SCREEN-1

.exit		ld	c,t		; new y pos

		jal	TextSetCursor
		jal	restartCursor

		popa
		j	(hl)


scrollScreenDown:
		pusha

		ld	t,0
		jal	TextScrollLinesDown
		jal	scrollLinesLengthsDown
		ld	bc,lineLengths
		ld	(bc),t

		popa
		j	(hl)


scrollScreenUp:
		pusha

		ld	t,0
		jal	TextScrollLinesUp
		jal	scrollLinesLengthsUp

		popa
		j	(hl)


; -- Outputs
; --
; --    f = "eq" condition if true
isCursorOnFirstVirtualCharacter:
		push	hl

		jal	getVirtualCursorPos
		cmp	f,0

		pop	hl
		j	(hl)


; -- Outputs
; --
; --    f = "eq" condition if true
isCursorOnFirstLine:
		push	hl

		jal	TextGetCursor
		cmp	t,0

		pop	hl
		j	(hl)


; -- Outputs
; --
; --    f = "eq" condition if true
isCursorOnLastLine:
		push	hl

		jal	TextGetCursor
		cmp	t,LINES_ON_SCREEN-1

		pop	hl
		j	(hl)


hideCursor:
		pusha

		ld	b,VATTR_UNDERLINE
		ld	c,$00
		jal	TextSetAttributesAtCursor

		popa
		j	(hl)


keyFormFeed:
		pusha
		jal	TextClearScreen
		jal	InitializeLines
		popa
		j	(hl)

keyHome:	push	ft/bc/hl

		jal	hideCursor

		jal	getVirtualCursorPos
		ld	bc,ft
		cmp	b,0
		j/nz	.line_home

		; move to top of screen when X = 0
		ld	bc,VideoCursor+csr_X
		ld	t,0
		ld	(bc),t
		add	bc,csr_Y-csr_X
		ld	(bc),t
		j	.done

.line_home	; move to beginning of virtual line

		ld	hl,VideoCursor+csr_X
		ld	t,0
		ld	(hl),t

		cmp	b,CHARS_PER_LINE
		j/ltu	.done

		add	hl,csr_Y-csr_X
		ld	t,(hl)
		sub	t,1
		ld	(hl),t

.done		jal	restartCursor

		pop	ft/bc/hl
		j	(hl)


keyLeft:	push	hl

		ld	b,-1
		ld	c,0
		jal	moveCursor

		pop	hl
		j	(hl)


keyRight:	push	hl

		ld	b,1
		ld	c,0
		jal	moveCursor

		pop	hl
		j	(hl)


keyDown:	push	hl

		ld	b,0
		ld	c,1
		jal	moveCursor

		pop	hl
		j	(hl)

keyUp:		push	hl

		ld	b,0
		ld	c,-1
		jal	moveCursor

		pop	hl
		j	(hl)


keyDelete:
		push	hl

		jal	hideCursor
		jal	deleteCharacterAtCursor
		jal	restartCursor

		pop	hl
		j	(hl)


KeyEnd:		j	(hl)


keyBackspace:	push	hl

		jal	isCursorOnFirstVirtualCharacter
		j/eq	.skip

		ld	b,-1
		ld	c,0
		jal	moveCursor
		jal	keyDelete

.skip
		pop	hl
		j	(hl)


keyTab:
		push	hl

		jal	TextGetCursor
		ld	t,f
		cmp	t,CHARS_PER_LINE-8
		j/geu	.dont_move

		and	t,7
		sub	t,8
		neg	t

		ld	b,t
		ld	c,0
		jal	moveCursor

.dont_move	pop	hl
		j	(hl)


keyReturn:	pusha

		jal	getVirtualCursorPos

		ld	de,ft

		ld	f,0
		ld	bc,lineLengths
		add	ft,bc
		ld	t,(bc)

		ld	c,1

		cmp	t,CHARS_PER_LINE
		j/leu	.short			; it's a short line (not pair)

		ld	t,CHARS_PER_LINE-1
		cmp	t,d
		j/leu	.last		; on the last line of a pair

		; first line of pair
		add	c,1
.short
.last
		ld	b,0
		jal	moveCursor

		; insert empty line

		ld	bc,VideoCursor+csr_X
		ld	t,0
		ld	(bc),t
		add	bc,csr_Y-csr_X
		ld	t,(bc)

		ld	de,ft

		ld	bc,isInsert
		ld	t,(bc)
		cmp	t,0
		j/z	.no_insert

		ld	ft,de
		jal	TextScrollLinesDown
		jal	scrollLinesLengthsDown
		ld	f,0
		ld	bc,lineLengths
		add	ft,bc
		ld	b,0
		ld	(ft),b

.no_insert	popa	
		j	(hl)

keyF1:		j	(hl)

keyF2:		j	(hl)

keyF3:		j	(hl)

keyF4:		j	(hl)

keyF5:		j	(hl)

keyF6:		j	(hl)

keyF7:		j	(hl)

keyF8:		j	(hl)

keyEscape:	j	(hl)

keyF9:		j	(hl)

keyF10:
	IF 0
		push	hl
		jal	printLineLengths
		pop	hl
	ENDC
		j	(hl)

keyF11:		j	(hl)

keyF12:		j	(hl)

		SECTION	"PrintLineLengths",CODE
printLineLengths:
		pusha

		ld	bc,lineLengths
		ld	de,$C000
		ld	l,LINES_ON_SCREEN
.loop		push	hl
		ld	t,(bc)

		push	ft
		ld	f,0
		rs	ft,4
		jal	DigitToAscii
		ld	(de),t
		add	de,1
		ld	t,0
		ld	(de),t
		add	de,1
		pop	ft

		and	t,$F
		jal	DigitToAscii
		ld	(de),t
		add	de,1
		ld	t,0
		ld	(de),t
		add	d,1
		ld	e,0

		add	bc,1
		pop	hl
		dj	l,.loop

		popa
		j	(hl)
		

; --
; -- Delete character at cursor position
; --
; -- Outputs:
; --    f - non-zero if successful
; --
		SECTION	"DeleteCharacterAtCursor",CODE
deleteCharacterAtCursor:
		pusha
		jal	hideCursor

		jal	getVirtualCursorPos
		ld	bc,ft

		jal	deleteCharacterAtVirtualCursorPos

		jal	decreaseLineLength

		jal	restartCursor

		popa
		j	(hl)


; --
; -- Inserts a character at cursor position
; --
; -- Inputs:
; --   ft - character
; --
; -- Outputs:
; --    f - non-zero if successful
; --
insertCharacterAtCursor:
		ld	de,ft

		jal	hideCursor

		ld	ft,isInsert
		ld	t,(ft)
		cmp	t,0
		j/nz	.insert

		; overwrite
		jal	getVirtualCursorPos
		add	f,1
		jal	setLineLength

		ld	ft,de
		jal	TextSetWideChar

		jal	keyRight
		j	.done

.insert		jal	getVirtualCursorPos
		ld	bc,ft

		jal	increaseLineLength
		j/ne	.done	; no insert

		ld	ft,de
		jal	insertCharacterAtVirtualCursorPos

		jal	keyRight

.done		jal	restartCursor

		popa
		j	(hl)

; ft - character
;  b - virtual x
;  c - virtual y
insertCharacterAtVirtualCursorPos:
		pusha
		push	ft

		push	bc
		ld	b,0
		add	bc,lineLengths
		ld	t,(bc)
		pop	bc

		cmp	t,CHARS_PER_LINE
		j/leu	.short			; it's a short line (not pair)

		cmp	b,CHARS_PER_LINE-1
		j/gtu	.long_last		; on the last line of a pair

		; on the first line of a pair

		ld	f,CHARS_PER_LINE-1
		ld	t,c
		jal	TextGetCharacterAt

		push	bc
		ld	b,0
		add	c,1
		jal	insertCharacterOnLine
		pop	bc

		j	.exit

.long_last
		; on the last line of a pair

		sub	b,CHARS_PER_LINE
		add	c,1

		j	.exit

.short
		; short line (not pair)		

.exit
		pop	ft
		jal	insertCharacterOnLine

		popa
		j	(hl)


;  b - virtual x
;  c - virtual y
deleteCharacterAtVirtualCursorPos:
		pusha

		push	bc
		ld	b,0
		ld	ft,lineLengths
		add	ft,bc
		ld	t,(ft)
		pop	bc

		cmp	t,b
		j/leu	.exit			; delete character after line end

		cmp	t,CHARS_PER_LINE
		j/leu	.short			; it's a short line (not pair)

		cmp	b,CHARS_PER_LINE-1
		j/gtu	.long_last		; on the last line of a pair

		; on the first line of a pair

		ld	ft,bc
		jal	TextDeleteCharacter

		ld	f,0
		ld	t,c
		add	t,1
		jal	TextGetCharacterAt

		push	bc
		ld	b,CHARS_PER_LINE-1
		jal	TextSetCharacterAt
		pop	bc

		add	c,1
		ld	b,0

		j	.short

.long_last	; on the last line of a pair

		sub	b,CHARS_PER_LINE
		add	c,1

.short		; short line (not pair)		
		ld	ft,bc
		jal	TextDeleteCharacter

.exit		popa
		j	(hl)


; --
; -- Decrease line length, so it is at least equal to cursor pos.
; -- May delete a line that has become empty
; --
; -- Inputs:
; --   f - virtual X pos, adjusted for line pairs
; --   t - line index, adjusted for line pairs
; --
decreaseLineLength:
		push	bc-hl

		ld	de,ft

		ld	bc,lineLengths
		ld	f,0
		add	ft,bc
		ld	bc,ft
		ld	t,(bc)
		cmp	t,d
		j/leu	.done	; line length is less than cursor pos, do nothing

		sub	t,1
		ld	(bc),t

		cmp	t,CHARS_PER_LINE-1
		j/ne	.done

		; a line has become empty

		add	e,1
		ld	t,e
		jal	TextScrollLinesUp
		ld	t,e
		jal	scrollLinesLengthsUp

.done		pop	bc-hl
		j	(hl)


; --
; -- Set line length, so it is at least equal to cursor pos.
; -- Does not insert an empty line
; --
; -- Inputs:
; --   f - virtual X pos, adjusted for line pairs
; --   t - line index, adjusted for line pairs
; --
setLineLength:
		push	bc-hl

		ld	de,ft

		ld	b,0
		ld	c,t
		add	bc,lineLengths
		ld	t,(bc)
		cmp	t,d
		j/geu	.no_insert

		ld	t,d
		ld	(bc),t

.no_insert	pop	bc-hl
		j	(hl)


; --
; -- Increase line length, so it is at least equal to cursor pos.
; -- May insert an empty line
; --
; -- Inputs:
; --   f - virtual X pos, adjusted for line pairs
; --   t - line index, adjusted for line pairs
; --
; -- Outputs:
; --   z - "eq" condition if insert allowed
; --
increaseLineLength:
		push	bc-hl

		ld	de,ft

		ld	b,0
		ld	c,t
		add	bc,lineLengths
		ld	t,(bc)
		cmp	t,CHARS_PER_LINE*2
		j/ltu	.insert_char

		ld	f,FLAGS_NE
		j	.no_insert

.insert_char	cmp	t,d		; f = lineLength < cursorX
		ld/ltu	t,d
		add	t,1
		ld	(bc),t		; t = new line length

		cmp	t,CHARS_PER_LINE	; should line be inserted?
		j/ne	.allow_insert

		cmp	e,LINES_ON_SCREEN-1	; on the last line?
		j/ne	.insert			; no

		ld	f,FLAGS_NE
		j	.no_insert

.insert		add	e,1
		ld	t,e
		jal	TextScrollLinesDown
		ld	t,e
		jal	scrollLinesLengthsDown

.allow_insert
		ld	f,FLAGS_EQ

.no_insert	pop	bc-hl
		j	(hl)


; --
; -- Insert empty line in line length table. It is assumed that the line to
; -- insert is the second line of a pair or a single line
; --
; -- Inputs:
; --    t - line number
; --
scrollLinesLengthsDown:
		pusha

		ld	b,0
		ld	c,t
		add	bc,lineLengths+LINES_ON_SCREEN-2

		sub	t,LINES_ON_SCREEN-1
		cmp	t,0
		j/ge	.skip
		neg	t
		ld	f,t
		add	f,1

.loop		ld	t,(bc)
		add	bc,1
		ld	(bc),t
		sub	bc,2
		dj	f,.loop

.skip		ld	t,$FF
		add	bc,1
		ld	(bc),t

		popa
		j	(hl)


; --
; -- Delete line in line length table. It is assumed that the line to insert is the first line of a pair
; -- or a single line
; --
; -- Inputs:
; --    t - line number
; --
scrollLinesLengthsUp:
		pusha

		ld	f,0
		exg	ft,bc
		ld	ft,lineLengths
		add	ft,bc
		ld	de,ft
		add	de,1
		exg	ft,bc

		sub	t,LINES_ON_SCREEN-1
		neg	t
		ld	f,t

.loop		ld	t,(de)
		ld	(bc),t
		add	bc,1
		add	de,1
.enter		dj	f,.loop

		ld	t,$00
		ld	(bc),t

		popa
		j	(hl)


; returns cursor pos as
;   f - virtual X pos, adjusted for line pairs
;   t - line index, adjusted for line pairs
getVirtualCursorPos:
		push	bc-hl

		jal	TextGetCursor
		ld	de,ft

		ld	f,0
		add	ft,lineLengths
		ld	t,(ft)
		cmp	t,$FF
		j/eq	.second_line

		ld	ft,de
		j	.exit

.second_line
		; We're on the second line of a pair
		ld	ft,de
		add	f,CHARS_PER_LINE
		sub	t,1

.exit		pop	bc-hl
		j	(hl)


; ft - character
;  b - X
;  c - Y
insertCharacterOnLine:
		pusha

		push	ft
		ld	ft,bc
		jal	TextInsertEmptyCharacter
		pop	ft

		jal	TextSetCharacterAt

		popa
		jal	(hl)
		

blinkCursor:
		pusha

		ld	bc,blinkCount
		ld	t,(bc)
		ls	ft,2
		ext
		ld	t,f
		ld	c,t
		ld	b,VATTR_UNDERLINE
		jal	TextSetAttributesAtCursor

		popa
		j	(hl)


restartCursor:
		ld	bc,blinkCount
		ld	t,$30
		ld	(bc),t
		j	(hl)


ScreenVBlank:
		pusha

		ld	bc,blinkCount
		ld	t,(bc)
		add	t,1
		ld	(bc),t

		popa
		j	(hl)

		
		SECTION	"EditorVars",BSS
isInsert:	DS	1		
blinkCount:	DS	1
lineLengths:	DS	LINES_ON_SCREEN	; -1 means the line is joined to the one above
