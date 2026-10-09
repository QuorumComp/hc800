LOWLEVEL = ../lowlevel/
SRCS = startup.asm commands.asm main.asm text.asm

ASMFLAGS = -g -el -z0 -i../
TARGET = boot.bin

ASM = motorrc8
LIB = xlib
LINK = xlink

DEPDIR := .d
DEPFLAGS = -d$(DEPDIR)/$*.d

ifeq ($(MAKE_HOST),Windows32)
$(shell mkdir $(DEPDIR) >NUL 2>&1)
REMOVEALL = del /S /Q $(TARGET) $(notdir $(SRCS:asm=obj)) $(DEPDIR) >NUL
else
$(shell mkdir -p $(DEPDIR) >/dev/null)
REMOVEALL = rm -rf $(TARGET) $(notdir $(SRCS:asm=obj)) $(DEPDIR)
endif

ASSEMBLE = $(ASM) $(DEPFLAGS) $(ASMFLAGS)

$(TARGET) : $(notdir $(SRCS:asm=obj)) $(LOWLEVEL)lowlevel.lib
	@echo "\033[1;33m    Link\033[0m $(@F)"
	@$(LINK) -sEntry -m$(@:bin=map) -l$(@:bin=list) -o$@ -chc800b -fbin $+

%.obj : %.asm
%.obj : %.asm $(DEPDIR)/%.d
	@echo "\033[0;32mAssemble\033[0m $(@F)"
	@$(ASSEMBLE) -o$@ $<

$(DEPDIR)/%.d: ;
.PRECIOUS: $(DEPDIR)/%.d

clean :
	$(REMOVEALL)

include $(wildcard $(patsubst %,$(DEPDIR)/%.d,$(basename $(notdir $(SRCS)))))
