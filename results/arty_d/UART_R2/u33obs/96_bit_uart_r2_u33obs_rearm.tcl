# Bitstream U33OBS steer. NEW dir. Does not overwrite U33/H/U33OBS 71b9198f.
# PROGRAM=NO. Not PACK_ABI_24_24_PASS. Not TIMING_PASS.
set out {D:/FPGA/arty_d/UART_R2/build_u33obs_rearm}
set bitfile [file join $out uart_r2_u33obs_rearm_candidate.bit]
set old_obs {D:/FPGA/arty_d/UART_R2/build_u33obs/uart_r2_u33obs_candidate.bit}
set steer_obs {D:/FPGA/arty_d/UART_R2/build_u33obs_steer/uart_r2_u33obs_steer_candidate.bit}
set rgoff_obs {D:/FPGA/arty_d/UART_R2/build_u33obs_rgoff/uart_r2_u33obs_rgoff_candidate.bit}

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
  puts "uart_r2_u33obs_rearm_ABORT $cut $msg"
  exit 1
}

set outn [file normalize $out]
if {$outn ne [file normalize {D:/FPGA/arty_d/UART_R2/build_u33obs_rearm}]} { r2_fail WRONG_OUT $outn }
if {[string match *uart_r2_u33_candidate* $bitfile] || [string match *m4_mig* $bitfile]} {
  r2_fail FORBIDDEN_BITNAME $bitfile
}
if {[file normalize $bitfile] eq [file normalize $old_obs]} { r2_fail OVERWRITE_OLD_OBS $bitfile }
if {[file normalize $bitfile] eq [file normalize $steer_obs]} { r2_fail OVERWRITE_STEER $bitfile }
if {[file normalize $bitfile] eq [file normalize $rgoff_obs]} { r2_fail OVERWRITE_RGOFF $bitfile }
set dcp [file join $out post_route.dcp]
if {![file exists $dcp]} { r2_fail ROUTE_DCP_MISSING $dcp }
open_checkpoint $dcp
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
write_bitstream -force $bitfile
set fh [open [file join $out BUILD.txt] w]
puts $fh "STATUS=BIT_OK"
puts $fh "OUT=$out"
puts $fh "BIT=$bitfile"
puts $fh "CLASS=uart_r2_u33obs_REARM_CANDIDATE"
puts $fh "PROGRAM_PASS=NO"
puts $fh "PACK_ABI_24_24_PASS=NO"
puts $fh "READY_TO_PROGRAM=NO"
close $fh
set sha [exec python -c "import hashlib,sys; print(hashlib.sha256(open(sys.argv[1],'rb').read()).hexdigest())" $bitfile]
set sha [string trim $sha]
set sfh [open [file join $out SHA256.txt] w]
puts $sfh $sha
close $sfh
puts "uart_r2_u33obs_rearm_BIT_OK path=$bitfile sha=$sha PROGRAM=NO"
exit 0
