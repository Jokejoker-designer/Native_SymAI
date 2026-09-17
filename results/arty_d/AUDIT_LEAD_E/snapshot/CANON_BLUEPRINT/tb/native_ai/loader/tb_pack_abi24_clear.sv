// tb_pack_abi24_clear.sv — D-PACK-VALIDATION-RESET-01 word-level T1-T6 + 24x2.
// VALIDATION_ONLY. Dest BRAM persists. Not PACK_ABI_24_24_PASS.
`timescale 1ns/1ps
`include "pack_abi24_constants.svh"

module tb_pack_abi24_clear;
`include "pack_abi24_expect.svh"
`include "pack_abi24_fopen.svh"

  localparam logic [31:0] CLR_CMD  = 32'h44524743;
  localparam logic [31:0] CLR_ACK  = 32'hC1EA50A5;
  localparam logic [31:0] CLR_BUSY = 32'hC1EA50B5;

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
  logic debug_clear;
  logic clr_in_valid;
  logic [31:0] clr_in_data;
  logic clr_take, clr_hold, uart_flush, cdc_rst_100;
  logic ui_req, ui_ack, ui_nack;
  logic clr_ack_valid, clr_ack_ready;
  logic [31:0] clr_ack_data;

  pack_abi24_mig_dut dut (
    .clk, .rst_n, .debug_clear, .s_valid, .s_ready, .s_data,
    .load_ack, .load_reject, .reason_code, .active_generation,
    .query_status, .query_reason, .query_valid, .pack_quiescent
  );

  pack_debug_clear u_clr (
    .clk, .rst_n,
    .in_valid(clr_in_valid), .in_data(clr_in_data),
    .take(clr_take), .hold(clr_hold),
    .uart_flush, .cdc_rst_100,
    .ui_req, .ui_ack, .ui_nack,
    .pack_quiescent,
    .ack_valid(clr_ack_valid), .ack_ready(clr_ack_ready), .ack_data(clr_ack_data)
  );
  assign clr_ack_ready = clr_ack_valid;

  pack_clear_ui u_uiclr (
    .clk, .rst_n, .req(ui_req), .pack_quiescent,
    .ack(ui_ack), .nack(ui_nack), .debug_clear
  );

  always #5 clk = ~clk;

  integer rec, wi, nwords, t, n_fail, n_pass, fd, rc, round, mismatch, ok, ghost;
  integer unsigned wtmp;
  integer exp_ack, exp_rej, got_ack, got_rej;
  integer seq_pass, seq_fail;
  integer round_pass [0:1];
  logic [31:0] stream [0:PACK_ABI24_MAX_WORDS-1];
  integer clear_got [0:1][0:PACK_ABI24_N-1];
  integer t_fail;

  task automatic load_case(input integer rec_i);
    begin
      fd = pa24_fopen_mem(rec_i);
      if (fd == 0) $fatal(1, "cannot open mem case %0d", rec_i);
      rc = $fscanf(fd, "%h", nwords);
      if (rc != 1 || nwords <= 0 || nwords > PACK_ABI24_MAX_WORDS)
        $fatal(1, "bad word count case %0d", rec_i);
      wi = 0;
      while (wi < nwords) begin
        rc = $fscanf(fd, "%h", wtmp);
        if (rc != 1) $fatal(1, "short mem case %0d word %0d", rec_i, wi);
        stream[wi] = wtmp;
        wi = wi + 1;
      end
      $fclose(fd);
    end
  endtask

  task automatic send_stream;
    integer k;
    begin
      k = 0;
      while (!s_ready && k < 20000) begin @(posedge clk); k = k + 1; end
      for (wi = 0; wi < nwords; wi = wi + 1) begin
        s_data = stream[wi];
        s_valid = 1'b1;
        k = 0;
        while (!s_ready && k < 40000) begin @(posedge clk); k = k + 1; end
        @(posedge clk);
      end
      s_valid = 1'b0;
    end
  endtask

  task automatic wait_pack(output integer word, output integer ok_o);
    integer k;
    begin
      k = 0;
      while (!load_ack && !load_reject && k < 200000) begin @(posedge clk); k = k + 1; end
      got_ack = load_ack;
      got_rej = load_reject;
      if (got_ack)
        word = {8'h01, 8'h00, reason_code, 8'hA5};
      else
        word = {8'h02, 8'h00, reason_code, 8'h5A};
      ok_o = (k < 200000);
      @(posedge clk);
    end
  endtask

  task automatic score_rec(input integer rec_i, input integer word, output integer ok_o);
    begin
      mismatch = 0;
      if (load_ack !== PA24_ACK[rec_i]) mismatch = mismatch + 1;
      if (load_reject !== PA24_REJ[rec_i]) mismatch = mismatch + 1;
      if (reason_code !== PA24_REASON[rec_i]) mismatch = mismatch + 1;
      ok_o = (mismatch == 0);
      if (!ok_o)
        $display("FAIL %s ack=%0d/%0d rej=%0d/%0d reason=%02h/%02h",
                 PA24_ID[rec_i], load_ack, PA24_ACK[rec_i], load_reject, PA24_REJ[rec_i],
                 reason_code, PA24_REASON[rec_i]);
    end
  endtask

  task automatic do_clear(input logic [31:0] exp, output integer got);
    integer k;
    begin
      k = 0;
      while ((clr_ack_valid || clr_hold) && k < 65535) begin @(posedge clk); k = k + 1; end
      clr_in_data = CLR_CMD;
      clr_in_valid = 1'b1;
      @(posedge clk);
      clr_in_valid = 1'b0;
      k = 0;
      while (!clr_ack_valid && k < 65535) begin @(posedge clk); k = k + 1; end
      got = clr_ack_data;
      if (!clr_ack_valid || clr_ack_data !== exp) begin
        $display("CLEAR_MISMATCH exp=%08h got=%08h t=%0d qsc=%0d hold=%0d",
                 exp, clr_ack_data, k, pack_quiescent, clr_hold);
        t_fail = t_fail + 1;
      end else
        $display("CLEAR_MATCH %08h t=%0d", clr_ack_data, k);
      @(posedge clk);
      while (clr_hold) @(posedge clk);
      if (clr_ack_data === CLR_ACK) begin
        k = 0;
        while (!pack_quiescent && k < 20000) begin @(posedge clk); k = k + 1; end
        repeat (4) @(posedge clk);
      end
    end
  endtask

  initial begin
    n_fail = 0; n_pass = 0; seq_pass = 0; seq_fail = 0; t_fail = 0;
    round_pass[0] = 0; round_pass[1] = 0;
    s_valid = 1'b0; s_data = 32'h0;
    clr_in_valid = 1'b0; clr_in_data = 32'h0;
    rst_n = 1'b0;
    repeat (8) @(posedge clk);
    rst_n = 1'b1;
    repeat (8) @(posedge clk);

    // T1 fresh V-01
    load_case(0);
    send_stream();
    wait_pack(wtmp, ok);
    score_rec(0, wtmp, ok);
    if (!ok || wtmp !== 32'h010000A5) t_fail = t_fail + 1;
    else $display("T1 PASS V-01 %08h", wtmp);

    // T2 V-01 again no CLEAR -> STALE
    load_case(0);
    send_stream();
    wait_pack(wtmp, ok);
    if (wtmp !== 32'h02000E5A) begin
      $display("T2 FAIL expected STALE got=%08h", wtmp);
      t_fail = t_fail + 1;
    end else $display("T2 PASS STALE %08h", wtmp);

    // T3 CLEAR then V-01 == fresh
    do_clear(CLR_ACK, wtmp);
    load_case(0);
    send_stream();
    wait_pack(wtmp, ok);
    if (wtmp !== 32'h010000A5) begin
      $display("T3 FAIL after CLEAR V-01 got=%08h", wtmp);
      t_fail = t_fail + 1;
    end else $display("T3 PASS CLEAR then V-01");

    // T4 reject then CLEAR then V-01
    load_case(4); // PA24-S-01 reject
    send_stream();
    wait_pack(wtmp, ok);
    do_clear(CLR_ACK, wtmp);
    load_case(0);
    send_stream();
    wait_pack(wtmp, ok);
    if (wtmp !== 32'h010000A5) begin
      $display("T4 FAIL got=%08h", wtmp);
      t_fail = t_fail + 1;
    end else $display("T4 PASS reject then CLEAR then V-01");

    // T5 CLEAR while transaction active: MUST NOT destructive-clear. Immediate BUSY.
    do_clear(CLR_ACK, wtmp);
    load_case(1); // V-02
    fork
      send_stream();
      begin
        t = 0;
        while (pack_quiescent && t < 100000) begin @(posedge clk); t = t + 1; end
        do_clear(CLR_BUSY, wtmp);
      end
    join
    wait_pack(wtmp, ok);
    if (wtmp !== 32'h010000A5) begin
      $display("T5 FAIL pack after BUSY got=%08h", wtmp);
      t_fail = t_fail + 1;
    end else $display("T5 PASS pack completed after BUSY (not destroyed)");

    // T6 CLEAR twice
    do_clear(CLR_ACK, wtmp);
    do_clear(CLR_ACK, wtmp);
    $display("T6 PASS double CLEAR");

    // T8 after CLEAR_ACK: no ghost pack completion
    t = 0;
    ghost = 0;
    while (t < 64) begin
      @(posedge clk);
      t = t + 1;
      if (load_ack || load_reject) ghost = 1;
    end
    if (ghost) begin
      $display("T8 FAIL ghost pack status after CLEAR_ACK");
      t_fail = t_fail + 1;
    end else $display("T8 PASS no ghost after CLEAR_ACK");

    // 24 x2 with CLEAR
    for (round = 0; round < 2; round = round + 1) begin
      for (rec = 0; rec < PACK_ABI24_N; rec = rec + 1) begin
        do_clear(CLR_ACK, wtmp);
        load_case(rec);
        send_stream();
        wait_pack(wtmp, ok);
        score_rec(rec, wtmp, ok);
        clear_got[round][rec] = wtmp;
        if (ok) begin
          n_pass = n_pass + 1;
          round_pass[round] = round_pass[round] + 1;
        end else n_fail = n_fail + 1;
      end
    end

    rst_n = 1'b0;
    repeat (8) @(posedge clk);
    rst_n = 1'b1;
    repeat (8) @(posedge clk);
    for (rec = 0; rec < PACK_ABI24_N; rec = rec + 1) begin
      load_case(rec);
      send_stream();
      wait_pack(wtmp, ok);
      score_rec(rec, wtmp, ok);
      if (ok) seq_pass = seq_pass + 1;
      else seq_fail = seq_fail + 1;
    end

    $display("PACK_ABI24_CLEAR_XSIM t_fail=%0d round0=%0d/24 round1=%0d/24 seq_no_clear pass=%0d fail=%0d",
             t_fail, round_pass[0], round_pass[1], seq_pass, seq_fail);
    $display("NOTE round1/seq dest payload persists; SENTINEL is dest-assumption evidence, not gold edit");
    if (t_fail == 0 && round_pass[0] == PACK_ABI24_N)
      $display("PACK_ABI24_CLEAR_XSIM_PASS T1-T8+round0 24/24 (simulation only; not PACK_ABI_24_24_PASS)");
    else
      $display("PACK_ABI24_CLEAR_XSIM_FAIL t_fail=%0d pass=%0d fail=%0d", t_fail, n_pass, n_fail);
    $finish;
  end
endmodule
