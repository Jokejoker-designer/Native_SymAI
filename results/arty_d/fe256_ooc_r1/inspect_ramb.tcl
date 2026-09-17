# Inspect RAMB36E1 store_q_reg on FE256_HW_R1 routed DCP. PROGRAM=NO.
set dcp {D:/FPGA/arty_d/fe256_ooc_r1/post_route.dcp}
open_checkpoint $dcp
set rams [get_cells -hier -filter {REF_NAME =~ RAMB36*}]
puts "RAMB_COUNT=[llength $rams]"
foreach c $rams {
  puts "CELL=$c"
  puts "  REF=[get_property REF_NAME $c]"
  foreach p {READ_WIDTH_A READ_WIDTH_B WRITE_WIDTH_A WRITE_WIDTH_B RAM_MODE DOA_REG DOB_REG} {
    catch { puts "  $p=[get_property $p $c]" }
  }
}
report_property [lindex $rams 0] -file {D:/FPGA/arty_d/fe256_ooc_r1/reports/ramb36_props.rpt}
set store [get_cells -hier -filter {NAME =~ *store_q*}]
puts "STORE_CELLS=[llength $store]"
foreach c $store {
  puts "STORE_CELL=$c REF=[get_property REF_NAME $c]"
}
# Which store_q bits were removed
if {[llength [get_nets -quiet store_q[*]]] > 0} {
  puts "STORE_Q_NETS=[llength [get_nets store_q[*]]]"
}
report_utilization -file {D:/FPGA/arty_d/fe256_ooc_r1/reports/ramb_util_check.rpt}
puts "RAMB_INSPECT_DONE"
exit
