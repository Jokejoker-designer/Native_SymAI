// tb_pack_hop_log.sv — CLEAR must not wipe; same-cycle uart+load both in mask.
`timescale 1ns/1ps

module tb_pack_hop_log;
  logic clk, rst_n, clr_event, uart_fire, fifo_wr_fire, fifo_rd_fire;
  logic cdc_a_fire, cdc_b_fire, load_fire, ack_event, nak_event;
  logic [31:0] uart_data, fifo_wr_data, fifo_rd_data, cdc_a_data, cdc_b_data, load_data;
  logic [7:0] reason_code;
  logic [8:0] n_ev, wr_ptr;
  logic [31:0] last_mask, last_data;
  integer fails;

  pack_hop_log #(.DEPTH(16)) u_log (
    .clk, .rst_n, .clr_event,
    .uart_fire, .uart_data,
    .fifo_wr_fire, .fifo_wr_data,
    .fifo_rd_fire, .fifo_rd_data,
    .cdc_a_fire, .cdc_a_data,
    .cdc_b_fire, .cdc_b_data,
    .load_fire, .load_data,
    .ack_event, .nak_event, .reason_code,
    .n_ev, .wr_ptr, .last_mask, .last_data
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  task automatic tick;
    begin
      @(posedge clk);
      #1;
      uart_fire = 1'b0; fifo_wr_fire = 1'b0; fifo_rd_fire = 1'b0;
      cdc_a_fire = 1'b0; cdc_b_fire = 1'b0; load_fire = 1'b0;
      clr_event = 1'b0; ack_event = 1'b0; nak_event = 1'b0;
    end
  endtask

  initial begin
    fails = 0;
    rst_n = 1'b0;
    clr_event = 1'b0;
    uart_fire = 1'b0; fifo_wr_fire = 1'b0; fifo_rd_fire = 1'b0;
    cdc_a_fire = 1'b0; cdc_b_fire = 1'b0; load_fire = 1'b0;
    ack_event = 1'b0; nak_event = 1'b0;
    uart_data = 32'h0; fifo_wr_data = 32'h0; fifo_rd_data = 32'h0;
    cdc_a_data = 32'h0; cdc_b_data = 32'h0; load_data = 32'h0;
    reason_code = 8'h0;
    repeat (4) @(posedge clk);
    rst_n = 1'b1;
    tick;
    uart_fire = 1'b1; uart_data = 32'h00800001;
    load_fire = 1'b1; load_data = 32'h3149414E;
    @(posedge clk);
    #1;
    if (n_ev != 9'd1) begin $display("FAIL n_ev %0d", n_ev); fails = fails + 1; end
    if (last_mask[0] != 1'b1 || last_mask[5] != 1'b1) begin
      $display("FAIL mask %08h", last_mask); fails = fails + 1;
    end
    if (last_data != 32'h3149414E) begin $display("FAIL data prefer load"); fails = fails + 1; end
    uart_fire = 1'b0; load_fire = 1'b0;
    tick;
    clr_event = 1'b1;
    @(posedge clk);
    #1;
    if (n_ev != 9'd2) begin $display("FAIL n_ev after CLEAR %0d", n_ev); fails = fails + 1; end
    clr_event = 1'b0;
    tick;
    uart_fire = 1'b1; uart_data = 32'hAABBCCDD;
    @(posedge clk);
    #1;
    if (n_ev != 9'd3) begin $display("FAIL survive CLEAR %0d", n_ev); fails = fails + 1; end
    if (fails == 0) $display("PASS_XSIM pack_hop_log CLEAR-survive same-cycle mask");
    else $display("FAIL pack_hop_log %0d", fails);
    $finish;
  end
endmodule
