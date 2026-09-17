// H-ILA-A dump: consume DUMP 0x504D5544, emit 4 LE words. Observe path only.
`timescale 1ns/1ps

module h_ila_a_dump (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        go,
  input  logic        in_valid,
  input  logic [31:0] in_data,
  output logic        take,
  output logic        out_valid,
  input  logic        out_ready,
  output logic [31:0] out_data,
  input  logic        captured,
  input  logic [7:0]  sh0,
  input  logic [7:0]  sh1,
  input  logic [7:0]  sh2,
  input  logic [7:0]  sh3,
  input  logic [3:0]  n_bytes,
  input  logic [1:0]  bix_at_arm,
  input  logic [9:0]  wire10,
  input  logic        false_start,
  input  logic        have_word,
  input  logic [31:0] first_word,
  input  logic        wv_at_sh0,
  input  logic        fifo_wr_at_sh0
);
  localparam logic [31:0] CMD = 32'h504D5544;
  localparam logic [31:0] MAGIC = 32'h31414C48;
  typedef enum logic [2:0] { S_IDLE, S0, S1, S2, S3 } st_t;
  st_t st;
  logic [5:0] flags;

  assign take = (st == S_IDLE) && in_valid && (in_data == CMD);
  assign flags = {fifo_wr_at_sh0, wv_at_sh0, have_word, wire10[9], false_start, captured};

  always_comb begin
    out_valid = 1'b0;
    out_data = 32'h0;
    unique case (st)
      S0: begin
        out_valid = 1'b1;
        out_data = MAGIC;
      end
      S1: begin
        out_valid = 1'b1;
        out_data = {2'b0, wire10, flags, sh0, bix_at_arm, n_bytes};
      end
      S2: begin
        out_valid = 1'b1;
        out_data = {sh3, sh2, sh1, sh0};
      end
      S3: begin
        out_valid = 1'b1;
        out_data = first_word;
      end
      default: begin
        out_valid = 1'b0;
        out_data = 32'h0;
      end
    endcase
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      st <= S_IDLE;
    else unique case (st)
      S_IDLE: if (take || go) st <= S0;
      S0: if (out_ready) st <= S1;
      S1: if (out_ready) st <= S2;
      S2: if (out_ready) st <= S3;
      S3: if (out_ready) st <= S_IDLE;
      default: st <= S_IDLE;
    endcase
  end
endmodule
