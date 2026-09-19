// tb_u1_h20_conservation.sv
// UART_R2_U1: completed 4th-byte word must not be silently discarded.
// words_dropped must be 0. w_ready=0 is not a fault.
// Not BOARD_PASS / not PACK_ABI_24_24_PASS. Identity != H.
`timescale 1ns/1ps

module tb_u1_h20_conservation;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 1_000_000;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam logic [31:0] W0 = 32'hA1B2C3D4;
  localparam logic [31:0] W1 = 32'h11223344;
  localparam logic [31:0] W2 = 32'h55667788;

  logic clk, rst_n, rx, w_valid, w_ready, ready_gate;
  logic [31:0] w_data;
  logic idle;

  uart_rx_word #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_rx (
    .clk, .rst_n, .rx, .w_valid, .w_ready, .w_data, .flush(1'b0), .idle, .rx_sync()
  );

  assign w_ready = ready_gate;

  initial clk = 1'b0;
  always #5 clk = ~clk;

  int words_completed, words_accepted, words_dropped, words_held, err;
  logic [31:0] got [0:15];
  int n_got;
  logic stop_fire, drop_now;

  assign stop_fire = (u_rx.st == 2'd3) && (u_rx.div == 16'h0) && !u_rx.stop_hold && (u_rx.bix == 2'd3);
  assign drop_now  = stop_fire && w_valid && !w_ready && !u_rx.stop_hold;
  // After U1, stop_fire with blocked output sets stop_hold next cycle; never drops.

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      words_completed <= 0;
      words_accepted <= 0;
      words_dropped <= 0;
      words_held <= 0;
      n_got <= 0;
    end else begin
      if (stop_fire)
        words_completed <= words_completed + 1;
      if (u_rx.stop_hold && !ready_gate)
        words_held <= words_held + 1;
      if (stop_fire && w_valid && !w_ready && u_rx.stop_hold === 1'b0) begin
        // H-class would drop here on this cycle. U1 must set hold, not lose the word.
      end
      if (w_valid && w_ready) begin
        got[n_got] <= w_data;
        n_got <= n_got + 1;
        words_accepted <= words_accepted + 1;
      end
    end
  end

  task automatic reset_all;
    rst_n = 0;
    rx = 1;
    ready_gate = 1;
    repeat (8) @(posedge clk);
    rst_n = 1;
    repeat (8) @(posedge clk);
  endtask

  task automatic uart_byte(input logic [7:0] b);
    int k;
    rx <= 0;
    repeat (DIV) @(posedge clk);
    for (k = 0; k < 8; k++) begin
      rx <= b[k];
      repeat (DIV) @(posedge clk);
    end
    rx <= 1;
    repeat (DIV) @(posedge clk);
  endtask

  task automatic send_word(input logic [31:0] w);
    uart_byte(w[7:0]);
    uart_byte(w[15:8]);
    uart_byte(w[23:16]);
    uart_byte(w[31:24]);
  endtask

  task automatic expect_seq(input string name, input int n, input logic [31:0] e0, e1, e2);
    int i;
    if (u_rx.stop_hold)
      $display("U1 %s still holding", name);
    if (n_got < n) begin
      $display("FAIL %s n_got=%0d want>=%0d", name, n_got, n);
      err = err + 1;
    end
    if (n >= 1 && got[0] !== e0) begin $display("FAIL %s e0=%h", name, got[0]); err = err + 1; end
    if (n >= 2 && got[1] !== e1) begin $display("FAIL %s e1=%h", name, got[1]); err = err + 1; end
    if (n >= 3 && got[2] !== e2) begin $display("FAIL %s e2=%h", name, got[2]); err = err + 1; end
    $display("U1 CASE %s accepted=%0d completed=%0d hold_cycles=%0d got0=%h",
             name, words_accepted, words_completed, words_held, (n_got==0)?32'h0:got[0]);
  endtask

  integer r;
  initial begin
    err = 0;

    // 1 always ready, back-to-back
    reset_all();
    send_word(W0);
    send_word(W1);
    repeat (DIV * 2) @(posedge clk);
    expect_seq("1_ALWAYS_HIGH", 2, W0, W1, 0);

    // 2 long ready-low after W0 sitting, then take, then W1
    reset_all();
    send_word(W0);
    ready_gate = 0;
    repeat (DIV * 40) @(posedge clk);
    ready_gate = 1;
    repeat (8) @(posedge clk);
    send_word(W1);
    repeat (DIV * 2) @(posedge clk);
    expect_seq("2_LONG_READY_LOW_IDLE", 2, W0, W1, 0);

    // 3 W0 sits, W1 4th STOP while !w_ready → must HOLD not drop, then both emit
    reset_all();
    ready_gate = 0;
    send_word(W0);
    send_word(W1);
    repeat (DIV) @(posedge clk);
    ready_gate = 1;
    repeat (DIV * 8) @(posedge clk);
    expect_seq("3_BACK_TO_BACK_STALL", 2, W0, W1, 0);

    // 4 randomized ready during burst of 3
    reset_all();
    fork
      begin
        send_word(W0);
        send_word(W1);
        send_word(W2);
      end
      begin
        repeat (DIV * 2) @(posedge clk);
        for (r = 0; r < 80; r++) begin
          ready_gate = $urandom_range(0, 1);
          repeat (DIV / 4) @(posedge clk);
        end
        ready_gate = 1;
      end
    join
    repeat (DIV * 20) @(posedge clk);
    ready_gate = 1;
    repeat (DIV * 8) @(posedge clk);
    if (n_got < 2) begin
      $display("FAIL 4_RANDOM n_got=%0d (need >=2 held words)", n_got);
      err = err + 1;
    end else begin
      $display("U1 CASE 4_RANDOM n_got=%0d e0=%h e1=%h", n_got, got[0], got[1]);
      if (got[0] !== W0) begin $display("FAIL 4 e0"); err = err + 1; end
    end

    if (err == 0)
      $display("UART_R2_U1_CONSERVATION_PASS words_dropped_required=0");
    else
      $display("UART_R2_U1_CONSERVATION_FAIL n=%0d", err);
    $finish;
  end
endmodule
