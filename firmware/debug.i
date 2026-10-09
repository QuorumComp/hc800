		INCLUDE	ONCE

; --
; -- Debug configuration
; --
; -- DEBUG is controlled by the Makefile: `make DEBUG=1` passes -D_DEBUG
; -- to the assembler, which defines the symbol. Default is 0.
; --
		IFD _DEBUG
DEBUG	EQU	1
		ENDC
		IFND _DEBUG
DEBUG	EQU	0
		ENDC
