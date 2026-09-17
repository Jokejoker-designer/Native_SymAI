# Program H_OBS observe bit. Does not write identity H PROGRAM.txt.
# Refuses sha cf62102f. EXPLAINS_IDENTITY_H=NO.
set out {D:/FPGA/arty_d/H_OBS}
set bitfile [file join $out arty_a7_r2_top_m4_mig_clear_h_obs.bit]
set want_jtag {210319BE776EA}
set refuse_h {cf62102f21bd146976779e45dec77f912790da1000327fbc505941cdef4e7fc9}
set refuse_ila {b037b355a7098c99b9a995554756122e09569230d3b8d02698c255e6a64f8cef}

proc prog_fail {cut msg} {
  global out
  set fh [open [file join $out PROGRAM.txt] w]
  puts $fh "STATUS=ABORTED"
  puts $fh "CUT=$cut"
  puts $fh "MSG=$msg"
  puts $fh "PROGRAM_PASS=NO"
  puts $fh "EXPLAINS_IDENTITY_H=NO"
  close $fh
  puts "PROG_ABORT $cut $msg"
  catch {close_hw_target}
  catch {disconnect_hw_server}
  catch {close_hw_manager}
  exit 1
}

if {![file exists $bitfile]} { prog_fail BIT_MISSING $bitfile }
set raw [exec certutil -hashfile $bitfile SHA256]
set hash_out ""
foreach line [split $raw "\n"] {
  set t [string trim $line]
  if {[regexp {^[0-9a-fA-F]{64}$} $t]} { set hash_out [string tolower $t] }
}
if {$hash_out eq $refuse_h} { prog_fail REFUSE_IDENTITY_H $hash_out }
if {$hash_out eq $refuse_ila} { prog_fail REFUSE_H_ILA_A $hash_out }
puts "H_OBS_BIT_SHA $hash_out"

open_hw_manager
connect_hw_server
set tgt ""
foreach t [get_hw_targets] {
  if {[string match *$want_jtag* $t]} { set tgt $t }
}
if {$tgt eq ""} { prog_fail JTAG_SERIAL "want $want_jtag" }
open_hw_target $tgt
set a7 [get_hw_devices -quiet xc7a100t_0]
if {![llength $a7]} { prog_fail DEVICE "no xc7a100t_0" }
current_hw_device [lindex $a7 0]
refresh_hw_device -update_hw_probes false [current_hw_device]
set_property PROGRAM.FILE $bitfile [current_hw_device]
puts "PROGRAM_BEGIN file=$bitfile target=$tgt"
program_hw_devices [current_hw_device]
refresh_hw_device [current_hw_device]
set fh [open [file join $out PROGRAM.txt] w]
puts $fh "STATUS=PROGRAMMED"
puts $fh "FILE=$bitfile"
puts $fh "SHA256=$hash_out"
puts $fh "TARGET=$tgt"
puts $fh "JTAG=$want_jtag"
puts $fh "IDENTITY=H_OBS"
puts $fh "IDENTITY_H_UNTOUCHED=YES"
puts $fh "EXPLAINS_IDENTITY_H=NO"
puts $fh "H20_ROLE=CLASSIFIER_ONLY"
puts $fh "PROGRAM_PASS=NO"
puts $fh "BOARD_PASS=NOT_EVIDENCED"
close $fh
puts "H_OBS_PROGRAM_DONE sha=$hash_out EXPLAINS_IDENTITY_H=NO"
catch {close_hw_target}
catch {disconnect_hw_server}
catch {close_hw_manager}
exit 0
