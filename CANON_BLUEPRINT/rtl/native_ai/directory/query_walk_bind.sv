// query_walk_bind.sv — common-runtime QueryRecord → bounded_walk.
// AGENT_D CANDIDATE. Not FE256 engine. Not M3_PASS. PROGRAM=NO. XSim != board.
// hop_budget = query_meta[8:5]; want_rev = query_meta[10] (CANDIDATE packs).
`timescale 1ns/1ps

module query_walk_bind #(
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
  output logic        incomplete,
  output logic        crc_fail,
  output logic        magic_fail,
  output logic [3:0] hops_taken,
  output logic [31:0] end_id,
  output logic [15:0] last_count
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

  logic        w_req, w_rdy, w_rsp, w_hit, w_oop, w_inc, w_rev;
  logic [3:0]  w_hops, hops_i;
  logic [31:0] sid, w_end;
  logic [15:0] w_cnt;

  bounded_walk #(.N_DIR(N_DIR), .N_POST(N_POST)) u_walk (
    .clk, .rst_n,
    .req_valid(w_req), .req_ready(w_rdy),
    .start_id(sid), .hop_budget(hops_i), .want_rev(w_rev),
    .active_id_max(active_id_max),
    .rsp_valid(w_rsp), .rsp_ready(1'b1),
    .hit(w_hit), .out_of_profile(w_oop), .incomplete(w_inc),
    .hops_taken(w_hops), .end_id(w_end), .last_count(w_cnt)
  );

  typedef enum logic [1:0] { S_IDLE, S_ISSUE, S_WALK, S_RSP } state_t;
  state_t state;
  logic [7:0] qb [0:31];
  logic found, oop, more, cf, mf;
  logic [3:0] hops_r;
  logic [31:0] end_r;
  logic [15:0] cnt_r;

  assign q_ready = (state == S_IDLE);
  assign r_valid = (state == S_RSP);
  assign hit = found;
  assign out_of_profile = oop;
  assign incomplete = more;
  assign crc_fail = cf;
  assign magic_fail = mf;
  assign hops_taken = hops_r;
  assign end_id = end_r;
  assign last_count = cnt_r;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= S_IDLE;
      w_req <= 1'b0;
      w_rev <= 1'b0;
      hops_i <= 4'h0;
      sid <= 32'h0;
      found <= 1'b0;
      oop <= 1'b0;
      more <= 1'b0;
      cf <= 1'b0;
      mf <= 1'b0;
      hops_r <= 4'h0;
      end_r <= 32'h0;
      cnt_r <= 16'h0;
    end else begin
      case (state)
        S_IDLE: begin
          w_req <= 1'b0;
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
            more <= 1'b0;
            hops_r <= 4'h0;
            end_r <= 32'h0;
            cnt_r <= 16'h0;
            w_req <= 1'b0;
            state <= S_RSP;
          end else begin
            sid <= {qb[17], qb[16], qb[15], qb[14]};
            w_rev <= qb[13][2];
            hops_i <= {qb[13][0], qb[12][7:5]};
            w_req <= 1'b1;
            state <= S_WALK;
          end
        end
        S_WALK: begin
          if (w_rdy) w_req <= 1'b0;
          if (w_rsp) begin
            found <= w_hit;
            oop <= w_oop;
            more <= w_inc;
            hops_r <= w_hops;
            end_r <= w_end;
            cnt_r <= w_cnt;
            state <= S_RSP;
          end
        end
        S_RSP: begin
          w_req <= 1'b0;
          if (r_ready) state <= S_IDLE;
        end
        default: state <= S_IDLE;
      endcase
    end
  end
endmodule
