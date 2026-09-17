// mig_ui_bram.sv — synthesizable native-UI dest (128b beats). CANDIDATE.
// Stand-in until mig0 app_* is instantiated. Not MIG_PASS.
// Beat index folds SLOT1_BASE (addr[20]) and FEM_BASE (addr[21]) so
// gen-1 / FEM region 28'h0200000 do not alias slot 0.
// RAM has no async reset (Synth 8-3391).
`timescale 1ns/1ps

module mig_ui_bram (
  input  logic         clk,
  input  logic         rst_n,
  output logic         calib_done,
  input  logic         stall,
  input  logic [27:0]  app_addr,
  input  logic [2:0]   app_cmd,
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
  (* ram_style = "block" *) logic [127:0] dest [0:4095];
  logic [11:0] widx, ridx;
  logic        rd_pend_v;
  logic [1:0]  rd_lat;
  logic [127:0] nxt, ram_q;
  integer b;

  assign calib_done = rst_n;
  assign app_rdy = rst_n && !stall;
  assign app_wdf_rdy = rst_n && !stall;
  assign app_rd_data_end = app_rd_data_valid;
  assign widx = {app_addr[21:20], app_addr[13:4]};

  always_ff @(posedge clk) begin
    if (app_wdf_wren && app_wdf_rdy) begin
      nxt = dest[widx];
      for (b = 0; b < 16; b = b + 1)
        if (!app_wdf_mask[b]) nxt[8*b +: 8] = app_wdf_data[8*b +: 8];
      dest[widx] <= nxt;
    end
    if (app_en && app_rdy && (app_cmd == 3'b001))
      ridx <= {app_addr[21:20], app_addr[13:4]};
    ram_q <= dest[ridx];
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      app_rd_data_valid <= 1'b0;
      app_rd_data <= 128'h0;
      rd_pend_v <= 1'b0;
      rd_lat <= 2'h0;
    end else begin
      app_rd_data_valid <= 1'b0;
      if (app_en && app_rdy && (app_cmd == 3'b001)) begin
        rd_pend_v <= 1'b1;
        rd_lat <= 2'd2;
      end
      if (rd_pend_v) begin
        if (rd_lat != 2'd0) rd_lat <= rd_lat - 2'd1;
        else begin
          app_rd_data <= ram_q;
          app_rd_data_valid <= 1'b1;
          rd_pend_v <= 1'b0;
        end
      end
    end
  end
endmodule
