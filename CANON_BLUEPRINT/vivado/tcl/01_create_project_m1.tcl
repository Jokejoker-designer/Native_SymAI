# M1 Pack Loader Vivado project. PROGRAM=NO.
# Usage: vivado -mode batch -source 01_create_project_m1.tcl
set script_dir [file dirname [file normalize [info script]]]
set root [file normalize [file join $script_dir .. ..]]
set project_name "m1_pack_loader"
set project_dir  [file join $root vivado m1_pack_loader]
set part_number  "xc7a100tcsg324-1"

file mkdir $project_dir
create_project $project_name $project_dir -part $part_number -force

set_property simulator_language Mixed [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]

add_files -norecurse [list \
  [file join $root rtl native_ai common crc32_iso_hdlc.sv] \
  [file join $root rtl native_ai loader pack_loader.sv] \
]
add_files -fileset sim_1 -norecurse [file join $root tb native_ai loader tb_pack_loader.sv]
set_property file_type SystemVerilog [get_files *.sv]

set_property top pack_loader [current_fileset]
set_property top tb_pack_loader [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "Created $project_dir/$project_name.xpr PROGRAM=NO"
