SRCS = ftstep.asm
TARGET = ftstep
LIBS = $(STD) $(LOWLEVEL)
LINKFLAGS = -sEntry -m$@.sym -o$@ -chc8s -fhc800
include ../rules.mk

# FINAL=1 hand-encodes the native bytes this file probes (stepped FT rows,
# EI/DI under RETI, hub-byte loads); the default spells them through the
# assembler and must build byte-identically (see the source header).  Like
# the DEBUG stamp in rules.mk, the objects track the flag, not just sources.
FINAL ?= 0
ASMFLAGS += -D _FTSTEP_FINAL=$(FINAL)
FINALSTAMP = $(DEPDIR)/final-$(FINAL)

$(FINALSTAMP):
	@rm -f $(DEPDIR)/final-*
	@touch $@

ftstep.obj: $(FINALSTAMP)
