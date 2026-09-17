// tb_h16_hold_overlap.sv — H16 arm: start A-01 as soon as CLEAR reaches S_ACK
// (ACK word accepted by TX, host may still be shifting ACK). Tests BEGIN drop
// while clr_hold=1 → MAGIC as first pack opcode → R_UNSUP 0200075a.
// BAUD=115200. dest=mig_ui_bram. Not PACK_ABI_24_24_PASS / not BOARD_PASS.
`timescale 1ns/1ps

module tb_h16_hold_overlap;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 115_200;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam logic [31:0] CLR_CMD = 32'h44524743;
  localparam logic [31:0] CLR_ACK = 32'hC1EA50A5;
  localparam logic [31:0] NAK_ABI = 32'h0200025A;
  localparam logic [31:0] UNSUP   = 32'h0200075A;
  localparam logic [31:0] MAG     = 32'h0200015A;
  localparam logic [31:0] MAGIC   = 32'h3149414E;

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

  integer n_p;
  logic [31:0] first_p;
  always @(posedge ui_clk or negedge rst_ui_n) begin
    if (!rst_ui_n) begin
      n_p = 0;
      first_p <= 32'h0;
    end else if (p_fire) begin
      if (n_p == 0)
        first_p <= p_data;
      n_p = n_p + 1;
    end
  end

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
  int nwords, i, c, n_drop;
  logic [31:0] pack_g, host_words [0:7];
  int n_host;
  bit mute;
  logic hold_at_a01;
  logic [3:0] st_at_a01;

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

  task automatic wait_word(output logic [31:0] g, input int maxc, output bit mu);
    begin
      c = 0;
      host_take = 1'b0;
      while (c < maxc && !host_seen) begin
        @(posedge clk100);
        c = c + 1;
      end
      mu = !host_seen;
      g = host_seen ? host_cap : 32'h0;
      host_take = 1'b1;
      @(posedge clk100);
      host_take = 1'b0;
    end
  endtask

  always @(posedge clk100 or negedge rst100_n) begin
    if (!rst100_n)
      n_drop <= 0;
    else if (u_h.u_rx.w_valid && !u_h.w_ready)
      n_drop <= n_drop + 1;
  end

  initial begin
    n_host = 0;
    rst100_n = 1'b0;
    rst_ui_n = 1'b0;
    uart_rx = 1'b1;
    repeat (20) @(posedge clk100);
    rst100_n = 1'b1;
    rst_ui_n = 1'b1;
    repeat (40) @(posedge clk100);
    load_mem("PA24-A-01.mem");
    $display("H16_HOLD nwords=%0d BEGIN=%08h MAGIC=%08h", nwords, vec[0], MAGIC);

    send_word(CLR_CMD);
    c = 0;
    while (c < 2_000_000 && u_h.u_clr.st < 4'd5) begin
      @(posedge clk100);
      c = c + 1;
    end
    hold_at_a01 = u_h.u_clr.hold;
    st_at_a01 = u_h.u_clr.st;
    $display("H16_HOLD start A-01 st=%0d hold=%0b w_ready=%0b t=%0t",
             st_at_a01, hold_at_a01, u_h.w_ready, $time);

    send_word(vec[0]);
    for (i = 1; i < nwords; i++)
      send_word(vec[i]);

    for (i = 0; i < 8; i++) begin
      wait_word(host_words[i], 8_000_000, mute);
      if (mute)
        break;
      n_host = n_host + 1;
      $display("H16_HOLD host[%0d]=%08h first_p=%08h n_p=%0d n_drop=%0d hold=%0b st=%0d bix=%0d t=%0t",
               i, host_words[i], first_p, n_p, n_drop, u_h.u_clr.hold, u_h.u_clr.st,
               u_h.u_rx.bix, $time);
    end
    pack_g = (n_host > 0) ? host_words[n_host-1] : 32'h0;
    if (n_host >= 2)
      pack_g = host_words[1];
    else if (n_host == 1)
      pack_g = host_words[0];

    $display("H16_HOLD first_p=%08h n_p=%0d n_drop=%0d n_host=%0d pack_or_last=%08h",
             first_p, n_p, n_drop, n_host, pack_g);
    if (first_p === MAGIC && pack_g === UNSUP)
      $display("H16_HOLD_OVERLAP_XSIM_BEGIN_DROP_UNSUP (mechanism named; not silicon proof / not PACK_ABI_24_24_PASS)");
    else if (first_p === vec[0] && pack_g === NAK_ABI)
      $display("H16_HOLD_OVERLAP_XSIM_STILL_NAK hold_at_a01=%0b n_drop=%0d (BEGIN not dropped)",
               hold_at_a01, n_drop);
    else
      $display("H16_HOLD_OVERLAP_XSIM_CLASS first_p=%08h pack=%08h unsup=%0d mag=%0d nak=%0d",
               first_p, pack_g, pack_g===UNSUP, pack_g===MAG, pack_g===NAK_ABI);
    $finish;
  end
endmodule
