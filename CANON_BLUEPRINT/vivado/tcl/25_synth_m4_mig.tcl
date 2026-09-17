# FROZEN historical M4+mig synth. Do NOT run: it would overwrite
# D:/FPGA/arty_d/m4_mig/post_synth.dcp of bit f6a6091f...
# CLEAR candidate uses 29_synth_m4_mig_clear.tcl -> m4_mig_clear/.
puts "REFUSE: 25_synth_m4_mig.tcl is historical. Use 29_synth_m4_mig_clear.tcl"
exit 1
# Synth M4 QueryRecord@100MHz + generated mig0 T2 dest. PROGRAM=NO.
# Separate out: do not clobber freeze / mig_uiclk / mig_tx DCPs.
# Not MIG_PASS / TIMING_PASS / BOARD_PASS / ASTRA_PASS.
set root [file normalize {D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT}]
set migxci {D:/FPGA/miggen/p/mig0.srcs/sources_1/ip/mig0/mig0.xci}
set out {D:/FPGA/arty_d/m4_mig}
file mkdir $out
file mkdir [file join $out reports]
cd $out

create_project m4_mig $out -part xc7a100tcsg324-1 -force
set_param general.maxThreads 4
set_msg_config -id {Synth 8-3332} -limit 8

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
read_verilog -sv [file join $rtl directory query_result_bind.sv]
read_verilog    [file join $rtl strategy spear_rank.v]
read_verilog -sv [file join $rtl strategy spear_profile_bind.sv]
read_verilog    [file join $rtl strategy qstar_select.v]
read_verilog    [file join $rtl memory fem_lifecycle.v]
read_verilog    [file join $rtl memory fem_media_bridge.v]
read_verilog    [file join $rtl memory fem_t2_adapter.v]
read_verilog    [file join $rtl memory fem_t2_ce.v]
read_verilog    [file join $rtl memory fem_media_sys.v]
read_verilog -sv [file join $rtl board uart_rx_word.sv]
read_verilog -sv [file join $rtl board uart_tx_word.sv]
read_verilog -sv [file join $rtl board uart_fe256_host.sv]
read_verilog -sv [file join $rtl board word_cdc32.sv]
read_verilog -sv [file join $rtl board pack_debug_clear.sv]
read_verilog -sv [file join $rtl board pack_clear_ui.sv]
read_verilog -sv [file join $rtl board clk_arty_mig.sv]
read_verilog -sv [file join $rtl board arty_a7_r2_top_m4_mig_candidate.sv]
file copy -force [file join $rtl directory dir_a.mem] [file join $out dir_a.mem]
file copy -force [file join $rtl directory post_a.mem] [file join $out post_a.mem]
add_files [file join $out dir_a.mem]
add_files [file join $out post_a.mem]
read_xdc [file join $rtl board arty_a7_mig.xdc]
read_xdc [file join $rtl board arty_a7_mig_cdc.xdc]
read_xdc [file join {D:/FPGA/miggen/p/mig0.gen/sources_1/ip/mig0/mig0/user_design/constraints/mig0.xdc}]

synth_design -top arty_a7_r2_top_m4_mig_candidate -part xc7a100tcsg324-1 -flatten_hierarchy rebuilt
write_checkpoint -force [file join $out post_synth.dcp]
report_utilization -file [file join $out reports util.rpt]
report_utilization -hierarchical -file [file join $out reports util_hier.rpt]
report_timing_summary -delay_type min_max -max_paths 10 -file [file join $out reports timing.rpt]
report_timing -max_paths 5 -file [file join $out reports crit.rpt]
report_cdc -file [file join $out reports cdc.rpt]
check_timing -file [file join $out reports check_timing.rpt]
report_drc -file [file join $out reports drc.rpt]
puts "M4_MIG_SYNTH_DONE"
exit
