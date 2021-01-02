COMMON = ../common/
STD = ../stdlib/
FIRM = ../firmlib/
SRCS = startup.asm editor.asm keyboard.asm main.asm math.asm syscall.asm video.asm video_common.asm
LIBS = $(STD)std.lib $(FIRM)firm.lib

ASMFLAGS = -g -el -z0 -i$(COMMON) -i$(STD) -i$(FIRM)
TARGET = kernal.bin

ASM = motorrc8
LIB = xlib
LINK = xlink

DEPDIR := .d
$(shell mkdir -p $(DEPDIR) >/dev/null)
DEPFLAGS = -d$(DEPDIR)/$*.Td

ASSEMBLE = $(ASM) $(DEPFLAGS) $(ASMFLAGS)
POSTCOMPILE = @mv -f $(DEPDIR)/$*.Td $(DEPDIR)/$*.d && touch $@

$(TARGET) : $(notdir $(SRCS:asm=obj)) $(LIBS)
	$(LINK) -m$(@:bin=sym) -o$@ -thc8b $+

%.obj : %.asm
%.obj : %.asm $(DEPDIR)/%.d
	$(ASSEMBLE) -o$@ $<
	$(POSTCOMPILE)

$(DEPDIR)/%.d: ;
.PRECIOUS: $(DEPDIR)/%.d

clean :
	rm -rf $(TARGET) $(notdir $(SRCS:asm=obj)) $(DEPDIR)

include $(wildcard $(patsubst %,$(DEPDIR)/%.d,$(basename $(notdir $(SRCS)))))
