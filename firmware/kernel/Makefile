SRCS = startup.asm \
	blockdevice.asm \
	commandline.asm \
	editor.asm \
	error.asm \
	fail.asm \
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

TARGET = kernel.bin
LIBS = $(STD) $(LOWLEVEL)
LINKFLAGS = -sInit -m$(@:bin=sym) -l$(@:bin=lst) -o$@ -chc800b -fhc800k
include ../rules.mk
