# =====================================================================
#  MEGA65 board build: headless Vivado flow for the HC800 on the MEGA65.
#      create project -> sources + IP + XDC -> synth -> opt -> place
#      -> route -> write_bitstream
#
#  Run it from the repo root with `just bitstream`, or directly:
#      source /home/ces/Xilinx/vivado_env.sh
#      cd boards/mega65
#      vivado -mode batch -nojournal -nolog -source build.tcl
#
#  The design sources are the SpinalHDL-generated `hc800_mega65.v`
#  (see `just rtl`) wrapped by `Mega65Top.v`, plus the board-level
#  keyboard / HDMI glue in this directory and `boards/common/hdmi`.
#
#  Everything tunable lives in the configuration block below. Each knob
#  can also be overridden from the environment (used by the justfile):
#      MEGA65_REV  r3 | r6      -> mega65<rev>.xdc
#      JOBS        parallel jobs
#      BITSTREAM   1 = full bitstream, 0 = stop after synthesis
#      CLEAN       1 = delete the project dir first
# =====================================================================

set here [file normalize [file dirname [info script]]]
cd $here

# ---- configuration --------------------------------------------------
if {![info exists cfg(root)]}      { set cfg(root)      $here }
if {![info exists cfg(project)]}   { set cfg(project)   Mega65Hc800 }
if {![info exists cfg(part)]}      { set cfg(part)      xc7a200tfbg484-2 }
if {![info exists cfg(top)]}       { set cfg(top)       Mega65Top }
if {![info exists cfg(out_dir)]}   { set cfg(out_dir)   build }
if {![info exists cfg(jobs)]}      { set cfg(jobs)      8 }
if {![info exists cfg(bitstream)]} { set cfg(bitstream) 1 }
if {![info exists cfg(clean)]}     { set cfg(clean)     0 }
# MEGA65 board revision -> mega65<rev>.xdc. r6 is the current board.
if {![info exists cfg(rev)]}       { set cfg(rev)       r6 }
# synth_design -flatten, matching the checked-in GUI project.
if {![info exists cfg(flatten)]}   { set cfg(flatten)   rebuilt }

foreach {key var} {MEGA65_REV rev JOBS jobs BITSTREAM bitstream CLEAN clean} {
    if {[info exists env($key)] && $env($key) ne ""} { set cfg($var) $env($key) }
}

set proj_path [file normalize [file join $cfg(root) $cfg(out_dir) $cfg(project)]]

puts "== Vivado build: MEGA65 =="
puts "project : $cfg(project)"
puts "part    : $cfg(part)"
puts "top     : $cfg(top)"
puts "board   : mega65$cfg(rev)"
puts "out     : $proj_path"

if {$cfg(clean) && [file exists $proj_path]} {
    puts "cleaning $proj_path"
    file delete -force $proj_path
}
file mkdir [file dirname $proj_path]
create_project -force $cfg(project) $proj_path -part $cfg(part)

# ---- sources --------------------------------------------------------
# This board's RTL is spread over three directories:
#   boards/mega65            board wrapper, keyboard, generated HC800
#   boards/common/hdmi       shared HDMI encoder
#   boards/common/hdmi/xilinx  Xilinx-specific HDMI IO stage
# `common/hdmi/altera` is deliberately skipped: it targets Altera primitives.
set src_dirs [list \
    $here \
    [file normalize [file join $here .. common hdmi]] \
    [file normalize [file join $here .. common hdmi xilinx]]]

set srcs {}
foreach dir $src_dirs {
    foreach ext {v sv vhd vhdl} {
        foreach f [glob -nocomplain -directory $dir *.$ext] { lappend srcs $f }
    }
}
if {[llength $srcs] == 0} { error "No HDL sources found under: $src_dirs" }
add_files -fileset sources_1 $srcs
puts "sources: [llength $srcs] files"

# ---- Xilinx IP (block RAMs + clock wizard) --------------------------
# The .xci files are checked in under ip/; Vivado generates them in place
# (gen_directory ".") and creates the out-of-context synthesis runs.
set ips {}
foreach f [glob -nocomplain -directory $here ip/*/*.xci] { lappend ips $f }
if {[llength $ips] == 0} { error "No .xci IP files found under $here/ip" }
add_files -fileset sources_1 $ips
puts "ip: [llength $ips] cores"

set_property top $cfg(top) [get_filesets sources_1]
update_compile_order -fileset sources_1

# The .xci files were authored on an older Vivado; bring them up to date.
if {[llength [get_ips -quiet]]} {
    set st [catch { upgrade_ip -quiet [get_ips] } msg]
    puts "upgrade_ip: [string trim $msg]"
}

# ---- constraints ----------------------------------------------------
set xdc [file normalize [file join $here mega65$cfg(rev).xdc]]
if {![file exists $xdc]} { error "Constraint file not found: $xdc (cfg(rev)=$cfg(rev))" }
add_files -fileset constrs_1 $xdc
puts "constraints: $xdc"

# ---- synthesis ------------------------------------------------------
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY $cfg(flatten) [get_runs synth_1]

# hc800_mega65.v initializes its ROMs with $readmemb("..._memory.bin").
# Synthesis runs in the run directory, so stage the images next to it.
set hook [file join $proj_path stage_mem.tcl]
set fh [open $hook w]
puts $fh {# Stage the SpinalHDL memory images into the synthesis working dir.}
puts $fh "foreach f \[glob -nocomplain {$here/*.bin}\] { file copy -force \$f \[pwd\] }"
close $fh
add_files -fileset utils_1 $hook
set_property STEPS.SYNTH_DESIGN.TCL.PRE $hook [get_runs synth_1]
puts "staging memory images via $hook"

launch_runs synth_1 -jobs $cfg(jobs)
wait_on_run synth_1
if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} {
    puts "ERROR: synthesis failed"; exit 1
}
puts "SYNTH_OK"

if {!$cfg(bitstream)} { puts "BUILD_DONE (synthesis only)"; exit 0 }

# ---- implementation + bitstream -------------------------------------
launch_runs impl_1 -to_step write_bitstream -jobs $cfg(jobs)
wait_on_run impl_1
if {[get_property PROGRESS [get_runs impl_1]] ne "100%"} {
    puts "ERROR: implementation failed"; exit 1
}

set runs [file join $proj_path "${cfg(project)}.runs" impl_1]
set bits [glob -nocomplain [file join $runs *.bit]]
puts "BUILD_DONE"
if {[llength $bits]} {
    foreach b $bits { puts "BITSTREAM=$b" }
} else {
    puts "WARNING: no .bit file found under $runs"
}
foreach rpt [glob -nocomplain [file join $runs *timing_summary_routed.rpt]] {
    puts "TIMING=$rpt"
}
