# DEBUG ONLY. List RX/CLEAR nets on m4_mig_clear post_synth. Does not write H bit.
# Not Identity I. Not BOARD_PASS / PROGRAM_PASS.
set src {D:/FPGA/arty_d/m4_mig_clear/post_synth.dcp}
open_checkpoint $src
puts "CLK_NETS:"
foreach n [lsort [get_nets -quiet -hier *clk100*]] { puts "  $n" }
foreach n [lsort [get_nets -quiet CLK100MHZ]] { puts "  PIN $n" }
puts "BIX:"
foreach n [lsort [get_nets -quiet -hier *bix*]] { puts "  $n" }
puts "WVALID:"
foreach n [lsort [get_nets -quiet -hier *w_valid*]] { puts "  $n" }
puts "WREADY:"
foreach n [lsort [get_nets -quiet -hier *w_ready*]] { puts "  $n" }
puts "WDATA sample:"
puts "  [llength [get_nets -quiet -hier *w_data*]] nets"
foreach n [lrange [lsort [get_nets -quiet -hier *u_rx*w_data*]] 0 8] { puts "  $n" }
puts "CLR:"
foreach n [lsort [get_nets -quiet -hier *u_clr*]] { puts "  $n" }
puts "UART_RX:"
foreach n [lsort [get_nets -quiet uart_rx]] { puts "  $n" }
puts "LIST_RX_NETS_DONE"
exit 0
