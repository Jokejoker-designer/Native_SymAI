# Program H-ILA-A debug bit, handshake with uart_ila_a_h11.py, capture first
# uart_rx falling after CLEAR ACK, dump probes. Does not write identity H PROGRAM.txt.
# Not BOARD_PASS / PROGRAM_PASS / PACK_ABI_24_24_PASS.
set out {D:/FPGA/arty_d/H_ILA_A}
set bitfile [file join $out arty_a7_r2_top_m4_mig_clear_ila_a.bit]
set ltx [file join $out debug_nets.ltx]
set want_jtag {210319BE776EA}
set refuse_sha {cf62102f21bd146976779e45dec77f912790da1000327fbc505941cdef4e7fc9}

proc cap_fail {cut msg} {
  global out
  set fh [open [file join $out CAPTURE.txt] w]
  puts $fh "STATUS=ABORTED"
  puts $fh "CUT=$cut"
  puts $fh "MSG=$msg"
  puts $fh "PROGRAM_PASS=NO"
  puts $fh "BOARD_PASS=NOT_EVIDENCED"
  close $fh
  puts "ILA_A_CAP_ABORT $cut $msg"
  catch {close_hw_target}
  catch {disconnect_hw_server}
  catch {close_hw_manager}
  exit 1
}

proc write_flag {name} {
  global out
  set fh [open [file join $out $name] w]
  puts $fh [clock format [clock seconds] -gmt 1 -format {%Y-%m-%dT%H:%M:%SZ}]
  close $fh
}

proc wait_flag {name timeout_s} {
  global out
  set p [file join $out $name]
  set t0 [clock seconds]
  while {![file exists $p]} {
    if {([clock seconds] - $t0) > $timeout_s} { return 0 }
    after 50
  }
  return 1
}

if {![file exists $bitfile]} { cap_fail BIT_MISSING $bitfile }
if {![file exists $ltx]} { cap_fail LTX_MISSING $ltx }
set raw [exec certutil -hashfile $bitfile SHA256]
set hash_out ""
foreach line [split $raw "\n"] {
  set t [string trim $line]
  if {[regexp {^[0-9a-fA-F]{64}$} $t]} { set hash_out [string tolower $t] }
}
if {$hash_out eq $refuse_sha} { cap_fail REFUSE_IDENTITY_H $hash_out }
puts "ILA_A_BIT_SHA $hash_out"

foreach f {SETUP_DONE GO_ARM ARMED CAPTURE_DONE} {
  catch {file delete -force [file join $out $f]}
}

open_hw_manager
connect_hw_server
set all_tgts [get_hw_targets]
puts "HW_TARGETS=$all_tgts"
set found 0
set tgt ""
foreach t $all_tgts {
  if {[string match *1234-TUL* $t] || [string match *xc7z020* $t]} {
    cap_fail REFUSE_PYNQ $t
  }
  if {[string match *$want_jtag* $t]} {
    set found 1
    set tgt $t
  }
}
if {!$found} { cap_fail JTAG_SERIAL "want $want_jtag not in $all_tgts" }

# JTAG < debug-hub/2.5. Hub ~100 MHz -> JTAG < 40 MHz.
catch {set_property PARAM.FREQUENCY 10000000 $tgt}
open_hw_target $tgt
set a7 [get_hw_devices -quiet xc7a100t_0]
if {![llength $a7]} { cap_fail DEVICE "no xc7a100t_0 devices=[get_hw_devices]" }
current_hw_device [lindex $a7 0]
set_property PROGRAM.FILE $bitfile [current_hw_device]
set_property PROBES.FILE $ltx [current_hw_device]
puts "PROGRAM_BEGIN file=$bitfile target=$tgt"
program_hw_devices [current_hw_device]
refresh_hw_device [current_hw_device]
set prog_done "NA"
catch {set prog_done [get_property PROGRAM.DONE [current_hw_device]]}
puts "PROGRAM.DONE=$prog_done"
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

