# Synth isolated FE256_HW_R1 shadow-bind candidate. PROGRAM=NO. Not frozen r2_top.
set root [file normalize {D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT}]
set out {D:/FPGA/arty_d/fe256_r1_shadow}
file mkdir $out
file mkdir [file join $out reports]
cd $out

create_project -in_memory -part xc7a100tcsg324-1
set_param general.maxThreads 4
set_msg_config -id {Synth 8-3332} -limit 8

set rtl [file join $root rtl native_ai]
set_property include_dirs [list $out [file join $root verification fe256]] [current_fileset]
read_verilog -sv [file join $rtl common crc32_iso_hdlc.sv]
read_verilog -sv [file join $rtl loader pack_loader.sv]
read_verilog -sv [file join $rtl memory mig_ui32.sv]
read_verilog -sv [file join $rtl memory pack_mig_bind.sv]
read_verilog -sv [file join $rtl memory mig_ui_bram.sv]
read_verilog -sv [file join $rtl memory mig_ui_mux.sv]
read_verilog -sv [file join $rtl memory fem_req_ui.sv]
read_verilog -sv [file join $rtl memory fem_on_mig.sv]
read_verilog -sv [file join $rtl directory runtime_profile.sv]
read_verilog -sv [file join $rtl directory exact_directory.sv]
read_verilog -sv [file join $rtl directory posting_walk.sv]
read_verilog -sv [file join $rtl directory bounded_walk.sv]
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
read_verilog -sv [file join $rtl fe256 fe256_query_path.sv]
read_verilog -sv [file join $rtl board arty_a7_r2_top_fe256_r1_candidate.sv]
file copy -force [file join $rtl directory dir_a.mem] [file join $out dir_a.mem]
file copy -force [file join $rtl directory post_a.mem] [file join $out post_a.mem]
file copy -force [file join $rtl fe256 fe256_store.mem] [file join $out fe256_store.mem]
file copy -force [file join $root verification fe256 fe256_abi_constants.svh] [file join $out fe256_abi_constants.svh]
add_files [file join $out dir_a.mem]
add_files [file join $out post_a.mem]
add_files [file join $out fe256_store.mem]
read_xdc [file join $rtl board arty_a7_r2.xdc]

synth_design -top arty_a7_r2_top_fe256_r1_candidate -part xc7a100tcsg324-1 -flatten_hierarchy rebuilt
write_checkpoint -force [file join $out post_synth.dcp]
report_utilization -file [file join $out reports util.rpt]
report_utilization -hierarchical -file [file join $out reports util_hier.rpt]
report_timing_summary -delay_type min_max -max_paths 10 -file [file join $out reports timing.rpt]
report_timing -max_paths 5 -file [file join $out reports crit.rpt]
report_cdc -file [file join $out reports cdc.rpt]
check_timing -file [file join $out reports check_timing.rpt]
report_drc -file [file join $out reports drc.rpt]
puts "FE256_R1_SHADOW_SYNTH_DONE"
exit
