// tb_mig_ui32.sv — dest-complete 32b/128b native UI. Not MIG_PASS.
`timescale 1ns/1ps

module tb_mig_ui32;
  logic clk = 0, rst_n = 0;
  always #5 clk = ~clk;

  logic calib_done;
  logic mem_cmd_valid, mem_cmd_ready, mem_cmd_write;
  logic [27:0] mem_addr;
  logic [31:0] mem_wdata, mem_rdata;
  logic mem_resp_valid, mem_resp_ready, mem_resp_err;
  logic [15:0] wr_outstanding;
  logic cmd_fifo_empty, force_fifo_empty, inject_tear;

  logic [27:0] app_addr;
  logic [2:0] app_cmd;
  logic app_en, app_wdf_end, app_wdf_wren, app_rd_data_end;
  logic [127:0] app_wdf_data, app_rd_data;
  logic [15:0] app_wdf_mask;
  logic app_rd_data_valid, app_rdy, app_wdf_rdy;

  mig_ui32 dut (
    .clk, .rst_n, .calib_done,
    .mem_cmd_valid, .mem_cmd_ready, .mem_cmd_write, .mem_addr, .mem_wdata,
    .mem_resp_valid, .mem_resp_ready, .mem_resp_err, .mem_rdata,
    .wr_outstanding, .cmd_fifo_empty, .force_fifo_empty, .inject_tear,
    .app_addr, .app_cmd, .app_en, .app_wdf_data, .app_wdf_end, .app_wdf_mask, .app_wdf_wren,
    .app_rd_data, .app_rd_data_valid, .app_rdy, .app_wdf_rdy
  );

  mig_ui_model mdl (
    .clk, .rst_n, .calib_done,
    .app_addr, .app_cmd, .app_en, .app_wdf_data, .app_wdf_end, .app_wdf_mask, .app_wdf_wren,
    .app_rd_data, .app_rd_data_end, .app_rd_data_valid, .app_rdy, .app_wdf_rdy
  );

  integer nfail, t;

  task xact;
    input wr;
    input [27:0] a;
    input [31:0] w;
    begin
      @(posedge clk);
      while (!mem_cmd_ready) @(posedge clk);
      mem_cmd_write = wr;
      mem_addr = a;
      mem_wdata = w;
      mem_cmd_valid = 1;
      @(posedge clk);
      mem_cmd_valid = 0;
      t = 0;
      while (!mem_resp_valid && t < 80) begin @(posedge clk); t = t + 1; end
      if (!mem_resp_valid) begin nfail = nfail + 1; $display("FAIL timeout a=%h", a); end
      @(posedge clk);
    end
  endtask

  initial begin
    nfail = 0;
    mem_cmd_valid = 0;
    mem_cmd_write = 0;
    mem_addr = 0;
    mem_wdata = 0;
    mem_resp_ready = 1;
    force_fifo_empty = 0;
    inject_tear = 0;
    repeat (4) @(posedge clk);
    rst_n = 1;
    repeat (2) @(posedge clk);

    // four lanes of one 16-byte beat
    xact(1, 28'h10, 32'hA0A0_0000);
    if (mem_resp_err) begin nfail++; $display("FAIL L0 wr"); end
    xact(1, 28'h14, 32'hA1A1_0001);
    xact(1, 28'h18, 32'hA2A2_0002);
    xact(1, 28'h1C, 32'hA3A3_0003);
    xact(0, 28'h10, 32'h0);
    if (mem_rdata !== 32'hA0A0_0000) begin nfail++; $display("FAIL L0 rd %h", mem_rdata); end
    xact(0, 28'h14, 32'h0);
    if (mem_rdata !== 32'hA1A1_0001) begin nfail++; $display("FAIL L1 rd %h", mem_rdata); end
    xact(0, 28'h1C, 32'h0);
    if (mem_rdata !== 32'hA3A3_0003) begin nfail++; $display("FAIL L3 rd %h", mem_rdata); end

    // PROXY: fifo-empty must not complete dest
    force_fifo_empty = 1;
    @(posedge clk);
    while (!mem_cmd_ready) @(posedge clk);
    mem_cmd_write = 1; mem_addr = 28'h20; mem_wdata = 32'hBEEF_0020; mem_cmd_valid = 1;
    @(posedge clk); mem_cmd_valid = 0;
    repeat (16) @(posedge clk);
    if (mem_resp_valid) begin nfail++; $display("FAIL proxy complete"); end
    if (wr_outstanding == 0) begin nfail++; $display("FAIL outstanding drained by proxy"); end
    force_fifo_empty = 0;
    t = 0;
    while (!mem_resp_valid && t < 40) begin @(posedge clk); t = t + 1; end
    if (!mem_resp_valid) begin nfail++; $display("FAIL dest drain"); end
    if (mem_resp_err) begin nfail++; $display("FAIL dest err after proxy"); end

    inject_tear = 1;
    xact(1, 28'h30, 32'hCAFE_0030);
    if (!mem_resp_err) begin nfail++; $display("FAIL tear not flagged"); end
    inject_tear = 0;

    if (nfail == 0) $display("MIG_UI32_XSIM_PASS dest-complete 32b/128b (not MIG_PASS)");
    else $display("MIG_UI32_XSIM_FAIL nfail=%0d", nfail);
    $finish;
  end
endmodule
