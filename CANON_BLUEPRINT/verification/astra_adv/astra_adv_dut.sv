// astra_adv_dut.sv — AGENT_B fail-closed Q-eval shell until Agent D binds.
// Not production DUT RTL. PROGRAM=NO. XSim != board.
// q_ready/s_ready stuck 0. Do not import astra_adv_gold.py as the encoder.
// Do not edit pack_loader.sv from this campaign.
`timescale 1ns/1ps

module astra_adv_dut (
  input  wire        clk,
  input  wire        rst_n,
  input  wire        q_valid,
  output wire        q_ready,
  input  wire        s_valid,
  output wire        s_ready,
  input  wire [31:0] q_data,
  output wire        r_valid,
  input  wire        r_ready,
  output wire [31:0] r_data
);
  assign q_ready = 1'b0;
  assign s_ready = 1'b0;
  assign r_valid = 1'b0;
  assign r_data  = 32'h0;
endmodule
