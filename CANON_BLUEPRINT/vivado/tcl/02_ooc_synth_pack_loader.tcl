# OOC synthesis for pack_loader. PROGRAM=NO. Do not write bitstream.
set script_dir [file dirname [file normalize [info script]]]
set root [file normalize [file join $script_dir .. ..]]
set outdir [file join $root vivado m1_pack_loader ooc]
file mkdir $outdir

set part "xc7a100tcsg324-1"
set srcs [list \
  [file join $root rtl native_ai common crc32_iso_hdlc.sv] \
  [file join $root rtl native_ai loader pack_loader.sv] \
]

set_part $part
read_verilog -sv $srcs
synth_design -mode out_of_context -top pack_loader -part $part
read_xdc [file join $root vivado constraints pack_loader_ooc.xdc]
report_utilization -file [file join $outdir utilization.rpt]
if {[catch {report_ram_utilization -file [file join $outdir ram.rpt]} err]} {
  puts "WARN report_ram_utilization: $err"
}
report_timing_summary -file [file join $outdir timing_summary.rpt]
if {[catch {report_timing -delay_type max -max_paths 5 -file [file join $outdir timing_paths.rpt]} err]} {
  puts "WARN report_timing: $err"
}
write_checkpoint -force [file join $outdir pack_loader_ooc.dcp]
puts "OOC complete. PROGRAM=NO. Reports in $outdir"
