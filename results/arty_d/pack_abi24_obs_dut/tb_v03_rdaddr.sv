// Isolated PA24-V-03 dest read vs write addresses. Does not modify B TB.
// Prefills mig_ui_bram so X does not false-pass sentinel. Not PACK_ABI_24_24_PASS.
`timescale 1ns/1ps
`include "pack_abi24_constants.svh"

module tb_v03_rdaddr;
`include "pack_abi24_expect.svh"
`include "pack_abi24_fopen.svh"

  logic clk = 0;
  logic rst_n = 0;
  logic        s_valid;
  logic        s_ready;
  logic [31:0] s_data;
  logic        load_ack, load_reject;
  logic [7:0]  reason_code;
  logic [31:0] active_generation;
  logic [7:0]  query_status, query_reason;
  logic        query_valid;
  logic        pack_quiescent;

  pack_abi24_mig_dut dut (
    .clk, .rst_n, .s_valid, .s_ready, .s_data,
    .load_ack, .load_reject, .reason_code, .active_generation,
    .query_status, .query_reason, .query_valid, .pack_quiescent
  );

  always #5 clk = ~clk;

  integer wi, nwords, t, fd, rc, i;
  integer unsigned wtmp;
  logic [31:0] stream [0:PACK_ABI24_MAX_WORDS-1];

  always @(posedge clk) begin
    if (rst_n && dut.u_ld.u_ld.mem_cmd_valid && dut.u_ld.u_ld.mem_cmd_ready)
      $display("MEM %0t wr=%0d addr=%07h wdata=%08h state=%0d wr_off=%0d wr_sel=%0d chk_i=%0d rg0=%08h rg1=%08h",
               $time, dut.u_ld.u_ld.mem_cmd_write, dut.u_ld.u_ld.mem_addr,
               dut.u_ld.u_ld.mem_wdata, dut.u_ld.u_ld.state,
               dut.u_ld.u_ld.wr_off_bytes, dut.u_ld.u_ld.wr_sel, dut.u_ld.u_ld.chk_i,
               dut.u_ld.u_ld.rg_ddr[0], dut.u_ld.u_ld.rg_ddr[1]);
    if (rst_n && dut.u_ld.u_ld.mem_resp_valid)
      $display("RESP %0t err=%0d rdata=%08h rg_first0=%08h rg_first1=%08h state=%0d chk_i=%0d",
               $time, dut.u_ld.u_ld.mem_resp_err, dut.u_ld.u_ld.mem_rdata,
               dut.u_ld.u_ld.rg_first[0], dut.u_ld.u_ld.rg_first[1],
               dut.u_ld.u_ld.state, dut.u_ld.u_ld.chk_i);
  end

  initial begin
    s_valid = 1'b0; s_data = 32'h0;
    rst_n = 1'b0;
    repeat (4) @(posedge clk);
    for (i = 0; i < 64; i = i + 1)
      dut.u_dest.dest[i] = 128'hA5A5A5A5_5A5A5A5A_DEADBEEF_CAFEBABE;
    rst_n = 1'b1;
    repeat (8) @(posedge clk);

    fd = pa24_fopen_mem(2);
    if (fd == 0) $fatal(1, "cannot open V-03");
    rc = $fscanf(fd, "%h", nwords);
    if (rc != 1) $fatal(1, "bad nwords");
    wi = 0;
    while (wi < nwords) begin
      rc = $fscanf(fd, "%h", wtmp);
      if (rc != 1) $fatal(1, "short V-03");
      stream[wi] = wtmp;
      wi = wi + 1;
    end
    $fclose(fd);

    t = 0;
    while (!s_ready && t < 20000) begin @(posedge clk); t = t + 1; end
    for (wi = 0; wi < nwords; wi = wi + 1) begin
      s_data = stream[wi];
      s_valid = 1'b1;
      t = 0;
      while (!s_ready && t < 40000) begin @(posedge clk); t = t + 1; end
      @(posedge clk);
    end
    s_valid = 1'b0;
    t = 0;
    while (!load_ack && !load_reject && t < 200000) begin @(posedge clk); t = t + 1; end
    $display("V03_TERM ack=%0d rej=%0d reason=%02h t=%0d PACK_ABI_24_24_PASS=NO",
             load_ack, load_reject, reason_code, t);
    if (load_reject && reason_code == 8'h08)
      $display("V03_DIRTY_DEST_R_SENTINEL");
    else if (load_ack)
      $display("V03_DIRTY_DEST_LOAD_OK");
    else
      $display("V03_DIRTY_DEST_OTHER");
    $finish;
  end
endmodule
