# DEBUG ILA insert on a COPY of m4_mig_clear post_synth.
# Does NOT overwrite identity H bit/DCP/PROGRAM.txt.
# Not Identity I. Not BOARD_PASS / PROGRAM_PASS / PACK_ABI_24_24_PASS / TIMING_PASS.
set src {D:/FPGA/arty_d/m4_mig_clear/post_synth.dcp}
set out {D:/FPGA/arty_d/m4_mig_clear_ila}
set root {D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT}
file mkdir $out
file mkdir [file join $out reports]
cd $out
file copy -force $src [file join $out post_synth.dcp]
open_checkpoint [file join $out post_synth.dcp]
read_xdc [file join $root rtl/native_ai/board/arty_a7_mig_cdc.xdc]
read_xdc [file join $root rtl/native_ai/board/arty_a7_mig_clear_cdc.xdc]

proc must_net {pat} {
  set n [get_nets -quiet $pat]
  if {![llength $n]} {
    puts "ILA_ABORT missing net $pat"
    exit 2
  }
  return [lindex $n 0]
}

set n_clk [must_net CLK100MHZ]
set n_wv  [must_net u_rx/w_valid]
set n_b0  [must_net {u_rx/bix_reg_n_0_[0]}]
set n_b1  [must_net {u_rx/bix_reg_n_0_[1]}]
set n_rx  [must_net uart_rx]

set wd {}
for {set i 0} {$i < 32} {incr i} {
  set cand [get_nets -quiet [format {u_rx/w_data_reg_n_0_[%d]} $i]]
  if {![llength $cand]} {
    set cand [get_nets -quiet [format {u_rx/w_data[%d]} $i]]
  }
  if {![llength $cand]} {
    puts "ILA_ABORT missing w_data bit $i"
    exit 2
  }
  lappend wd [lindex $cand 0]
}

set n_wr [get_nets -quiet w_ready]
if {![llength $n_wr]} { set n_wr [get_nets -quiet u_rx/w_ready] }
if {![llength $n_wr]} {
  puts "ILA_WARN no w_ready net; continue without it"
  set n_wr ""
}

foreach n [concat [list $n_clk $n_wv $n_b0 $n_b1 $n_rx] $wd $n_wr] {
  if {$n ne ""} {
    catch {set_property MARK_DEBUG true $n}
  }
}

create_debug_core u_ila_0 ila
set_property C_DATA_DEPTH 2048 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 1 [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]

set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [list $n_clk]

# probe0: w_valid, uart_rx, bix[0], bix[1], (optional w_ready)
set p0 [list $n_wv $n_rx $n_b0 $n_b1]
if {$n_wr ne ""} { lappend p0 $n_wr }
set_property port_width [llength $p0] [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 $p0

create_debug_port u_ila_0 probe
set_property port_width 32 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 $wd

implement_debug_core
puts "ILA_CORE_IMPLEMENTED probes0=[llength $p0] probes1=32"

opt_design
place_design
phys_opt_design
route_design
write_checkpoint -force [file join $out post_route_ila.dcp]
write_debug_probes -force [file join $out debug_nets.ltx]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
write_bitstream -force [file join $out arty_a7_r2_top_m4_mig_clear_ila.bit]
report_timing_summary -delay_type min_max -max_paths 5 -file [file join $out reports timing_route.rpt]
report_utilization -file [file join $out reports util_route.rpt]
set wns [get_property SLACK [lindex [get_timing_paths -quiet -delay_type max -max_paths 1] 0]]
puts "M4_MIG_CLEAR_ILA_ROUTE_DONE WNS=$wns"
exit 0
