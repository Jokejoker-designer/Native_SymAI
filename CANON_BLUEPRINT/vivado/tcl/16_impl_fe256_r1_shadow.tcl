# Isolated place/route FE256_HW_R1 shadow-bind. PROGRAM=NO. No bitstream. Not frozen r2_top.
set out {D:/FPGA/arty_d/fe256_r1_shadow}
open_checkpoint [file join $out post_synth.dcp]
opt_design
place_design
phys_opt_design
route_design
write_checkpoint -force [file join $out post_route.dcp]
report_utilization -file [file join $out reports util_route.rpt]
report_timing_summary -delay_type min_max -max_paths 10 -file [file join $out reports timing_route.rpt]
report_timing -max_paths 5 -file [file join $out reports crit_route.rpt]
report_timing -hold -max_paths 5 -file [file join $out reports hold_route.rpt]
report_cdc -file [file join $out reports cdc_route.rpt]
report_route_status -file [file join $out reports route_status.rpt]
report_drc -file [file join $out reports drc_route.rpt]
puts "FE256_R1_SHADOW_ROUTE_DONE"
exit
