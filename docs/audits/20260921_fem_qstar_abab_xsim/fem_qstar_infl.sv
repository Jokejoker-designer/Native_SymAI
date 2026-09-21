// fem_qstar_infl.sv — D-only FEM influence into frozen Q*.
// Does not edit fem_lifecycle / qstar_select / spear_rank.
// fem_rst_n clears FEM only. Q* reset is rst_n, so theta survives FRST.
// SPEAR is not in this DUT. legal_mask is a fixture, not ASTRA.
// Not FEM_PERSIST_PASS. Not BOARD_PASS. PROGRAM=NO.
`timescale 1ns/1ps

module fem_qstar_infl (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        fem_rst_n,
  input  logic        calib_done,

  input  logic        ing_valid,
  input  logic [1:0]  ing_domain,
  input  logic [3:0]  ing_stage,
  input  logic [3:0]  ing_cap,
  input  logic [2:0]  ing_macro,
  input  logic [3:0]  ing_prim,
  input  logic [3:0]  ing_effect,
  input  logic [2:0]  ing_ctx,
  output logic        ing_done,
  output logic        ing_accepted,

  input  logic        rep_valid,
  input  logic [7:0]  rep_skill_id,
  input  logic [7:0]  rep_skill_ver,
  output logic        rep_done,
  output logic        rep_accepted,

  input  logic        cmp_start,
  output logic        cmp_done,
  output logic [2:0]  cmp_result,
  output logic [3:0]  txn_step,

  input  logic        rec_start,
  output logic        rec_done,
  output logic [1:0]  recover_state,
  output logic        integrity_fault,

  output logic        fem_busy,
  output logic [2:0]  life_state,
  output logic [7:0]  failure_total,
  output logic [7:0]  failure_recent,
  output logic [7:0]  success_after_repair,
  output logic        unresolved,
  output logic        compacted,
  output logic [15:0] key,
  output logic [3:0]  n_raw,
  output logic        t2_err,

  input  logic        fem_infl_en,
  input  logic        theta_we,
  input  logic [5:0]  theta_addr,
  input  logic [15:0] theta_wdata,
  output logic [15:0] theta_rdata,
  input  logic        prop_start,
  output logic        prop_done,
  output logic        prop_valid,
  output logic [2:0]  greedy_action,
  output logic [2:0]  proposed_action,
  output logic        explored,
  output logic [31:0] q_sel,
  output logic [7:0]  feat0_obs,

  output logic [27:0]  app_addr,
  output logic [2:0]   app_cmd,
  output logic         app_en,
  output logic [127:0] app_wdf_data,
  output logic         app_wdf_end,
  output logic [15:0]  app_wdf_mask,
  output logic         app_wdf_wren,
  input  logic [127:0] app_rd_data,
  input  logic         app_rd_data_valid,
  input  logic         app_rdy,
  input  logic         app_wdf_rdy
);
  logic [7:0] fem_feat;
  logic [15:0] ingress_rejected, key_mismatch, exemplar_full, wr_outstanding;
  logic [2:0] regression_count;
  logic cmd_fifo_empty, ui_busy;
  logic prop_refused, no_legal, q_sat, q_pending, q_busy;
  logic upd_done, upd_applied;
  logic [3:0] upd_reason;
  logic [31:0] delta_out;
  logic [15:0] q_policy_version, lfsr_state, theta_rdata_w;
  logic [15:0] explore_count, credit_denied_count, no_legal_count;
  logic [15:0] illegal_exec_count, exam_blocked_count, illegal_selection_count, prop_refused_count;

  assign feat0_obs = fem_infl_en ? failure_total : 8'h00;
  assign theta_rdata = theta_rdata_w;

  fem_on_mig #(.FEM_BASE(28'h0200000)) u_fem (
    .clk(clk), .rst_n(fem_rst_n), .calib_done(calib_done),
    .ing_valid(ing_valid), .ing_domain(ing_domain), .ing_stage(ing_stage),
    .ing_cap(ing_cap), .ing_macro(ing_macro), .ing_prim(ing_prim),
    .ing_effect(ing_effect), .ing_ctx(ing_ctx),
    .ing_done(ing_done), .ing_accepted(ing_accepted),
    .rep_valid(rep_valid), .rep_skill_id(rep_skill_id), .rep_skill_ver(rep_skill_ver),
    .rep_done(rep_done), .rep_accepted(rep_accepted),
    .cmp_start(cmp_start), .cmp_done(cmp_done), .cmp_result(cmp_result), .txn_step(txn_step),
    .rec_start(rec_start), .rec_done(rec_done), .recover_state(recover_state),
    .integrity_fault(integrity_fault),
    .busy(fem_busy), .life_state(life_state), .failure_total(failure_total),
    .failure_recent(failure_recent), .success_after_repair(success_after_repair),
    .regression_count(regression_count), .unresolved(unresolved), .compacted(compacted),
    .key(key), .n_raw(n_raw), .ingress_rejected(ingress_rejected),
    .key_mismatch(key_mismatch), .exemplar_full(exemplar_full), .fem_feat(fem_feat),
    .force_fifo_empty(1'b0), .inject_tear(1'b0),
    .wr_outstanding(wr_outstanding), .cmd_fifo_empty(cmd_fifo_empty), .t2_err(t2_err),
    .ui_busy(ui_busy),
    .app_addr(app_addr), .app_cmd(app_cmd), .app_en(app_en),
    .app_wdf_data(app_wdf_data), .app_wdf_end(app_wdf_end),
    .app_wdf_mask(app_wdf_mask), .app_wdf_wren(app_wdf_wren),
    .app_rd_data(app_rd_data), .app_rd_data_valid(app_rd_data_valid),
    .app_rdy(app_rdy), .app_wdf_rdy(app_wdf_rdy)
  );

  qstar_select u_q (
    .clk(clk), .rst_n(rst_n),
    .prop_start(prop_start),
    .feat_flat({56'h0, feat0_obs}),
    .legal_mask(8'h03),
    .exam(1'b1),
    .epsilon16(16'h0),
    .prop_done(prop_done), .prop_valid(prop_valid), .prop_refused(prop_refused),
    .pending(q_pending), .proposed_action(proposed_action), .greedy_action(greedy_action),
    .explored(explored), .no_legal(no_legal), .q_sel(q_sel), .q_sat(q_sat),
    .upd_start(1'b0), .exec_valid(1'b0), .exec_action(3'h0), .reward_accepted(1'b0),
    .reward16(16'h0), .qnext_max32(32'h0), .alpha8(8'h0), .gamma8(8'h0),
    .upd_done(upd_done), .upd_applied(upd_applied), .upd_reason(upd_reason), .delta_out(delta_out),
    .learn_reset(1'b0), .theta_we(theta_we), .theta_addr(theta_addr), .theta_wdata(theta_wdata),
    .theta_rdata(theta_rdata_w), .version_we(1'b0), .version_wdata(16'h0),
    .q_policy_version(q_policy_version), .lfsr_we(1'b0), .lfsr_wdata(16'h0), .lfsr_state(lfsr_state),
    .busy(q_busy), .explore_count(explore_count), .credit_denied_count(credit_denied_count),
    .no_legal_count(no_legal_count), .illegal_exec_count(illegal_exec_count),
    .exam_blocked_count(exam_blocked_count), .illegal_selection_count(illegal_selection_count),
    .prop_refused_count(prop_refused_count)
  );
endmodule
