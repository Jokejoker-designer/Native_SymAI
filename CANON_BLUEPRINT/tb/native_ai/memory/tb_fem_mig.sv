// tb_fem_mig.sv — FEM dest-complete through mig_ui32 + mux (pack idle).
// CANDIDATE. Not FEM_PERSIST_PASS / MIG_PASS. PROXY_METRIC_FALSE_PASS_GUARD.
`timescale 1ns/1ps

module tb_fem_mig;
  logic clk = 0, rst_n = 0;
  always #5 clk = ~clk;

  logic        ing_valid = 0;
  logic [1:0]  ing_domain = 0;
  logic [3:0]  ing_stage = 0, ing_cap = 0, ing_prim = 0, ing_effect = 0;
  logic [2:0]  ing_macro = 0, ing_ctx = 0;
  logic        ing_done, ing_accepted;
  logic        rep_valid = 0;
  logic [7:0]  rep_skill_id = 0, rep_skill_ver = 0;
  logic        rep_done, rep_accepted;
  logic        cmp_start = 0, rec_start = 0;
  logic        cmp_done, rec_done, busy, unresolved, compacted, integrity_fault;
  logic [2:0]  cmp_result, life_state, regression_count;
  logic [3:0]  txn_step, n_raw;
  logic [1:0]  recover_state;
  logic [7:0]  failure_total, failure_recent, success_after_repair, fem_feat;
  logic [15:0] key, ingress_rejected, key_mismatch, exemplar_full;
  logic [15:0] wr_outstanding, pack_out;
  logic        cmd_fifo_empty, t2_err, force_fifo_empty = 0, inject_tear = 0;
  logic        calib_done, fem_busy, pack_busy;

  logic [27:0] p_addr, f_addr, d_addr;
  logic [2:0]  p_cmd, f_cmd, d_cmd;
  logic        p_en, f_en, d_en, p_end, f_end, d_end, p_wren, f_wren, d_wren;
  logic [127:0] p_wdata, f_wdata, d_wdata, p_rdata, f_rdata, d_rdata;
  logic [15:0] p_mask, f_mask, d_mask;
  logic        p_rdv, f_rdv, d_rdv, p_rdy, f_rdy, d_rdy, p_wdf_rdy, f_wdf_rdy, d_wdf_rdy;
  logic        d_rd_end;
  logic        load_ack, load_reject, p_s_ready;
  logic [7:0]  reason_code;
  logic [31:0] active_generation;

  pack_mig_bind u_pack (
    .clk, .rst_n, .calib_done,
    .s_valid(1'b0), .s_ready(p_s_ready), .s_data(32'h0),
    .load_ack, .load_reject, .reason_code, .active_generation, .wr_outstanding(pack_out),
    .force_fifo_empty(1'b0), .ui_busy(pack_busy),
    .app_addr(p_addr), .app_cmd(p_cmd), .app_en(p_en),
    .app_wdf_data(p_wdata), .app_wdf_end(p_end), .app_wdf_mask(p_mask), .app_wdf_wren(p_wren),
    .app_rd_data(p_rdata), .app_rd_data_valid(p_rdv), .app_rdy(p_rdy), .app_wdf_rdy(p_wdf_rdy)
  );

  fem_on_mig #(.FEM_BASE(28'h0200000)) u_fem (
    .clk, .rst_n, .calib_done,
    .ing_valid, .ing_domain, .ing_stage, .ing_cap, .ing_macro, .ing_prim, .ing_effect, .ing_ctx,
    .ing_done, .ing_accepted,
    .rep_valid, .rep_skill_id, .rep_skill_ver, .rep_done, .rep_accepted,
    .cmp_start, .cmp_done, .cmp_result, .txn_step,
    .rec_start, .rec_done, .recover_state, .integrity_fault,
    .busy, .life_state, .failure_total, .failure_recent, .success_after_repair,
    .regression_count, .unresolved, .compacted, .key, .n_raw,
    .ingress_rejected, .key_mismatch, .exemplar_full, .fem_feat,
    .force_fifo_empty, .inject_tear, .wr_outstanding, .cmd_fifo_empty, .t2_err, .ui_busy(fem_busy),
    .app_addr(f_addr), .app_cmd(f_cmd), .app_en(f_en),
    .app_wdf_data(f_wdata), .app_wdf_end(f_end), .app_wdf_mask(f_mask), .app_wdf_wren(f_wren),
    .app_rd_data(f_rdata), .app_rd_data_valid(f_rdv), .app_rdy(f_rdy), .app_wdf_rdy(f_wdf_rdy)
  );

  mig_ui_mux u_mux (
    .clk, .rst_n,
    .a_busy(pack_busy), .a_addr(p_addr), .a_cmd(p_cmd), .a_en(p_en),
    .a_wdf_data(p_wdata), .a_wdf_end(p_end), .a_wdf_mask(p_mask), .a_wdf_wren(p_wren),
    .a_rd_data(p_rdata), .a_rd_valid(p_rdv), .a_rdy(p_rdy), .a_wdf_rdy(p_wdf_rdy),
    .b_busy(fem_busy), .b_addr(f_addr), .b_cmd(f_cmd), .b_en(f_en),
    .b_wdf_data(f_wdata), .b_wdf_end(f_end), .b_wdf_mask(f_mask), .b_wdf_wren(f_wren),
    .b_rd_data(f_rdata), .b_rd_valid(f_rdv), .b_rdy(f_rdy), .b_wdf_rdy(f_wdf_rdy),
    .d_addr, .d_cmd, .d_en, .d_wdf_data(d_wdata), .d_wdf_end(d_end),
    .d_wdf_mask(d_mask), .d_wdf_wren(d_wren),
    .d_rd_data(d_rdata), .d_rd_valid(d_rdv), .d_rdy, .d_wdf_rdy
  );

  mig_ui_bram u_dest (
    .clk, .rst_n, .calib_done, .stall(1'b0),
    .app_addr(d_addr), .app_cmd(d_cmd), .app_en(d_en),
    .app_wdf_data(d_wdata), .app_wdf_end(d_end), .app_wdf_mask(d_mask), .app_wdf_wren(d_wren),
    .app_rd_data(d_rdata), .app_rd_data_end(d_rd_end), .app_rd_data_valid(d_rdv),
    .app_rdy(d_rdy), .app_wdf_rdy(d_wdf_rdy)
  );

  integer nfail, timeout;

  task pulse_reset;
    begin
      @(negedge clk); rst_n = 0; @(negedge clk); @(negedge clk); rst_n = 1; @(negedge clk);
    end
  endtask

  task ingress;
    input [1:0] dom;
    input [2:0] ctx;
    begin
      @(negedge clk);
      ing_domain = dom; ing_stage = 3; ing_cap = 5; ing_macro = 2; ing_prim = 7; ing_effect = 4; ing_ctx = ctx;
      ing_valid = 1; @(negedge clk); ing_valid = 0;
      timeout = 0;
      while (!ing_done && timeout < 40000) begin @(posedge clk); timeout = timeout + 1; end
      if (!ing_done) begin nfail = nfail + 1; $display("FAIL ingress timeout"); end
    end
  endtask

  task repair;
    input [7:0] ver;
    begin
      @(negedge clk); rep_skill_id = 8'h11; rep_skill_ver = ver; rep_valid = 1; @(negedge clk); rep_valid = 0;
      timeout = 0;
      while (!rep_done && timeout < 40000) begin @(posedge clk); timeout = timeout + 1; end
      if (!rep_done) begin nfail = nfail + 1; $display("FAIL repair timeout"); end
    end
  endtask

  task drive_to_resolved;
    begin
      ingress(2'd1, 3'd1);
      if (ing_accepted) begin nfail = nfail + 1; $display("FAIL tool accepted"); end
      ingress(2'd2, 3'd1);
      if (ing_accepted) begin nfail = nfail + 1; $display("FAIL host accepted"); end
      ingress(2'd0, 3'd1);
      if (life_state !== 3'd0) begin nfail = nfail + 1; $display("FAIL RAW"); end
      ingress(2'd0, 3'd1);
      if (life_state !== 3'd1) begin nfail = nfail + 1; $display("FAIL CLUSTERED"); end
      repair(8'h01); repair(8'h01); repair(8'h01);
      if (life_state !== 3'd2) begin nfail = nfail + 1; $display("FAIL RESOLVED"); end
    end
  endtask

  initial begin
    nfail = 0;
    pulse_reset;
    drive_to_resolved;

    @(negedge clk); cmp_start = 1; @(negedge clk); cmp_start = 0;
    timeout = 0;
    while (txn_step !== 4'd0 && timeout < 40000) begin @(posedge clk); timeout = timeout + 1; end
    if (txn_step !== 4'd0) begin
      nfail = nfail + 1;
      $display("FAIL never reached B0 txn_step=%0d", txn_step);
    end
    force_fifo_empty = 1;
    repeat (20) @(posedge clk);
    if (txn_step > 4'd1) begin
      nfail = nfail + 1;
      $display("FAIL PROXY_METRIC_FALSE_PASS_GUARD txn_step=%0d while fifo-empty", txn_step);
    end
    force_fifo_empty = 0;
    timeout = 0;
    while (!cmp_done && timeout < 80000) begin @(posedge clk); timeout = timeout + 1; end
    if (!cmp_done) begin nfail = nfail + 1; $display("FAIL cmp timeout"); end
    if (cmp_result !== 3'd0) begin nfail = nfail + 1; $display("FAIL cmp_result=%0d", cmp_result); end
    if (!compacted) begin nfail = nfail + 1; $display("FAIL not compacted"); end
    if (n_raw !== 4'd0) begin nfail = nfail + 1; $display("FAIL raw not retired n_raw=%0d", n_raw); end

    @(negedge clk); rec_start = 1; @(negedge clk); rec_start = 0;
    timeout = 0;
    while (!rec_done && timeout < 80000) begin @(posedge clk); timeout = timeout + 1; end
    if (!rec_done) begin nfail = nfail + 1; $display("FAIL recover timeout"); end
    if (integrity_fault) begin nfail = nfail + 1; $display("FAIL unexpected COMMITTED_CORRUPT"); end
    if (recover_state !== 2'd2) begin nfail = nfail + 1; $display("FAIL recover_state=%0d", recover_state); end

    if (nfail == 0) $display("FEM_MIG_UI32_XSIM_PASS dest-complete mux (not FEM_PERSIST_PASS)");
    else $display("FEM_MIG_UI32_XSIM_FAIL nfail=%0d", nfail);
    $finish;
  end

  initial begin
    #20_000_000;
    $display("FEM_MIG_UI32_XSIM_FAIL watchdog");
    $finish;
  end
endmodule
