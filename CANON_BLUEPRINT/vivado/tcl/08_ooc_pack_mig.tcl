# OOC synth pack_mig_bind (loader + mig_ui32). CANDIDATE. Not MIG_PASS.
# OOC != integrated. PROGRAM=NO.
set root [file normalize {D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT}]
set out {D:/FPGA/arty_d/ooc_pack_mig}
file mkdir $out
file mkdir [file join $out reports]
cd $out
create_project -in_memory -part xc7a100tcsg324-1
read_verilog -sv [file join $root rtl native_ai common crc32_iso_hdlc.sv]
read_verilog -sv [file join $root rtl native_ai loader pack_loader.sv]
read_verilog -sv [file join $root rtl native_ai memory mig_ui32.sv]
read_verilog -sv [file join $root rtl native_ai memory pack_mig_bind.sv]
synth_design -mode out_of_context -top pack_mig_bind -part xc7a100tcsg324-1
create_clock -period 10.000 [get_ports clk]
report_utilization -file [file join $out reports util.rpt]
report_timing_summary -file [file join $out reports timing.rpt]
report_timing -max_paths 5 -file [file join $out reports crit.rpt]
puts "OOC_PACK_MIG_DONE"
exit
