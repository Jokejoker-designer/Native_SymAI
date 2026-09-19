// tb_u20_followon_drop.sv — following UART word during long S_DROP after ACK.
// Exclusive U19 class: whole-DROP uart_flush destroys V-04/CLEAR already on RX.
// U20: one-cycle DROP flush; later bytes assemble; word parked by hold.
// Not BOARD_PASS.
`timescale 1ns/1ps

module tb_u20_followon_drop;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 1_000_000;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam logic [31:0] CLR_CMD = 32'h44524743;
  localparam logic [31:0] CLR_ACK = 32'hC1EA50A5;
  localparam logic [31:0] BEGINW  = 32'h00800001;

  logic clk, rst_n, in_valid, take, hold, uart_flush, cdc_rst_100;
  logic ui_req, ui_ack, ui_nack, pack_qsc, uart_mark, ack_valid, ack_ready;
  logic [31:0] in_data, ack_data;
  logic rx, w_valid, w_ready;
  logic [31:0] w_data;
  integer k, c, pass, fail;

  pack_debug_clear u_clr (
    .clk, .rst_n,
    .in_valid(w_valid), .in_data(w_data),
    .take, .hold, .uart_flush, .cdc_rst_100,
    .ui_req, .ui_ack, .ui_nack,
    .pack_quiescent(pack_qsc), .uart_rx_mark(uart_mark),
    .ack_valid, .ack_ready, .ack_data
  );

  uart_rx_word #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_rx (
    .clk, .rst_n, .rx,
    .w_valid, .w_ready, .w_data,
    .flush(uart_flush)
  );

  assign w_ready = take || (!hold && 1'b1);

  initial clk = 1'b0;
  always #5 clk = ~clk;

  task automatic uart_byte(input logic [7:0] b);
    begin
      rx <= 1'b0;
      repeat (DIV) @(posedge clk);
      for (k = 0; k < 8; k = k + 1) begin
        rx <= b[k];
        repeat (DIV) @(posedge clk);
      end
      rx <= 1'b1;
      repeat (DIV) @(posedge clk);
    end
  endtask

  task automatic send_word(input logic [31:0] w);
    begin
      uart_byte(w[7:0]); uart_byte(w[15:8]); uart_byte(w[23:16]); uart_byte(w[31:24]);
    end
  endtask

  initial begin
    pass = 0; fail = 0;
    rst_n = 0; in_valid = 0; in_data = 0; ack_ready = 0;
    pack_qsc = 1; uart_mark = 1; rx = 1;
    ui_ack = 0; ui_nack = 0;
    repeat (8) @(posedge clk);
    rst_n = 1;
    repeat (8) @(posedge clk);

    send_word(CLR_CMD);
    c = 0;
    while (c < 40000 && !ui_req) begin
      @(posedge clk);
      c = c + 1;
    end
    if (!ui_req) begin
      $display("FAIL no ui_req");
      $finish;
    end
    repeat (4) @(posedge clk);
    ui_ack <= 1;
    c = 0;
    while (c < 30000 && !ack_valid) begin
      @(posedge clk);
      c = c + 1;
    end
    if (!(ack_valid && ack_data == CLR_ACK)) begin
      $display("FAIL no ACK");
      $finish;
    end
    ack_ready <= 1;
    @(posedge clk);
    ack_ready <= 0;
    // Keep DROP alive (ui_ack stays 1). Skip first-cycle flush, then send BEGIN.
    repeat (8) @(posedge clk);
    if (uart_flush) begin
      fail = fail + 1;
      $display("FAIL flush still 1 after 8 DROP cycles");
    end else begin
      pass = pass + 1;
      $display("PASS flush=0 during long DROP");
    end
    send_word(BEGINW);
    repeat (DIV * 4) @(posedge clk);
    if (!w_valid || w_data !== BEGINW) begin
      fail = fail + 1;
      $display("FAIL parked BEGIN during DROP valid=%0b data=%08h", w_valid, w_data);
    end else begin
      pass = pass + 1;
      $display("PASS BEGIN parked during DROP hold");
    end
    ui_ack <= 0;
    c = 0;
    while (c < 70000 && hold) begin
      @(posedge clk);
      c = c + 1;
    end
    @(posedge clk);
    // IDLE raises w_ready; uart_rx may drop w_valid the same cycle. Data latch is enough.
    if (w_data === BEGINW) begin
      pass = pass + 1;
      $display("PASS BEGIN survived DROP (IDLE consume ok) valid=%0b", w_valid);
    end else begin
      fail = fail + 1;
      $display("FAIL BEGIN gone at IDLE valid=%0b data=%08h", w_valid, w_data);
    end
    if (fail == 0)
      $display("UART_R2_U20_FOLLOWON_DROP_XSIM_PASS pass=%0d", pass);
    else
      $display("UART_R2_U20_FOLLOWON_DROP_XSIM_FAIL fail=%0d pass=%0d", fail, pass);
    $finish;
  end
endmodule
