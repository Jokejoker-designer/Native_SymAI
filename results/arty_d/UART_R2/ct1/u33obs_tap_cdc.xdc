# U33OBS TAP dump CDCs + OBS 2FF + U32 busy CDC. Apply at synth AND impl.
# Unique identity. Not TIMING_PASS. Not PACK_ABI_24_24_PASS.
# Vivado 2026.1: set_max_delay -datapath_only requires non-empty -from AND -to.
# No Tcl proc/if in this file (read_xdc rejects them).

set_property ASYNC_REG TRUE [get_cells -quiet {busy_u0_reg busy_u1_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {tx_busy_100_r_reg}] -to [get_cells -quiet {busy_u0_reg}]

# u_dump/u_cdc_tap: ui_clk -> clk100
set_property ASYNC_REG TRUE [get_cells -quiet {u_dump/u_cdc_tap/ack_a0_reg u_dump/u_cdc_tap/ack_a1_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {u_dump/u_cdc_tap/req_b0_reg u_dump/u_cdc_tap/req_b1_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_dump/u_cdc_tap/req_a_reg}] -to [get_cells -quiet {u_dump/u_cdc_tap/req_b0_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_dump/u_cdc_tap/ack_b_reg}] -to [get_cells -quiet {u_dump/u_cdc_tap/ack_a0_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_dump/u_cdc_tap/hold_reg[*]}] -to [get_cells -quiet {u_dump/u_cdc_tap/b_data_reg[*]}]

# u_dump/u_cdc_u2ui: clk100 -> ui_clk
set_property ASYNC_REG TRUE [get_cells -quiet {u_dump/u_cdc_u2ui/ack_a0_reg u_dump/u_cdc_u2ui/ack_a1_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {u_dump/u_cdc_u2ui/req_b0_reg u_dump/u_cdc_u2ui/req_b1_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_dump/u_cdc_u2ui/req_a_reg}] -to [get_cells -quiet {u_dump/u_cdc_u2ui/req_b0_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_dump/u_cdc_u2ui/ack_b_reg}] -to [get_cells -quiet {u_dump/u_cdc_u2ui/ack_a0_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_dump/u_cdc_u2ui/hold_reg[*]}] -to [get_cells -quiet {u_dump/u_cdc_u2ui/b_data_reg[*]}]

# OBS 2FF: do not time 100 MHz vs ui_clk as a 2 ns related-clock sync path.
set_property ASYNC_REG TRUE [get_cells -quiet {u_obs_ctrl/a0_reg u_obs_ctrl/a1_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {u_obs_ctrl/u0_reg u_obs_ctrl/u1_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {nak0_reg nak1_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {cal0_reg cal1_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {cv0_reg cv_ui_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {epoch_ui_reg[*]}]
set_property ASYNC_REG TRUE [get_cells -quiet {u_dump/freeze_ui0_reg u_dump/freeze_ui_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {u_dump/fr0_reg[*] u_dump/fr_ui_reg[*]}]

set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_obs_ctrl/ack_ui_reg_replica u_obs_ctrl/ack_ui_reg}] \
  -to [get_cells -quiet {u_obs_ctrl/a0_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_obs_ctrl/arm_hold_reg u_obs_ctrl/req_100_reg}] \
  -to [get_cells -quiet {u_obs_ctrl/u0_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_ld/u_ld/load_reject_reg}] \
  -to [get_cells -quiet {nak0_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_obs_ctrl/valid_r_reg u_obs_ctrl/freeze_r_reg}] \
  -to [get_cells -quiet {cv0_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_obs_ctrl/freeze_r_reg}] \
  -to [get_cells -quiet {u_dump/freeze_ui0_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_obs_ctrl/reason_r_reg[*]}] \
  -to [get_cells -quiet {u_dump/fr0_reg[*]}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_obs_ctrl/epoch_r_reg[*]}] \
  -to [get_cells -quiet {epoch_ui_reg[*]}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet -hier -filter {NAME =~ *init_calib_complete_reg*}] \
  -to [get_cells -quiet {cal0_reg}]

# CLEAR re-arm 2FF: ui_clk debug_clear -> clk100. Do not time as 2 ns related-clock.
set_property ASYNC_REG TRUE [get_cells -quiet {clr100_0_reg clr100_1_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_uiclr/debug_clear_reg}] \
  -to [get_cells -quiet {clr100_0_reg}]

# Query stale: ui_clk active_generation -> clk100 2FF. Do not time as 2 ns related-clock.
set_property ASYNC_REG TRUE [get_cells -quiet {gen100_0_reg[*] gen100_reg[*]}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_ld/u_ld/active_generation_reg[*]}] \
  -to [get_cells -quiet {gen100_0_reg[*]}]
