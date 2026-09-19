// tb_u33_dup_begin.sv — DUP4 leftover BEGIN vs DUP16 (64B USB packet) MAG class.
// Dest=mig_ui_bram, bind=U33. PROGRAM=NO. Not PACK_ABI_24_24_PASS.
`timescale 1ns/1ps

module tb_u33_dup_begin;
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
  int nwords, i, c, k;
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
    int bi;
    begin
      uart_rx <= 1'b0;
      repeat (DIV) @(posedge clk100);
      for (bi = 0; bi < 8; bi++) begin
        uart_rx <= b[bi];
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

  task automatic score(input string tag);
    begin
      wait_word(got, 2_000_000, mute);
      log1($sformatf("%s mute=%0d got=%08h n_p=%0d p0=%08h p1=%08h p2=%08h rej=%0b rsn=%02h",
                     tag, mute, got, n_p,
                     (n_p > 0) ? pw[0] : 32'h0,
                     (n_p > 1) ? pw[1] : 32'h0,
                     (n_p > 2) ? pw[2] : 32'h0,
                     load_reject, reason_code));
    end
  endtask

  initial begin
    logfd = $fopen("u33_dup_begin.log", "w");
    cap = 1'b0;
    rst100_n = 0; rst_ui_n = 0; uart_rx = 1;
    repeat (20) @(posedge clk100);
    rst100_n = 1; rst_ui_n = 1;
    repeat (40) @(posedge clk100);
    force u_h.calib_ui = 1'b1;
    load_mem("PA24-V-04.mem");
    log1($sformatf("U33_DUP nwords=%0d PACK_ABI_24_24_PASS=NO", nwords));

    // DUP4: extra exact BEGIN after CLEAR IDLE, then full V-04.
    do_clear_ack();
    cap = 1'b0;
    repeat (8) @(posedge ui_clk);
    cap = 1'b1;
    send_word(BEGINW);
    send_v04();
    score("DUP4");
    if (!mute && got === MAG && (n_p > 1) && pw[0] === BEGINW && pw[1] === BEGINW)
      log1("DUP4_MAG 4-byte BEGIN dup is sufficient p1=BEGIN");
    else
      log1($sformatf("DUP4_OTHER got=%08h p0=%08h p1=%08h", got, pw[0], pw[1]));

    // DUP16: extra first 16 words (64B USB packet) then full V-04.
    do_clear_ack();
    cap = 1'b0;
    repeat (8) @(posedge ui_clk);
    cap = 1'b1;
    k = (nwords < 16) ? nwords : 16;
    for (i = 0; i < k; i++) send_word(vec[i]);
    send_v04();
    score("DUP16");
    if (!mute && got === MAG && (n_p > 1) && pw[1] === BEGINW)
      log1("DUP16_MAG 64B prefix dup also R_BAD_MAGIC p1=BEGIN");
    else if (!mute && got === MAG)
      log1($sformatf("DUP16_MAG other p0=%08h p1=%08h", pw[0], pw[1]));
    else if (!mute && got === GOLD)
      log1("DUP16_GOLD 64B USB-packet dup is not board MAG token");
    else
      log1($sformatf("DUP16_OTHER got=%08h", got));

    // LATE_DUP4: GOLD, then extra BEGIN (retry after complete), CLEAR, V-04.
    do_clear_ack();
    cap = 1'b0;
    repeat (8) @(posedge ui_clk);
    cap = 1'b1;
    send_v04();
    score("LATE_PRE_GOLD");
    if (mute || got !== GOLD) begin
      log1("LATE_FAIL baseline GOLD");
      $finish;
    end
    send_word(BEGINW);
    do_clear_ack();
    cap = 1'b0;
    repeat (8) @(posedge ui_clk);
    cap = 1'b1;
    send_v04();
    score("LATE_DUP4_AFTER_GOLD");
    if (!mute && got === MAG)
      log1("LATE_DUP4_MAG CLEAR did not flush post-GOLD extra BEGIN");
    else if (!mute && got === GOLD)
      log1("LATE_DUP4_GOLD CLEAR flushed post-GOLD extra BEGIN");
    else
      log1($sformatf("LATE_DUP4_OTHER got=%08h", got));

    log1("U33_DUP_XSIM_DONE PACK_ABI_24_24_PASS=NO");
    $fclose(logfd);
    $finish;
  end
endmodule
