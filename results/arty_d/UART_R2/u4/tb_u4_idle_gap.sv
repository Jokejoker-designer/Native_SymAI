// tb_u4_idle_gap.sv — UART_R2_U4 measure idle-gap vs leftover. NO timeout RTL.
// Distinguishes EXTRA_BYTE_WITH_CONTINUOUS_STREAM vs PARTIAL_WORD_WITH_IDLE_GAP.
// XSim != board. Timeout is NOT claimed as an H19 fix.
`timescale 1ns/1ps

module tb_u4_idle_gap;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 1_000_000;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam logic [31:0] W0 = 32'hA1B2C3D4;
  localparam logic [31:0] W1 = 32'h11223344;

  logic clk, rst_n, rx, w_valid, w_ready, ferr;
  logic [31:0] w_data;
  uart_rx_word #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_rx (
    .clk, .rst_n, .rx, .w_valid, .w_ready, .w_data,
    .flush(1'b0), .idle(), .rx_sync(), .framing_error(ferr)
  );
  assign w_ready = 1'b1;
  initial clk = 1'b0;
  always #5 clk = ~clk;

  int n_acc, fail;
  logic [31:0] accepted [0:7];
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) n_acc <= 0;
    else if (w_valid && w_ready) begin
      accepted[n_acc] <= w_data;
      n_acc <= n_acc + 1;
    end
  end

  task automatic reset_all;
    begin
      rst_n = 1'b0; rx = 1'b1;
      repeat (8) @(posedge clk);
      rst_n = 1'b1;
      repeat (8) @(posedge clk);
    end
  endtask

  task automatic uart_byte(input logic [7:0] b);
    int k;
    begin
      rx <= 1'b0;
      repeat (DIV) @(posedge clk);
      for (k = 0; k < 8; k++) begin
        rx <= b[k];
        repeat (DIV) @(posedge clk);
      end
      rx <= 1'b1;
      repeat (DIV) @(posedge clk);
    end
  endtask

  task automatic idle_bits(input int n);
    repeat (n * DIV) @(posedge clk);
  endtask

  task automatic send_word_paced(input logic [31:0] w, input int gap_bits);
    begin
      uart_byte(w[7:0]); idle_bits(gap_bits);
      uart_byte(w[15:8]); idle_bits(gap_bits);
      uart_byte(w[23:16]); idle_bits(gap_bits);
      uart_byte(w[31:24]);
    end
  endtask

  initial begin
    $display("UART_R2_U4_IDLE_GAP_XSIM start");
    fail = 0;

    // 1. extra byte + no idle gap: leftover shifts the next word
    reset_all();
    uart_byte(8'h00);
    send_word_paced(W0, 0);
    idle_bits(4);
    $display("U4 CONT extra+burst n=%0d w0=%08h bix=%0d (leftover expected)", n_acc, accepted[0], u_rx.bix);
    if (n_acc == 1 && accepted[0] === W0)
      $display("U4 CHECK_INFO CONT unexpectedly aligned (no leftover effect)");
    else
      $display("U4 CHECK_OK EXTRA_BYTE_WITH_CONTINUOUS_STREAM shifted_or_partial");

    // 2. extra byte + legal command idle gap (50 bit-times ~ 0.5 ms at 1 Mbaud)
    reset_all();
    uart_byte(8'h00);
    idle_bits(50);
    send_word_paced(W1, 0);
    idle_bits(4);
    $display("U4 GAP extra+50bit then W1 n=%0d w0=%08h bix=%0d", n_acc, accepted[0], u_rx.bix);
    if (n_acc == 1 && accepted[0] === W1)
      $display("U4 CHECK_INFO GAP recovered without timeout (would mean leftover aged out — unexpected)");
    else
      $display("U4 CHECK_OK PARTIAL_WORD_WITH_IDLE_GAP leftover STILL PRESENT (timeout not justified from this class)");

    // 3. valid normal burst
    reset_all();
    send_word_paced(W0, 0);
    send_word_paced(W1, 0);
    idle_bits(4);
    if (n_acc != 2 || accepted[0] !== W0 || accepted[1] !== W1) begin
      $display("U4 CHECK_FAIL BURST");
      fail = fail + 1;
    end else $display("U4 CHECK_OK VALID_BURST");

    // 4. valid paced mode: 20 bit-times between bytes inside a word
    reset_all();
    send_word_paced(W0, 20);
    idle_bits(4);
    if (n_acc != 1 || accepted[0] !== W0) begin
      $display("U4 CHECK_FAIL PACED");
      fail = fail + 1;
    end else $display("U4 CHECK_OK VALID_PACED_20BIT");

    // 5. largest observed legitimate inter-byte delay analogue: 50 bit-times (H10 0.5 ms @ 1 Mbaud)
    reset_all();
    send_word_paced(W0, 50);
    idle_bits(4);
    if (n_acc != 1 || accepted[0] !== W0) begin
      $display("U4 CHECK_FAIL LARGE_LEGAL_GAP");
      fail = fail + 1;
    end else $display("U4 CHECK_OK LARGEST_LEGAL_INTERBYTE_50BIT");

    // 6. timeout boundary is NOT implemented; ±1 symbol would require a timeout.
    $display("U4 TIMEOUT_RTL=NO  H10_paced=0.5ms/byte  115200_char~86.8us  Windows_gap_often_ms");
    $display("U4 SAFE_SEPARATION=NO  TIMEOUT_NOT_JUSTIFIED");

    if (fail == 0)
      $display("UART_R2_U4_IDLE_GAP_XSIM_PASS measurement_only timeout_not_added");
    else
      $display("UART_R2_U4_IDLE_GAP_XSIM_FAIL fail=%0d", fail);
    $finish;
  end
endmodule
