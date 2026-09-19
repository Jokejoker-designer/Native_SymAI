// tb_u33_leftover_begin_mag.sv — M4 leftover inject vs board MAG 0200015a.
// Dest=mig_ui_bram, bind=U33. Does not touch running mig0 xsim_u33m.
// PROGRAM=NO. Not PACK_ABI_24_24_PASS / BOARD_PASS / MIG_PASS.
`timescale 1ns/1ps

module tb_u33_leftover_begin_mag;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 1_000_000;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam logic [31:0] CLR_CMD = 32'h44524743;
  localparam logic [31:0] CLR_ACK = 32'hC1EA50A5;
  localparam logic [31:0] GOLD    = 32'h010000A5;
  localparam logic [31:0] MAG     = 32'h0200015A;
  localparam logic [31:0] BEGINW  = 32'h00800001;
  localparam logic [31:0] MAGIC   = 32'h3149414E;

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

  int n_p;
  logic cap;
  logic [31:0] pw [0:7];
  always_ff @(posedge ui_clk or negedge rst_ui_n) begin
    if (!rst_ui_n) n_p <= 0;
    else if (!cap) n_p <= 0;
    else if (p_fire && n_p < 8) begin
      pw[n_p] <= p_data;
      n_p <= n_p + 1;
    end
  end

  logic [31:0] vec [0:1023];
  int nwords, i, c;
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

  task automatic wait_word_nosettle(output logic [31:0] g, input int maxc, output bit m);
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
    end
  endtask

  task automatic send_v04();
    begin
      for (i = 0; i < nwords; i++) send_word(vec[i]);
    end
  endtask

  task automatic do_clear_ack();
    begin
      send_word(CLR_CMD);
      wait_word(got, 400000, mute);
      if (mute || got !== CLR_ACK) begin
        log1($sformatf("FAIL CLEAR mute=%0d got=%08h", mute, got));
        $finish;
      end
    end
  endtask

  task automatic score_v04(input string tag);
    begin
      wait_word(got, 2_000_000, mute);
      log1($sformatf("%s mute=%0d got=%08h n_p=%0d p0=%08h p1=%08h p2=%08h rej=%0b rsn=%02h empty=%0b",
                     tag, mute, got, n_p,
                     (n_p > 0) ? pw[0] : 32'h0,
                     (n_p > 1) ? pw[1] : 32'h0,
                     (n_p > 2) ? pw[2] : 32'h0,
                     load_reject, reason_code, u_h.fifo_empty));
    end
  endtask

  initial begin
    logfd = $fopen("u33_leftover_mag.log", "w");
    cap = 1'b0;
    rst100_n = 0; rst_ui_n = 0; uart_rx = 1;
    repeat (20) @(posedge clk100);
    rst100_n = 1; rst_ui_n = 1;
    repeat (40) @(posedge clk100);
    force u_h.calib_ui = 1'b1;
    load_mem("PA24-V-04.mem");
    log1($sformatf("U33_LEFTOVER_MAG nwords=%0d PACK_ABI_24_24_PASS=NO", nwords));

    // CELL A: extra BEGIN after CLEAR reaches IDLE, then V-04.
    do_clear_ack();
    cap = 1'b0;
    repeat (8) @(posedge ui_clk);
    cap = 1'b1;
    send_word(BEGINW);
    send_v04();
    score_v04("CELL_A_BEGIN_THEN_V04");
    if (!mute && got === MAG && (n_p > 1) && pw[0] === BEGINW && pw[1] === BEGINW)
      log1("CELL_A_MAG leftover BEGIN is sufficient for R_BAD_MAGIC p1=BEGIN");
    else if (!mute && got === MAG)
      log1($sformatf("CELL_A_MAG other p0=%08h p1=%08h", pw[0], pw[1]));
    else
      log1($sformatf("CELL_A_NOT_MAG got=%08h", got));

    // CELL C: leftover GOLD token after CLEAR, then V-04 (control).
    do_clear_ack();
    cap = 1'b0;
    repeat (8) @(posedge ui_clk);
    cap = 1'b1;
    send_word(GOLD);
    send_v04();
    score_v04("CELL_C_GOLD_THEN_V04");
    if (!mute && got === GOLD && (n_p == 0 || pw[0] === BEGINW) && (n_p < 2 || pw[1] === MAGIC))
      log1("CELL_C_GOLD unlocked non-BEGIN leftover does not MAG");
    else
      log1($sformatf("CELL_C_OTHER got=%08h p0=%08h p1=%08h", got, pw[0], pw[1]));

    // CELL B: extra BEGIN while CLEAR ACK is on the wire (S_ACK/S_DROP hold).
    send_word(CLR_CMD);
    c = 0;
    while (c < 400000 && !u_h.clr_ack_valid) begin
      @(posedge clk100);
      c = c + 1;
    end
    if (!u_h.clr_ack_valid) begin
      log1("CELL_B_FAIL no ack_valid");
      $finish;
    end
    send_word(BEGINW);
    wait_word(got, 400000, mute);
    log1($sformatf("CELL_B_CLEAR mute=%0d got=%08h", mute, got));
    if (mute || got !== CLR_ACK) begin
      log1("CELL_B_FAIL CLEAR");
      $finish;
    end
    cap = 1'b0;
    repeat (8) @(posedge ui_clk);
    cap = 1'b1;
    send_v04();
    score_v04("CELL_B_BEGIN_DURING_ACK");
    if (!mute && got === MAG)
      log1("CELL_B_MAG ACK-overlap BEGIN survived flush");
    else if (!mute && got === GOLD)
      log1("CELL_B_GOLD S_DROP flush ate ACK-overlap BEGIN");
    else
      log1($sformatf("CELL_B_OTHER got=%08h", got));

    // CELL D: board r2 n=0 then retry, then another CLEAR+V-04 (r3 analogue).
    send_word(CLR_CMD);
    wait_word(got, 1000, mute);
    log1($sformatf("CELL_D_CLEAR_SHORT mute=%0d got=%08h", mute, got));
    send_word(CLR_CMD);
    wait_word(got, 400000, mute);
    log1($sformatf("CELL_D_CLEAR_RETRY mute=%0d got=%08h", mute, got));
    if (mute || got !== CLR_ACK) begin
      log1("CELL_D_FAIL RETRY");
      $finish;
    end
    cap = 1'b0;
    repeat (8) @(posedge ui_clk);
    cap = 1'b1;
    send_v04();
    score_v04("CELL_D_V04_AFTER_RETRY");
    do_clear_ack();
    cap = 1'b0;
    repeat (8) @(posedge ui_clk);
    cap = 1'b1;
    send_v04();
    score_v04("CELL_D_V04_R3");
    if (!mute && got === MAG)
      log1("CELL_D_MAG n=0-retry then next V-04");
    else if (!mute && got === GOLD)
      log1("CELL_D_GOLD n=0-retry is not sufficient for MAG on BRAM");
    else
      log1($sformatf("CELL_D_OTHER got=%08h", got));

    // CELL E: campaign WAIT_AFTER_ACK_S=0 — V-04 with no DIV*8 settle.
    send_word(CLR_CMD);
    wait_word_nosettle(got, 400000, mute);
    log1($sformatf("CELL_E_CLEAR mute=%0d got=%08h", mute, got));
    if (mute || got !== CLR_ACK) begin
      log1("CELL_E_FAIL CLEAR");
      $finish;
    end
    cap = 1'b0;
    repeat (2) @(posedge ui_clk);
    cap = 1'b1;
    send_v04();
    score_v04("CELL_E_V04_NOSETTLE");
    if (!mute && got === MAG)
      log1("CELL_E_MAG zero-settle after ACK");
    else if (!mute && got === GOLD)
      log1("CELL_E_GOLD zero-settle after ACK still GOLD on BRAM 1M");
    else
      log1($sformatf("CELL_E_OTHER got=%08h", got));

    log1("U33_LEFTOVER_MAG_XSIM_DONE PACK_ABI_24_24_PASS=NO");
    $fclose(logfd);
    $finish;
  end
endmodule
