// runtime_profile.sv — D wires loaded board/pack profile. CANDIDATE. PROGRAM=NO.
// SEMANTIC_ID_WIDTH=32. ACTIVE_ID_RANGE and K_HARD are loadable, not baked 24-bit identity.
// ASTRA status is not emitted here.
`timescale 1ns/1ps

module runtime_profile (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        wr_valid,
  input  logic [31:0] wr_active_id_max,
  input  logic [7:0]  wr_k_hard,
  output logic [31:0] active_id_max,
  output logic [7:0]  k_hard
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      active_id_max <= 32'hFFFF_FFFF;
      k_hard <= 8'd8;
    end else if (wr_valid) begin
      active_id_max <= wr_active_id_max;
      k_hard <= wr_k_hard;
    end
  end

  function automatic logic in_active_range(input logic [31:0] id);
    in_active_range = (id <= active_id_max);
  endfunction
endmodule
