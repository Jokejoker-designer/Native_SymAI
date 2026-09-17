# Place/route VALIDATION_CLEAR candidate. Writes post_route_clear.dcp
# Do not overwrite D:/FPGA/arty_d/m4_mig/post_route.dcp
set out {D:/FPGA/arty_d/m4_mig_clear}
set xdc {D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT/rtl/native_ai/board/arty_a7_mig_cdc.xdc}
set xdc_clr {D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT/rtl/native_ai/board/arty_a7_mig_clear_cdc.xdc}
file mkdir [file join $out reports]
open_checkpoint [file join $out post_synth.dcp]
read_xdc $xdc
read_xdc $xdc_clr
opt_design
place_design
phys_opt_design
route_design
write_checkpoint -force [file join $out post_route_clear.dcp]
report_utilization -file [file join $out reports util_route.rpt]
report_timing_summary -delay_type min_max -max_paths 10 -file [file join $out reports timing_route.rpt]
report_timing -max_paths 5 -file [file join $out reports crit_route.rpt]
report_timing -hold -max_paths 5 -file [file join $out reports hold_route.rpt]
report_cdc -file [file join $out reports cdc_route.rpt]
report_route_status -file [file join $out reports route_status.rpt]
report_drc -file [file join $out reports drc_route.rpt]
report_methodology -file [file join $out reports methodology_route.rpt]
puts "M4_MIG_CLEAR_ROUTE_DONE"
exit
