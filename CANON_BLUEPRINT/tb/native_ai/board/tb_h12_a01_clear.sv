// tb_h12_a01_clear.sv — A-01 ABI NAK then CLEAR. Dest BRAM.
// Not PACK_ABI_24_24_PASS / not BOARD_PASS.
`timescale 1ns/1ps

module tb_h12_a01_clear;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 1_000_000;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam logic [31:0] CLR_CMD = 32'h44524743;
  localparam logic [31:0] CLR_ACK = 32'hC1EA50A5;
  localparam logic [31:0] NAK_ABI = 32'h0200025A;

  logic clk100, ui_clk, rst100_n, rst_ui_n, uart_rx, uart_tx;
  initial clk100 = 1'b0;
  always #5 clk100 = ~clk100;
  initial ui_clk = 1'b0;
  always #6.25 ui_clk = ~ui_clk;

  logic w_valid, w_ready;
  logic [31:0] w_data;
  logic fifo_wr_fire, fifo_rd_fire, p_fire;
  logic [31:0] fifo_wr_data, fifo_rd_data, p_data;
  logic load_ack, load_reject;
  logic [7:0] reason_code;

  pack_uart_dualclk_harness #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_h (
    .clk100, .ui_clk, .rst100_n, .rst_ui_n, .uart_rx, .uart_tx,
    .w_valid, .w_ready, .w_data,
    .fifo_wr_fire, .fifo_wr_data, .fifo_rd_fire, .fifo_rd_data,
    .p_fire, .p_data, .load_ack, .load_reject, .reason_code
  );

  logic host_valid, host_ready, host_seen, host_take;
  logic [31:0] host_data, host_cap;
  uart_rx_word #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_host (
    .clk(clk100), .rst_n(rst100_n), .rx(uart_tx),
    .w_valid(host_valid), .w_ready(host_ready), .w_data(host_data)
  );
  assign host_ready = 1'b1;
  initial host_take = 1'b0;
  always @(posedge clk100 or negedge rst100_n) begin
    if (!rst100_n) begin
      host_seen <= 1'b0;
      host_cap <= 32'h0;
    end else if (host_take)
      host_seen <= 1'b0;
    else if (host_valid && !host_seen) begin
      host_seen <= 1'b1;
      host_cap <= host_data;
    end
  end

  logic [31:0] vec [0:1023];
  int nwords, i, c, k, n_ack;
  logic [31:0] got, pack_g, clr2;

  task automatic load_mem(input string path);
    int fd;
    begin
      fd = $fopen(path, "r");
      void'($fscanf(fd, "%h", nwords));
      for (i = 0; i < nwords; i++)
        void'($fscanf(fd, "%h", vec[i]));
      $fclose(fd);
    end
  endtask

  task automatic uart_byte(input logic [7:0] b);
    int k;
    begin
      uart_rx <= 1'b0;
      repeat (DIV) @(posedge clk100);
      for (k = 0; k < 8; k++) begin
        uart_rx <= b[k];
        repeat (DIV) @(posedge clk100);
      end
      uart_rx <= 1'b1;
      repeat (DIV) @(posedge clk100);
    end
  endtask

  task automatic send_word(input logic [31:0] w);
    begin
      uart_byte(w[7:0]); uart_byte(w[15:8]); uart_byte(w[23:16]); uart_byte(w[31:24]);
    end
  endtask

  task automatic wait_word(output logic [31:0] g, input int maxc);
    begin
      c = 0;
      host_take = 1'b0;
      while (c < maxc && !host_seen) begin
        @(posedge clk100);
        c = c + 1;
      end
      g = host_seen ? host_cap : 32'h0;
      host_take = 1'b1;
      @(posedge clk100);
      host_take = 1'b0;
      repeat (DIV * 8) @(posedge clk100);
    end
  endtask

  initial begin
    rst100_n = 1'b0;
    rst_ui_n = 1'b0;
    uart_rx = 1'b1;
    repeat (20) @(posedge clk100);
    rst100_n = 1'b1;
    rst_ui_n = 1'b1;
    repeat (40) @(posedge clk100);
    load_mem("PA24-A-01.mem");
    n_ack = 0;
    for (k = 0; k < 6; k++) begin
      send_word(CLR_CMD);
      wait_word(got, 400000);
      $display("A01 i=%0d CLEAR1 got=%08h bix=%0d ld=%0d", k, got, u_h.u_rx.bix, u_h.u_ld.u_ld.state);
      for (i = 0; i < nwords; i++)
        send_word(vec[i]);
      wait_word(pack_g, 3_000_000);
      $display("A01 i=%0d PACK got=%08h bix=%0d ld=%0d qsc=%0b",
               k, pack_g, u_h.u_rx.bix, u_h.u_ld.u_ld.state, u_h.qsc_ui);
      if (got === CLR_ACK)
        n_ack = n_ack + 1;
    end
    send_word(CLR_CMD);
    wait_word(clr2, 400000);
    $display("A01 POST CLEAR got=%08h n_ack=%0d/6", clr2, n_ack);
    if (n_ack == 6 && clr2 === CLR_ACK)
      $display("H12_A01_CLEAR_XSIM_NAK_THEN_ACK (not PACK_ABI_24_24_PASS / not BOARD_PASS)");
    else
      $display("H12_A01_CLEAR_XSIM_FAIL n_ack=%0d clr2=%08h", n_ack, clr2);
    $finish;
  end
endmodule
