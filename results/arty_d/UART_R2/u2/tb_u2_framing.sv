// tb_u2_framing.sv — UART_R2_U2 STOP validation.
// Malformed STOP must not become a data byte. No timeout.
`timescale 1ns/1ps

module tb_u2_framing;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD = 1_000_000;
  localparam int DIV = CLK_HZ / BAUD;
  localparam logic [31:0] W0 = 32'hA1B2C3D4;
  localparam logic [31:0] W1 = 32'h11223344;

  logic clk, rst_n, rx, w_valid, w_ready, ferr, idle;
  logic [31:0] w_data;
  uart_rx_word #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_rx (
    .clk, .rst_n, .rx, .w_valid, .w_ready, .w_data,
    .flush(1'b0), .idle, .rx_sync(), .framing_error(ferr)
  );
  assign w_ready = 1'b1;
  initial clk = 0;
  always #5 clk = ~clk;

  int n_got, n_ferr, err, bix_at_ferr;
  logic [31:0] got0;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      n_got <= 0;
      n_ferr <= 0;
    end else begin
      if (w_valid && w_ready) begin
        if (n_got == 0) got0 <= w_data;
        n_got <= n_got + 1;
      end
      if (ferr) begin
        n_ferr <= n_ferr + 1;
        bix_at_ferr <= u_rx.bix;
      end
    end
  end

  task automatic reset_all;
    rst_n = 0; rx = 1;
    repeat (8) @(posedge clk);
    rst_n = 1;
    repeat (8) @(posedge clk);
  endtask

  task automatic uart_byte_stop(input logic [7:0] b, input logic stopb);
    int k;
    rx <= 0;
    repeat (DIV) @(posedge clk);
    for (k = 0; k < 8; k++) begin
      rx <= b[k];
      repeat (DIV) @(posedge clk);
    end
    rx <= stopb;
    repeat (DIV) @(posedge clk);
    rx <= 1;
    repeat (DIV) @(posedge clk);
  endtask

  task automatic send_word(input logic [31:0] w);
    uart_byte_stop(w[7:0], 1);
    uart_byte_stop(w[15:8], 1);
    uart_byte_stop(w[23:16], 1);
    uart_byte_stop(w[31:24], 1);
  endtask

  initial begin
    err = 0;
    reset_all();
    send_word(W0);
    send_word(W1);
    repeat (DIV) @(posedge clk);
    if (n_got != 2 || got0 !== W0) begin
      $display("FAIL normal n=%0d e0=%h", n_got, got0); err++;
    end else $display("U2 CASE 1_NORMAL_8N1 n=%0d", n_got);

    reset_all();
    uart_byte_stop(8'h5A, 1'b0);
    repeat (DIV * 2) @(posedge clk);
    if (n_ferr == 0) begin $display("FAIL no framing_error"); err++; end
    if (n_got != 0) begin $display("FAIL silent data on bad STOP"); err++; end
    if (u_rx.bix != 0) begin $display("FAIL bix advanced %0d", u_rx.bix); err++; end
    $display("U2 CASE 2_STOP_LOW ferr=%0d n_got=%0d bix=%0d", n_ferr, n_got, u_rx.bix);

    send_word(W0);
    repeat (DIV) @(posedge clk);
    if (n_got != 1 || got0 !== W0) begin
      $display("FAIL recover after bad STOP n=%0d", n_got); err++;
    end else $display("U2 CASE 3_RECOVER_AFTER_BAD n=%0d", n_got);

    reset_all();
    rx <= 0;
    repeat (DIV * 20) @(posedge clk);
    rx <= 1;
    repeat (DIV * 4) @(posedge clk);
    if (n_got != 0) begin $display("FAIL BREAK became data"); err++; end
    $display("U2 CASE 4_BREAK n_got=%0d ferr=%0d", n_got, n_ferr);

    reset_all();
    uart_byte_stop(8'h11, 0);
    uart_byte_stop(8'h11, 0);
    send_word(W1);
    repeat (DIV) @(posedge clk);
    if (n_got != 1 || got0 !== W1) begin
      $display("FAIL repeated malformed then valid n=%0d e0=%h", n_got, got0); err++;
    end else $display("U2 CASE 5_REPEATED_THEN_VALID n=%0d", n_got);

    reset_all();
    rx <= 0;
    repeat (3) @(posedge clk);
    rx <= 1;
    repeat (DIV * 2) @(posedge clk);
    if (n_got != 0) begin $display("FAIL short LOW glitch became data"); err++; end
    send_word(W0);
    repeat (DIV) @(posedge clk);
    if (n_got != 1 || got0 !== W0) begin
      $display("FAIL after glitch n=%0d e0=%h", n_got, got0); err++;
    end else $display("U2 CASE 6_SHORT_LOW_GLITCH n=%0d", n_got);

    if (err == 0) $display("UART_R2_U2_FRAMING_PASS");
    else $display("UART_R2_U2_FRAMING_FAIL n=%0d", err);
    $finish;
  end
endmodule
