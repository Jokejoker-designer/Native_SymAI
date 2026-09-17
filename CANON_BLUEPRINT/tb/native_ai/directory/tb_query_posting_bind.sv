// tb_query_posting_bind.sv — QueryRecord → posting_walk. CANDIDATE. PROGRAM=NO.
// Does not use FE256 gold, FE256 engine, or B 256-case set.
`timescale 1ns/1ps

module tb_query_posting_bind;
  logic clk = 0;
  logic rst_n = 0;
  always #5 clk = ~clk;

  logic q_valid, q_ready, r_valid, r_ready, hit, oop, mism, cf, mf;
  logic [7:0] q_bytes [0:31];
  logic [31:0] active_id_max, first_nb, first_eref;
  logic [15:0] count;

  query_posting_bind dut (
    .clk, .rst_n, .q_valid, .q_ready, .q_bytes, .active_id_max,
    .r_valid, .r_ready, .hit, .out_of_profile(oop), .hdr_mismatch(mism),
    .crc_fail(cf), .magic_fail(mf), .count, .first_neighbor(first_nb),
    .first_edge_ref(first_eref)
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
    input bit rev;
    input [15:0] txn;
    integer k;
    logic [15:0] crc;
    logic [15:0] meta;
    begin
      meta = rev ? 16'h0400 : 16'h0000; // query_meta[10]
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
      while (!q_ready && t < 4000) begin @(posedge clk); t++; end
      @(posedge clk);
      q_valid = 0;
      t = 0;
      while (!r_valid && t < 4000) begin @(posedge clk); t++; end
    end
  endtask

  int n_pass, n_fail, n_exp, fd, t;
  logic [31:0] eid, fn, rn;
  logic [15:0] cfwd, crev;

  initial begin
    n_pass = 0;
    n_fail = 0;
    n_exp = 0;
    r_ready = 1;
    q_valid = 0;
    active_id_max = 32'hFFFF_FFFF;
    repeat (4) @(posedge clk);
    rst_n = 1;
    repeat (2) @(posedge clk);

    fd = $fopen("post_expect.hex", "r");
    if (fd == 0) $fatal(1, "cannot open post_expect.hex");
    while (!$feof(fd)) begin
      if ($fscanf(fd, "%h %h %h %h %h\n", eid, cfwd, fn, crev, rn) == 5) begin
        n_exp++;
        pack_q(eid, 1'b0, n_exp[15:0]);
        issue();
        if (!r_valid || cf || mf || oop || mism || !hit || count !== cfwd ||
            (cfwd != 0 && first_nb !== fn)) begin
          n_fail++;
          $display("FAIL fwd id=%08x hit=%0d oop=%0d mism=%0d cf=%0d mf=%0d cnt=%0x exp=%0x nb=%08x exp=%08x",
                   eid, hit, oop, mism, cf, mf, count, cfwd, first_nb, fn);
        end else n_pass++;
        @(posedge clk);
        pack_q(eid, 1'b1, n_exp[15:0] + 16'h8000);
        issue();
        if (!r_valid || cf || mf || oop || mism || !hit || count !== crev ||
            (crev != 0 && first_nb !== rn)) begin
          n_fail++;
          $display("FAIL rev id=%08x hit=%0d oop=%0d mism=%0d cf=%0d mf=%0d cnt=%0x exp=%0x nb=%08x exp=%08x",
                   eid, hit, oop, mism, cf, mf, count, crev, first_nb, rn);
        end else n_pass++;
        @(posedge clk);
      end
    end
    $fclose(fd);

    pack_q(32'h1, 1'b0, 16'h00FE);
    q_bytes[0] = 8'h00;
    q_bytes[30] = 8'h00;
    q_bytes[31] = 8'h00;
    issue();
    if (!r_valid || !mf || hit) begin
      n_fail++;
      $display("FAIL magic expected mf=%0d hit=%0d", mf, hit);
    end else n_pass++;
    @(posedge clk);

    pack_q(32'h1, 1'b0, 16'h00FF);
    q_bytes[30] = ~q_bytes[30];
    issue();
    if (!r_valid || !cf || hit) begin
      n_fail++;
      $display("FAIL crc expected cf=%0d hit=%0d", cf, hit);
    end else n_pass++;
    @(posedge clk);

    active_id_max = 32'h0;
    pack_q(32'h1, 1'b0, 16'h0100);
    issue();
    if (!r_valid || cf || mf || !oop || hit) begin
      n_fail++;
      $display("FAIL oop expected hit=%0d oop=%0d", hit, oop);
    end else n_pass++;
    @(posedge clk);

    if (n_fail == 0)
      $display("M2_QUERY_POST_XSIM_PASS  rows=%0d (simulation only; not M2_PASS)", n_exp);
    else
      $display("M2_QUERY_POST_XSIM_FAIL  pass=%0d fail=%0d", n_pass, n_fail);
    $finish;
  end
endmodule
