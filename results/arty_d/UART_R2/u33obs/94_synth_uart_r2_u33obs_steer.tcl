# Synth UART_R2 U33OBS OP_BEGIN UART steer. NEW dir, does not overwrite build_u33obs.
# PROGRAM=NO. Not PACK_ABI_24_24_PASS.
set out {D:/FPGA/arty_d/UART_R2/build_u33obs_steer}
set root [file normalize {D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT}]
set r2 {D:/FPGA/arty_d/UART_R2}
set migxci {D:/FPGA/miggen/p/mig0.srcs/sources_1/ip/mig0/mig0.xci}

proc r2_fail {cut msg} {
  global out
  file mkdir $out
  set fh [open [file join $out BUILD.txt] w]
  puts $fh "STATUS=ABORTED"
  puts $fh "CUT=$cut"
  puts $fh "MSG=$msg"
  puts $fh "PROGRAM_PASS=NO"
  puts $fh "PACK_ABI_24_24_PASS=NO"
  puts $fh "READY_TO_PROGRAM=NO"
  close $fh
  puts "uart_r2_u33obs_steer_ABORT $cut $msg"
  exit 1
}

set outn [file normalize $out]
set want [file normalize {D:/FPGA/arty_d/UART_R2/build_u33obs_steer}]
if {$outn ne $want} { r2_fail WRONG_OUT "out=$outn want=$want" }
foreach bad {
  {D:/FPGA/arty_d/UART_R2/build_u33obs}
  {D:/FPGA/arty_d/UART_R2/build_u33obs_rgoff}
  {D:/FPGA/arty_d/UART_R2/build_u33}
  {D:/FPGA/arty_d/UART_R2/build_u33tap}
  {D:/FPGA/arty_d/UART_R2/build_u33tap_cdc}
  {D:/FPGA/arty_d/m4_mig}
  {D:/FPGA/arty_d/hold_r2}
} {
  if {$outn eq [file normalize $bad]} { r2_fail FORBIDDEN_DIR $bad }
}

file mkdir $out
file mkdir [file join $out reports]
cd $out

create_project uart_r2_u33obs_steer $out -part xc7a100tcsg324-1 -force
set_param general.maxThreads 4
set_msg_config -id {Synth 8-3332} -limit 8

read_ip $migxci
set_property generate_synth_checkpoint false [get_files $migxci]
generate_target {synthesis} [get_ips mig0]

set rtl [file join $root rtl native_ai]
read_verilog -sv [file join $rtl common crc32_iso_hdlc.sv]
read_verilog -sv [file join $rtl loader pack_loader.sv]
read_verilog -sv [file join $rtl memory mig_ui32.sv]
read_verilog -sv [file join $r2 u33 pack_mig_bind.sv]
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
read_verilog -sv [file join $r2 u11 uart_rx_word.sv]
read_verilog -sv [file join $r2 u14 uart_tx_word.sv]
read_verilog -sv [file join $r2 u6 uart_fe256_host.sv]
read_verilog -sv [file join $rtl board word_cdc32.sv]
read_verilog -sv [file join $rtl board word_fifo32.sv]
read_verilog -sv [file join $r2 u32 pack_debug_clear.sv]
read_verilog -sv [file join $r2 u32 pack_clear_ui.sv]
read_verilog -sv [file join $r2 u33obs pack_obs_ctrl.sv]
read_verilog -sv [file join $r2 u33obs pack_obs_gen.sv]
read_verilog -sv [file join $r2 u33obs pack_obs_dump.sv]
read_verilog -sv [file join $rtl board clk_arty_mig.sv]
read_verilog -sv [file join $r2 u33obs arty_a7_r2_top_m4_mig_candidate.sv]
file copy -force [file join $rtl directory dir_a.mem] [file join $out dir_a.mem]
file copy -force [file join $rtl directory post_a.mem] [file join $out post_a.mem]
add_files [file join $out dir_a.mem]
add_files [file join $out post_a.mem]
read_xdc [file join $rtl board arty_a7_mig.xdc]
read_xdc [file join $rtl board arty_a7_mig_cdc.xdc]
read_xdc [file join $rtl board arty_a7_mig_clear_cdc.xdc]
read_xdc [file join $r2 u33obs u33obs_tap_cdc.xdc]
read_xdc [file join {D:/FPGA/miggen/p/mig0.gen/sources_1/ip/mig0/mig0/user_design/constraints/mig0.xdc}]

synth_design -top arty_a7_r2_top_m4_mig_candidate -part xc7a100tcsg324-1 -flatten_hierarchy rebuilt
write_checkpoint -force [file join $out post_synth.dcp]
report_utilization -file [file join $out reports util.rpt]
report_timing_summary -delay_type min_max -max_paths 10 -file [file join $out reports timing.rpt]
set ntap [llength [get_cells -quiet u_dump/u_cdc_tap/req_a_reg]]
set nu2u [llength [get_cells -quiet u_dump/u_cdc_u2ui/req_a_reg]]
set fh [open [file join $out BUILD.txt] w]
puts $fh "STATUS=SYNTH_DONE"
puts $fh "OUT=$out"
puts $fh "CLASS=uart_r2_u33obs_STEER_CANDIDATE"
puts $fh "NOT_OVERWRITE_U33OBS_71b9198f=YES"
puts $fh "TAP_CDC_CELLS=$ntap"
puts $fh "U2UI_CDC_CELLS=$nu2u"
puts $fh "PROGRAM_PASS=NO"
puts $fh "PACK_ABI_24_24_PASS=NO"
puts $fh "READY_TO_PROGRAM=NO"
close $fh
if {$ntap < 1} { r2_fail TAP_CDC_CELLS_MISSING "u_dump/u_cdc_tap/req_a_reg" }
puts "uart_r2_u33obs_steer_SYNTH_OK path=$out TAP_CDC_CELLS=$ntap U2UI=$nu2u"
exit 0
