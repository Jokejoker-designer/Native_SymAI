# Proof image top. Not the JA bitstream e2d97151. PROGRAM=NO.
# CONNECTOR_PIN JA1 = PACKAGE_PIN G13 = RTL_PORT effect_drive
# CONNECTOR_PIN JA2 = PACKAGE_PIN B11 = RTL_PORT effect_sense

set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property PACKAGE_PIN E3 [get_ports CLK100MHZ]
set_property IOSTANDARD LVCMOS33 [get_ports CLK100MHZ]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports CLK100MHZ]
set_property PACKAGE_PIN C2 [get_ports ck_rst]
set_property IOSTANDARD LVCMOS33 [get_ports ck_rst]
set_property PACKAGE_PIN D10 [get_ports uart_tx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx]
set_property PACKAGE_PIN G13 [get_ports effect_drive]
set_property IOSTANDARD LVCMOS33 [get_ports effect_drive]
set_property PACKAGE_PIN B11 [get_ports effect_sense]
set_property IOSTANDARD LVCMOS33 [get_ports effect_sense]
set_property PULLTYPE PULLDOWN [get_ports effect_sense]
set_property PACKAGE_PIN H5 [get_ports led0]
set_property IOSTANDARD LVCMOS33 [get_ports led0]
