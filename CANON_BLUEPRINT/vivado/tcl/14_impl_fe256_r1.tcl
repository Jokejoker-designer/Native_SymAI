# Isolated OOC place/route FE256_HW_R1. PROGRAM=NO. No bitstream. Not r2_top.
set out {D:/FPGA/arty_d/fe256_ooc_r1}
open_checkpoint [file join $out post_synth.dcp]
opt_design
place_design
route_design
write_checkpoint -force [file join $out post_route.dcp]
report_timing_summary -delay_type min_max -max_paths 5 -file [file join $out reports route_timing.rpt]
report_timing -max_paths 5 -file [file join $out reports route_crit.rpt]
report_utilization -file [file join $out reports route_util.rpt]
report_route_status -file [file join $out reports route_status.rpt]
puts "FE256_HW_R1_OOC_ROUTE_DONE"
exit
