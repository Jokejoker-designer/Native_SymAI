// pack_edge_dut.sv — Pack dest SoT + dest-backed posting/EdgeRecord query.
// AGENT_D XSim DUT. Does not modify pack_loader / FE256 / C RTL / gold.py.
// PROGRAM=NO. Not RUNTIME_KNOWLEDGE_BINDING_8_8_PASS. Not PACK_ABI_24_24_PASS.
`timescale 1ns/1ps

module pack_edge_dut (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        s_valid,
  output logic        s_ready,
  input  logic [31:0] s_data,
  output logic        load_ack,
  output logic        load_reject,
  output logic [7:0]  reason_code,
  output logic [31:0] active_generation,
  output logic        pack_quiescent,
  input  logic        q_valid,
  output logic        q_ready,
  input  logic [7:0]  q_bytes [0:31],
  output logic        r_valid,
  input  logic        r_ready,
  output logic        hit,
  output logic [31:0] first_neighbor,
  output logic        dest_rd_pulse,
  output logic        t1_valid,
  input  logic        t1_flush,
  output logic        root_valid,
  output logic [27:0] published_root
);
  localparam logic [31:0] UNSET_GEN = 32'hFFFF_FFFF;

  logic        ui_busy, d_rd_end, calib_done;
  logic [15:0] wr_outstanding;
  logic [27:0] p_addr, w_addr, d_addr;
  logic [2:0]  p_cmd, w_cmd, d_cmd;
  logic        p_en, w_en, d_en, p_wdf_end, w_wdf_end, d_wdf_end;
  logic        p_wdf_wren, w_wdf_wren, d_wdf_wren;
  logic [127:0] p_wdf, w_wdf, d_wdf, d_rd;
  logic [15:0] p_mask, w_mask, d_mask;
  logic        d_rd_v, d_rdy, d_wdf_rdy;
  logic        walk_busy, lookup_done, walk_hit;
  logic [31:0] walk_nb;
  logic [27:0] pub_root;
  logic        wr_beat_v;
  logic [27:0] wr_beat;
  logic        lookup_go;
  logic [31:0] lookup_sid;

  pack_mig_bind u_ld (
    .clk, .rst_n, .debug_clear(1'b0), .calib_done,
    .s_valid, .s_ready, .s_data,
    .load_ack, .load_reject, .reason_code, .active_generation, .wr_outstanding,
    .force_fifo_empty(1'b0), .ui_busy, .pack_quiescent,
    .app_addr(p_addr), .app_cmd(p_cmd), .app_en(p_en), .app_wdf_data(p_wdf),
    .app_wdf_end(p_wdf_end), .app_wdf_mask(p_mask), .app_wdf_wren(p_wdf_wren),
    .app_rd_data(d_rd), .app_rd_data_valid(d_rd_v && !walk_busy),
    .app_rdy(d_rdy && !walk_busy), .app_wdf_rdy(d_wdf_rdy && !walk_busy)
  );

  dest_root_cache u_cache (
    .clk, .rst_n, .load_ack, .pack_quiescent,
    .wr_beat_addr(wr_beat), .wr_beat_valid(wr_beat_v),
    .lookup_go(1'b0), .lookup_sid(32'h0),
    .t1_flush, .t1_rebuild(1'b0),
    .busy(), .lookup_done(), .hit(), .neighbor(),
    .t1_valid(), .published_root(pub_root), .root_valid,
    .app_addr(), .app_cmd(), .app_en(),
    .app_wdf_data(), .app_wdf_end(), .app_wdf_mask(),
    .app_wdf_wren(),
    .app_rd_data(128'h0), .app_rd_data_valid(1'b0),
    .app_rdy(1'b0), .app_wdf_rdy(1'b0)
  );

  dest_posting_edge_walk u_walk (
    .clk, .rst_n, .pack_quiescent, .root_valid, .published_root(pub_root),
    .lookup_go, .lookup_sid, .load_ack, .t1_flush, .t1_valid,
    .busy(walk_busy), .lookup_done, .hit(walk_hit), .neighbor(walk_nb),
    .app_addr(w_addr), .app_cmd(w_cmd), .app_en(w_en),
    .app_wdf_data(w_wdf), .app_wdf_end(w_wdf_end), .app_wdf_mask(w_mask),
    .app_wdf_wren(w_wdf_wren),
    .app_rd_data(d_rd), .app_rdy(d_rdy),
    .app_rd_data_valid(d_rd_v && walk_busy)
  );

  assign d_addr = walk_busy ? w_addr : p_addr;
  assign d_cmd  = walk_busy ? w_cmd  : p_cmd;
  assign d_en   = walk_busy ? w_en   : p_en;
  assign d_wdf  = walk_busy ? w_wdf  : p_wdf;
  assign d_wdf_end  = walk_busy ? w_wdf_end  : p_wdf_end;
  assign d_mask     = walk_busy ? w_mask     : p_mask;
  assign d_wdf_wren = walk_busy ? w_wdf_wren : p_wdf_wren;
  assign dest_rd_pulse = walk_busy && w_en && d_rdy && (w_cmd == 3'b001);
  assign published_root = pub_root;

  mig_ui_bram u_dest (
    .clk, .rst_n, .calib_done, .stall(1'b0),
    .app_addr(d_addr), .app_cmd(d_cmd), .app_en(d_en),
    .app_wdf_data(d_wdf), .app_wdf_end(d_wdf_end), .app_wdf_mask(d_mask),
    .app_wdf_wren(d_wdf_wren),
    .app_rd_data(d_rd), .app_rd_data_end(d_rd_end), .app_rd_data_valid(d_rd_v),
    .app_rdy(d_rdy), .app_wdf_rdy(d_wdf_rdy)
  );

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wr_beat <= 28'h0;
      wr_beat_v <= 1'b0;
    end else begin
      wr_beat_v <= 1'b0;
      if (p_wdf_wren && d_wdf_rdy && !walk_busy) begin
        wr_beat <= {p_addr[27:4], 4'b0000};
        wr_beat_v <= 1'b1;
      end
    end
  end

  function automatic [15:0] crc16_step(input [15:0] c, input [7:0] b);
    logic [15:0] x;
    integer kk;
    begin
      x = c ^ {b, 8'h00};
      for (kk = 0; kk < 8; kk++)
        x = x[15] ? {x[14:0], 1'b0} ^ 16'h1021 : {x[14:0], 1'b0};
      crc16_step = x;
    end
  endfunction

  function automatic [15:0] crc16_q(input logic [7:0] b [0:31]);
    logic [15:0] c;
    integer ii;
    begin
      c = 16'hFFFF;
      for (ii = 0; ii < 30; ii++)
        c = crc16_step(c, b[ii]);
      crc16_q = c;
    end
  endfunction

  typedef enum logic [1:0] { Q_IDLE, Q_ISSUE, Q_WALK, Q_RSP } qst_t;
  qst_t qst;
  logic [7:0] qb [0:31];
  logic found;
  logic [31:0] nb0;

  assign q_ready = (qst == Q_IDLE);
  assign r_valid = (qst == Q_RSP);
  assign hit = found;
  assign first_neighbor = nb0;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      qst <= Q_IDLE;
      lookup_go <= 1'b0;
      lookup_sid <= 32'h0;
      found <= 1'b0;
      nb0 <= 32'h0;
    end else begin
      unique case (qst)
        Q_IDLE: begin
          lookup_go <= 1'b0;
          if (q_valid) begin
            qb <= q_bytes;
            qst <= Q_ISSUE;
          end
        end
        Q_ISSUE: begin
          if (({qb[1], qb[0]} != 16'h4E51) || (qb[2] != 8'h01) ||
              (crc16_q(qb) != {qb[31], qb[30]})) begin
            found <= 1'b0;
            nb0 <= 32'h0;
            lookup_go <= 1'b0;
            qst <= Q_RSP;
          end else if ((active_generation == UNSET_GEN) || !root_valid) begin
            found <= 1'b0;
            nb0 <= 32'h0;
            lookup_go <= 1'b0;
            qst <= Q_RSP;
          end else begin
            lookup_sid <= {qb[17], qb[16], qb[15], qb[14]};
            lookup_go <= 1'b1;
            qst <= Q_WALK;
          end
        end
        Q_WALK: begin
          if (walk_busy)
            lookup_go <= 1'b0;
          if (lookup_done) begin
            found <= walk_hit;
            nb0 <= walk_nb;
            lookup_go <= 1'b0;
            qst <= Q_RSP;
          end
        end
        Q_RSP: begin
          lookup_go <= 1'b0;
          if (r_ready)
            qst <= Q_IDLE;
        end
        default: qst <= Q_IDLE;
      endcase
    end
  end
endmodule
