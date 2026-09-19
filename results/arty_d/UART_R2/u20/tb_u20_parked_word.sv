// tb_u18_parked_word.sv — inject 0-word on RX during CLEAR ACK after GOLD.
// U17 class: parked complete RX word → next V-04 R_UNSUP.
// U18: S_DROP flush must destroy parked word; V-04 GOLD; first p_data=BEGIN.
// Dest=mig_ui_bram. BAUD 1M. Not BOARD_PASS.
`timescale 1ns/1ps

module tb_u18_parked_word;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 1_000_000;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam logic [31:0] CLR_CMD = 32'h44524743;
  localparam logic [31:0] CLR_ACK = 32'hC1EA50A5;
  localparam logic [31:0] GOLD    = 32'h010000A5;
  localparam logic [31:0] UNSUP   = 32'h0200075A;
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

  int n_p2;
  logic cap2;
  logic [31:0] p2 [0:7];
  always_ff @(posedge ui_clk or negedge rst_ui_n) begin
    if (!rst_ui_n) begin
      n_p2 <= 0;
    end else if (!cap2) begin
      n_p2 <= 0;
    end else if (p_fire && n_p2 < 8) begin
      p2[n_p2] <= p_data;
      n_p2 <= n_p2 + 1;
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
    cap2 = 1'b0;
    rst100_n = 0; rst_ui_n = 0; uart_rx = 1;
    repeat (20) @(posedge clk100);
    rst100_n = 1; rst_ui_n = 1;
    repeat (40) @(posedge clk100);
    force u_h.calib_ui = 1'b1;
    load_mem("PA24-V-04.mem");
    $display("U18_PARK nwords=%0d DIV=%0d", nwords, DIV);

    send_word(CLR_CMD);
    wait_word(got, 400000, mute);
    if (mute || got !== CLR_ACK) begin
      $display("UART_R2_U18_PARK_FAIL CLEAR1 mute=%0d got=%08h", mute, got);
      $finish;
    end

    for (i = 0; i < nwords; i++) send_word(vec[i]);
    wait_word(got, 2_000_000, mute);
    if (mute || got !== GOLD) begin
      $display("UART_R2_U18_PARK_FAIL V04_0 mute=%0d got=%08h", mute, got);
      $finish;
    end

    cap2 = 1'b1;
    fork
      begin
        send_word(CLR_CMD);
        wait_word(got, 400000, mute);
      end
      begin
        @(negedge uart_tx);
        send_word(32'h0);
        $display("U18_PARK injected 00000000 during ACK TX");
      end
    join
    $display("CLEAR2 mute=%0d got=%08h hold=%0b flush=%0b", mute, got, u_h.clr_hold, u_h.uart_flush);
    if (mute || got !== CLR_ACK) begin
      $display("UART_R2_U18_PARK_FAIL CLEAR2 mute=%0d got=%08h", mute, got);
      $finish;
    end

    repeat (DIV * 20) @(posedge clk100);
    $display("U18_PARK first_p n=%0d p0=%08h p1=%08h p2=%08h", n_p2,
             (n_p2 > 0) ? p2[0] : 32'hx,
             (n_p2 > 1) ? p2[1] : 32'hx,
             (n_p2 > 2) ? p2[2] : 32'hx);

    for (i = 0; i < nwords; i++) send_word(vec[i]);
    wait_word(got, 2_000_000, mute);
    $display("V04_1 mute=%0d got=%08h reason=%02h first_p=%08h n_p2=%0d",
             mute, got, reason_code, (n_p2 > 0) ? p2[0] : 32'h0, n_p2);

    if (got === UNSUP) begin
      $display("UART_R2_U18_PARK_UNSUP first_p=%08h (parked-word class)", (n_p2 > 0) ? p2[0] : 32'h0);
      $finish;
    end
    if (!mute && got === GOLD && (n_p2 == 0 || p2[0] === BEGINW))
      $display("UART_R2_U18_PARK_XSIM_PASS GOLD after parked-0 first_p=%08h", (n_p2 > 0) ? p2[0] : 32'h0);
    else
      $display("UART_R2_U18_PARK_XSIM_FAIL got=%08h first_p=%08h", got, (n_p2 > 0) ? p2[0] : 32'h0);
    $finish;
  end
endmodule
