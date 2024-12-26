STD = ../stdlib/
LOWLEVEL = ../lowlevel/
SRCS = startup.asm \
	blockdevice.asm \
	commandline.asm \
	editor.asm \
	error.asm \
	fat32.asm \
	filesystems.asm \
	keyboard.asm \
	main.asm \
	mbr.asm \
	mmu.asm \
	sd.asm \
	sddevice.asm \
	syscall.asm \
	text.asm \
	uart_commands.asm \
	uartfs.asm \
	video.asm


LIBS = $(STD)std.lib $(LOWLEVEL)lowlevel.lib

ASMFLAGS = -g -el -z0 -i../
TARGET = kernel.bin

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
	@echo "\033[1;33m    Link\033[0m $(@F)"
	@$(LINK) -sInit -m$(@:bin=sym) -l$(@:bin=lst) -o$@ -chc800b -fhc800k $+

%.obj : %.asm
%.obj : %.asm $(DEPDIR)/%.d
	@echo "\033[0;32mAssemble\033[0m $(@F)"
	@$(ASSEMBLE) -o$@ $<
#	@$(POSTCOMPILE)

$(DEPDIR)/%.d: ;
.PRECIOUS: $(DEPDIR)/%.d

clean :
	$(REMOVEALL)

include $(wildcard $(patsubst %,$(DEPDIR)/%.d,$(basename $(notdir $(SRCS)))))
