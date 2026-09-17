// D-owned integrated XSim of FE256_HW_R1 inside shadow-bind candidate top.
// B gold files + handshake copied; B TB file is not modified.
// PROGRAM=NO. XSim != board. Not FE256_PASS.
`timescale 1ns/1ps
`include "fe256_abi_constants.svh"

module tb_fe256_r1_shadow_bind;
  localparam int N = FE256_N_CASES;
  localparam int QW = FE256_QUERY_BYTES;
  localparam int RW = FE256_RESULT_BYTES;

  logic clk = 0;
  logic rst_n = 0;
  logic uart_tx;
  logic [3:0] led;
  always #5 clk = ~clk;

  arty_a7_r2_top_fe256_r1_candidate dut (
    .CLK100MHZ(clk),
    .ck_rst(rst_n),
    .uart_rx(1'b1),
    .uart_tx(uart_tx),
    .led(led)
  );

  logic [7:0] gold_q [0:N-1][0:QW-1];
  logic [7:0] gold_r [0:N-1][0:RW-1];
  int unsigned n_loaded, n_fail, n_pass;

  function automatic int hex_nibble(byte c);
    if (c >= "0" && c <= "9") return c - "0";
    if (c >= "a" && c <= "f") return 10 + (c - "a");
    if (c >= "A" && c <= "F") return 10 + (c - "A");
    return -1;
  endfunction

  function automatic [255:0] pack_q(input logic [7:0] b [0:QW-1]);
    int i;
    begin
      pack_q = 256'h0;
      for (i = 0; i < QW; i++) pack_q[8*i +: 8] = b[i];
    end
  endfunction

  integer fd, code, rec, bi, hi, lo, t, mismatch;
  string line;
  logic [255:0] qpack;

  initial begin
    n_loaded = 0;
    n_fail = 0;
    n_pass = 0;
    fd = $fopen("fe256_queries.hex", "r");
    if (fd == 0) fd = $fopen("out/fe256_queries.hex", "r");
    if (fd == 0) $fatal(1, "cannot open fe256_queries.hex");
    rec = 0;
    while (!$feof(fd) && rec < N) begin
      code = $fgets(line, fd);
      if (code <= 0) continue;
      if (line.len() < 2 * QW) continue;
      for (bi = 0; bi < QW; bi++) begin
        hi = hex_nibble(line.getc(2 * bi));
        lo = hex_nibble(line.getc(2 * bi + 1));
        if (hi < 0 || lo < 0) $fatal(1, "bad query hex rec %0d", rec);
        gold_q[rec][bi] = 8'(hi * 16 + lo);
      end
      rec++;
    end
    $fclose(fd);
    if (rec != N) $fatal(1, "query count %0d != %0d", rec, N);

    fd = $fopen("fe256_gold_results.hex", "r");
    if (fd == 0) fd = $fopen("out/fe256_gold_results.hex", "r");
    if (fd == 0) $fatal(1, "cannot open fe256_gold_results.hex");
    rec = 0;
    while (!$feof(fd) && rec < N) begin
      code = $fgets(line, fd);
      if (code <= 0) continue;
      if (line.len() < 2 * RW) continue;
      for (bi = 0; bi < RW; bi++) begin
        hi = hex_nibble(line.getc(2 * bi));
        lo = hex_nibble(line.getc(2 * bi + 1));
        if (hi < 0 || lo < 0) $fatal(1, "bad result hex rec %0d", rec);
        gold_r[rec][bi] = 8'(hi * 16 + lo);
      end
      rec++;
    end
    $fclose(fd);
    if (rec != N) $fatal(1, "result count %0d != %0d", rec, N);
    n_loaded = rec;

    rst_n = 0;
    force dut.tb_steer = 1'b0;
    force dut.tb_q_valid = 1'b0;
    force dut.tb_r_ready = 1'b1;
    force dut.tb_q_pack = 256'h0;
    repeat (8) @(posedge clk);
    rst_n = 1;
    repeat (2) @(posedge clk);
    force dut.tb_steer = 1'b1;

    for (rec = 0; rec < N; rec++) begin
      qpack = pack_q(gold_q[rec]);
      force dut.tb_q_pack = qpack;
      force dut.tb_q_valid = 1'b1;
      t = 0;
      while (!dut.u_fe256.q_ready && t < 10000) begin
        @(posedge clk);
        t++;
      end
      if (!dut.u_fe256.q_ready) begin
        n_fail = N;
        $display("FE256 shadow-bind XSim FAIL: q_ready stuck 0 at %0d", rec);
        $finish;
      end
      @(posedge clk);
      force dut.tb_q_valid = 1'b0;
      t = 0;
      while (!dut.u_fe256.r_valid && t < 100000) begin
        @(posedge clk);
        t++;
      end
      if (!dut.u_fe256.r_valid) begin
        n_fail++;
        $display("FAIL timeout case %0d", rec);
      end else begin
        mismatch = 0;
        for (bi = 0; bi < RW; bi++) begin
          if (dut.u_fe256.r_bytes[bi] !== gold_r[rec][bi]) mismatch++;
        end
        if (mismatch != 0) begin
          n_fail++;
          $display("FAIL case %0d byte_mismatches=%0d", rec, mismatch);
        end else n_pass++;
      end
      @(posedge clk);
    end

    if (n_fail == 0 && n_pass == N)
      $display("FE256_SHADOW_BIND_XSIM  %0d/%0d bit-exact (simulation only; not FE256_PASS)", n_pass, N);
    else
      $display("FE256_SHADOW_BIND_XSIM_FAIL  pass=%0d fail=%0d", n_pass, n_fail);
    $finish;
  end
endmodule
