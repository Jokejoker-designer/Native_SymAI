// pack_hop_log.sv — U33OBS observe-only. One BRAM write per cycle; bitmask of fires.
// Does not drive DUT ready. CLEAR is logged, not a wipe. PROGRAM=NO.
`timescale 1ns/1ps

module pack_hop_log #(
  parameter int DEPTH = 256
) (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        clr_event,
  input  logic        uart_fire,
  input  logic [31:0] uart_data,
  input  logic        fifo_wr_fire,
  input  logic [31:0] fifo_wr_data,
  input  logic        fifo_rd_fire,
  input  logic [31:0] fifo_rd_data,
  input  logic        cdc_a_fire,
  input  logic [31:0] cdc_a_data,
  input  logic        cdc_b_fire,
  input  logic [31:0] cdc_b_data,
  input  logic        load_fire,
  input  logic [31:0] load_data,
  input  logic        ack_event,
  input  logic        nak_event,
  input  logic [7:0]  reason_code,
  output logic [8:0]  n_ev,
  output logic [8:0]  wr_ptr,
  output logic [31:0] last_mask,
  output logic [31:0] last_data
);
  localparam int AW = $clog2(DEPTH);

  logic [8:0]  mask_c;
  logic [31:0] data_c;
  logic        any_c;
  logic [40:0] mem [0:DEPTH-1];
  logic [AW-1:0] wr;

  always_comb begin
    mask_c = 9'b0;
    mask_c[0] = uart_fire;
    mask_c[1] = fifo_wr_fire;
    mask_c[2] = fifo_rd_fire;
    mask_c[3] = cdc_a_fire;
    mask_c[4] = cdc_b_fire;
    mask_c[5] = load_fire;
    mask_c[6] = clr_event;
    mask_c[7] = ack_event;
    mask_c[8] = nak_event;
    any_c = |mask_c;
    if (load_fire)
      data_c = load_data;
    else if (cdc_b_fire)
      data_c = cdc_b_data;
    else if (cdc_a_fire)
      data_c = cdc_a_data;
    else if (fifo_rd_fire)
      data_c = fifo_rd_data;
    else if (fifo_wr_fire)
      data_c = fifo_wr_data;
    else if (uart_fire)
      data_c = uart_data;
    else if (ack_event || nak_event)
      data_c = {24'h0, reason_code};
    else
      data_c = 32'h0;
  end

  integer i;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wr <= '0;
      n_ev <= 9'd0;
      last_mask <= 32'h0;
      last_data <= 32'h0;
      for (i = 0; i < DEPTH; i++)
        mem[i] <= 41'h0;
    end else if (any_c) begin
      mem[wr] <= {mask_c, data_c};
      wr <= wr + 1'b1;
      last_mask <= {23'h0, mask_c};
      last_data <= data_c;
      if (n_ev != 9'(DEPTH))
        n_ev <= n_ev + 9'd1;
    end
  end

  assign wr_ptr = {{(9-AW){1'b0}}, wr};
endmodule
