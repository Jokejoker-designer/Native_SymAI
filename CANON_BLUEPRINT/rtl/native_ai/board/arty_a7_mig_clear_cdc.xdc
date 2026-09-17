# CDC for VALIDATION_CLEAR 2FF (clk100 <-> ui_clk) and UART RX pin sync.
# New identity m4_mig_clear only. Do not apply to freeze / historical m4_mig bit.
# Handshake is registered req + 4-phase ack/nack + 2FF. Not TIMING_PASS.

set_property ASYNC_REG TRUE [get_cells -quiet {req_u0_reg req_u1_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {ack_c0_reg ack_c1_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {nack_c0_reg nack_c1_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {qsc_c0_reg qsc_c1_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {u_rx/rx_s_reg u_rx/rx_d_reg}]

set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_clr/ui_req_r_reg}] -to [get_cells -quiet {req_u0_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_uiclr/ack_reg}] -to [get_cells -quiet {ack_c0_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_uiclr/nack_reg}] -to [get_cells -quiet {nack_c0_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {qsc_ui_r_reg}] -to [get_cells -quiet {qsc_c0_reg}]

set_false_path -from [get_ports uart_rx] -to [get_cells -quiet {u_rx/rx_s_reg}]
