# OOC synth fem_media_sys. CANDIDATE. Not FEM_PERSIST_PASS. OOC != integrated timing.
set root [file normalize {D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT}]
set out {D:/FPGA/arty_d/ooc_fem_crcpipe}
file mkdir $out
file mkdir [file join $out reports]
cd $out
create_project -in_memory -part xc7a100tcsg324-1
set rtl [file join $root rtl native_ai memory]
read_verilog [file join $rtl fem_lifecycle.v]
read_verilog [file join $rtl fem_media_bridge.v]
read_verilog [file join $rtl fem_t2_adapter.v]
read_verilog [file join $rtl fem_t2_ce.v]
read_verilog [file join $rtl fem_media_sys.v]
synth_design -mode out_of_context -top fem_media_sys -part xc7a100tcsg324-1
create_clock -period 10.000 [get_ports clk]
report_utilization -file [file join $out reports util.rpt]
report_timing_summary -file [file join $out reports timing.rpt]
report_timing -max_paths 5 -file [file join $out reports crit.rpt]
puts "OOC_FEM_MEDIA_SYS_DONE"
exit
