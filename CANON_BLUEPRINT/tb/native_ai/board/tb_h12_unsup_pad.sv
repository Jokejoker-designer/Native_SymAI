// tb_h12_unsup_pad.sv — extra1 then CLEAR UNSUP, then pad0 vs pad3.
// Dest BRAM. Not PACK_ABI_24_24_PASS / not BOARD_PASS.
`timescale 1ns/1ps

module tb_h12_unsup_pad;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 1_000_000;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam logic [31:0] CLR_CMD = 32'h44524743;
  localparam logic [31:0] CLR_ACK = 32'hC1EA50A5;
  localparam logic [31:0] GOLD = 32'h010000A5;
  localparam logic [31:0] UNSUP = 32'h0200075A;

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
  logic [31:0] got, pad0_g, pad3_g;

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

  task automatic hw_rst();
    begin
      rst100_n = 1'b0;
      rst_ui_n = 1'b0;
      uart_rx = 1'b1;
      repeat (20) @(posedge clk100);
      rst100_n = 1'b1;
      rst_ui_n = 1'b1;
      repeat (40) @(posedge clk100);
    end
  endtask

  task automatic gold_and_extra1_unsup();
    begin
      send_word(CLR_CMD);
      wait_word(got, 400000);
      for (i = 0; i < nwords; i++)
        send_word(vec[i]);
      wait_word(got, 3_000_000);
      $display("UP GOLD got=%08h", got);
      uart_byte(8'h00);
      send_word(CLR_CMD);
      wait_word(got, 400000);
      $display("UP extra1_CLEAR got=%08h expect_UNSUP=%08h bix=%0d ld=%0d",
               got, UNSUP, u_h.u_rx.bix, u_h.u_ld.u_ld.state);
    end
  endtask

  initial begin
    load_mem("PA24-V-04.mem");
    hw_rst();
    gold_and_extra1_unsup();
    send_word(CLR_CMD);
    wait_word(pad0_g, 400000);
    $display("UP PAD0_CLEAR got=%08h bix=%0d", pad0_g, u_h.u_rx.bix);

    hw_rst();
    gold_and_extra1_unsup();
    uart_byte(8'h00);
    uart_byte(8'h00);
    uart_byte(8'h00);
    send_word(CLR_CMD);
    wait_word(pad3_g, 400000);
    $display("UP PAD3_CLEAR got=%08h bix=%0d", pad3_g, u_h.u_rx.bix);

    if (pad0_g === 32'h0 && pad3_g === CLR_ACK)
      $display("H12_UNSUP_PAD_XSIM_PAD0_MUTE_PAD3_ACK (not PACK_ABI_24_24_PASS / not BOARD_PASS)");
    else
      $display("H12_UNSUP_PAD_XSIM_FAIL pad0=%08h pad3=%08h", pad0_g, pad3_g);
    $finish;
  end
endmodule
