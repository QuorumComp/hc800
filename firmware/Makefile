IMAGEDIR = _image_

DEBUG ?= 0
export DEBUG

TARGETS = \
	boot/boot.bin \
	kernel/kernel.bin \
	ascii/ascii \
	devices/devices \
	dir/dir \
	gfxtest/gfxtest \
	mathtest/mathtest \
	reset/reset \
	type/type \
	volumes/volumes

LIBS = stdlib/std.lib lowlevel/lowlevel.lib

CLEAN = $(addsuffix .clean,$(dir $(TARGETS) $(LIBS)))

.PHONY: install all clean disk disk-part disk-2part $(TARGETS) $(LIBS)

install: $(TARGETS)
ifeq ($(MAKE_HOST),Windows32)
	@mkdir $(IMAGEDIR) >NUL 2>&1 || echo. >NUL
	@cmd /Q /C for %%G in ($(subst /,\\,$?)) do xcopy %%G $(IMAGEDIR) /Y /Q >NUL
else
	@mkdir -p $(IMAGEDIR)
	@cp addons/* $? $(IMAGEDIR)
endif

disk: install
	just disk

disk-part: install
	just disk-part

disk-2part: install
	just disk-2part

clean: $(CLEAN)
ifeq ($(MAKE_HOST),Windows32)
	del /S /Q $(IMAGEDIR)
else
	rm -rf $(IMAGEDIR)
endif

all: $(TARGETS)

%.clean:
	@$(MAKE) -C $* clean

$(LIBS):
	@$(MAKE) --no-print-directory -C $(@D)

$(TARGETS): $(LIBS)
	@$(MAKE) --no-print-directory -C $(@D)

