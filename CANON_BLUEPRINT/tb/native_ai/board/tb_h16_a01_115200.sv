// tb_h16_a01_115200.sv — H16 TX/response + A-01 at silicon baud 115200.
// Prior A-01 XSim used BAUD=1e6; silicon isolate first PACK is UNSUP not NAK_R02.
// Dual-clock harness, dest=mig_ui_bram not mig0. Not PACK_ABI_24_24_PASS / not BOARD_PASS.
`timescale 1ns/1ps

module tb_h16_a01_115200;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 115_200;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam int NLOOP  = 2;
  localparam logic [31:0] CLR_CMD = 32'h44524743;
  localparam logic [31:0] CLR_ACK = 32'hC1EA50A5;
  localparam logic [31:0] NAK_ABI = 32'h0200025A;
  localparam logic [31:0] UNSUP   = 32'h0200075A;
  localparam logic [31:0] MAG     = 32'h0200015A;

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
  integer n_st_tx;
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
  always @(posedge clk100 or negedge rst100_n) begin
    if (!rst100_n)
      n_st_tx = 0;
    else if (u_h.st_valid_100 && u_h.st_ready_100)
      n_st_tx = n_st_tx + 1;
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
  int nwords, i, c, k, n_nak, n_unsup, n_mag, n_mute, n_ack_clr;
  logic [31:0] got, pack_g, clr2;
  bit mute;

  task automatic load_mem(input string path);
    int fd;
    begin
      fd = $fopen(path, "r");
      if (fd == 0) begin
        $display("FAIL open %s", path);
        nwords = 0;
      end else begin
        void'($fscanf(fd, "%h", nwords));
        for (i = 0; i < nwords; i++)
          void'($fscanf(fd, "%h", vec[i]));
        $fclose(fd);
      end
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
      repeat (DIV * 8) @(posedge clk100);
    end
  endtask

  initial begin
    n_nak = 0;
    n_unsup = 0;
    n_mag = 0;
    n_mute = 0;
    n_ack_clr = 0;
    rst100_n = 1'b0;
    rst_ui_n = 1'b0;
    uart_rx = 1'b1;
    repeat (20) @(posedge clk100);
    rst100_n = 1'b1;
    rst_ui_n = 1'b1;
    repeat (40) @(posedge clk100);
    load_mem("PA24-A-01.mem");
    $display("H16_A01_115200 DIV=%0d nwords=%0d first_mem=%08h", DIV, nwords, vec[0]);

    for (k = 0; k < NLOOP; k++) begin
      send_word(CLR_CMD);
      wait_word(got, 800000, mute);
      $display("H16 i=%0d CLEAR mute=%0d got=%08h bix=%0d fifo_used=%0d tx_rdy=%0b st100=%0b qsc=%0b t=%0t",
               k, mute, got, u_h.u_rx.bix, u_h.u_rfifo.used_o, u_h.u_tx.w_ready,
               u_h.st_valid_100, u_h.qsc_100, $time);
      if (mute) begin
        n_mute = n_mute + 1;
        break;
      end
      if (got === CLR_ACK)
        n_ack_clr = n_ack_clr + 1;
      send_word(vec[0]);
      for (i = 1; i < nwords; i++)
        send_word(vec[i]);
      wait_word(pack_g, 8_000_000, mute);
      $display("H16 i=%0d PACK mute=%0d got=%08h first_p=%08h n_p=%0d n_st_tx=%0d reason=%02h ld=%0d bix=%0d fifo_used=%0d lock=%0b tx_rdy=%0b t=%0t",
               k, mute, pack_g, first_p, n_p, n_st_tx, reason_code, u_h.u_ld.u_ld.state,
               u_h.u_rx.bix, u_h.u_rfifo.used_o, u_h.pack_lock, u_h.u_tx.w_ready, $time);
      if (mute)
        n_mute = n_mute + 1;
      else if (pack_g === NAK_ABI)
        n_nak = n_nak + 1;
      else if (pack_g === UNSUP)
        n_unsup = n_unsup + 1;
      else if (pack_g === MAG)
        n_mag = n_mag + 1;
    end

    send_word(CLR_CMD);
    wait_word(clr2, 800000, mute);
    $display("H16 POST CLEAR mute=%0d got=%08h n_nak=%0d n_unsup=%0d n_mag=%0d n_mute=%0d n_ack_clr=%0d",
             mute, clr2, n_nak, n_unsup, n_mag, n_mute, n_ack_clr);
    if (!mute && n_nak == NLOOP && n_unsup == 0 && n_mag == 0 && n_mute == 0 && clr2 === CLR_ACK)
      $display("H16_A01_115200_XSIM_NAK_THEN_ACK (silicon isolate UNSUP/MAG/mute not in BRAM 115200; not PACK_ABI_24_24_PASS)");
    else
      $display("H16_A01_115200_XSIM_CLASS nak=%0d unsup=%0d mag=%0d mute=%0d clr2=%08h",
               n_nak, n_unsup, n_mag, n_mute, clr2);
    $finish;
  end
endmodule
