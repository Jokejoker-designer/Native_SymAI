// posting_walk.sv — M2: ID → directory → posting page. CANDIDATE. PROGRAM=NO.
// PostingEntry.edge_ref is a T2 byte address, not identity.
`timescale 1ns/1ps

module posting_walk #(
  parameter int N_DIR = 235,
  parameter int N_POST = 2048
) (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        req_valid,
  output logic        req_ready,
  input  logic [31:0] semantic_id,
  input  logic        want_rev,
  input  logic [31:0] active_id_max,
  output logic        rsp_valid,
  input  logic        rsp_ready,
  output logic        hit,
  output logic        out_of_profile,
  output logic        hdr_mismatch,
  output logic [15:0] count,
  output logic [31:0] first_neighbor,
  output logic [31:0] first_edge_ref
);
  (* ram_style = "block" *) logic [127:0] post [0:N_POST-1];
  initial $readmemh("post_a.mem", post);

  logic d_req, d_rdy, d_rsp, d_hit, d_oop;
  logic [31:0] fwd_ptr, rev_ptr, sid;
  logic [15:0] dgen;
  logic [7:0] dkind, dfl;

  exact_directory #(.N_DIR(N_DIR)) dir (
    .clk, .rst_n,
    .req_valid(d_req), .req_ready(d_rdy), .semantic_id(sid),
    .active_id_max(active_id_max),
    .rsp_valid(d_rsp), .rsp_ready(1'b1),
    .hit(d_hit), .out_of_profile(d_oop),
    .fwd_ptr, .rev_ptr, .generation(dgen), .kind(dkind), .flags(dfl)
  );

  typedef enum logic [2:0] { S_IDLE, S_DIR, S_HDR, S_ENT, S_RSP } state_t;
  state_t state;
  logic rev_r, found, oop, mism;
  logic [15:0] cnt;
  logic [31:0] nb0, eref0, page_ptr;
  logic [11:0] widx;

  assign req_ready = (state == S_IDLE);
  assign rsp_valid = (state == S_RSP);
  assign hit = found;
  assign out_of_profile = oop;
  assign hdr_mismatch = mism;
  assign count = cnt;
  assign first_neighbor = nb0;
  assign first_edge_ref = eref0;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= S_IDLE;
      d_req <= 1'b0;
      found <= 1'b0;
      oop <= 1'b0;
      mism <= 1'b0;
      cnt <= 16'h0;
      nb0 <= 32'h0;
      eref0 <= 32'h0;
    end else begin
      case (state)
        S_IDLE: begin
          d_req <= 1'b0;
          if (req_valid) begin
            sid <= semantic_id;
            rev_r <= want_rev;
            found <= 1'b0;
            oop <= 1'b0;
            mism <= 1'b0;
            cnt <= 16'h0;
            nb0 <= 32'h0;
            eref0 <= 32'h0;
            d_req <= 1'b1;
            state <= S_DIR;
          end
        end
        S_DIR: begin
          if (d_rdy) d_req <= 1'b0;
          if (d_rsp) begin
            oop <= d_oop;
            if (!d_hit) begin
              found <= 1'b0;
              state <= S_RSP;
            end else begin
              page_ptr <= rev_r ? rev_ptr : fwd_ptr;
              if ((rev_r ? rev_ptr : fwd_ptr) == 32'h0) begin
                found <= 1'b1;
                cnt <= 16'h0;
                state <= S_RSP;
              end else begin
                widx <= rev_r ? rev_ptr[15:4] : fwd_ptr[15:4];
                state <= S_HDR;
              end
            end
          end
        end
        S_HDR: begin
          if (post[widx][31:0] != sid) begin
            mism <= 1'b1;
            found <= 1'b0;
            state <= S_RSP;
          end else begin
            cnt <= post[widx][79:64];
            found <= 1'b1;
            if (post[widx][79:64] == 16'h0) state <= S_RSP;
            else begin
              widx <= widx + 12'h1;
              state <= S_ENT;
            end
          end
        end
        S_ENT: begin
          eref0 <= post[widx][31:0];
          nb0 <= post[widx][63:32];
          state <= S_RSP;
        end
        S_RSP: if (rsp_ready) state <= S_IDLE;
        default: state <= S_IDLE;
      endcase
    end
  end
endmodule
