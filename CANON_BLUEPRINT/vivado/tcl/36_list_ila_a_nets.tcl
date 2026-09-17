# DEBUG ONLY. Dump ILA-A candidate nets from identity-H post_synth.
# Does not write bitstream. Does not overwrite H DCP.
set src {D:/FPGA/arty_d/m4_mig_clear/post_synth.dcp}
set out {D:/FPGA/arty_d/H_ILA_A}
file mkdir $out
open_checkpoint $src
set fh [open [file join $out nets_post_synth.txt] w]
proc dump {fh title pat} {
  puts $fh "===== $title  pat=$pat ====="
  set ns [lsort [get_nets -quiet -hier $pat]]
  puts $fh "COUNT [llength $ns]"
  foreach n $ns { puts $fh $n }
}
dump $fh CLK {*CLK100*}
dump $fh CLK2 {*clk100*}
dump $fh URX {u_rx/*}
dump $fh TAKE {*take*}
dump $fh HOLD {*hold*}
dump $fh CLR {*clr*}
dump $fh FLUSH {*flush*}
dump $fh FIFO {*fifo*}
dump $fh WRVALID {*wr_valid*}
dump $fh WDATA {u_rx/*data*}
dump $fh SH {u_rx/*sh*}
dump $fh RXD {u_rx/*rx*}
dump $fh ST {u_rx/*st*}
dump $fh ACC {u_rx/*acc*}
puts $fh "===== w_valid clock ====="
foreach p [get_pins -quiet u_rx/w_valid_reg/C] {
  puts $fh "PIN $p net=[get_nets -quiet -of_objects $p] clk=[get_clocks -quiet -of_objects $p]"
}
close $fh
puts "NETS_DUMP_DONE [file join $out nets_post_synth.txt]"
exit 0
