# HC800 build recipes — a thin wrapper over the Makefile, which owns the
# dependency graph. Every stage (firmware, RTL generation, synthesis,
# bitstream) rebuilds only when its inputs are newer than its outputs.
#
#   just bitstream   MEGA65 bitstream (stages skipped when up to date)
#   just blast       build, then blast the bitstream into the board via JTAG
#   just reblast     blast the existing bitstream into the board (no rebuild)
#   just             list the recipes
#
# Variables can be overridden on the command line, e.g.
#   just rev=r3 bitstream     # MEGA65 R3 board constraints
#   just jobs=16 bitstream

board := "mega65"
rev   := "r6"
jobs  := "8"
cable := "digilent"
make  := "make --no-print-directory"

# List the available recipes
default:
    @just --list

# Check the Vivado toolchain and the board rev
init:
    {{make}} init

# Build the firmware (needs ASMotor installed: motorrc8, xlib, xlink)
firmware:
    {{make}} firmware

# Firmware, then board Verilog (sbt skipped when up to date)
rtl:
    {{make}} rtl

# Firmware + RTL generation
build: rtl

# Vivado synthesis only
synth:
    {{make}} board={{board}} rev={{rev}} jobs={{jobs}} synth

# Full MEGA65 bitstream
bitstream:
    {{make}} board={{board}} rev={{rev}} jobs={{jobs}} bitstream

# Build, then blast the bitstream into the MEGA65's FPGA via JTAG (openFPGALoader)
blast:
    {{make}} board={{board}} rev={{rev}} jobs={{jobs}} cable={{cable}} blast

# Re-blast the existing bitstream into the MEGA65's FPGA via JTAG (no rebuild)
reblast:
    {{make}} board={{board}} cable={{cable}} reblast

# Remove the generated Vivado project (keeps the checked-in IP .xci files)
clean:
    {{make}} clean
