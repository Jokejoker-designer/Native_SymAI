// tb_common_runtime_fe256_xsim_compare.sv
// D-04: same B-owned 256 QueryRecord/StructuredResult hex as tb_fe256_xsim_compare.
// DUT is astra_edge_qeval (common-runtime ASTRA + pack store).
// Not fe256_query_path. Do not modify B TB, B gold, QueryRecord, StructuredResult.
// PROGRAM=NO. XSim != board. Not FE256_PASS / ASTRA_PASS / BOARD_PASS.
`timescale 1ns/1ps
`include "fe256_abi_constants.svh"

module tb_common_runtime_fe256_xsim_compare;
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

  astra_edge_qeval dut (
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
  int unsigned first_fail;
  logic [7:0] first_dut_st, first_gold_st, first_dut_rc, first_gold_rc;

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
    first_fail = N;
    first_dut_st = 8'hFF;
    first_gold_st = 8'hFF;
    first_dut_rc = 8'hFF;
    first_gold_rc = 8'hFF;
    fd = $fopen("fe256_queries.hex", "r");
    if (fd == 0) fd = $fopen("out/fe256_queries.hex", "r");
    if (fd == 0)
      $fatal(1, "cannot open fe256_queries.hex (copy B gold; do not regenerate)");
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
          $display("COMMON_RUNTIME_FE256_XSIM_FAIL  DUT did not accept query %0d (q_ready stuck 0)", rec);
          $display("GOLD_LOADED=%0d  not FE256_PASS", n_loaded);
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
          if (first_fail == N) first_fail = rec;
          $display("FAIL timeout case %0d", rec);
        end else begin
          int mismatch;
          mismatch = 0;
          for (bi = 0; bi < RW; bi++) begin
            if (r_bytes[bi] !== gold_r[rec][bi]) mismatch++;
          end
          if (mismatch != 0) begin
            n_fail++;
            if (first_fail == N) begin
              first_fail = rec;
              first_dut_st = r_bytes[3];
              first_gold_st = gold_r[rec][3];
              first_dut_rc = r_bytes[4];
              first_gold_rc = gold_r[rec][4];
            end
            if (n_fail <= 4)
              $display("FAIL case %0d mismatches=%0d dut_st=%02h dut_rc=%02h gold_st=%02h gold_rc=%02h",
                       rec, mismatch, r_bytes[3], r_bytes[4], gold_r[rec][3], gold_r[rec][4]);
          end else n_pass++;
        end
      end
      @(posedge clk);
    end

    $display("COMMON_RUNTIME_FE256_LOADED=%0d pass=%0d fail=%0d first_fail=%0d",
             n_loaded, n_pass, n_fail, first_fail);
    $display("FIRST_DUT_ST=%02h FIRST_DUT_RC=%02h FIRST_GOLD_ST=%02h FIRST_GOLD_RC=%02h",
             first_dut_st, first_dut_rc, first_gold_st, first_gold_rc);
    if (n_fail == 0 && n_pass == N)
      $display("COMMON_RUNTIME_FE256_XSIM  %0d/%0d bit-exact (simulation only; not FE256_PASS)", n_pass, N);
    else begin
      $display("COMMON_RUNTIME_FE256_XSIM_FAIL  pass=%0d fail=%0d (simulation only; not FE256_PASS)", n_pass, n_fail);
      if (first_dut_st == FE256_ST_SEARCH_INCOMPLETE &&
          (first_gold_st == FE256_ST_ANSWER || first_gold_st == FE256_ST_UNKNOWN))
        $display("CLASSIFICATION=ASTRA_STATUS");
      else if (first_dut_st == FE256_ST_DATA_INTEGRITY_FAIL)
        $display("CLASSIFICATION=IDENTITY_OR_INTEGRITY");
      else
        $display("CLASSIFICATION=UNKNOWN");
    end
    $finish;
  end
endmodule
