// tb_fe256_xsim_compare.sv
// AGENT_B XSim gate for FE256_256_256_PASS.
// Parent/Verification Lead owns the compare contract. Agent D owns DUT RTL.
// PROGRAM=NO. XSim != board.
//
// Hex files: one record per line, lowercase hex, no 0x prefix.
//   fe256_queries.hex       64 hex chars  (32 bytes)
//   fe256_gold_results.hex  96 hex chars  (48 bytes)
//
// DUT must present a 48-byte StructuredResult for each 32-byte QueryRecord
// with matching txn_id. Bit-exact compare against gold.

`timescale 1ns/1ps
`include "fe256_abi_constants.svh"

module tb_fe256_xsim_compare;
  localparam int N = FE256_N_CASES;
  localparam int QW = FE256_QUERY_BYTES;
  localparam int RW = FE256_RESULT_BYTES;

  logic clk = 0;
  logic rst_n = 0;
  always #5 clk = ~clk;

  logic        q_valid;
  logic        q_ready;
  logic [7:0]  q_bytes [0:QW-1];
  logic        r_valid;
  logic        r_ready;
  logic [7:0]  r_bytes [0:RW-1];

  fe256_query_path dut (
    .clk(clk),
    .rst_n(rst_n),
    .q_valid(q_valid),
    .q_ready(q_ready),
    .q_bytes(q_bytes),
    .r_valid(r_valid),
    .r_ready(r_ready),
    .r_bytes(r_bytes)
  );

  logic [7:0] gold_q [0:N-1][0:QW-1];
  logic [7:0] gold_r [0:N-1][0:RW-1];
  int unsigned n_loaded;
  int unsigned n_fail;
  int unsigned n_pass;

  function automatic int hex_nibble(byte c);
    if (c >= "0" && c <= "9") return c - "0";
    if (c >= "a" && c <= "f") return 10 + (c - "a");
    if (c >= "A" && c <= "F") return 10 + (c - "A");
    return -1;
  endfunction

  integer fd, code, rec, bi, hi, lo;
  string line;

  initial begin
    n_loaded = 0;
    n_fail = 0;
    n_pass = 0;
    fd = $fopen("fe256_queries.hex", "r");
    if (fd == 0) fd = $fopen("out/fe256_queries.hex", "r");
    if (fd == 0) begin
      $fatal(1, "cannot open fe256_queries.hex (run fe256_gold.py --emit out)");
    end
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
    q_valid = 0;
    r_ready = 1;
    repeat (8) @(posedge clk);
    rst_n = 1;
    repeat (2) @(posedge clk);

    // Handshake campaign. Open DUT (q_ready=0) fails closed — not a PASS.
    for (rec = 0; rec < N; rec++) begin
      for (bi = 0; bi < QW; bi++) q_bytes[bi] = gold_q[rec][bi];
      q_valid = 1;
      begin : wait_ready
        int t;
        t = 0;
        while (!q_ready && t < 10000) begin
          @(posedge clk);
          t++;
        end
        if (!q_ready) begin
          n_fail = N;
          $display("FE256 XSim FAIL: DUT did not accept query %0d (q_ready stuck 0). Bind Agent D sink.", rec);
          $display("GOLD_LOADED=%0d  this is not FE256_256_256_PASS", n_loaded);
          $finish;
        end
      end
      @(posedge clk);
      q_valid = 0;
      begin : wait_result
        int t;
        t = 0;
        while (!r_valid && t < 100000) begin
          @(posedge clk);
          t++;
        end
        if (!r_valid) begin
          n_fail++;
          $display("FAIL timeout case %0d", rec);
        end else begin
          int mismatch;
          mismatch = 0;
          for (bi = 0; bi < RW; bi++) begin
            if (r_bytes[bi] !== gold_r[rec][bi]) mismatch++;
          end
          if (mismatch != 0) begin
            n_fail++;
            $display("FAIL case %0d byte_mismatches=%0d", rec, mismatch);
          end else n_pass++;
        end
      end
    end

    if (n_fail == 0 && n_pass == N)
      $display("FE256_XSIM_PASS  %0d/%0d bit-exact (simulation only)", n_pass, N);
    else
      $display("FE256_XSIM_FAIL  pass=%0d fail=%0d (simulation only)", n_pass, n_fail);
    $finish;
  end
endmodule
