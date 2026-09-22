// command_effect_hold_r1.sv
// One issued command can be observed twice. The command id does not change.
// With no latched command, the table is not read and the code is FB_NO_BINDING.
// Does not edit primitive_executor_r1.sv. The table is a substitute, not a sensor.
`timescale 1ns/1ps

module command_effect_hold_r1 (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        product_done,
  input  logic        command_valid,
  input  logic [2:0]  command_primitive,
  input  logic [31:0] command_id,
  input  logic [23:0] effect_table,
  input  logic        sense_req,
  output logic        effect_valid,
  output logic [2:0]  effect_result,
  output logic [31:0] effect_command_id
);
  import skill_option_pkg_r1::*;
  logic        seen;
  logic        held_valid;
  logic [2:0]  held_prim;
  logic [31:0] held_id;

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      seen <= 1'b0;
      held_valid <= 1'b0;
      held_prim <= 3'd0;
      held_id <= 32'h0;
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
      if (sense_req) begin
        effect_valid <= 1'b1;
        if (seen && held_valid) begin
          effect_command_id <= held_id;
          effect_result <= effect_table[held_prim * 3 +: 3];
        end else begin
          effect_command_id <= 32'h0;
          effect_result <= FB_NO_BINDING;
        end
      end
    end
  end
endmodule
