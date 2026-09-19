// tb_u15_zero_word.sv — GOLD through TX CDC then CLEAR.
// U8: extra 32'h0 then ACK. U15: ACK only. Not BOARD_PASS.
`timescale 1ns/1ps

module tb_u15_zero_word;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD = 115200;
  localparam int DIV = CLK_HZ / BAUD;
  localparam logic [31:0] CMD = 32'h44524743;
  localparam logic [31:0] ACK = 32'hC1EA50A5;
  localparam logic [31:0] GOLD = 32'h010000A5;

  int pass, fail;
  logic clk, ui_clk, rst_n, rst_ui_n;

  logic in_valid, take, hold, uart_flush, cdc_rst_100;
  logic ui_req, ui_ack, ui_nack, debug_clear;
  logic pack_qsc, uart_mark, ack_valid, ack_ready;
  logic [31:0] in_data, ack_data;

  pack_debug_clear u_clr (
    .clk, .rst_n,
    .in_valid, .in_data, .take, .hold, .uart_flush, .cdc_rst_100,
    .ui_req, .ui_ack, .ui_nack,
    .pack_quiescent(pack_qsc), .uart_rx_mark(uart_mark),
    .ack_valid, .ack_ready, .ack_data
  );
  pack_clear_ui u_ui (
    .clk(ui_clk), .rst_n(rst_ui_n), .req(ui_req), .pack_quiescent(pack_qsc),
    .ack(ui_ack), .nack(ui_nack), .debug_clear
  );

  logic rst100_pack_n, rst_ui_pack_n;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) rst100_pack_n <= 1'b0;
    else rst100_pack_n <= ~cdc_rst_100;
  end
  always_ff @(posedge ui_clk or negedge rst_ui_n) begin
    if (!rst_ui_n) rst_ui_pack_n <= 1'b0;
    else rst_ui_pack_n <= ~debug_clear;
  end

  logic st_valid_ui, st_ready_ui, st_valid_100, st_ready_100;
  logic [31:0] st_data_ui, st_data_100;
  logic tx_a_idle, tx_b_idle;
  word_cdc32 u_cdc_tx (
    .a_clk(ui_clk), .a_rst_n(rst_ui_pack_n),
    .a_valid(st_valid_ui), .a_ready(st_ready_ui), .a_data(st_data_ui),
    .b_clk(clk), .b_rst_n(rst100_pack_n),
    .b_valid(st_valid_100), .b_ready(st_ready_100), .b_data(st_data_100),
    .a_idle(tx_a_idle), .b_idle(tx_b_idle)
  );

  logic tx, mux_valid, mux_ready;
  logic [31:0] mux_data;
  assign mux_valid = ack_valid | st_valid_100;
  assign mux_data  = ack_valid ? ack_data : st_data_100;
  assign ack_ready = mux_ready && !uart_flush;
  assign st_ready_100 = (!ack_valid) && mux_ready;

  uart_tx_word #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_tx (
    .clk, .rst_n,
    .w_valid(mux_valid), .w_ready(mux_ready), .w_data(mux_data),
    .flush(uart_flush), .tx
  );

  initial clk = 1'b0;
  initial ui_clk = 1'b0;
  always #5 clk = ~clk;
  always #7 ui_clk = ~ui_clk;

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

  integer nbyte, nw, c;
  logic [31:0] tw, w0, w1;
  logic saw_extra;

  initial begin
    pass = 0;
    fail = 0;
    rst_n = 1'b0;
    rst_ui_n = 1'b0;
    in_valid = 1'b0;
    in_data = 32'h0;
    pack_qsc = 1'b1;
    uart_mark = 1'b1;
    st_valid_ui = 1'b0;
    st_data_ui = 32'h0;
    repeat (8) @(posedge clk);
    rst_n = 1'b1;
    rst_ui_n = 1'b1;
    repeat (16) @(posedge clk);

    // T_CDC: A reset with req odd while B live samples hold=0.
    @(posedge ui_clk);
    st_data_ui = GOLD;
    st_valid_ui = 1'b1;
    @(posedge ui_clk);
    while (!(st_valid_ui && st_ready_ui)) @(posedge ui_clk);
    @(posedge ui_clk);
    st_valid_ui = 1'b0;
    recv_tx_word(80 * DIV, nbyte, tw);
    if (nbyte != 4 || tw != GOLD)
      tfail($sformatf("T_GOLD nbyte=%0d tw=%08h", nbyte, tw));
    else
      tpass("T_GOLD on UART");
    repeat (8) @(posedge clk);

    in_valid = 1'b1;
    in_data = CMD;
    @(posedge clk);
    in_valid = 1'b0;
    in_data = 32'h0;

    nw = 0;
    w0 = 32'h0;
    w1 = 32'h0;
    saw_extra = 1'b0;
    repeat (2) begin
      recv_tx_word(40000 + 80 * DIV, nbyte, tw);
      if (nbyte == 4) begin
        if (nw == 0) w0 = tw;
        else w1 = tw;
        nw = nw + 1;
      end
    end
    $display("T11 words=%0d w0=%08h w1=%08h", nw, w0, w1);
    if (nw >= 1 && w0 == 32'h0) begin
      tfail("T11 leading zero word before ACK");
      saw_extra = 1'b1;
    end
    if (nw == 1 && w0 == ACK)
      tpass("T11 CLEAR ACK only after GOLD");
    else if (nw == 2 && w1 == ACK && w0 == 32'h0)
      tfail("T11 0 then ACK (U8/U14 board class)");
    else if (nw >= 1 && w0 == ACK)
      tpass($sformatf("T11 first UART word is ACK extra=%0d", nw - 1));
    else
      tfail($sformatf("T11 unexpected nw=%0d w0=%08h w1=%08h", nw, w0, w1));

    if (cdc_rst_100)
      tfail("T11 cdc_rst still 1 after ACK window");
    c = 0;
    while (c < 70000 && hold) begin
      @(posedge clk);
      c = c + 1;
    end
    if (cdc_rst_100)
      tfail("T11 cdc_rst after DROP");
    else
      tpass("T11 S_DROP cdc_rst=0");

    if (fail == 0)
      $display("UART_R2_U15_ZERO_WORD_XSIM_PASS pass=%0d (not BOARD_PASS)", pass);
    else
      $display("UART_R2_U15_ZERO_WORD_XSIM_FAIL fail=%0d pass=%0d", fail, pass);
    $finish;
  end
endmodule
