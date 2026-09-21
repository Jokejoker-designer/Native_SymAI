// Isolated pack_obs_query. Gold QueryRecord 8 words (no count prefix).
// PASS_XSIM only. PROGRAM=NO. Not PACK_ABI_24_24_PASS.
`timescale 1ns/1ps

module tb_pack_obs_query;
  logic clk = 0;
  logic rst_n = 0;
  logic w_valid, dump_take, clr_take, debug_clear, pack_fire, tx_ready;
  logic [31:0] w_data, pack_word, active_generation, tx_data;
  logic q_take, tx_valid;

  pack_obs_query u_q (
    .clk, .rst_n, .w_valid, .w_data, .dump_take, .clr_take, .debug_clear,
    .pack_fire, .pack_word, .active_generation,
    .q_take, .tx_valid, .tx_ready, .tx_data
  );

  always #5 clk = ~clk;

  integer i, nfail, wait_n;
  logic [31:0] r04 [0:7];
  logic [31:0] g04 [0:7];
  logic [31:0] bad [0:7];

  task automatic send_q(input logic [31:0] qw [0:7]);
    integer k;
    begin
      for (k = 0; k < 8; k = k + 1) begin
        w_data = qw[k];
        w_valid = 1;
        @(posedge clk);
        #1;
        if (k == 0 && !q_take) begin
          $display("FAIL q_take=0 at first magic word");
          nfail = nfail + 1;
        end
      end
      w_valid = 0;
      w_data = 0;
    end
  endtask

  task automatic wait_tx(input [31:0] want, input string tag);
    begin
      wait_n = 0;
      while (!tx_valid && wait_n < 40) begin
        @(posedge clk);
        #1;
        wait_n = wait_n + 1;
      end
      $display("%s TX valid=%0d data=%08h after %0d dest=%0d",
               tag, tx_valid, tx_data, wait_n, u_q.dest_fail);
      if (!tx_valid) begin
        $display("FAIL %s no TX", tag);
        nfail = nfail + 1;
      end else if (tx_data !== want) begin
        $display("FAIL %s got %08h want %08h", tag, tx_data, want);
        nfail = nfail + 1;
      end
      @(posedge clk);
      #1;
    end
  endtask

  initial begin
    nfail = 0;
    w_valid = 0; dump_take = 0; clr_take = 0; debug_clear = 0; pack_fire = 0;
    tx_ready = 1; w_data = 0; pack_word = 0; active_generation = 32'h2b;
    r04[0] = 32'h03014e51;
    r04[1] = 32'h00000002;
    r04[2] = 32'h0001002b;
    r04[3] = 32'h01000000;
    r04[4] = 32'h00090001;
    r04[5] = 32'h00000000;
    r04[6] = 32'h00000000;
    r04[7] = 32'hca320040;
    g04[0] = 32'h03014e51;
    g04[1] = 32'h00000009;
    g04[2] = 32'h00010001;
    g04[3] = 32'h01000000;
    g04[4] = 32'h00090001;
    g04[5] = 32'h00000000;
    g04[6] = 32'h00000000;
    g04[7] = 32'hf2a30040;
    for (i = 0; i < 8; i = i + 1)
      bad[i] = r04[i];
    bad[7] = 32'h00000000;
    repeat (4) @(posedge clk);
    rst_n = 1;
    repeat (4) @(posedge clk);

    send_q(r04);
    wait_tx(32'h03000051, "R04_CRC_OK_NO_DEST");

    for (i = 0; i < 8; i = i + 1) begin
      pack_word = bad[i];
      pack_fire = 1;
      @(posedge clk);
      #1;
    end
    pack_fire = 0;
    pack_word = 0;
    repeat (2) @(posedge clk);
    #1;
    if (!u_q.dest_fail) begin
      $display("FAIL dest_fail stayed 0 after inner CRC mismatch");
      nfail = nfail + 1;
    end
    send_q(r04);
    wait_tx(32'h03065051, "R04_DEST_PACK_CRC");

    debug_clear = 1;
    @(posedge clk);
    #1;
    debug_clear = 0;
    repeat (2) @(posedge clk);
    send_q(g04);
    wait_tx(32'h03065451, "G04_STALE");

    if (nfail == 0)
      $display("PACK_OBS_QUERY_XSIM_PASS (not PACK_ABI_24_24_PASS)");
    else
      $display("PACK_OBS_QUERY_XSIM_FAIL nfail=%0d", nfail);
    $display("PACK_ABI_24_24_PASS=NO PROGRAM=NO");
    $finish;
  end
endmodule
