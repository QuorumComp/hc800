	IFND	SYSCALL_I_INCLUDED_

SYSCALL_I_INCLUDED_ = 1

			RSSET	8

; -- Reset machine
KReset			RB	1

; -- Clear the text screen
KClearScreen		RB	1

; -- Set attributes
; --   b - mask of attributes to set
; --   c - attribute value
KTextSetAttributes	RB	1

; -- Output character (incl. control codes)
; --   t - character to print
KCharacterOut		RB	1

; -- Execute command line
; --  bc - command line
KExecute		RB	1

; -- Exit client to kernal
KExit			RB	1

; -- Print debug character
; --   t - character to print
; -- Outputs:
; --    f - "eq" condition if success
KDebugCharacterOut	RB	1

; -- Set the color attribute for printing text
; -- Usage: MSetColor color
MSetColor:	MACRO
		pusha
		ld	b,$F0
		ld	c,(\1)<<4
		sys	KTextSetAttributes
		popa
		ENDM

; -- Set attribute bits
; -- Usage: MSetAttribute attribute
MSetAttribute:	MACRO
		pusha
		ld	b,(\1)
		ld	c,(\1)
		sys	KTextSetAttributes
		popa
		ENDM

; -- Clear attribute bits
; -- Usage: MSetAttribute attribute
MClearAttribute:	MACRO
		pusha
		ld	b,(\1)
		ld	c,0
		sys	KTextSetAttributes
		popa
		ENDM

; -- Print a new line
MNewLine:	MACRO
		pusha
		ld	t,10
		sys	KCharacterOut
		popa
		ENDM

; -- Print a debug string to UART
MDebugPrint:	MACRO
		pusha
		j	.skip\@
.string\@	DB	\1
.skip\@		ld	d,.skip\@-.string\@
		ld	bc,.string\@
.next\@		lco	t,(bc)
		add	bc,1
		sys	KDebugCharacterOut
		j/ne	.error\@
		dj	d,.next\@
.error\@	popa
		ENDM




	ENDC
