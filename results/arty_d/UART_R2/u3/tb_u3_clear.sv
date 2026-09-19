// tb_u3_clear.sv — UART_R2_U3 CLEAR destroys logical partial state.
// Physical UART idle (rx_s/rx_d) is not zeroed. idle requires MARK.
// XSim != board. Not PACK_ABI_24_24_PASS / not BOARD_PASS.
`timescale 1ns/1ps

module tb_u3_clear;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 1_000_000;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam logic [31:0] W0 = 32'hA1B2C3D4;
  localparam logic [31:0] FRESH = 32'h55667788;
  localparam logic [31:0] Q0 = 32'h00004E51;

  logic clk, rst_n, rx, flush, w_valid, w_ready, ferr, ready_gate, rx_idle;
  logic [31:0] w_data;
  uart_rx_word #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_rx (
    .clk, .rst_n, .rx, .w_valid, .w_ready, .w_data,
    .flush, .idle(rx_idle), .rx_sync(), .framing_error(ferr)
  );
  assign w_ready = ready_gate;

  logic fifo_rst_n, fifo_wr_ready, f_valid, f_ready, fifo_empty, fifo_flush;
  logic fifo_wr_v;
  logic [31:0] fifo_wr_d;
  logic [31:0] f_data;
  logic [7:0] used;
  word_fifo32 #(.DEPTH(128)) u_fifo (
    .clk, .rst_n(fifo_rst_n),
    .wr_valid(fifo_wr_v), .wr_ready(fifo_wr_ready), .wr_data(fifo_wr_d),
    .rd_valid(f_valid), .rd_ready(f_ready), .rd_data(f_data),
    .flush(fifo_flush), .empty(fifo_empty), .used_o(used)
  );

  logic q_rst_n, q_in_valid, q_in_ready, q_taking, q_valid, q_ready;
  logic [31:0] q_in_data, gen_snap;
  logic [7:0] q_bytes [0:31];
  logic [7:0] dummy_r [0:47];
  uart_fe256_host u_q (
    .clk, .rst_n(q_rst_n),
    .in_valid(q_in_valid), .in_ready(q_in_ready), .in_data(q_in_data),
    .taking(q_taking),
    .q_valid, .q_ready, .q_bytes,
    .r_valid(1'b0), .r_ready(), .r_bytes(dummy_r),
    .tx_valid(), .tx_ready(1'b1), .tx_data(),
    .active_generation(32'h00000011), .query_generation_snapshot(gen_snap)
  );

  logic cdc_rst_n, a_valid, a_ready, b_valid, b_ready;
  logic [31:0] a_data, b_data;
  word_cdc32 u_cdc (
    .a_clk(clk), .a_rst_n(cdc_rst_n),
    .a_valid, .a_ready, .a_data,
    .b_clk(clk), .b_rst_n(cdc_rst_n),
    .b_valid, .b_ready, .b_data, .a_idle(), .b_idle()
  );

  logic p_rst_n, s_valid, s_ready, mem_cmd_valid, mem_cmd_ready, mem_cmd_write;
  logic mem_resp_valid, mem_resp_ready, mem_resp_err;
  logic [27:0] mem_addr;
  logic [31:0] s_data, mem_wdata, mem_rdata, active_generation;
  logic load_ack, load_reject, loader_busy;
  logic [7:0] reason_code;
  logic [15:0] wr_outstanding;
  pack_loader u_ld (
    .clk, .rst_n(p_rst_n), .s_valid, .s_ready, .s_data,
    .mem_cmd_valid, .mem_cmd_ready, .mem_cmd_write, .mem_addr, .mem_wdata,
    .mem_resp_valid, .mem_resp_ready, .mem_resp_err, .mem_rdata,
    .load_ack, .load_reject, .reason_code, .active_generation, .wr_outstanding, .loader_busy
  );
  assign mem_cmd_ready = 1'b1;
  assign mem_resp_err = 1'b0;
  assign mem_rdata = 32'h0;
  assign mem_resp_valid = 1'b0;

  initial clk = 1'b0;
  always #5 clk = ~clk;

  int n_w, n_cdc, fail;
  logic [31:0] got_w [0:15];
  integer i, qsum;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      n_w <= 0;
    else if (w_valid && w_ready && !flush) begin
      got_w[n_w] <= w_data;
      n_w <= n_w + 1;
    end
  end

  always @(posedge clk or negedge cdc_rst_n) begin
    if (!cdc_rst_n)
      n_cdc <= 0;
    else if (b_valid && b_ready) begin
      n_cdc <= n_cdc + 1;
    end
  end

  task automatic reset_all;
    begin
      rst_n = 1'b0; fifo_rst_n = 1'b0; q_rst_n = 1'b0; cdc_rst_n = 1'b0; p_rst_n = 1'b0;
      rx = 1'b1; flush = 1'b0; ready_gate = 1'b1;
      fifo_flush = 1'b0; fifo_wr_v = 1'b0; fifo_wr_d = 32'h0; f_ready = 1'b0;
      q_in_valid = 1'b0; q_in_data = 32'h0; q_ready = 1'b1;
      a_valid = 1'b0; a_data = 32'h0; b_ready = 1'b1;
      s_valid = 1'b0; s_data = 32'h0;
      repeat (8) @(posedge clk);
      rst_n = 1'b1; fifo_rst_n = 1'b1; q_rst_n = 1'b1; cdc_rst_n = 1'b1; p_rst_n = 1'b1;
      repeat (8) @(posedge clk);
    end
  endtask

  task automatic uart_byte(input logic [7:0] b);
    int k;
    begin
      rx <= 1'b0;
      repeat (DIV) @(posedge clk);
      for (k = 0; k < 8; k++) begin
        rx <= b[k];
        repeat (DIV) @(posedge clk);
      end
      rx <= 1'b1;
      repeat (DIV) @(posedge clk);
    end
  endtask

  task automatic send_word(input logic [31:0] w);
    begin
      uart_byte(w[7:0]); uart_byte(w[15:8]); uart_byte(w[23:16]); uart_byte(w[31:24]);
    end
  endtask

  task automatic do_clear_rx;
    begin
      flush = 1'b1;
      repeat (4) @(posedge clk);
      flush = 1'b0;
      repeat (4) @(posedge clk);
    end
  endtask

  initial begin
    $display("UART_R2_U3_CLEAR_XSIM start");
    fail = 0;
    for (i = 0; i < 48; i++) dummy_r[i] = 8'h0;

    reset_all();
    uart_byte(W0[7:0]);
    if (u_rx.bix != 2'd1) fail = fail + 1;
    do_clear_rx();
    if (u_rx.bix != 2'd0 || w_valid || u_rx.stop_hold) begin
      $display("U3 CHECK_FAIL BIX1 leftover bix=%0d v=%0b hold=%0b", u_rx.bix, w_valid, u_rx.stop_hold);
      fail = fail + 1;
    end
    send_word(FRESH);
    repeat (DIV * 2) @(posedge clk);
    if (n_w != 1 || got_w[0] !== FRESH) begin
      $display("U3 CHECK_FAIL BIX1 post %0d %08h", n_w, got_w[0]);
      fail = fail + 1;
    end else $display("U3 CHECK_OK BIX1");

    reset_all();
    uart_byte(W0[7:0]); uart_byte(W0[15:8]);
    if (u_rx.bix != 2'd2) fail = fail + 1;
    do_clear_rx();
    send_word(FRESH);
    repeat (DIV * 2) @(posedge clk);
    if (got_w[0] !== FRESH) fail = fail + 1;
    else $display("U3 CHECK_OK BIX2");

    reset_all();
    uart_byte(W0[7:0]); uart_byte(W0[15:8]); uart_byte(W0[23:16]);
    if (u_rx.bix != 2'd3) fail = fail + 1;
    do_clear_rx();
    send_word(FRESH);
    repeat (DIV * 2) @(posedge clk);
    if (got_w[0] !== FRESH) fail = fail + 1;
    else $display("U3 CHECK_OK BIX3");

    reset_all();
    ready_gate = 1'b0;
    send_word(W0);
    repeat (DIV) @(posedge clk);
    if (!w_valid || w_data !== W0) begin
      $display("U3 CHECK_FAIL pending not sitting");
      fail = fail + 1;
    end
    do_clear_rx();
    ready_gate = 1'b1;
    repeat (16) @(posedge clk);
    if (w_valid) begin
      $display("U3 CHECK_FAIL pending emerged after CLEAR");
      fail = fail + 1;
    end
    send_word(FRESH);
    repeat (DIV * 2) @(posedge clk);
    if (n_w != 1 || got_w[0] !== FRESH) begin
      $display("U3 CHECK_FAIL pending mix n=%0d %08h", n_w, got_w[0]);
      fail = fail + 1;
    end else $display("U3 CHECK_OK PENDING_OUTPUT");

    reset_all();
    f_ready = 1'b0;
    @(posedge clk);
    fifo_wr_v = 1'b1; fifo_wr_d = W0; @(posedge clk);
    fifo_wr_d = 32'hAABBCCDD; @(posedge clk);
    fifo_wr_v = 1'b0;
    @(posedge clk);
    if (used < 2) begin
      $display("U3 CHECK_FAIL FIFO used=%0d", used);
      fail = fail + 1;
    end
    fifo_flush = 1'b1;
    repeat (2) @(posedge clk);
    fifo_flush = 1'b0;
    f_ready = 1'b1;
    repeat (8) @(posedge clk);
    if (!fifo_empty || f_valid) begin
      $display("U3 CHECK_FAIL FIFO leftover empty=%0b v=%0b used=%0d", fifo_empty, f_valid, used);
      fail = fail + 1;
    end else $display("U3 CHECK_OK FIFO_NONEMPTY");

    reset_all();
    q_in_valid = 1'b1; q_in_data = Q0; @(posedge clk);
    q_in_data = 32'h11111111; @(posedge clk);
    q_in_data = 32'h22222222; @(posedge clk);
    q_in_valid = 1'b0;
    @(posedge clk);
    if (q_valid) fail = fail + 1;
    qsum = 0;
    for (i = 0; i < 32; i++) qsum = qsum + q_bytes[i];
    if (qsum != 0) begin
      $display("U3 CHECK_FAIL partial q_bytes sum=%0d", qsum);
      fail = fail + 1;
    end
    q_rst_n = 1'b0;
    repeat (4) @(posedge clk);
    q_rst_n = 1'b1;
    repeat (4) @(posedge clk);
    if (u_q.wix != 3'h0 || q_valid) begin
      $display("U3 CHECK_FAIL query leftover wix=%0d qv=%0b", u_q.wix, q_valid);
      fail = fail + 1;
    end else $display("U3 CHECK_OK PARTIAL_QUERY");

    reset_all();
    b_ready = 1'b0;
    a_valid = 1'b1; a_data = W0;
    repeat (8) @(posedge clk);
    a_valid = 1'b0;
    cdc_rst_n = 1'b0;
    repeat (4) @(posedge clk);
    cdc_rst_n = 1'b1;
    b_ready = 1'b1;
    repeat (16) @(posedge clk);
    if (n_cdc != 0) begin
      $display("U3 CHECK_FAIL CDC leftover n=%0d", n_cdc);
      fail = fail + 1;
    end else $display("U3 CHECK_OK CDC_PENDING");

    // Physical MARK: flush must not force rx_d=1 while the line is low.
    reset_all();
    uart_byte(W0[7:0]);
    rx = 1'b0;
    repeat (8) @(posedge clk);
    if (u_rx.rx_d !== 1'b0) begin
      $display("U3 CHECK_FAIL rx_d not low before flush");
      fail = fail + 1;
    end
    flush = 1'b1;
    repeat (4) @(posedge clk);
    if (u_rx.rx_d !== 1'b0) begin
      $display("U3 CHECK_FAIL flush zeroed physical rx_d");
      fail = fail + 1;
    end
    if (rx_idle) begin
      $display("U3 CHECK_FAIL idle true while line LOW (QUIET would lie)");
      fail = fail + 1;
    end
    if (!u_rx.need_mark) begin
      $display("U3 CHECK_FAIL need_mark not set on flush-while-low");
      fail = fail + 1;
    end
    flush = 1'b0;
    rx = 1'b1;
    repeat (8) @(posedge clk);
    if (!rx_idle) begin
      $display("U3 CHECK_FAIL idle not recovered after MARK");
      fail = fail + 1;
    end else $display("U3 CHECK_OK PHYSICAL_MARK_IDLE");

    // Pack command partial then debug_clear-style rst
    reset_all();
    s_valid = 1'b1; s_data = 32'h0008_0001;
    @(posedge clk);
    while (!s_ready) @(posedge clk);
    @(posedge clk);
    s_data = 32'h3149414E;
    @(posedge clk);
    s_valid = 1'b0;
    @(posedge clk);
    if (u_ld.state == 4'd0) begin
      $display("U3 CHECK_FAIL pack not in S_RX");
      fail = fail + 1;
    end
    p_rst_n = 1'b0;
    repeat (4) @(posedge clk);
    p_rst_n = 1'b1;
    repeat (4) @(posedge clk);
    if (u_ld.state != 4'd0 || u_ld.rx_words != 16'd0) begin
      $display("U3 CHECK_FAIL pack leftover st=%0d rxw=%0d", u_ld.state, u_ld.rx_words);
      fail = fail + 1;
    end
    if (active_generation !== 32'hFFFF_FFFF) begin
      $display("U3 CHECK_INFO CLEAR of loader also resets generation (VALIDATION_CLEAR)");
    end
    s_valid = 1'b1; s_data = 32'h0000_0099;
    @(posedge clk);
    while (!s_ready) @(posedge clk);
    @(posedge clk);
    s_valid = 1'b0;
    repeat (20) @(posedge clk);
    $display("U3 CHECK_OK PARTIAL_PACK_CMD");

    if (fail == 0)
      $display("UART_R2_U3_CLEAR_XSIM_PASS");
    else
      $display("UART_R2_U3_CLEAR_XSIM_FAIL fail=%0d", fail);
    $finish;
  end
endmodule
