// Scratch TB: dest_accept hold vs mid-pack hang. Dest=mig_ui_bram. Not PACK_ABI_24_24_PASS.
// Cell A (E6 class): ACK, dest_stall, V-04. Score mute + p_fire==0 vs GOLD.
// Then dest_stall=0 without host TX. Score FIFO recovery GOLD vs still mute.
// Cell B: ACK, V-04 starts, dest_stall on first p_fire. Score hang (p_fire>0, no GOLD).
`timescale 1ns/1ps

module tb_u31_dest_accept_mute;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 1_000_000;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam logic [31:0] CLR_CMD = 32'h44524743;
  localparam logic [31:0] CLR_ACK = 32'hC1EA50A5;
  localparam logic [31:0] GOLD    = 32'h010000A5;

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

  int n_p;
  always_ff @(posedge ui_clk or negedge rst_ui_n) begin
    if (!rst_ui_n) n_p <= 0;
    else if (p_fire) n_p <= n_p + 1;
  end

  logic [31:0] vec [0:1023];
  int nwords, i, c, n_p_snap;
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

  task automatic wait_cdc;
    begin
      repeat (32) @(posedge ui_clk);
      repeat (16) @(posedge clk100);
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
      $display("UART_R2_U31_DEST_ACCEPT_XSIM_FAIL CLEAR1 got=%08h mute=%0d", got, mute);
      $finish;
    end

    dest_stall = 1'b1;
    wait_cdc();
    $display("CELL_A_AFTER_STALL dest_accept=%0b qsc_c1=%0b rst100_pack_n=%0b qsc_ui=%0b d_rdy=%0b n_p=%0d f_valid=%0b f_data=%08h fifo_empty=%0b",
             u_h.dest_accept, u_h.qsc_c1, u_h.rst100_pack_n, u_h.qsc_ui, u_h.d_rdy, n_p,
             u_h.f_valid, u_h.f_data, u_h.fifo_empty);

    n_p_snap = n_p;
    for (i = 0; i < nwords; i++) send_word(vec[i]);
    wait_word(got, 400000, mute);
    $display("CELL_A_AFTER_V04 mute=%0d got=%08h dest_accept=%0b n_p=%0d dn_p=%0d f_valid=%0b f_data=%08h f_ready=%0b fifo_empty=%0b load_ack=%0b",
             mute, got, u_h.dest_accept, n_p, n_p - n_p_snap, u_h.f_valid, u_h.f_data,
             u_h.f_ready, u_h.fifo_empty, load_ack);
    if (mute && (n_p == n_p_snap))
      $display("UART_R2_U31_DEST_ACCEPT_SCORE CELL_A MUTE_PFIRE0");
    else if (mute)
      $display("UART_R2_U31_DEST_ACCEPT_SCORE CELL_A MUTE_PFIRE_GT0 dn_p=%0d", n_p - n_p_snap);
    else if (got === GOLD)
      $display("UART_R2_U31_DEST_ACCEPT_SCORE CELL_A GOLD (probe failed)");
    else
      $display("UART_R2_U31_DEST_ACCEPT_SCORE CELL_A OTHER got=%08h", got);

    dest_stall = 1'b0;
    wait_cdc();
    $display("CELL_A_RELEASE dest_accept=%0b qsc_ui=%0b d_rdy=%0b fifo_empty=%0b f_data=%08h",
             u_h.dest_accept, u_h.qsc_ui, u_h.d_rdy, u_h.fifo_empty, u_h.f_data);
    wait_word(got, 2_000_000, mute);
    $display("CELL_A_RECOVERY mute=%0d got=%08h n_p=%0d load_ack=%0b", mute, got, n_p, load_ack);
    if (!mute && got === GOLD)
      $display("UART_R2_U31_DEST_ACCEPT_SCORE CELL_A RECOVERY_GOLD");
    else if (mute)
      $display("UART_R2_U31_DEST_ACCEPT_SCORE CELL_A STILL_MUTE");
    else
      $display("UART_R2_U31_DEST_ACCEPT_SCORE CELL_A RECOVERY_OTHER got=%08h", got);

    send_word(CLR_CMD);
    wait_word(got, 400000, mute);
    if (mute || got !== CLR_ACK) begin
      $display("UART_R2_U31_DEST_ACCEPT_XSIM_FAIL CLEAR2 got=%08h mute=%0d", got, mute);
      $finish;
    end

    n_p_snap = n_p;
    dest_stall = 1'b0;
    fork
      begin
        for (i = 0; i < nwords; i++) send_word(vec[i]);
      end
      begin : stall_on_first_p
        int c_b;
        c_b = 0;
        while ((n_p == n_p_snap) && (c_b < 2_000_000)) begin
          @(posedge ui_clk);
          c_b = c_b + 1;
        end
        dest_stall = 1'b1;
        $display("CELL_B_STALL_AT n_p=%0d dest_accept=%0b d_rdy=%0b c_b=%0d",
                 n_p, u_h.dest_accept, u_h.d_rdy, c_b);
      end
    join
    wait_word(got, 2_000_000, mute);
    $display("CELL_B_AFTER mute=%0d got=%08h n_p=%0d dn_p=%0d load_ack=%0b qsc_ui=%0b",
             mute, got, n_p, n_p - n_p_snap, load_ack, u_h.qsc_ui);
    if (mute && (n_p > n_p_snap))
      $display("UART_R2_U31_DEST_ACCEPT_SCORE CELL_B HANG_PFIRE_GT0");
    else if (mute)
      $display("UART_R2_U31_DEST_ACCEPT_SCORE CELL_B MUTE_PFIRE0");
    else if (got === GOLD)
      $display("UART_R2_U31_DEST_ACCEPT_SCORE CELL_B GOLD");
    else
      $display("UART_R2_U31_DEST_ACCEPT_SCORE CELL_B OTHER got=%08h", got);

    $display("UART_R2_U31_DEST_ACCEPT_XSIM_DONE PACK_ABI_24_24_PASS=NO");
    $finish;
  end
endmodule
