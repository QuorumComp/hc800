SRCS = ftstep.asm
TARGET = ftstep
LIBS = $(STD) $(LOWLEVEL)
LINKFLAGS = -sEntry -m$@.sym -o$@ -chc8s -fhc800
include ../rules.mk

# FINAL=1 builds for the post-swap decoder: native stepped FT rows and
# the moved EI/DI and hub-byte load encodings, hand-encoded (see the
# source header).  The default targets the interim world.  Like the
# DEBUG stamp in rules.mk, the objects track the flag, not just sources.
FINAL ?= 0
ASMFLAGS += -D _FTSTEP_FINAL=$(FINAL)
FINALSTAMP = $(DEPDIR)/final-$(FINAL)

$(FINALSTAMP):
	@rm -f $(DEPDIR)/final-*
	@touch $@

ftstep.obj: $(FINALSTAMP)
