// query_posting_bind.sv — common-runtime QueryRecord → posting_walk.
// AGENT_D CANDIDATE. Not FE256 engine. Not M2_PASS. PROGRAM=NO. XSim != board.
// QueryRecord layout [§04.3] little-endian. CRC16-CCITT-FALSE [§04.12].
`timescale 1ns/1ps

module query_posting_bind #(
  parameter int N_DIR = 235,
  parameter int N_POST = 2048
) (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        q_valid,
  output logic        q_ready,
  input  logic [7:0]  q_bytes [0:31],
  input  logic [31:0] active_id_max,
  output logic        r_valid,
  input  logic        r_ready,
  output logic        hit,
  output logic        out_of_profile,
  output logic        hdr_mismatch,
  output logic        crc_fail,
  output logic        magic_fail,
  output logic [15:0] count,
  output logic [31:0] first_neighbor,
  output logic [31:0] first_edge_ref
);
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
      for (ii = 0; ii < 30; ii++) c = crc16_step(c, b[ii]);
      crc16_q = c;
    end
  endfunction

  logic        p_req, p_rdy, p_rsp, p_hit, p_oop, p_mism, p_rev;
  logic [31:0] sid;
  logic [15:0] p_cnt;
  logic [31:0] p_nb, p_eref;

  posting_walk #(.N_DIR(N_DIR), .N_POST(N_POST)) u_post (
    .clk, .rst_n,
    .req_valid(p_req), .req_ready(p_rdy),
    .semantic_id(sid), .want_rev(p_rev), .active_id_max(active_id_max),
    .rsp_valid(p_rsp), .rsp_ready(1'b1),
    .hit(p_hit), .out_of_profile(p_oop), .hdr_mismatch(p_mism),
    .count(p_cnt), .first_neighbor(p_nb), .first_edge_ref(p_eref)
  );

  typedef enum logic [1:0] { S_IDLE, S_ISSUE, S_WALK, S_RSP } state_t;
  state_t state;
  logic [7:0] qb [0:31];
  logic found, oop, mism, cf, mf;
  logic [15:0] cnt;
  logic [31:0] nb0, eref0;

  assign q_ready = (state == S_IDLE);
  assign r_valid = (state == S_RSP);
  assign hit = found;
  assign out_of_profile = oop;
  assign hdr_mismatch = mism;
  assign crc_fail = cf;
  assign magic_fail = mf;
  assign count = cnt;
  assign first_neighbor = nb0;
  assign first_edge_ref = eref0;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= S_IDLE;
      p_req <= 1'b0;
      p_rev <= 1'b0;
      sid <= 32'h0;
      found <= 1'b0;
      oop <= 1'b0;
      mism <= 1'b0;
      cf <= 1'b0;
      mf <= 1'b0;
      cnt <= 16'h0;
      nb0 <= 32'h0;
      eref0 <= 32'h0;
    end else begin
      case (state)
        S_IDLE: begin
          p_req <= 1'b0;
          if (q_valid) begin
            qb <= q_bytes;
            state <= S_ISSUE;
          end
        end
        S_ISSUE: begin
          mf <= ({qb[1], qb[0]} != 16'h4E51) || (qb[2] != 8'h01);
          cf <= (crc16_q(qb) != {qb[31], qb[30]});
          if (({qb[1], qb[0]} != 16'h4E51) || (qb[2] != 8'h01) ||
              (crc16_q(qb) != {qb[31], qb[30]})) begin
            found <= 1'b0;
            oop <= 1'b0;
            mism <= 1'b0;
            cnt <= 16'h0;
            nb0 <= 32'h0;
            eref0 <= 32'h0;
            p_req <= 1'b0;
            state <= S_RSP;
          end else begin
            sid <= {qb[17], qb[16], qb[15], qb[14]};
            p_rev <= qb[13][2]; // query_meta[10] in {qb[13], qb[12]}
            p_req <= 1'b1;
            state <= S_WALK;
          end
        end
        S_WALK: begin
          if (p_rdy) p_req <= 1'b0;
          if (p_rsp) begin
            found <= p_hit;
            oop <= p_oop;
            mism <= p_mism;
            cnt <= p_cnt;
            nb0 <= p_nb;
            eref0 <= p_eref;
            state <= S_RSP;
          end
        end
        S_RSP: begin
          p_req <= 1'b0;
          if (r_ready) state <= S_IDLE;
        end
        default: state <= S_IDLE;
      endcase
    end
  end
endmodule
