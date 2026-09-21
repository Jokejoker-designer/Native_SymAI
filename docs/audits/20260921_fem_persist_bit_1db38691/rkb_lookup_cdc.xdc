# RKB_DIR_POST_EDGE lookup CDC: clk100 <-> ui_clk. Apply at synth AND impl.
# Unique board candidate. Not TIMING_PASS. PROGRAM=NO.
# Does not overwrite CT1 ct1_lookup_cdc.xdc.

set_property ASYNC_REG TRUE [get_cells -quiet {u_qcdc/req_u0_reg u_qcdc/req_u1_reg u_qcdc/req_u2_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {u_qcdc/ack_c0_reg u_qcdc/ack_c1_reg u_qcdc/ack_c2_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {root100_0_reg root100_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {flsh_u0_reg flsh_u1_reg flsh_u2_reg}]

set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_qcdc/req_tog_reg}] -to [get_cells -quiet {u_qcdc/req_u0_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_qcdc/ack_tog_reg}] -to [get_cells -quiet {u_qcdc/ack_c0_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_qcdc/sid_hold_reg[*]}] -to [get_cells -quiet {u_walk/sid_r_reg[*]}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_qcdc/hit_lat_reg u_qcdc/nb_lat_reg[*]}] \
  -to [get_cells -quiet {u_qcdc/hit_hold_reg u_qcdc/nb_hold_reg[*]}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_cache/pub_v_reg}] -to [get_cells -quiet {root100_0_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {flsh_tog_reg}] -to [get_cells -quiet {flsh_u0_reg}]

# dest_diag CDC + WALK_TAP 2FF. Unique dest causal TAP. Not TIMING_PASS.
set_property ASYNC_REG TRUE [get_cells -quiet {u_dcdc/req_u0_reg u_dcdc/req_u1_reg u_dcdc/req_u2_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {u_dcdc/ack_c0_reg u_dcdc/ack_c1_reg u_dcdc/ack_c2_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {tap_sid100_0_reg[*] tap_sid100_reg[*]}]
set_property ASYNC_REG TRUE [get_cells -quiet {tap_nb100_0_reg[*] tap_nb100_reg[*]}]
set_property ASYNC_REG TRUE [get_cells -quiet {tap_gen100_0_reg[*] tap_gen100_reg[*]}]
set_property ASYNC_REG TRUE [get_cells -quiet {tap_e0100_0_reg[*] tap_e0100_reg[*]}]
set_property ASYNC_REG TRUE [get_cells -quiet {tap_root100_0_reg[*] tap_root100_reg[*]}]
set_property ASYNC_REG TRUE [get_cells -quiet {tap_rd100_0_reg[*] tap_rd100_reg[*]}]
set_property ASYNC_REG TRUE [get_cells -quiet {tap_rdd100_0_reg[*] tap_rdd100_reg[*]}]
set_property ASYNC_REG TRUE [get_cells -quiet {tap_hit100_0_reg tap_hit100_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {tap_t1100_0_reg tap_t1100_reg}]

set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_dcdc/req_tog_reg}] -to [get_cells -quiet {u_dcdc/req_u0_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_dcdc/ack_tog_reg}] -to [get_cells -quiet {u_dcdc/ack_c0_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_dcdc/addr_hold_reg[*] u_dcdc/wr_hold_reg u_dcdc/wdata_hold_reg[*] u_dcdc/wmask_hold_reg[*]}] \
  -to [get_cells -quiet {u_dgui/addr_r_reg[*] u_dgui/wr_r_reg u_dgui/wdata_r_reg[*] u_dgui/wmask_r_reg[*]}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_dcdc/rdata_lat_reg[*]}] -to [get_cells -quiet {u_dcdc/rdata_hold_reg[*]}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {tap_sid_ui_reg[*]}] -to [get_cells -quiet {tap_sid100_0_reg[*]}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {tap_nb_ui_reg[*]}] -to [get_cells -quiet {tap_nb100_0_reg[*]}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {tap_gen_ui_reg[*]}] -to [get_cells -quiet {tap_gen100_0_reg[*]}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {tap_e0_ui_reg[*]}] -to [get_cells -quiet {tap_e0100_0_reg[*]}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {tap_root_ui_reg[*]}] -to [get_cells -quiet {tap_root100_0_reg[*]}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {tap_rd_ui_reg[*]}] -to [get_cells -quiet {tap_rd100_0_reg[*]}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {tap_rd_delta_ui_reg[*]}] -to [get_cells -quiet {tap_rdd100_0_reg[*]}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {tap_hit_ui_reg}] -to [get_cells -quiet {tap_hit100_0_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {tap_t1_ui_reg}] -to [get_cells -quiet {tap_t1100_0_reg}]

# FEM persist UART CDC. Unique identity. Not TIMING_PASS. PROGRAM=NO.
set_property ASYNC_REG TRUE [get_cells -quiet {u_fcdc/req_u0_reg u_fcdc/req_u1_reg u_fcdc/req_u2_reg}]
set_property ASYNC_REG TRUE [get_cells -quiet {u_fcdc/ack_c0_reg u_fcdc/ack_c1_reg u_fcdc/ack_c2_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_fcdc/req_tog_reg}] -to [get_cells -quiet {u_fcdc/req_u0_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_fcdc/ack_tog_reg}] -to [get_cells -quiet {u_fcdc/ack_c0_reg}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_fcdc/op_hold_reg[*] u_fcdc/arg_hold_reg[*]}] \
  -to [get_cells -quiet {u_fcdc/op_u_reg[*] u_fcdc/arg_u_reg[*]}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_fcdc/op_hold_reg[*] u_fcdc/arg_hold_reg[*]}] \
  -to [get_cells -quiet {u_fcdc/ing_domain_reg[*] u_fcdc/ing_ctx_reg[*] u_fcdc/rep_skill_id_reg[*] u_fcdc/rep_skill_ver_reg[*] u_fcdc/FSM_sequential_ust_reg[*] u_fcdc/rst_cnt_reg[*] u_fcdc/ing_valid_reg u_fcdc/rep_valid_reg u_fcdc/cmp_start_reg u_fcdc/rec_start_reg u_fcdc/fem_rst_hold_reg u_fcdc/s4_lat_reg[*]}]
set_max_delay -datapath_only 8.0 \
  -from [get_cells -quiet {u_fcdc/s0_lat_reg[*] u_fcdc/s1_lat_reg[*] u_fcdc/s2_lat_reg[*] u_fcdc/s3_lat_reg[*] u_fcdc/s4_lat_reg[*]}] \
  -to [get_cells -quiet {u_fcdc/s0_h_reg[*] u_fcdc/s1_h_reg[*] u_fcdc/s2_h_reg[*] u_fcdc/s3_h_reg[*] u_fcdc/s4_h_reg[*]}]
