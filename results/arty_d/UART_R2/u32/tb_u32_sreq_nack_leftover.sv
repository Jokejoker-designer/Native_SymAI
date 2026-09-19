// Scratch TB: S_REQ then dest_stall nack. U32 must NOT replay GOLD (BUSY n=4).
// Dest=mig_ui_bram. Not PACK_ABI_24_24_PASS.
`timescale 1ns/1ps

module tb_u32_sreq_nack_leftover;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 1_000_000;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam logic [31:0] CLR_CMD  = 32'h44524743;
  localparam logic [31:0] CLR_ACK  = 32'hC1EA50A5;
  localparam logic [31:0] CLR_BUSY = 32'hC1EA50B5;
  localparam logic [31:0] GOLD     = 32'h010000A5;

  logic clk100, ui_clk, rst100_n, rst_ui_n, uart_rx, uart_tx;
  logic dest_stall;
  initial clk100 = 1'b0;
  always #5 clk100 = ~clk100;
  initial ui_clk = 1'b0;
  always #6.25 ui_clk = ~ui_clk;

  logic w_valid, w_ready, fifo_wr_fire, fifo_rd_fire, p_fire;
  logic [31:0] w_data, fifo_wr_data, fifo_rd_data, p_data;
  logic load_ack, load_reject;
  logic [7:0] reason_code;

  pack_uart_dualclk_harness #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_h (
    .clk100, .ui_clk, .rst100_n, .rst_ui_n, .uart_rx, .uart_tx,
    .w_valid, .w_ready, .w_data,
    .fifo_wr_fire, .fifo_wr_data, .fifo_rd_fire, .fifo_rd_data,
    .p_fire, .p_data, .load_ack, .load_reject, .reason_code,
    .dest_stall
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
  int nwords, i, c, nw;
  logic [31:0] got;
  logic [31:0] capw [0:7];
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
    dest_stall = 1'b0;
    rst100_n = 0; rst_ui_n = 0; uart_rx = 1;
    repeat (20) @(posedge clk100);
    rst100_n = 1; rst_ui_n = 1;
    repeat (40) @(posedge clk100);
    force u_h.calib_ui = 1'b1;
    load_mem("PA24-V-04.mem");

    send_word(CLR_CMD);
    wait_word(got, 400000, mute);
    if (mute || got !== CLR_ACK) begin
      $display("UART_R2_U32_SREQ_NACK_FAIL CLEAR1 got=%08h", got);
      $finish;
    end
    for (i = 0; i < nwords; i++) send_word(vec[i]);
    wait_word(got, 2_000_000, mute);
    if (mute || got !== GOLD) begin
      $display("UART_R2_U32_SREQ_NACK_FAIL V04_0 got=%08h", got);
      $finish;
    end
    $display("PHASE4_GOLD req_a=%0b last_b=%0b load_ack=%0b ack_d=%0b qsc_ui=%0b qsc_100=%0b",
             u_h.u_cdc_tx.req_a, u_h.u_cdc_tx.last_b, load_ack, u_h.ack_d,
             u_h.qsc_ui, u_h.qsc_100);

    fork
      send_word(CLR_CMD);
      begin
        c = 0;
        while ((u_h.u_clr.st != 4'd2) && (c < 200000)) begin
          @(posedge clk100);
          c = c + 1;
        end
        dest_stall = 1'b1;
        $display("AT_SREQ st=%0d ui_req=%0b rst100_tx_b_n=%0b qsc_ui=%0b qsc_100=%0b c=%0d",
                 u_h.u_clr.st, u_h.clr_ui_req, u_h.rst100_tx_b_n, u_h.qsc_ui, u_h.qsc_100, c);
      end
    join
    repeat (32) @(posedge ui_clk);
    repeat (16) @(posedge clk100);
    $display("AFTER_NACK_WIN st=%0d ui_req=%0b rst100_tx_b_n=%0b st_valid_100=%0b nack=%0b req_a=%0b last_b=%0b",
             u_h.u_clr.st, u_h.clr_ui_req, u_h.rst100_tx_b_n, u_h.st_valid_100,
             u_h.nack_c1, u_h.u_cdc_tx.req_a, u_h.u_cdc_tx.last_b);

    nw = 0;
    for (i = 0; i < 8; i++) begin
      wait_word(got, 200000, mute);
      if (mute)
        break;
      capw[nw] = got;
      nw = nw + 1;
      $display("CLR2_WORD %0d %08h", nw, got);
    end
    if (nw == 0)
      $display("UART_R2_U32_SREQ_NACK_SCORE MUTE");
    else if (nw == 1 && capw[0] === CLR_BUSY)
      $display("UART_R2_U32_SREQ_NACK_SCORE BUSY_N4_NO_GOLD");
    else if (nw >= 2 && capw[0] === CLR_BUSY && capw[1] === GOLD)
      $display("UART_R2_U32_SREQ_NACK_SCORE BUSY_THEN_GOLD_N8");
    else if (nw == 1 && capw[0] === CLR_ACK)
      $display("UART_R2_U32_SREQ_NACK_SCORE ACK");
    else
      $display("UART_R2_U32_SREQ_NACK_SCORE OTHER nw=%0d w0=%08h", nw, capw[0]);
    $display("UART_R2_U32_SREQ_NACK_XSIM_DONE PACK_ABI_24_24_PASS=NO");
    $finish;
  end
endmodule
