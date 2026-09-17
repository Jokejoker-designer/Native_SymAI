# OOC synth FE256_HW_R1 fe256_query_path xc7a100t. CANDIDATE. PROGRAM=NO.
# Isolated from R0 fe256_ooc and frozen r2_top. Gold oracle not imported.
set root {D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT}
set out {D:/FPGA/arty_d/fe256_ooc_r1}
file mkdir $out
file mkdir [file join $out reports]
cd $out
file copy -force [file join $root rtl native_ai fe256 fe256_store.mem] [file join $out fe256_store.mem]
file copy -force [file join $root verification fe256 fe256_abi_constants.svh] [file join $out fe256_abi_constants.svh]
create_project -in_memory -part xc7a100tcsg324-1
set_property include_dirs [list $out [file join $root verification fe256]] [current_fileset]
read_verilog -sv [file join $root rtl native_ai fe256 fe256_query_path.sv]
synth_design -mode out_of_context -top fe256_query_path -part xc7a100tcsg324-1 -flatten_hierarchy rebuilt
create_clock -period 10.000 -name clk [get_ports clk]
write_checkpoint -force [file join $out post_synth.dcp]
report_utilization -file [file join $out reports util.rpt]
report_timing_summary -delay_type min_max -max_paths 5 -file [file join $out reports timing.rpt]
report_timing -max_paths 5 -file [file join $out reports crit.rpt]
check_timing -file [file join $out reports check_timing.rpt]
puts "FE256_HW_R1_OOC_SYNTH_DONE"
exit
