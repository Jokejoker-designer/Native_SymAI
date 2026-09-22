// command_plant_r1.sv
// The effect is the plant state after the latched command acts.
// state starts at 0. Each act does state <= state + primitive.
// No effect-code input. The testbench cannot write the result.
// With no latched command the state does not move and the code is FB_NO_BINDING.
// This plant is a substitute. It is not a pin.
`timescale 1ns/1ps

module command_plant_r1 (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        product_done,
  input  logic        command_valid,
  input  logic [2:0]  command_primitive,
  input  logic [31:0] command_id,
  input  logic        exec_req,
  output logic        effect_valid,
  output logic [2:0]  effect_result,
  output logic [31:0] effect_command_id,
  output logic [2:0]  plant_state
);
  import skill_option_pkg_r1::*;
  logic        seen;
  logic        held_valid;
  logic [2:0]  held_prim;
  logic [31:0] held_id;
  logic [2:0]  state;

  assign plant_state = state;

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      seen <= 1'b0;
      held_valid <= 1'b0;
      held_prim <= 3'd0;
      held_id <= 32'h0;
      state <= 3'd0;
      effect_valid <= 1'b0;
      effect_result <= FB_NO_BINDING;
      effect_command_id <= 32'h0;
    end else begin
      effect_valid <= 1'b0;
      if (product_done && command_valid) begin
        seen <= 1'b1;
        held_valid <= 1'b1;
        held_prim <= command_primitive;
        held_id <= command_id;
      end
      if (exec_req) begin
        effect_valid <= 1'b1;
        if (seen && held_valid) begin
          effect_command_id <= held_id;
          effect_result <= state + held_prim;
          state <= state + held_prim;
        end else begin
          effect_command_id <= 32'h0;
          effect_result <= FB_NO_BINDING;
        end
      end
    end
  end
endmodule
