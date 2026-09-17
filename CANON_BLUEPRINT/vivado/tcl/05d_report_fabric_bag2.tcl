# Report timing on fabric_bag2 post_synth.dcp. CANDIDATE. PROGRAM=NO.
set out {D:/FPGA/arty_d/fabric_bag2}
file mkdir [file join $out reports]
open_checkpoint [file join $out post_synth.dcp]
report_utilization -file [file join $out reports util.rpt]
report_utilization -hierarchical -file [file join $out reports util_hier.rpt]
report_timing_summary -delay_type min_max -max_paths 10 -file [file join $out reports timing.rpt]
report_timing -max_paths 5 -file [file join $out reports crit.rpt]
report_drc -file [file join $out reports drc.rpt]
puts "ARTY_FABRIC_BAG2_REPORT_DONE"
exit
