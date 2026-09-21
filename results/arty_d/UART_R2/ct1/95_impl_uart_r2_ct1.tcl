# Impl unique CT1 identity. NEW dir. Does not overwrite build_u33obs_query.
# PROGRAM=NO. Not TIMING_PASS. Not PACK_ABI_24_24_PASS.
set out {D:/FPGA/arty_d/UART_R2/build_ct1}
set xdc {D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT/rtl/native_ai/board/arty_a7_mig_cdc.xdc}
set xdc_clr {D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT/rtl/native_ai/board/arty_a7_mig_clear_cdc.xdc}
set xdc_tap {D:/FPGA/arty_d/UART_R2/u33obs/u33obs_tap_cdc.xdc}
set xdc_q {D:/FPGA/arty_d/UART_R2/u33obs_query/u33obs_tap_cdc.xdc}
set xdc_ct1 {D:/FPGA/arty_d/UART_R2/ct1/ct1_lookup_cdc.xdc}

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
  puts $fh "PROGRAM=NO"
  close $fh
  puts "uart_r2_ct1_ABORT $cut $msg"
  exit 1
}

set outn [file normalize $out]
if {$outn ne [file normalize {D:/FPGA/arty_d/UART_R2/build_ct1}]} { r2_fail WRONG_OUT $outn }
file mkdir $out
file mkdir [file join $out reports]
set dcp [file join $out post_synth.dcp]
if {![file exists $dcp]} { r2_fail SYNTH_DCP_MISSING $dcp }
open_checkpoint $dcp
read_xdc $xdc
read_xdc $xdc_clr
read_xdc $xdc_tap
read_xdc $xdc_q
read_xdc $xdc_ct1
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
report_drc -file [file join $out reports drc_route.rpt]
report_methodology -file [file join $out reports methodology_route.rpt]
check_timing -verbose -file [file join $out reports check_timing.rpt]
catch {report_cdc -file [file join $out reports cdc_route.rpt]}
set wns "NA"
set whs "NA"
catch {set wns [get_property SLACK [lindex [get_timing_paths -setup -max_paths 1] 0]]}
catch {set whs [get_property SLACK [lindex [get_timing_paths -hold -max_paths 1] 0]]}
set fh [open [file join $out BUILD.txt] w]
puts $fh "STATUS=ROUTE_DONE"
puts $fh "OUT=$out"
puts $fh "CLASS=uart_r2_ct1_CANDIDATE"
puts $fh "NOT_OVERWRITE_8fc14f25=YES"
puts $fh "WNS=$wns"
puts $fh "WHS=$whs"
puts $fh "PROGRAM_PASS=NO"
puts $fh "TIMING_PASS=NO"
puts $fh "PACK_ABI_24_24_PASS=NO"
puts $fh "READY_TO_PROGRAM=NO"
puts $fh "PROGRAM=NO"
close $fh
puts "uart_r2_ct1_ROUTE_OK path=$out WNS=$wns WHS=$whs TIMING_PASS=NO PROGRAM=NO"
exit 0
