// pack_obs_ctrl.sv — epoch arm/freeze. Dual-clock handshake. Observe-only.
`timescale 1ns/1ps

module pack_obs_ctrl (
  input  logic        clk100,
  input  logic        ui_clk,
  input  logic        rst100_n,
  input  logic        rst_ui_n,
  input  logic        arm_req_100,
  input  logic        freeze_nak,
  input  logic        freeze_dump,
  input  logic        overflow_any,
  input  logic        rst_abort,
  output logic [15:0] epoch_id,
  output logic        armed_100,
  output logic        armed_ui,
  output logic        arm_pulse_100,
  output logic        arm_pulse_ui,
  output logic        freeze,
  output logic [3:0]  freeze_reason,
  output logic        capture_valid
);
  localparam logic [3:0] FR_NONE = 4'd0;
  localparam logic [3:0] FR_BAD_MAGIC = 4'd1;
  localparam logic [3:0] FR_OTHER_NAK = 4'd2;
  localparam logic [3:0] FR_DUMP = 4'd3;
  localparam logic [3:0] FR_OVERFLOW = 4'd5;
  localparam logic [3:0] FR_RESET = 4'd6;

  logic [15:0] epoch_r;
  logic        arm_hold, freeze_r;
  logic [3:0]  reason_r;
  logic        valid_r;
  (* ASYNC_REG = "TRUE" *) logic a0, a1, u0, u1;
  logic        ack_ui, req_100;

  assign epoch_id = epoch_r;
  assign freeze = freeze_r;
  assign freeze_reason = reason_r;
  assign capture_valid = valid_r && !freeze_r;
  assign armed_100 = a1;
  assign armed_ui = u1;

  always_ff @(posedge clk100 or negedge rst100_n) begin
    if (!rst100_n) begin
      epoch_r <= 16'h1;
      arm_hold <= 1'b0;
      freeze_r <= 1'b0;
      reason_r <= FR_NONE;
      valid_r <= 1'b0;
      req_100 <= 1'b0;
      a0 <= 1'b0;
      a1 <= 1'b0;
      arm_pulse_100 <= 1'b0;
    end else begin
      a0 <= ack_ui;
      a1 <= a0;
      arm_pulse_100 <= 1'b0;
      if (rst_abort) begin
        freeze_r <= 1'b1;
        reason_r <= FR_RESET;
        valid_r <= 1'b0;
        arm_hold <= 1'b0;
        req_100 <= 1'b0;
      end else if (overflow_any) begin
        freeze_r <= 1'b1;
        reason_r <= FR_OVERFLOW;
        valid_r <= 1'b0;
      end else if (freeze_nak && !freeze_r) begin
        freeze_r <= 1'b1;
        reason_r <= FR_BAD_MAGIC;
      end else if (freeze_dump && !freeze_r) begin
        freeze_r <= 1'b1;
        reason_r <= FR_DUMP;
      end else if (arm_req_100 && !arm_hold && !freeze_r) begin
        epoch_r <= epoch_r + 16'd1;
        arm_hold <= 1'b1;
        req_100 <= 1'b1;
        valid_r <= 1'b0;
        arm_pulse_100 <= 1'b1;
      end else if (arm_hold && a1) begin
        arm_hold <= 1'b0;
        req_100 <= 1'b0;
        valid_r <= 1'b1;
        freeze_r <= 1'b0;
        reason_r <= FR_NONE;
      end
    end
  end

  always_ff @(posedge ui_clk or negedge rst_ui_n) begin
    if (!rst_ui_n) begin
      u0 <= 1'b0;
      u1 <= 1'b0;
      ack_ui <= 1'b0;
      arm_pulse_ui <= 1'b0;
    end else begin
      u0 <= req_100;
      u1 <= u0;
      arm_pulse_ui <= (u1 && !ack_ui);
      if (u1)
        ack_ui <= 1'b1;
      else
        ack_ui <= 1'b0;
    end
  end
endmodule
