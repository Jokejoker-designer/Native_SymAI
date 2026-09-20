# Read-only FPGA configuration status. Never programs, resets or writes a bit.
# Usage: vivado -mode batch -source read_board_status.tcl -log <new status.log> -nojournal
# Expected output: BOARD_STATUS key=value lines in the specified new log.
# Next: distinguish no configured design from UART silence; do not infer bit SHA.
open_hw_manager
connect_hw_server
set matches {}
foreach target [get_hw_targets] {
    if {[string match *210319BE776EA $target]} { lappend matches $target }
}
if {[llength $matches] != 1} { error "BOARD_STATUS_TARGET_NOT_UNIQUE" }
open_hw_target [lindex $matches 0]
set devices [get_hw_devices -quiet xc7a100t_0]
if {[llength $devices] != 1} { error "BOARD_STATUS_DEVICE_NOT_UNIQUE" }
set dev [lindex $devices 0]
current_hw_device $dev
refresh_hw_device -update_hw_probes false $dev
puts "BOARD_STATUS TARGET=[lindex $matches 0]"
foreach prop [lsort [list_property $dev]] {
    if {[regexp {^(NAME$|PART$|IDCODE|REGISTER\.(BOOT_STATUS|CONFIG_STATUS|IR|USERCODE|USR_ACCESS)|IS_PROGRAMMED|PROGRAM\.DONE|STATUS)} $prop]} {
        if {![catch {get_property $prop $dev} value]} {
            puts "BOARD_STATUS $prop=$value"
        }
    }
}
puts "BOARD_STATUS PROGRAM_EXECUTED=NO BIT_IDENTITY_READBACK=NOT_PERFORMED"
close_hw_target [lindex $matches 0]
disconnect_hw_server
close_hw_manager
exit 0
