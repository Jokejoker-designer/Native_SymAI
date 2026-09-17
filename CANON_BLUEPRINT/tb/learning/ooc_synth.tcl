# OOC synthesis smoke for AGENT_C candidate modules (synthesizability evidence only; NOT timing signoff,
# NOT board evidence). Part = Arty A7-100T (XC7A100T-CSG324-1) per _ARCHIVE/ORIGINAL_REQUEST.md.
# Usage: vivado -mode batch -source tb/learning/ooc_synth.tcl -tclargs <module> <rtl_file> [rpt_dir]
set top     [lindex $argv 0]
set rtl     [lindex $argv 1]
set rptdir  [expr {[llength $argv] > 2 ? [lindex $argv 2] : "tb/learning/build/ooc"}]
file mkdir $rptdir
create_project -in_memory -part xc7a100tcsg324-1
read_verilog $rtl
synth_design -top $top -mode out_of_context -flatten_hierarchy rebuilt
report_utilization -file $rptdir/${top}_util.rpt
# Preliminary post-synth timing estimate at 100 MHz (Arty sys clk). Estimate only: pre-place, OOC,
# no IO constraints. NOT timing signoff (LATENCY = MEASURED AFTER IMPLEMENTATION).
if {[llength [get_ports -quiet clk]] == 1} { create_clock -period 10.000 -name clk_ooc [get_ports clk] }
report_timing_summary -no_detailed_paths -file $rptdir/${top}_timing.rpt
report_timing -max_paths 3 -file $rptdir/${top}_paths.rpt
# Optional named cone via env OOC_FROM / OOC_TO (cell-name regexes; env avoids shell quoting of '|' and
# parentheses): reports that cone's worst paths separately, to quote a fabric-reported path that is not
# the OOC worst.
if {[info exists ::env(OOC_FROM)] && [info exists ::env(OOC_TO)]} {
    set from [get_cells -quiet -hierarchical -regexp $::env(OOC_FROM)]
    set to   [get_cells -quiet -hierarchical -regexp $::env(OOC_TO)]
    if {[llength $from] > 0 && [llength $to] > 0} {
        report_timing -from $from -to $to -max_paths 3 -file $rptdir/${top}_cone.rpt
    } else {
        puts "OOC_CONE_EMPTY from=[llength $from] to=[llength $to]"
    }
}
set n_err [get_msg_config -count -severity {ERROR}]
set n_crit [get_msg_config -count -severity {CRITICAL WARNING}]
puts "OOC_SYNTH_DONE top=$top errors=$n_err critical_warnings=$n_crit"
