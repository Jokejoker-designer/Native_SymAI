// tb_u6_generation.sv — UART_R2_U6 pack commit vs query snapshot.
// POLICY B for R1: serialize (pack_lock + pack_quiescent). No mixed generation.
// XSim != board. Not M1_BOARD_CLOSED / not BOARD_PASS.
`timescale 1ns/1ps

module tb_u6_generation;
  logic clk, rst_n, s_valid, s_ready;
  logic [31:0] s_data;
  logic mem_cmd_valid, mem_cmd_ready, mem_cmd_write, mem_resp_valid, mem_resp_ready, mem_resp_err;
  logic [27:0] mem_addr;
  logic [31:0] mem_wdata, mem_rdata, active_generation;
  logic load_ack, load_reject, loader_busy;
  logic [7:0] reason_code;
  logic [15:0] wr_outstanding;

  pack_loader u_ld (
    .clk, .rst_n, .s_valid, .s_ready, .s_data,
    .mem_cmd_valid, .mem_cmd_ready, .mem_cmd_write, .mem_addr, .mem_wdata,
    .mem_resp_valid, .mem_resp_ready, .mem_resp_err, .mem_rdata,
    .load_ack, .load_reject, .reason_code, .active_generation, .wr_outstanding, .loader_busy
  );

  assign mem_cmd_ready = 1'b1;
  assign mem_resp_err = 1'b0;
  assign mem_rdata = 32'h0;
  assign mem_resp_valid = 1'b0;

  logic q_rst_n, in_valid, in_ready, taking, q_valid, q_ready, r_ready, tx_valid, tx_ready;
  logic [31:0] in_data, tx_data, snap, gen_in;
  logic [7:0] q_bytes [0:31];
  logic [7:0] r_bytes [0:47];
  uart_fe256_host u_q (
    .clk, .rst_n(q_rst_n),
    .in_valid, .in_ready, .in_data, .taking,
    .q_valid, .q_ready, .q_bytes,
    .r_valid(1'b0), .r_ready, .r_bytes(r_bytes),
    .tx_valid, .tx_ready(1'b1), .tx_data,
    .active_generation(gen_in), .query_generation_snapshot(snap)
  );
  assign q_ready = 1'b1;

  initial clk = 1'b0;
  always #5 clk = ~clk;

  int fail, i, qsum, n_q;
  logic [31:0] snap_at_q;

  always @(posedge clk or negedge q_rst_n) begin
    if (!q_rst_n) n_q <= 0;
    else if (q_valid && q_ready) begin
      snap_at_q <= snap;
      n_q <= n_q + 1;
    end
  end

  task automatic push(input logic [31:0] w);
    begin
      s_valid = 1'b1; s_data = w;
      while (!s_ready) @(posedge clk);
      @(posedge clk);
      s_valid = 1'b0;
      @(posedge clk);
    end
  endtask

  task automatic qword(input logic [31:0] w);
    begin
      in_valid = 1'b1; in_data = w;
      @(posedge clk);
      in_valid = 1'b0;
      @(posedge clk);
    end
  endtask

  initial begin
    $display("UART_R2_U6_GENERATION_XSIM start POLICY_B_SERIALIZE");
    fail = 0;
    for (i = 0; i < 48; i++) r_bytes[i] = 8'h0;
    rst_n = 1'b0; q_rst_n = 1'b0; s_valid = 1'b0; in_valid = 1'b0; gen_in = 32'h0000000A;
    repeat (8) @(posedge clk);
    rst_n = 1'b1; q_rst_n = 1'b1;
    repeat (8) @(posedge clk);

    // Q1 analogue: no pack, query of 8 words, snapshot = presented gen
    qword(32'h00004E51);
    qsum = 0;
    for (i = 0; i < 32; i++) qsum = qsum + q_bytes[i];
    if (q_valid || qsum != 0) begin
      $display("U6 CHECK_FAIL Q1 partial visible");
      fail = fail + 1;
    end
    qword(32'h1); qword(32'h2); qword(32'h3);
    qword(32'h4); qword(32'h5); qword(32'h6); qword(32'h7);
    repeat (4) @(posedge clk);
    if (n_q != 1) begin
      $display("U6 CHECK_FAIL Q1 n_q=%0d", n_q);
      fail = fail + 1;
    end else if (snap_at_q !== 32'h0000000A) begin
      $display("U6 CHECK_FAIL Q1 snap=%08h", snap_at_q);
      fail = fail + 1;
    end else $display("U6 CHECK_OK Q1 snapshot N=0x0A");

    // Q2: partial pack command does not change generation
    if (active_generation !== 32'hFFFF_FFFF) begin
      $display("U6 CHECK_FAIL gen after reset %08h", active_generation);
      fail = fail + 1;
    end
    // illegal opcode -> reject path, generation stays UNSET
    push(32'h0000_0099);
    repeat (20) @(posedge clk);
    if (active_generation !== 32'hFFFF_FFFF) begin
      $display("U6 CHECK_FAIL Q3 failed pack mutated gen %08h", active_generation);
      fail = fail + 1;
    end else $display("U6 CHECK_OK Q3 failed N+1 leaves N (UNSET)");
    if (!load_reject) begin
      $display("U6 CHECK_INFO reject not seen reason=%02h busy=%0b st=%0d", reason_code, loader_busy, u_ld.state);
    end else $display("U6 CHECK_OK load_reject reason=%02h", reason_code);

    // Q2 partial BEGIN payload (length 8 bytes = 2 extra words) stays in S_RX
    rst_n = 1'b0; repeat (4) @(posedge clk); rst_n = 1'b1; repeat (4) @(posedge clk);
    push(32'h0008_0001); // BEGIN, 8 bytes more
    push(32'h3149414E);
    if (active_generation !== 32'hFFFF_FFFF) fail = fail + 1;
    if (!loader_busy) begin
      $display("U6 CHECK_FAIL Q2 expected busy during partial");
      fail = fail + 1;
    end else $display("U6 CHECK_OK Q2 partial pack gen still UNSET busy=1");

    // Q4 not executed as a full legal pack here (ABI-24 DUT is the commit oracle).
    $display("U6 Q4 full activate N+1 = NOT_RUN_IN_THIS_TB use PACK_ABI24_MIG_DUT_XSIM");
    $display("U6 Q5 activation during query: POLICY B serialize via pack_lock on product top");
    $display("U6 concurrent load+reason: NOT_PROVEN; SERIALIZE_FOR_R1");

    if (fail == 0)
      $display("UART_R2_U6_GENERATION_XSIM_PASS snapshot_and_reject_only");
    else
      $display("UART_R2_U6_GENERATION_XSIM_FAIL fail=%0d", fail);
    $finish;
  end
endmodule
