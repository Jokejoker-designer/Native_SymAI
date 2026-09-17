# H-ILA-A debug identity ONLY. Netlist-insert ILA on a COPY of identity-H post_synth.
# Same H functional RTL. Does NOT overwrite:
#   identity H bit cf62102f... / m4_mig_clear/*.bit
#   freeze DCPs 858d0e99... / b48b7c88... / f25fdf64...
#   m4_mig candidate bit f6a6091f...
# Not Identity I. Not BOARD_PASS / PROGRAM_PASS / PACK_ABI_24_24_PASS / TIMING_PASS / MIG_PASS.
set src {D:/FPGA/arty_d/m4_mig_clear/post_synth.dcp}
set out {D:/FPGA/arty_d/H_ILA_A}
set root {D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT}
set xdc [file join $root rtl/native_ai/board/arty_a7_mig_cdc.xdc]
set xdc_clr [file join $root rtl/native_ai/board/arty_a7_mig_clear_cdc.xdc]

proc ila_fail {cut msg} {
  global out
  file mkdir $out
  set fh [open [file join $out BUILD.txt] w]
  puts $fh "STATUS=ABORTED"
  puts $fh "CUT=$cut"
  puts $fh "MSG=$msg"
  puts $fh "PROGRAM_PASS=NO"
  puts $fh "BOARD_PASS=NOT_EVIDENCED"
  close $fh
  puts "ILA_A_ABORT $cut $msg"
  exit 2
}

file mkdir $out
file mkdir [file join $out reports]
if {![file exists $src]} { ila_fail SRC_MISSING $src }

# Refuse to write into identity-H / freeze / m4_mig dirs.
if {[string equal -nocase $out {D:/FPGA/arty_d/m4_mig_clear}]} { ila_fail REFUSE_H_DIR $out }
if {[string equal -nocase $out {D:/FPGA/arty_d/m4_mig}]} { ila_fail REFUSE_M4_DIR $out }

file copy -force $src [file join $out post_synth_copy.dcp]
open_checkpoint [file join $out post_synth_copy.dcp]
read_xdc $xdc
read_xdc $xdc_clr
set_param general.maxThreads 4

proc get_net_lit {pat} {
  set n [get_nets -quiet -filter [format {NAME == {%s}} $pat]]
  if {[llength $n]} { return [lindex $n 0] }
  set n [get_nets -quiet -hier -filter [format {NAME == {%s}} $pat]]
  if {[llength $n]} { return [lindex $n 0] }
  return {}
}

proc first_net {args} {
  foreach pat $args {
    set n [get_net_lit $pat]
    if {$n ne {}} { return $n }
  }
  return {}
}

proc bus_nets {nbits args} {
  set outl {}
  for {set i 0} {$i < $nbits} {incr i} {
    set found {}
    foreach fmt $args {
      set pat [format $fmt $i]
      set n [get_net_lit $pat]
      if {$n ne {}} {
        set found $n
        break
      }
    }
    if {$found eq {}} { return {} }
    lappend outl $found
  }
  return $outl
}

proc ff_q_bus {nbits args} {
  set outl {}
  for {set i 0} {$i < $nbits} {incr i} {
    set found {}
    foreach fmt $args {
      set c [get_cells -quiet [format $fmt $i]]
      if {![llength $c]} { continue }
      set q [get_pins -quiet [lindex $c 0]/Q]
      set n [get_nets -quiet -of_objects $q]
      if {[llength $n]} {
        set found [lindex $n 0]
        break
      }
    }
    if {$found eq {}} { return {} }
    lappend outl $found
  }
  return $outl
}

