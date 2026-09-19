// tb_u11_rx_gap.sv — partial byte then MARK gap must drop bix; then CLEAR word emits.
`timescale 1ns/1ps

module tb_u11_rx_gap;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD = 115200;
  localparam int DIV = CLK_HZ / BAUD;
  localparam logic [31:0] CMD = 32'h44524743;

  logic clk, rst_n, rx, w_valid, w_ready, flush, idle, rx_sync, framing_error;
  logic [31:0] w_data;
  logic [31:0] seen;
  int pass, fail;

  always @(posedge clk) begin
    if (w_valid)
      seen <= w_data;
  end

  uart_rx_word #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_rx (
    .clk, .rst_n, .rx,
    .w_valid, .w_ready, .w_data,
    .flush, .idle, .rx_sync, .framing_error
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  task automatic bit_time;
    repeat (DIV) @(posedge clk);
  endtask

  task automatic send_byte(input logic [7:0] b);
    int i;
    begin
      rx = 1'b0;
      bit_time;
      for (i = 0; i < 8; i = i + 1) begin
        rx = b[i];
        bit_time;
      end
      rx = 1'b1;
      bit_time;
    end
  endtask

  initial begin
    pass = 0;
    fail = 0;
    rst_n = 1'b0;
    rx = 1'b1;
    w_ready = 1'b1;
    flush = 1'b0;
    repeat (8) @(posedge clk);
    rst_n = 1'b1;
    repeat (8) @(posedge clk);

    send_byte(8'hA5);
    repeat (DIV) @(posedge clk);
    if (u_rx.bix != 2'd1) begin
      $display("FAIL bix after one byte %0d", u_rx.bix);
      fail = fail + 1;
    end else begin
      $display("PASS partial bix=1");
      pass = pass + 1;
    end

    // 2 char-times of MARK.
    repeat (2 * 10 * DIV + 8) @(posedge clk);
    if (u_rx.bix != 2'd0 || u_rx.acc != 32'h0) begin
      $display("FAIL gap did not drop partial bix=%0d acc=%08h", u_rx.bix, u_rx.acc);
      fail = fail + 1;
    end else begin
      $display("PASS gap dropped partial");
      pass = pass + 1;
    end

    seen = 32'h0;
    send_byte(CMD[7:0]);
    send_byte(CMD[15:8]);
    send_byte(CMD[23:16]);
    send_byte(CMD[31:24]);
    repeat (2 * DIV) @(posedge clk);
    if (seen != CMD) begin
      $display("FAIL CLEAR word seen=%08h", seen);
      fail = fail + 1;
    end else begin
      $display("PASS CLEAR word after gap");
      pass = pass + 1;
    end

    if (fail == 0)
      $display("UART_R2_U11_RX_GAP_XSIM_PASS %0d (not BOARD_PASS)", pass);
    else
      $display("UART_R2_U11_RX_GAP_XSIM_FAIL fail=%0d", fail);
    $finish;
  end
endmodule
