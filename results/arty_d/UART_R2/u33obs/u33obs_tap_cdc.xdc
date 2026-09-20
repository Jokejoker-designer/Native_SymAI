# U33OBS TAP dump CDCs + U32 busy CDC. Apply at synth AND impl.
# Unique identity. Not TIMING_PASS. Not PACK_ABI_24_24_PASS.

set_property ASYNC_REG TRUE [get_cells -quiet {busy_u0_reg busy_u1_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {tx_busy_100_r_reg}] -to [get_cells -quiet {busy_u0_reg}]

# u_dump/u_cdc_tap: ui_clk -> clk100
set_property ASYNC_REG TRUE [get_cells -quiet {u_dump/u_cdc_tap/ack_a0_reg u_dump/u_cdc_tap/ack_a1_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {u_dump/u_cdc_tap/req_b0_reg u_dump/u_cdc_tap/req_b1_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet u_dump/u_cdc_tap/req_a_reg] -to [get_cells -quiet u_dump/u_cdc_tap/req_b0_reg]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet u_dump/u_cdc_tap/ack_b_reg] -to [get_cells -quiet u_dump/u_cdc_tap/ack_a0_reg]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_dump/u_cdc_tap/hold_reg[*]}] -to [get_cells -quiet {u_dump/u_cdc_tap/b_data_reg[*]}]

# u_dump/u_cdc_u2ui: clk100 -> ui_clk
set_property ASYNC_REG TRUE [get_cells -quiet {u_dump/u_cdc_u2ui/ack_a0_reg u_dump/u_cdc_u2ui/ack_a1_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {u_dump/u_cdc_u2ui/req_b0_reg u_dump/u_cdc_u2ui/req_b1_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet u_dump/u_cdc_u2ui/req_a_reg] -to [get_cells -quiet u_dump/u_cdc_u2ui/req_b0_reg]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet u_dump/u_cdc_u2ui/ack_b_reg] -to [get_cells -quiet u_dump/u_cdc_u2ui/ack_a0_reg]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_dump/u_cdc_u2ui/hold_reg[*]}] -to [get_cells -quiet {u_dump/u_cdc_u2ui/b_data_reg[*]}]

# OBS 2FF CDC: ctrl handshake, NAK, calib, freeze, capture_valid.
# Do not treat 100 MHz vs ui_clk 2ns phase offset as a sync path.
set_property ASYNC_REG TRUE [get_cells -quiet {u_obs_ctrl/a0_reg u_obs_ctrl/a1_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {u_obs_ctrl/u0_reg u_obs_ctrl/u1_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {nak0_reg nak1_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {cal0_reg cal1_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {cv0_reg cv_ui_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {u_dump/freeze_ui0_reg u_dump/freeze_ui_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {u_dump/fr0_reg[*] u_dump/fr_ui_reg[*]}]
set_max_delay -datapath_only 8.0 -to [get_cells -quiet {u_obs_ctrl/a0_reg}]
set_max_delay -datapath_only 8.0 -to [get_cells -quiet {u_obs_ctrl/u0_reg}]
set_max_delay -datapath_only 8.0 -to [get_cells -quiet {nak0_reg}]
set_max_delay -datapath_only 8.0 -to [get_cells -quiet {cal0_reg}]
set_max_delay -datapath_only 8.0 -to [get_cells -quiet {cv0_reg}]
set_max_delay -datapath_only 8.0 -to [get_cells -quiet {u_dump/freeze_ui0_reg}]
set_max_delay -datapath_only 8.0 -to [get_cells -quiet {u_dump/fr0_reg[*]}]
