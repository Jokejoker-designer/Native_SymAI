# Program H-ILA-A observe debug bit. Does not write identity H PROGRAM.txt.
# Not BOARD_PASS / PROGRAM_PASS / PACK_ABI_24_24_PASS.
set out {D:/FPGA/arty_d/H_ILA_A}
set bitfile [file join $out arty_a7_r2_top_m4_mig_clear_ila_a.bit]
set want_jtag {210319BE776EA}
set refuse_sha {cf62102f21bd146976779e45dec77f912790da1000327fbc505941cdef4e7fc9}

proc prog_fail {cut msg} {
  global out
  set fh [open [file join $out PROGRAM.txt] w]
  puts $fh "STATUS=ABORTED"
  puts $fh "CUT=$cut"
  puts $fh "MSG=$msg"
  puts $fh "PROGRAM_PASS=NO"
  puts $fh "BOARD_PASS=NOT_EVIDENCED"
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
if {$hash_out eq $refuse_sha} { prog_fail REFUSE_IDENTITY_H $hash_out }
puts "ILA_A_BIT_SHA $hash_out"

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
if {!$found} { prog_fail JTAG_SERIAL "want $want_jtag not in $all_tgts" }
open_hw_target $tgt
set a7 [get_hw_devices -quiet xc7a100t_0]
if {![llength $a7]} { prog_fail DEVICE "no xc7a100t_0 devices=[get_hw_devices]" }
current_hw_device [lindex $a7 0]
refresh_hw_device -update_hw_probes false [current_hw_device]
set_property PROGRAM.FILE $bitfile [current_hw_device]
puts "PROGRAM_BEGIN file=$bitfile target=$tgt"
program_hw_devices [current_hw_device]
refresh_hw_device [current_hw_device]
set prog_done "NA"
catch {set prog_done [get_property PROGRAM.DONE [current_hw_device]]}
set pfh [open [file join $out PROGRAM.txt] w]
puts $pfh "STATUS=PROGRAMMED"
puts $pfh "FILE=$bitfile"
puts $pfh "SHA256=$hash_out"
puts $pfh "TARGET=$tgt"
puts $pfh "JTAG=$want_jtag"
puts $pfh "PROGRAM.DONE=$prog_done"
puts $pfh "CLASS=H_ILA_A_DEBUG_ONLY"
puts $pfh "IDENTITY_H_UNTOUCHED=YES"
puts $pfh "PROGRAM_PASS=NO"
puts $pfh "BOARD_PASS=NOT_EVIDENCED"
close $pfh
puts "ILA_A_PROGRAM_DONE sha=$hash_out done=$prog_done"
catch {close_hw_target}
catch {disconnect_hw_server}
catch {close_hw_manager}
exit 0
