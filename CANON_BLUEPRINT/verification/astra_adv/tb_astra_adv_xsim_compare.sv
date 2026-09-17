// tb_astra_adv_xsim_compare.sv
// AGENT_B XSim comparator for ASTRA adv Q-eval. Not DUT RTL. PROGRAM=NO.
// XSim != board. A pass banner here is ASTRA_ADV_XSIM_PASS only,
// never ASTRA_ADV_PASS / FE256_PASS / PACK_ABI_24_24_PASS / BOARD_PASS.
//
// Agent D binds astra_adv_dut (q_ready/s_ready). Open stub keeps both 0 (fail-closed).
// Streams: out/<CASE_ID>.mem   Expect: astra_adv_expect.svh
// Host: python astra_adv_gold.py --selfcheck --emit out
//       python astra_adv_gold.py --compare DUT.jsonl
//
// iverilog-friendly: $fscanf mem, integer/reg arrays, no string localparam.

`timescale 1ns/1ps
`include "astra_adv_constants.svh"

module tb_astra_adv_xsim_compare;
`include "astra_adv_expect.svh"
`include "astra_adv_fopen.svh"

  reg clk;
  reg rst_n;
  reg        q_valid;
  wire       q_ready;
  reg        s_valid;
  wire       s_ready;
  reg [31:0] q_data;
  wire       r_valid;
  reg        r_ready;
  wire [31:0] r_data;

  astra_adv_dut dut (
    .clk(clk),
    .rst_n(rst_n),
    .q_valid(q_valid),
    .q_ready(q_ready),
    .s_valid(s_valid),
    .s_ready(s_ready),
    .q_data(q_data),
    .r_valid(r_valid),
    .r_ready(r_ready),
    .r_data(r_data)
  );

  integer rec, wi, nwords, t, n_fail, n_pass, n_loaded;
  integer mismatch, fd, rc, got_words;
  integer unsigned wtmp;
  integer unsigned rw;
  reg [31:0] stream [0:ASTRA_ADV_MAX_WORDS-1];
  reg [31:0] rstream [0:ASTRA_ADV_RESULT_WORDS-1];
  reg [7:0] got_status;
  reg [7:0] got_reason;
  reg [7:0] got_kind;
  reg [7:0] got_cmpl;
  reg [31:0] got_txn;
  reg [31:0] got_proof;
  reg [31:0] got_conflict;
  integer illegal_st;
  integer ready_ok;

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  initial begin
    n_fail = 0;
    n_pass = 0;
    n_loaded = 0;
    rst_n = 1'b0;
    q_valid = 1'b0;
    s_valid = 1'b0;
    q_data = 32'h0;
    r_ready = 1'b1;
    if (ASTRA_ADV_N < 11) begin
      $display("FATAL ASTRA_ADV_N < 11 (locked prefix shrunk)");
      $finish;
    end
    repeat (8) @(posedge clk);
    rst_n = 1'b1;
    repeat (2) @(posedge clk);

    for (rec = 0; rec < ASTRA_ADV_N; rec = rec + 1) begin
      fd = aa_fopen_mem(rec);
      if (fd == 0) begin
        $display("FATAL cannot open mem for case %0d (run astra_adv_gold.py --selfcheck --emit out)", rec);
        $finish;
      end
      rc = $fscanf(fd, "%h", nwords);
      if (rc != 1 || nwords <= 0 || nwords > ASTRA_ADV_MAX_WORDS) begin
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
      ready_ok = 0;
      while (!ready_ok && t < 10000) begin
        if (q_ready || s_ready) ready_ok = 1;
        else begin
          @(posedge clk);
          t = t + 1;
        end
      end
      if (!ready_ok) begin
        n_fail = ASTRA_ADV_N;
        $display("ASTRA_ADV XSim FAIL: DUT did not accept query for %s (q_ready/s_ready stuck 0). Bind Agent D astra_adv_dut.", AA_ID[rec]);
        $display("GOLD_LOADED=%0d  this is not ASTRA_ADV_PASS and not ASTRA_ADV_XSIM_PASS", n_loaded);
        $finish;
      end

      for (wi = 0; wi < nwords; wi = wi + 1) begin
        q_data = stream[wi];
        q_valid = 1'b1;
        s_valid = 1'b1;
        t = 0;
        ready_ok = 0;
        while (!ready_ok && t < 20000) begin
          if (q_ready || s_ready) ready_ok = 1;
          else begin
            @(posedge clk);
            t = t + 1;
          end
        end
        if (!ready_ok) begin
          n_fail = ASTRA_ADV_N;
          $display("ASTRA_ADV XSim FAIL: q_ready/s_ready timeout on %s word %0d", AA_ID[rec], wi);
          $finish;
        end
        @(posedge clk);
      end
      q_valid = 1'b0;
      s_valid = 1'b0;

      t = 0;
      while (!r_valid && t < 100000) begin
        @(posedge clk);
        t = t + 1;
      end

      mismatch = 0;
      illegal_st = 0;
      got_status = 8'h00;
      got_reason = 8'h00;
      got_kind = 8'h00;
      got_cmpl = 8'h00;
      got_txn = 32'h0;
      got_proof = 32'h0;
      got_conflict = 32'h0;
      got_words = 0;

      if (t >= 100000) begin
        mismatch = mismatch + 1;
        $display("FAIL %s result timeout", AA_ID[rec]);
      end else begin
        for (wi = 0; wi < ASTRA_ADV_RESULT_WORDS; wi = wi + 1) begin
          t = 0;
          while (!r_valid && t < 20000) begin
            @(posedge clk);
            t = t + 1;
          end
          rstream[wi] = r_data;
          got_words = got_words + 1;
          @(posedge clk);
        end
        // LE words: w0 = {status,abi,magic[15:0]} with status in [31:24]
        got_status = rstream[0][31:24];
        got_reason = rstream[1][7:0];
        got_kind = rstream[1][15:8];
        got_cmpl = rstream[1][23:16];
        got_txn = rstream[2];
        // StructuredResult LE: proof_ref @ bytes 28-31, conflict_ref @ 40-43
        got_proof = rstream[7];
        got_conflict = rstream[10];

        if (got_status == ASTRA_ADV_ILLEGAL_00 ||
            got_status == ASTRA_ADV_ILLEGAL_22 ||
            got_status == ASTRA_ADV_ILLEGAL_23 ||
            got_status == ASTRA_ADV_ILLEGAL_55 ||
            got_status == ASTRA_ADV_ILLEGAL_56 ||
            got_status == ASTRA_ADV_ILLEGAL_80) begin
          illegal_st = 1;
          mismatch = mismatch + 1;
          $display("FAIL %s illegal FPGA status %02h (0x00/0x22/0x23/0x55/0x56/0x80 never lawful)",
                   AA_ID[rec], got_status);
        end

        if (AA_MODE[rec] == ASTRA_ADV_MODE_PROTOCOL) begin
          if (got_status == ASTRA_ADV_ST_UNKNOWN) begin
            mismatch = mismatch + 1;
            $display("FAIL %s protocol fault mapped to UNKNOWN", AA_ID[rec]);
          end
          if (got_status !== AA_STATUS[rec]) mismatch = mismatch + 1;
          if (got_reason !== AA_REASON[rec]) mismatch = mismatch + 1;
        end else if (AA_MODE[rec] == ASTRA_ADV_MODE_COMPARE) begin
          if (got_status !== AA_STATUS[rec]) mismatch = mismatch + 1;
          if (got_reason !== AA_REASON[rec]) mismatch = mismatch + 1;
          if (got_cmpl !== AA_CMPL[rec]) mismatch = mismatch + 1;
          if (got_kind !== AA_KIND[rec]) mismatch = mismatch + 1;
          if (got_txn !== AA_TXN[rec]) begin
            mismatch = mismatch + 1;
            $display("FAIL %s txn echo got=%08h exp=%08h (not UNKNOWN)",
                     AA_ID[rec], got_txn, AA_TXN[rec]);
          end
          if (got_proof !== AA_PROOF[rec]) mismatch = mismatch + 1;
          if (got_conflict !== AA_CONFLICT[rec]) mismatch = mismatch + 1;
          if (AA_STATUS[rec] == 8'h01) begin
            if (got_proof == 32'h0) mismatch = mismatch + 1;
            if (got_kind == 8'h00) mismatch = mismatch + 1;
            if (got_cmpl !== 8'h01) mismatch = mismatch + 1;
            if (got_conflict != 32'h0) mismatch = mismatch + 1;
          end
          if (AA_STATUS[rec] == 8'h04) begin
            if (got_cmpl !== 8'h02) mismatch = mismatch + 1;
            if (got_status == ASTRA_ADV_ST_UNKNOWN) mismatch = mismatch + 1;
          end
          if (AA_STATUS[rec] == 8'h03) begin
            if (got_conflict == 32'h0) mismatch = mismatch + 1;
            if (got_reason !== 8'h30) mismatch = mismatch + 1;
          end
        end
      end

      if (illegal_st != 0 || mismatch != 0) begin
        n_fail = n_fail + 1;
        $display("FAIL %s status=%02h/%02h reason=%02h/%02h txn=%08h illegal=%0d",
                 AA_ID[rec], got_status, AA_STATUS[rec], got_reason, AA_REASON[rec],
                 got_txn, illegal_st);
      end else begin
        n_pass = n_pass + 1;
      end

      rst_n = 1'b0;
      q_valid = 1'b0;
      s_valid = 1'b0;
      repeat (4) @(posedge clk);
      rst_n = 1'b1;
      repeat (2) @(posedge clk);
    end

    if (n_fail == 0 && n_pass == ASTRA_ADV_N)
      $display("ASTRA_ADV_XSIM_PASS  %0d/%0d (simulation only; not ASTRA_ADV_PASS, not BOARD_PASS, PROGRAM=NO)", n_pass, ASTRA_ADV_N);
    else
      $display("ASTRA_ADV_XSIM_FAIL  pass=%0d fail=%0d (simulation only)", n_pass, n_fail);
    $finish;
  end
endmodule
