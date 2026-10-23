SRCS = startup.asm commands.asm main.asm text.asm
TARGET = boot.bin
LIBS = $(LOWLEVEL)
LINKFLAGS = -sEntry -m$(@:bin=sym) -l$(@:bin=lst) -o$@ -chc800b -fbin
include ../rules.mk
