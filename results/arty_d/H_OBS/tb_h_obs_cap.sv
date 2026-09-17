// H_OBS cap unit TB. H_OBS != H. Not BOARD_PASS.
`timescale 1ns/1ps
module tb_h_obs_cap;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD = 1_000_000;
  localparam int DIV = CLK_HZ / BAUD;
  localparam logic [31:0] CLR = 32'h44524743;
  localparam logic [31:0] BEGINW = 32'h00800001;
  localparam logic [31:0] MAGIC = 32'h3149414E;
  localparam logic [31:0] SHIFT = 32'h80000100;

  logic clk, rst_n, rx, w_ready, flush;
  logic w_valid, idle;
  logic [31:0] w_data;
  logic [1:0] dbg_bix, dbg_st;
  logic [7:0] dbg_sh;
  logic dbg_rx_d;
  logic [3:0] dbg_bitn;
  logic clr_take, fifo_wr_valid, fifo_wr_ready, dump_go;
  logic cap_fresh, have_pack, drop_seen;
  logic [31:0] first_pack;
  logic [1:0] bix_arm, bix_fp, bix_gap;
  logic [7:0] sh0, sh1, sh2, sh3;
  logic [3:0] n_bytes;
  logic pack_en;
  integer err;

  assign flush = 1'b0;
  assign dump_go = 1'b0;
  assign clr_take = w_valid && (w_data == CLR);
  assign fifo_wr_valid = w_valid && !clr_take && pack_en;
  assign fifo_wr_ready = 1'b1;

  uart_rx_word_observe #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_rx (
    .clk, .rst_n, .rx, .w_valid, .w_ready, .w_data, .flush, .idle, .rx_sync(),
    .dbg_bix, .dbg_sh, .dbg_rx_d, .dbg_st, .dbg_bitn
  );
  h_obs_cap u_cap (
    .clk, .rst_n, .clr_take, .w_valid, .w_ready, .w_data,
    .fifo_wr_valid, .fifo_wr_ready, .dump_go,
    .dbg_bix, .dbg_sh, .dbg_st,
    .cap_fresh, .have_pack_word(have_pack), .first_pack_word(first_pack),
    .bix_at_arm(bix_arm), .bix_at_first_pack(bix_fp), .bix_gap(bix_gap),
    .drop_seen, .sh0, .sh1, .sh2, .sh3, .n_bytes
  );

  initial clk = 0;
  always #5 clk = ~clk;

  task automatic send_byte(input byte b);
    integer i;
    rx = 1'b0;
    repeat (DIV) @(posedge clk);
    for (i = 0; i < 8; i++) begin
      rx = b[i];
      repeat (DIV) @(posedge clk);
    end
    rx = 1'b1;
    repeat (DIV) @(posedge clk);
  endtask

  task automatic send_word(input logic [31:0] w);
    send_byte(w[7:0]);
    send_byte(w[15:8]);
    send_byte(w[23:16]);
    send_byte(w[31:24]);
  endtask

  task automatic reset_dut;
    rst_n = 0;
    rx = 1;
    w_ready = 1;
    pack_en = 1;
    repeat (8) @(posedge clk);
    rst_n = 1;
    repeat (8) @(posedge clk);
  endtask

  initial begin
    err = 0;
    reset_dut();
    send_word(CLR);
    send_word(BEGINW);
    repeat (4) @(posedge clk);
    if (!have_pack || first_pack !== BEGINW) begin
      $display("FAIL OTHER first=%h have=%0d", first_pack, have_pack); err++;
    end
    if (sh0 !== 8'h01) begin $display("FAIL sh0=%h", sh0); err++; end
    $display("H_OBS CASE OTHER first=%h bix_arm=%0d bix_gap=%0d sh0=%h",
             first_pack, bix_arm, bix_gap, sh0);

    reset_dut();
    send_word(CLR);
    send_byte(8'h00);
    send_byte(8'h01);
    send_byte(8'h00);
    send_byte(8'h80);
    repeat (4) @(posedge clk);
    if (!have_pack || first_pack !== SHIFT) begin
      $display("FAIL H19 first=%h", first_pack); err++;
    end
    if (sh0 !== 8'h00) begin $display("FAIL H19 sh0=%h", sh0); err++; end
    $display("H_OBS CASE H19 first=%h bix_arm=%0d bix_gap=%0d sh0=%h",
             first_pack, bix_arm, bix_gap, sh0);

    reset_dut();
    send_word(CLR);
    pack_en = 0;
    w_ready = 0;
    send_word(32'hA1B2C3D4);
    send_word(BEGINW);
    w_ready = 1;
    repeat (8) @(posedge clk);
    pack_en = 1;
    send_word(MAGIC);
    repeat (4) @(posedge clk);
    if (!have_pack || first_pack !== MAGIC) begin
      $display("FAIL H20 first=%h drop=%0d", first_pack, drop_seen); err++;
    end
    if (!drop_seen) begin $display("FAIL H20 drop_seen=0"); err++; end
    $display("H_OBS CASE H20 first=%h drop=%0d sh0=%h", first_pack, drop_seen, sh0);

    if (err == 0) $display("TB_H_OBS_CAP_PASS");
    else $display("TB_H_OBS_CAP_FAIL n=%0d", err);
    $finish;
  end
endmodule
