# Round 2: one attempt from frozen baseline (Round1 WHS unchanged).
# METHOD: route_design -directive Explore + phys_opt ExploreWithHoldFix
# NO RTL. PROGRAM=NO. Does not overwrite baseline or round1.
set base {D:/FPGA/arty_d/hold_r2/R2_TOP_ROUTE_BASELINE_WHS_0P021/post_route.dcp}
set out {D:/FPGA/arty_d/hold_r2/round2}
file mkdir $out
file mkdir [file join $out reports]
open_checkpoint $base
puts "HOLD_R2_ROUND2_ROUTE_EXPLORE"
route_design -directive Explore
if {[catch {phys_opt_design -directive ExploreWithHoldFix} err]} {
  puts "HOLD_R2_ROUND2_EWHF_FALLBACK: $err"
  phys_opt_design -hold_fix
}
write_checkpoint -force [file join $out post_route.dcp]
report_timing_summary -delay_type min_max -max_paths 10 -file [file join $out reports timing_route.rpt]
report_timing -delay_type min -max_paths 5 -file [file join $out reports hold_route.rpt]
report_timing -max_paths 5 -file [file join $out reports crit_route.rpt]
report_utilization -file [file join $out reports util_route.rpt]
puts "HOLD_R2_ROUND2_DONE"
exit
