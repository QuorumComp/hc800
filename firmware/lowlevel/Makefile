SRCS = commands.asm math.asm memory.asm nexys3.asm uart.asm
ASMFLAGS = -g -el -z0
TARGET = lowlevel.lib

ASM = motorrc8
LIB = xlib
LINK = xlink

DEPDIR := .d
$(shell mkdir -p $(DEPDIR) >/dev/null)
DEPFLAGS = -d$(DEPDIR)/$*.Td

ASSEMBLE = $(ASM) $(DEPFLAGS) $(ASMFLAGS)
POSTCOMPILE = @mv -f $(DEPDIR)/$*.Td $(DEPDIR)/$*.d && touch $@

$(TARGET) : $(notdir $(SRCS:asm=obj))
	$(LIB) $@ a $+

%.obj : %.asm
%.obj : %.asm $(DEPDIR)/%.d
	$(ASSEMBLE) -o$@ $<
	$(POSTCOMPILE)

$(DEPDIR)/%.d: ;
.PRECIOUS: $(DEPDIR)/%.d

clean :
	rm -rf $(TARGET) $(notdir $(SRCS:asm=obj)) $(DEPDIR)

include $(wildcard $(patsubst %,$(DEPDIR)/%.d,$(basename $(notdir $(SRCS)))))
