// bounded_walk.sv — M3 CANDIDATE: hop-budget first-neighbor walk. PROGRAM=NO.
// incomplete is a walker observable, not an ASTRA status.
`timescale 1ns/1ps

module bounded_walk #(
  parameter int N_DIR = 235,
  parameter int N_POST = 2048
) (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        req_valid,
  output logic        req_ready,
  input  logic [31:0] start_id,
  input  logic [3:0]  hop_budget,
  input  logic        want_rev,
  input  logic [31:0] active_id_max,
  output logic        rsp_valid,
  input  logic        rsp_ready,
  output logic        hit,
  output logic        out_of_profile,
  output logic        incomplete,
  output logic [3:0]  hops_taken,
  output logic [31:0] end_id,
  output logic [15:0] last_count
);
  logic w_req, w_rdy, w_rsp, w_hit, w_oop, w_mism;
  logic [15:0] w_cnt, cnt_r;
  logic [31:0] nb, eref, cur;
  logic [3:0] budget, taken;
  logic rev_r, oop, miss, more;
  typedef enum logic [2:0] { S_IDLE, S_ISSUE, S_WAIT, S_RSP } state_t;
  state_t state;

  posting_walk #(.N_DIR(N_DIR), .N_POST(N_POST)) walk (
    .clk, .rst_n,
    .req_valid(w_req), .req_ready(w_rdy), .semantic_id(cur),
    .want_rev(rev_r), .active_id_max(active_id_max),
    .rsp_valid(w_rsp), .rsp_ready(1'b1),
    .hit(w_hit), .out_of_profile(w_oop), .hdr_mismatch(w_mism),
    .count(w_cnt), .first_neighbor(nb), .first_edge_ref(eref)
  );

  assign req_ready = (state == S_IDLE);
  assign rsp_valid = (state == S_RSP);
  assign hit = !miss && !oop;
  assign out_of_profile = oop;
  assign incomplete = more;
  assign hops_taken = taken;
  assign end_id = cur;
  assign last_count = cnt_r;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= S_IDLE;
      w_req <= 1'b0;
      taken <= 4'h0;
      oop <= 1'b0;
      miss <= 1'b0;
      more <= 1'b0;
    end else begin
      case (state)
        S_IDLE: begin
          w_req <= 1'b0;
          if (req_valid) begin
            cur <= start_id;
            budget <= hop_budget;
            rev_r <= want_rev;
            taken <= 4'h0;
            oop <= 1'b0;
            miss <= 1'b0;
            more <= 1'b0;
            cnt_r <= 16'h0;
            if (hop_budget == 4'h0) state <= S_RSP;
            else begin
              w_req <= 1'b1;
              state <= S_ISSUE;
            end
          end
        end
        S_ISSUE: begin
          if (w_rdy) begin
            w_req <= 1'b0;
            state <= S_WAIT;
          end
        end
        S_WAIT: begin
          if (w_rsp) begin
            oop <= w_oop;
            cnt_r <= w_cnt;
            if (w_oop || !w_hit || w_mism) begin
              miss <= 1'b1;
              more <= 1'b0;
              state <= S_RSP;
            end else if (w_cnt == 16'h0) begin
              more <= 1'b0;
              state <= S_RSP;
            end else begin
              cur <= nb;
              taken <= taken + 4'h1;
              more <= ((taken + 4'h1) >= budget) && (w_cnt > 16'h0);
              if ((taken + 4'h1) >= budget) state <= S_RSP;
              else begin
                w_req <= 1'b1;
                state <= S_ISSUE;
              end
            end
          end
        end
        S_RSP: if (rsp_ready) state <= S_IDLE;
        default: state <= S_IDLE;
      endcase
    end
  end
endmodule
