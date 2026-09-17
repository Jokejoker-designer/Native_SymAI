# Round 1: post-route phys_opt -hold_fix. NO RTL. PROGRAM=NO. Does not overwrite baseline.
set base {D:/FPGA/arty_d/hold_r2/R2_TOP_ROUTE_BASELINE_WHS_0P021/post_route.dcp}
set out {D:/FPGA/arty_d/hold_r2/round1}
file mkdir $out
file mkdir [file join $out reports]
open_checkpoint $base
phys_opt_design -hold_fix
write_checkpoint -force [file join $out post_route.dcp]
report_timing_summary -delay_type min_max -max_paths 10 -file [file join $out reports timing_route.rpt]
report_timing -delay_type min -max_paths 5 -file [file join $out reports hold_route.rpt]
report_timing -max_paths 5 -file [file join $out reports crit_route.rpt]
report_utilization -file [file join $out reports util_route.rpt]
puts "HOLD_R2_ROUND1_DONE"
exit
