# PREPARED ONLY. Run only after explicit owner permission to reprogram exact U33.
# Reprogramming resets the current FPGA runtime state. No RTL/build/flash change.
# Usage: vivado -mode batch -source program_exact_u33.tcl -tclargs <new-output-dir> OWNER_AUTHORIZED
# Output: new PROGRAM_RECORD.txt and console status. Old build/PROGRAM.txt is untouched.
# Next: close JTAG, verify server release, then run the prefix UART diagnostic.
if {$argc != 2 || [lindex $argv 1] ne "OWNER_AUTHORIZED"} {
    error "Explicit owner authorization and a new output directory are required"
}
set out [file normalize [lindex $argv 0]]
set allowed [file normalize {D:/FPGA/arty_d/UART_R2/results}]
if {![string match "${allowed}/*" $out] || [file exists $out]} {
    error "Refuse output outside UART_R2/results or existing output"
}
set bit {D:/FPGA/arty_d/UART_R2/build_u33/uart_r2_u33_candidate.bit}
set expected {ff399e0bb9e6ff6c91caf3b769270b03ca9cfb2ea317035a5f3533031338a350}
set py {C:/Users/phant/AppData/Local/Programs/Python/Python311/python.exe}
set actual [string trim [exec $py -I -c {import hashlib,sys; print(hashlib.sha256(open(sys.argv[1],"rb").read()).hexdigest())} $bit]]
if {$actual ne $expected} { error "U33_SHA_MISMATCH" }
file mkdir $out
set fh [open [file join $out PROGRAM_RECORD.txt] {WRONLY CREAT EXCL}]
puts $fh "STATUS=STARTED"
puts $fh "BIT=$bit"
puts $fh "SHA256=$actual"
puts $fh "TARGET_SERIAL=210319BE776EA"
puts $fh "AUTHORITY=OWNER_AUTHORIZATION_IN_CALLING_TASK_REQUIRED"
puts $fh "PROGRAM_PASS=NO BOARD_PASS=NO PACK_ABI_24_24_PASS=NO"
flush $fh
set rc [catch {
    open_hw_manager
    connect_hw_server
    set targets {}
    foreach target [get_hw_targets] {
        if {[string match *210319BE776EA $target]} { lappend targets $target }
    }
    if {[llength $targets] != 1} { error "TARGET_NOT_UNIQUE" }
    set target [lindex $targets 0]
    open_hw_target $target
    set devices [get_hw_devices -quiet xc7a100t_0]
    if {[llength $devices] != 1} { error "DEVICE_NOT_UNIQUE" }
    set dev [lindex $devices 0]
    current_hw_device $dev
    refresh_hw_device -update_hw_probes false $dev
    set_property PROGRAM.FILE $bit $dev
    puts $fh "PROGRAM_BEGIN=[clock seconds]"
    flush $fh
    program_hw_devices $dev
    refresh_hw_device -update_hw_probes false $dev
    foreach prop {REGISTER.CONFIG_STATUS.BIT00_CRC_ERROR REGISTER.CONFIG_STATUS.BIT13_DONE_INTERNAL_SIGNAL_STATUS REGISTER.CONFIG_STATUS.BIT14_DONE_PIN} {
        puts $fh "$prop=[get_property $prop $dev]"
    }
    if {[get_property REGISTER.CONFIG_STATUS.BIT13_DONE_INTERNAL_SIGNAL_STATUS $dev] ne "1"} { error "DONE_NOT_HIGH" }
    if {[get_property REGISTER.CONFIG_STATUS.BIT00_CRC_ERROR $dev] ne "0"} { error "CONFIG_CRC_ERROR" }
    puts $fh "STATUS=PROGRAMMED_CANDIDATE_ONLY"
} message]
if {$rc} { puts $fh "STATUS=FAILED"; puts $fh "ERROR=$message" }
close $fh
catch {close_hw_target}
catch {disconnect_hw_server}
catch {close_hw_manager}
if {$rc} { error $message }
puts "EXACT_U33_PROGRAMMED_CANDIDATE_ONLY PROGRAM_PASS=NO"
exit 0
