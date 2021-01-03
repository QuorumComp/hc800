LOWLEVEL = ../lowlevel/
SRCS = startup.asm main.asm text.asm

ASMFLAGS = -g -el -z0 -i../
TARGET = boot.bin

ASM = motorrc8
LIB = xlib
LINK = xlink

DEPDIR := .d
$(shell mkdir -p $(DEPDIR) >/dev/null)
DEPFLAGS = -d$(DEPDIR)/$*.Td

ASSEMBLE = $(ASM) $(DEPFLAGS) $(ASMFLAGS)
POSTCOMPILE = @mv -f $(DEPDIR)/$*.Td $(DEPDIR)/$*.d && touch $@

$(TARGET) : $(notdir $(SRCS:asm=obj)) $(LOWLEVEL)lowlevel.lib
	$(LINK) -sEntry -m$(@:bin=sym) -o$@ -thc8b $+

%.obj : %.asm
%.obj : %.asm $(DEPDIR)/%.d
	$(ASSEMBLE) -o$@ $<
	$(POSTCOMPILE)

$(DEPDIR)/%.d: ;
.PRECIOUS: $(DEPDIR)/%.d

clean :
	rm -rf $(TARGET) $(notdir $(SRCS:asm=obj)) $(DEPDIR)

include $(wildcard $(patsubst %,$(DEPDIR)/%.d,$(basename $(notdir $(SRCS)))))
