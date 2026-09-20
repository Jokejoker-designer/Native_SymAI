// pack_obs_lane.sv — U33OBS per-hop BRAM. Observe-only. PROGRAM=NO.
// 112-bit TraceEntry. Depth 256. No silent wrap. CLEAR does not wipe.
`timescale 1ns/1ps

module pack_obs_lane #(
  parameter int DEPTH = 256
) (
  input  logic         clk,
  input  logic         rst_n,
  input  logic         arm,
  input  logic         armed,
  input  logic         freeze,
  input  logic         clr_event,
  input  logic [15:0]  epoch_id,
  input  logic         fire,
  input  logic [31:0]  data,
  input  logic [15:0]  flags,
  output logic         overflow,
  output logic [8:0]   n_ev,
  output logic [7:0]   wr_ptr,
  input  logic         rd_en,
  input  logic [7:0]   rd_addr,
  output logic [111:0] rd_data
);
  localparam int AW = $clog2(DEPTH);
  logic [111:0] mem [0:DEPTH-1];
  logic [15:0]  seq_r;
  logic [31:0]  cyc_r;
  logic [AW-1:0] wr;
  integer i;

  wire take = armed && !freeze && !overflow && fire && (n_ev < 9'(DEPTH));

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wr <= '0;
      seq_r <= 16'h0;
      cyc_r <= 32'h0;
      n_ev <= 9'd0;
      overflow <= 1'b0;
      for (i = 0; i < DEPTH; i++)
        mem[i] <= 112'h0;
    end else begin
      cyc_r <= cyc_r + 32'd1;
      if (arm) begin
        wr <= '0;
        seq_r <= 16'h0;
        n_ev <= 9'd0;
        overflow <= 1'b0;
      end else begin
        if (armed && !freeze && fire && (n_ev >= 9'(DEPTH)))
          overflow <= 1'b1;
        else if (take) begin
          mem[wr] <= {epoch_id, seq_r, cyc_r, data, flags};
          wr <= wr + 1'b1;
          seq_r <= seq_r + 16'd1;
          n_ev <= n_ev + 9'd1;
        end
      end
    end
  end

  always_ff @(posedge clk) begin
    if (rd_en)
      rd_data <= mem[rd_addr[AW-1:0]];
  end

  assign wr_ptr = 8'(wr);
  wire unused_clr = clr_event;
endmodule
