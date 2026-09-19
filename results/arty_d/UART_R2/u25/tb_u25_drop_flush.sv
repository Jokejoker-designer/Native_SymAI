// tb_u20_drop_flush.sv — U20 CLEAR flush lifecycle.
// S_CDC|S_QUIET flush=1; S_ACK flush=0 cdc_rst=1;
// S_DROP: one cycle flush=1 then flush=0 while still in DROP; cdc_rst=0.
// Not BOARD_PASS.
`timescale 1ns/1ps

module tb_u20_drop_flush;
  logic clk, rst_n, in_valid, take, hold, uart_flush, cdc_rst_100;
  logic ui_req, ui_ack, ui_nack, pack_qsc, uart_mark, ack_valid, ack_ready;
  logic [31:0] in_data, ack_data;
  integer c, pass, fail;
  integer drop_flush_hi, drop_flush_lo;

  pack_debug_clear u_clr (
    .clk, .rst_n,
    .in_valid, .in_data, .take, .hold, .uart_flush, .cdc_rst_100,
    .ui_req, .ui_ack, .ui_nack,
    .pack_quiescent(pack_qsc), .uart_rx_mark(uart_mark),
    .ack_valid, .ack_ready, .ack_data
  );

  pack_clear_ui u_ui (
    .clk, .rst_n, .req(ui_req), .pack_quiescent(pack_qsc),
    .ack(ui_ack), .nack(ui_nack), .debug_clear()
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  task automatic tpass(input string s);
    begin pass = pass + 1; $display("PASS %s", s); end
  endtask
  task automatic tfail(input string s);
    begin fail = fail + 1; $display("FAIL %s", s); end
  endtask

  initial begin
    pass = 0; fail = 0;
    rst_n = 0; in_valid = 0; in_data = 0; ack_ready = 0;
    pack_qsc = 1; uart_mark = 1;
    drop_flush_hi = 0; drop_flush_lo = 0;
    repeat (8) @(posedge clk);
    rst_n = 1;
    repeat (8) @(posedge clk);
    @(posedge clk);
    in_data <= 32'h44524743;
    in_valid <= 1;
    @(posedge clk);
    in_valid <= 0;

    c = 0;
    while (c < 30000 && !ack_valid) begin
      @(posedge clk);
      c = c + 1;
      if (u_clr.st == 4'd3) begin
        @(posedge clk);
        if (!(cdc_rst_100 && uart_flush)) tfail("S_CDC rst/flush");
        else tpass("S_CDC cdc_rst=1 flush=1");
      end
      if (u_clr.st == 4'd4 && c == 100) begin
        if (!(cdc_rst_100 && uart_flush)) tfail("S_QUIET rst/flush");
        else tpass("S_QUIET cdc_rst=1 flush=1");
      end
    end
    @(posedge clk);
    if (!(ack_valid && cdc_rst_100 && !uart_flush && ack_data == 32'hC1EA50A5))
      tfail($sformatf("S_ACK window rst=%0b flush=%0b data=%08h", cdc_rst_100, uart_flush, ack_data));
    else
      tpass("S_ACK cdc_rst=1 flush=0 (ACK must not be flushed)");
    ack_ready <= 1;
    @(posedge clk);
    ack_ready <= 0;
    force u_clr.ui_ack = 1'b1;
    force u_clr.ui_nack = 1'b0;
    for (c = 0; c < 16; c = c + 1) begin
      @(posedge clk);
      if (c == 1 && cdc_rst_100) tfail("S_DROP cdc_rst still 1");
      if (uart_flush) drop_flush_hi = drop_flush_hi + 1;
      else drop_flush_lo = drop_flush_lo + 1;
    end
    if (!cdc_rst_100) tpass("S_DROP cdc_rst=0");
    if (drop_flush_hi < 1) tfail("S_DROP never pulsed flush");
    else tpass("S_DROP flush pulse seen");
    if (drop_flush_lo < 1) tfail("S_DROP flush stuck 1 (U19 class)");
    else tpass("S_DROP flush returns 0 while DROP held");
    release u_clr.ui_ack;
    release u_clr.ui_nack;
    c = 0;
    while (c < 70000 && hold) begin
      @(posedge clk);
      c = c + 1;
    end
    @(posedge clk);
    if (uart_flush || cdc_rst_100 || hold) tfail("IDLE leftover flush/rst/hold");
    else tpass("IDLE flush=0 cdc_rst=0 hold=0");
    if (fail == 0)
      $display("UART_R2_U20_DROP_FLUSH_XSIM_PASS pass=%0d", pass);
    else
      $display("UART_R2_U20_DROP_FLUSH_XSIM_FAIL fail=%0d pass=%0d", fail, pass);
    $finish;
  end
endmodule
