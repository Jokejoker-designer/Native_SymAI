// query_result_bind.sv — QueryRecord → walk → StructuredResult pack.
// AGENT_D CANDIDATE. Not FE256 engine. Not ASTRA_PASS. PROGRAM=NO.
// Pre-search Q-eval: integrity / UNSUPPORTED / DIR_ILLEGAL / budget=0.
// Hop-1 walk still does not establish completeness: never ANSWER/UNKNOWN/CONFLICT.
`timescale 1ns/1ps

module query_result_bind #(
  parameter int N_DIR = 235,
  parameter int N_POST = 2048
) (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        q_valid,
  output logic        q_ready,
  input  logic [7:0]  q_bytes [0:31],
  input  logic        s_valid,
  output logic        s_ready,
  input  logic [31:0] active_id_max,
  output logic        r_valid,
  input  logic        r_ready,
  output logic [7:0]  r_bytes [0:47]
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

  function automatic [15:0] crc16_n46(input logic [7:0] b [0:45]);
    logic [15:0] c;
    integer ii;
    begin
      c = 16'hFFFF;
      for (ii = 0; ii < 46; ii++) c = crc16_step(c, b[ii]);
      crc16_n46 = c;
    end
  endfunction

  logic        w_qv, w_qr, w_rv, w_rr;
  logic        w_hit, w_oop, w_inc, w_cf, w_mf;
  logic [3:0]  w_hops;
  logic [31:0] w_end;
  logic [15:0] w_cnt;
  logic [7:0]  qb [0:31];
  logic [7:0]  ev_st, ev_rc, ev_ak, ev_cm, ev_fl;

  query_walk_bind #(.N_DIR(N_DIR), .N_POST(N_POST)) u_walk (
    .clk, .rst_n,
    .q_valid(w_qv), .q_ready(w_qr), .q_bytes(qb), .active_id_max(active_id_max),
    .r_valid(w_rv), .r_ready(w_rr),
    .hit(w_hit), .out_of_profile(w_oop), .incomplete(w_inc),
    .crc_fail(w_cf), .magic_fail(w_mf),
    .hops_taken(w_hops), .end_id(w_end), .last_count(w_cnt)
  );

  astra_qeval u_eval (
    .q(qb), .crc_fail(w_cf), .magic_fail(w_mf),
    .status(ev_st), .reason(ev_rc), .answer_kind(ev_ak),
    .completeness(ev_cm), .flags(ev_fl)
  );

  typedef enum logic [1:0] { S_IDLE, S_WALK, S_PACK, S_EMIT } state_t;
  state_t state;
  logic [7:0] rb [0:47];
  integer pi;

  assign q_ready = (state == S_IDLE);
  assign s_ready = 1'b1; // no extra stream this slice
  assign r_valid = (state == S_EMIT);
  assign r_bytes = rb;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= S_IDLE;
      w_qv <= 1'b0;
      w_rr <= 1'b0;
      for (pi = 0; pi < 48; pi++) rb[pi] <= 8'h0;
    end else begin
      case (state)
        S_IDLE: begin
          w_qv <= 1'b0;
          w_rr <= 1'b0;
          if (q_valid) begin
            qb <= q_bytes;
            w_qv <= 1'b1;
            state <= S_WALK;
          end
        end
        S_WALK: begin
          if (w_qr) w_qv <= 1'b0;
          if (w_rv) begin
            w_rr <= 1'b1;
            state <= S_PACK;
          end
        end
        S_PACK: begin
          w_rr <= 1'b0;
          begin : pack
            logic [7:0] b [0:45];
            logic [15:0] crc;
            integer i;
            for (i = 0; i < 46; i++) b[i] = 8'h0;
            b[0] = 8'h52;
            b[1] = 8'h4E;
            b[2] = 8'h01;
            b[3] = ev_st;
            b[4] = ev_rc;
            b[5] = ev_ak;
            b[6] = ev_cm;
            b[7] = ev_fl;
            b[8]  = qb[4];
            b[9]  = qb[5];
            b[10] = qb[6];
            b[11] = qb[7];
            b[12] = qb[8];
            b[13] = qb[9];
            b[14] = qb[10];
            b[15] = qb[11];
            b[36] = qb[24];
            b[37] = qb[25];
            b[38] = qb[26];
            b[39] = qb[27];
            crc = crc16_n46(b);
            for (i = 0; i < 46; i++) rb[i] <= b[i];
            rb[46] <= crc[7:0];
            rb[47] <= crc[15:8];
          end
          state <= S_EMIT;
        end
        S_EMIT: begin
          if (r_ready) state <= S_IDLE;
        end
        default: state <= S_IDLE;
      endcase
    end
  end
endmodule
