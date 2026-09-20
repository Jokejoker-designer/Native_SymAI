// pack_obs_gen.sv — Pack-owner COMMIT transition. Owner Ý5–6 four-AND.
// Does not drive DUT. PROGRAM=NO. Not PACK_ABI_24_24_PASS.
`timescale 1ns/1ps

module pack_obs_gen (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        capture_valid,
  input  logic [15:0] epoch_id,
  input  logic        debug_clear,
  input  logic        commit_pulse,
  input  logic [31:0] active_generation,
  output logic        commit_event,
  output logic [31:0] generation_before,
  output logic [31:0] generation_after,
  output logic        same_capture_epoch,
  output logic        flip_present,
  output logic        generation_flipped
);
  typedef enum logic [1:0] { G_IDLE, G_WAIT, G_HOLD } gst_e;
  gst_e st;
  logic [31:0] before_r, after_r;
  logic [15:0] ep0, ep1;
  logic        clr_between;
  logic        commit_d;

  wire commit_edge = commit_pulse && !commit_d;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st <= G_IDLE;
      commit_d <= 1'b0;
      commit_event <= 1'b0;
      before_r <= 32'h0;
      after_r <= 32'h0;
      ep0 <= 16'h0;
      ep1 <= 16'h0;
      clr_between <= 1'b0;
      same_capture_epoch <= 1'b0;
      flip_present <= 1'b0;
      generation_flipped <= 1'b0;
    end else begin
      commit_d <= commit_pulse;
      commit_event <= 1'b0;
      unique case (st)
        G_IDLE: begin
          if (commit_edge && capture_valid) begin
            commit_event <= 1'b1;
            before_r <= active_generation;
            ep0 <= epoch_id;
            clr_between <= 1'b0;
            st <= G_WAIT;
          end else if (commit_edge && !capture_valid) begin
            flip_present <= 1'b0;
            generation_flipped <= 1'b0;
          end
        end
        G_WAIT: begin
          if (debug_clear)
            clr_between <= 1'b1;
          after_r <= active_generation;
          ep1 <= epoch_id;
          st <= G_HOLD;
        end
        G_HOLD: begin
          same_capture_epoch <= (ep0 == ep1) && !clr_between;
          if (capture_valid && (ep0 == ep1) && !clr_between) begin
            flip_present <= 1'b1;
            generation_flipped <= (after_r != before_r);
          end else begin
            flip_present <= 1'b0;
            generation_flipped <= 1'b0;
          end
          st <= G_IDLE;
        end
        default: st <= G_IDLE;
      endcase
    end
  end

  assign generation_before = before_r;
  assign generation_after = after_r;
endmodule
