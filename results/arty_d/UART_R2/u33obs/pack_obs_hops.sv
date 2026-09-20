// pack_obs_hops.sv — UART/FIFO_WR/FIFO_RD/CDC_A (clk100) + CDC_B/LOADER (ui).
// Observe-only. Overflow OR. PROGRAM=NO. 9-lane top still incomplete.
`timescale 1ns/1ps

module pack_obs_hops (
  input  logic         clk100,
  input  logic         ui_clk,
  input  logic         rst100_n,
  input  logic         rst_ui_n,
  input  logic         arm_100,
  input  logic         arm_ui,
  input  logic         armed_100,
  input  logic         armed_ui,
  input  logic         freeze_100,
  input  logic         freeze_ui,
  input  logic [15:0]  epoch_id,
  input  logic         uart_fire,
  input  logic [31:0]  uart_data,
  input  logic         fifo_wr_fire,
  input  logic [31:0]  fifo_wr_data,
  input  logic         fifo_rd_fire,
  input  logic [31:0]  fifo_rd_data,
  input  logic         cdc_a_fire,
  input  logic [31:0]  cdc_a_data,
  input  logic         p_fire,
  input  logic [31:0]  p_data,
  input  logic         clr_event,
  output logic         overflow,
  output logic [8:0]   n_uart,
  output logic [8:0]   n_fifo_wr,
  output logic [8:0]   n_fifo_rd,
  output logic [8:0]   n_cdc_a,
  output logic [8:0]   n_cdc_b,
  output logic [8:0]   n_load,
  input  logic         rd_uart_en,
  input  logic [7:0]   rd_uart_addr,
  output logic [111:0] rd_uart,
  input  logic         rd_load_en,
  input  logic [7:0]   rd_load_addr,
  output logic [111:0] rd_load
);
  logic ov_u, ov_fw, ov_fr, ov_ca, ov_cb, ov_ld;
  logic [7:0] wr_u, wr_fw, wr_fr, wr_ca, wr_cb, wr_ld;
  logic [111:0] dummy_fw, dummy_fr, dummy_ca, dummy_cb;

  pack_obs_lane u_uart (
    .clk(clk100), .rst_n(rst100_n), .arm(arm_100), .armed(armed_100),
    .freeze(freeze_100), .clr_event, .epoch_id,
    .fire(uart_fire), .data(uart_data), .flags(16'h0001),
    .overflow(ov_u), .n_ev(n_uart), .wr_ptr(wr_u),
    .rd_en(rd_uart_en), .rd_addr(rd_uart_addr), .rd_data(rd_uart)
  );
  pack_obs_lane u_fifo_wr (
    .clk(clk100), .rst_n(rst100_n), .arm(arm_100), .armed(armed_100),
    .freeze(freeze_100), .clr_event, .epoch_id,
    .fire(fifo_wr_fire), .data(fifo_wr_data), .flags(16'h0002),
    .overflow(ov_fw), .n_ev(n_fifo_wr), .wr_ptr(wr_fw),
    .rd_en(1'b0), .rd_addr(8'h0), .rd_data(dummy_fw)
  );
  pack_obs_lane u_fifo_rd (
    .clk(clk100), .rst_n(rst100_n), .arm(arm_100), .armed(armed_100),
    .freeze(freeze_100), .clr_event, .epoch_id,
    .fire(fifo_rd_fire), .data(fifo_rd_data), .flags(16'h0004),
    .overflow(ov_fr), .n_ev(n_fifo_rd), .wr_ptr(wr_fr),
    .rd_en(1'b0), .rd_addr(8'h0), .rd_data(dummy_fr)
  );
  pack_obs_lane u_cdc_a (
    .clk(clk100), .rst_n(rst100_n), .arm(arm_100), .armed(armed_100),
    .freeze(freeze_100), .clr_event, .epoch_id,
    .fire(cdc_a_fire), .data(cdc_a_data), .flags(16'h0008),
    .overflow(ov_ca), .n_ev(n_cdc_a), .wr_ptr(wr_ca),
    .rd_en(1'b0), .rd_addr(8'h0), .rd_data(dummy_ca)
  );
  pack_obs_lane u_cdc_b (
    .clk(ui_clk), .rst_n(rst_ui_n), .arm(arm_ui), .armed(armed_ui),
    .freeze(freeze_ui), .clr_event(1'b0), .epoch_id,
    .fire(p_fire), .data(p_data), .flags(16'h0010),
    .overflow(ov_cb), .n_ev(n_cdc_b), .wr_ptr(wr_cb),
    .rd_en(1'b0), .rd_addr(8'h0), .rd_data(dummy_cb)
  );
  pack_obs_lane u_load (
    .clk(ui_clk), .rst_n(rst_ui_n), .arm(arm_ui), .armed(armed_ui),
    .freeze(freeze_ui), .clr_event(1'b0), .epoch_id,
    .fire(p_fire), .data(p_data), .flags(16'h0020),
    .overflow(ov_ld), .n_ev(n_load), .wr_ptr(wr_ld),
    .rd_en(rd_load_en), .rd_addr(rd_load_addr), .rd_data(rd_load)
  );

  assign overflow = ov_u | ov_fw | ov_fr | ov_ca | ov_cb | ov_ld;
endmodule
