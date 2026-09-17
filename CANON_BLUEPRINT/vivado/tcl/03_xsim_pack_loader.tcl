# XSim smoke. PROGRAM=NO. Run from tb/native_ai/loader so $read/$fopen finds vectors.
set script_dir [file dirname [file normalize [info script]]]
set root [file normalize [file join $script_dir .. ..]]
set simdir [file join $root vivado m1_pack_loader xsim]
file mkdir $simdir
cd $simdir

set src_crc [file join $root rtl native_ai common crc32_iso_hdlc.sv]
set src_dut [file join $root rtl native_ai loader pack_loader.sv]
set src_tb  [file join $root tb native_ai loader tb_pack_loader.sv]
set vecdir  [file join $root tb native_ai loader vectors]

exec xvlog -sv $src_crc $src_dut $src_tb
exec xelab tb_pack_loader -snapshot tb_pack_loader_snap -timescale 1ns/1ps
# Work from vector dir so $fopen relative names resolve
cd $vecdir
exec xsim tb_pack_loader_snap -runall -log [file join $simdir xsim.log]
puts "XSim finished. PROGRAM=NO."
