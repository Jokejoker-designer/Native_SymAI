# Arty A7-100T fabric synth (no MIG). CANDIDATE. Not BOARD_PASS.
# OOC/synth != integrated MIG timing. PROGRAM_PASS != functional PASS.
set root [file normalize {D:/FPGA/NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT}]
set out {D:/FPGA/arty_d}
file mkdir $out
file mkdir [file join $out reports]
cd $out

create_project -in_memory -part xc7a100tcsg324-1
set_param general.maxThreads 4

set rtl [file join $root rtl native_ai]
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
read_verilog -sv [file join $rtl board arty_a7_r2_top.sv]
file copy -force [file join $rtl directory dir_a.mem] [file join $out dir_a.mem]
file copy -force [file join $rtl directory post_a.mem] [file join $out post_a.mem]
add_files [file join $out dir_a.mem]
add_files [file join $out post_a.mem]
read_xdc [file join $rtl board arty_a7_r2.xdc]

synth_design -top arty_a7_r2_top -part xc7a100tcsg324-1 -flatten_hierarchy rebuilt
write_checkpoint -force [file join $out post_synth.dcp]
report_utilization -file [file join $out reports util.rpt]
report_utilization -hierarchical -file [file join $out reports util_hier.rpt]
report_timing_summary -delay_type min_max -max_paths 10 -file [file join $out reports timing.rpt]
report_timing -max_paths 5 -file [file join $out reports crit.rpt]
report_drc -file [file join $out reports drc.rpt]

set ufp [open [file join $out reports util.rpt] r]
set utxt [read $ufp]
close $ufp
set tfp [open [file join $out reports timing.rpt] r]
set ttxt [read $tfp]
close $tfp

proc grab {txt pat} {
  if {[regexp $pat $txt -> v]} { return $v }
  return NA
}

set lut [grab $utxt {Slice LUTs\*?\s+\|\s+(\d+)}]
if {$lut eq "NA"} { set lut [grab $utxt {CLB LUTs\s+\|\s+(\d+)}] }
if {$lut eq "NA"} { set lut [grab $utxt {\|\s+Slice LUTs\s+\|\s+(\d+)}] }
set ff  [grab $utxt {Slice Registers\s+\|\s+(\d+)}]
if {$ff eq "NA"} { set ff [grab $utxt {Register as Flip Flop\s+\|\s+(\d+)}] }
set dsp [grab $utxt {DSPs\s+\|\s+(\d+)}]
set bram [grab $utxt {Block RAM Tile\s+\|\s+(\d+)}]
set wns [grab $ttxt {WNS\(ns\)\s+WHS\(ns\).*?\n\s+\S+\s+(-?[\d\.]+)}]
if {$wns eq "NA"} { set wns [grab $ttxt {Setup\s+\|\s+(-?[\d\.]+)}] }
set tns [grab $ttxt {TNS\(ns\)\s+THS\(ns\).*?\n\s+\S+\s+\S+\s+(-?[\d\.]+)}]

set jf [open [file join $out SYNTH_RESULT.json] w]
puts $jf "\{"
puts $jf "  \"status\": \"CANDIDATE\","
puts $jf "  \"top\": \"arty_a7_r2_top\","
puts $jf "  \"part\": \"xc7a100tcsg324-1\","
puts $jf "  \"claim\": \"not BOARD_PASS; OOC/synth != integrated MIG timing; PROGRAM=NO\","
puts $jf "  \"LUT\": \"$lut\","
puts $jf "  \"FF\": \"$ff\","
puts $jf "  \"DSP\": \"$dsp\","
puts $jf "  \"BRAM\": \"$bram\","
puts $jf "  \"WNS\": \"$wns\","
puts $jf "  \"TNS\": \"$tns\""
puts $jf "\}"
close $jf
puts "ARTY_FABRIC_SYNTH_DONE"
exit
