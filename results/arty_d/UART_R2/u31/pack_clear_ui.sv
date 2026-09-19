// pack_clear_ui.sv — U31 overlay. PACKAGE live not overwritten.
// Drain while still quiescent BEFORE debug_clear. Do not lengthen dest reset after ACK
// (U28 SETTLE CONTRADICTED). VALIDATION_CLEAR != MIG_RESET.
`timescale 1ns/1ps

module pack_clear_ui (
  input  logic clk,
  input  logic rst_n,
  input  logic req,
  input  logic pack_quiescent,
  output logic ack,
  output logic nack,
  output logic debug_clear
);
  localparam int CLR_CYC = 4;
  localparam int DRAIN_N = 64;

  typedef enum logic [2:0] { S_IDLE, S_DRAIN, S_CLR, S_ACK, S_NACK } st_t;
  st_t st;
  logic [7:0] cnt;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st <= S_IDLE;
      cnt <= 8'h0;
      ack <= 1'b0;
      nack <= 1'b0;
      debug_clear <= 1'b0;
    end else begin
      unique case (st)
        S_IDLE: begin
          ack <= 1'b0;
          nack <= 1'b0;
          debug_clear <= 1'b0;
          cnt <= 8'h0;
          if (req) begin
            if (!pack_quiescent) begin
              nack <= 1'b1;
              st <= S_NACK;
            end else
              st <= S_DRAIN;
          end
        end
        S_DRAIN: begin
          debug_clear <= 1'b0;
          if (!req)
            st <= S_IDLE;
          else if (!pack_quiescent) begin
            nack <= 1'b1;
            st <= S_NACK;
          end else begin
            cnt <= cnt + 8'h1;
            if (cnt == DRAIN_N[7:0] - 8'h1) begin
              cnt <= 8'h0;
              debug_clear <= 1'b1;
              st <= S_CLR;
            end
          end
        end
        S_CLR: begin
          debug_clear <= 1'b1;
          cnt <= cnt + 8'h1;
          if (cnt == CLR_CYC[7:0] - 8'h1) begin
            ack <= 1'b1;
            st <= S_ACK;
          end
        end
        S_ACK: begin
          ack <= 1'b1;
          debug_clear <= 1'b1;
          if (!req) begin
            ack <= 1'b0;
            debug_clear <= 1'b0;
            st <= S_IDLE;
          end
        end
        S_NACK: begin
          nack <= 1'b1;
          debug_clear <= 1'b0;
          if (!req) begin
            nack <= 1'b0;
            st <= S_IDLE;
          end
        end
        default: st <= S_IDLE;
      endcase
    end
  end
endmodule
