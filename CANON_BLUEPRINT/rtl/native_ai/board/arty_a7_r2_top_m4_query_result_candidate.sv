// Isolated common-runtime QueryRecord→StructuredResult candidate. PROGRAM=NO.
// Do not overwrite frozen r2_top / R2_FE256_R1_INTEGRATED_FREEZE / FE256_R1_REFERENCE_FREEZE.
// No fe256_query_path. uart_fe256_host reused for 0x4E51/0x4E52 word packing only.
`timescale 1ns/1ps

module arty_a7_r2_top_m4_query_result_candidate (
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

  logic tb_steer;
  logic tb_q_valid;
  logic tb_r_ready;
  logic [255:0] tb_q_pack;
  initial begin
    tb_steer   = 1'b0;
    tb_q_valid = 1'b0;
    tb_r_ready = 1'b1;
    tb_q_pack  = 256'h0;
  end

  logic        q_taking, qh_in_ready;
  logic        uart_q_valid, uart_q_ready, uart_r_ready;
  logic        uart_tx_valid, uart_tx_ready;
  logic [31:0] uart_tx_data;
  logic [7:0]  uart_q_bytes [0:31];
  logic [7:0]  cr_q_bytes [0:31];
  logic [7:0]  cr_r_bytes [0:47];
  logic        cr_q_valid, cr_q_ready, cr_r_valid, cr_r_ready, cr_s_ready;
  logic [31:0] active_id_max;

  uart_fe256_host u_qhost (
    .clk, .rst_n,
    .in_valid(w_valid), .in_ready(qh_in_ready), .in_data(w_data),
    .taking(q_taking),
    .q_valid(uart_q_valid), .q_ready(uart_q_ready), .q_bytes(uart_q_bytes),
    .r_valid(cr_r_valid), .r_ready(uart_r_ready), .r_bytes(cr_r_bytes),
    .tx_valid(uart_tx_valid), .tx_ready(uart_tx_ready), .tx_data(uart_tx_data)
  );

  integer tbi;
  always_comb begin
    for (tbi = 0; tbi < 32; tbi++)
      cr_q_bytes[tbi] = tb_steer ? tb_q_pack[8*tbi +: 8] : uart_q_bytes[tbi];
  end
  assign cr_q_valid   = tb_steer ? tb_q_valid : uart_q_valid;
  assign uart_q_ready = tb_steer ? 1'b0 : cr_q_ready;
  assign cr_r_ready    = tb_steer ? tb_r_ready : uart_r_ready;

  (* keep_hierarchy = "yes" *)
  query_result_bind u_cr (
    .clk, .rst_n,
    .q_valid(cr_q_valid), .q_ready(cr_q_ready), .q_bytes(cr_q_bytes),
    .s_valid(1'b0), .s_ready(cr_s_ready),
    .active_id_max(active_id_max),
    .r_valid(cr_r_valid), .r_ready(cr_r_ready), .r_bytes(cr_r_bytes)
  );

  logic pack_valid, pack_ready;
  assign pack_valid = w_valid && !q_taking;
  assign w_ready = q_taking ? qh_in_ready : pack_ready;

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
    .s_valid(pack_valid), .s_ready(pack_ready), .s_data(w_data),
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

  // No tied-off bounded_walk: walk lives inside query_result_bind. Duplicate
  // directory/posting BRAM is not allowed on this candidate.

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

  logic        mux_valid;
  logic [31:0] mux_data;
  logic        mux_ready;
  assign mux_valid = uart_tx_valid | st_valid;
  assign mux_data  = uart_tx_valid ? uart_tx_data : st_data;
  assign uart_tx_ready = uart_tx_valid ? mux_ready : 1'b0;
  assign st_ready       = uart_tx_valid ? 1'b0 : mux_ready;

  uart_tx_word u_tx (
    .clk, .rst_n, .w_valid(mux_valid), .w_ready(mux_ready), .w_data(mux_data), .tx(uart_tx)
  );
  assign led = {load_reject, load_ack, cr_r_valid, q_pending};
endmodule
