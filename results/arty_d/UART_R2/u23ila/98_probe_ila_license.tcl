# Probe whether this Vivado can create_debug_core (ILA).
# Opens a COPY of U22 post_synth.dcp. Does not overwrite U22 artifacts.
set src {D:/FPGA/arty_d/UART_R2/build_u22/post_synth.dcp}
set tmp {D:/FPGA/arty_d/UART_R2/build_u23ila/_license_probe}
file mkdir $tmp
if {![file exists $src]} {
  puts "ILA_LICENSE_PROBE FAIL no U22 post_synth.dcp"
  exit 2
}
file copy -force $src [file join $tmp probe.dcp]
open_checkpoint [file join $tmp probe.dcp]
set err ""
set ok [expr {![catch {create_debug_core u_ila_probe ila} err]}]
puts "ILA_CREATE_OK=$ok"
puts "ILA_CREATE_ERR=$err"
puts "LICENSE_HINT_BASIC_SEEN_IN_PRIOR_LOG=YES"
if {$ok} {
  catch {delete_debug_core [get_debug_cores u_ila_probe]}
  puts "ILA_LICENSE=YES"
} else {
  puts "ILA_LICENSE=NO"
}
close_design
exit [expr {$ok ? 0 : 3}]
