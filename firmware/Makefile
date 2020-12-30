IMAGEDIR = _image_

TARGETS = \
	boot/boot.bin \
	kernal/kernal.bin \
	ascii/ascii.com \
	monitor/monitor.com

LIBS = stdlib/std.lib firmlib/firm.lib

CLEAN = $(addsuffix .clean,$(dir $(TARGETS) $(LIBS)))

.PHONY: install all clean $(TARGETS) $(LIBS)

install: $(TARGETS)
	@mkdir -p $(IMAGEDIR)
	cp $? $(IMAGEDIR)

clean: $(CLEAN)
	rm -rf $(IMAGEDIR)

all: $(TARGETS)

%.clean:
	@$(MAKE) -C $* clean

$(LIBS):
	@$(MAKE) -C $(@D)

$(TARGETS): $(LIBS)
	@$(MAKE) -C $(@D)

