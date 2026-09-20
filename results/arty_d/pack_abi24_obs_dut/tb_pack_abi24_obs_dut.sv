// D-owned 24-case Pack/ABI-24 observe. pack_obs_gen four-AND on Pack S_COMMIT.
// Does not modify B TB. Does not copy PA24_FLIP. PROGRAM=NO.
// XSim DUT.jsonl is not PACK_ABI_24_24_PASS / BOARD_PASS.
`timescale 1ns/1ps
`include "pack_abi24_constants.svh"

module tb_pack_abi24_obs_dut;
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
  logic        pack_quiescent;
  logic [15:0] epoch_id;
  logic        cap_v;
  logic        commit_pulse;
  logic        commit_event, same_ep, flip_present, gen_flip, commit_seen, cap_at;
  logic [31:0] gbefore, gafter;

  pack_abi24_mig_dut dut (
    .clk, .rst_n, .s_valid, .s_ready, .s_data,
    .load_ack, .load_reject, .reason_code, .active_generation,
    .query_status, .query_reason, .query_valid, .pack_quiescent
  );

  assign commit_pulse = (dut.u_ld.u_ld.state == 4'd7);
  assign cap_v = rst_n;

  pack_obs_gen u_gen (
    .clk, .rst_n, .capture_valid(cap_v), .epoch_id,
    .debug_clear(1'b0), .commit_pulse, .active_generation,
    .commit_event, .generation_before(gbefore), .generation_after(gafter),
    .same_capture_epoch(same_ep), .flip_present, .generation_flipped(gen_flip),
    .commit_seen, .capture_valid_at(cap_at)
  );

  always #5 clk = ~clk;

  integer rec, wi, nwords, t, n_fail, n_pass, n_loaded, fd, rc, jfd, k;
  integer unsigned wtmp;
  integer exp_ack, exp_rej, got_ack, got_rej, mismatch;
  logic [31:0] stream [0:PACK_ABI24_MAX_WORDS-1];
  string outcome;
  string line;

  initial begin
    n_fail = 0; n_pass = 0; n_loaded = 0;
    s_valid = 1'b0; s_data = 32'h0; epoch_id = 16'h1;
    jfd = $fopen("DUT.jsonl", "w");
    if (jfd == 0) $fatal(1, "cannot open DUT.jsonl");
    rst_n = 1'b0;
    repeat (8) @(posedge clk);
    rst_n = 1'b1;
    repeat (4) @(posedge clk);

    for (rec = 0; rec < PACK_ABI24_N; rec = rec + 1) begin
      epoch_id = epoch_id + 16'h1;
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
      for (k = 0; k < 8; k = k + 1) @(posedge clk);

      got_ack = load_ack;
      got_rej = load_reject;
      exp_ack = PA24_ACK[rec];
      exp_rej = PA24_REJ[rec];
      mismatch = 0;
      if (got_ack !== exp_ack) mismatch = mismatch + 1;
      if (got_rej !== exp_rej) mismatch = mismatch + 1;
      if (reason_code !== PA24_REASON[rec]) mismatch = mismatch + 1;

      if (t >= 200000 || mismatch != 0) begin
        n_fail = n_fail + 1;
        $display("FAIL_LOAD %s ack=%0d/%0d rej=%0d/%0d reason=%02h/%02h t=%0d",
                 PA24_ID[rec], got_ack, exp_ack, got_rej, exp_rej,
                 reason_code, PA24_REASON[rec], t);
      end else n_pass = n_pass + 1;

      if (got_ack) outcome = "LOAD_OK";
      else outcome = "LOAD_REJECT";

      if (flip_present && commit_seen && same_ep && cap_at)
        $sformat(line,
          "{\"case_id\":\"%0s\",\"outcome\":\"%0s\",\"reason\":%0d,\"ack\":%0d,\"reject\":%0d,\"generation_flipped\":%0d,\"header_bytes\":128,\"commit_event\":1,\"same_capture_epoch\":%0d,\"capture_valid\":%0d,\"generation_before\":\"%08h\",\"generation_after\":\"%08h\",\"source\":\"XSIM_PACK_OBS_GEN_NOT_SILICON\",\"PACK_ABI_24_24_PASS\":\"NO\"}",
          PA24_ID[rec], outcome, reason_code, got_ack, got_rej, gen_flip,
          same_ep, cap_at, gbefore, gafter);
      else
        $sformat(line,
          "{\"case_id\":\"%0s\",\"outcome\":\"%0s\",\"reason\":%0d,\"ack\":%0d,\"reject\":%0d,\"header_bytes\":128,\"commit_event\":%0d,\"flip_present\":%0d,\"source\":\"XSIM_PACK_OBS_GEN_NOT_SILICON\",\"PACK_ABI_24_24_PASS\":\"NO\"}",
          PA24_ID[rec], outcome, reason_code, got_ack, got_rej, commit_seen, flip_present);
      $fdisplay(jfd, "%s", line);
      $display("OBS %s ack=%0d rej=%0d reason=%02h flip_present=%0d gen_flip=%0d commit_seen=%0d before=%08h after=%08h",
               PA24_ID[rec], got_ack, got_rej, reason_code, flip_present, gen_flip, commit_seen, gbefore, gafter);

      rst_n = 1'b0;
      s_valid = 1'b0;
      repeat (8) @(posedge clk);
      rst_n = 1'b1;
      repeat (4) @(posedge clk);
    end

    $fclose(jfd);
    if (n_fail == 0 && n_pass == PACK_ABI24_N)
      $display("PACK_ABI24_OBS_DUT_XSIM_LOAD  %0d/%0d dest-complete observe (simulation only; not PACK_ABI_24_24_PASS)", n_pass, PACK_ABI24_N);
    else
      $display("PACK_ABI24_OBS_DUT_XSIM_LOAD_FAIL  pass=%0d fail=%0d", n_pass, n_fail);
    $display("PACK_ABI_24_24_PASS=NO PROGRAM=NO");
    $finish;
  end
endmodule