set dump [open [file join $out nets_post_synth.txt] w]
puts $dump "===== u_rx CELLS ====="
foreach c [lsort [get_cells -quiet -hier -filter {NAME =~ u_rx/*}]] { puts $dump $c }
puts $dump "===== u_rx NETS ====="
foreach n [lsort [get_nets -quiet -hier -filter {NAME =~ u_rx/*}]] { puts $dump $n }
puts $dump "===== take/hold/flush/clr ====="
foreach n [lsort [get_nets -quiet -hier -regexp {.*(take|hold|flush|clr_take|clr_hold|uart_flush).*}]] { puts $dump $n }
puts $dump "===== u_rfifo NETS ====="
foreach n [lsort [get_nets -quiet -hier -filter {NAME =~ *u_rfifo*}]] { puts $dump $n }
puts $dump "===== u_clr CELLS (first 80) ====="
foreach c [lrange [lsort [get_cells -quiet -hier -filter {NAME =~ u_clr*}]] 0 79] { puts $dump $c }
puts $dump "===== clocks of u_rx/w_valid ====="
foreach p [get_pins -quiet -hier -filter {NAME =~ *u_rx*w_valid_reg*/C}] {
  puts $dump "PIN $p NET=[get_nets -quiet -of_objects $p]"
}
close $dump
puts "NETS_DUMP_OK [file join $out nets_post_synth.txt]"

set n_clk {}
foreach p [get_pins -quiet -hier -filter {NAME =~ *u_rx*w_valid_reg*/C}] {
  set nn [get_nets -quiet -of_objects $p]
  if {[llength $nn]} { set n_clk [lindex $nn 0]; break }
}
if {$n_clk eq {}} {
  set n_clk [first_net CLK100MHZ_IBUF_BUFG CLK100MHZ_IBUF clk100 clk CLK100MHZ]
}
if {$n_clk eq {}} { ila_fail CLK "no ILA clock net" }
puts "ILA_CLK $n_clk"

set n_rxd [first_net u_rx/rx_d u_rx/rx_d_reg {u_rx/rx_d_reg_n_0_} uart_rx_IBUF]
set n_rx  [first_net uart_rx_IBUF uart_rx]
set n_wv  [first_net u_rx/w_valid]
set n_b0  [first_net {u_rx/bix_reg_n_0_[0]} {u_rx/bix[0]} {u_rx/bix_reg[0]}]
set n_b1  [first_net {u_rx/bix_reg_n_0_[1]} {u_rx/bix[1]} {u_rx/bix_reg[1]}]
set n_wr  [first_net w_ready u_rx/w_ready u_clr/w_ready_reg]
set n_take [first_net clr_take take u_clr/take]
set n_hold [first_net clr_hold hold u_clr/hold]
set n_flush [first_net uart_flush u_clr/uart_flush u_clr/flush_r]
set n_wfv [first_net u_rfifo/wr_valid fifo_wr_valid]
set n_wfr [first_net fifo_wr_ready u_rfifo/wr_ready]

set sh [bus_nets 8 {u_rx/sh[%d]} {u_rx/sh_reg_n_0_[%d]} {u_rx/sh_reg[%d]}]
if {![llength $sh]} { set sh [ff_q_bus 8 {u_rx/sh_reg[%d]} {u_rx/sh_reg_reg[%d]}] }

set st [bus_nets 2 {u_rx/st_reg_n_0_[%d]} {u_rx/st[%d]} {u_rx/st_reg[%d]}]
if {![llength $st]} { set st [ff_q_bus 2 {u_rx/st_reg[%d]}] }

set wd [bus_nets 32 {w_data[%d]} {u_rx/w_data[%d]} {u_rx/w_data_reg_n_0_[%d]} {u_rx/acc_reg_n_0_[%d]}]
if {![llength $wd]} { set wd [ff_q_bus 32 {u_rx/w_data_reg[%d]} {u_rx/acc_reg[%d]}] }

set trig $n_rxd
if {$trig eq {}} { set trig $n_rx }
if {$trig eq {}} { ila_fail RX "no uart_rx / rx_d net" }
if {$n_wv eq {}} { ila_fail W_VALID "no u_rx/w_valid" }
if {$n_b0 eq {} || $n_b1 eq {}} { ila_fail BIX "b0=$n_b0 b1=$n_b1" }

set map [open [file join $out probes_map.txt] w]
puts $map "clk $n_clk"
puts $map "trig $trig"
puts $map "rx_d $n_rxd"
puts $map "uart_rx $n_rx"
puts $map "w_valid $n_wv"
puts $map "bix0 $n_b0"
puts $map "bix1 $n_b1"
puts $map "w_ready $n_wr"
puts $map "take $n_take"
puts $map "hold $n_hold"
puts $map "flush $n_flush"
puts $map "fifo_wr_valid $n_wfv"
puts $map "fifo_wr_ready $n_wfr"
puts $map "sh_count [llength $sh]"
puts $map "st_count [llength $st]"
puts $map "w_data_count [llength $wd]"
if {[llength $wd]} { puts $map "w_data0 [lindex $wd 0]" }
if {[llength $sh]} { puts $map "sh0 [lindex $sh 0]" }
close $map
puts "PROBES_MAP_OK"

set mark [list $n_clk $trig $n_wv $n_b0 $n_b1]
foreach n [list $n_rxd $n_rx $n_wr $n_take $n_hold $n_flush $n_wfv $n_wfr] {
  if {$n ne {}} { lappend mark $n }
}
foreach n [concat $sh $st $wd] { lappend mark $n }
foreach n $mark {
  if {$n eq {}} { continue }
  catch {set_property MARK_DEBUG true [get_nets $n]}
}

if {[catch {create_debug_core u_ila_0 ila} err]} {
  ila_fail ILA_CREATE $err
}
set core [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 32768 $core
set_property C_TRIGIN_EN false $core
set_property C_TRIGOUT_EN false $core
set_property C_INPUT_PIPE_STAGES 1 $core
set_property C_EN_STRG_QUAL false $core
set_property C_ADV_TRIGGER false $core
set_property ALL_PROBE_SAME_MU true $core
set_property ALL_PROBE_SAME_MU_CNT 1 $core
catch {set_property C_ALL_PROBE_SAME_MU true $core}
catch {set_property C_ALL_PROBE_SAME_MU_CNT 1 $core}

set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [list $n_clk]

# probe0: trigger net (rx_d preferred, else uart_rx)
set_property port_width 1 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [list $trig]

proc add_probe {nets} {
  if {![llength $nets]} { return }
  create_debug_port u_ila_0 probe
  set dp [lindex [get_debug_ports u_ila_0/probe*] end]
  set_property port_width [llength $nets] $dp
  connect_debug_port $dp $nets
}

# Keep a stable order for the decoder.
set p_ctrl [list $n_wv $n_b0 $n_b1]
foreach n [list $n_rx $n_wr $n_take $n_hold $n_flush $n_wfv $n_wfr] {
  if {$n ne {}} { lappend p_ctrl $n }
}
add_probe $p_ctrl
if {[llength $sh] == 8} { add_probe $sh }
if {[llength $st] == 2} { add_probe $st }
if {[llength $wd] == 32} { add_probe $wd }

if {[catch {implement_debug_core} err]} {
  ila_fail ILA_IMPLEMENT $err
}
catch {
  set_property C_CLK_INPUT_FREQ_HZ 100000000 [get_debug_cores dbg_hub]
  set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
  connect_debug_port dbg_hub/clk [list $n_clk]
}
report_debug_core -file [file join $out reports debug_core.rpt]
puts "ILA_CORE_OK"

opt_design
place_design
phys_opt_design
route_design
write_checkpoint -force [file join $out post_route_ila.dcp]
write_debug_probes -force [file join $out debug_nets.ltx]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set bitfile [file join $out arty_a7_r2_top_m4_mig_clear_ila_a.bit]
write_bitstream -force $bitfile
report_timing_summary -delay_type min_max -max_paths 5 -file [file join $out reports timing_route.rpt]
report_utilization -file [file join $out reports util_route.rpt]
report_debug_core -file [file join $out reports debug_core_route.rpt]

set wns "NA"
catch {set wns [get_property SLACK [lindex [get_timing_paths -quiet -delay_type max -max_paths 1] 0]]}
set raw [exec certutil -hashfile $bitfile SHA256]
set hash_out ""
foreach line [split $raw "\n"] {
  set t [string trim $line]
  if {[regexp {^[0-9a-fA-F]{64}$} $t]} { set hash_out [string tolower $t] }
}
set fh [open [file join $out BUILD.txt] w]
puts $fh "STATUS=BUILT"
puts $fh "FILE=$bitfile"
puts $fh "SHA256=$hash_out"
puts $fh "WNS=$wns"
puts $fh "LTX=[file join $out debug_nets.ltx]"
puts $fh "IDENTITY_H_UNTOUCHED=YES"
puts $fh "PROGRAM_PASS=NO"
puts $fh "BOARD_PASS=NOT_EVIDENCED"
puts $fh "CLASS=H_ILA_A_DEBUG_ONLY"
close $fh
puts "ILA_A_BUILD_DONE WNS=$wns SHA=$hash_out"
exit 0
