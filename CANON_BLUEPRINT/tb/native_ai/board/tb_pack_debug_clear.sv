// tb_pack_debug_clear.sv — UART T7/T8 + handshake. VALIDATION_ONLY.
// CLEAR_REQ 32'h44524743. Mid-word CLEAR_REQ is out of scope (word-aligned host).
// T7 proves assembler flush after CLEAR_ACK. Not PACK_ABI / not PACK_ABI_24_24_PASS.
`timescale 1ns/1ps

module tb_pack_debug_clear;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD = 1_000_000;
  localparam int DIV = CLK_HZ / BAUD;
  localparam logic [31:0] CLR_CMD  = 32'h44524743;
  localparam logic [31:0] CLR_ACK  = 32'hC1EA50A5;
  localparam logic [31:0] CLR_BUSY = 32'hC1EA50B5;

  logic clk, rst_n, uart_rx, uart_tx;
  initial clk = 1'b0;
  always #5 clk = ~clk;

  logic clr_take, clr_hold, uart_flush, cdc_rst_100;
  logic ui_req, ui_ack, ui_nack, debug_clear;
  logic clr_ack_valid, clr_ack_ready;
  logic [31:0] clr_ack_data;
  logic w_valid, w_ready;
  logic [31:0] w_data;
  logic pack_qsc, cdc_a_idle, cdc_b_idle;
  logic ack_d, nak_d, st_valid, st_ready;
  logic [31:0] st_data;
  logic fifo_empty, f_valid, pack_lock;
  wire rst_pack_n = rst_n & ~cdc_rst_100;
  wire rst_ui_pack_n = rst_n & ~debug_clear;
  wire qsc_100 = pack_qsc && cdc_a_idle && !st_valid;

  logic rx_mark;
  pack_debug_clear u_clr (
    .clk, .rst_n,
    .in_valid(w_valid), .in_data(w_data),
    .take(clr_take), .hold(clr_hold),
    .uart_flush, .cdc_rst_100,
    .ui_req, .ui_ack, .ui_nack,
    .pack_quiescent(qsc_100),
    .uart_rx_mark(rx_mark),
    .ack_valid(clr_ack_valid), .ack_ready(clr_ack_ready), .ack_data(clr_ack_data)
  );

  pack_clear_ui u_uiclr (
    .clk, .rst_n, .req(ui_req), .pack_quiescent(pack_qsc),
    .ack(ui_ack), .nack(ui_nack), .debug_clear
  );

  uart_rx_word #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_rx (
    .clk, .rst_n, .rx(uart_rx),
    .w_valid(w_valid), .w_ready(w_ready), .w_data(w_data),
    .flush(uart_flush), .idle(rx_mark), .rx_sync()
  );

  logic load_ack, load_reject, pack_busy, calib_ui;
  logic [7:0] reason_code;
  logic [31:0] active_generation;
  logic [15:0] wr_outstanding;
  logic [27:0] p_addr, d_addr;
  logic [2:0] p_cmd, d_cmd;
  logic p_en, d_en, p_end, d_end, p_wren, d_wren, p_rdv, d_rdv, p_rdy, d_rdy, p_wdf_rdy, d_wdf_rdy;
  logic d_rd_end;
  logic [127:0] p_wdata, d_wdata, p_rdata, d_rdata;
  logic [15:0] p_mask, d_mask;
  logic [127:0] b_rdata;
  logic b_rdv, b_rdy, b_wdf_rdy;
  logic p_valid, p_ready;
  logic [31:0] p_data;
  logic s_ready_pack;
  logic fifo_wr_ready, f_ready, q_taking, qh_in_ready;
  logic [31:0] f_data;
  logic uart_q_valid, uart_q_ready, uart_r_ready, uart_tx_valid, uart_tx_ready;
  logic [31:0] uart_tx_data;
  logic [7:0] uart_q_bytes [0:31];
  logic [7:0] dummy_r [0:47];
  wire pack_op = (f_data[7:0] == 8'h01);

  word_cdc32 u_cdc (
    .a_clk(clk), .a_rst_n(rst_pack_n),
    .a_valid(f_valid && !q_taking && !clr_take && !clr_hold),
    .a_ready(s_ready_pack), .a_data(f_data),
    .b_clk(clk), .b_rst_n(rst_ui_pack_n),
    .b_valid(p_valid), .b_ready(p_ready), .b_data(p_data),
    .a_idle(cdc_a_idle), .b_idle(cdc_b_idle)
  );

  word_fifo32 #(.DEPTH(128)) u_rfifo (
    .clk, .rst_n,
    .wr_valid(w_valid && !clr_take && !clr_hold), .wr_ready(fifo_wr_ready), .wr_data(w_data),
    .rd_valid(f_valid), .rd_ready(f_ready), .rd_data(f_data),
    .flush(uart_flush), .empty(fifo_empty)
  );

  uart_fe256_host u_qhost (
    .clk, .rst_n(rst_pack_n),
    .in_valid(f_valid && !clr_take && !clr_hold && !pack_lock),
    .in_ready(qh_in_ready), .in_data(f_data),
    .taking(q_taking),
    .q_valid(uart_q_valid), .q_ready(uart_q_ready), .q_bytes(uart_q_bytes),
    .r_valid(1'b0), .r_ready(uart_r_ready), .r_bytes(dummy_r),
    .tx_valid(uart_tx_valid), .tx_ready(uart_tx_ready), .tx_data(uart_tx_data)
  );
  assign uart_q_ready = 1'b1;
  assign uart_tx_ready = 1'b1;

  assign w_ready = clr_take || (!clr_hold && fifo_wr_ready);
  assign f_ready = q_taking ? qh_in_ready : s_ready_pack;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      pack_lock <= 1'b0;
    else if (uart_flush || cdc_rst_100)
      pack_lock <= 1'b0;
    else if (st_valid && st_ready)
      pack_lock <= 1'b0;
    else if (f_valid && f_ready && !q_taking && pack_op)
      pack_lock <= 1'b1;
  end

  pack_mig_bind u_ld (
    .clk, .rst_n, .debug_clear, .calib_done(calib_ui),
    .s_valid(p_valid), .s_ready(p_ready), .s_data(p_data),
    .load_ack, .load_reject, .reason_code, .active_generation, .wr_outstanding,
    .force_fifo_empty(1'b0), .ui_busy(pack_busy), .pack_quiescent(pack_qsc),
    .app_addr(p_addr), .app_cmd(p_cmd), .app_en(p_en),
    .app_wdf_data(p_wdata), .app_wdf_end(p_end), .app_wdf_mask(p_mask), .app_wdf_wren(p_wren),
    .app_rd_data(p_rdata), .app_rd_data_valid(p_rdv), .app_rdy(p_rdy), .app_wdf_rdy(p_wdf_rdy)
  );

  mig_ui_mux u_mux (
    .clk, .rst_n,
    .a_busy(pack_busy), .a_addr(p_addr), .a_cmd(p_cmd), .a_en(p_en),
    .a_wdf_data(p_wdata), .a_wdf_end(p_end), .a_wdf_mask(p_mask), .a_wdf_wren(p_wren),
    .a_rd_data(p_rdata), .a_rd_valid(p_rdv), .a_rdy(p_rdy), .a_wdf_rdy(p_wdf_rdy),
    .b_busy(1'b0), .b_addr(28'h0), .b_cmd(3'h0), .b_en(1'b0),
    .b_wdf_data(128'h0), .b_wdf_end(1'b0), .b_wdf_mask(16'h0), .b_wdf_wren(1'b0),
    .b_rd_data(b_rdata), .b_rd_valid(b_rdv), .b_rdy(b_rdy), .b_wdf_rdy(b_wdf_rdy),
    .d_addr, .d_cmd, .d_en, .d_wdf_data(d_wdata), .d_wdf_end(d_end),
    .d_wdf_mask(d_mask), .d_wdf_wren(d_wren),
    .d_rd_data(d_rdata), .d_rd_valid(d_rdv), .d_rdy, .d_wdf_rdy
  );

  mig_ui_bram u_dest (
    .clk, .rst_n, .calib_done(calib_ui), .stall(1'b0),
    .app_addr(d_addr), .app_cmd(d_cmd), .app_en(d_en),
    .app_wdf_data(d_wdata), .app_wdf_end(d_end), .app_wdf_mask(d_mask), .app_wdf_wren(d_wren),
    .app_rd_data(d_rdata), .app_rd_data_end(d_rd_end), .app_rd_data_valid(d_rdv),
    .app_rdy(d_rdy), .app_wdf_rdy(d_wdf_rdy)
  );

  always_ff @(posedge clk or negedge rst_ui_pack_n) begin
    if (!rst_ui_pack_n) begin
      ack_d <= 1'b0;
      nak_d <= 1'b0;
      st_valid <= 1'b0;
      st_data <= 32'h0;
    end else begin
      ack_d <= load_ack;
      nak_d <= load_reject;
      if (st_valid && st_ready) st_valid <= 1'b0;
      else if (!st_valid) begin
        if (load_ack && !ack_d) begin
          st_data <= {8'h01, 8'h00, reason_code, 8'hA5};
          st_valid <= 1'b1;
        end else if (load_reject && !nak_d) begin
          st_data <= {8'h02, 8'h00, reason_code, 8'h5A};
          st_valid <= 1'b1;
        end
      end
    end
  end

  logic mux_valid, mux_ready;
  logic [31:0] mux_data;
  assign mux_valid = clr_ack_valid | st_valid;
  assign mux_data = clr_ack_valid ? clr_ack_data : st_data;
  assign clr_ack_ready = mux_ready && !uart_flush;
  assign st_ready = !clr_ack_valid && mux_ready;

  uart_tx_word #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_tx (
    .clk, .rst_n, .w_valid(mux_valid), .w_ready(mux_ready), .w_data(mux_data),
    .flush(uart_flush), .tx(uart_tx)
  );

  logic host_valid, host_ready, host_seen, host_take = 1'b0;
  logic [31:0] host_data, host_cap;
  uart_rx_word #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_host (
    .clk, .rst_n, .rx(uart_tx), .w_valid(host_valid), .w_ready(host_ready), .w_data(host_data)
  );
  assign host_ready = 1'b1;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      host_seen <= 1'b0;
      host_cap <= 32'h0;
    end else if (host_take) begin
      host_seen <= 1'b0;
    end else if (host_valid && !host_seen) begin
      host_seen <= 1'b1;
      host_cap <= host_data;
    end
  end

  logic [31:0] vec [0:1023];
  int nwords, pass, fail, ghost, i, c, hold_wr_max;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      hold_wr_max <= 0;
    else if (clr_hold && w_valid && !clr_take && fifo_wr_ready) begin
      if (hold_wr_max < 1023)
        hold_wr_max <= hold_wr_max + 1;
    end
  end

  task automatic load_mem(input string path);
    int fd;
    begin
      fd = $fopen(path, "r");
      if (fd == 0) begin
        $display("FAIL open %s", path);
        fail = fail + 1;
        nwords = 0;
      end else begin
        void'($fscanf(fd, "%h", nwords));
        for (i = 0; i < nwords; i++) void'($fscanf(fd, "%h", vec[i]));
        $fclose(fd);
      end
    end
  endtask

  task automatic uart_byte(input logic [7:0] b);
    int k;
    begin
      uart_rx <= 1'b0;
      repeat (DIV) @(posedge clk);
      for (k = 0; k < 8; k++) begin
        uart_rx <= b[k];
        repeat (DIV) @(posedge clk);
      end
      uart_rx <= 1'b1;
      repeat (DIV) @(posedge clk);
    end
  endtask

  task automatic send_word(input logic [31:0] w);
    begin
      uart_byte(w[7:0]);
      uart_byte(w[15:8]);
      uart_byte(w[23:16]);
      uart_byte(w[31:24]);
    end
  endtask

  task automatic send_pack;
    begin
      for (i = 0; i < nwords; i++) send_word(vec[i]);
    end
  endtask

  task automatic wait_status(input logic [31:0] exp, input int maxc);
    begin
      c = 0;
      host_take = 1'b0;
      while (c < maxc && !host_seen) begin
        @(posedge clk);
        c = c + 1;
      end
      if (!host_seen) begin
        $display("TIMEOUT exp=%08h ack=%0d nak=%0d rc=%02h",
                 exp, load_ack, load_reject, reason_code);
        fail = fail + 1;
      end else if (host_cap !== exp) begin
        $display("MISMATCH exp=%08h got=%08h", exp, host_cap);
        fail = fail + 1;
      end else begin
        $display("MATCH %08h", host_cap);
        pass = pass + 1;
      end
      host_take = 1'b1;
      @(posedge clk);
      host_take = 1'b0;
      repeat (DIV * 16) @(posedge clk);
    end
  endtask

  initial begin
    pass = 0;
    fail = 0;
    rst_n = 1'b0;
    uart_rx = 1'b1;
    repeat (20) @(posedge clk);
    rst_n = 1'b1;
    repeat (20) @(posedge clk);

    // T1-ish: CLEAR then V-01
    send_word(CLR_CMD);
    wait_status(CLR_ACK, 200000);
    load_mem("PA24-V-01.mem");
    send_pack();
    wait_status(32'h010000A5, 2000000);

    // T2 history
    load_mem("PA24-V-01.mem");
    send_pack();
    wait_status(32'h02000E5A, 2000000);

    // T3 CLEAR then V-01
    send_word(CLR_CMD);
    wait_status(CLR_ACK, 200000);
    load_mem("PA24-V-01.mem");
    send_pack();
    wait_status(32'h010000A5, 2000000);

    // T6 idempotent
    send_word(CLR_CMD);
    wait_status(CLR_ACK, 200000);
    send_word(CLR_CMD);
    wait_status(CLR_ACK, 200000);

    // T7: after CLEAR take, inject 2 stray bytes before ACK; flush must drop them
    send_word(CLR_CMD);
    uart_byte(8'hAA);
    uart_byte(8'hBB);
    wait_status(CLR_ACK, 200000);
    load_mem("PA24-V-01.mem");
    send_pack();
    wait_status(32'h010000A5, 2000000);

    // T8: after CLEAR_ACK, no ghost pack status
    send_word(CLR_CMD);
    wait_status(CLR_ACK, 200000);
    ghost = 0;
    for (c = 0; c < 4000; c++) begin
      @(posedge clk);
      if (host_valid && host_data !== CLR_ACK && host_data !== CLR_BUSY)
        ghost = 1;
    end
    if (ghost) begin
      $display("T8 FAIL ghost UART word after CLEAR_ACK");
      fail = fail + 1;
    end else begin
      $display("T8 PASS no ghost after CLEAR_ACK");
      pass = pass + 1;
    end

    // T5 UART: start V-02 then CLEAR mid-stream
    load_mem("PA24-V-02.mem");
    send_word(vec[0]);
    send_word(vec[1]);
    send_word(CLR_CMD);
    wait_status(CLR_BUSY, 200000);
    for (i = 2; i < nwords; i++) send_word(vec[i]);
    wait_status(32'h010000A5, 2000000);

    // T9: R-04 payload contains 0x4E51; pack_lock must not divert to query host
    send_word(CLR_CMD);
    wait_status(CLR_ACK, 200000);
    load_mem("PA24-R-04.mem");
    send_pack();
    wait_status(32'h010000A5, 2000000);

    // T10: extra CLEAR during hold must not flood FIFO (E handshake)
    send_word(CLR_CMD);
    send_word(CLR_CMD);
    send_word(CLR_CMD);
    wait_status(CLR_ACK, 400000);
    if (hold_wr_max >= 8) begin
      $display("T10 FAIL HOLD_WR_MAX=%0d", hold_wr_max);
      fail = fail + 1;
    end else begin
      $display("T10 PASS HOLD_WR_MAX=%0d", hold_wr_max);
      pass = pass + 1;
    end

    if (fail == 0)
      $display("PACK_DEBUG_CLEAR_UART_XSIM_PASS %0d (not PACK_ABI_24_24_PASS)", pass);
    else
      $display("PACK_DEBUG_CLEAR_UART_XSIM_FAIL fail=%0d pass=%0d", fail, pass);
    $finish;
  end
endmodule
