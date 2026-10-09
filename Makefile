# =====================================================================
#  HC800 MEGA65 build graph: firmware -> SpinalHDL Verilog -> Vivado.
#
#  Every stage rebuilds only when its outputs are older than its inputs.
#  Multi-output stages (sbt writes the .v + memory images; Vivado writes
#  the .dcp/.bit) use stamp files under boards/<board>/build/ that are
#  touched only after a successful run. The Vivado stamps are named after
#  the board rev, so switching rev (r3/r6) always rebuilds.
#
#  Drive it from hc800/.justfile (`just bitstream`, `just blast`, ...)
#  or run make directly. Overridable variables:
#      rev        r3 | r6     board revision -> mega65<rev>.xdc
#      board      mega65      board directory under boards/
#      jobs       8           Vivado parallel jobs
#      cable      digilent    openFPGALoader cable model
#      vivado_env             Vivado environment script
# =====================================================================

SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:

rev        ?= r6
board      ?= mega65
jobs       ?= 8
cable      ?= digilent
vivado_env ?= /home/ces/Xilinx/vivado_env.sh

BD        := boards/$(board)
RUNS      := $(BD)/build/Mega65Hc800/Mega65Hc800.runs
GEN_V     := $(BD)/hc800_mega65.v
GEN_BINS  := $(wildcard $(GEN_V)_toplevel_*.bin)
FW_BINS   := firmware/boot/boot.bin firmware/kernel/kernel.bin
DATA_BINS := data/font.bin data/box.bin
RTL_SRCS  := $(shell find rtl -name target -prune -o -name '*.scala' -print) rtl/build.sbt rtl/project/build.properties
VIV_IN    := $(wildcard $(BD)/*.v $(BD)/*.sv $(BD)/*.vhd $(BD)/*.vhdl $(BD)/*.bin) \
             $(shell find boards/common -type f \( -name '*.v' -o -name '*.sv' -o -name '*.vhd' -o -name '*.vhdl' \)) \
             $(wildcard $(BD)/ip/*/*.xci) $(BD)/mega65$(rev).xdc $(BD)/build.tcl
BIT       := $(RUNS)/impl_1/Mega65Top.bit
DCP       := $(RUNS)/synth_1/Mega65Top.dcp
RTL_STAMP := $(BD)/build/rtl.stamp
SYN_STAMP := $(BD)/build/synth.$(rev)
BIT_STAMP := $(BD)/build/bitstream.$(rev)

.PHONY: all init firmware rtl build synth bitstream blast reblast clean
all: bitstream

# Check the Vivado toolchain and the board rev.
init:
	@case "$(rev)" in r3|r6) ;; *) echo "error: rev=$(rev) must be r3 or r6" >&2; exit 1 ;; esac
	@test -f "$(vivado_env)" || { echo "error: Vivado env not found at $(vivado_env)"; echo "see /home/ces/Xilinx/README.md" >&2; exit 1; }
	@echo "init OK"

# Firmware: incremental, delegated to the firmware Makefile. The stamp
# rules below depend on the images, so a firmware change propagates.
.PHONY: firmware
firmware:
	$(MAKE) -C firmware --no-print-directory -s
$(FW_BINS): | firmware

# SpinalHDL -> board Verilog + memory images. sbt runs only when Scala
# sources, firmware images, or font data are newer than the artifacts
# (the artifacts are prerequisites of the stamp, so deleting any of them
# also forces regeneration).
$(RTL_STAMP): $(RTL_SRCS) $(FW_BINS) $(DATA_BINS) $(GEN_V) $(GEN_BINS)
	cd rtl && sbt "runMain hc800.HC800TopLevel"
	mkdir -p "$(abspath $(BD)/build)"
	touch "$(abspath $@)"
rtl: $(RTL_STAMP)

# Firmware, then RTL generation.
build: rtl

# Vivado synthesis only. The stamp records the board rev.
#
# $(FW_BINS) is listed first on purpose: make checks freshness once, at the
# start of the run, using current mtimes. The memory bins in $(VIV_IN) are
# *regenerated* by the rtl stage later in the same run, so at the start their
# mtime is stale and would make this stamp look up to date. Depending directly
# on the firmware images forces a rebuild whenever the firmware changes.
$(SYN_STAMP): $(FW_BINS) $(VIV_IN) $(DCP)
	source "$(vivado_env)"
	cd "$(BD)"
	MEGA65_REV="$(rev)" JOBS="$(jobs)" BITSTREAM=0 vivado -mode batch -nojournal -nolog -source build.tcl
	touch "$(abspath $@)"
synth: rtl $(SYN_STAMP)

# Full bitstream: synth -> place -> route -> write_bitstream.
# $(FW_BINS) first for the same reason as $(SYN_STAMP) above.
$(BIT_STAMP): $(FW_BINS) $(VIV_IN) $(BIT)
	source "$(vivado_env)"
	cd "$(BD)"
	MEGA65_REV="$(rev)" JOBS="$(jobs)" vivado -mode batch -nojournal -nolog -source build.tcl
	touch "$(abspath $@)"
bitstream: rtl $(BIT_STAMP)

# Blast the built bitstream into the MEGA65's FPGA via JTAG (openFPGALoader).
# Volatile SRAM load: the design runs until the next power cycle, which
# restores the stock MEGA65 core. Deliberately no -f: writing the config
# flash would replace the MEGA65 core + hypervisor. Requires a JTAG adapter
# on the board's 12-pin header (TE0790-03 -> cable=digilent).
blast: bitstream
	@command -v openFPGALoader >/dev/null || { echo "error: openFPGALoader not found; install it: pacman -S openfpgaloader" >&2; exit 1; }
	env -u LD_LIBRARY_PATH openFPGALoader -c "$(cable)" "$(BIT)"

# Re-blast the existing bitstream into the MEGA65's FPGA via JTAG
# (openFPGALoader) without rebuilding any stage. Same volatile SRAM load as
# `blast`; fails fast if the bitstream has not been built yet.
reblast:
	@test -f "$(BIT)" || { echo "error: bitstream not found at $(BIT); run 'just bitstream' first" >&2; exit 1; }
	@command -v openFPGALoader >/dev/null || { echo "error: openFPGALoader not found; install it: pacman -S openfpgaloader" >&2; exit 1; }
	env -u LD_LIBRARY_PATH openFPGALoader -c "$(cable)" "$(BIT)"

# Remove the generated Vivado project (keeps the checked-in IP .xci files).
clean:
	rm -rf "$(BD)/build" "$(BD)/.Xil"
