# Program unique CT1 identity only. Requires tclargs OUTDIR OWNER_AUTHORIZED.
# SHA must be 8bfd993d…. Ban 8fc14f25 and all prior identities.
# PROGRAM_PASS=NO. PACK_ABI_24_24_PASS=NO. STOP if hash mismatch.
if {$argc < 2} {
  puts "ABORT ARGC need OUTDIR OWNER_AUTHORIZED"
  exit 1
}
set out [lindex $argv 0]
set auth [lindex $argv 1]
if {$auth ne "OWNER_AUTHORIZED"} {
  puts "ABORT AUTH $auth"
  exit 1
}
set bitfile {D:/FPGA/arty_d/UART_R2/build_ct1/uart_r2_ct1_candidate.bit}
set shafile {D:/FPGA/arty_d/UART_R2/build_ct1/SHA256.txt}
set want_fixed {8bfd993d6ebd754df0f97d96887d1a9dd3952aa56be695ae2b8f69fcf73c283c}
set want_jtag {210319BE776EA}
set ban_sha {
  8fc14f25f2b9d936b7d412ce41b6d963991cc91137c20587e3ab5a96b5224df5
  cf62102f21bd146976779e45dec77f912790da1000327fbc505941cdef4e7fc9
  f6a6091fccab5bdb331932195d34c984f3101cdf52d3959c172706b33ba368d7
  ff399e0bb9e6ff6c91caf3b769270b03ca9cfb2ea317035a5f3533031338a350
  0df4de2ec075bfdbe567bb661702da088a1be5322cc9112ad2ebf959d116f6ff
  c02c3343b7076a9ff2a95d88488a926130979396af5f46baa86b6164aaa0190c
  d448544f88f09d4c78990b08c2810928d00e9f319f0bf653966ddacdd8897d7f
  eb99ac69f07e582c1ac4b1a1da876bfa1a381310133b9fe7c7605bf9e766166b
  71b9198f512972bae75af04e406d26c17d7940ecadd324e5b5ffecaedcbf6762
  251eafa9451cabd83089fc5cba0c6351f1955c27a70dd9a60e7e2321f4910764
  bd541f9579dfe0e2ca1b9dc4e220818fe460e293e6a7c42c08ecf8652fc9b46f
  08c647ee850cb513f503448ea91c1461551450a145151f0fe02fb296f8137728
  99823c92122ac1e3bb16ddbc3885610a84b51cbb2e16416e94ccced91ac81099
}

proc prog_fail {cut msg} {
  global out
  file mkdir $out
  set fh [open [file join $out PROGRAM.txt] w]
  puts $fh "STATUS=ABORTED"
  puts $fh "CUT=$cut"
  puts $fh "MSG=$msg"
  puts $fh "BOARD_PASS=NOT_EVIDENCED"
  puts $fh "PROGRAM_PASS=NO"
  puts $fh "PACK_ABI_24_24_PASS=NO"
  puts $fh "CT1_BOARD_PASS=NO"
  puts $fh "READY_TO_PROGRAM=NO"
  close $fh
  puts "uart_r2_ct1_PROG_ABORT $cut $msg"
  catch {close_hw_target}
  catch {disconnect_hw_server}
  catch {close_hw_manager}
  exit 1
}

if {![file exists $shafile]} { prog_fail SHAFILE_MISSING $shafile }
set sfh [open $shafile r]
set want_sha [string trim [read $sfh]]
close $sfh
if {$want_sha ne $want_fixed} { prog_fail SHAFILE_NOT_CT1 "shafile=$want_sha want=$want_fixed" }

