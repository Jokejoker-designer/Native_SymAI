// tb_bounded_walk.sv — M3 hop-budget walk. CANDIDATE. Not M3_PASS.
`timescale 1ns/1ps

module tb_bounded_walk;
  logic clk = 0, rst_n = 0;
  always #5 clk = ~clk;

  logic req_valid, req_ready, rsp_valid, rsp_ready, hit, oop, inc, want_rev;
  logic [31:0] start_id, active_id_max, end_id;
  logic [3:0] hop_budget, hops;
  logic [15:0] last_count;

  bounded_walk dut (
    .clk, .rst_n, .req_valid, .req_ready, .start_id, .hop_budget, .want_rev,
    .active_id_max, .rsp_valid, .rsp_ready, .hit, .out_of_profile(oop),
    .incomplete(inc), .hops_taken(hops), .end_id, .last_count
  );

  int n_pass, n_fail, fd, t;
  logic [31:0] eid, fn, rn;
  logic [15:0] cf, cr;

  task query;
    input [31:0] id;
    input [3:0] hops_i;
    begin
      start_id = id;
      hop_budget = hops_i;
      want_rev = 1'b0;
      req_valid = 1;
      t = 0;
      while (!req_ready && t < 8000) begin @(posedge clk); t++; end
      @(posedge clk);
      req_valid = 0;
      t = 0;
      while (!rsp_valid && t < 8000) begin @(posedge clk); t++; end
    end
  endtask

  initial begin
    n_pass = 0; n_fail = 0;
    rsp_ready = 1; req_valid = 0; want_rev = 0;
    active_id_max = 32'hFFFF_FFFF;
    repeat (4) @(posedge clk);
    rst_n = 1;
    repeat (2) @(posedge clk);

    query(32'h00010100, 4'd0);
    if (!rsp_valid || end_id !== 32'h00010100 || hops !== 0 || inc) begin
      n_fail++; $display("FAIL hop0");
    end else n_pass++;
    @(posedge clk);

    fd = $fopen("post_expect.hex", "r");
    if (fd == 0) $fatal(1, "cannot open post_expect.hex");
    while ($fscanf(fd, "%h %h %h %h %h\n", eid, cf, fn, cr, rn) == 5) begin
      if (cf == 0) continue;
      query(eid, 4'd1);
      if (!rsp_valid || oop || !hit || hops !== 4'd1 || end_id !== fn) begin
        n_fail++;
        $display("FAIL hop1 id=%08x end=%08x exp=%08x hops=%0d hit=%0d", eid, end_id, fn, hops, hit);
      end else n_pass++;
      @(posedge clk);
    end
    $fclose(fd);

    active_id_max = 32'h0;
    query(32'h00010100, 4'd1);
    if (!rsp_valid || !oop || hit) begin
      n_fail++; $display("FAIL oop");
    end else n_pass++;

    if (n_fail == 0)
      $display("M3_WALK_XSIM_PASS hop1 (simulation only; not M3_PASS)");
    else
      $display("M3_WALK_XSIM_FAIL pass=%0d fail=%0d", n_pass, n_fail);
    $finish;
  end
endmodule
