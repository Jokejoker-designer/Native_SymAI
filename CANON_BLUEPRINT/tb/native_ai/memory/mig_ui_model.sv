// mig_ui_model.sv — behavioral native MIG UI (XSim only). Not silicon. Not MIG_PASS.
`timescale 1ns/1ps

module mig_ui_model #(
  parameter int N_BEATS = 1024
) (
  input  logic         clk,
  input  logic         rst_n,
  output logic         calib_done,
  input  logic [27:0]  app_addr,
  input  logic [2:0]  app_cmd,
  input  logic         app_en,
  input  logic [127:0] app_wdf_data,
  input  logic         app_wdf_end,
  input  logic [15:0]  app_wdf_mask,
  input  logic         app_wdf_wren,
  output logic [127:0] app_rd_data,
  output logic         app_rd_data_end,
  output logic         app_rd_data_valid,
  output logic         app_rdy,
  output logic         app_wdf_rdy
);
  logic [127:0] dest [0:N_BEATS-1];
  logic [9:0] wr_idx, rd_idx, rd_pend;
  logic        rd_pend_v;
  logic [1:0]  rd_lat;
  integer i, b;

  assign calib_done = rst_n;
  assign app_rdy = rst_n;
  assign app_wdf_rdy = rst_n;
  assign app_rd_data_end = app_rd_data_valid;

  function automatic [9:0] beat_idx(input [27:0] a);
    beat_idx = a[13:4]; // 16-byte beats into 1024-entry model
  endfunction

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      app_rd_data_valid <= 1'b0;
      app_rd_data <= 128'h0;
      rd_pend_v <= 1'b0;
      rd_lat <= 2'h0;
      for (i = 0; i < N_BEATS; i = i + 1) dest[i] <= 128'h0;
    end else begin
      app_rd_data_valid <= 1'b0;
      if (app_en && app_rdy && app_cmd == 3'b001) begin
        rd_pend <= beat_idx(app_addr);
        rd_pend_v <= 1'b1;
        rd_lat <= 2'd2;
      end
      if (app_wdf_wren && app_wdf_rdy) begin
        wr_idx = beat_idx(app_addr);
        // apply byte mask: mask bit 1 = keep dest
        for (b = 0; b < 16; b = b + 1) begin
          if (!app_wdf_mask[b])
            dest[wr_idx][8*b +: 8] <= app_wdf_data[8*b +: 8];
        end
      end
      if (rd_pend_v) begin
        if (rd_lat != 2'd0) rd_lat <= rd_lat - 2'd1;
        else begin
          app_rd_data <= dest[rd_pend];
          app_rd_data_valid <= 1'b1;
          rd_pend_v <= 1'b0;
        end
      end
    end
  end
endmodule
