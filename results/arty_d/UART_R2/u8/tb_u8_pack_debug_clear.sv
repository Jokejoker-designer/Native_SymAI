// tb_u8_pack_debug_clear.sv — unit XSim for UART_R2_U8 pack_debug_clear.
// Not PACK_ABI_24_24_PASS. Not board.
`timescale 1ns/1ps

module tb_u8_pack_debug_clear;
  localparam logic [31:0] CMD  = 32'h44524743;
  localparam logic [31:0] ACK  = 32'hC1EA50A5;
  localparam logic [31:0] BUSY = 32'hC1EA50B5;

  logic clk, rst_n;
  initial clk = 1'b0;
  always #5 clk = ~clk;

  logic in_valid;
  logic [31:0] in_data;
  logic take, hold, uart_flush, cdc_rst_100;
  logic ui_req, ui_ack, ui_nack, debug_clear;
  logic pack_quiescent, uart_rx_mark;
  logic ack_valid, ack_ready;
  logic [31:0] ack_data;
  int c, pass, fail;
  int saw_overlap, saw_hold;

  pack_debug_clear u_clr (
    .clk, .rst_n,
    .in_valid, .in_data,
    .take, .hold, .uart_flush, .cdc_rst_100,
    .ui_req, .ui_ack, .ui_nack,
    .pack_quiescent, .uart_rx_mark,
    .ack_valid, .ack_ready, .ack_data
  );

  pack_clear_ui u_ui (
    .clk, .rst_n,
    .req(ui_req), .pack_quiescent(1'b1),
    .ack(ui_ack), .nack(ui_nack), .debug_clear
  );

  task automatic pulse_cmd;
    begin
      @(posedge clk);
      in_valid <= 1'b1;
      in_data <= CMD;
      @(posedge clk);
      in_valid <= 1'b0;
      in_data <= 32'h0;
    end
  endtask

  initial begin
    pass = 0;
    fail = 0;
    rst_n = 1'b0;
    in_valid = 1'b0;
    in_data = 32'h0;
    pack_quiescent = 1'b1;
    uart_rx_mark = 1'b1;
    ack_ready = 1'b0;
    repeat (8) @(posedge clk);
    rst_n = 1'b1;
    repeat (8) @(posedge clk);

    // T_HOLD: ACK must stay asserted past old 65535 timeout if ack_ready=0.
    pulse_cmd;
    c = 0;
    saw_overlap = 0;
    while (c < 30000 && !ack_valid) begin
      @(posedge clk);
      c = c + 1;
      if (cdc_rst_100 && debug_clear)
        saw_overlap = 1;
    end
    if (!ack_valid) begin
      $display("FAIL never reached S_ACK");
      fail = fail + 1;
    end else begin
      $display("REACHED_ACK cycles=%0d ack_data=%08h", c, ack_data);
      pass = pass + 1;
    end
    if (!saw_overlap) begin
      $display("FAIL no cdc_rst && debug_clear overlap before ACK");
      fail = fail + 1;
    end else begin
      $display("PASS CDC_UI_RESET_OVERLAP");
      pass = pass + 1;
    end

    // Settle registered flush/cdc from S_QUIET -> S_ACK.
    repeat (3) @(posedge clk);
    if (!(ack_valid && cdc_rst_100 && !uart_flush && ack_data == ACK)) begin
      $display("FAIL ACK window cdc_rst=%0b flush=%0b data=%08h",
               cdc_rst_100, uart_flush, ack_data);
      fail = fail + 1;
    end else begin
      $display("PASS ACK_WITH_CDC_RST_NO_FLUSH");
      pass = pass + 1;
    end

    saw_hold = 1;
    for (c = 0; c < 70000; c = c + 1) begin
      @(posedge clk);
      if (!ack_valid || !hold || !cdc_rst_100)
        saw_hold = 0;
    end
    if (!saw_hold) begin
      $display("FAIL dropped ACK/cdc_rst without ack_ready (old G2/timeout)");
      fail = fail + 1;
    end else begin
      $display("PASS HOLD_ACK_70000_WITHOUT_READY");
      pass = pass + 1;
    end

    ack_ready = 1'b1;
    @(posedge clk);
    ack_ready = 1'b0;
    c = 0;
    while (c < 70000 && hold) begin
      @(posedge clk);
      c = c + 1;
    end
    if (hold || ack_valid) begin
      $display("FAIL did not return IDLE after ack_ready hold=%0b ack_valid=%0b",
               hold, ack_valid);
      fail = fail + 1;
    end else begin
      $display("PASS IDLE_AFTER_ACK_READY cycles=%0d", c);
      pass = pass + 1;
    end

    // Second CLEAR must ACK (T2 class).
    pulse_cmd;
    c = 0;
    while (c < 30000 && !ack_valid) begin
      @(posedge clk);
      c = c + 1;
    end
    if (!ack_valid || ack_data != ACK) begin
      $display("FAIL second CLEAR ack_valid=%0b data=%08h", ack_valid, ack_data);
      fail = fail + 1;
    end else begin
      $display("PASS SECOND_CLEAR_ACK");
      pass = pass + 1;
    end
    ack_ready = 1'b1;
    @(posedge clk);
    ack_ready = 1'b0;
    c = 0;
    while (c < 70000 && hold) begin
      @(posedge clk);
      c = c + 1;
    end
    if (hold) begin
      $display("FAIL second CLEAR stuck hold");
      fail = fail + 1;
    end else begin
      $display("PASS SECOND_CLEAR_IDLE");
      pass = pass + 1;
    end

    // BUSY path: !quiescent, no cdc_rst, hold until ready.
    pack_quiescent = 1'b0;
    pulse_cmd;
    c = 0;
    while (c < 200 && !ack_valid) begin
      @(posedge clk);
      c = c + 1;
    end
    if (!ack_valid || ack_data != BUSY || cdc_rst_100) begin
      $display("FAIL BUSY path valid=%0b data=%08h cdc_rst=%0b",
               ack_valid, ack_data, cdc_rst_100);
      fail = fail + 1;
    end else begin
      $display("PASS BUSY_NO_CDC_RST");
      pass = pass + 1;
    end
    ack_ready = 1'b1;
    @(posedge clk);
    ack_ready = 1'b0;
    c = 0;
    while (c < 70000 && hold) begin
      @(posedge clk);
      c = c + 1;
    end
    if (hold) begin
      $display("FAIL BUSY stuck hold");
      fail = fail + 1;
    end else begin
      $display("PASS BUSY_IDLE");
      pass = pass + 1;
    end

    if (fail == 0)
      $display("UART_R2_U8_CLEAR_XSIM_PASS %0d (not BOARD_PASS)", pass);
    else
      $display("UART_R2_U8_CLEAR_XSIM_FAIL fail=%0d pass=%0d", fail, pass);
    $finish;
  end
endmodule
