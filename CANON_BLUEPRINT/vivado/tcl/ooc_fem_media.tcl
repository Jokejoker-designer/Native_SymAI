# OOC synth for FEM media bridge. Not FEM_PERSIST_PASS. Not TIMING_PASS.
set root [file normalize [file join [file dirname [info script]] ../..]]
set out [file join $root vivado fem_media ooc]
file mkdir $out
create_project -in_memory -part xc7a100tcsg324-1
read_verilog [file join $root rtl native_ai memory fem_media_bridge.v]
read_verilog [file join $root rtl native_ai memory fem_commit_class.v]
synth_design -mode out_of_context -top fem_media_bridge -part xc7a100tcsg324-1
report_utilization -file [file join $out util.rpt]
create_clock -period 10.000 [get_ports clk]
report_timing_summary -file [file join $out timing.rpt]
report_timing -max_paths 3 -file [file join $out crit.rpt]
puts "OOC_FEM_MEDIA_DONE"
exit
