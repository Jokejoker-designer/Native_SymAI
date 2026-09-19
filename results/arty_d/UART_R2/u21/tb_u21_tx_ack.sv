// tb_u21_tx_ack.sv — U14 TX must emit a following ACK after a QUIET-length flush.
`timescale 1ns/1ps

module tb_u21_tx_ack;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 1_000_000;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam int QUIET  = 20000;
  localparam logic [31:0] GOLD = 32'h010000A5;
  localparam logic [31:0] ACK  = 32'hC1EA50A5;

  logic clk, rst_n, w_valid, w_ready, flush, tx;
  logic [31:0] w_data;
  initial clk = 0;
  always #5 clk = ~clk;

  uart_tx_word #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_tx (
    .clk, .rst_n, .w_valid, .w_ready, .w_data, .flush, .tx
  );

  logic host_valid, host_ready, host_seen, host_take;
  logic [31:0] host_data, host_cap;
  uart_rx_word #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_rx (
    .clk, .rst_n, .rx(tx),
    .w_valid(host_valid), .w_ready(host_ready), .w_data(host_data)
  );
  assign host_ready = 1'b1;
  initial host_take = 1'b0;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      host_seen <= 1'b0;
      host_cap <= 32'h0;
    end else if (host_take)
      host_seen <= 1'b0;
    else if (host_valid && !host_seen) begin
      host_seen <= 1'b1;
      host_cap <= host_data;
    end
  end

  int c;
  bit mute;

  task automatic wait_cap(input logic [31:0] want, input string tag);
    begin
      c = 0;
      host_take = 1'b0;
      while (c < 400000 && !host_seen) begin
        @(posedge clk);
        c = c + 1;
      end
      mute = !host_seen;
      if (mute || host_cap !== want) begin
        $display("UART_R2_U21_TX_FAIL %s mute=%0d got=%08h", tag, mute, host_cap);
        $finish;
      end
      $display("PASS %s %08h", tag, host_cap);
      host_take = 1'b1;
      @(posedge clk);
      host_take = 1'b0;
    end
  endtask

  initial begin
    rst_n = 0; w_valid = 0; w_data = 0; flush = 0;
    repeat (8) @(posedge clk);
    rst_n = 1;
    repeat (8) @(posedge clk);

    w_data = GOLD;
    w_valid = 1;
    while (!(w_valid && w_ready)) @(posedge clk);
    @(posedge clk);
    w_valid = 0;
    wait_cap(GOLD, "GOLD");

    flush = 1;
    repeat (QUIET) @(posedge clk);
    flush = 0;
    @(posedge clk);

    w_data = ACK;
    w_valid = 1;
    c = 0;
    while (c < 400000 && !(w_valid && w_ready)) begin
      @(posedge clk);
      c = c + 1;
    end
    if (c >= 400000) begin
      $display("UART_R2_U21_TX_FAIL ACK never ready after quiet flush");
      $finish;
    end
    @(posedge clk);
    w_valid = 0;
    wait_cap(ACK, "ACK_AFTER_QUIET_FLUSH");
    $display("UART_R2_U21_TX_XSIM_PASS ACK after QUIET-length TX flush");
    $finish;
  end
endmodule
