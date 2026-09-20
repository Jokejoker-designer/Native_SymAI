// pack_query_eval.sv — D observe-only. QueryRecord vs Pack active_generation
// and dest inner QueryRecord CRC. Not FE256 engine. Not ASTRA_PASS.
// Does not invent TSV query_*. CRC is a function sampled on q_go (not always_comb).
// PROGRAM=NO. Not PACK_ABI_24_24_PASS.
`timescale 1ns/1ps

module pack_query_eval (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        q_go,
  input  logic [255:0] q_pack,
  input  logic [31:0] active_generation,
  input  logic        dest_inner_crc_fail,
  output logic        done,
  output logic        query_valid,
  output logic [7:0]  query_status,
  output logic [7:0]  query_reason
);
  localparam logic [15:0] MAGIC_QUERY = 16'h4E51;
  localparam logic [31:0] UNSET_GEN = 32'hFFFF_FFFF;
  localparam logic [7:0]  ST_DATA_INTEGRITY_FAIL = 8'h06;
  localparam logic [7:0]  RC_PACK_CRC = 8'h50;
  localparam logic [7:0]  RC_STALE_GENERATION = 8'h54;
  localparam logic [7:0]  RC_INVALID_DESCRIPTOR = 8'h55;

  function automatic [15:0] crc16_ccitt_false(input [255:0] p);
    integer ii, kk;
    logic [7:0] bb;
    logic [15:0] cx;
    begin
      cx = 16'hFFFF;
      for (ii = 0; ii < 30; ii = ii + 1) begin
        bb = p[8 * ii +: 8];
        cx = cx ^ {bb, 8'h00};
        for (kk = 0; kk < 8; kk = kk + 1)
          cx = cx[15] ? ({cx[14:0], 1'b0} ^ 16'h1021) : {cx[14:0], 1'b0};
      end
      crc16_ccitt_false = cx;
    end
  endfunction

  logic [15:0] crc_s;
  logic        mag_s, crc_s_fail, stale_s;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      done <= 1'b0;
      query_valid <= 1'b0;
      query_status <= 8'h00;
      query_reason <= 8'h00;
      crc_s <= 16'h0;
      mag_s <= 1'b0;
      crc_s_fail <= 1'b0;
      stale_s <= 1'b0;
    end else if (q_go) begin
      crc_s <= crc16_ccitt_false(q_pack);
      mag_s <= (q_pack[15:0] != MAGIC_QUERY);
      crc_s_fail <= (crc16_ccitt_false(q_pack) != q_pack[255:240]);
      stale_s <= (active_generation != UNSET_GEN) && (q_pack[79:64] != 16'h0) &&
                 (q_pack[79:64] != active_generation[15:0]);
      done <= 1'b1;
      if ((q_pack[15:0] != MAGIC_QUERY) ||
          (crc16_ccitt_false(q_pack) != q_pack[255:240])) begin
        query_valid <= 1'b1;
        query_status <= ST_DATA_INTEGRITY_FAIL;
        query_reason <= RC_INVALID_DESCRIPTOR;
      end else if ((active_generation != UNSET_GEN) && (q_pack[79:64] != 16'h0) &&
                   (q_pack[79:64] != active_generation[15:0])) begin
        query_valid <= 1'b1;
        query_status <= ST_DATA_INTEGRITY_FAIL;
        query_reason <= RC_STALE_GENERATION;
      end else if (dest_inner_crc_fail) begin
        query_valid <= 1'b1;
        query_status <= ST_DATA_INTEGRITY_FAIL;
        query_reason <= RC_PACK_CRC;
      end else begin
        query_valid <= 1'b0;
        query_status <= 8'h00;
        query_reason <= 8'h00;
      end
    end
  end
endmodule
