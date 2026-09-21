// ct1_lookup_cdc.sv — clk100 QueryRecord SID → ui_clk dest_root_cache lookup.
// Handshake only. No host T1 poke. PROGRAM=NO. Not CT1_BOARD_PASS.
`timescale 1ns/1ps

module ct1_lookup_cdc (
  input  logic        clk100,
  input  logic        rst100_n,
  input  logic        req100,
  input  logic [31:0] sid100,
  output logic        busy100,
  output logic        done100,
  output logic        hit100,
  output logic [31:0] nb100,
  input  logic        clk_ui,
  input  logic        rst_ui_n,
  output logic        lookup_go,
  output logic [31:0] lookup_sid,
  input  logic        lookup_done,
  input  logic        hit_ui,
  input  logic [31:0] nb_ui,
  input  logic        cache_busy
);
  logic req_tog, ack_tog, pend_go, go_r;
  (* ASYNC_REG = "TRUE" *) logic req_u0, req_u1, req_u2;
  (* ASYNC_REG = "TRUE" *) logic ack_c0, ack_c1, ack_c2;
  logic [31:0] sid_hold, nb_lat, nb_hold;
  logic        hit_lat, hit_hold, done_r;

  assign busy100 = (req_tog != ack_c2);
  assign done100 = done_r;
  assign hit100 = hit_hold;
  assign nb100 = nb_hold;
  assign lookup_go = go_r;
  assign lookup_sid = sid_hold;

  always_ff @(posedge clk100 or negedge rst100_n) begin
    if (!rst100_n) begin
      req_tog <= 1'b0;
      sid_hold <= 32'h0;
      ack_c0 <= 1'b0;
      ack_c1 <= 1'b0;
      ack_c2 <= 1'b0;
      hit_hold <= 1'b0;
      nb_hold <= 32'h0;
      done_r <= 1'b0;
    end else begin
      ack_c0 <= ack_tog;
      ack_c1 <= ack_c0;
      ack_c2 <= ack_c1;
      done_r <= 1'b0;
      if (req100 && (req_tog == ack_c2)) begin
        req_tog <= ~req_tog;
        sid_hold <= sid100;
      end
      if (ack_c1 != ack_c2) begin
        hit_hold <= hit_lat;
        nb_hold <= nb_lat;
        done_r <= 1'b1;
      end
    end
  end

  always_ff @(posedge clk_ui or negedge rst_ui_n) begin
    if (!rst_ui_n) begin
      req_u0 <= 1'b0;
      req_u1 <= 1'b0;
      req_u2 <= 1'b0;
      ack_tog <= 1'b0;
      pend_go <= 1'b0;
      go_r <= 1'b0;
      hit_lat <= 1'b0;
      nb_lat <= 32'h0;
    end else begin
      req_u0 <= req_tog;
      req_u1 <= req_u0;
      req_u2 <= req_u1;
      go_r <= 1'b0;
      if ((req_u1 != req_u2) && (ack_tog == req_u2))
        pend_go <= 1'b1;
      if (pend_go && !cache_busy)
        go_r <= 1'b1;
      if (cache_busy)
        go_r <= 1'b0;
      if (lookup_done && pend_go) begin
        hit_lat <= hit_ui;
        nb_lat <= nb_ui;
        ack_tog <= req_u1;
        pend_go <= 1'b0;
        go_r <= 1'b0;
      end
    end
  end
endmodule
