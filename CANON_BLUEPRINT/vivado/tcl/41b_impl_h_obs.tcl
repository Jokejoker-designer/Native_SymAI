# H_OBS impl from post_synth DCP. H_OBS != identity H.
# Resume after Vivado 2026.1 ACCESS_VIOLATION in opt_design Phase 3 Retarget.
# Writes ONLY under D:/FPGA/arty_d/H_OBS. Does not open m4_mig_clear DCP.
# Refuses sha cf62102f / b037b355. EXPLAINS_IDENTITY_H=NO.
set out {D:/FPGA/arty_d/H_OBS}
set dcp [file join $out post_synth_h_obs.dcp]
set root [file normalize {D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT}]
set rtl [file join $root rtl native_ai]

proc obs_fail {cut msg} {
  global out
  set fh [open [file join $out BUILD.txt] w]
  puts $fh "STATUS=ABORTED"
  puts $fh "CUT=$cut"
  puts $fh "MSG=$msg"
  puts $fh "PROGRAM_PASS=NO"
  puts $fh "BOARD_PASS=NOT_EVIDENCED"
  puts $fh "EXPLAINS_IDENTITY_H=NO"
  close $fh
  puts "H_OBS_ABORT $cut $msg"
  exit 2
}

if {![file exists $dcp]} { obs_fail SYNTH_DCP $dcp }
file mkdir [file join $out reports]
cd $out
open_checkpoint $dcp
# Skip -retarget: first batch died EXCEPTION_ACCESS_VIOLATION there.
opt_design -propconst -sweep -shift_register_opt -control_set_merge
puts "H_OBS_OPT_DONE"
place_design
phys_opt_design
route_design
write_checkpoint -force [file join $out post_route_h_obs.dcp]
report_timing_summary -delay_type min_max -max_paths 5 -file [file join $out reports timing_route.rpt]
report_utilization -file [file join $out reports util_route.rpt]
set wns "NA"
catch {set wns [get_property SLACK [lindex [get_timing_paths -quiet -delay_type max -max_paths 1] 0]]}
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set bitfile [file join $out arty_a7_r2_top_m4_mig_clear_h_obs.bit]
write_bitstream -force $bitfile
set raw [exec certutil -hashfile $bitfile SHA256]
set hash_out ""
foreach line [split $raw "\n"] {
  set t [string trim $line]
  if {[regexp {^[0-9a-fA-F]{64}$} $t]} { set hash_out [string tolower $t] }
}
if {$hash_out eq {cf62102f21bd146976779e45dec77f912790da1000327fbc505941cdef4e7fc9}} {
  obs_fail REFUSE_IDENTITY_H $hash_out
}
if {$hash_out eq {b037b355a7098c99b9a995554756122e09569230d3b8d02698c255e6a64f8cef}} {
  obs_fail REFUSE_H_ILA_A $hash_out
}
set fh [open [file join $out BUILD.txt] w]
puts $fh "STATUS=BUILT"
puts $fh "FILE=$bitfile"
puts $fh "SHA256=$hash_out"
puts $fh "WNS=$wns"
puts $fh "SYNTH_DCP_SHA256=ca77d6cdf5e76348a688f8eab12e6ee72b80e7421be19c767f3aefb349142c81"
puts $fh "OPT=NO_RETARGET_WORKAROUND"
puts $fh "ILA_IP=NO_BASIC_LICENSE"
puts $fh "PROBE=uart_dump_pack_side"
puts $fh "IDENTITY=H_OBS"
puts $fh "IDENTITY_H_UNTOUCHED=YES"
puts $fh "EXPLAINS_IDENTITY_H=NO"
puts $fh "H20_ROLE=CLASSIFIER_ONLY"
puts $fh "PROGRAM_PASS=NO"
puts $fh "BOARD_PASS=NOT_EVIDENCED"
close $fh
puts "H_OBS_BUILD_DONE WNS=$wns SHA=$hash_out EXPLAINS_IDENTITY_H=NO"
exit 0
