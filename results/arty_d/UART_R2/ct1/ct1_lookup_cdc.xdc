# CT1 lookup CDC: clk100 <-> ui_clk. Apply at synth AND impl.
# Unique CT1 identity. Not TIMING_PASS. Not PACK_ABI_24_24_PASS. PROGRAM=NO.

set_property ASYNC_REG TRUE [get_cells -quiet {u_qcdc/req_u0_reg u_qcdc/req_u1_reg u_qcdc/req_u2_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {u_qcdc/ack_c0_reg u_qcdc/ack_c1_reg u_qcdc/ack_c2_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {root100_0_reg root100_reg}]

set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_qcdc/req_tog_reg}] -to [get_cells -quiet {u_qcdc/req_u0_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_qcdc/ack_tog_reg}] -to [get_cells -quiet {u_qcdc/ack_c0_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_qcdc/sid_hold_reg[*]}] -to [get_cells -quiet {u_cache/sid_r_reg[*]}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_qcdc/hit_lat_reg u_qcdc/nb_lat_reg[*]}] \
  -to [get_cells -quiet {u_qcdc/hit_hold_reg u_qcdc/nb_hold_reg[*]}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_cache/pub_v_reg}] -to [get_cells -quiet {root100_0_reg}]
