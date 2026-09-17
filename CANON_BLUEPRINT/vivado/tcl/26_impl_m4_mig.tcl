# FROZEN historical impl. Do NOT run: would overwrite post_route.dcp 91c9f084...
# CLEAR candidate uses 30_impl_m4_mig_clear.tcl -> post_route_clear.dcp
puts "REFUSE: 26_impl_m4_mig.tcl is historical. Use 30_impl_m4_mig_clear.tcl"
exit 1
# Place/route M4+mig0 candidate. PROGRAM=NO. No bitstream.
# Do not clobber freeze / mig_uiclk / mig_tx. Not MIG_PASS / TIMING_PASS.
set out {D:/FPGA/arty_d/m4_mig}
set xdc {D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT/rtl/native_ai/board/arty_a7_mig_cdc.xdc}
file mkdir [file join $out reports]
open_checkpoint [file join $out post_synth.dcp]
read_xdc $xdc
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
puts "M4_MIG_ROUTE_DONE"
exit
