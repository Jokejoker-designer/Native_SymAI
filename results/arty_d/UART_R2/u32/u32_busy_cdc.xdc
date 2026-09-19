# U32 busy CDC: clk100 FF then 2FF to ui_clk. Do not patch PACKAGE xdc.
# Not TIMING_PASS.

set_property ASYNC_REG TRUE [get_cells -quiet {busy_u0_reg busy_u1_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {tx_busy_100_r_reg}] -to [get_cells -quiet {busy_u0_reg}]
