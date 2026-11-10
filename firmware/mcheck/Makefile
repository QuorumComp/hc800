# mcheck is a flat binary for the cosim model rather than an executable for the
# kernel, so it is not in the firmware Makefile's target list: build and run it
# here with make / make run.

TARGET = mcheck.bin
SRCS = mcheck.asm
LIBS = $(STD) $(LOWLEVEL)
LINKFLAGS = -sEntry -fbin -l$@.lst -m$@.map -o$@ -chc8s
include ../rules.mk

COSIM ?= ../../../emulator/_build/default/cosim/cosim.exe

run: $(TARGET)
	@$(COSIM) -n 3000000 $< | sed -n 's/^CONSOLE //p' | xxd -r -p
