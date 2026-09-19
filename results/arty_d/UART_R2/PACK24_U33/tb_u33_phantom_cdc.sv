// tb_u33_phantom_cdc.sv — leftover BEGIN without TB injection?
// After GOLD+CLEAR, dump CDC/FIFO/lock then 5th V-04. Also leftover 00010001
// (V-04 ABI word, low byte OP_BEGIN but not exact 00800001).
// Dest=BRAM. PROGRAM=NO. Not PACK_ABI_24_24_PASS.
`timescale 1ns/1ps

module tb_u33_phantom_cdc;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 1_000_000;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam logic [31:0] CLR_CMD = 32'h44524743;
  localparam logic [31:0] CLR_ACK = 32'hC1EA50A5;
  localparam logic [31:0] GOLD    = 32'h010000A5;
  localparam logic [31:0] MAG     = 32'h0200015A;
  localparam logic [31:0] BEGINW  = 32'h00800001;
  localparam logic [31:0] MAGIC   = 32'h3149414E;
  localparam logic [31:0] ABI01   = 32'h00010001;

  logic clk100, ui_clk, rst100_n, rst_ui_n, uart_rx, uart_tx;
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
    .p_fire, .p_data, .load_ack, .load_reject, .reason_code
  );

  logic host_valid, host_seen, host_take;
  logic [31:0] host_data, host_cap;
  uart_rx_word #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_host (
    .clk(clk100), .rst_n(rst100_n), .rx(uart_tx),
    .w_valid(host_valid), .w_ready(1'b1), .w_data(host_data)
  );
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

  int n_p, n_ph;
  logic cap, cap_ph;
  logic [31:0] pw [0:7];
  logic [31:0] ph [0:7];
  always_ff @(posedge ui_clk or negedge rst_ui_n) begin
    if (!rst_ui_n) begin
      n_p <= 0;
      n_ph <= 0;
    end else begin
      if (!cap) n_p <= 0;
      else if (p_fire && n_p < 8) begin
        pw[n_p] <= p_data;
        n_p <= n_p + 1;
      end
      if (!cap_ph) n_ph <= 0;
      else if (p_fire && n_ph < 8) begin
        ph[n_ph] <= p_data;
        n_ph <= n_ph + 1;
      end
    end
  end

  logic [31:0] vec [0:1023];
  int nwords, i, c, rnd;
  logic [31:0] got;
  bit mute;
  int logfd;

  task automatic log1(input string s);
    begin
      $display("%s", s);
      $fdisplay(logfd, "%s", s);
      $fflush(logfd);
    end
  endtask

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

  task automatic dump_cdc(input string tag);
    begin
      log1($sformatf("%s lock=%0b empty=%0b f_valid=%0b f_data=%08h steer=%0b dest_acc=%0b",
                     tag, u_h.pack_lock, u_h.fifo_empty, u_h.f_valid, u_h.f_data,
                     u_h.steer_pack, u_h.dest_accept));
      log1($sformatf("%s cdc a_idle=%0b b_idle=%0b b_valid=%0b hold=%08h req_a=%0b last_b=%0b p_valid=%0b p_data=%08h n_ph=%0d ph0=%08h",
                     tag, u_h.u_cdc.a_idle, u_h.u_cdc.b_idle, u_h.u_cdc.b_valid,
                     u_h.u_cdc.hold, u_h.u_cdc.req_a, u_h.u_cdc.last_b,
                     u_h.p_valid, u_h.p_data_i, n_ph,
                     (n_ph > 0) ? ph[0] : 32'h0));
    end
  endtask

  task automatic send_v04();
    begin
      for (i = 0; i < nwords; i++) send_word(vec[i]);
    end
  endtask

  task automatic do_clear();
    begin
      send_word(CLR_CMD);
      wait_word(got, 400000, mute);
      if (mute || got !== CLR_ACK) begin
        log1($sformatf("FAIL CLEAR mute=%0d got=%08h", mute, got));
        $finish;
      end
    end
  endtask

  initial begin
    logfd = $fopen("u33_phantom_cdc.log", "w");
    cap = 1'b0;
    cap_ph = 1'b0;
    rst100_n = 0; rst_ui_n = 0; uart_rx = 1;
    repeat (20) @(posedge clk100);
    rst100_n = 1; rst_ui_n = 1;
    repeat (40) @(posedge clk100);
    force u_h.calib_ui = 1'b1;
    load_mem("PA24-V-04.mem");
    log1($sformatf("U33_PHANTOM nwords=%0d PACK_ABI_24_24_PASS=NO", nwords));

    do_clear();
    cap = 1'b1;
    send_v04();
    wait_word(got, 2_000_000, mute);
    log1($sformatf("GOLD0 mute=%0d got=%08h", mute, got));
    if (mute || got !== GOLD) begin
      log1("FAIL GOLD0");
      $finish;
    end

    cap_ph = 1'b1;
    do_clear();
    dump_cdc("AFTER_CLEAR1");
    repeat (20000) @(posedge clk100);
    dump_cdc("AFTER_CLEAR1_WAIT");
    if (n_ph > 0)
      log1($sformatf("PHANTOM_WORDS n=%0d ph0=%08h", n_ph, ph[0]));
    else
      log1("NO_PHANTOM_AFTER_CLEAR1");

    cap = 1'b0;
    repeat (4) @(posedge ui_clk);
    cap = 1'b1;
    send_v04();
    wait_word(got, 2_000_000, mute);
    log1($sformatf("V04_AFTER_PROBE mute=%0d got=%08h p0=%08h p1=%08h",
                   mute, got, (n_p > 0) ? pw[0] : 32'h0, (n_p > 1) ? pw[1] : 32'h0));
    if (!mute && got === MAG)
      log1("PROBE_THEN_V04_MAG");
    else if (!mute && got === GOLD)
      log1("PROBE_THEN_V04_GOLD no phantom BEGIN");
    else
      log1($sformatf("PROBE_THEN_V04_OTHER got=%08h", got));

    // Leftover ABI 00010001 (low byte OP_BEGIN, not exact pack_begin).
    do_clear();
    cap = 1'b0;
    repeat (4) @(posedge ui_clk);
    cap = 1'b1;
    send_word(ABI01);
    send_v04();
    wait_word(got, 2_000_000, mute);
    log1($sformatf("LEFTOVER_00010001 mute=%0d got=%08h p0=%08h p1=%08h n_p=%0d",
                   mute, got, (n_p > 0) ? pw[0] : 32'h0, (n_p > 1) ? pw[1] : 32'h0, n_p));
    if (!mute && got === MAG)
      log1("ABI01_LEFTOVER_MAG");
    else if (!mute && got === GOLD)
      log1("ABI01_LEFTOVER_GOLD unlocked drop (not exact BEGIN)");
    else
      log1($sformatf("ABI01_OTHER got=%08h", got));

    // Four GOLD then CLEAR+dump then 5th (board MAG cell, no inject).
    do_clear();
    cap = 1'b1;
    send_v04();
    wait_word(got, 2_000_000, mute);
    if (mute || got !== GOLD) begin log1("FAIL GOLD_PRE4"); $finish; end
    for (rnd = 0; rnd < 3; rnd++) begin
      do_clear();
      cap = 1'b0;
      repeat (4) @(posedge ui_clk);
      cap = 1'b1;
      send_v04();
      wait_word(got, 2_000_000, mute);
      log1($sformatf("PRE5_%0d mute=%0d got=%08h", rnd, mute, got));
      if (mute || got !== GOLD) begin
        log1("FAIL PRE5");
        $finish;
      end
    end
    cap_ph = 1'b0;
    repeat (2) @(posedge ui_clk);
    cap_ph = 1'b1;
    do_clear();
    dump_cdc("BEFORE_5TH");
    repeat (20000) @(posedge clk100);
    dump_cdc("BEFORE_5TH_WAIT");
    if (n_ph > 0)
      log1($sformatf("PHANTOM_BEFORE_5TH n=%0d ph0=%08h", n_ph, ph[0]));
    else
      log1("NO_PHANTOM_BEFORE_5TH");
    cap = 1'b0;
    repeat (4) @(posedge ui_clk);
    cap = 1'b1;
    send_v04();
    wait_word(got, 2_000_000, mute);
    log1($sformatf("V04_5 mute=%0d got=%08h p0=%08h p1=%08h n_ph=%0d",
                   mute, got, (n_p > 0) ? pw[0] : 32'h0, (n_p > 1) ? pw[1] : 32'h0, n_ph));
    if (!mute && got === MAG)
      log1("FIFTH_MAG_WITHOUT_INJECT");
    else if (!mute && got === GOLD)
      log1("FIFTH_GOLD_WITHOUT_INJECT BRAM");
    else
      log1($sformatf("FIFTH_OTHER got=%08h", got));

    log1("U33_PHANTOM_CDC_DONE PACK_ABI_24_24_PASS=NO");
    $fclose(logfd);
    $finish;
  end
endmodule
