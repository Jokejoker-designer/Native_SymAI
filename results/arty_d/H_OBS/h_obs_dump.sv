// H_OBS dump. Magic "OBS1" on the wire (LE). H_OBS != identity H.
// Auto-go after pack status. Optional DUMP cmd 0x504D5544.
// Not BOARD_PASS / PACK_ABI_24_24_PASS. Does not explain identity H.
`timescale 1ns/1ps

module h_obs_dump (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        go,
  input  logic        in_valid,
  input  logic [31:0] in_data,
  output logic        take,
  output logic        out_valid,
  input  logic        out_ready,
  output logic [31:0] out_data,
  input  logic        have_pack_word,
  input  logic        cap_fresh,
  input  logic        drop_seen,
  input  logic [1:0]  bix_at_arm,
  input  logic [1:0]  bix_at_first_pack,
  input  logic [1:0]  bix_gap,
  input  logic [3:0]  n_bytes,
  input  logic [7:0]  sh0,
  input  logic [7:0]  sh1,
  input  logic [7:0]  sh2,
  input  logic [7:0]  sh3,
  input  logic [31:0] first_pack_word
);
  localparam logic [31:0] CMD   = 32'h504D5544;
  localparam logic [31:0] MAGIC = 32'h3153424F; // wire LE "OBS1"
  typedef enum logic [2:0] { S_IDLE, S0, S1, S2, S3 } st_t;
  st_t st;

  assign take = (st == S_IDLE) && in_valid && (in_data == CMD);
  // W1: [1:0] arm [3:2] first_pack_bix [5:4] gap [13:6] sh0 [17:14] n_bytes
  //     [18] have [19] fresh [20] drop

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
        out_data = {11'h0, drop_seen, cap_fresh, have_pack_word, n_bytes,
                    sh0, bix_gap, bix_at_first_pack, bix_at_arm};
      end
      S2: begin
        out_valid = 1'b1;
        out_data = {sh3, sh2, sh1, sh0};
      end
      S3: begin
        out_valid = 1'b1;
        out_data = first_pack_word;
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
