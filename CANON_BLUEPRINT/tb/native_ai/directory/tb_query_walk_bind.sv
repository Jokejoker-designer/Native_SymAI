// tb_query_walk_bind.sv — QueryRecord → bounded_walk. CANDIDATE. PROGRAM=NO.
// Does not use FE256 gold or the dedicated FE256 engine.
`timescale 1ns/1ps

module tb_query_walk_bind;
  logic clk = 0;
  logic rst_n = 0;
  always #5 clk = ~clk;

  logic q_valid, q_ready, r_valid, r_ready, hit, oop, inc, cf, mf;
  logic [7:0] q_bytes [0:31];
  logic [31:0] active_id_max, end_id;
  logic [3:0] hops;
  logic [15:0] last_count;

  query_walk_bind dut (
    .clk, .rst_n, .q_valid, .q_ready, .q_bytes, .active_id_max,
    .r_valid, .r_ready, .hit, .out_of_profile(oop), .incomplete(inc),
    .crc_fail(cf), .magic_fail(mf), .hops_taken(hops), .end_id, .last_count
  );

  function automatic [15:0] crc16_step(input [15:0] c, input [7:0] b);
    logic [15:0] x;
    integer kk;
    begin
      x = c ^ {b, 8'h00};
      for (kk = 0; kk < 8; kk++)
        x = x[15] ? {x[14:0], 1'b0} ^ 16'h1021 : {x[14:0], 1'b0};
      crc16_step = x;
    end
  endfunction

  function automatic [15:0] crc16_q(input logic [7:0] b [0:31]);
    logic [15:0] c;
    integer ii;
    begin
      c = 16'hFFFF;
      for (ii = 0; ii < 30; ii++) c = crc16_step(c, b[ii]);
      crc16_q = c;
    end
  endfunction

  task automatic pack_q;
    input [31:0] sid;
    input [3:0] hops_i;
    input bit rev;
    input [15:0] txn;
    integer k;
    logic [15:0] crc;
    logic [15:0] meta;
    begin
      meta = {4'h0, 1'b0, rev, 1'b0, hops_i, 5'h0}; // [11:10] dir, [8:5] hops
      for (k = 0; k < 32; k++) q_bytes[k] = 8'h00;
      q_bytes[0] = 8'h51;
      q_bytes[1] = 8'h4E;
      q_bytes[2] = 8'h01;
      q_bytes[3] = 8'h00;
      q_bytes[4] = txn[7:0];
      q_bytes[5] = txn[15:8];
      q_bytes[12] = meta[7:0];
      q_bytes[13] = meta[15:8];
      q_bytes[14] = sid[7:0];
      q_bytes[15] = sid[15:8];
      q_bytes[16] = sid[23:16];
      q_bytes[17] = sid[31:24];
      crc = crc16_q(q_bytes);
      q_bytes[30] = crc[7:0];
      q_bytes[31] = crc[15:8];
    end
  endtask

  task automatic issue;
    integer t;
    begin
      q_valid = 1;
      t = 0;
      while (!q_ready && t < 8000) begin @(posedge clk); t++; end
      @(posedge clk);
      q_valid = 0;
      t = 0;
      while (!r_valid && t < 8000) begin @(posedge clk); t++; end
    end
  endtask

  int n_pass, n_fail, n_hop1, fd;
  logic [31:0] eid, fn, rn;
  logic [15:0] cfwd, crev;

  initial begin
    n_pass = 0;
    n_fail = 0;
    n_hop1 = 0;
    r_ready = 1;
    q_valid = 0;
    active_id_max = 32'hFFFF_FFFF;
    repeat (4) @(posedge clk);
    rst_n = 1;
    repeat (2) @(posedge clk);

    pack_q(32'h00010100, 4'd0, 1'b0, 16'h0001);
    issue();
    if (!r_valid || cf || mf || inc || hops !== 4'd0 || end_id !== 32'h00010100) begin
      n_fail++;
      $display("FAIL hop0 end=%08x hops=%0d inc=%0d", end_id, hops, inc);
    end else n_pass++;
    @(posedge clk);

    fd = $fopen("post_expect.hex", "r");
    if (fd == 0) $fatal(1, "cannot open post_expect.hex");
    while (!$feof(fd)) begin
      if ($fscanf(fd, "%h %h %h %h %h\n", eid, cfwd, fn, crev, rn) == 5) begin
        if (cfwd == 0) continue;
        n_hop1++;
        pack_q(eid, 4'd1, 1'b0, n_hop1[15:0]);
        issue();
        if (!r_valid || cf || mf || oop || !hit || hops !== 4'd1 || end_id !== fn) begin
          n_fail++;
          $display("FAIL hop1 id=%08x end=%08x exp=%08x hops=%0d hit=%0d",
                   eid, end_id, fn, hops, hit);
        end else n_pass++;
        @(posedge clk);
      end
    end
    $fclose(fd);

    pack_q(32'h00010100, 4'd1, 1'b0, 16'h00FE);
    q_bytes[0] = 8'h00;
    q_bytes[30] = 8'h00;
    q_bytes[31] = 8'h00;
    issue();
    if (!r_valid || !mf || hit) begin
      n_fail++;
      $display("FAIL magic mf=%0d hit=%0d", mf, hit);
    end else n_pass++;
    @(posedge clk);

    pack_q(32'h00010100, 4'd1, 1'b0, 16'h00FF);
    q_bytes[30] = ~q_bytes[30];
    issue();
    if (!r_valid || !cf || hit) begin
      n_fail++;
      $display("FAIL crc cf=%0d hit=%0d", cf, hit);
    end else n_pass++;
    @(posedge clk);

    active_id_max = 32'h0;
    pack_q(32'h00010100, 4'd1, 1'b0, 16'h0100);
    issue();
    if (!r_valid || cf || mf || !oop || hit) begin
      n_fail++;
      $display("FAIL oop hit=%0d oop=%0d", hit, oop);
    end else n_pass++;
    @(posedge clk);

    if (n_fail == 0)
      $display("M3_QUERY_WALK_XSIM_PASS  hop1=%0d (simulation only; not M3_PASS)", n_hop1);
    else
      $display("M3_QUERY_WALK_XSIM_FAIL  pass=%0d fail=%0d", n_pass, n_fail);
    $finish;
  end
endmodule
