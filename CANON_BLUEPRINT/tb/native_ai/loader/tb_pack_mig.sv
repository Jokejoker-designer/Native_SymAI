// tb_pack_mig.sv — M1 pack_loader through mig_ui32 dest-complete. Not MIG_PASS.
`timescale 1ns/1ps

module tb_pack_mig;
  logic clk = 0, rst_n = 0;
  always #5 clk = ~clk;

  logic s_valid, s_ready;
  logic [31:0] s_data;
  logic load_ack, load_reject, calib_done, stall;
  logic [7:0] reason_code;
  logic [31:0] active_generation;
  logic [15:0] wr_outstanding;
  logic ui_busy;
  logic [27:0] app_addr;
  logic [2:0] app_cmd;
  logic app_en, app_wdf_end, app_wdf_wren, app_rd_data_end;
  logic [127:0] app_wdf_data, app_rd_data;
  logic [15:0] app_wdf_mask;
  logic app_rd_data_valid, app_rdy, app_wdf_rdy;

  pack_mig_bind dut (
    .clk, .rst_n, .calib_done,
    .s_valid, .s_ready, .s_data,
    .load_ack, .load_reject, .reason_code, .active_generation, .wr_outstanding,
    .force_fifo_empty(stall), .ui_busy,
    .app_addr, .app_cmd, .app_en, .app_wdf_data, .app_wdf_end, .app_wdf_mask, .app_wdf_wren,
    .app_rd_data, .app_rd_data_valid, .app_rdy, .app_wdf_rdy
  );

  mig_ui_bram dest (
    .clk, .rst_n, .calib_done, .stall(1'b0),
    .app_addr, .app_cmd, .app_en, .app_wdf_data, .app_wdf_end, .app_wdf_mask, .app_wdf_wren,
    .app_rd_data, .app_rd_data_end, .app_rd_data_valid, .app_rdy, .app_wdf_rdy
  );

  logic [31:0] vec [0:1023];
  int nwords, fail, t;

  task automatic load_mem(input string path);
    int fd, i;
    begin
      fd = $fopen(path, "r");
      if (fd == 0) begin $display("FAIL open %s", path); fail = fail + 1; nwords = 0; end
      else begin
        void'($fscanf(fd, "%h", nwords));
        for (i = 0; i < nwords; i++) void'($fscanf(fd, "%h", vec[i]));
        $fclose(fd);
      end
    end
  endtask

  task automatic reset_dut;
    begin
      rst_n = 0; s_valid = 0; s_data = 0; stall = 0;
      repeat (4) @(posedge clk); rst_n = 1; repeat (2) @(posedge clk);
    end
  endtask

  task automatic send_word(input logic [31:0] w, input int maxc, input bit strict, output bit ok);
    begin
      ok = 1'b0;
      t = 0; s_valid <= 1; s_data <= w; @(posedge clk);
      while (!s_ready && t < maxc) begin @(posedge clk); t = t + 1; end
      if (s_ready) ok = 1'b1;
      else if (strict) begin $display("FAIL s_ready timeout"); fail = fail + 1; end
    end
  endtask

  task automatic drive_vec;
    int i; bit ok;
    begin for (i = 0; i < nwords; i++) send_word(vec[i], 40000, 1, ok); s_valid <= 0; @(posedge clk); end
  endtask

  task automatic wait_done(input int maxc);
    int c; begin c = 0; while (c < maxc && !load_ack && !load_reject) begin @(posedge clk); c = c + 1; end end
  endtask

  initial begin
    fail = 0; stall = 0; rst_n = 0; s_valid = 0; s_data = 0;

    reset_dut(); load_mem("v1_valid.mem"); drive_vec(); wait_done(80000);
    if (!load_ack || load_reject || active_generation != 32'd7 || reason_code != 8'h00) begin
      $display("FAIL V1 ack=%0d rej=%0d gen=%h rc=%h out=%0d", load_ack, load_reject, active_generation, reason_code, wr_outstanding);
      fail = fail + 1;
    end else $display("PASS V1 dest-complete");

    reset_dut(); load_mem("v2_bad_magic.mem"); drive_vec(); wait_done(40000);
    if (!load_reject || load_ack || reason_code != 8'h01) begin $display("FAIL V2"); fail = fail + 1; end
    else $display("PASS V2");

    reset_dut(); load_mem("v3_bad_abi.mem"); drive_vec(); wait_done(40000);
    if (!load_reject || load_ack || reason_code != 8'h02) begin $display("FAIL V3"); fail = fail + 1; end
    else $display("PASS V3");

    reset_dut(); load_mem("v4_bad_page_crc.mem"); drive_vec(); wait_done(40000);
    if (!load_reject || load_ack || reason_code != 8'h05) begin $display("FAIL V4"); fail = fail + 1; end
    else $display("PASS V4");

    reset_dut(); stall = 1; load_mem("v5_valid_drain.mem");
    begin
      int i, sent; bit ok;
      sent = 0;
      for (i = 0; i < nwords; i++) begin
        send_word(vec[i], 2000, 0, ok);
        if (ok) sent = sent + 1;
        else break;
      end
      s_valid <= 0;
      repeat (200) @(posedge clk);
      if (load_ack) begin $display("FAIL V5 ACK while dest held out=%0d sent=%0d", wr_outstanding, sent); fail = fail + 1; end
      else $display("PASS V5 pre-release (ack=0 out=%0d sent=%0d)", wr_outstanding, sent);
      stall = 0;
      for (i = sent; i < nwords; i++) send_word(vec[i], 40000, 1, ok);
      s_valid <= 0;
    end
    wait_done(80000);
    if (!load_ack || load_reject) begin $display("FAIL V5 after release"); fail = fail + 1; end
    else $display("PASS V5 post-release dest-complete");

    if (fail == 0) $display("PACK_MIG_UI32_XSIM_PASS 5 vectors dest-complete (not MIG_PASS)");
    else $display("PACK_MIG_UI32_XSIM_FAIL count=%0d", fail);
    $finish;
  end
endmodule
