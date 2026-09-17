# H-ILA-A observe debug bit. BASIC license: no create_debug_core.
# Same H functional modules. Writes ONLY under D:/FPGA/arty_d/H_ILA_A
# Does not overwrite identity H cf62102f, freeze DCPs, or m4_mig candidate bit.
# Not BOARD_PASS / PROGRAM_PASS / PACK_ABI_24_24_PASS / TIMING_PASS / MIG_PASS.
set root [file normalize {D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT}]
set migxci {D:/FPGA/miggen/p/mig0.srcs/sources_1/ip/mig0/mig0.xci}
set out {D:/FPGA/arty_d/H_ILA_A}
set proj [file join $out vivado_proj]
set dbg $out
file mkdir $out
file mkdir [file join $out reports]
file mkdir $proj

proc ila_fail {cut msg} {
  global out
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

cd $out
create_project ila_a $proj -part xc7a100tcsg324-1 -force
set_param general.maxThreads 4
set_msg_config -id {Synth 8-3332} -limit 8

if {![file exists $migxci]} { ila_fail MIG_XCI $migxci }
read_ip $migxci
set_property generate_synth_checkpoint false [get_files $migxci]
generate_target {synthesis} [get_ips mig0]

set rtl [file join $root rtl native_ai]
read_verilog -sv [file join $rtl common crc32_iso_hdlc.sv]
read_verilog -sv [file join $rtl loader pack_loader.sv]
read_verilog -sv [file join $rtl memory mig_ui32.sv]
read_verilog -sv [file join $rtl memory pack_mig_bind.sv]
read_verilog -sv [file join $rtl memory mig_ui_mux.sv]
read_verilog -sv [file join $rtl memory fem_req_ui.sv]
read_verilog -sv [file join $rtl memory fem_on_mig.sv]
read_verilog -sv [file join $rtl directory runtime_profile.sv]
read_verilog -sv [file join $rtl directory exact_directory.sv]
read_verilog -sv [file join $rtl directory posting_walk.sv]
read_verilog -sv [file join $rtl directory bounded_walk.sv]
read_verilog -sv [file join $rtl directory query_walk_bind.sv]
read_verilog -sv [file join $rtl astra astra_qeval.sv]
read_verilog -sv [file join $rtl directory query_result_bind.sv]
read_verilog    [file join $rtl strategy spear_rank.v]
read_verilog -sv [file join $rtl strategy spear_profile_bind.sv]
read_verilog    [file join $rtl strategy qstar_select.v]
read_verilog    [file join $rtl memory fem_lifecycle.v]
read_verilog    [file join $rtl memory fem_media_bridge.v]
read_verilog    [file join $rtl memory fem_t2_adapter.v]
read_verilog    [file join $rtl memory fem_t2_ce.v]
read_verilog    [file join $rtl memory fem_media_sys.v]
read_verilog -sv [file join $dbg uart_rx_word_observe.sv]
read_verilog -sv [file join $dbg h_ila_a_cap.sv]
read_verilog -sv [file join $dbg h_ila_a_dump.sv]
read_verilog -sv [file join $rtl board uart_tx_word.sv]
read_verilog -sv [file join $rtl board uart_fe256_host.sv]
read_verilog -sv [file join $rtl board word_cdc32.sv]
read_verilog -sv [file join $rtl board word_fifo32.sv]
read_verilog -sv [file join $rtl board pack_debug_clear.sv]
read_verilog -sv [file join $rtl board pack_clear_ui.sv]
read_verilog -sv [file join $rtl board clk_arty_mig.sv]
read_verilog -sv [file join $dbg arty_a7_r2_top_m4_mig_clear_ila_a.sv]
file copy -force [file join $rtl directory dir_a.mem] [file join $out dir_a.mem]
file copy -force [file join $rtl directory post_a.mem] [file join $out post_a.mem]
add_files [file join $out dir_a.mem]
add_files [file join $out post_a.mem]
read_xdc [file join $rtl board arty_a7_mig.xdc]
read_xdc [file join $rtl board arty_a7_mig_cdc.xdc]
read_xdc [file join $rtl board arty_a7_mig_clear_cdc.xdc]
read_xdc [file join {D:/FPGA/miggen/p/mig0.gen/sources_1/ip/mig0/mig0/user_design/constraints/mig0.xdc}]

synth_design -top arty_a7_r2_top_m4_mig_clear_ila_a -part xc7a100tcsg324-1 -flatten_hierarchy rebuilt
write_checkpoint -force [file join $out post_synth_ila_a.dcp]
puts "ILA_A_SYNTH_DONE"
opt_design
place_design
phys_opt_design
route_design
write_checkpoint -force [file join $out post_route_ila_a.dcp]
report_timing_summary -delay_type min_max -max_paths 5 -file [file join $out reports timing_route.rpt]
report_utilization -file [file join $out reports util_route.rpt]
set wns "NA"
catch {set wns [get_property SLACK [lindex [get_timing_paths -quiet -delay_type max -max_paths 1] 0]]}
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set bitfile [file join $out arty_a7_r2_top_m4_mig_clear_ila_a.bit]
write_bitstream -force $bitfile
set raw [exec certutil -hashfile $bitfile SHA256]
set hash_out ""
foreach line [split $raw "\n"] {
  set t [string trim $line]
  if {[regexp {^[0-9a-fA-F]{64}$} $t]} { set hash_out [string tolower $t] }
}
if {$hash_out eq {cf62102f21bd146976779e45dec77f912790da1000327fbc505941cdef4e7fc9}} {
  ila_fail REFUSE_IDENTITY_H $hash_out
}
set fh [open [file join $out BUILD.txt] w]
puts $fh "STATUS=BUILT"
puts $fh "FILE=$bitfile"
puts $fh "SHA256=$hash_out"
puts $fh "WNS=$wns"
puts $fh "ILA_IP=NO_BASIC_LICENSE"
puts $fh "PROBE=observe_uart_dump"
puts $fh "IDENTITY_H_UNTOUCHED=YES"
puts $fh "PROGRAM_PASS=NO"
puts $fh "BOARD_PASS=NOT_EVIDENCED"
puts $fh "CLASS=H_ILA_A_DEBUG_ONLY"
close $fh
puts "ILA_A_BUILD_DONE WNS=$wns SHA=$hash_out"
exit 0
