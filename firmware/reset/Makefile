STD = ../stdlib/std.lib
LIBS = $(STD)
SRCS = reset.asm
ASMFLAGS = -g -el -z0 -i../
TARGET = reset

ASM = motorrc8
LIB = xlib
LINK = xlink

DEPDIR := .d
DEPFLAGS = -d$(DEPDIR)/$*.Td

ifeq ($(MAKE_HOST),Windows32)
$(shell mkdir $(DEPDIR) >NUL 2>&1)
POSTCOMPILE = @move /Y $(DEPDIR)\$*.Td $(DEPDIR)\$*.d >NUL && type NUL >>$@
REMOVEALL = del /S /Q $(TARGET) $(notdir $(SRCS:asm=obj)) $(DEPDIR) >NUL
else
$(shell mkdir -p $(DEPDIR) >/dev/null)
POSTCOMPILE = @mv -f $(DEPDIR)/$*.Td $(DEPDIR)/$*.d && touch $@
REMOVEALL = rm -rf $(TARGET) $(notdir $(SRCS:asm=obj)) $(DEPDIR)
endif

ASSEMBLE = $(ASM) $(DEPFLAGS) $(ASMFLAGS)

%.obj : %.asm
%.obj : %.asm $(DEPDIR)/%.d
	$(ASSEMBLE) -o$@ $<
	$(POSTCOMPILE)

$(DEPDIR)/%.d: ;
.PRECIOUS: $(DEPDIR)/%.d

$(TARGET) : $(notdir $(SRCS:asm=obj)) $(LIBS)
	$(LINK) -sEntry -m$@.sym -o$@ -chc800s -fhc800 $+

clean :
	$(REMOVEALL)

include $(wildcard $(patsubst %,$(DEPDIR)/%.d,$(basename $(notdir $(SRCS)))))
