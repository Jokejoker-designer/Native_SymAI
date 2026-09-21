# Bitstream unique CT1 identity. Does not overwrite 8fc14f25 / U33 / H.
# PROGRAM=NO. Does not call program_hw_devices. Not PACK_ABI_24_24_PASS.
set out {D:/FPGA/arty_d/UART_R2/build_ct1}
set bitfile [file join $out uart_r2_ct1_candidate.bit]
set live_query {D:/FPGA/arty_d/UART_R2/build_u33obs_query/uart_r2_u33obs_query_candidate.bit}

proc r2_fail {cut msg} {
  global out
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
if {[string match *u33obs_query* $bitfile] || [string match *m4_mig* $bitfile]} {
  r2_fail FORBIDDEN_BITNAME $bitfile
}
if {[file normalize $bitfile] eq [file normalize $live_query]} { r2_fail OVERWRITE_LIVE_QUERY $bitfile }
set dcp [file join $out post_route.dcp]
if {![file exists $dcp]} { r2_fail ROUTE_DCP_MISSING $dcp }
open_checkpoint $dcp
set wns "NA"
catch {set wns [get_property SLACK [lindex [get_timing_paths -setup -max_paths 1] 0]]}
if {![string is double -strict $wns] || $wns < 0} { r2_fail SETUP_NOT_MET "WNS=$wns" }
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
write_bitstream -force $bitfile
set fh [open [file join $out BUILD.txt] w]
puts $fh "STATUS=BIT_OK"
puts $fh "OUT=$out"
puts $fh "BIT=$bitfile"
puts $fh "CLASS=uart_r2_ct1_CANDIDATE"
puts $fh "WNS=$wns"
puts $fh "PROGRAM_PASS=NO"
puts $fh "TIMING_PASS=NO"
puts $fh "PACK_ABI_24_24_PASS=NO"
puts $fh "READY_TO_PROGRAM=NO"
puts $fh "PROGRAM=NO"
puts $fh "STOP_BEFORE_PROGRAM=YES"
close $fh
set sha [exec python -c "import hashlib,sys; print(hashlib.sha256(open(sys.argv[1],'rb').read()).hexdigest())" $bitfile]
set sha [string trim $sha]
set sfh [open [file join $out SHA256.txt] w]
puts $sfh $sha
close $sfh
puts "uart_r2_ct1_BIT_OK path=$bitfile sha=$sha PROGRAM=NO STOP_BEFORE_PROGRAM=YES"
exit 0
