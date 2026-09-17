// pack_clear_ui.sv — UI-domain validation clear slave. 4-phase req/ack/nack.
// VALIDATION_CLEAR != GLOBAL_RESET / MIG_RESET. Does not reset generated mig0.
// Destructive debug_clear only when pack_quiescent. Else nack (CLEAR_BUSY).
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

  typedef enum logic [1:0] { S_IDLE, S_CLR, S_ACK, S_NACK } st_t;
  st_t st;
  logic [2:0] cnt;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st <= S_IDLE;
      cnt <= 3'h0;
      ack <= 1'b0;
      nack <= 1'b0;
      debug_clear <= 1'b0;
    end else begin
      unique case (st)
        S_IDLE: begin
          ack <= 1'b0;
          nack <= 1'b0;
          debug_clear <= 1'b0;
          cnt <= 3'h0;
          if (req) begin
            if (!pack_quiescent) begin
              nack <= 1'b1;
              st <= S_NACK;
            end else begin
              debug_clear <= 1'b1;
              st <= S_CLR;
            end
          end
        end
        S_CLR: begin
          // Hold debug_clear until 100-side drops req so RX CDC A+B overlap in reset.
          debug_clear <= 1'b1;
          cnt <= cnt + 3'h1;
          if (cnt == CLR_CYC[2:0] - 3'h1) begin
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
