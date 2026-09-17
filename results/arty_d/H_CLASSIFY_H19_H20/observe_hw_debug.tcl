# Observe-only: list debug cores on the currently programmed device.
# Does not program. Does not insert ILA. Identity H has no dump/ILA by construction.
# Not BOARD_PASS / PROGRAM_PASS / PACK_ABI_24_24_PASS.
set want_jtag {210319BE776EA}
set out {D:/FPGA/arty_d/H_CLASSIFY_H19_H20}
file mkdir $out
set rpt [file join $out HW_DEBUG_CORES.txt]

open_hw_manager
connect_hw_server
set tgt ""
foreach t [get_hw_targets] {
  if {[string match *$want_jtag* $t]} { set tgt $t }
}
if {$tgt eq ""} {
  set fh [open $rpt w]
  puts $fh "STATUS=NO_JTAG want=$want_jtag"
  close $fh
  puts "OBS_ABORT NO_JTAG"
  catch {disconnect_hw_server}
  catch {close_hw_manager}
  exit 2
}
open_hw_target $tgt
current_hw_device [lindex [get_hw_devices xc7a100t_0] 0]
refresh_hw_device -update_hw_probes true [current_hw_device]
set ilas [get_hw_ilas -quiet]
set vios [get_hw_vios -quiet]
set probes [get_hw_probes -quiet]
set fh [open $rpt w]
puts $fh "STATUS=OBSERVED"
puts $fh "TARGET=$tgt"
puts $fh "DEVICE=[current_hw_device]"
puts $fh "PROGRAM.FILE=[get_property PROGRAM.FILE [current_hw_device]]"
catch {puts $fh "PROGRAM.DONE=[get_property PROGRAM.DONE [current_hw_device]]"}
puts $fh "HW_ILA_COUNT=[llength $ilas]"
puts $fh "HW_ILA=$ilas"
puts $fh "HW_VIO_COUNT=[llength $vios]"
puts $fh "HW_VIO=$vios"
puts $fh "HW_PROBE_COUNT=[llength $probes]"
puts $fh "NOTE=empty ILA/VIO means first_pack_word and bix are not JTAG-visible on this bit"
close $fh
puts "OBS_DONE ila=[llength $ilas] vio=[llength $vios] probes=[llength $probes]"
catch {close_hw_target}
catch {disconnect_hw_server}
catch {close_hw_manager}
exit 0
