// tb_uart_pack.sv — UART RX pack -> dest-complete -> UART TX ACK/NAK.
// Mirrors arty_a7_r2_top pack/UART slice. CANDIDATE. XSim != board. PROGRAM=NO.
`timescale 1ns/1ps

module tb_uart_pack;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD = 115200;
  localparam int DIV = CLK_HZ / BAUD;

  logic clk, rst_n, uart_rx, uart_tx;
  initial clk = 1'b0;
  always #5 clk = ~clk;

  logic w_valid, w_ready;
  logic [31:0] w_data;
  uart_rx_word #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_rx (
    .clk, .rst_n, .rx(uart_rx), .w_valid(w_valid), .w_ready(w_ready), .w_data(w_data)
  );

  logic load_ack, load_reject, calib_ui, pack_busy;
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

  pack_mig_bind u_ld (
    .clk, .rst_n, .calib_done(calib_ui),
    .s_valid(w_valid), .s_ready(w_ready), .s_data(w_data),
    .load_ack, .load_reject, .reason_code, .active_generation, .wr_outstanding,
    .force_fifo_empty(1'b0), .ui_busy(pack_busy),
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

  logic ack_d, nak_d, st_valid, st_ready;
  logic [31:0] st_data;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
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

  uart_tx_word #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_tx (
    .clk, .rst_n, .w_valid(st_valid), .w_ready(st_ready), .w_data(st_data), .tx(uart_tx)
  );

  logic host_valid, host_ready;
  logic [31:0] host_data;
  uart_rx_word #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_host (
    .clk, .rst_n, .rx(uart_tx), .w_valid(host_valid), .w_ready(host_ready), .w_data(host_data)
  );
  assign host_ready = 1'b1;

  logic [31:0] vec [0:1023];
  int nwords, pass, fail;

  task automatic load_mem(input string path);
    int fd, i;
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
    int i;
    begin
      uart_rx <= 1'b0;
      repeat (DIV) @(posedge clk);
      for (i = 0; i < 8; i++) begin
        uart_rx <= b[i];
        repeat (DIV) @(posedge clk);
      end
      uart_rx <= 1'b1;
      repeat (DIV) @(posedge clk);
    end
  endtask

  task automatic send_pack;
    int i;
    begin
      for (i = 0; i < nwords; i++) begin
        uart_byte(vec[i][7:0]);
        uart_byte(vec[i][15:8]);
        uart_byte(vec[i][23:16]);
        uart_byte(vec[i][31:24]);
      end
    end
  endtask

  task automatic wait_status(input logic [31:0] exp, input int maxc);
    int c;
    begin
      c = 0;
      while (c < maxc && !host_valid) begin
        @(posedge clk);
        c = c + 1;
      end
      if (!host_valid) begin
        $display("TIMEOUT exp=%08h ack=%0d nak=%0d rc=%02h", exp, load_ack, load_reject, reason_code);
        fail = fail + 1;
      end else if (host_data !== exp) begin
        $display("MISMATCH exp=%08h got=%08h", exp, host_data);
        fail = fail + 1;
      end else begin
        $display("MATCH %08h", host_data);
        pass = pass + 1;
      end
      @(posedge clk);
    end
  endtask

  task automatic reset_dut;
    begin
      rst_n = 1'b0;
      uart_rx = 1'b1;
      repeat (20) @(posedge clk);
      rst_n = 1'b1;
      repeat (20) @(posedge clk);
    end
  endtask

  initial begin
    pass = 0;
    fail = 0;
    rst_n = 1'b0;
    uart_rx = 1'b1;

    reset_dut();
    load_mem("v1_valid.mem");
    send_pack();
    wait_status(32'h010000A5, 2000000);

    reset_dut();
    load_mem("v2_bad_magic.mem");
    send_pack();
    wait_status(32'h0200015A, 2000000);

    if (fail == 0)
      $display("UART_PACK_XSIM_PASS %0d/2", pass);
    else
      $display("UART_PACK_XSIM_FAIL fail=%0d", fail);
    $finish;
  end
endmodule
