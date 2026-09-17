// tb_h19_ack_pad_a01.sv — FTDI/host leftover arm, not a baud replay.
// After CLEAR ACK, inject one extra 0x00 then send A-01 at 115200.
// Silicon isolate is ACK then first PACK UNSUP. H12 extra was BEFORE CLEAR.
// dest=mig_ui_bram. Not PACK_ABI_24_24_PASS / not BOARD_PASS.
`timescale 1ns/1ps

module tb_h19_ack_pad_a01;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 115_200;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam logic [31:0] CLR_CMD = 32'h44524743;
  localparam logic [31:0] CLR_ACK = 32'hC1EA50A5;
  localparam logic [31:0] NAK_ABI = 32'h0200025A;
  localparam logic [31:0] UNSUP   = 32'h0200075A;
  localparam logic [31:0] MAG     = 32'h0200015A;
  localparam logic [31:0] BEGINW  = 32'h00800001;

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
  int nwords, i, c;
  logic [31:0] got, pack_g;
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
    rst100_n = 1'b0;
    rst_ui_n = 1'b0;
    uart_rx = 1'b1;
    repeat (20) @(posedge clk100);
    rst100_n = 1'b1;
    rst_ui_n = 1'b1;
    repeat (40) @(posedge clk100);
    load_mem("PA24-A-01.mem");
    $display("H19_ACK_PAD DIV=%0d nwords=%0d first_mem=%08h extra=00_after_ACK",
             DIV, nwords, vec[0]);

    send_word(CLR_CMD);
    wait_word(got, 800000, mute);
    $display("H19 CLEAR mute=%0d got=%08h bix=%0d t=%0t",
             mute, got, u_h.u_rx.bix, $time);
    if (mute || got !== CLR_ACK) begin
      $display("H19_ACK_PAD_XSIM_CLEAR_FAIL got=%08h", got);
      $finish;
    end

    uart_byte(8'h00);
    $display("H19 injected extra 0x00 after ACK bix=%0d t=%0t", u_h.u_rx.bix, $time);

    send_word(vec[0]);
    for (i = 1; i < nwords; i++)
      send_word(vec[i]);
    wait_word(pack_g, 8_000_000, mute);
    $display("H19 PACK mute=%0d got=%08h first_p=%08h n_p=%0d reason=%02h bix=%0d fifo=%0d t=%0t",
             mute, pack_g, first_p, n_p, reason_code, u_h.u_rx.bix, u_h.u_rfifo.used_o, $time);

    if (!mute && pack_g === UNSUP && first_p !== BEGINW)
      $display("H19_ACK_PAD_XSIM_UNSUP extra_after_ACK first_p=%08h (token matches silicon isolate; source still UNKNOWN; not PACK_ABI_24_24_PASS)",
               first_p);
    else if (!mute && pack_g === MAG)
      $display("H19_ACK_PAD_XSIM_MAG extra_after_ACK first_p=%08h", first_p);
    else if (!mute && pack_g === NAK_ABI && first_p === BEGINW)
      $display("H19_ACK_PAD_XSIM_STILL_NAK extra_after_ACK did not shift BEGIN");
    else
      $display("H19_ACK_PAD_XSIM_CLASS mute=%0d pack=%08h first_p=%08h unsup=%0d mag=%0d nak=%0d",
               mute, pack_g, first_p, pack_g===UNSUP, pack_g===MAG, pack_g===NAK_ABI);
    $finish;
  end
endmodule
