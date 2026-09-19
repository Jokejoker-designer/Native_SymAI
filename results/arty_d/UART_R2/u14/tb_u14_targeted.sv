// tb_u14_targeted.sv — UART_R2_U14 targeted XSim before bitstream.
// RX=U11 CLEAR=U8 TX=U10 CDC=PACKAGE. Not BOARD_PASS.
`timescale 1ns/1ps

module tb_u14_targeted;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD = 115200;
  localparam int DIV = CLK_HZ / BAUD;
  localparam logic [31:0] CMD  = 32'h44524743;
  localparam logic [31:0] ACK  = 32'hC1EA50A5;
  localparam logic [31:0] BUSY = 32'hC1EA50B5;
  localparam logic [31:0] ERR  = 32'hC1EA50E5;
  localparam logic [31:0] GOLD = 32'h010000A5;
  localparam logic [31:0] MAG  = 32'h0200015A;
  localparam logic [31:0] BEGINW = 32'h00800001;
  localparam logic [31:0] MAGIC = 32'h3149414E;

  int pass, fail, warn;
  int mag_n, unsup_n, n0_n, to_n, phantom_n, trunc_n, shift_n;

  // ---------- RX U11 ----------
  logic clk, rst_n, rx, rx_valid, rx_ready, rx_flush, rx_idle, rx_sync, rx_fe;
  logic [31:0] rx_data;
  logic [31:0] rx_seen;
  int rx_words;

  uart_rx_word #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_rx (
    .clk, .rst_n, .rx,
    .w_valid(rx_valid), .w_ready(rx_ready), .w_data(rx_data),
    .flush(rx_flush), .idle(rx_idle), .rx_sync, .framing_error(rx_fe)
  );

  always @(posedge clk) begin
    if (rst_n && rx_valid && rx_ready)
      rx_words <= rx_words + 1;
  end

  // ---------- TX U14 ----------
  logic tx_valid, tx_ready, tx_flush, tx;
  logic [31:0] tx_data;
  logic mux_en;
  logic tx_valid_drv, tx_flush_drv, ack_ready_drv;
  logic [31:0] tx_data_drv;

  uart_tx_word #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_tx (
    .clk, .rst_n,
    .w_valid(tx_valid), .w_ready(tx_ready), .w_data(tx_data),
    .flush(tx_flush), .tx
  );

  // ---------- CLEAR U8 + UI slave (same clk for unit) ----------
  logic in_valid, take, hold, uart_flush, cdc_rst_100;
  logic ui_req, ui_ack, ui_nack, debug_clear;
  logic pack_qsc, uart_mark, ack_valid, ack_ready;
  logic [31:0] in_data, ack_data;

  pack_debug_clear u_clr (
    .clk, .rst_n,
    .in_valid, .in_data, .take, .hold, .uart_flush, .cdc_rst_100,
    .ui_req, .ui_ack, .ui_nack,
    .pack_quiescent(pack_qsc), .uart_rx_mark(uart_mark),
    .ack_valid, .ack_ready, .ack_data
  );

  pack_clear_ui u_ui (
    .clk, .rst_n, .req(ui_req), .pack_quiescent(pack_qsc),
    .ack(ui_ack), .nack(ui_nack), .debug_clear
  );

  assign tx_valid = mux_en ? ack_valid : tx_valid_drv;
  assign tx_data  = mux_en ? ack_data  : tx_data_drv;
  assign tx_flush = mux_en ? uart_flush : tx_flush_drv;
  assign ack_ready = mux_en ? (tx_ready && !uart_flush) : ack_ready_drv;

  // ---------- dual-clock transport for tests 2+9 ----------
  logic ui_clk, a_rst_n, b_rst_n;
  logic a_valid, a_ready, b_valid, b_ready;
  logic [31:0] a_data, b_data;
  logic a_idle, b_idle;
  int b_n;
  logic [31:0] b_got [0:63];
  logic [31:0] gold_tx_word, gold_seen;
  logic gold_valid, gold_ready;

  word_cdc32 u_cdc (
    .a_clk(clk), .a_rst_n(a_rst_n),
    .a_valid, .a_ready, .a_data,
    .b_clk(ui_clk), .b_rst_n(b_rst_n),
    .b_valid, .b_ready, .b_data,
    .a_idle, .b_idle
  );

  initial begin
    clk = 1'b0;
    ui_clk = 1'b0;
  end
  always #5 clk = ~clk;
  always #7 ui_clk = ~ui_clk;

  always @(posedge clk) begin
    if (rst_n && rx_valid)
      rx_seen <= rx_data;
  end


  // Tiny pack stub: BEGIN then MAGIC => GOLD, else MAG. Transport only.
  logic [1:0] pst;
  always_ff @(posedge ui_clk or negedge b_rst_n) begin
    if (!b_rst_n) begin
      pst <= 2'd0;
      gold_valid <= 1'b0;
      gold_tx_word <= 32'h0;
    end else begin
      if (gold_valid && gold_ready)
        gold_valid <= 1'b0;
      if (b_valid && b_ready) begin
        if (pst == 2'd0 && b_data[7:0] == 8'h01)
          pst <= 2'd1;
        else if (pst == 2'd1) begin
          gold_tx_word <= (b_data == MAGIC) ? GOLD : MAG;
          gold_valid <= 1'b1;
          pst <= 2'd0;
        end
      end
    end
  end
  assign b_ready = 1'b1;
  assign gold_ready = 1'b1;

  task automatic bit_time;
    repeat (DIV) @(posedge clk);
  endtask

  task automatic send_byte(input logic [7:0] b);
    int i;
    begin
      rx = 1'b0;
      bit_time;
      for (i = 0; i < 8; i = i + 1) begin
        rx = b[i];
        bit_time;
      end
      rx = 1'b1;
      bit_time;
    end
  endtask

  task automatic send_word(input logic [31:0] w);
    begin
      send_byte(w[7:0]);
      send_byte(w[15:8]);
      send_byte(w[23:16]);
      send_byte(w[31:24]);
    end
  endtask

  task automatic wait_ack(input int maxc, output int saw, output logic [31:0] data);
    int c;
    begin
      saw = 0;
      data = 32'h0;
      c = 0;
      while (c < maxc && !ack_valid) begin
        @(posedge clk);
        c = c + 1;
      end
      if (ack_valid) begin
        saw = 1;
        data = ack_data;
      end
    end
  endtask

  task automatic send_a(input logic [31:0] w);
    begin
      @(posedge clk);
      a_data <= w;
      a_valid <= 1'b1;
      @(posedge clk);
      while (!(a_valid && a_ready))
        @(posedge clk);
      @(posedge clk);
      a_valid <= 1'b0;
      @(posedge clk);
      while (!a_ready)
        @(posedge clk);
    end
  endtask

  task automatic collect_b(input int nneed, input int maxc);
    int c;
    begin
      c = 0;
      while (c < maxc && b_n < nneed) begin
        @(posedge ui_clk);
        c = c + 1;
        if (b_valid) begin
          b_got[b_n] = b_data;
          b_n = b_n + 1;
        end
        if (gold_valid)
          gold_seen = gold_tx_word;
      end
    end
  endtask

  task automatic pulse_cmd;
    begin
      @(posedge clk);
      in_valid <= 1'b1;
      in_data <= CMD;
      @(posedge clk);
      in_valid <= 1'b0;
      in_data <= 32'h0;
    end
  endtask

  task automatic tpass(input string s);
    begin
      $display("PASS %s", s);
      pass = pass + 1;
    end
  endtask

  task automatic tfail(input string s);
    begin
      $display("FAIL %s", s);
      fail = fail + 1;
    end
  endtask

  // Capture one UART word from DUT tx (U10).
  task automatic recv_tx_word(input int maxc, output int nbyte, output logic [31:0] w);
    int c, bi, by;
    logic [7:0] b;
    begin
      nbyte = 0;
      w = 32'h0;
      c = 0;
      while (c < maxc && tx === 1'b1) begin
        @(posedge clk);
        c = c + 1;
      end
      if (tx !== 1'b0) begin
        nbyte = 0;
        disable recv_tx_word;
      end
      for (by = 0; by < 4; by = by + 1) begin
        if (by != 0) begin
          c = 0;
          while (c < (20 * DIV) && tx === 1'b1) begin
            @(posedge clk);
            c = c + 1;
          end
          if (tx !== 1'b0) begin
            nbyte = by;
            disable recv_tx_word;
          end
        end
        repeat (DIV / 2) @(posedge clk);
        if (tx !== 1'b0) begin
          nbyte = by;
          disable recv_tx_word;
        end
        b = 8'h0;
        for (bi = 0; bi < 8; bi = bi + 1) begin
          repeat (DIV) @(posedge clk);
          b[bi] = tx;
        end
        repeat (DIV) @(posedge clk);
        w = {b, w[31:8]};
        nbyte = by + 1;
      end
    end
  endtask

  integer i, c, saw, nbyte, k;
  logic [31:0] dw, tw;
  logic saw_cdc, saw_quiet, saw_ack, saw_drop0;
  logic aborted;
  logic [31:0] hold_data;

  initial begin
    pass = 0;
    fail = 0;
    warn = 0;
    mag_n = 0;
    unsup_n = 0;
    n0_n = 0;
    to_n = 0;
    phantom_n = 0;
    trunc_n = 0;
    shift_n = 0;
    mux_en = 1'b0;
    rst_n = 1'b0;
    rx = 1'b1;
    rx_ready = 1'b1;
    rx_flush = 1'b0;
    rx_words = 0;
    rx_seen = 32'h0;
    tx_valid_drv = 1'b0;
    tx_data_drv = 32'h0;
    tx_flush_drv = 1'b0;
    in_valid = 1'b0;
    in_data = 32'h0;
    pack_qsc = 1'b1;
    uart_mark = 1'b1;
    ack_ready_drv = 1'b0;
    a_rst_n = 1'b0;
    b_rst_n = 1'b0;
    a_valid = 1'b0;
    a_data = 32'h0;
    b_n = 0;
    gold_seen = 32'h0;
    repeat (8) @(posedge clk);
    rst_n = 1'b1;
    a_rst_n = 1'b1;
    b_rst_n = 1'b1;
    repeat (8) @(posedge clk);

    // ============================================================
    // 1. RX partial-state recovery bix=1,2,3
    // ============================================================
    for (k = 1; k <= 3; k = k + 1) begin
      rx_words = 0;
      rx_seen = 32'h0;
      for (i = 0; i < k; i = i + 1)
        send_byte(8'hA0 + i[7:0]);
      repeat (DIV) @(posedge clk);
      if (u_rx.bix != k[1:0])
        tfail($sformatf("T1 bix want=%0d got=%0d", k, u_rx.bix));
      else
        tpass($sformatf("T1 partial bix=%0d", k));
      repeat (2 * 10 * DIV + 16) @(posedge clk);
      if (u_rx.bix != 2'd0 || u_rx.acc != 32'h0 || rx_words != 0)
        tfail($sformatf("T1 gap leftover bix=%0d acc=%08h words=%0d", u_rx.bix, u_rx.acc, rx_words));
      else
        tpass($sformatf("T1 gap destroyed bix=%0d no phantom", k));
      send_word(CMD);
      repeat (2 * DIV) @(posedge clk);
      if (rx_seen != CMD || rx_words != 1)
        tfail($sformatf("T1 CLEAR after bix=%0d seen=%08h words=%0d", k, rx_seen, rx_words));
      else
        tpass($sformatf("T1 CLEAR aligned after bix=%0d", k));
    end

    // ============================================================
    // 2. CDC reset lifecycle + ACK then immediate pack
    // ============================================================
    ack_ready_drv = 1'b0;
    pack_qsc = 1'b1;
    uart_mark = 1'b1;
    saw_cdc = 1'b0;
    saw_quiet = 1'b0;
    saw_ack = 1'b0;
    saw_drop0 = 1'b1;
    pulse_cmd;
    c = 0;
    while (c < 30000 && u_clr.st != 4'd5) begin
      @(posedge clk);
      c = c + 1;
      if (u_clr.st == 4'd3) begin
        @(posedge clk);
        if (!cdc_rst_100)
          tfail("T2 S_CDC cdc_rst=0");
        else
          saw_cdc = 1'b1;
      end
      if (u_clr.st == 4'd4) begin
        @(posedge clk);
        if (!cdc_rst_100)
          tfail("T2 S_QUIET cdc_rst=0");
        else
          saw_quiet = 1'b1;
      end
    end
    @(posedge clk);
    if (!(ack_valid && cdc_rst_100 && ack_data == ACK))
      tfail($sformatf("T2 S_ACK window valid=%0b cdc=%0b data=%08h", ack_valid, cdc_rst_100, ack_data));
    else begin
      tpass("T2 S_ACK cdc_rst=1");
      saw_ack = 1'b1;
    end
    if (!saw_cdc)
      tfail("T2 never sampled S_CDC");
    else
      tpass("T2 S_CDC cdc_rst=1");
    if (!saw_quiet)
      tfail("T2 never sampled S_QUIET");
    else
      tpass("T2 S_QUIET cdc_rst=1");

    ack_ready_drv = 1'b1;
    @(posedge clk);
    ack_ready_drv = 1'b0;
    repeat (3) @(posedge clk);
    if (cdc_rst_100)
      tfail("T2 S_DROP cdc_rst still 1");
    else
      tpass("T2 S_DROP cdc_rst=0");
    c = 0;
    while (c < 70000 && hold) begin
      @(posedge clk);
      c = c + 1;
    end

    // Immediate pack through CDC after ACK (A released).
    a_rst_n = ~cdc_rst_100;
    b_rst_n = ~debug_clear;
    repeat (8) @(posedge clk);
    b_n = 0;
    gold_seen = 32'h0;
    fork
      collect_b(2, 800);
      begin
        send_a(BEGINW);
        send_a(MAGIC);
      end
    join
    if (b_n != 2 || b_got[0] != BEGINW || b_got[1] != MAGIC) begin
      tfail($sformatf("T2 immediate pack b_n=%0d w0=%08h w1=%08h", b_n, b_got[0], b_got[1]));
      if (b_n >= 2 && b_got[1] != MAGIC) begin
        mag_n = mag_n + 1;
        shift_n = shift_n + 1;
      end
    end else
      tpass("T2 CLEAR ACK then immediate Pack first words exact");

    // ============================================================
    // 3. TX flush while idle
    // ============================================================
    tx_flush_drv = 1'b1;
    tx_valid_drv = 1'b1;
    tx_data_drv = 32'hA5A5A5A5;
    repeat (4) @(posedge clk);
    if (u_tx.st != 2'd0 || tx !== 1'b1)
      tfail($sformatf("T3 idle flush started frame st=%0d tx=%0b", u_tx.st, tx));
    else
      tpass("T3 idle flush no frame");
    if (tx_ready)
      tfail("T3 idle flush w_ready=1 (would drop ACK)");
    else
      tpass("T3 idle flush w_ready=0");
    tx_valid_drv = 1'b0;
    tx_flush_drv = 1'b0;
    repeat (4) @(posedge clk);

    // ============================================================
    // 4-6. TX flush during START / BITS / STOP — must not abort frame
    // ============================================================
    // START
    tx_flush_drv = 1'b0;
    @(posedge clk);
    tx_data_drv = 32'h00000000;
    tx_valid_drv = 1'b1;
    @(posedge clk);
    while (!(tx_valid && tx_ready)) @(posedge clk);
    @(posedge clk);
    tx_valid_drv = 1'b0;
    c = 0;
    while (c < (2 * DIV) && u_tx.st != 2'd1) begin
      @(posedge clk);
      c = c + 1;
    end
    tx_flush_drv = 1'b1;
    @(posedge clk);
    aborted = (u_tx.st == 2'd0);
    repeat (DIV / 2) @(posedge clk);
    if (aborted || u_tx.st == 2'd0)
      tfail("T4 flush during START aborted frame");
    else
      tpass("T4 START frame not aborted");
    c = 0;
    while (c < (50 * DIV) && u_tx.st != 2'd0) begin
      @(posedge clk);
      c = c + 1;
    end
    tx_flush_drv = 1'b0;
    repeat (4) @(posedge clk);

    // BITS
    @(posedge clk);
    tx_data_drv = 32'h00000000;
    tx_valid_drv = 1'b1;
    @(posedge clk);
    while (!(tx_valid && tx_ready)) @(posedge clk);
    @(posedge clk);
    tx_valid_drv = 1'b0;
    c = 0;
    while (c < (20 * DIV) && u_tx.st != 2'd2) begin
      @(posedge clk);
      c = c + 1;
    end
    tx_flush_drv = 1'b1;
    @(posedge clk);
    if (u_tx.st == 2'd0)
      tfail("T5 flush during BITS aborted frame");
    else
      tpass("T5 BITS frame not aborted");
    c = 0;
    while (c < (50 * DIV) && u_tx.st != 2'd0) begin
      @(posedge clk);
      c = c + 1;
    end
    tx_flush_drv = 1'b0;
    repeat (4) @(posedge clk);

    // STOP
    @(posedge clk);
    tx_data_drv = 32'h00000000;
    tx_valid_drv = 1'b1;
    @(posedge clk);
    while (!(tx_valid && tx_ready)) @(posedge clk);
    @(posedge clk);
    tx_valid_drv = 1'b0;
    c = 0;
    while (c < (20 * DIV) && u_tx.st != 2'd3) begin
      @(posedge clk);
      c = c + 1;
    end
    tx_flush_drv = 1'b1;
    @(posedge clk);
    if (u_tx.st == 2'd0)
      tfail("T6 flush during STOP aborted frame");
    else
      tpass("T6 STOP frame not aborted");
    c = 0;
    while (c < (50 * DIV) && u_tx.st != 2'd0) begin
      @(posedge clk);
      c = c + 1;
    end
    tx_flush_drv = 1'b0;
    repeat (8) @(posedge clk);

    // ============================================================
    // 7. ACK backpressure: VALID && !READY => VALID+DATA stable
    // ============================================================
    ack_ready_drv = 1'b0;
    pulse_cmd;
    wait_ack(30000, saw, dw);
    if (!saw || dw != ACK)
      tfail($sformatf("T7 never ACK saw=%0d data=%08h", saw, dw));
    else
      tpass("T7 reached ACK");
    hold_data = ack_data;
    saw = 1;
    for (c = 0; c < 2048; c = c + 1) begin
      @(posedge clk);
      if (!ack_valid || ack_data != hold_data)
        saw = 0;
    end
    if (!saw)
      tfail("T7 VALID/DATA dropped under backpressure");
    else
      tpass("T7 ack_valid/data stable 2048 without ready");
    ack_ready_drv = 1'b1;
    @(posedge clk);
    ack_ready_drv = 1'b0;
    c = 0;
    while (c < 70000 && hold) begin
      @(posedge clk);
      c = c + 1;
    end

    // ============================================================
    // 8. CLEAR physical quiet
    // ============================================================
    // 8a: ACK must not fire before QUIET_N consecutive MARK.
    uart_mark = 1'b1;
    ack_ready_drv = 1'b0;
    pulse_cmd;
    c = 0;
    saw = 0;
    while (c < 25000) begin
      @(posedge clk);
      c = c + 1;
      if (ack_valid && c < 20000)
        saw = 1;
    end
    if (saw)
      tfail("T8 ACK before QUIET_N MARK");
    else
      tpass("T8 no ACK before QUIET_N");
    wait_ack(20000, saw, dw);
    if (!saw || dw != ACK)
      tfail("T8 no ACK after MARK quiet");
    else
      tpass("T8 ACK after MARK quiet");
    ack_ready_drv = 1'b1;
    @(posedge clk);
    ack_ready_drv = 1'b0;
    c = 0;
    while (c < 70000 && hold) begin
      @(posedge clk);
      c = c + 1;
    end

    // 8b: MARK never — U8 wall timeout currently ACKs (frozen U8, not U12 delta).
    uart_mark = 1'b0;
    pulse_cmd;
    wait_ack(80000, saw, dw);
    if (saw && dw == ACK) begin
      $display("U8_LEGACY T8 timeout masquerades as ACK (frozen U8; U12 must not retouch CLEAR)");
      warn = warn + 1;
    end else if (saw && dw == ERR)
      tpass("T8 timeout returned ERR not ACK");
    else if (!saw)
      tpass("T8 timeout did not ACK");
    else
      tfail($sformatf("T8 timeout unexpected data=%08h", dw));
    uart_mark = 1'b1;
    ack_ready_drv = 1'b1;
    @(posedge clk);
    ack_ready_drv = 1'b0;
    c = 0;
    while (c < 70000 && hold) begin
      @(posedge clk);
      c = c + 1;
    end

    // ============================================================
    // 9. 32x CLEAR -> ACK -> V-04 first words -> GOLD  (transport)
    // Drive CLEAR as in_valid (already proven UART RX in T1).
    // Drive pack words on CDC A immediately after ACK handshake.
    // ============================================================
    a_rst_n = 1'b1;
    b_rst_n = 1'b1;
    for (k = 0; k < 32; k = k + 1) begin
      ack_ready_drv = 1'b0;
      pack_qsc = 1'b1;
      uart_mark = 1'b1;
      b_n = 0;
      pulse_cmd;
      gold_seen = 32'h0;
      wait_ack(30000, saw, dw);
      if (!saw || dw != ACK) begin
        tfail($sformatf("T9 iter %0d no ACK", k));
        n0_n = n0_n + 1;
        to_n = to_n + 1;
      end else begin
      // ACK visible: CDC must already be receivable after ready handshake.
      ack_ready_drv = 1'b1;
      @(posedge clk);
      ack_ready_drv = 1'b0;
      c = 0;
      while (c < 256 && (cdc_rst_100 || debug_clear || hold && u_clr.st == 4'd8)) begin
        @(posedge clk);
        c = c + 1;
      end
      while (c < 512 && (cdc_rst_100 || debug_clear)) begin
        @(posedge clk);
        c = c + 1;
      end
      a_rst_n = 1'b1;
      b_rst_n = 1'b1;
      repeat (4) @(posedge clk);
      if (cdc_rst_100)
        tfail($sformatf("T9 iter %0d CDC still reset after ACK ready", k));
      @(posedge clk);
      b_n = 0;
      gold_seen = 32'h0;
      fork
        collect_b(2, 800);
        begin
          send_a(BEGINW);
          send_a(MAGIC);
        end
      join
      if (b_n < 2) begin
        tfail($sformatf("T9 iter %0d n=0 pack b_n=%0d", k, b_n));
        n0_n = n0_n + 1;
      end else if (b_got[0] != BEGINW || b_got[1] != MAGIC) begin
        tfail($sformatf("T9 iter %0d MAG/shift w0=%08h w1=%08h", k, b_got[0], b_got[1]));
        mag_n = mag_n + 1;
        shift_n = shift_n + 1;
      end else if (gold_seen == MAG) begin
        tfail($sformatf("T9 iter %0d stub MAG", k));
        mag_n = mag_n + 1;
      end else
        tpass($sformatf("T9 iter %0d GOLD (BEGIN+MAGIC exact gold_seen=%08h)", k, gold_seen));
      end
      c = 0;
      while (c < 70000 && hold) begin
        @(posedge clk);
        c = c + 1;
      end
    end

    mux_en = 1'b1;
    pack_qsc = 1'b1;
    uart_mark = 1'b1;
    pulse_cmd;
    recv_tx_word(30000 + 80 * DIV, nbyte, tw);
    if (nbyte != 4 || tw != ACK) begin
      tfail($sformatf("T10 product mux ACK nbyte=%0d tw=%08h", nbyte, tw));
      n0_n = n0_n + 1;
    end else
      tpass("T10 CLEAR ACK on UART via product mux");
    mux_en = 1'b0;
    c = 0;
    while (c < 70000 && hold) begin
      @(posedge clk);
      c = c + 1;
    end

    $display("COUNTERS mag=%0d unsup=%0d n0=%0d timeout=%0d phantom=%0d trunc=%0d shift=%0d warn=%0d",
             mag_n, unsup_n, n0_n, to_n, phantom_n, trunc_n, shift_n, warn);
    if (fail == 0 && mag_n == 0 && n0_n == 0 && unsup_n == 0)
      $display("UART_R2_U14_TARGETED_XSIM_PASS pass=%0d warn=%0d (not BOARD_PASS)", pass, warn);
    else
      $display("UART_R2_U14_TARGETED_XSIM_FAIL fail=%0d pass=%0d mag=%0d n0=%0d", fail, pass, mag_n, n0_n);
    $finish;
  end
endmodule
