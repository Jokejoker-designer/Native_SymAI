# OOC synth query_result_bind xc7a100t 100 MHz. CANDIDATE. PROGRAM=NO.
set root {D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT}
set out {D:/FPGA/arty_d/m4_query_result_ooc}
file mkdir $out
file mkdir [file join $out reports]
cd $out
file copy -force [file join $root rtl native_ai directory dir_a.mem] [file join $out dir_a.mem]
file copy -force [file join $root rtl native_ai directory post_a.mem] [file join $out post_a.mem]
create_project -in_memory -part xc7a100tcsg324-1
read_verilog -sv [file join $root rtl native_ai directory exact_directory.sv]
read_verilog -sv [file join $root rtl native_ai directory posting_walk.sv]
read_verilog -sv [file join $root rtl native_ai directory bounded_walk.sv]
read_verilog -sv [file join $root rtl native_ai directory query_walk_bind.sv]
read_verilog -sv [file join $root rtl native_ai astra astra_qeval.sv]
read_verilog -sv [file join $root rtl native_ai directory query_result_bind.sv]
synth_design -mode out_of_context -top query_result_bind -part xc7a100tcsg324-1 -flatten_hierarchy rebuilt
create_clock -period 10.000 -name clk [get_ports clk]
write_checkpoint -force [file join $out post_synth.dcp]
report_utilization -file [file join $out reports util.rpt]
report_timing_summary -delay_type min_max -max_paths 5 -file [file join $out reports timing.rpt]
report_timing -max_paths 5 -file [file join $out reports crit.rpt]
puts "M4_QUERY_RESULT_OOC_SYNTH_DONE"
exit
