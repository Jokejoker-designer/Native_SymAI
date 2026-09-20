// pack_obs_9lane.sv — hops + CONTROL/STATE/TERMINAL. Observe-only. PROGRAM=NO.
`timescale 1ns/1ps

module pack_obs_9lane (
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
  input  logic         ctrl_fire,
  input  logic [31:0]  ctrl_data,
  input  logic [15:0]  ctrl_flags,
  input  logic         state_fire,
  input  logic [31:0]  state_data,
  input  logic [15:0]  state_flags,
  input  logic         term_fire,
  input  logic [31:0]  term_data,
  input  logic [15:0]  term_flags,
  output logic         overflow,
  output logic [8:0]   n_uart,
  output logic [8:0]   n_fifo_wr,
  output logic [8:0]   n_fifo_rd,
  output logic [8:0]   n_cdc_a,
  output logic [8:0]   n_cdc_b,
  output logic [8:0]   n_load,
  output logic [8:0]   n_ctrl,
  output logic [8:0]   n_state,
  output logic [8:0]   n_term,
  input  logic         rd_uart_en,
  input  logic [7:0]   rd_uart_addr,
  output logic [111:0] rd_uart,
  input  logic         rd_load_en,
  input  logic [7:0]   rd_load_addr,
  output logic [111:0] rd_load,
  input  logic         rd_term_en,
  input  logic [7:0]   rd_term_addr,
  output logic [111:0] rd_term
);
  logic ov_h, ov_c, ov_s, ov_t;
  logic [7:0] wr_c, wr_s, wr_t;
  logic [111:0] dummy_c, dummy_s;

  pack_obs_hops u_hops (
    .clk100, .ui_clk, .rst100_n, .rst_ui_n,
    .arm_100, .arm_ui, .armed_100, .armed_ui, .freeze_100, .freeze_ui,
    .epoch_id, .uart_fire, .uart_data, .fifo_wr_fire, .fifo_wr_data,
    .fifo_rd_fire, .fifo_rd_data, .cdc_a_fire, .cdc_a_data, .p_fire, .p_data,
    .clr_event, .overflow(ov_h), .n_uart, .n_fifo_wr, .n_fifo_rd,
    .n_cdc_a, .n_cdc_b, .n_load,
    .rd_uart_en, .rd_uart_addr, .rd_uart,
    .rd_load_en, .rd_load_addr, .rd_load
  );

  pack_obs_lane u_ctrl (
    .clk(clk100), .rst_n(rst100_n), .arm(arm_100), .armed(armed_100),
    .freeze(freeze_100), .clr_event, .epoch_id,
    .fire(ctrl_fire), .data(ctrl_data), .flags(ctrl_flags),
    .overflow(ov_c), .n_ev(n_ctrl), .wr_ptr(wr_c),
    .rd_en(1'b0), .rd_addr(8'h0), .rd_data(dummy_c)
  );
  pack_obs_lane u_state (
    .clk(ui_clk), .rst_n(rst_ui_n), .arm(arm_ui), .armed(armed_ui),
    .freeze(freeze_ui), .clr_event(1'b0), .epoch_id,
    .fire(state_fire), .data(state_data), .flags(state_flags),
    .overflow(ov_s), .n_ev(n_state), .wr_ptr(wr_s),
    .rd_en(1'b0), .rd_addr(8'h0), .rd_data(dummy_s)
  );
  pack_obs_lane u_term (
    .clk(ui_clk), .rst_n(rst_ui_n), .arm(arm_ui), .armed(armed_ui),
    .freeze(freeze_ui), .clr_event(1'b0), .epoch_id,
    .fire(term_fire), .data(term_data), .flags(term_flags),
    .overflow(ov_t), .n_ev(n_term), .wr_ptr(wr_t),
    .rd_en(rd_term_en), .rd_addr(rd_term_addr), .rd_data(rd_term)
  );

  assign overflow = ov_h | ov_c | ov_s | ov_t;
endmodule
