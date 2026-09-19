// Scratch TB: dest/MIG classes on U32 harness. No UART/CLEAR overlay.
// Dest=mig_ui_bram, not generated mig0. Not PACK_ABI_24_24_PASS.
// D: dest_stall from reset, 8x CLEAR (U32 board BUSY then n=0 class).
// CALIB: calib_ui=0, dest not stalled (BRAM still asserts app_rdy).
// F: force mux b_busy (FEM grant), CLEAR then V-04.
// B: stall on first p_fire after ACK (hang UART-identical).
`timescale 1ns/1ps

module tb_u32_dest_mig_class;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 1_000_000;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam logic [31:0] CLR_CMD  = 32'h44524743;
  localparam logic [31:0] CLR_ACK  = 32'hC1EA50A5;
  localparam logic [31:0] CLR_BUSY = 32'hC1EA50B5;
  localparam logic [31:0] GOLD     = 32'h010000A5;
  localparam logic [31:0] BEGINW   = 32'h00800001;

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
  int nwords, i, c, k, nw, n_p_snap;
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
    int kb;
    begin
      uart_rx <= 1'b0;
      repeat (DIV) @(posedge clk100);
      for (kb = 0; kb < 8; kb++) begin
        uart_rx <= b[kb];
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

  task automatic collect_reply(output int nout);
    begin
      nout = 0;
      for (i = 0; i < 4; i++) begin
        wait_word(got, 400000, mute);
        if (mute)
          break;
        capw[nout] = got;
        nout = nout + 1;
      end
    end
  endtask

  task automatic score_clear(input string tag, input int nout);
    begin
      if (nout == 0)
        $display("%s MUTE st=%0d hold=%0b qsc_ui=%0b qsc_100=%0b d_rdy=%0b dest_accept=%0b tx_b_n=%0b tx_b_idle=%0b ack_v=%0b",
                 tag, u_h.u_clr.st, u_h.clr_hold, u_h.qsc_ui, u_h.qsc_100, u_h.d_rdy,
                 u_h.dest_accept, u_h.rst100_tx_b_n, u_h.tx_b_idle, u_h.clr_ack_valid);
      else if (nout == 1 && capw[0] === CLR_BUSY)
        $display("%s BUSY_N4_NO_GOLD st=%0d qsc_ui=%0b d_rdy=%0b",
                 tag, u_h.u_clr.st, u_h.qsc_ui, u_h.d_rdy);
      else if (nout >= 2 && capw[0] === CLR_BUSY && capw[1] === GOLD)
        $display("%s BUSY_THEN_GOLD_N8", tag);
      else if (nout == 1 && capw[0] === CLR_ACK)
        $display("%s ACK st=%0d qsc_ui=%0b d_rdy=%0b",
                 tag, u_h.u_clr.st, u_h.qsc_ui, u_h.d_rdy);
      else
        $display("%s OTHER nw=%0d w0=%08h st=%0d", tag, nout, capw[0], u_h.u_clr.st);
    end
  endtask

  initial begin
    dest_stall = 1'b1;
    rst100_n = 0; rst_ui_n = 0; uart_rx = 1;
    repeat (20) @(posedge clk100);
    rst100_n = 1; rst_ui_n = 1;
    repeat (40) @(posedge clk100);
    force u_h.calib_ui = 1'b1;
    load_mem("PA24-V-04.mem");
    wait_cdc();
    $display("CELL_D_START d_rdy=%0b qsc_ui=%0b qsc_100=%0b dest_accept=%0b calib=%0b nwords=%0d",
             u_h.d_rdy, u_h.qsc_ui, u_h.qsc_100, u_h.dest_accept, u_h.calib_ui, nwords);

    for (k = 0; k < 8; k++) begin
      send_word(CLR_CMD);
      collect_reply(nw);
      score_clear($sformatf("CELL_D_CLR%0d", k), nw);
    end

    dest_stall = 1'b0;
    wait_cdc();
    send_word(CLR_CMD);
    collect_reply(nw);
    score_clear("CELL_D_RELEASE", nw);

    dest_stall = 1'b0;
    force u_h.calib_ui = 1'b0;
    wait_cdc();
    send_word(CLR_CMD);
    collect_reply(nw);
    $display("CELL_CALIB d_rdy=%0b qsc_ui=%0b calib=%0b", u_h.d_rdy, u_h.qsc_ui, u_h.calib_ui);
    score_clear("CELL_CALIB", nw);
    force u_h.calib_ui = 1'b1;
    wait_cdc();

    dest_stall = 1'b0;
    force u_h.u_mux.b_busy = 1'b1;
    wait_cdc();
    $display("CELL_F_GRANT g=%0d a_rdy=%0b d_rdy=%0b qsc_ui=%0b dest_accept=%0b",
             u_h.u_mux.g, u_h.p_rdy, u_h.d_rdy, u_h.qsc_ui, u_h.dest_accept);
    send_word(CLR_CMD);
    collect_reply(nw);
    score_clear("CELL_F_CLEAR", nw);
    n_p_snap = n_p;
    if (nw == 1 && capw[0] === CLR_ACK) begin
      for (i = 0; i < nwords; i++) send_word(vec[i]);
      wait_word(got, 2_000_000, mute);
      $display("CELL_F_V04 mute=%0d got=%08h n_p=%0d dn_p=%0d load_ack=%0b f_valid=%0b f_data=%08h",
               mute, got, n_p, n_p - n_p_snap, load_ack, u_h.f_valid, u_h.f_data);
      if (mute && (n_p == n_p_snap))
        $display("UART_R2_U32_DEST_MIG_SCORE CELL_F MUTE_PFIRE0");
      else if (mute && (n_p > n_p_snap))
        $display("UART_R2_U32_DEST_MIG_SCORE CELL_F HANG_PFIRE_GT0");
      else if (!mute && got === GOLD)
        $display("UART_R2_U32_DEST_MIG_SCORE CELL_F GOLD");
      else
        $display("UART_R2_U32_DEST_MIG_SCORE CELL_F OTHER got=%08h", got);
    end else
      $display("UART_R2_U32_DEST_MIG_SCORE CELL_F NO_ACK_SKIP_V04");
    release u_h.u_mux.b_busy;
    wait_cdc();

    send_word(CLR_CMD);
    wait_word(got, 400000, mute);
    if (mute || got !== CLR_ACK) begin
      $display("UART_R2_U32_DEST_MIG_XSIM_FAIL CLEAR_B got=%08h mute=%0d", got, mute);
      $display("UART_R2_U32_DEST_MIG_XSIM_DONE PACK_ABI_24_24_PASS=NO");
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
      $display("UART_R2_U32_DEST_MIG_SCORE CELL_B HANG_PFIRE_GT0");
    else if (mute)
      $display("UART_R2_U32_DEST_MIG_SCORE CELL_B MUTE_PFIRE0");
    else if (got === GOLD)
      $display("UART_R2_U32_DEST_MIG_SCORE CELL_B GOLD");
    else
      $display("UART_R2_U32_DEST_MIG_SCORE CELL_B OTHER got=%08h", got);

    $display("UART_R2_U32_DEST_MIG_XSIM_DONE PACK_ABI_24_24_PASS=NO");
    $finish;
  end
endmodule
