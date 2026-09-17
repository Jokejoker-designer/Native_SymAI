# OOC synth mig_ui32. CANDIDATE. Not MIG_PASS. OOC != integrated.
set root [file normalize {D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT}]
set out {D:/FPGA/arty_d/ooc_mig_ui32}
file mkdir $out
file mkdir [file join $out reports]
cd $out
create_project -in_memory -part xc7a100tcsg324-1
read_verilog -sv [file join $root rtl native_ai memory mig_ui32.sv]
synth_design -mode out_of_context -top mig_ui32 -part xc7a100tcsg324-1
create_clock -period 10.000 [get_ports clk]
report_utilization -file [file join $out reports util.rpt]
report_timing_summary -file [file join $out reports timing.rpt]
puts "OOC_MIG_UI32_DONE"
exit
