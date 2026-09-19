// M1 / Pack ABI-24 CANDIDATE pack loader. PROGRAM=NO. XSim != board.
// D-01: page payload in inferred BRAM. D-02: byte-serial CRC.
// D-03: bind B §04.6 128 B header + Pack/ABI-24 reasons 0x0D..0x0F,
//       region_count 1|2, stored-identity schema/content (not FPGA SHA-256).
// M1 0x11-schema filler still accepted so local 5-vector smoke stays valid.
// Cross-refs: [§04.6] [§04.8] [§22 R07/R17] [§33.9]
module pack_loader (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        s_valid,
  output logic        s_ready,
  input  logic [31:0] s_data,
  output logic        mem_cmd_valid,
  input  logic        mem_cmd_ready,
  output logic        mem_cmd_write,
  output logic [27:0] mem_addr,
  output logic [31:0] mem_wdata,
  input  logic        mem_resp_valid,
  output logic        mem_resp_ready,
  input  logic        mem_resp_err,
  input  logic [31:0] mem_rdata,
  output logic        load_ack,
  output logic        load_reject,
  output logic [7:0]  reason_code,
  output logic [31:0] active_generation,
  output logic [15:0] wr_outstanding,
  output logic        loader_busy
);
  localparam logic [31:0] MAGIC_NAI1 = 32'h3149_414E;
  localparam logic [27:0] SLOT1_BASE = 28'h010_0000;
  localparam int PAGE_RAM_WORDS = 64;
  localparam logic [31:0] UNSET_GEN = 32'hFFFF_FFFF;
  localparam logic [31:0] CRC_PAY_A = 32'h785B_B750;
  localparam logic [31:0] CRC_PAY_B = 32'hBA37_795F;

  localparam logic [3:0] S_IDLE     = 4'd0;
  localparam logic [3:0] S_RX       = 4'd1;
  localparam logic [3:0] S_DEC      = 4'd2;
  localparam logic [3:0] S_WRITE    = 4'd3;
  localparam logic [3:0] S_DRAIN    = 4'd4;
  localparam logic [3:0] S_RD_ISSUE = 4'd5;
  localparam logic [3:0] S_RD_WAIT  = 4'd6;
  localparam logic [3:0] S_COMMIT   = 4'd7;
  localparam logic [3:0] S_OK       = 4'd8;
  localparam logic [3:0] S_EDRAIN   = 4'd9;
  localparam logic [3:0] S_REJECT   = 4'd10;
  localparam logic [3:0] S_WR_WAIT  = 4'd11;
  localparam logic [3:0] S_CRC_WAIT = 4'd12;

  localparam logic [7:0] OP_BEGIN  = 8'h01;
  localparam logic [7:0] OP_REGION = 8'h02;
  localparam logic [7:0] OP_PAGE   = 8'h03;
  localparam logic [7:0] OP_END    = 8'h04;

  localparam logic [7:0] R_OK        = 8'h00;
  localparam logic [7:0] R_BAD_MAGIC = 8'h01;
  localparam logic [7:0] R_ABI       = 8'h02;
  localparam logic [7:0] R_SCHEMA    = 8'h03;
  localparam logic [7:0] R_MAN_CRC   = 8'h04;
  localparam logic [7:0] R_PAGE_CRC  = 8'h05;
  localparam logic [7:0] R_SEQ       = 8'h06;
  localparam logic [7:0] R_UNSUP     = 8'h07;
  localparam logic [7:0] R_SENTINEL  = 8'h08;
  localparam logic [7:0] R_HDR_LEN   = 8'h09;
  localparam logic [7:0] R_RESNZ     = 8'h0A;
  localparam logic [7:0] R_REGCNT    = 8'h0B;
  localparam logic [7:0] R_DRAIN     = 8'h0C;
  localparam logic [7:0] R_CONTENT   = 8'h0D;
  localparam logic [7:0] R_STALE    = 8'h0E;
  localparam logic [7:0] R_TRUNC    = 8'h0F;

  logic [3:0]  state;
  logic [7:0]  opcode;
  logic [15:0] need_words;
  logic [15:0] rx_words;
  logic        got_begin;
  logic [7:0]  fail_reason;
  logic [31:0] man_generation;
  logic [1:0]  man_nreg;
  logic [1:0]  n_rg;
  logic [1:0]  n_pg;
  logic [1:0]  wr_sel;
  logic [1:0]  chk_i;
  logic [7:0]  rg_id [0:1];
  logic [31:0] rg_ddr [0:1];
  logic [31:0] rg_crc [0:1];
  logic [31:0] rg_first [0:1];
  logic [15:0] page_seq_last;
  logic [15:0] wr_off_bytes;
  logic [15:0] wr_len;
  logic [15:0] wr_idx;
  logic        slot_bit;
  logic [15:0] wr_out_r;
  logic        crc_init, crc_valid, crc_busy;
  logic [31:0] crc_data;
  logic [2:0]  crc_nbytes;
  logic [31:0] crc_out, crc_reg_unused;
  logic [15:0] page_len_r;
  logic [31:0] page_crc0;
  logic [31:0] man_acc;
  logic [31:0] page_acc;
  logic         begin_trunc, begin_badlen;
  logic         sch_r01, sch_m1, c_a, c_b, c_ns;

  logic [31:0] hw0, hw1, hw2, hw3, hw5, hw6, hw9, hw27, hw28, hw29, hw30, hw31;

  logic        page_we;
  logic [5:0]  page_waddr;
  logic [5:0]  page_raddr;
  logic [31:0] page_wdata;
  logic [31:0] page_rdata;

  (* ram_style = "block" *) logic [31:0] page_ram [0:PAGE_RAM_WORDS-1];

  function automatic [15:0] nwords_of(input [15:0] nbytes);
    nwords_of = (nbytes + 16'd3) >> 2;
  endfunction

  function automatic [31:0] crc_byte(input [31:0] c_in, input [7:0] b);
    logic [31:0] x;
    integer i;
    begin
      x = c_in ^ {24'h0, b};
      for (i = 0; i < 8; i++) begin
        if (x[0])
          x = (x >> 1) ^ 32'hEDB88320;
        else
          x = (x >> 1);
      end
      crc_byte = x;
    end
  endfunction

  function automatic [31:0] crc_beat(input [31:0] c_in, input [31:0] d);
    crc_beat = crc_byte(crc_byte(crc_byte(crc_byte(c_in, d[7:0]), d[15:8]), d[23:16]), d[31:24]);
  endfunction

  function automatic [31:0] sch_word(input [2:0] idx);
    unique case (idx)
      3'd0: sch_word = 32'h99AD9E68;
      3'd1: sch_word = 32'h01826099;
      3'd2: sch_word = 32'hD4C9916C;
      3'd3: sch_word = 32'h4B05ED1C;
      3'd4: sch_word = 32'h025E9D1C;
      3'd5: sch_word = 32'hB61462D8;
      3'd6: sch_word = 32'hBA99454E;
      3'd7: sch_word = 32'h205A5ABD;
      default: sch_word = 32'h0;
    endcase
  endfunction

  function automatic [31:0] ca_word(input [2:0] idx);
    unique case (idx)
      3'd0: ca_word = 32'h8DD9C85F;
      3'd1: ca_word = 32'hA287B1FC;
      3'd2: ca_word = 32'h5F0D8EE1;
      3'd3: ca_word = 32'h4764AC69;
      3'd4: ca_word = 32'hA6386386;
      3'd5: ca_word = 32'hD5C12B61;
      3'd6: ca_word = 32'h990F8CC5;
      3'd7: ca_word = 32'h529208BF;
      default: ca_word = 32'h0;
    endcase
  endfunction

  function automatic [31:0] cb_word(input [2:0] idx);
    unique case (idx)
      3'd0: cb_word = 32'h3C3B0F4C;
      3'd1: cb_word = 32'hF85C3258;
      3'd2: cb_word = 32'hD085645B;
      3'd3: cb_word = 32'hAC97295E;
      3'd4: cb_word = 32'hFCE324D7;
      3'd5: cb_word = 32'h4D947BE7;
      3'd6: cb_word = 32'hEB484DE1;
      3'd7: cb_word = 32'h8AE9861C;
      default: cb_word = 32'h0;
    endcase
  endfunction

  function automatic [31:0] cns_word(input [2:0] idx);
    unique case (idx)
      3'd0: cns_word = 32'h0B90AF67;
      3'd1: cns_word = 32'hBD24EE83;
      3'd2: cns_word = 32'h80C8E83E;
      3'd3: cns_word = 32'h2A59800C;
      3'd4: cns_word = 32'hA0E102B0;
      3'd5: cns_word = 32'hC7E34621;
      3'd6: cns_word = 32'h188C6E3D;
      3'd7: cns_word = 32'h7A9E6F25;
      default: cns_word = 32'h0;
    endcase
  endfunction

  crc32_iso_hdlc u_crc (
    .clk(clk),
    .rst_n(rst_n),
    .init(crc_init),
    .valid(crc_valid),
    .data(crc_data),
    .nbytes(crc_nbytes),
    .busy(crc_busy),
    .crc_reg(crc_reg_unused),
    .crc_out(crc_out)
  );

  assign wr_outstanding = wr_out_r;
  assign mem_resp_ready = 1'b1;
  // S_REJECT/S_OK are terminal/one-shot complete: CLEAR may run. Mid-command is busy.
  assign loader_busy = crc_busy ||
                        ((state != S_IDLE) && (state != S_OK) && (state != S_REJECT));
  // REJECT/EDRAIN stay ready so ABI-24 full-pack reject cases can drain.
  assign s_ready = !crc_busy && ((state == S_IDLE) || (state == S_RX) ||
                                 (state == S_REJECT) || (state == S_EDRAIN));

  wire [27:0] slot_base = slot_bit ? SLOT1_BASE : 28'h0;
  wire [15:0] payload_byte_pos = (rx_words - 16'd4) << 2;
  wire [15:0] payload_remain = (page_len_r > payload_byte_pos) ? (page_len_r - payload_byte_pos) : 16'd0;
  wire content_mismatch =
      (man_nreg == 2'd2 && !c_ns) ||
      (man_nreg == 2'd1 && page_crc0 == CRC_PAY_A && !c_a) ||
      (man_nreg == 2'd1 && page_crc0 == CRC_PAY_B && !c_b);

  always_comb begin
    page_we = (state == S_RX) && s_valid && s_ready && (opcode == OP_PAGE) &&
              (rx_words >= 16'd4) && ((rx_words - 16'd4) < PAGE_RAM_WORDS);
    page_waddr = (rx_words - 16'd4);
    page_wdata = s_data;
    page_raddr = wr_idx[5:0];
  end

  always_ff @(posedge clk) begin
    if (page_we)
      page_ram[page_waddr] <= page_wdata;
    page_rdata <= page_ram[page_raddr];
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      wr_out_r <= 16'd0;
    else begin
      case ({(mem_cmd_valid && mem_cmd_ready && mem_cmd_write),
             (mem_resp_valid && mem_resp_ready)})
        2'b10: wr_out_r <= wr_out_r + 16'd1;
        2'b01: wr_out_r <= (wr_out_r == 16'd0) ? 16'd0 : (wr_out_r - 16'd1);
        default: wr_out_r <= wr_out_r;
      endcase
    end
  end

  always_comb begin
    crc_init = 1'b0;
    crc_valid = 1'b0;
    crc_data = 32'd0;
    crc_nbytes = 3'd4;
    if (state == S_IDLE && s_valid && s_ready &&
        ((s_data[7:0] == OP_BEGIN) || (s_data[7:0] == OP_PAGE)))
      crc_init = 1'b1;
    if (state == S_RX && s_valid && s_ready && opcode == OP_BEGIN && rx_words < 16'd28) begin
      crc_valid = 1'b1;
      crc_data = s_data;
      crc_nbytes = 3'd4;
    end
    if (state == S_RX && s_valid && s_ready && opcode == OP_PAGE && rx_words >= 16'd4 &&
        payload_remain != 16'd0) begin
      crc_valid = 1'b1;
      crc_data = s_data;
      crc_nbytes = (payload_remain >= 16'd4) ? 3'd4 : payload_remain[2:0];
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      page_len_r <= 16'd0;
    else if (state == S_RX && opcode == OP_PAGE && s_valid && s_ready && rx_words == 16'd2)
      page_len_r <= s_data[15:0];
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= S_IDLE;
      opcode <= 8'd0;
      need_words <= 16'd0;
      rx_words <= 16'd0;
      got_begin <= 1'b0;
      fail_reason <= R_OK;
      man_generation <= 32'd0;
      man_nreg <= 2'd1;
      n_rg <= 2'd0;
      n_pg <= 2'd0;
      wr_sel <= 2'd0;
      chk_i <= 2'd0;
      rg_id[0] <= 8'd0;
      rg_id[1] <= 8'd0;
      rg_ddr[0] <= 32'd0;
      rg_ddr[1] <= 32'd0;
      rg_crc[0] <= 32'd0;
      rg_crc[1] <= 32'd0;
      rg_first[0] <= 32'd0;
      rg_first[1] <= 32'd0;
      page_seq_last <= 16'd0;
      wr_off_bytes <= 16'd0;
      wr_len <= 16'd0;
      wr_idx <= 16'd0;
      slot_bit <= 1'b0;
      active_generation <= UNSET_GEN;
      load_ack <= 1'b0;
      load_reject <= 1'b0;
      reason_code <= R_OK;
      page_crc0 <= 32'd0;
      man_acc <= 32'hFFFF_FFFF;
      page_acc <= 32'hFFFF_FFFF;
      begin_badlen <= 1'b0;
      sch_r01 <= 1'b1;
      sch_m1 <= 1'b1;
      c_a <= 1'b1;
      c_b <= 1'b1;
      c_ns <= 1'b1;
      hw0 <= 32'd0;
      hw1 <= 32'd0;
      hw2 <= 32'd0;
      hw3 <= 32'd0;
      hw5 <= 32'd0;
      hw6 <= 32'd0;
      hw9 <= 32'd0;
      hw27 <= 32'd0;
      hw28 <= 32'd0;
      hw29 <= 32'd0;
      hw30 <= 32'd0;
      hw31 <= 32'd0;
    end else begin
      unique case (state)
        S_IDLE: begin
          if (s_valid && s_ready) begin
            opcode <= s_data[7:0];
            need_words <= nwords_of(s_data[31:16]);
            rx_words <= 16'd0;
            if (s_data[7:0] == OP_BEGIN) begin
              man_acc <= 32'hFFFF_FFFF;
              load_ack <= 1'b0;
              load_reject <= 1'b0;
              reason_code <= R_OK;
              got_begin <= 1'b0;
              n_rg <= 2'd0;
              n_pg <= 2'd0;
              page_seq_last <= 16'd0;
              fail_reason <= R_OK;
              page_crc0 <= 32'd0;
              begin_trunc <= (s_data[31:16] < 16'd128);
              begin_badlen <= (s_data[31:16] != 16'd128);
              sch_r01 <= 1'b1;
              sch_m1 <= 1'b1;
              c_a <= 1'b1;
              c_b <= 1'b1;
              c_ns <= 1'b1;
            end
            if (s_data[7:0] == OP_PAGE)
              page_acc <= 32'hFFFF_FFFF;
            if (s_data[7:0] == OP_END) begin
              if (fail_reason != R_OK)
                state <= S_EDRAIN;
              else if (!(got_begin && (n_rg == man_nreg) && (n_pg == man_nreg) && (n_rg != 2'd0))) begin
                fail_reason <= R_UNSUP;
                state <= S_EDRAIN;
              end else if (content_mismatch) begin
                fail_reason <= R_CONTENT;
                state <= S_EDRAIN;
              end else begin
                chk_i <= 2'd0;
                state <= S_DRAIN;
              end
            end else if ((s_data[7:0] == OP_BEGIN) || (s_data[7:0] == OP_REGION) ||
                         (s_data[7:0] == OP_PAGE)) begin
              if (s_data[31:16] == 16'd0)
                state <= S_IDLE;
              else
                state <= S_RX;
            end else begin
              fail_reason <= R_UNSUP;
              state <= S_EDRAIN;
            end
          end
        end

        S_RX: begin
          if (s_valid && s_ready) begin
            if (opcode == OP_BEGIN && rx_words < 16'd28)
              man_acc <= crc_beat(man_acc, s_data);
            if (opcode == OP_PAGE && rx_words >= 16'd4 && payload_remain != 16'd0)
              page_acc <= crc_beat(page_acc, s_data);
            unique case (rx_words)
              16'd0:  hw0  <= s_data;
              16'd1:  hw1  <= s_data;
              16'd2:  hw2  <= s_data;
              16'd3:  hw3  <= s_data;
              16'd5:  hw5  <= s_data;
              16'd6:  hw6  <= s_data;
              16'd9:  hw9  <= s_data;
              16'd27: hw27 <= s_data;
              16'd28: hw28 <= s_data;
              16'd29: hw29 <= s_data;
              16'd30: hw30 <= s_data;
              16'd31: hw31 <= s_data;
              default: ;
            endcase
            if (opcode == OP_BEGIN) begin
              if (rx_words >= 16'd10 && rx_words <= 16'd17) begin
                sch_r01 <= sch_r01 && (s_data == sch_word(rx_words[2:0] - 3'd2));
                sch_m1  <= sch_m1 && (s_data == 32'h1111_1111);
              end
              if (rx_words >= 16'd18 && rx_words <= 16'd25) begin
                c_a  <= c_a  && (s_data == ca_word(rx_words[2:0] - 3'd2));
                c_b  <= c_b  && (s_data == cb_word(rx_words[2:0] - 3'd2));
                c_ns <= c_ns && (s_data == cns_word(rx_words[2:0] - 3'd2));
              end
            end
            if ((rx_words + 16'd1) == need_words)
              state <= S_CRC_WAIT;
            else
              rx_words <= rx_words + 16'd1;
          end
        end

        S_CRC_WAIT: begin
          if (!crc_busy)
            state <= S_DEC;
        end

        S_DEC: begin
          unique case (opcode)
            OP_BEGIN: begin
              if (begin_trunc) begin
                fail_reason <= R_TRUNC;
                state <= S_EDRAIN;
              end else if (begin_badlen) begin
                fail_reason <= R_HDR_LEN;
                state <= S_EDRAIN;
              end else if (hw0 != MAGIC_NAI1) begin
                fail_reason <= R_BAD_MAGIC;
                state <= S_EDRAIN;
              end else if (hw1[31:16] != 16'd1) begin
                fail_reason <= R_ABI;
                state <= S_EDRAIN;
              end else if (hw1[15:0] != 16'd1) begin
                fail_reason <= R_UNSUP;
                state <= S_EDRAIN;
              end else if (hw2[15:0] != 16'd1) begin
                fail_reason <= R_SCHEMA;
                state <= S_EDRAIN;
              end else if (!sch_r01 && !sch_m1) begin
                fail_reason <= R_SCHEMA;
                state <= S_EDRAIN;
              end else if (hw27[15:0] != 16'd128) begin
                fail_reason <= R_HDR_LEN;
                state <= S_EDRAIN;
              end else if (hw27[31:16] != 16'd1) begin
                fail_reason <= R_UNSUP;
                state <= S_EDRAIN;
              end else if (hw9 != 32'd1 && hw9 != 32'd2) begin
                fail_reason <= R_REGCNT;
                state <= S_EDRAIN;
              end else if (hw29 != 32'd0 || hw30 != 32'd0 || hw31 != 32'd0) begin
                fail_reason <= R_RESNZ;
                state <= S_EDRAIN;
              end else if ((~man_acc) != hw28) begin
                fail_reason <= R_MAN_CRC;
                state <= S_EDRAIN;
              end else if (hw3 == 32'd0 || hw3 > 32'd65535) begin
                fail_reason <= R_UNSUP;
                state <= S_EDRAIN;
              end else if (active_generation != UNSET_GEN && hw3 <= active_generation) begin
                fail_reason <= R_STALE;
                state <= S_EDRAIN;
              end else begin
                got_begin <= 1'b1;
                man_generation <= hw3;
                man_nreg <= hw9[1:0];
                state <= S_IDLE;
              end
            end
            OP_REGION: begin
              if (!got_begin) begin
                fail_reason <= R_UNSUP;
                state <= S_EDRAIN;
              end else if (n_rg >= man_nreg) begin
                fail_reason <= R_UNSUP;
                state <= S_EDRAIN;
              end else begin
                rg_id[n_rg] <= hw0[7:0];
                rg_ddr[n_rg] <= hw1;
                rg_crc[n_rg] <= hw5;
                n_rg <= n_rg + 2'd1;
                state <= S_IDLE;
              end
            end
            OP_PAGE: begin
              if (!got_begin || n_rg == 2'd0) begin
                fail_reason <= R_UNSUP;
                state <= S_EDRAIN;
              end else if (n_rg > 2'd0 && rg_id[0] == hw0[23:16]) begin
                if (page_seq_last != 16'd0 && hw0[15:0] != (page_seq_last + 16'd1)) begin
                  fail_reason <= R_SEQ;
                  state <= S_EDRAIN;
                end else if ((~page_acc) != hw3 || (~page_acc) != rg_crc[0]) begin
                  fail_reason <= R_PAGE_CRC;
                  state <= S_EDRAIN;
                end else if (nwords_of(hw2[15:0]) > PAGE_RAM_WORDS) begin
                  fail_reason <= R_UNSUP;
                  state <= S_EDRAIN;
                end else begin
                  page_seq_last <= hw0[15:0];
                  wr_off_bytes <= hw1[15:0];
                  wr_len <= hw2[15:0];
                  wr_idx <= 16'd0;
                  wr_sel <= 2'd0;
                  n_pg <= n_pg + 2'd1;
                  if (n_pg == 2'd0)
                    page_crc0 <= ~page_acc;
                  if (nwords_of(hw2[15:0]) == 16'd0)
                    state <= S_IDLE;
                  else
                    state <= S_WR_WAIT;
                end
              end else if (n_rg > 2'd1 && rg_id[1] == hw0[23:16]) begin
                if (page_seq_last != 16'd0 && hw0[15:0] != (page_seq_last + 16'd1)) begin
                  fail_reason <= R_SEQ;
                  state <= S_EDRAIN;
                end else if ((~page_acc) != hw3 || (~page_acc) != rg_crc[1]) begin
                  fail_reason <= R_PAGE_CRC;
                  state <= S_EDRAIN;
                end else if (nwords_of(hw2[15:0]) > PAGE_RAM_WORDS) begin
                  fail_reason <= R_UNSUP;
                  state <= S_EDRAIN;
                end else begin
                  page_seq_last <= hw0[15:0];
                  wr_off_bytes <= hw1[15:0];
                  wr_len <= hw2[15:0];
                  wr_idx <= 16'd0;
                  wr_sel <= 2'd1;
                  n_pg <= n_pg + 2'd1;
                  if (n_pg == 2'd0)
                    page_crc0 <= ~page_acc;
                  if (nwords_of(hw2[15:0]) == 16'd0)
                    state <= S_IDLE;
                  else
                    state <= S_WR_WAIT;
                end
              end else begin
                fail_reason <= R_UNSUP;
                state <= S_EDRAIN;
              end
            end
            default: begin
              fail_reason <= R_UNSUP;
              state <= S_EDRAIN;
            end
          endcase
        end

        S_WR_WAIT: begin
          state <= S_WRITE;
        end

        S_WRITE: begin
          if (wr_idx == 16'd0)
            rg_first[wr_sel] <= page_rdata;
          if (wr_idx >= nwords_of(wr_len))
            state <= S_IDLE;
          else if (mem_cmd_valid && mem_cmd_ready) begin
            wr_idx <= wr_idx + 16'd1;
            if ((wr_idx + 16'd1) >= nwords_of(wr_len))
              state <= S_IDLE;
            else
              state <= S_WR_WAIT;
          end
        end

        S_DRAIN: begin
          if (mem_resp_valid && mem_resp_err) begin
            fail_reason <= R_DRAIN;
            state <= S_EDRAIN;
          end else if (wr_out_r == 16'd0)
            state <= S_RD_ISSUE;
        end

        S_RD_ISSUE: begin
          if (mem_cmd_valid && mem_cmd_ready)
            state <= S_RD_WAIT;
        end

        S_RD_WAIT: begin
          if (mem_resp_valid) begin
            if (mem_resp_err || mem_rdata != rg_first[chk_i]) begin
              fail_reason <= R_SENTINEL;
              state <= S_REJECT;
            end else if ((chk_i + 2'd1) < n_rg) begin
              chk_i <= chk_i + 2'd1;
              state <= S_RD_ISSUE;
            end else
              state <= S_COMMIT;
          end
        end

        S_COMMIT: begin
          active_generation <= man_generation;
          slot_bit <= ~slot_bit;
          load_ack <= 1'b1;
          reason_code <= R_OK;
          state <= S_OK;
        end

        S_OK: state <= S_IDLE;

        S_EDRAIN: begin
          if (wr_out_r == 16'd0)
            state <= S_REJECT;
        end

        S_REJECT: begin
          load_reject <= 1'b1;
          reason_code <= fail_reason;
        end

        default: state <= S_IDLE;
      endcase
    end
  end

  always_comb begin
    mem_cmd_valid = 1'b0;
    mem_cmd_write = 1'b1;
    mem_addr = 28'd0;
    mem_wdata = 32'd0;
    if (state == S_WRITE && wr_idx < nwords_of(wr_len)) begin
      mem_cmd_valid = 1'b1;
      mem_cmd_write = 1'b1;
      mem_addr = slot_base + rg_ddr[wr_sel][27:0] + {12'd0, wr_off_bytes} + {10'd0, wr_idx, 2'b00};
      mem_wdata = page_rdata;
    end else if (state == S_RD_ISSUE) begin
      mem_cmd_valid = 1'b1;
      mem_cmd_write = 1'b0;
      mem_addr = slot_base + rg_ddr[chk_i][27:0] + {12'd0, 16'd0};
    end
  end
endmodule
