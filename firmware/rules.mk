# Shared build rules for the HC800 firmware.
#
# The library submodules (stdlib, lowlevel) carry a copy of this file for their
# own builds. Keep all copies in sync.
#
# A leaf Makefile sets:
#   SRCS      assembly sources (basenames)
#   TARGET    output file
#   KIND      program (default) or library
#   LIBS      libraries to link (programs only)
#   LINKFLAGS linker arguments (programs only); use = so $@ expands per target
# and then includes this file.
#
# ASM/LIB/LINK can be overridden from the environment or the command line.

STD      = ../stdlib/std.lib
LOWLEVEL = ../lowlevel/lowlevel.lib

ASM  ?= motorrc8
LIB  ?= xlib
LINK ?= xlink

DEBUG ?= 0
# lowlevel has no ../ include path; it sets ASMFLAGS before including this file.
ASMFLAGS ?= -g -el -z0 -i../
ASMFLAGS += -D _DEBUG=$(DEBUG)

DEPDIR   := .d
DEPFLAGS  = -d$(DEPDIR)/$*.d
ASSEMBLE  = $(ASM) $(DEPFLAGS) $(ASMFLAGS)

# Object files are shared between debug and release builds, so a DEBUG change
# has to invalidate them.
DEBUGSTAMP = $(DEPDIR)/debug-$(DEBUG)

ifeq ($(MAKE_HOST),Windows32)
$(shell mkdir $(DEPDIR) >NUL 2>&1)
REMOVEALL = del /S /Q $(TARGET) $(notdir $(SRCS:asm=obj)) $(DEPDIR) >NUL
else
$(shell mkdir -p $(DEPDIR) >/dev/null)
REMOVEALL = rm -rf $(TARGET) $(notdir $(SRCS:asm=obj)) $(DEPDIR)
endif

.DEFAULT_GOAL := $(TARGET)
KIND ?= program

ifeq ($(KIND),library)
$(TARGET) : $(notdir $(SRCS:asm=obj))
	@echo "\033[1;33m Collect\033[0m $(@F)"
	@$(LIB) $@ a $+
else
$(TARGET) : $(notdir $(SRCS:asm=obj)) $(LIBS)
	@echo "\033[1;33m    Link\033[0m $(@F)"
	@$(LINK) $(LINKFLAGS) $+
endif

$(DEBUGSTAMP):
	@rm -f $(DEPDIR)/debug-*
	@touch $@

$(notdir $(SRCS:asm=obj)): $(DEBUGSTAMP)

%.obj : %.asm
%.obj : %.asm $(DEPDIR)/%.d
	@echo "\033[0;32mAssemble\033[0m $(@F)"
	@$(ASSEMBLE) -o$@ $<

$(DEPDIR)/%.d: ;
.PRECIOUS: $(DEPDIR)/%.d

clean :
	$(REMOVEALL)

include $(wildcard $(patsubst %,$(DEPDIR)/%.d,$(basename $(notdir $(SRCS)))))
