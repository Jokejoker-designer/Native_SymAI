`timescale 1ns/1ps
// XSim smoke TB for pack_loader. XSim != board. PROGRAM=NO.
module tb_pack_loader;
  logic clk;
  logic rst_n;
  logic s_valid;
  logic s_ready;
  logic [31:0] s_data;
  logic mem_cmd_valid;
  logic mem_cmd_ready;
  logic mem_cmd_write;
  logic [27:0] mem_addr;
  logic [31:0] mem_wdata;
  logic mem_resp_valid;
  logic mem_resp_ready;
  logic mem_resp_err;
  logic [31:0] mem_rdata;
  logic load_ack;
  logic load_reject;
  logic [7:0] reason_code;
  logic [31:0] active_generation;
  logic [15:0] wr_outstanding;
  logic        loader_busy;
  int stall_resp;

  logic [31:0] mem [0:65535];
  logic [31:0] resp_q [0:63];
  logic        err_q [0:63];
  int q_head, q_tail, q_delay [0:63];
  int delay_cfg;

  pack_loader dut (.*);

  initial clk = 1'b0;
  always #5 clk = ~clk;

  assign mem_cmd_ready = 1'b1;
  assign mem_resp_err = (q_head != q_tail) ? err_q[q_head] : 1'b0;
  assign mem_rdata = (q_head != q_tail) ? resp_q[q_head] : 32'd0;
  assign mem_resp_valid = (q_head != q_tail) && (q_delay[q_head] == 0) && (stall_resp == 0);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      q_head <= 0;
      q_tail <= 0;
    end else begin
      if (mem_cmd_valid && mem_cmd_ready) begin
        if (mem_cmd_write) begin
          mem[mem_addr[17:2]] <= mem_wdata;
          resp_q[q_tail] <= 32'd0;
          err_q[q_tail] <= 1'b0;
        end else begin
          resp_q[q_tail] <= mem[mem_addr[17:2]];
          err_q[q_tail] <= 1'b0;
        end
        q_delay[q_tail] <= delay_cfg;
        q_tail <= (q_tail + 1) & 63;
      end
      if (q_head != q_tail && q_delay[q_head] > 0 && stall_resp == 0)
        q_delay[q_head] <= q_delay[q_head] - 1;
      if (mem_resp_valid && mem_resp_ready)
        q_head <= (q_head + 1) & 63;
    end
  end

  logic [31:0] vec [0:1023];
  int nwords;
  int fail;

  task automatic load_mem(input string path);
    int fd;
    int i;
    string tok;
    begin
      fd = $fopen(path, "r");
      if (fd == 0) begin
        $display("FAIL cannot open %s", path);
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

  task automatic reset_dut;
    begin
      rst_n = 1'b0;
      s_valid = 1'b0;
      s_data = 32'd0;
      stall_resp = 0;
      delay_cfg = 0;
      repeat (4) @(posedge clk);
      rst_n = 1'b1;
      repeat (2) @(posedge clk);
    end
  endtask

  task automatic send_word(input logic [31:0] w);
    int t;
    begin
      t = 0;
      s_valid <= 1'b1;
      s_data <= w;
      @(posedge clk);
      while (!s_ready && t < 20000) begin
        @(posedge clk);
        t = t + 1;
      end
      if (!s_ready) begin
        $display("FAIL timeout s_ready state=%0d rx=%0d busy=%0d",
                 dut.state, dut.rx_words, dut.crc_busy);
        fail = fail + 1;
        disable send_word;
      end
    end
  endtask

  task automatic drive_vec;
    int i;
    begin
      for (i = 0; i < nwords; i++)
        send_word(vec[i]);
      s_valid <= 1'b0;
      @(posedge clk);
    end
  endtask

  task automatic wait_done(input int maxc);
    int c;
    begin
      c = 0;
      while (c < maxc && !load_ack && !load_reject) begin
        @(posedge clk);
        c = c + 1;
      end
    end
  endtask

  initial begin
    fail = 0;
    delay_cfg = 0;
    stall_resp = 0;
    rst_n = 0;
    s_valid = 0;
    s_data = 0;

    // V1 valid
    reset_dut();
    load_mem("v1_valid.mem");
    drive_vec();
    wait_done(20000);
    if (!load_ack || load_reject || active_generation != 32'd7 || reason_code != 8'h00) begin
      $display("FAIL V1 ack=%0d rej=%0d gen=%0h rc=%0h state=%0d outstanding=%0d",
               load_ack, load_reject, active_generation, reason_code, dut.state, wr_outstanding);
      fail = fail + 1;
    end else
      $display("PASS V1");

    // V2 bad magic
    reset_dut();
    load_mem("v2_bad_magic.mem");
    drive_vec();
    wait_done(20000);
    if (!load_reject || load_ack || reason_code != 8'h01 || active_generation != 32'hFFFF_FFFF) begin
      $display("FAIL V2 ack=%0d rej=%0d gen=%0h rc=%0h", load_ack, load_reject, active_generation, reason_code);
      fail = fail + 1;
    end else
      $display("PASS V2");

    // V3 bad ABI
    reset_dut();
    load_mem("v3_bad_abi.mem");
    drive_vec();
    wait_done(20000);
    if (!load_reject || load_ack || reason_code != 8'h02 || active_generation != 32'hFFFF_FFFF) begin
      $display("FAIL V3 ack=%0d rej=%0d gen=%0h rc=%0h", load_ack, load_reject, active_generation, reason_code);
      fail = fail + 1;
    end else
      $display("PASS V3");

    // V4 bad page CRC
    reset_dut();
    load_mem("v4_bad_page_crc.mem");
    drive_vec();
    wait_done(20000);
    if (!load_reject || load_ack || reason_code != 8'h05 || active_generation != 32'hFFFF_FFFF) begin
      $display("FAIL V4 ack=%0d rej=%0d gen=%0h rc=%0h", load_ack, load_reject, active_generation, reason_code);
      fail = fail + 1;
    end else
      $display("PASS V4");

    // V5 drain stall: ACK forbidden while outstanding
    reset_dut();
    stall_resp = 1;
    load_mem("v5_valid_drain.mem");
    drive_vec();
    repeat (200) @(posedge clk);
    if (load_ack) begin
      $display("FAIL V5 ACK while stalled outstanding=%0d", wr_outstanding);
      fail = fail + 1;
    end else
      $display("PASS V5 pre-release (ack=0 outstanding=%0d)", wr_outstanding);
    stall_resp = 0;
    wait_done(20000);
    if (!load_ack || load_reject) begin
      $display("FAIL V5 after release ack=%0d rej=%0d rc=%0h", load_ack, load_reject, reason_code);
      fail = fail + 1;
    end else
      $display("PASS V5 post-release");

    if (fail == 0)
      $display("M1_XSIM_SMOKE PASS %0d vectors", 5);
    else
      $display("M1_XSIM_SMOKE FAIL count=%0d", fail);
    $finish;
  end
endmodule
