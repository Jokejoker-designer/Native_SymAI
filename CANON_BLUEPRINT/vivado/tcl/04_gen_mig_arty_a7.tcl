# Generate Arty A7-100T MIG under a short Windows path (AR52787).
# PROGRAM=NO. Not MIG_PASS. Native UI; dest complete is not AXI BRESP.
set part "xc7a100tcsg324-1"
set short "D:/FPGA/miggen"
set src_prj [file normalize [file join [file dirname [file normalize [info script]]] .. ip mig_arty_a7_100t mig_arty_a7_100t.prj]]
set pkg_out [file normalize [file join [file dirname [file normalize [info script]]] .. ip mig_arty_a7_100t]]

file mkdir $short
set prj [file join $short mig0.prj]
set fh [open $src_prj r]
set txt [read $fh]
close $fh
set txt [string map {mig_arty_a7_100t mig0} $txt]
set out [open $prj w]
fconfigure $out -translation lf -encoding utf-8
puts -nonewline $out $txt
close $out

file mkdir [file join $short p]
cd $short
create_project mig0 [file join $short p] -part $part -force
create_ip -name mig_7series -vendor xilinx.com -library ip -module_name mig0
set_property CONFIG.XML_INPUT_FILE $prj [get_ips mig0]
generate_target {instantiation_template synthesis simulation} [get_ips mig0]

set ipfile [get_property IP_FILE [get_ips mig0]]
puts "MIG_GEN_DONE $ipfile"

# Record generated widths from the wrapper / xci
set hits [list]
foreach f [concat [glob -nocomplain [file join $short p *.srcs sources_1 ip mig0 *.v]] \
                 [glob -nocomplain [file join $short p *.gen sources_1 ip mig0 *.v]] \
                 [glob -nocomplain [file join $short p *.gen sources_1 ip mig0 mig0 *.v]]] {
  puts "MIG_FILE $f"
}
foreach f [glob -nocomplain -directory $short *] {
  puts "MIG_ROOT $f"
}

file mkdir $pkg_out
set rec [file join $pkg_out MIG_GEN_RESULT.txt]
set rf [open $rec w]
puts $rf "ip_file=$ipfile"
puts $rf "prj=$prj"
puts $rf "PROGRAM=NO"
close $rf
puts "MIG_GEN_RECORD $rec"
puts "PROGRAM=NO"
