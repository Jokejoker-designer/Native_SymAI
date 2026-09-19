// UART_R2_U27 pack_clear_ui overlay. Do not patch PACKAGE live or frozen U25/U26.
// U25 FAIL_BOARD: 3 GOLD then r2 V-04 n=0 after ACK. U26 loader-only reset failed earlier (r1 n=0).
// U27: when pack_quiescent, ACK without debug_clear so loader+ui32+mig0 UI stay live.
// BUSY nack still if !pack_quiescent. Dest payload still not cleared. CANDIDATE.
// Not MIG_PASS / BOARD_PASS / PACK_ABI_24_24_PASS.
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
  typedef enum logic [1:0] { S_IDLE, S_ACK, S_NACK } st_t;
  st_t st;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st <= S_IDLE;
      ack <= 1'b0;
      nack <= 1'b0;
      debug_clear <= 1'b0;
    end else begin
      unique case (st)
        S_IDLE: begin
          ack <= 1'b0;
          nack <= 1'b0;
          debug_clear <= 1'b0;
          if (req) begin
            if (!pack_quiescent) begin
              nack <= 1'b1;
              st <= S_NACK;
            end else begin
              ack <= 1'b1;
              st <= S_ACK;
            end
          end
        end
        S_ACK: begin
          ack <= 1'b1;
          debug_clear <= 1'b0;
          if (!req) begin
            ack <= 1'b0;
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
