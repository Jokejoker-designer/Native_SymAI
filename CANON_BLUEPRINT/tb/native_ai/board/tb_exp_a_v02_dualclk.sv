// tb_exp_a_v02_dualclk.sv — Experiment A XSim 4-stage dump. Independent of Exp B.
// Fresh V-02 after reset. Dual-clock CDC like silicon candidate top.
// Dest mig_ui_bram, not mig0. Not PACK_ABI_24_24_PASS / not BOARD_PASS.
`timescale 1ns/1ps

module tb_exp_a_v02_dualclk;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 1_000_000;
  localparam int DIV    = CLK_HZ / BAUD;
  localparam logic [31:0] MAGIC = 32'h3149_414E;
  localparam logic [31:0] BEGINW = 32'h0080_0001;
  localparam logic [31:0] GOLD  = 32'h010000A5;
  localparam logic [31:0] MAG   = 32'h0200015A;

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

  integer n_assem, n_fifo_wr, n_fifo_rd, n_p;
  logic [31:0] assem_q [0:63];
  logic [31:0] fifo_wr_q [0:63];
  logic [31:0] fifo_rd_q [0:63];
  logic [31:0] p_q [0:63];

  always @(posedge clk100 or negedge rst100_n) begin
    if (!rst100_n) begin
      n_assem = 0;
      n_fifo_wr = 0;
      n_fifo_rd = 0;
    end else begin
      if (w_valid && w_ready && n_assem < 64) begin
        assem_q[n_assem] = w_data;
        $display("STAGE_ASSEM idx=%0d word=%08h", n_assem, w_data);
        n_assem = n_assem + 1;
      end
      if (fifo_wr_fire && n_fifo_wr < 64) begin
        fifo_wr_q[n_fifo_wr] = fifo_wr_data;
        $display("STAGE_FIFO_WR idx=%0d word=%08h", n_fifo_wr, fifo_wr_data);
        n_fifo_wr = n_fifo_wr + 1;
      end
      if (fifo_rd_fire && n_fifo_rd < 64) begin
        fifo_rd_q[n_fifo_rd] = fifo_rd_data;
        $display("STAGE_FIFO_RD idx=%0d word=%08h opcode=%02h",
                 n_fifo_rd, fifo_rd_data, fifo_rd_data[7:0]);
        n_fifo_rd = n_fifo_rd + 1;
      end
    end
  end

  always @(posedge ui_clk or negedge rst_ui_n) begin
    if (!rst_ui_n)
      n_p = 0;
    else if (p_fire && n_p < 64) begin
      p_q[n_p] = p_data;
      $display("STAGE_LOADER idx=%0d word=%08h opcode=%02h",
               n_p, p_data, p_data[7:0]);
      n_p = n_p + 1;
    end
  end

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
    end else if (host_take) begin
      host_seen <= 1'b0;
    end else if (host_valid && !host_seen) begin
      host_seen <= 1'b1;
      host_cap <= host_data;
    end
  end

  logic [31:0] vec [0:1023];
  int nwords, i, c, pass, fail;

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
      uart_byte(w[7:0]);
      uart_byte(w[15:8]);
      uart_byte(w[23:16]);
      uart_byte(w[31:24]);
    end
  endtask

  task automatic wait_status(input int maxc);
    begin
      c = 0;
      host_take = 1'b0;
      while (c < maxc && !host_seen) begin
        @(posedge clk100);
        c = c + 1;
      end
      if (!host_seen) begin
        $display("EXP_A TIMEOUT ack=%0d nak=%0d rc=%02h",
                 load_ack, load_reject, reason_code);
        fail = fail + 1;
      end else begin
        $display("EXP_A STATUS got=%08h GOLD=%08h MAG=%08h", host_cap, GOLD, MAG);
        if (host_cap === GOLD)
          pass = pass + 1;
        else begin
          $display("EXP_A NOT_GOLD");
          fail = fail + 1;
        end
      end
      host_take = 1'b1;
      @(posedge clk100);
      host_take = 1'b0;
    end
  endtask

  initial begin
    pass = 0;
    fail = 0;
    rst100_n = 1'b0;
    rst_ui_n = 1'b0;
    uart_rx = 1'b1;
    repeat (20) @(posedge clk100);
    rst100_n = 1'b1;
    rst_ui_n = 1'b1;
    repeat (40) @(posedge clk100);

    load_mem("PA24-V-02.mem");
    $display("EXP_A HOST_TX nwords=%0d w0=%08h w1=%08h", nwords, vec[0], vec[1]);
    if (vec[0] !== BEGINW || vec[1] !== MAGIC) begin
      $display("EXP_A MEM_UNEXPECTED w0=%08h w1=%08h", vec[0], vec[1]);
      fail = fail + 1;
    end
    for (i = 0; i < nwords; i++)
      send_word(vec[i]);
    wait_status(3_000_000);

    $display("EXP_A COUNTS assem=%0d fifo_wr=%0d fifo_rd=%0d loader=%0d",
             n_assem, n_fifo_wr, n_fifo_rd, n_p);
    if (n_assem >= 2 && n_fifo_wr >= 2 && n_fifo_rd >= 2 && n_p >= 2) begin
      $display("EXP_A COMPARE_W0 assem=%08h fifo_wr=%08h fifo_rd=%08h loader=%08h mem=%08h",
               assem_q[0], fifo_wr_q[0], fifo_rd_q[0], p_q[0], vec[0]);
      $display("EXP_A COMPARE_W1 assem=%08h fifo_wr=%08h fifo_rd=%08h loader=%08h mem=%08h MAGIC=%08h",
               assem_q[1], fifo_wr_q[1], fifo_rd_q[1], p_q[1], vec[1], MAGIC);
      if (assem_q[0] !== vec[0] || fifo_wr_q[0] !== vec[0] ||
          fifo_rd_q[0] !== vec[0] || p_q[0] !== vec[0]) begin
        $display("EXP_A FIRST_DIVERGENCE_W0");
        fail = fail + 1;
      end
      if (assem_q[1] !== MAGIC || fifo_wr_q[1] !== MAGIC ||
          fifo_rd_q[1] !== MAGIC || p_q[1] !== MAGIC) begin
        $display("EXP_A FIRST_DIVERGENCE_MAGIC");
        fail = fail + 1;
      end else
        $display("EXP_A PATH_MATCH host_tx==assem==fifo==loader MAGIC");
    end else begin
      $display("EXP_A SHORT_PATH");
      fail = fail + 1;
    end
    $display("HW0=%08h", u_h.u_ld.u_ld.hw0);

    if (fail == 0)
      $display("EXP_A_V02_DUALCLK_XSIM_PASS (not PACK_ABI_24_24_PASS / not BOARD_PASS)");
    else
      $display("EXP_A_V02_DUALCLK_XSIM_FAIL fail=%0d pass=%0d", fail, pass);
    $finish;
  end
endmodule
