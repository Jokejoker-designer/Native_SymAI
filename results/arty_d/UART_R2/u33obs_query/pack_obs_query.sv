// pack_obs_query.sv — D observe-only. Steal 8-word QueryRecord (magic 0x4E51)
// before pack FIFO so interior 0x01 cannot look like OP_BEGIN (board hop 02000f5a).
// CRC16-CCITT-FALSE + sticky pack-stream inner QueryRecord CRC. TX 03|qs|qr|51.
// Not FE256. PROGRAM=NO. Not PACK_ABI_24_24_PASS.
`timescale 1ns/1ps

module pack_obs_query (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        w_valid,
  input  logic [31:0] w_data,
  input  logic        dump_take,
  input  logic        clr_take,
  input  logic        debug_clear,
  input  logic        pack_fire,
  input  logic [31:0] pack_word,
  input  logic [31:0] active_generation,
  output logic        q_take,
  output logic        tx_valid,
  input  logic        tx_ready,
  output logic [31:0] tx_data
);
  localparam logic [15:0] MAGIC_QUERY = 16'h4E51;
  localparam logic [31:0] UNSET_GEN = 32'hFFFF_FFFF;
  localparam logic [7:0]  ST_DI = 8'h06;
  localparam logic [7:0]  RC_PACK_CRC = 8'h50;
  localparam logic [7:0]  RC_STALE = 8'h54;
  localparam logic [7:0]  RC_BAD = 8'h55;

  function automatic [15:0] crc_feed(input [15:0] c0, input [7:0] b);
    logic [15:0] c;
    integer k;
    begin
      c = c0 ^ {b, 8'h00};
      for (k = 0; k < 8; k = k + 1)
        c = c[15] ? ({c[14:0], 1'b0} ^ 16'h1021) : {c[14:0], 1'b0};
      crc_feed = c;
    end
  endfunction

  function automatic [15:0] crc16_q(input [255:0] p);
    integer ii;
    logic [15:0] c;
    begin
      c = 16'hFFFF;
      for (ii = 0; ii < 30; ii = ii + 1)
        c = crc_feed(c, p[8*ii +: 8]);
      crc16_q = c;
    end
  endfunction

  logic        collecting;
  logic [2:0]  wix;
  logic [255:0] q_pack;
  logic        go;
  logic        dest_fail;
  logic [1:0]  sst;
  logic [5:0]  sn;
  logic [15:0] sc;
  logic [7:0]  got_lo;
  integer      bi;
  logic [7:0]  bb;

  assign q_take = collecting ||
                  (w_valid && !dump_take && !clr_take && (w_data[15:0] == MAGIC_QUERY));

  logic [15:0] magic_e, q_gen_e, got_e, calc_e;
  logic mag_fail_e, crc_fail_e, stale_e;
  logic [7:0] qs_e, qr_e;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      collecting <= 1'b0;
      wix <= 3'h0;
      q_pack <= 256'h0;
      go <= 1'b0;
      tx_valid <= 1'b0;
      tx_data <= 32'h0;
    end else begin
      go <= 1'b0;
      if (tx_valid && tx_ready)
        tx_valid <= 1'b0;
      if (q_take && w_valid && !dump_take && !clr_take) begin
        if (!collecting) begin
          q_pack[31:0] <= w_data;
          wix <= 3'h1;
          collecting <= 1'b1;
        end else begin
          q_pack[32*wix +: 32] <= w_data;
          if (wix == 3'h7) begin
            collecting <= 1'b0;
            wix <= 3'h0;
            go <= 1'b1;
            $display("QGO last=%08h", w_data);
          end else wix <= wix + 3'h1;
        end
      end
      if (go) begin
        magic_e = q_pack[15:0];
        q_gen_e = q_pack[79:64];
        got_e = q_pack[255:240];
        calc_e = crc16_q(q_pack);
        mag_fail_e = (magic_e != MAGIC_QUERY);
        crc_fail_e = (calc_e != got_e);
        stale_e = (active_generation != UNSET_GEN) && (q_gen_e != 16'h0) &&
                  (q_gen_e != active_generation[15:0]);
        if (mag_fail_e || crc_fail_e) begin
          qs_e = ST_DI; qr_e = RC_BAD;
        end else if (stale_e) begin
          qs_e = ST_DI; qr_e = RC_STALE;
        end else if (dest_fail) begin
          qs_e = ST_DI; qr_e = RC_PACK_CRC;
        end else begin
          qs_e = 8'h00; qr_e = 8'h00;
        end
        tx_data <= {8'h03, qs_e, qr_e, 8'h51};
        tx_valid <= 1'b1;
        $display("QTX mag=%04h calc=%04h got=%04h stale=%0d dest=%0d qs=%02h qr=%02h",
                 magic_e, calc_e, got_e, stale_e, dest_fail, qs_e, qr_e);
      end
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      dest_fail <= 1'b0;
      sst <= 2'd0;
      sn <= 6'h0;
      sc <= 16'hFFFF;
      got_lo <= 8'h0;
    end else if (debug_clear) begin
      dest_fail <= 1'b0;
      sst <= 2'd0;
      sn <= 6'h0;
      sc <= 16'hFFFF;
    end else if (pack_fire) begin
      for (bi = 0; bi < 4; bi = bi + 1) begin
        bb = pack_word[8*bi +: 8];
        unique case (sst)
          2'd0: begin
            if (bb == 8'h51) sst = 2'd1;
          end
          2'd1: begin
            if (bb == 8'h4E) begin
              sst = 2'd2;
              sn = 6'd2;
              sc = crc_feed(crc_feed(16'hFFFF, 8'h51), 8'h4E);
            end else if (bb != 8'h51) sst = 2'd0;
          end
          2'd2: begin
            if (sn < 6'd30) begin
              sc = crc_feed(sc, bb);
              sn = sn + 6'd1;
            end else if (sn == 6'd30) begin
              got_lo = bb;
              sn = 6'd31;
            end else begin
              if ({bb, got_lo} != sc) dest_fail = 1'b1;
              sst = 2'd0;
              sn = 6'h0;
              sc = 16'hFFFF;
            end
          end
          default: sst = 2'd0;
        endcase
      end
    end
  end
endmodule
