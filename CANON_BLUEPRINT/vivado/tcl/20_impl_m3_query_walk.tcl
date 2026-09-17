# Isolated OOC place/route query_walk_bind. PROGRAM=NO. No bitstream. Not freeze top.
set out {D:/FPGA/arty_d/m3_query_walk_ooc}
open_checkpoint [file join $out post_synth.dcp]
opt_design
place_design
route_design
write_checkpoint -force [file join $out post_route.dcp]
report_timing_summary -delay_type min_max -max_paths 5 -file [file join $out reports route_timing.rpt]
report_timing -max_paths 5 -file [file join $out reports route_crit.rpt]
report_utilization -file [file join $out reports route_util.rpt]
report_route_status -file [file join $out reports route_status.rpt]
puts "M3_QUERY_WALK_OOC_ROUTE_DONE"
exit
