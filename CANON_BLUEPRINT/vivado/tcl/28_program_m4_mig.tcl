# Program M4+mig0 candidate onto Arty A7-100T.
# Owner granted PROGRAM=YES. Not BOARD_PASS / MIG_PASS / TIMING_PASS.
# Do not program freeze DCPs. Refuse PYNQ / wrong device.
set out {D:/FPGA/arty_d/m4_mig}
set bitfile [file join $out arty_a7_r2_top_m4_mig_candidate.bit]
set want_sha {f6a6091fccab5bdb331932195d34c984f3101cdf52d3959c172706b33ba368d7}
set want_jtag {210319BE776EA}

proc prog_fail {cut msg} {
  global out
  set fh [open [file join $out PROGRAM.txt] w]
  puts $fh "STATUS=ABORTED"
  puts $fh "CUT=$cut"
  puts $fh "MSG=$msg"
  puts $fh "BOARD_PASS=NOT_EVIDENCED"
  puts $fh "PROGRAM_PASS=NO"
  close $fh
  puts "PROG_ABORT $cut $msg"
  catch {close_hw_target}
  catch {disconnect_hw_server}
  catch {close_hw_manager}
  exit 1
}

if {![file exists $bitfile]} { prog_fail BIT_MISSING $bitfile }
set hash_out [exec python -c "import hashlib,sys; p=sys.argv[1]; print(hashlib.sha256(open(p,'rb').read()).hexdigest())" $bitfile]
set hash_out [string trim $hash_out]
if {$hash_out ne $want_sha} {
  prog_fail SHA_MISMATCH "got $hash_out want $want_sha"
}
puts "BIT_SHA_OK $hash_out"

open_hw_manager
connect_hw_server
set all_tgts [get_hw_targets]
puts "HW_TARGETS=$all_tgts"
set found 0
set tgt ""
foreach t $all_tgts {
  if {[string match *1234-TUL* $t] || [string match *xc7z020* $t]} {
    prog_fail REFUSE_PYNQ $t
  }
  if {[string match *$want_jtag* $t]} {
    set found 1
    set tgt $t
  }
}
if {!$found} {
  prog_fail JTAG_SERIAL "want $want_jtag not in $all_tgts"
}
open_hw_target $tgt
set devs [get_hw_devices]
puts "HW_DEVICES=$devs"
set a7 [get_hw_devices -quiet xc7a100t_0]
if {![llength $a7]} {
  prog_fail DEVICE "no xc7a100t_0 devices=$devs"
}
foreach d $devs {
  set nm [get_property NAME $d]
  if {[string match *xc7z020* $nm] || [string match *arm* $nm]} {
    prog_fail REFUSE_ZYNQ $nm
  }
}
current_hw_device [lindex $a7 0]
refresh_hw_device -update_hw_probes false [current_hw_device]
set_property PROGRAM.FILE $bitfile [current_hw_device]
puts "PROGRAM_BEGIN file=$bitfile target=$tgt device=[current_hw_device] sha=$hash_out"
program_hw_devices [current_hw_device]
refresh_hw_device [current_hw_device]
set done "NA"
set prog_done "NA"
catch {set done [get_property REGISTER.IR.STATUS [current_hw_device]]}
catch {set prog_done [get_property PROGRAM.DONE [current_hw_device]]}
puts "IR.STATUS=$done PROGRAM.DONE=$prog_done"
set pfh [open [file join $out PROGRAM.txt] w]
puts $pfh "STATUS=PROGRAMMED"
puts $pfh "FILE=$bitfile"
puts $pfh "SHA256=$hash_out"
puts $pfh "TARGET=$tgt"
puts $pfh "DEVICE=[current_hw_device]"
puts $pfh "JTAG=$want_jtag"
puts $pfh "IR.STATUS=$done"
puts $pfh "PROGRAM.DONE=$prog_done"
puts $pfh "BOARD_PASS=NOT_EVIDENCED"
puts $pfh "MIG_PASS=NO"
puts $pfh "TIMING_PASS=NO"
puts $pfh "PROGRAM_PASS=NO"
puts $pfh "OWNER_AUTH=PROGRAM=YES"
close $pfh
puts "M4_MIG_PROGRAM_DONE target=$tgt sha=$hash_out done=$prog_done"
catch {close_hw_target}
catch {disconnect_hw_server}
catch {close_hw_manager}
exit 0
