// tb_u14_handshake.sv — decisive U12/U13 n=0 repro vs U14.
// Product mux: ack_ready = tx_ready && !uart_flush.
// Not BOARD_PASS.
`timescale 1ns/1ps

module tb_u14_handshake;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD = 115200;
  localparam int DIV = CLK_HZ / BAUD;
  localparam logic [31:0] CMD = 32'h44524743;
  localparam logic [31:0] ACK = 32'hC1EA50A5;

  int pass, fail;
  logic clk, rst_n;

  logic tx_valid, tx_ready, tx_flush, tx;
  logic [31:0] tx_data;
  uart_tx_word #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_tx (
    .clk, .rst_n,
    .w_valid(tx_valid), .w_ready(tx_ready), .w_data(tx_data),
    .flush(tx_flush), .tx
  );

  logic in_valid, take, hold, uart_flush, cdc_rst_100;
  logic ui_req, ui_ack, ui_nack, debug_clear;
  logic pack_qsc, uart_mark, ack_valid, ack_ready;
  logic [31:0] in_data, ack_data;
  logic mux_en;
  logic tx_flush_drv, tx_valid_drv, ack_ready_drv;
  logic [31:0] tx_data_drv;

  pack_debug_clear u_clr (
    .clk, .rst_n,
    .in_valid, .in_data, .take, .hold, .uart_flush, .cdc_rst_100,
    .ui_req, .ui_ack, .ui_nack,
    .pack_quiescent(pack_qsc), .uart_rx_mark(uart_mark),
    .ack_valid, .ack_ready, .ack_data
  );
  pack_clear_ui u_ui (
    .clk, .rst_n, .req(ui_req), .pack_quiescent(pack_qsc),
    .ack(ui_ack), .nack(ui_nack), .debug_clear
  );

  assign tx_flush = mux_en ? uart_flush : tx_flush_drv;
  assign tx_valid = mux_en ? ack_valid : tx_valid_drv;
  assign tx_data  = mux_en ? ack_data  : tx_data_drv;
  assign ack_ready = mux_en ? (tx_ready && !uart_flush) : ack_ready_drv;

  initial clk = 1'b0;
  always #5 clk = ~clk;

  task automatic tpass(input string s);
    begin
      $display("PASS %s", s);
      pass = pass + 1;
    end
  endtask
  task automatic tfail(input string s);
    begin
      $display("FAIL %s", s);
      fail = fail + 1;
    end
  endtask

  task automatic recv_tx_word(input int maxc, output int nbyte, output logic [31:0] w);
    int c, bi, by;
    logic [7:0] b;
    begin
      nbyte = 0;
      w = 32'h0;
      c = 0;
      while (c < maxc && tx === 1'b1) begin
        @(posedge clk);
        c = c + 1;
      end
      if (tx !== 1'b0) begin
        nbyte = 0;
        disable recv_tx_word;
      end
      for (by = 0; by < 4; by = by + 1) begin
        if (by != 0) begin
          c = 0;
          while (c < (20 * DIV) && tx === 1'b1) begin
            @(posedge clk);
            c = c + 1;
          end
          if (tx !== 1'b0) begin
            nbyte = by;
            disable recv_tx_word;
          end
        end
        repeat (DIV / 2) @(posedge clk);
        if (tx !== 1'b0) begin
          nbyte = by;
          disable recv_tx_word;
        end
        b = 8'h0;
        for (bi = 0; bi < 8; bi = bi + 1) begin
          repeat (DIV) @(posedge clk);
          b[bi] = tx;
        end
        repeat (DIV) @(posedge clk);
        w = {b, w[31:8]};
        nbyte = by + 1;
      end
    end
  endtask

  integer c, nbyte;
  logic [31:0] tw;
  logic saw_ready_during_flush;

  initial begin
    pass = 0;
    fail = 0;
    rst_n = 1'b0;
    mux_en = 1'b0;
    tx_flush_drv = 1'b0;
    tx_valid_drv = 1'b0;
    tx_data_drv = 32'h0;
    ack_ready_drv = 1'b0;
    in_valid = 1'b0;
    in_data = 32'h0;
    pack_qsc = 1'b1;
    uart_mark = 1'b1;
    repeat (8) @(posedge clk);
    rst_n = 1'b1;
    repeat (8) @(posedge clk);

    // T3: idle flush must not handshake.
    tx_flush_drv = 1'b1;
    tx_valid_drv = 1'b1;
    tx_data_drv = ACK;
    saw_ready_during_flush = 1'b0;
    repeat (8) @(posedge clk);
    if (tx_ready)
      saw_ready_during_flush = 1'b1;
    if (saw_ready_during_flush || tx !== 1'b1 || u_tx.st != 2'd0)
      tfail($sformatf("T3 flush ready=%0b tx=%0b st=%0d", tx_ready, tx, u_tx.st));
    else
      tpass("T3 idle flush w_ready=0 no frame");
    tx_flush_drv = 1'b0;
    c = 0;
    while (c < 8 && !(tx_valid_drv && tx_ready)) begin
      @(posedge clk);
      c = c + 1;
    end
    if (!(tx_valid_drv && tx_ready))
      tfail("T3 after flush drop never ready");
    else
      tpass("T3 ready after flush drop");
    @(posedge clk);
    tx_valid_drv = 1'b0;
    recv_tx_word(80 * DIV, nbyte, tw);
    if (nbyte != 4 || tw != ACK)
      tfail($sformatf("T3 word nbyte=%0d tw=%08h", nbyte, tw));
    else
      tpass("T3 word after idle flush");

    // T4 START not aborted, then pending flush, then new word.
    tx_flush_drv = 1'b0;
    @(posedge clk);
    tx_data_drv = 32'h00000011;
    tx_valid_drv = 1'b1;
    @(posedge clk);
    while (!(tx_valid_drv && tx_ready)) @(posedge clk);
    @(posedge clk);
    tx_valid_drv = 1'b0;
    c = 0;
    while (c < (2 * DIV) && u_tx.st != 2'd1) begin
      @(posedge clk);
      c = c + 1;
    end
    tx_flush_drv = 1'b1;
    @(posedge clk);
    if (u_tx.st == 2'd0)
      tfail("T4 START aborted");
    else
      tpass("T4 START not aborted");
    c = 0;
    while (c < (50 * DIV) && u_tx.st != 2'd0) begin
      @(posedge clk);
      c = c + 1;
    end
    if (tx_ready)
      tfail("T4 IDLE+flush w_ready=1");
    else
      tpass("T4 pending flush holds ready=0");
    tx_flush_drv = 1'b0;
    tx_data_drv = 32'h00000022;
    tx_valid_drv = 1'b1;
    c = 0;
    while (c < 16 && !(tx_valid_drv && tx_ready)) begin
      @(posedge clk);
      c = c + 1;
    end
    @(posedge clk);
    tx_valid_drv = 1'b0;
    recv_tx_word(80 * DIV, nbyte, tw);
    if (nbyte != 4 || tw != 32'h00000022)
      tfail($sformatf("T4 next word nbyte=%0d tw=%08h", nbyte, tw));
    else
      tpass("T4 next word after non-abort flush");

    // T10 product mux: CLEAR ACK must appear on UART, not fake-handshake.
    mux_en = 1'b1;
    pack_qsc = 1'b1;
    uart_mark = 1'b1;
    @(posedge clk);
    in_valid = 1'b1;
    in_data = CMD;
    @(posedge clk);
    in_valid = 1'b0;
    in_data = 32'h0;
    recv_tx_word(30000 + 80 * DIV, nbyte, tw);
    if (nbyte != 4 || tw != ACK)
      tfail($sformatf("T10 product mux ACK nbyte=%0d tw=%08h ack_valid=%0b", nbyte, tw, ack_valid));
    else
      tpass("T10 CLEAR ACK on UART via product mux");

    if (fail == 0)
      $display("UART_R2_U14_HANDSHAKE_XSIM_PASS pass=%0d (not BOARD_PASS)", pass);
    else
      $display("UART_R2_U14_HANDSHAKE_XSIM_FAIL fail=%0d pass=%0d", fail, pass);
    $finish;
  end
endmodule
