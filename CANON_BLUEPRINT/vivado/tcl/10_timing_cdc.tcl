# Apply CDC exceptions on existing mig_bind post_synth.dcp. CANDIDATE.
# PROGRAM=NO. Not TIMING_PASS. Open-checkpoint != re-synth.
set out {D:/FPGA/arty_d/mig_bind}
set xdc {D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT/rtl/native_ai/board/arty_a7_mig_cdc.xdc}
open_checkpoint [file join $out post_synth.dcp]
read_xdc $xdc
report_timing_summary -delay_type min_max -max_paths 10 -file [file join $out reports timing_cdc.rpt]
report_timing -max_paths 5 -file [file join $out reports crit_cdc.rpt]
puts "ARTY_MIG_CDC_TIMING_DONE"
exit