set outn [file normalize $out]
set outn_fwd [string map {\\ /} $outn]
if {![string match {*/UART_R2/results/*} $outn_fwd]} { prog_fail WRONG_OUT $outn }
if {[string match *U33OBS_QUERY* $outn_fwd] || [string match *build_u33obs_query* $outn_fwd]} {
  prog_fail FORBIDDEN_OUT $outn
}
set bitn [file normalize $bitfile]
set bitn_fwd [string map {\\ /} $bitn]
if {![string match {*/UART_R2/build_ct1/*} $bitn_fwd]} { prog_fail BIT_NOT_IN_CT1 $bitn }
if {[string match *u33obs_query* $bitn_fwd] || [string match *m4_mig* $bitn_fwd]} {
  prog_fail FORBIDDEN_BIT $bitn
}
if {![file exists $bitfile]} { prog_fail BIT_MISSING $bitfile }

set hash_out [exec python -c "import hashlib,sys; print(hashlib.sha256(open(sys.argv[1],'rb').read()).hexdigest())" $bitfile]
set hash_out [string trim $hash_out]
if {$hash_out ne $want_sha} { prog_fail SHA_MISMATCH "got $hash_out want $want_sha" }
if {$hash_out ne $want_fixed} { prog_fail SHA_NOT_FIXED "got $hash_out want $want_fixed" }
foreach b $ban_sha {
  if {$hash_out eq $b} { prog_fail OTHER_IDENTITY_SHA "sha $hash_out is banned identity" }
}
puts "uart_r2_ct1_SHA_OK $hash_out"

open_hw_manager
connect_hw_server
set all_tgts [get_hw_targets]
puts "HW_TARGETS=$all_tgts"
set found 0
set tgt ""
foreach t $all_tgts {
  if {[string match *1234-TUL* $t] || [string match *xc7z020* $t]} { prog_fail REFUSE_PYNQ $t }
  if {[string match *$want_jtag* $t]} { set found 1; set tgt $t }
}
if {!$found} { prog_fail JTAG_SERIAL "want $want_jtag not in $all_tgts" }
open_hw_target $tgt
set a7 [get_hw_devices -quiet xc7a100t_0]
if {![llength $a7]} { prog_fail DEVICE "no xc7a100t_0" }
current_hw_device [lindex $a7 0]
refresh_hw_device -update_hw_probes false [current_hw_device]
set_property PROGRAM.FILE $bitfile [current_hw_device]
puts "PROGRAM_BEGIN file=$bitfile target=$tgt sha=$hash_out"
program_hw_devices [current_hw_device]
refresh_hw_device [current_hw_device]
set done "NA"
set prog_done "NA"
catch {set done [get_property REGISTER.IR.STATUS [current_hw_device]]}
catch {set prog_done [get_property PROGRAM.DONE [current_hw_device]]}
puts "IR.STATUS=$done PROGRAM.DONE=$prog_done"
file mkdir $out
set pfh [open [file join $out PROGRAM.txt] w]
puts $pfh "STATUS=PROGRAMMED"
puts $pfh "FILE=$bitfile"
puts $pfh "SHA256=$hash_out"
puts $pfh "TARGET=$tgt"
puts $pfh "JTAG=$want_jtag"
puts $pfh "IR.STATUS=$done"
puts $pfh "PROGRAM.DONE=$prog_done"
puts $pfh "CLASS=uart_r2_ct1_CANDIDATE"
puts $pfh "BOARD_PASS=NOT_EVIDENCED"
puts $pfh "CT1_BOARD_PASS=NO"
puts $pfh "TIMING_PASS=NO"
puts $pfh "PACK_ABI_24_24_PASS=NO"
puts $pfh "PROGRAM_PASS=NO"
puts $pfh "RUNTIME_KNOWLEDGE_BINDING_8_8_PASS=NOT_RUN"
puts $pfh "NOT_8fc14f25=YES"
close $pfh
puts "uart_r2_ct1_PROGRAM_OK target=$tgt sha=$hash_out PROGRAM_PASS=NO"
catch {close_hw_target}
catch {disconnect_hw_server}
catch {close_hw_manager}
catch {exec taskkill /F /IM hw_server.exe}
catch {exec taskkill /F /IM cs_server.exe}
exit 0
