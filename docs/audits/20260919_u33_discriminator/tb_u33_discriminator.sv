// tb_u33_discriminator.sv — K1 TAP: log s_valid&&s_ready beats. Product SHA unchanged.
// Dest=BRAM, bind=U33. PROGRAM=NO. Not PACK_ABI_24_24_PASS.
`timescale 1ns/1ps

module tb_u33_discriminator;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 115200;
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

  task automatic dump_tap(input string tag);
    begin
      log1($sformatf("%s n_p=%0d p0=%08h p1=%08h p2=%08h p3=%08h s_valid=%0b s_ready=%0b b_data=%08h",
                     tag, n_p,
                     (n_p > 0) ? pw[0] : 32'h0,
                     (n_p > 1) ? pw[1] : 32'h0,
                     (n_p > 2) ? pw[2] : 32'h0,
                     (n_p > 3) ? pw[3] : 32'h0,
                     u_h.p_valid, u_h.p_ready, u_h.p_data_i));
    end
  endtask

  int scenario, phase, j, total_p, begin_p, dest_writes;
  logic counting;
  always @(posedge ui_clk) begin
    if (!rst_ui_n) begin total_p=0; begin_p=0; dest_writes=0; end
    else if (counting) begin
      if (p_fire) begin total_p++; if(p_data==BEGINW) begin_p++; end
      if(u_h.d_en && u_h.d_rdy && u_h.d_cmd==0) dest_writes++;
    end
  end
  task automatic checkpoint(input int ph, input logic [31:0] expected);
    begin
      wait_word(got, 200000, mute);
      log1($sformatf("CASE=%0d PHASE=%0d mute=%0b token=%08h total_p=%0d begin_p=%0d p0=%08h p1=%08h state=%0d rx_words=%0d hw0=%08h writes=%0d",
        scenario,ph,mute,got,total_p,begin_p,pw[0],pw[1],u_h.u_ld.u_ld.state,u_h.u_ld.u_ld.rx_words,u_h.u_ld.u_ld.hw0,dest_writes));
      if(expected==0 && !mute) $fatal(1,"UNEXPECTED_REPLY");
      if(expected!=0 && (mute || got!==expected)) $fatal(1,"BAD_REPLY");
      if(dest_writes!=0) $fatal(1,"UNEXPECTED_DEST_WRITE");
    end
  endtask
  initial begin
    logfd=$fopen("discriminator.log","w"); counting=0; cap=0;
    rst100_n=0; rst_ui_n=0; uart_rx=1;
    load_mem("PA24-V-04.mem");
    if(nwords!=52 || vec[0]!==BEGINW || vec[1]!==MAGIC || vec[32]!==0) $fatal(1,"WRONG_VECTOR");
    for(scenario=0;scenario<5;scenario++) begin
      counting=0; cap=0; rst100_n=0; rst_ui_n=0; uart_rx=1;
      repeat(20) @(posedge clk100);
      rst100_n=1; rst_ui_n=1;
      repeat(100) @(posedge clk100);
      do_clear_ack();
      repeat(8) @(posedge ui_clk);
      cap=1; counting=1;
      // CASE0 clean; CASE1 extra BEGIN control; CASE2 bad MAGIC same count;
      // CASE3 omitted MAGIC control; CASE4 byte-gap inside MAGIC (no extra BEGIN).
      if(scenario==1) send_word(BEGINW);
      for(j=0;j<32;j++) begin
        if(scenario==2 && j==1) send_word(32'h12345678);
        else if(scenario==3 && j==1) begin end
        else if(scenario==4 && j==1) begin
          uart_byte(8'h4e);
          repeat(22*DIV) @(posedge clk100);
          uart_byte(8'h41);uart_byte(8'h49);uart_byte(8'h31);
        end else send_word(vec[j]);
      end
      checkpoint(1,scenario==1 ? MAG : 0);
      if(scenario!=1) begin
        send_word(vec[32]);
        checkpoint(2,scenario==2 ? MAG : 0);
        if(scenario!=2) begin
          send_word(32'h00000004);
          checkpoint(3,scenario==0 ? 32'h0200075a : MAG);
        end
      end
      if(scenario==4 && (begin_p!=1 || pw[1]!==32'h01314941)) $fatal(1,"GAP_COUNTEREXAMPLE_NOT_OBSERVED");
      log1($sformatf("CASE_DONE=%0d",scenario));
    end
    log1("DISCRIMINATOR_SIGNATURES_VERIFIED_XSIM_ONLY cases=5 PACK_ABI_24_24_PASS=NO BOARD_PASS=NO");
    $fclose(logfd); $finish;
  end
endmodule