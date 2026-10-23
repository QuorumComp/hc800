SRCS = devices.asm
TARGET = devices
LIBS = $(STD) $(LOWLEVEL)
LINKFLAGS = -sEntry -m$@.sym -o$@ -chc8s -fhc800
include ../rules.mk
