// tb_h20_4th_byte_bp.sv
// NEXT-B causal isolate: force w_ready around the 4th-byte STOP commit.
// No RTL change. XSim != board. Not PACK_ABI_24_24_PASS / not BOARD_PASS.
// Claim under test:
//   4TH_BYTE_BACKPRESSURE → WORD_DROP → RATE_DEPENDENT_FAILURE
`timescale 1ns/1ps

module tb_h20_4th_byte_bp;
  localparam int CLK_HZ = 100_000_000;
  localparam int BAUD   = 1_000_000;
  localparam int DIV    = CLK_HZ / BAUD;

  localparam logic [31:0] W0     = 32'hA1B2C3D4;
  localparam logic [31:0] W1     = 32'h11223344;
  localparam logic [31:0] W2     = 32'h55667788;
  localparam logic [31:0] BEGINW = 32'h00800001;
  localparam logic [31:0] MAGIC  = 32'h3149414E;
  localparam logic [31:0] TOK_UNSUP = 32'h0200075A;
  localparam logic [31:0] TOK_MAG   = 32'h0200015A;

  logic clk, rst_n, rx, w_valid, w_ready, ready_gate, pack_en;
  logic [31:0] w_data;
  logic idle;

  uart_rx_word #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_rx (
    .clk, .rst_n, .rx, .w_valid, .w_ready, .w_data, .flush(1'b0), .idle, .rx_sync()
  );

  logic s_valid, s_ready;
  logic [31:0] s_data;
  logic mem_cmd_valid, mem_cmd_ready, mem_cmd_write, mem_resp_valid, mem_resp_ready, mem_resp_err;
  logic [27:0] mem_addr;
  logic [31:0] mem_wdata, mem_rdata, active_generation;
  logic load_ack, load_reject, loader_busy;
  logic [7:0] reason_code;
  logic [15:0] wr_outstanding;

  pack_loader u_ld (
    .clk, .rst_n,
    .s_valid, .s_ready, .s_data,
    .mem_cmd_valid, .mem_cmd_ready, .mem_cmd_write, .mem_addr, .mem_wdata,
    .mem_resp_valid, .mem_resp_ready, .mem_resp_err, .mem_rdata,
    .load_ack, .load_reject, .reason_code, .active_generation, .wr_outstanding, .loader_busy
  );

  assign mem_cmd_ready  = 1'b1;
  assign mem_resp_err   = 1'b0;
  assign mem_rdata       = 32'h0;
  assign mem_resp_valid  = 1'b0;

  assign w_ready = ready_gate && (!pack_en || s_ready);
  assign s_valid  = pack_en && w_valid;
  assign s_data   = w_data;

  initial clk = 1'b0;
  always #5 clk = ~clk;

  int bytes_sent, bytes_stop, words_emitted, words_dropped, n_hs;
  logic [31:0] emitted [0:15];
  int bix_after;
  logic [31:0] pack_token;
  string pack_name;

  wire drop_now = (u_rx.st == 2'd3) && (u_rx.div == 16'h0) && (u_rx.bix == 2'd3) &&
                  w_valid && !w_ready;
  wire stop_now = (u_rx.st == 2'd3) && (u_rx.div == 16'h0);

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      bytes_stop <= 0;
      words_dropped <= 0;
      words_emitted <= 0;
      n_hs <= 0;
    end else begin
      if (stop_now)
        bytes_stop <= bytes_stop + 1;
      if (drop_now)
        words_dropped <= words_dropped + 1;
      if (w_valid && w_ready) begin
        emitted[n_hs] <= w_data;
        n_hs <= n_hs + 1;
        words_emitted <= words_emitted + 1;
      end
    end
  end

  task automatic reset_all;
    begin
      rst_n = 1'b0;
      rx = 1'b1;
      ready_gate = 1'b1;
      pack_en = 1'b0;
      bytes_sent = 0;
      pack_token = 32'h0;
      pack_name = "NONE";
      repeat (8) @(posedge clk);
      rst_n = 1'b1;
      repeat (8) @(posedge clk);
    end
  endtask

  task automatic uart_byte(input logic [7:0] b);
    int k;
    begin
      bytes_sent = bytes_sent + 1;
      rx <= 1'b0;
      repeat (DIV) @(posedge clk);
      for (k = 0; k < 8; k++) begin
        rx <= b[k];
        repeat (DIV) @(posedge clk);
      end
      rx <= 1'b1;
      repeat (DIV) @(posedge clk);
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

  task automatic wait_idle(input int maxc);
    int c;
    begin
      c = 0;
      while (c < maxc && u_rx.st != 2'd0) begin
        @(posedge clk);
        c = c + 1;
      end
      repeat (4) @(posedge clk);
    end
  endtask

  task automatic snap_bix;
    begin
      @(posedge clk);
      bix_after = u_rx.bix;
    end
  endtask

  task automatic wait_pack(input int maxc);
    int c;
    begin
      c = 0;
      while (c < maxc && !load_reject && !load_ack) begin
        @(posedge clk);
        c = c + 1;
      end
      if (load_reject) begin
        pack_token = {8'h02, 8'h00, reason_code, 8'h5A};
        if (reason_code == 8'h07) pack_name = "UNSUP";
        else if (reason_code == 8'h01) pack_name = "MAG";
        else pack_name = "REJ";
      end else if (load_ack) begin
        pack_token = 32'h010000A5;
        pack_name = "ACK";
      end else begin
        pack_token = 32'h0;
        pack_name = "MUTE";
      end
    end
  endtask

  function automatic bit aligned_next(input logic [31:0] got, input logic [31:0] exp);
    aligned_next = (got === exp);
  endfunction

  task automatic report_case(
      input string cname,
      input int words_exp,
      input logic [31:0] next_exp,
      input bit expect_drop,
      input bit expect_align
  );
    bit lost, align, next_ok;
    int i;
    begin
      snap_bix();
      lost = (words_emitted < words_exp) || (words_dropped > 0);
      next_ok = (words_emitted == 0) ? 1'b1 : aligned_next(emitted[words_emitted-1], next_exp);
      if (words_emitted >= 2)
        next_ok = aligned_next(emitted[1], next_exp);
      align = next_ok;
      $display("H20 CASE %s", cname);
      $display("  host_bytes_sent=%0d bytes_stop=%0d words_expected=%0d words_emitted=%0d",
               bytes_sent, bytes_stop, words_exp, words_emitted);
      $display("  word_lost=%0d words_dropped_evt=%0d bix_after=%0d",
               lost, words_dropped, bix_after);
      $write("  emitted=");
      for (i = 0; i < words_emitted; i++)
        $write(" %08h", emitted[i]);
      $display("");
      $display("  next_word_alignment=%s (last_or_2nd=%08h exp=%08h)",
               align ? "ALIGNED" : "MISALIGNED",
               (words_emitted == 0) ? 32'h0 : emitted[words_emitted-1], next_exp);
      $display("  pack_token=%08h %s reason=%02h", pack_token, pack_name, reason_code);
      $display("  expect_drop=%0d got_drop=%0d expect_align=%0d got_align=%0d",
               expect_drop, words_dropped > 0, expect_align, align);
      if (expect_drop && words_dropped == 0)
        $display("  CHECK_FAIL %s missing drop", cname);
      else if (!expect_drop && words_dropped != 0)
        $display("  CHECK_FAIL %s unexpected drop", cname);
      else if (expect_align && !align)
        $display("  CHECK_FAIL %s misaligned", cname);
      else
        $display("  CHECK_OK %s", cname);
    end
  endtask

  initial begin
    $display("H20_4TH_BYTE_BP_XSIM start BAUD=%0d DIV=%0d (predicate is baud-independent)",
             BAUD, DIV);

    // ------------------------------------------------------------------
    // 1. w_ready always high
    // ------------------------------------------------------------------
    reset_all();
    ready_gate = 1'b1;
    send_word(W0);
    send_word(W1);
    wait_idle(DIV * 4);
    report_case("1_ALWAYS_HIGH", 2, W1, 1'b0, 1'b1);

    // ------------------------------------------------------------------
    // 2. w_ready low before byte 4 of the FIRST word, high at 4th STOP
    //    First word still emits because !w_valid at commit.
    // ------------------------------------------------------------------
    reset_all();
    ready_gate = 1'b0;
    uart_byte(W0[7:0]);
    uart_byte(W0[15:8]);
    uart_byte(W0[23:16]);
    ready_gate = 1'b1;
    uart_byte(W0[31:24]);
    wait_idle(DIV * 4);
    report_case("2_LOW_BEFORE_BYTE4", 1, W0, 1'b0, 1'b1);

    // ------------------------------------------------------------------
    // 3. low exactly at byte-4 commit of W1 while W0 still valid
    //    First word emits because !w_valid; it sits (!w_ready). W1 4th STOP drops.
    // ------------------------------------------------------------------
    reset_all();
    ready_gate = 1'b0;
    send_word(W0);
    wait_idle(DIV);
    send_word(W1);
    wait_idle(DIV * 4);
    $display("H20 CASE 3_LOW_AT_BYTE4_COMMIT sitting w_data=%08h w_valid=%0b bix=%0d drop=%0d emitted_hs=%0d",
             u_rx.w_data, w_valid, u_rx.bix, words_dropped, words_emitted);
    report_case("3_LOW_AT_BYTE4_COMMIT", 2, W0, 1'b1, 1'b1);
    ready_gate = 1'b1;
    repeat (8) @(posedge clk);
    send_word(W2);
    wait_idle(DIV * 4);
    $display("  after_take_then_W2 emitted_n=%0d e0=%08h e1=%08h bix=%0d drop=%0d",
             words_emitted,
             (words_emitted == 0) ? 32'h0 : emitted[0],
             (words_emitted < 2) ? 32'h0 : emitted[1],
             u_rx.bix, words_dropped);
    if (words_emitted >= 2 && emitted[0] === W0 && emitted[1] === W2)
      $display("  CHECK_OK 3b_NEXT_WORD_ALIGNED_W2 (W1 lost, W2 not shifted)");
    else
      $display("  CHECK_FAIL 3b e0=%08h e1=%08h exp W0 then W2",
               (words_emitted == 0) ? 32'h0 : emitted[0],
               (words_emitted < 2) ? 32'h0 : emitted[1]);

    // ------------------------------------------------------------------
    // 4. low AFTER W0 already valid, UART idle, then take, then W1
    // ------------------------------------------------------------------
    reset_all();
    ready_gate = 1'b1;
    send_word(W0);
    wait_idle(DIV);
    ready_gate = 1'b0;
    repeat (DIV * 20) @(posedge clk);
    ready_gate = 1'b1;
    repeat (8) @(posedge clk);
    send_word(W1);
    wait_idle(DIV * 4);
    report_case("4_LOW_AFTER_VALID_IDLE", 2, W1, 1'b0, 1'b1);

    // ------------------------------------------------------------------
    // 5. repeated Pack words with controlled stalls.
    //    Dummy sits, BEGIN dropped at 4th STOP, dummy taken off-pack,
    //    MAGIC is first opcode into pack_loader → R_UNSUP.
    // ------------------------------------------------------------------
    reset_all();
    pack_en = 1'b0;
    ready_gate = 1'b0;
    send_word(W0);
    send_word(BEGINW);
    send_word(MAGIC);
    wait_idle(DIV * 4);
    $display("H20 CASE 5_REPEATED_PACK_STALL pre-drain sitting=%08h drop=%0d bix=%0d",
             u_rx.w_data, words_dropped, u_rx.bix);
    ready_gate = 1'b1;
    repeat (8) @(posedge clk);
    pack_en = 1'b1;
    send_word(MAGIC);
    wait_idle(DIV * 8);
    wait_pack(20000);
    report_case("5_REPEATED_PACK_STALL", 4, MAGIC, 1'b1, 1'b1);
    if (pack_token === TOK_UNSUP)
      $display("  CHECK_OK 5_PACK_TOKEN_UNSUP (dropped BEGIN; MAGIC first opcode)");
    else if (pack_token === TOK_MAG)
      $display("  CHECK_OK 5_PACK_TOKEN_MAG");
    else
      $display("  CHECK_INFO 5_PACK_TOKEN %s %08h (UNSUP=%08h MAG=%08h)",
               pack_name, pack_token, TOK_UNSUP, TOK_MAG);

    $display("H20_4TH_BYTE_BP_XSIM_DONE not PACK_ABI_24_24_PASS / not BOARD_PASS");
    $finish;
  end
endmodule
