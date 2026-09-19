// tb_u22_gold_then_clear.sv — GOLD then immediate CLEAR. Dest=bram BAUD=1M.
`timescale 1ns/1ps

module tb_u22_gold_then_clear;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 1_000_000;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam logic [31:0] CLR_CMD = 32'h44524743;
  localparam logic [31:0] CLR_ACK = 32'hC1EA50A5;
  localparam logic [31:0] GOLD    = 32'h010000A5;
  localparam logic [31:0] UNSUP   = 32'h0200075A;
  localparam logic [31:0] BUSY    = 32'hC1EA50B5;

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
  int nwords, i, c;
  logic [31:0] got;
  bit mute;

  task automatic load_mem(input string path);
    int fd;
    begin
      fd = $fopen(path, "r");
      if (fd == 0) nwords = 0;
      else begin
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

  task automatic wait_word(output logic [31:0] g, input int maxc, output bit m);
    begin
      c = 0;
      host_take = 1'b0;
      while (c < maxc && !host_seen) begin
        @(posedge clk100);
        c = c + 1;
      end
      m = !host_seen;
      g = host_seen ? host_cap : 32'h0;
      host_take = 1'b1;
      @(posedge clk100);
      host_take = 1'b0;
      repeat (DIV * 8) @(posedge clk100);
    end
  endtask

  initial begin
    rst100_n = 0; rst_ui_n = 0; uart_rx = 1;
    repeat (20) @(posedge clk100);
    rst100_n = 1; rst_ui_n = 1;
    repeat (40) @(posedge clk100);
    force u_h.calib_ui = 1'b1;
    load_mem("PA24-V-04.mem");
    $display("U22_G2C nwords=%0d DIV=%0d", nwords, DIV);

    send_word(CLR_CMD);
    wait_word(got, 400000, mute);
    if (mute || got !== CLR_ACK) begin
      $display("UART_R2_U22_G2C_FAIL CLEAR1 mute=%0d got=%08h", mute, got);
      $finish;
    end

    for (i = 0; i < nwords; i++) send_word(vec[i]);
    wait_word(got, 2_000_000, mute);
    if (mute || got !== GOLD) begin
      $display("UART_R2_U22_G2C_FAIL V04_0 mute=%0d got=%08h", mute, got);
      $finish;
    end
    $display("PHASE4_OK GOLD lock=%0b empty=%0b", u_h.pack_lock, u_h.fifo_empty);

    send_word(CLR_CMD);
    wait_word(got, 400000, mute);
    $display("CLEAR2 mute=%0d got=%08h flush=%0b txflush_tied=0 lock=%0b",
             mute, got, u_h.uart_flush, u_h.pack_lock);
    if (mute) begin
      $display("UART_R2_U22_G2C_FAIL CLEAR2 n=0 (board U20 class)");
      $finish;
    end
    if (got === BUSY) begin
      $display("UART_R2_U22_G2C_FAIL CLEAR2 BUSY");
      $finish;
    end
    if (got === UNSUP) begin
      $display("UART_R2_U22_G2C_FAIL CLEAR2 UNSUP");
      $finish;
    end
    if (got !== CLR_ACK) begin
      $display("UART_R2_U22_G2C_FAIL CLEAR2 got=%08h", got);
      $finish;
    end

    for (i = 0; i < nwords; i++) send_word(vec[i]);
    wait_word(got, 2_000_000, mute);
    if (got === UNSUP)
      $display("UART_R2_U22_G2C_XSIM_PASS CLEAR2 ACK; V04_1 UNSUP (U17 board class, bram)");
    else if (!mute && got === GOLD)
      $display("UART_R2_U22_G2C_XSIM_PASS GOLD then CLEAR ACK then GOLD2 dest=bram");
    else
      $display("UART_R2_U22_G2C_FAIL V04_1 mute=%0d got=%08h", mute, got);
    $finish;
  end
endmodule
