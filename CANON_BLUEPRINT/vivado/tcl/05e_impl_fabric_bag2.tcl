# Place/route arty_a7_r2_top bag2+uart_tx. CANDIDATE. PROGRAM=NO. No bitstream.
set out {D:/FPGA/arty_d/fabric_bag2}
file mkdir [file join $out reports]
open_checkpoint [file join $out post_synth.dcp]
opt_design
place_design
phys_opt_design
route_design
write_checkpoint -force [file join $out post_route.dcp]
report_utilization -file [file join $out reports util_route.rpt]
report_timing_summary -delay_type min_max -max_paths 10 -file [file join $out reports timing_route.rpt]
report_timing -max_paths 5 -file [file join $out reports crit_route.rpt]
report_drc -file [file join $out reports drc_route.rpt]
puts "ARTY_FABRIC_BAG2_ROUTE_DONE"
exit
