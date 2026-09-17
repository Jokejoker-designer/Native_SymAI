# STATIC_IMPLEMENTATION_DIAGNOSTICS for identity-H routed DCP.
# Read-only open_checkpoint. No bitstream, no program, no RTL edit.
# PRODUCT_RTL_CHANGE=NO PROGRAM=NO NEW_IDENTITY=NO
set dcp {D:/FPGA/arty_d/m4_mig_clear/post_route_clear.dcp}
set out {D:/FPGA/arty_d/AUDIT_TRANSPORT_CDC_MIG_R1/STATIC_IMPLEMENTATION_DIAGNOSTICS}
file mkdir $out

proc dump_help {cmd fh} {
  puts $fh "===== HELP $cmd ====="
  if {[catch {set txt [eval $cmd -help]} err]} {
    puts $fh "HELP_FAIL $err"
  } else {
    puts $fh $txt
  }
}

open_checkpoint $dcp

set nh [open [file join $out netlist_probe.txt] w]
puts $nh "DCP=$dcp"
puts $nh "DESIGN=[get_property TOP [current_design]]"
puts $nh "PART=[get_property PART [current_design]]"
puts $nh "----- CLOCKS -----"
foreach c [lsort [get_clocks]] {
  puts $nh "CLOCK $c period=[get_property PERIOD $c] sources=[get_property SOURCE_PINS $c]"
}
puts $nh "----- KEY PINS -----"
foreach p {u_mig/ui_clk u_mig/ui_clk_sync_rst u_mig/app_en u_cdc/a_clk u_cdc/b_clk u_cdc_tx/a_clk u_cdc_tx/b_clk u_rfifo/clk u_rx/clk u_tx/clk u_clr/clk} {
  set obj [get_pins -quiet $p]
  if {$obj eq ""} {
    puts $nh "PIN_MISSING $p"
  } else {
    puts $nh "PIN $p clock=[get_clocks -quiet -of_objects $obj] net=[get_nets -quiet -of_objects $obj]"
  }
}
puts $nh "----- APP_ADDR -----"
foreach p {u_mig/app_addr[*] u_mux/d_addr[*] u_ld/app_addr[*] u_fem/app_addr[*]} {
  set pins [get_pins -quiet $p]
  puts $nh "BUS $p count=[llength $pins]"
}
set mig_addr [get_pins -quiet {u_mig/app_addr[*]}]
if {[llength $mig_addr] > 0} {
  puts $nh "MIG_APP_ADDR_PINS [llength $mig_addr]"
  puts $nh "MIG_APP_ADDR_NAMES [lsort [get_property NAME $mig_addr]]"
}
puts $nh "----- CDC CELLS -----"
foreach c {u_cdc u_cdc_tx u_rfifo u_rx u_clr u_mux u_ld u_fem} {
  set cell [get_cells -quiet $c]
  if {$cell eq ""} {
    puts $nh "CELL_MISSING $c"
  } else {
    puts $nh "CELL $c ref=[get_property REF_NAME $cell]"
  }
}
puts $nh "----- WORD_CDC32 INST -----"
foreach c [get_cells -hier -quiet -filter {REF_NAME == word_cdc32}] {
  puts $nh "INST $c"
}
close $nh

set hh [open [file join $out vivado_help_excerpt.txt] w]
dump_help report_timing_summary $hh
dump_help report_clock_interaction $hh
dump_help report_cdc $hh
dump_help report_high_fanout_nets $hh
dump_help report_clock_utilization $hh
close $hh

report_timing_summary -delay_type min_max -max_paths 10 -file [file join $out timing_summary.rpt]
report_methodology -file [file join $out methodology.rpt]
report_drc -file [file join $out drc.rpt]
report_cdc -file [file join $out cdc.rpt]
if {[catch {report_cdc -details -file [file join $out cdc_details.rpt]} err]} {
  set ef [open [file join $out cdc_details.FAIL.txt] w]
  puts $ef $err
  close $ef
}
if {[catch {report_clock_interaction -delay_type min_max -file [file join $out clock_interaction.rpt]} err]} {
  report_clock_interaction -file [file join $out clock_interaction.rpt]
}
report_clock_utilization -file [file join $out clock_utilization.rpt]
if {[catch {report_high_fanout_nets -max_nets 30 -file [file join $out high_fanout.rpt]} err]} {
  report_high_fanout_nets -file [file join $out high_fanout.rpt]
}
report_utilization -file [file join $out utilization.rpt]
puts "STATIC_DIAG_DONE"
exit 0
