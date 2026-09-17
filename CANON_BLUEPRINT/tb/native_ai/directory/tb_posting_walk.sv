// tb_posting_walk.sv — M2 ID → directory → posting page. CANDIDATE. PROGRAM=NO.
`timescale 1ns/1ps

module tb_posting_walk;
  localparam int N_DIR = 235;
  localparam int N_POST = 2048;
  logic clk = 0;
  logic rst_n = 0;
  always #5 clk = ~clk;

  logic req_valid, req_ready, rsp_valid, rsp_ready, hit, oop, mism, want_rev;
  logic [31:0] semantic_id, active_id_max, first_nb, first_eref;
  logic [15:0] count;

  posting_walk #(.N_DIR(N_DIR), .N_POST(N_POST)) dut (
    .clk, .rst_n, .req_valid, .req_ready, .semantic_id, .want_rev,
    .active_id_max, .rsp_valid, .rsp_ready, .hit, .out_of_profile(oop),
    .hdr_mismatch(mism), .count, .first_neighbor(first_nb), .first_edge_ref(first_eref)
  );

  int n_pass, n_fail, fd, rec, t, n_exp;
  logic [31:0] eid, fn, rn;
  logic [15:0] cf, cr;
  string line;

  task query;
    input [31:0] id;
    input bit rev;
    begin
      semantic_id = id;
      want_rev = rev;
      req_valid = 1;
      t = 0;
      while (!req_ready && t < 4000) begin @(posedge clk); t++; end
      @(posedge clk);
      req_valid = 0;
      t = 0;
      while (!rsp_valid && t < 4000) begin @(posedge clk); t++; end
    end
  endtask

  initial begin
    n_pass = 0;
    n_fail = 0;
    n_exp = 0;
    rsp_ready = 1;
    req_valid = 0;
    want_rev = 0;
    active_id_max = 32'hFFFF_FFFF;
    repeat (4) @(posedge clk);
    rst_n = 1;
    repeat (2) @(posedge clk);

    fd = $fopen("post_expect.hex", "r");
    if (fd == 0) $fatal(1, "cannot open post_expect.hex");
    while (!$feof(fd)) begin
      if ($fscanf(fd, "%h %h %h %h %h\n", eid, cf, fn, cr, rn) == 5) begin
        n_exp++;
        query(eid, 1'b0);
        if (!rsp_valid || oop || mism || !hit || count !== cf || (cf != 0 && first_nb !== fn)) begin
          n_fail++;
          $display("FAIL fwd id=%08x hit=%0d oop=%0d mism=%0d cnt=%0x exp=%0x nb=%08x exp=%08x",
                   eid, hit, oop, mism, count, cf, first_nb, fn);
        end else n_pass++;
        @(posedge clk);
        query(eid, 1'b1);
        if (!rsp_valid || oop || mism || !hit || count !== cr || (cr != 0 && first_nb !== rn)) begin
          n_fail++;
          $display("FAIL rev id=%08x hit=%0d oop=%0d mism=%0d cnt=%0x exp=%0x nb=%08x exp=%08x",
                   eid, hit, oop, mism, count, cr, first_nb, rn);
        end else n_pass++;
        @(posedge clk);
      end
    end
    $fclose(fd);

    // profile gate: existing ID above max is out_of_profile, not a posting hit
    active_id_max = 32'h0;
    query(32'h1, 1'b0);
    if (!rsp_valid || !oop || hit) begin
      n_fail++;
      $display("FAIL oop expected hit=%0d oop=%0d", hit, oop);
    end else n_pass++;
    @(posedge clk);

    if (n_fail == 0)
      $display("M2_POST_XSIM_PASS  rows=%0d (simulation only; not M2_PASS)", n_exp);
    else
      $display("M2_POST_XSIM_FAIL  pass=%0d fail=%0d", n_pass, n_fail);
    $finish;
  end
endmodule
