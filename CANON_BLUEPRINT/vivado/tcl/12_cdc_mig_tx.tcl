# CDC/reset report from routed mig_tx. CANDIDATE. PROGRAM=NO. No bitstream.
# Does not clobber freeze or rewrite post_route.dcp.
set dcp {D:/FPGA/arty_d/mig_tx/post_route.dcp}
set out {D:/FPGA/arty_d/mig_tx/reports}
file mkdir $out
open_checkpoint $dcp
report_clock_interaction -delay_type min_max -file [file join $out clock_interaction.rpt]
if {[catch {report_cdc -details -file [file join $out cdc.rpt]} err]} {
  puts "WARN report_cdc: $err"
}
report_timing_summary -delay_type min_max -max_paths 1 -file [file join $out timing_cdc_check.rpt]
puts "MIG_TX_CDC_REPORT_DONE"
exit
