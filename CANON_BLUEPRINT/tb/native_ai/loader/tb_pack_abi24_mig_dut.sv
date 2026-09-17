// D-owned 24-case Pack/ABI-24 compare through pack_mig_bind dest-complete.
// Does not modify B TB. Not PACK_ABI_24_24_PASS. PROGRAM=NO. XSim != board.
`timescale 1ns/1ps
`include "pack_abi24_constants.svh"

module tb_pack_abi24_mig_dut;
`include "pack_abi24_expect.svh"
`include "pack_abi24_fopen.svh"

  logic clk = 0;
  logic rst_n = 0;
  logic        s_valid;
  logic        s_ready;
  logic [31:0] s_data;
  logic        load_ack, load_reject;
  logic [7:0]  reason_code;
  logic [31:0] active_generation;
  logic [7:0]  query_status, query_reason;
  logic        query_valid;

  pack_abi24_mig_dut dut (
    .clk, .rst_n, .s_valid, .s_ready, .s_data,
    .load_ack, .load_reject, .reason_code, .active_generation,
    .query_status, .query_reason, .query_valid
  );

  always #5 clk = ~clk;

  integer rec, wi, nwords, t, n_fail, n_pass, n_loaded, fd, rc;
  integer unsigned wtmp;
  integer exp_ack, exp_rej, got_ack, got_rej, mismatch;
  logic [31:0] stream [0:PACK_ABI24_MAX_WORDS-1];

  initial begin
    n_fail = 0; n_pass = 0; n_loaded = 0;
    s_valid = 1'b0; s_data = 32'h0;
    rst_n = 1'b0;
    repeat (8) @(posedge clk);
    rst_n = 1'b1;
    repeat (4) @(posedge clk);

    for (rec = 0; rec < PACK_ABI24_N; rec = rec + 1) begin
      fd = pa24_fopen_mem(rec);
      if (fd == 0) $fatal(1, "cannot open mem case %0d", rec);
      rc = $fscanf(fd, "%h", nwords);
      if (rc != 1 || nwords <= 0 || nwords > PACK_ABI24_MAX_WORDS)
        $fatal(1, "bad word count case %0d", rec);
      wi = 0;
      while (wi < nwords) begin
        rc = $fscanf(fd, "%h", wtmp);
        if (rc != 1) $fatal(1, "short mem case %0d word %0d", rec, wi);
        stream[wi] = wtmp;
        wi = wi + 1;
      end
      $fclose(fd);
      n_loaded = n_loaded + 1;

      t = 0;
      while (!s_ready && t < 20000) begin @(posedge clk); t = t + 1; end
      if (!s_ready) begin
        n_fail = PACK_ABI24_N;
        $display("FAIL s_ready stuck 0 case %s", PA24_ID[rec]);
        $finish;
      end

      for (wi = 0; wi < nwords; wi = wi + 1) begin
        s_data = stream[wi];
        s_valid = 1'b1;
        t = 0;
        while (!s_ready && t < 40000) begin @(posedge clk); t = t + 1; end
        if (!s_ready) begin
          n_fail = PACK_ABI24_N;
          $display("FAIL s_ready timeout %s word %0d", PA24_ID[rec], wi);
          $finish;
        end
        @(posedge clk);
      end
      s_valid = 1'b0;

      t = 0;
      while (!load_ack && !load_reject && t < 200000) begin @(posedge clk); t = t + 1; end

      got_ack = load_ack;
      got_rej = load_reject;
      exp_ack = PA24_ACK[rec];
      exp_rej = PA24_REJ[rec];
      mismatch = 0;
      if (got_ack !== exp_ack) mismatch = mismatch + 1;
      if (got_rej !== exp_rej) mismatch = mismatch + 1;
      if (reason_code !== PA24_REASON[rec]) mismatch = mismatch + 1;
      if (query_valid && (query_status == 8'h00 || query_status == 8'h02)) mismatch = mismatch + 1;

      if (t >= 200000 || mismatch != 0) begin
        n_fail = n_fail + 1;
        $display("FAIL %s ack=%0d/%0d rej=%0d/%0d reason=%02h/%02h t=%0d",
                 PA24_ID[rec], got_ack, exp_ack, got_rej, exp_rej,
                 reason_code, PA24_REASON[rec], t);
      end else n_pass = n_pass + 1;

      rst_n = 1'b0;
      s_valid = 1'b0;
      repeat (8) @(posedge clk);
      rst_n = 1'b1;
      repeat (4) @(posedge clk);
    end

    if (n_fail == 0 && n_pass == PACK_ABI24_N)
      $display("PACK_ABI24_MIG_DUT_XSIM_PASS  %0d/%0d dest-complete (simulation only; not PACK_ABI_24_24_PASS)", n_pass, PACK_ABI24_N);
    else
      $display("PACK_ABI24_MIG_DUT_XSIM_FAIL  pass=%0d fail=%0d", n_pass, n_fail);
    $finish;
  end
endmodule
