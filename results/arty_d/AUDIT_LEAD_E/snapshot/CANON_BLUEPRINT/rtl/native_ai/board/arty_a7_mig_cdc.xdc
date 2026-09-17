# CDC exceptions for arty_a7_mig_top. CANDIDATE. PROGRAM=NO.
# Not TIMING_PASS. Handshake is toggle + 2FF (word_cdc32).
# XDC cannot use Tcl `if` (Designutils 20-1307).

set_property ASYNC_REG TRUE [get_cells -quiet {u_cdc/ack_a0_reg u_cdc/ack_a1_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {u_cdc/req_b0_reg u_cdc/req_b1_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {u_cdc_tx/ack_a0_reg u_cdc_tx/ack_a1_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {u_cdc_tx/req_b0_reg u_cdc_tx/req_b1_reg}]

set_max_delay -datapath_only 8.0 \
  -from [get_cells u_cdc/req_a_reg] -to [get_cells u_cdc/req_b0_reg]
set_max_delay -datapath_only 8.0 \
  -from [get_cells u_cdc/ack_b_reg] -to [get_cells u_cdc/ack_a0_reg]
set_max_delay -datapath_only 8.0 \
  -from [get_cells {u_cdc/hold_reg[*]}] -to [get_cells {u_cdc/b_data_reg[*]}]

set_max_delay -datapath_only 8.0 \
  -from [get_cells u_cdc_tx/req_a_reg] -to [get_cells u_cdc_tx/req_b0_reg]
set_max_delay -datapath_only 8.0 \
  -from [get_cells u_cdc_tx/ack_b_reg] -to [get_cells u_cdc_tx/ack_a0_reg]
set_max_delay -datapath_only 8.0 \
  -from [get_cells {u_cdc_tx/hold_reg[*]}] -to [get_cells {u_cdc_tx/b_data_reg[*]}]

set_false_path -to [get_ports {led[*]}]
set_false_path -from [get_ports ck_rst]
