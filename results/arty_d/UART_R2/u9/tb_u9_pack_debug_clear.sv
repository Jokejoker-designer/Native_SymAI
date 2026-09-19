// tb_u9_pack_debug_clear.sv — unit XSim for UART_R2_U9.
// U8 ACK-hold + cdc_rst through S_DROP + word_cdc32 REL_N=16 holdoff.
// Not PACK_ABI_24_24_PASS. Not BOARD_PASS.
`timescale 1ns/1ps

module tb_u9_pack_debug_clear;
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
  int saw_overlap, saw_hold, saw_drop_rst;

  logic cdc_a_rst_n, cdc_b_rst_n;
  logic a_valid, a_ready, b_valid, b_ready;
  logic [31:0] a_data, b_data;
  logic a_idle, b_idle;
  int holdoff_ok, leak;

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

  word_cdc32 u_cdc (
    .a_clk(clk), .a_rst_n(cdc_a_rst_n),
    .a_valid, .a_ready, .a_data,
    .b_clk(clk), .b_rst_n(cdc_b_rst_n),
    .b_valid, .b_ready, .b_data,
    .a_idle, .b_idle
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
    cdc_a_rst_n = 1'b0;
    cdc_b_rst_n = 1'b0;
    a_valid = 1'b0;
    a_data = 32'h0;
    b_ready = 1'b1;
    repeat (8) @(posedge clk);
    rst_n = 1'b1;
    repeat (8) @(posedge clk);

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
      $display("FAIL dropped ACK/cdc_rst without ack_ready");
      fail = fail + 1;
    end else begin
      $display("PASS HOLD_ACK_70000_WITHOUT_READY");
      pass = pass + 1;
    end

    ack_ready = 1'b1;
    @(posedge clk);
    ack_ready = 1'b0;
    c = 0;
    saw_drop_rst = 0;
    while (c < 70000 && hold) begin
      @(posedge clk);
      c = c + 1;
      if (!ack_valid && hold && cdc_rst_100)
        saw_drop_rst = 1;
    end
    if (!saw_drop_rst) begin
      $display("FAIL S_DROP without cdc_rst (U8 release-at-DROP)");
      fail = fail + 1;
    end else begin
      $display("PASS CDC_RST_THROUGH_DROP");
      pass = pass + 1;
    end
    if (hold || ack_valid) begin
      $display("FAIL did not return IDLE after ack_ready hold=%0b ack_valid=%0b",
               hold, ack_valid);
      fail = fail + 1;
    end else begin
      $display("PASS IDLE_AFTER_ACK_READY cycles=%0d", c);
      pass = pass + 1;
    end
    @(posedge clk);
    if (cdc_rst_100) begin
      $display("FAIL cdc_rst stuck after IDLE");
      fail = fail + 1;
    end else begin
      $display("PASS CDC_RST_CLEAR_AT_IDLE");
      pass = pass + 1;
    end

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

    // word_cdc32: 16-cycle holdoff after each-side rst release.
    a_valid = 1'b1;
    a_data = 32'hA5A5_A5A5;
    b_ready = 1'b1;
    @(posedge clk);
    cdc_a_rst_n = 1'b1;
    cdc_b_rst_n = 1'b1;
    holdoff_ok = 0;
    leak = 0;
    c = 0;
    begin : holdoff_wait
      forever begin
        @(posedge clk);
        c = c + 1;
        if (b_valid)
          leak = 1;
        if (a_ready) begin
          holdoff_ok = (c == 16) && !leak && !b_valid;
          disable holdoff_wait;
        end
        if (c > 32)
          disable holdoff_wait;
      end
    end
    if (!holdoff_ok) begin
      $display("FAIL CDC holdoff first a_ready at cycle %0d leak=%0d b_valid=%0b",
               c, leak, b_valid);
      fail = fail + 1;
    end else begin
      $display("PASS CDC_HOLDOFF_16 first_ready=%0d", c);
      pass = pass + 1;
    end
    c = 0;
    while (c < 64 && !b_valid) begin
      @(posedge clk);
      c = c + 1;
    end
    if (!b_valid || b_data != 32'hA5A5_A5A5 || leak) begin
      $display("FAIL CDC post-holdoff b_valid=%0b data=%08h leak=%0d cycles=%0d",
               b_valid, b_data, leak, c);
      fail = fail + 1;
    end else begin
      $display("PASS CDC_TRANSFER_AFTER_HOLDOFF cycles=%0d", c);
      pass = pass + 1;
    end

    if (fail == 0)
      $display("UART_R2_U9_CLEAR_XSIM_PASS %0d (not BOARD_PASS)", pass);
    else
      $display("UART_R2_U9_CLEAR_XSIM_FAIL fail=%0d pass=%0d", fail, pass);
    $finish;
  end
endmodule
