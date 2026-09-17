# Place/route arty_a7_mig_top from post_synth.dcp. CANDIDATE. PROGRAM=NO.
# Not MIG_PASS / BOARD_PASS / TIMING_PASS. No bitstream.
set out {D:/FPGA/arty_d/mig_bind}
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
report_drc -file [file join $out reports drc_route.rpt]
puts "ARTY_MIG_ROUTE_DONE"
exit
