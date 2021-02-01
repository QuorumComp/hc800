IMAGEDIR = _image_

TARGETS = \
	boot/boot.bin \
	kernal/kernal.bin \
	ascii/ascii.exe \
	mathtest/mathtest.com

LIBS = stdlib/std.lib lowlevel/lowlevel.lib

CLEAN = $(addsuffix .clean,$(dir $(TARGETS) $(LIBS)))

.PHONY: install all clean $(TARGETS) $(LIBS)

install: $(TARGETS)
ifeq ($(MAKE_HOST),Windows32)
	@mkdir $(IMAGEDIR) >NUL 2>&1 || echo. >NUL
	@cmd /Q /C for %%G in ($(subst /,\\,$?)) do xcopy %%G $(IMAGEDIR) /Y /Q >NUL
else
	@mkdir -p $(IMAGEDIR)
	cp $? $(IMAGEDIR)
endif

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
	@$(MAKE) -C $(@D)

$(TARGETS): $(LIBS)
	@$(MAKE) -C $(@D)

