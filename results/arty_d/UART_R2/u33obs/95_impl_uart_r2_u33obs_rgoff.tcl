# Impl U33OBS rg_off. NEW dir. Does not overwrite build_u33obs.
# PROGRAM=NO. Not TIMING_PASS. Not PACK_ABI_24_24_PASS.
set out {D:/FPGA/arty_d/UART_R2/build_u33obs_rgoff}
set xdc {D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT/rtl/native_ai/board/arty_a7_mig_cdc.xdc}
set xdc_clr {D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT/rtl/native_ai/board/arty_a7_mig_clear_cdc.xdc}
set xdc_tap {D:/FPGA/arty_d/UART_R2/u33obs/u33obs_tap_cdc.xdc}

proc r2_fail {cut msg} {
  global out
  file mkdir $out
  set fh [open [file join $out BUILD.txt] w]
  puts $fh "STATUS=ABORTED"
  puts $fh "CUT=$cut"
  puts $fh "MSG=$msg"
  puts $fh "PROGRAM_PASS=NO"
  puts $fh "PACK_ABI_24_24_PASS=NO"
  puts $fh "READY_TO_PROGRAM=NO"
  close $fh
  puts "uart_r2_u33obs_rgoff_ABORT $cut $msg"
  exit 1
}

set outn [file normalize $out]
if {$outn ne [file normalize {D:/FPGA/arty_d/UART_R2/build_u33obs_rgoff}]} { r2_fail WRONG_OUT $outn }
file mkdir $out
file mkdir [file join $out reports]
set dcp [file join $out post_synth.dcp]
if {![file exists $dcp]} { r2_fail SYNTH_DCP_MISSING $dcp }
open_checkpoint $dcp
read_xdc $xdc
read_xdc $xdc_clr
read_xdc $xdc_tap
set ncell [llength [get_cells -quiet u_dump/u_cdc_tap/req_a_reg]]
puts "TAP_CDC_REQ_A_CELLS=$ncell"
if {$ncell < 1} { r2_fail TAP_CDC_CELLS_MISSING "u_dump/u_cdc_tap/req_a_reg not found" }
opt_design
place_design
phys_opt_design
route_design
write_checkpoint -force [file join $out post_route.dcp]
report_utilization -file [file join $out reports util_route.rpt]
report_timing_summary -delay_type min_max -max_paths 10 -file [file join $out reports timing_route.rpt]
report_timing -hold -max_paths 5 -file [file join $out reports hold_route.rpt]
set fh [open [file join $out BUILD.txt] w]
puts $fh "STATUS=ROUTE_DONE"
puts $fh "OUT=$out"
puts $fh "TAP_CDC_XDC_AT_IMPL=YES"
puts $fh "CLASS=uart_r2_u33obs_RGOFF_CANDIDATE"
puts $fh "NOT_OVERWRITE_U33OBS_71b9198f=YES"
puts $fh "PROGRAM_PASS=NO"
puts $fh "TIMING_PASS=NO"
puts $fh "PACK_ABI_24_24_PASS=NO"
puts $fh "READY_TO_PROGRAM=NO"
close $fh
puts "uart_r2_u33obs_rgoff_ROUTE_OK path=$out"
exit 0
