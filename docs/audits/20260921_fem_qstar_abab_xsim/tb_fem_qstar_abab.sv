// tb_fem_qstar_abab.sv — XSim A/B/A/B. MIG UI stand-in. Not a bitstream.
// PASS_XSIM only. FEM_PERSIST_PASS=NO BOARD_PASS=NO PROGRAM=NO.
// Same-clock. CDC of fem_feat into clk100 is NOT_TESTED here.
`timescale 1ns/1ps

module tb_fem_qstar_abab;
  logic clk = 0;
  logic rst_n = 0;
  logic fem_rst_n = 0;
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
  logic        cmp_done, rec_done, fem_busy, unresolved, compacted, integrity_fault, t2_err;
  logic [2:0]  cmp_result, life_state;
  logic [3:0]  txn_step, n_raw;
  logic [1:0]  recover_state;
  logic [7:0]  failure_total, failure_recent, success_after_repair, feat0_obs;
  logic [15:0] key;
  logic        fem_infl_en = 0;
  logic        theta_we = 0;
  logic [5:0]  theta_addr = 0;
  logic [15:0] theta_wdata = 0, theta_rdata;
  logic        prop_start = 0, prop_done, prop_valid, explored;
  logic [2:0]  greedy_action, proposed_action;
  logic [31:0] q_sel;

  logic [27:0] f_addr;
  logic [2:0]  f_cmd;
  logic        f_en, f_end, f_wren;
  logic [127:0] f_wdata, f_rdata;
  logic [15:0] f_mask;
  logic        f_rdv, f_rdy, f_wdf_rdy, f_rd_end;
  logic        calib_done;

  localparam logic [2:0] L_COMPACTED = 3'd3;
  localparam logic [2:0] L_NONE = 3'd7;

  fem_qstar_infl u_dut (
    .clk, .rst_n, .fem_rst_n, .calib_done,
    .ing_valid, .ing_domain, .ing_stage, .ing_cap, .ing_macro, .ing_prim, .ing_effect, .ing_ctx,
    .ing_done, .ing_accepted,
    .rep_valid, .rep_skill_id, .rep_skill_ver, .rep_done, .rep_accepted,
    .cmp_start, .cmp_done, .cmp_result, .txn_step,
    .rec_start, .rec_done, .recover_state, .integrity_fault,
    .fem_busy, .life_state, .failure_total, .failure_recent, .success_after_repair,
    .unresolved, .compacted, .key, .n_raw, .t2_err,
    .fem_infl_en, .theta_we, .theta_addr, .theta_wdata, .theta_rdata,
    .prop_start, .prop_done, .prop_valid, .greedy_action, .proposed_action, .explored, .q_sel, .feat0_obs,
    .app_addr(f_addr), .app_cmd(f_cmd), .app_en(f_en),
    .app_wdf_data(f_wdata), .app_wdf_end(f_end), .app_wdf_mask(f_mask), .app_wdf_wren(f_wren),
    .app_rd_data(f_rdata), .app_rd_data_valid(f_rdv), .app_rdy(f_rdy), .app_wdf_rdy(f_wdf_rdy)
  );

  mig_ui_bram u_dest (
    .clk, .rst_n, .calib_done, .stall(1'b0),
    .app_addr(f_addr), .app_cmd(f_cmd), .app_en(f_en),
    .app_wdf_data(f_wdata), .app_wdf_end(f_end), .app_wdf_mask(f_mask), .app_wdf_wren(f_wren),
    .app_rd_data(f_rdata), .app_rd_data_end(f_rd_end), .app_rd_data_valid(f_rdv),
    .app_rdy(f_rdy), .app_wdf_rdy(f_wdf_rdy)
  );

  integer nfail, timeout;
  logic [2:0] got_g;

  task automatic sys_reset;
    begin
      rst_n = 0;
      fem_rst_n = 0;
      @(negedge clk);
      @(negedge clk);
      rst_n = 1;
      fem_rst_n = 1;
      @(negedge clk);
    end
  endtask

  task automatic fem_only_reset;
    integer k;
    begin
      @(negedge clk);
      fem_rst_n = 0;
      for (k = 0; k < 8; k = k + 1) @(negedge clk);
      fem_rst_n = 1;
      @(negedge clk);
    end
  endtask

  task automatic load_theta;
    begin
      @(negedge clk);
      theta_addr = 6'd8;
      theta_wdata = 16'h0001;
      theta_we = 1;
      @(negedge clk);
      theta_we = 0;
      @(posedge clk);
      if (theta_rdata !== 16'h0001) begin
        nfail = nfail + 1;
        $display("FAIL theta[8]=%04h", theta_rdata);
      end
    end
  endtask

  task automatic propose;
    input [8*8-1:0] name;
    input infl;
    input [2:0] want;
    begin
      fem_infl_en = infl;
      @(negedge clk);
      while (fem_busy) @(negedge clk);
      prop_start = 1;
      @(negedge clk);
      prop_start = 0;
      timeout = 0;
      while (!prop_done && timeout < 400) begin
        @(posedge clk);
        timeout = timeout + 1;
      end
      got_g = greedy_action;
      $display("ARM %0s infl=%0d feat0=%0d ft=%0d life=%0d greedy=%0d proposed=%0d explored=%0d q_sel=%0d valid=%0d",
               name, infl, feat0_obs, failure_total, life_state, greedy_action, proposed_action,
               explored, q_sel, prop_valid);
      if (!prop_done) begin
        nfail = nfail + 1;
        $display("FAIL %0s prop timeout", name);
      end
      if (!prop_valid || explored || proposed_action !== greedy_action) begin
        nfail = nfail + 1;
        $display("FAIL %0s not exam-greedy", name);
      end
      if (got_g !== want) begin
        nfail = nfail + 1;
        $display("FAIL %0s greedy=%0d want=%0d", name, got_g, want);
      end
    end
  endtask

  task automatic ingress;
    input [1:0] dom;
    input [2:0] ctx;
    begin
      @(negedge clk);
      ing_domain = dom;
      ing_stage = 3;
      ing_cap = 5;
      ing_macro = 2;
      ing_prim = 7;
      ing_effect = 4;
      ing_ctx = ctx;
      ing_valid = 1;
      @(negedge clk);
      ing_valid = 0;
      timeout = 0;
      while (!ing_done && timeout < 40000) begin
        @(posedge clk);
        timeout = timeout + 1;
      end
      if (!ing_done) begin
        nfail = nfail + 1;
        $display("FAIL ingress timeout");
      end
    end
  endtask

  task automatic repair;
    begin
      @(negedge clk);
      rep_skill_id = 8'h11;
      rep_skill_ver = 8'h01;
      rep_valid = 1;
      @(negedge clk);
      rep_valid = 0;
      timeout = 0;
      while (!rep_done && timeout < 40000) begin
        @(posedge clk);
        timeout = timeout + 1;
      end
      if (!rep_done) begin
        nfail = nfail + 1;
        $display("FAIL repair timeout");
      end
    end
  endtask

  initial begin
    nfail = 0;
    sys_reset;
    fem_only_reset;
    if (life_state !== L_NONE || failure_total !== 8'd0) begin
      nfail = nfail + 1;
      $display("FAIL virgin life=%0d ft=%0d", life_state, failure_total);
    end
    load_theta;
    propose("A", 1'b1, 3'd0);

    ingress(2'd1, 3'd1);
    if (ing_accepted) begin nfail = nfail + 1; $display("FAIL tool accepted"); end
    ingress(2'd2, 3'd1);
    if (ing_accepted) begin nfail = nfail + 1; $display("FAIL host accepted"); end
    ingress(2'd0, 3'd1);
    ingress(2'd0, 3'd1);
    repair();
    repair();
    repair();
    if (life_state !== 3'd2) begin
      nfail = nfail + 1;
      $display("FAIL not RESOLVED life=%0d", life_state);
    end

    @(negedge clk);
    cmp_start = 1;
    @(negedge clk);
    cmp_start = 0;
    timeout = 0;
    while (!cmp_done && timeout < 80000) begin
      @(posedge clk);
      timeout = timeout + 1;
    end
    if (!cmp_done || !compacted || failure_total !== 8'd2) begin
      nfail = nfail + 1;
      $display("FAIL compact life=%0d ft=%0d cmp=%0d", life_state, failure_total, cmp_result);
    end

    fem_only_reset;
    theta_addr = 6'd8;
    @(posedge clk);
    if (theta_rdata !== 16'h0001) begin
      nfail = nfail + 1;
      $display("FAIL theta wiped by FRST %04h", theta_rdata);
    end
    if (life_state !== L_NONE || failure_total !== 8'd0) begin
      nfail = nfail + 1;
      $display("FAIL FRST life=%0d ft=%0d", life_state, failure_total);
    end

    @(negedge clk);
    rec_start = 1;
    @(negedge clk);
    rec_start = 0;
    timeout = 0;
    while (!rec_done && timeout < 80000) begin
      @(posedge clk);
      timeout = timeout + 1;
    end
    if (!rec_done || recover_state !== 2'd2 || life_state !== L_COMPACTED || failure_total !== 8'd2 || integrity_fault) begin
      nfail = nfail + 1;
      $display("FAIL FREC rec=%0d life=%0d ft=%0d ift=%0d", recover_state, life_state, failure_total, integrity_fault);
    end

    propose("B", 1'b1, 3'd1);
    if (q_sel !== 32'd2) begin
      nfail = nfail + 1;
      $display("FAIL B q_sel=%0d", q_sel);
    end
    propose("A2", 1'b0, 3'd0);
    if (life_state !== L_COMPACTED || failure_total !== 8'd2) begin
      nfail = nfail + 1;
      $display("FAIL A2 media changed life=%0d ft=%0d", life_state, failure_total);
    end
    propose("B2", 1'b1, 3'd1);

    if (nfail == 0)
      $display("FEM_QSTAR_ABAB_XSIM_RESULT greedy=0,1,0,1 PASS_XSIM FEM_PERSIST_PASS=NO BOARD_PASS=NO PROGRAM=NO");
    else
      $display("FEM_QSTAR_ABAB_XSIM_RESULT FAIL nfail=%0d", nfail);
    $finish;
  end
endmodule
