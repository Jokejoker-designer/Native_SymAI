// mig_ui_mux.sv — exclusive native UI grant: pack (A) vs FEM (B).
// CANDIDATE. PROGRAM=NO. Not MIG_PASS / FEM_PERSIST_PASS.
// Pack wins when both request. Grant held while the winner is busy.
`timescale 1ns/1ps

module mig_ui_mux (
  input  logic         clk,
  input  logic         rst_n,

  input  logic         a_busy,
  input  logic [27:0] a_addr,
  input  logic [2:0]  a_cmd,
  input  logic         a_en,
  input  logic [127:0] a_wdf_data,
  input  logic         a_wdf_end,
  input  logic [15:0] a_wdf_mask,
  input  logic         a_wdf_wren,
  output logic [127:0] a_rd_data,
  output logic         a_rd_valid,
  output logic         a_rdy,
  output logic         a_wdf_rdy,

  input  logic         b_busy,
  input  logic [27:0] b_addr,
  input  logic [2:0]  b_cmd,
  input  logic         b_en,
  input  logic [127:0] b_wdf_data,
  input  logic         b_wdf_end,
  input  logic [15:0] b_wdf_mask,
  input  logic         b_wdf_wren,
  output logic [127:0] b_rd_data,
  output logic         b_rd_valid,
  output logic         b_rdy,
  output logic         b_wdf_rdy,

  output logic [27:0] d_addr,
  output logic [2:0]  d_cmd,
  output logic         d_en,
  output logic [127:0] d_wdf_data,
  output logic         d_wdf_end,
  output logic [15:0] d_wdf_mask,
  output logic         d_wdf_wren,
  input  logic [127:0] d_rd_data,
  input  logic         d_rd_valid,
  input  logic         d_rdy,
  input  logic         d_wdf_rdy
);
  typedef enum logic [1:0] { G_NONE = 2'd0, G_A = 2'd1, G_B = 2'd2 } g_t;
  g_t g, g_n;

  logic a_req, b_req;
  assign a_req = a_busy | a_en | a_wdf_wren;
  assign b_req = b_busy | b_en | b_wdf_wren;

  always_comb begin
    g_n = g;
    unique case (g)
      G_NONE: begin
        if (a_req) g_n = G_A;
        else if (b_req) g_n = G_B;
      end
      G_A: begin
        if (!a_req) g_n = b_req ? G_B : G_NONE;
      end
      G_B: begin
        if (!b_req) g_n = a_req ? G_A : G_NONE;
      end
      default: g_n = G_NONE;
    endcase
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) g <= G_NONE;
    else g <= g_n;
  end

  always_comb begin
    d_addr     = 28'h0;
    d_cmd      = 3'b000;
    d_en       = 1'b0;
    d_wdf_data = 128'h0;
    d_wdf_end  = 1'b0;
    d_wdf_mask = 16'hFFFF;
    d_wdf_wren = 1'b0;
    a_rdy      = 1'b0;
    a_wdf_rdy  = 1'b0;
    a_rd_valid = 1'b0;
    a_rd_data  = d_rd_data;
    b_rdy      = 1'b0;
    b_wdf_rdy  = 1'b0;
    b_rd_valid = 1'b0;
    b_rd_data  = d_rd_data;
    unique case (g)
      G_A: begin
        d_addr     = a_addr;
        d_cmd      = a_cmd;
        d_en       = a_en;
        d_wdf_data = a_wdf_data;
        d_wdf_end  = a_wdf_end;
        d_wdf_mask = a_wdf_mask;
        d_wdf_wren = a_wdf_wren;
        a_rdy      = d_rdy;
        a_wdf_rdy  = d_wdf_rdy;
        a_rd_valid = d_rd_valid;
      end
      G_B: begin
        d_addr     = b_addr;
        d_cmd      = b_cmd;
        d_en       = b_en;
        d_wdf_data = b_wdf_data;
        d_wdf_end  = b_wdf_end;
        d_wdf_mask = b_wdf_mask;
        d_wdf_wren = b_wdf_wren;
        b_rdy      = d_rdy;
        b_wdf_rdy  = d_wdf_rdy;
        b_rd_valid = d_rd_valid;
      end
      G_NONE: ;
      default: ;
    endcase
  end
endmodule
