// tb_pack_abi24_xsim_compare.sv
// AGENT_B XSim comparator for Pack/ABI-24. Not DUT RTL. PROGRAM=NO.
// XSim != board. 24/24 here is PACK_ABI24_XSIM_PASS only, never PACK_ABI_24_24_PASS.
//
// Agent D binds pack_loader to s_*/load_*. Open DUT keeps s_ready=0 (fail-closed).
// Streams: out/<CASE_ID>.mem   Expect: pack_abi24_expect.svh
// Host: python pack_abi24_gold.py --compare DUT.jsonl

`timescale 1ns/1ps
`include "pack_abi24_constants.svh"

module tb_pack_abi24_xsim_compare;
`include "pack_abi24_expect.svh"
`include "pack_abi24_fopen.svh"

  logic clk;
  logic rst_n;
  logic        s_valid;
  logic        s_ready;
  logic [31:0] s_data;
  logic        load_ack;
  logic        load_reject;
  logic [7:0]  reason_code;
  logic [31:0] active_generation;
  logic [7:0]  query_status;
  logic [7:0]  query_reason;
  logic        query_valid;

  pack_abi24_dut dut (
    .clk(clk),
    .rst_n(rst_n),
    .s_valid(s_valid),
    .s_ready(s_ready),
    .s_data(s_data),
    .load_ack(load_ack),
    .load_reject(load_reject),
    .reason_code(reason_code),
    .active_generation(active_generation),
    .query_status(query_status),
    .query_reason(query_reason),
    .query_valid(query_valid)
  );

  integer rec, wi, nwords, t, n_fail, n_pass, n_loaded;
  integer exp_ack, exp_rej, got_ack, got_rej, mismatch, fd, rc;
  integer unsigned wtmp;
  reg [31:0] stream [0:PACK_ABI24_MAX_WORDS-1];
  reg [8*64-1:0] mempath;

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  initial begin
    n_fail = 0;
    n_pass = 0;
    n_loaded = 0;
    rst_n = 1'b0;
    s_valid = 1'b0;
    s_data = 32'h0;
    if (PACK_ABI24_N != 24) begin
      $display("FATAL PACK_ABI24_N != 24");
      $finish;
    end
    repeat (8) @(posedge clk);
    rst_n = 1'b1;
    repeat (2) @(posedge clk);

    for (rec = 0; rec < PACK_ABI24_N; rec = rec + 1) begin
      fd = pa24_fopen_mem(rec);
      if (fd == 0) begin
        $display("FATAL cannot open mem for case %0d (run pack_abi24_gold.py --emit out)", rec);
        $finish;
      end
      rc = $fscanf(fd, "%h", nwords);
      if (rc != 1 || nwords <= 0 || nwords > PACK_ABI24_MAX_WORDS) begin
        $display("FATAL bad word count in mem case %0d", rec);
        $finish;
      end
      wi = 0;
      while (wi < nwords) begin
        rc = $fscanf(fd, "%h", wtmp);
        if (rc != 1) begin
          $display("FATAL short mem case %0d word %0d", rec, wi);
          $finish;
        end
        stream[wi] = wtmp;
        wi = wi + 1;
      end
      $fclose(fd);
      n_loaded = n_loaded + 1;

      t = 0;
      while (!s_ready && t < 10000) begin
        @(posedge clk);
        t = t + 1;
      end
      if (!s_ready) begin
        n_fail = PACK_ABI24_N;
        $display("PACK_ABI24 XSim FAIL: DUT did not accept stream for %s (s_ready stuck 0). Bind Agent D pack_loader.", PA24_ID[rec]);
        $display("GOLD_LOADED=%0d  this is not PACK_ABI_24_24_PASS and not PACK_ABI24_XSIM_PASS", n_loaded);
        $finish;
      end

      for (wi = 0; wi < nwords; wi = wi + 1) begin
        s_data = stream[wi];
        s_valid = 1'b1;
        t = 0;
        @(posedge clk iff s_ready);
        t = t + 1;
        if (t > 20000) begin
          n_fail = PACK_ABI24_N;
          $display("PACK_ABI24 XSim FAIL: s_ready timeout on %s word %0d", PA24_ID[rec], wi);
          $finish;
        end
      end
      s_valid = 1'b0;

      t = 0;
      while (!load_ack && !load_reject && t < 100000) begin
        @(posedge clk);
        t = t + 1;
      end

      got_ack = load_ack;
      got_rej = load_reject;
      exp_ack = PA24_ACK[rec];
      exp_rej = PA24_REJ[rec];
      mismatch = 0;
      if (got_ack !== exp_ack) mismatch = mismatch + 1;
      if (got_rej !== exp_rej) mismatch = mismatch + 1;
      if (reason_code !== PA24_REASON[rec]) mismatch = mismatch + 1;
      if (query_valid && (query_status == 8'h00 || query_status == 8'h02)) mismatch = mismatch + 1;
      if (PA24_QSTATUS[rec] != PACK_ABI24_QNA && query_valid && query_status !== PA24_QSTATUS[rec][7:0])
        mismatch = mismatch + 1;

      if (t >= 100000 || mismatch != 0) begin
        n_fail = n_fail + 1;
        $display("FAIL %s ack=%0d/%0d rej=%0d/%0d reason=%02h/%02h",
                 PA24_ID[rec], got_ack, exp_ack, got_rej, exp_rej,
                 reason_code, PA24_REASON[rec]);
      end else begin
        n_pass = n_pass + 1;
      end

      rst_n = 1'b0;
      s_valid = 1'b0;
      repeat (4) @(posedge clk);
      rst_n = 1'b1;
      repeat (2) @(posedge clk);
    end

    if (n_fail == 0 && n_pass == PACK_ABI24_N)
      $display("PACK_ABI24_XSIM_PASS  %0d/%0d (simulation only; not PACK_ABI_24_24_PASS, not BOARD_PASS)", n_pass, PACK_ABI24_N);
    else
      $display("PACK_ABI24_XSIM_FAIL  pass=%0d fail=%0d (simulation only)", n_pass, n_fail);
    $finish;
  end
endmodule
