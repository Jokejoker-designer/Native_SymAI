# Bitstream U33OBS rg_off. NEW dir. Does not overwrite U33/H/U33OBS 71b9198f.
# PROGRAM=NO. Not PACK_ABI_24_24_PASS. Not TIMING_PASS.
set out {D:/FPGA/arty_d/UART_R2/build_u33obs_rgoff}
set bitfile [file join $out uart_r2_u33obs_rgoff_candidate.bit]
set old_obs {D:/FPGA/arty_d/UART_R2/build_u33obs/uart_r2_u33obs_candidate.bit}

proc r2_fail {cut msg} {
  global out
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
if {[string match *uart_r2_u33_candidate* $bitfile] || [string match *m4_mig* $bitfile]} {
  r2_fail FORBIDDEN_BITNAME $bitfile
}
if {[file normalize $bitfile] eq [file normalize $old_obs]} { r2_fail OVERWRITE_OLD_OBS $bitfile }
set dcp [file join $out post_route.dcp]
if {![file exists $dcp]} { r2_fail ROUTE_DCP_MISSING $dcp }
open_checkpoint $dcp
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
write_bitstream -force $bitfile
puts "uart_r2_u33obs_rgoff_BIT_OK path=$bitfile PROGRAM=NO"
exit 0