set ilas [get_hw_ilas]
puts "HW_ILAS=$ilas"
if {![llength $ilas]} { cap_fail NO_ILA "debug hub/ILA not discovered" }
current_hw_ila [lindex $ilas 0]
reset_hw_ila [current_hw_ila]
set_property CONTROL.TRIGGER_POSITION 1024 [current_hw_ila]
set_property CONTROL.DATA_DEPTH 32768 [current_hw_ila]
set_property CONTROL.TRIGGER_MODE BASIC_ONLY [current_hw_ila]
set_property CONTROL.CAPTURE_MODE ALWAYS [current_hw_ila]

set ph [open [file join $out hw_probes.txt] w]
foreach p [get_hw_probes] {
  set nm [get_property NAME $p]
  set w  [get_property CORE.PROBE_WIDTH $p]
  puts $ph "$nm width=$w"
  puts "PROBE $nm width=$w"
}
close $ph

set trigp ""
foreach p [get_hw_probes] {
  set nm [get_property NAME $p]
  if {[string match *rx_d* $nm] || [string match *probe0* $nm]} {
    set trigp $p
    break
  }
}
if {$trigp eq ""} {
  foreach p [get_hw_probes] {
    set nm [get_property NAME $p]
    if {[string match *uart_rx* $nm] && [get_property CORE.PROBE_WIDTH $p] == 1} {
      set trigp $p
      break
    }
  }
}
if {$trigp eq ""} { set trigp [lindex [get_hw_probes] 0] }
puts "TRIG_PROBE [get_property NAME $trigp]"
catch {set_property TRIGGER_COMPARE_VALUE eq1'bF $trigp}
catch {set_property COMPARE_VALUE.0 eq1'bF $trigp}

write_flag SETUP_DONE
puts "SETUP_DONE waiting GO_ARM"
if {![wait_flag GO_ARM 90]} { cap_fail GO_ARM_TIMEOUT "host did not finish CLEAR ACK" }

run_hw_ila [current_hw_ila]
write_flag ARMED
puts "ILA_ARMED waiting trigger"
if {[catch {wait_on_hw_ila -timeout 20000 [current_hw_ila]} err]} {
  cap_fail WAIT_ILA $err
}
catch {puts "ILA_CONTROL_WINDOW [get_property CONTROL.WINDOW_COUNT [current_hw_ila]]"}

if {[catch {current_hw_ila_data [upload_hw_ila_data [current_hw_ila]]} err]} {
  cap_fail UPLOAD $err
}
set ilafile [file join $out capture.ila]
catch {write_hw_ila_data -force $ilafile [current_hw_ila_data]}
set csvfile [file join $out capture.csv]
if {[catch {write_hw_ila_data -force -csv $csvfile [current_hw_ila_data]} csverr]} {
  puts "CSV_WARN $csverr"
}

set dump [open [file join $out capture_samples.txt] w]
foreach p [get_hw_probes] {
  set nm [get_property NAME $p]
  if {[catch {set samp [list_hw_samples $p]} e]} {
    puts $dump "PROBE $nm ERROR $e"
    continue
  }
  puts $dump "PROBE $nm N=[llength $samp]"
  puts $dump $samp
}
close $dump
write_flag CAPTURE_DONE
set fh [open [file join $out CAPTURE.txt] w]
puts $fh "STATUS=CAPTURED"
puts $fh "SHA256=$hash_out"
puts $fh "TRIG=[get_property NAME $trigp]"
puts $fh "ILA=[file join $out capture.ila]"
puts $fh "CSV=$csvfile"
puts $fh "PROGRAM_PASS=NO"
puts $fh "BOARD_PASS=NOT_EVIDENCED"
close $fh
puts "ILA_A_CAPTURE_DONE"
catch {close_hw_target}
catch {disconnect_hw_server}
catch {close_hw_manager}
exit 0
