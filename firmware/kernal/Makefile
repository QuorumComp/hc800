STD = ../stdlib/
LOWLEVEL = ../lowlevel/
SRCS = startup.asm editor.asm keyboard.asm main.asm syscall.asm text.asm
LIBS = $(STD)std.lib $(LOWLEVEL)lowlevel.lib

ASMFLAGS = -g -el -z0 -i../
TARGET = kernal.bin

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

$(TARGET) : $(notdir $(SRCS:asm=obj)) $(LIBS)
	$(LINK) -m$(@:bin=sym) -o$@ -thc8b $+

%.obj : %.asm
%.obj : %.asm $(DEPDIR)/%.d
	$(ASSEMBLE) -o$@ $<
	$(POSTCOMPILE)

$(DEPDIR)/%.d: ;
.PRECIOUS: $(DEPDIR)/%.d

clean :
	$(REMOVEALL)

include $(wildcard $(patsubst %,$(DEPDIR)/%.d,$(basename $(notdir $(SRCS)))))
