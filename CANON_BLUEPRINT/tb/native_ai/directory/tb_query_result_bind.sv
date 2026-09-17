// tb_query_result_bind.sv — QueryRecord → StructuredResult. CANDIDATE. PROGRAM=NO.
// Fail-closed: never ANSWER/UNKNOWN from hop-1 walk. Not FE256 gold.
`timescale 1ns/1ps

module tb_query_result_bind;
  logic clk = 0, rst_n = 0;
  always #5 clk = ~clk;

  logic q_valid, q_ready, r_valid, r_ready, s_ready;
  logic [7:0] q_bytes [0:31];
  logic [7:0] r_bytes [0:47];
  logic [31:0] active_id_max;
  int n_pass, n_fail, n_hop1, fd;

  query_result_bind dut (
    .clk, .rst_n, .q_valid, .q_ready, .q_bytes,
    .s_valid(1'b0), .s_ready, .active_id_max,
    .r_valid, .r_ready, .r_bytes
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

  function automatic [15:0] crc16_n46(input logic [7:0] b [0:45]);
    logic [15:0] c;
    integer ii;
    begin
      c = 16'hFFFF;
      for (ii = 0; ii < 46; ii++) c = crc16_step(c, b[ii]);
      crc16_n46 = c;
    end
  endfunction

  task automatic pack_q;
    input [31:0] sid;
    input [3:0] hops_i;
    input [15:0] txn;
    integer k;
    logic [15:0] crc;
    logic [15:0] meta;
    begin
      meta = {4'h0, 1'b0, 1'b0, 1'b0, hops_i, 5'h0};
      for (k = 0; k < 32; k++) q_bytes[k] = 8'h00;
      q_bytes[0] = 8'h51;
      q_bytes[1] = 8'h4E;
      q_bytes[2] = 8'h01;
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

  function automatic bit illegal_status(input [7:0] st);
    illegal_status = (st == 8'h00) || (st == 8'h01) || (st == 8'h02) ||
                     (st == 8'h22) || (st == 8'h23) || (st == 8'h55) ||
                     (st == 8'h56) || (st == 8'h80);
  endfunction

  task automatic check_crc_echo;
    input [7:0] exp_st;
    input [7:0] exp_rc;
    input [7:0] exp_cmpl;
    input [15:0] txn;
    logic [7:0] hdr [0:45];
    logic [15:0] crc;
    integer i;
    begin
      for (i = 0; i < 46; i++) hdr[i] = r_bytes[i];
      crc = crc16_n46(hdr);
      if ({r_bytes[1], r_bytes[0]} != 16'h4E52) begin
        n_fail++; $display("FAIL magic");
      end else if (r_bytes[2] != 8'h01) begin
        n_fail++; $display("FAIL abi");
      end else if (r_bytes[3] !== exp_st || r_bytes[4] !== exp_rc || r_bytes[6] !== exp_cmpl) begin
        n_fail++; $display("FAIL st=%02x rc=%02x cmpl=%02x", r_bytes[3], r_bytes[4], r_bytes[6]);
      end else if (r_bytes[5] != 8'h00) begin
        n_fail++; $display("FAIL answer_kind");
      end else if ({r_bytes[9], r_bytes[8]} !== txn) begin
        n_fail++; $display("FAIL txn echo");
      end else if ({r_bytes[47], r_bytes[46]} !== crc) begin
        n_fail++; $display("FAIL result crc");
      end else if (illegal_status(r_bytes[3])) begin
        n_fail++; $display("FAIL illegal status %02x", r_bytes[3]);
      end else n_pass++;
    end
  endtask

  logic [31:0] eid, fn, rn;
  logic [15:0] cfwd, crev;

  initial begin
    n_pass = 0; n_fail = 0; n_hop1 = 0;
    r_ready = 1; q_valid = 0;
    active_id_max = 32'hFFFF_FFFF;
    repeat (4) @(posedge clk);
    rst_n = 1;
    repeat (2) @(posedge clk);

    pack_q(32'h00010100, 4'd0, 16'h0001);
    issue();
    check_crc_echo(8'h04, 8'h20, 8'h02, 16'h0001);
    @(posedge clk);

    fd = $fopen("post_expect.hex", "r");
    if (fd == 0) $fatal(1, "cannot open post_expect.hex");
    while (!$feof(fd)) begin
      if ($fscanf(fd, "%h %h %h %h %h\n", eid, cfwd, fn, crev, rn) == 5) begin
        if (cfwd == 0) continue;
        n_hop1++;
        pack_q(eid, 4'd1, n_hop1[15:0]);
        issue();
        check_crc_echo(8'h04, 8'h20, 8'h02, n_hop1[15:0]);
        @(posedge clk);
      end
    end
    $fclose(fd);

    pack_q(32'h00010100, 4'd1, 16'h00FF);
    q_bytes[30] = ~q_bytes[30];
    issue();
    check_crc_echo(8'h06, 8'h55, 8'h00, 16'h00FF);
    @(posedge clk);

    if (n_fail == 0)
      $display("M4_QUERY_RESULT_XSIM_PASS  hop1=%0d (simulation only; not ASTRA_PASS)", n_hop1);
    else
      $display("M4_QUERY_RESULT_XSIM_FAIL  pass=%0d fail=%0d", n_pass, n_fail);
    $finish;
  end
endmodule
