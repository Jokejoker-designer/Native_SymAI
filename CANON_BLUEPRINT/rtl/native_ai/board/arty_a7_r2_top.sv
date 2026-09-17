// arty_a7_r2_top.sv — Arty A7-100T fabric top. CANDIDATE. PROGRAM=NO.
// pack_loader + fem_on_mig muxed onto 128b mig_ui_bram dest (not generated mig0).
// M2/M3 walk + SPEAR + Q* on CLK100MHZ. FEM_BASE=28'h0200000 (bit 21).
// Not BOARD_PASS / MIG_PASS / FEM_PERSIST_PASS. OOC/synth != integrated MIG timing.
`timescale 1ns/1ps

module arty_a7_r2_top (
  input  logic       CLK100MHZ,
  input  logic       ck_rst,
  input  logic       uart_rx,
  output logic       uart_tx,
  output logic [3:0] led
);
  logic clk, rst_n;
  assign clk = CLK100MHZ;
  assign rst_n = ck_rst;

  logic w_valid, w_ready;
  logic [31:0] w_data;
  uart_rx_word u_rx (
    .clk, .rst_n, .rx(uart_rx),
    .w_valid(w_valid), .w_ready(w_ready), .w_data(w_data)
  );

  logic load_ack, load_reject;
  logic [7:0] reason_code;
  logic [31:0] active_generation;
  logic [15:0] wr_outstanding;
  logic         calib_ui, pack_busy, fem_ui_busy;
  logic [27:0]  p_addr, f_addr, d_addr;
  logic [2:0]   p_cmd, f_cmd, d_cmd;
  logic         p_en, f_en, d_en, p_end, f_end, d_end, p_wren, f_wren, d_wren;
  logic         p_rdv, f_rdv, d_rdv, p_rdy, f_rdy, d_rdy, p_wdf_rdy, f_wdf_rdy, d_wdf_rdy;
  logic         d_rd_end;
  logic [127:0] p_wdata, f_wdata, d_wdata, p_rdata, f_rdata, d_rdata;
  logic [15:0]  p_mask, f_mask, d_mask;

  (* keep_hierarchy = "yes", dont_touch = "yes" *)
  pack_mig_bind u_ld (
    .clk, .rst_n, .calib_done(calib_ui),
    .s_valid(w_valid), .s_ready(w_ready), .s_data(w_data),
    .load_ack, .load_reject, .reason_code, .active_generation, .wr_outstanding,
    .force_fifo_empty(1'b0), .ui_busy(pack_busy),
    .app_addr(p_addr), .app_cmd(p_cmd), .app_en(p_en),
    .app_wdf_data(p_wdata), .app_wdf_end(p_end),
    .app_wdf_mask(p_mask), .app_wdf_wren(p_wren),
    .app_rd_data(p_rdata), .app_rd_data_valid(p_rdv),
    .app_rdy(p_rdy), .app_wdf_rdy(p_wdf_rdy)
  );

  mig_ui_mux u_mux (
    .clk, .rst_n,
    .a_busy(pack_busy), .a_addr(p_addr), .a_cmd(p_cmd), .a_en(p_en),
    .a_wdf_data(p_wdata), .a_wdf_end(p_end), .a_wdf_mask(p_mask), .a_wdf_wren(p_wren),
    .a_rd_data(p_rdata), .a_rd_valid(p_rdv), .a_rdy(p_rdy), .a_wdf_rdy(p_wdf_rdy),
    .b_busy(fem_ui_busy), .b_addr(f_addr), .b_cmd(f_cmd), .b_en(f_en),
    .b_wdf_data(f_wdata), .b_wdf_end(f_end), .b_wdf_mask(f_mask), .b_wdf_wren(f_wren),
    .b_rd_data(f_rdata), .b_rd_valid(f_rdv), .b_rdy(f_rdy), .b_wdf_rdy(f_wdf_rdy),
    .d_addr, .d_cmd, .d_en, .d_wdf_data(d_wdata), .d_wdf_end(d_end),
    .d_wdf_mask(d_mask), .d_wdf_wren(d_wren),
    .d_rd_data(d_rdata), .d_rd_valid(d_rdv), .d_rdy, .d_wdf_rdy
  );

  mig_ui_bram u_dest (
    .clk, .rst_n, .calib_done(calib_ui), .stall(1'b0),
    .app_addr(d_addr), .app_cmd(d_cmd), .app_en(d_en),
    .app_wdf_data(d_wdata), .app_wdf_end(d_end), .app_wdf_mask(d_mask), .app_wdf_wren(d_wren),
    .app_rd_data(d_rdata), .app_rd_data_end(d_rd_end), .app_rd_data_valid(d_rdv),
    .app_rdy(d_rdy), .app_wdf_rdy(d_wdf_rdy)
  );

  logic [31:0] active_id_max;
  logic [7:0] k_hard;
  logic k_invalid, tie_overflow, spear_done;
  logic [7:0] admitted_count;
  logic cand_ready;

  (* keep_hierarchy = "yes", dont_touch = "yes" *)
  spear_profile_bind u_spear (
    .clk, .rst_n,
    .prof_wr_valid(1'b0),
    .wr_active_id_max(32'h0),
    .wr_k_hard(8'h0),
    .active_id_max(active_id_max),
    .k_hard(k_hard),
    .q_start(1'b0),
    .q_k_soft(8'd4),
    .q_relation_class(4'h0),
    .q_max_hops(4'h1),
    .q_answer_kind(4'h0),
    .q_namespace_id(16'h0),
    .q_generation(16'h0),
    .w_flat(256'h0),
    .cand_valid(1'b0),
    .cand_desc(128'h0),
    .cand_ready(cand_ready),
    .q_end(1'b0),
    .done(spear_done),
    .k_invalid(k_invalid),
    .tie_overflow(tie_overflow),
    .admitted_count(admitted_count)
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
    .clk, .rst_n,
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
    .clk, .rst_n,
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
    .clk, .rst_n, .calib_done(calib_ui),
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

  logic ack_d, nak_d, st_valid, st_ready;
  logic [31:0] st_data;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      ack_d <= 1'b0;
      nak_d <= 1'b0;
      st_valid <= 1'b0;
      st_data <= 32'h0;
    end else begin
      ack_d <= load_ack;
      nak_d <= load_reject;
      if (st_valid && st_ready) st_valid <= 1'b0;
      else if (!st_valid) begin
        if (load_ack && !ack_d) begin
          st_data <= {8'h01, 8'h00, reason_code, 8'hA5};
          st_valid <= 1'b1;
        end else if (load_reject && !nak_d) begin
          st_data <= {8'h02, 8'h00, reason_code, 8'h5A};
          st_valid <= 1'b1;
        end
      end
    end
  end

  uart_tx_word u_tx (
    .clk, .rst_n, .w_valid(st_valid), .w_ready(st_ready), .w_data(st_data), .tx(uart_tx)
  );
  assign led = {load_reject, load_ack, k_invalid, q_pending};
endmodule
