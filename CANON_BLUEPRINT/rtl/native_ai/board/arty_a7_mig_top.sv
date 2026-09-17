// arty_a7_mig_top.sv — Arty A7-100T: clk_arty_mig + generated mig0 + pack_mig_bind.
// CANDIDATE. PROGRAM=NO. Not MIG_PASS / BOARD_PASS / FEM_PERSIST_PASS.
// UART at 100 MHz; pack + FEM + Q*/SPEAR/walk on ui_clk. Not MIG_PASS.
`timescale 1ns/1ps

module arty_a7_mig_top (
  input  logic        CLK100MHZ,
  input  logic        ck_rst,
  input  logic        uart_rx,
  output logic        uart_tx,
  output logic [3:0]  led,
  inout  [15:0]       ddr3_dq,
  inout  [1:0]        ddr3_dqs_n,
  inout  [1:0]        ddr3_dqs_p,
  output [13:0]       ddr3_addr,
  output [2:0]        ddr3_ba,
  output              ddr3_ras_n,
  output              ddr3_cas_n,
  output              ddr3_we_n,
  output              ddr3_reset_n,
  output [0:0]        ddr3_ck_p,
  output [0:0]        ddr3_ck_n,
  output [0:0]        ddr3_cke,
  output [0:0]        ddr3_cs_n,
  output [1:0]        ddr3_dm,
  output [0:0]        ddr3_odt
);
  logic clk100, rst100_n, clk_sys166, clk_ref200, clk_locked;
  assign clk100 = CLK100MHZ;
  assign rst100_n = ck_rst & clk_locked;

  clk_arty_mig u_clk (
    .clk100(CLK100MHZ), .rst_n(ck_rst),
    .clk_sys166, .clk_ref200, .clk_locked
  );

  logic        ui_clk, ui_rst_h, calib, sys_rst_i;
  logic [11:0] device_temp;
  logic        app_sr_active, app_ref_ack, app_zq_ack, app_rd_data_end;
  logic [27:0]  p_addr, f_addr, app_addr;
  logic [2:0]   p_cmd, f_cmd, app_cmd;
  logic         p_en, f_en, app_en, p_end, f_end, app_wdf_end, p_wren, f_wren, app_wdf_wren;
  logic         p_rdv, f_rdv, app_rd_data_valid, p_rdy, f_rdy, app_rdy;
  logic         p_wdf_rdy, f_wdf_rdy, app_wdf_rdy, pack_busy, fem_ui_busy;
  logic [127:0] p_wdata, f_wdata, app_wdf_data, p_rdata, f_rdata, app_rd_data;
  logic [15:0]  p_mask, f_mask, app_wdf_mask;

  // MIG sys_rst is active-low. Hold in reset until MMCM locks.
  assign sys_rst_i = ck_rst & clk_locked;

  mig0 u_mig (
    .ddr3_dq, .ddr3_dqs_n, .ddr3_dqs_p,
    .ddr3_addr, .ddr3_ba, .ddr3_ras_n, .ddr3_cas_n, .ddr3_we_n, .ddr3_reset_n,
    .ddr3_ck_p, .ddr3_ck_n, .ddr3_cke, .ddr3_cs_n, .ddr3_dm, .ddr3_odt,
    .sys_clk_i(clk_sys166), .clk_ref_i(clk_ref200),
    .app_addr, .app_cmd, .app_en, .app_wdf_data, .app_wdf_end, .app_wdf_mask, .app_wdf_wren,
    .app_rd_data, .app_rd_data_end, .app_rd_data_valid, .app_rdy, .app_wdf_rdy,
    .app_sr_req(1'b0), .app_ref_req(1'b0), .app_zq_req(1'b0),
    .app_sr_active, .app_ref_ack, .app_zq_ack,
    .ui_clk, .ui_clk_sync_rst(ui_rst_h), .init_calib_complete(calib),
    .device_temp, .sys_rst(sys_rst_i)
  );

  logic rst_ui_n;
  assign rst_ui_n = ~ui_rst_h;

  logic w_valid, w_ready;
  logic [31:0] w_data;
  uart_rx_word u_rx (
    .clk(clk100), .rst_n(rst100_n), .rx(uart_rx),
    .w_valid(w_valid), .w_ready(w_ready), .w_data(w_data)
  );

  logic p_valid, p_ready;
  logic [31:0] p_data;
  word_cdc32 u_cdc (
    .a_clk(clk100), .a_rst_n(rst100_n), .a_valid(w_valid), .a_ready(w_ready), .a_data(w_data),
    .b_clk(ui_clk), .b_rst_n(rst_ui_n), .b_valid(p_valid), .b_ready(p_ready), .b_data(p_data)
  );

  logic load_ack, load_reject;
  logic [7:0] reason_code;
  logic [31:0] active_generation;
  logic [15:0] wr_outstanding;

  pack_mig_bind u_ld (
    .clk(ui_clk), .rst_n(rst_ui_n), .calib_done(calib),
    .s_valid(p_valid), .s_ready(p_ready), .s_data(p_data),
    .load_ack, .load_reject, .reason_code, .active_generation, .wr_outstanding,
    .force_fifo_empty(1'b0), .ui_busy(pack_busy),
    .app_addr(p_addr), .app_cmd(p_cmd), .app_en(p_en),
    .app_wdf_data(p_wdata), .app_wdf_end(p_end), .app_wdf_mask(p_mask), .app_wdf_wren(p_wren),
    .app_rd_data(p_rdata), .app_rd_data_valid(p_rdv), .app_rdy(p_rdy), .app_wdf_rdy(p_wdf_rdy)
  );

  mig_ui_mux u_mux (
    .clk(ui_clk), .rst_n(rst_ui_n),
    .a_busy(pack_busy), .a_addr(p_addr), .a_cmd(p_cmd), .a_en(p_en),
    .a_wdf_data(p_wdata), .a_wdf_end(p_end), .a_wdf_mask(p_mask), .a_wdf_wren(p_wren),
    .a_rd_data(p_rdata), .a_rd_valid(p_rdv), .a_rdy(p_rdy), .a_wdf_rdy(p_wdf_rdy),
    .b_busy(fem_ui_busy), .b_addr(f_addr), .b_cmd(f_cmd), .b_en(f_en),
    .b_wdf_data(f_wdata), .b_wdf_end(f_end), .b_wdf_mask(f_mask), .b_wdf_wren(f_wren),
    .b_rd_data(f_rdata), .b_rd_valid(f_rdv), .b_rdy(f_rdy), .b_wdf_rdy(f_wdf_rdy),
    .d_addr(app_addr), .d_cmd(app_cmd), .d_en(app_en), .d_wdf_data(app_wdf_data),
    .d_wdf_end(app_wdf_end), .d_wdf_mask(app_wdf_mask), .d_wdf_wren(app_wdf_wren),
    .d_rd_data(app_rd_data), .d_rd_valid(app_rd_data_valid), .d_rdy(app_rdy), .d_wdf_rdy(app_wdf_rdy)
  );

  logic [31:0] active_id_max;
  logic [7:0] k_hard;
  logic k_invalid, tie_overflow, spear_done;
  logic [7:0] admitted_count;
  logic cand_ready;

  (* keep_hierarchy = "yes", dont_touch = "yes" *)
  spear_profile_bind u_spear (
    .clk(ui_clk), .rst_n(rst_ui_n),
    .prof_wr_valid(1'b0), .wr_active_id_max(32'h0), .wr_k_hard(8'h0),
    .active_id_max(active_id_max), .k_hard(k_hard),
    .q_start(1'b0), .q_k_soft(8'd4), .q_relation_class(4'h0), .q_max_hops(4'h1),
    .q_answer_kind(4'h0), .q_namespace_id(16'h0), .q_generation(16'h0), .w_flat(256'h0),
    .cand_valid(1'b0), .cand_desc(128'h0), .cand_ready(cand_ready), .q_end(1'b0),
    .done(spear_done), .k_invalid(k_invalid), .tie_overflow(tie_overflow), .admitted_count(admitted_count)
  );

  logic q_pending, q_busy, prop_done, prop_valid, prop_refused;
  logic [2:0] proposed_action, greedy_action;
  logic explored, no_legal, q_sat;
  logic [31:0] q_sel;
  logic upd_done, upd_applied;
  logic [3:0] upd_reason;
  logic [31:0] delta_out;
  logic [15:0] theta_rdata, q_policy_version, lfsr_state;
  logic [15:0] explore_count, credit_denied_count, no_legal_count;
  logic [15:0] illegal_exec_count, exam_blocked_count, illegal_selection_count, prop_refused_count;

  (* keep_hierarchy = "yes", dont_touch = "yes" *)
  qstar_select u_q (
    .clk(ui_clk), .rst_n(rst_ui_n),
    .prop_start(1'b0), .feat_flat(64'h0), .legal_mask(8'h0), .exam(1'b0), .epsilon16(16'h0),
    .prop_done(prop_done), .prop_valid(prop_valid), .prop_refused(prop_refused),
    .pending(q_pending), .proposed_action(proposed_action), .greedy_action(greedy_action),
    .explored(explored), .no_legal(no_legal), .q_sel(q_sel), .q_sat(q_sat),
    .upd_start(1'b0), .exec_valid(1'b0), .exec_action(3'h0), .reward_accepted(1'b0),
    .reward16(16'h0), .qnext_max32(32'h0), .alpha8(8'h0), .gamma8(8'h0),
    .upd_done(upd_done), .upd_applied(upd_applied), .upd_reason(upd_reason), .delta_out(delta_out),
    .learn_reset(1'b0), .theta_we(1'b0), .theta_addr(6'h0), .theta_wdata(16'h0),
    .theta_rdata(theta_rdata), .version_we(1'b0), .version_wdata(16'h0),
    .q_policy_version(q_policy_version), .lfsr_we(1'b0), .lfsr_wdata(16'h0), .lfsr_state(lfsr_state),
    .busy(q_busy), .explore_count(explore_count), .credit_denied_count(credit_denied_count),
    .no_legal_count(no_legal_count), .illegal_exec_count(illegal_exec_count),
    .exam_blocked_count(exam_blocked_count), .illegal_selection_count(illegal_selection_count),
    .prop_refused_count(prop_refused_count)
  );

  logic bw_rdy, bw_rsp, bw_hit, bw_oop, bw_inc;
  logic [3:0] hops;
  logic [31:0] end_id;
  logic [15:0] last_count;

  (* keep_hierarchy = "yes", dont_touch = "yes" *)
  bounded_walk u_bw (
    .clk(ui_clk), .rst_n(rst_ui_n),
    .req_valid(1'b0), .req_ready(bw_rdy), .start_id(32'h0), .hop_budget(4'h1),
    .want_rev(1'b0), .active_id_max(active_id_max),
    .rsp_valid(bw_rsp), .rsp_ready(1'b1),
    .hit(bw_hit), .out_of_profile(bw_oop), .incomplete(bw_inc),
    .hops_taken(hops), .end_id, .last_count
  );

  logic fem_busy, integrity_fault;
  logic [1:0] recover_state;
  logic [2:0] life_state, cmp_result, regression_count;
  logic [3:0] txn_step, n_raw;
  logic ing_done, ing_accepted, rep_done, rep_accepted, cmp_done, rec_done;
  logic unresolved_f, compacted_f, fem_t2_err, cmd_fifo_empty;
  logic [7:0] failure_total, failure_recent, success_after_repair, fem_feat;
  logic [15:0] fem_key, fem_rej, key_mismatch, exemplar_full, fem_wr_out;

  (* keep_hierarchy = "yes", dont_touch = "yes" *)
  fem_on_mig #(.FEM_BASE(28'h0200000)) u_fem (
    .clk(ui_clk), .rst_n(rst_ui_n), .calib_done(calib),
    .ing_valid(1'b0), .ing_domain(2'h0), .ing_stage(4'h0), .ing_cap(4'h0),
    .ing_macro(3'h0), .ing_prim(4'h0), .ing_effect(4'h0), .ing_ctx(3'h0),
    .ing_done(ing_done), .ing_accepted(ing_accepted),
    .rep_valid(1'b0), .rep_skill_id(8'h0), .rep_skill_ver(8'h0),
    .rep_done(rep_done), .rep_accepted(rep_accepted),
    .cmp_start(1'b0), .cmp_done(cmp_done), .cmp_result(cmp_result), .txn_step(txn_step),
    .rec_start(1'b0), .rec_done(rec_done), .recover_state(recover_state), .integrity_fault(integrity_fault),
    .busy(fem_busy), .life_state(life_state), .failure_total(failure_total),
    .failure_recent(failure_recent), .success_after_repair(success_after_repair),
    .regression_count(regression_count), .unresolved(unresolved_f), .compacted(compacted_f),
    .key(fem_key), .n_raw(n_raw), .ingress_rejected(fem_rej), .key_mismatch(key_mismatch),
    .exemplar_full(exemplar_full), .fem_feat(fem_feat),
    .force_fifo_empty(1'b0), .inject_tear(1'b0),
    .wr_outstanding(fem_wr_out), .cmd_fifo_empty(cmd_fifo_empty), .t2_err(fem_t2_err),
    .ui_busy(fem_ui_busy),
    .app_addr(f_addr), .app_cmd(f_cmd), .app_en(f_en),
    .app_wdf_data(f_wdata), .app_wdf_end(f_end), .app_wdf_mask(f_mask), .app_wdf_wren(f_wren),
    .app_rd_data(f_rdata), .app_rd_data_valid(f_rdv), .app_rdy(f_rdy), .app_wdf_rdy(f_wdf_rdy)
  );

  assign led = {calib, load_ack, load_reject, clk_locked};

  logic ack_d, nak_d, st_valid_ui, st_ready_ui;
  logic [31:0] st_data_ui;
  always_ff @(posedge ui_clk or negedge rst_ui_n) begin
    if (!rst_ui_n) begin
      ack_d <= 1'b0;
      nak_d <= 1'b0;
      st_valid_ui <= 1'b0;
      st_data_ui <= 32'h0;
    end else begin
      ack_d <= load_ack;
      nak_d <= load_reject;
      if (st_valid_ui && st_ready_ui) st_valid_ui <= 1'b0;
      else if (!st_valid_ui) begin
        if (load_ack && !ack_d) begin
          st_data_ui <= {8'h01, 8'h00, reason_code, 8'hA5};
          st_valid_ui <= 1'b1;
        end else if (load_reject && !nak_d) begin
          st_data_ui <= {8'h02, 8'h00, reason_code, 8'h5A};
          st_valid_ui <= 1'b1;
        end
      end
    end
  end

  logic st_valid_100, st_ready_100;
  logic [31:0] st_data_100;
  word_cdc32 u_cdc_tx (
    .a_clk(ui_clk), .a_rst_n(rst_ui_n),
    .a_valid(st_valid_ui), .a_ready(st_ready_ui), .a_data(st_data_ui),
    .b_clk(clk100), .b_rst_n(rst100_n),
    .b_valid(st_valid_100), .b_ready(st_ready_100), .b_data(st_data_100)
  );

  uart_tx_word u_tx (
    .clk(clk100), .rst_n(rst100_n),
    .w_valid(st_valid_100), .w_ready(st_ready_100), .w_data(st_data_100),
    .tx(uart_tx)
  );
endmodule
