// pack_abi24_dut.sv — AGENT_D integration wrapper. PROGRAM=NO.
// Instantiates pack_loader + a word-atomic memory model. Not Agent B gold.
// query_* fail-closed until the FE256 query path is bound (R-04/G-04 TB
// only samples query when query_valid=1).
`timescale 1ns/1ps

module pack_abi24_dut (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        s_valid,
  output logic        s_ready,
  input  logic [31:0] s_data,
  output logic        load_ack,
  output logic        load_reject,
  output logic [7:0]  reason_code,
  output logic [31:0] active_generation,
  output logic [7:0]  query_status,
  output logic [7:0]  query_reason,
  output logic        query_valid
);
  logic        mem_cmd_valid;
  logic        mem_cmd_ready;
  logic        mem_cmd_write;
  logic [27:0] mem_addr;
  logic [31:0] mem_wdata;
  logic        mem_resp_valid;
  logic        mem_resp_ready;
  logic        mem_resp_err;
  logic [31:0] mem_rdata;
  logic [15:0] wr_outstanding;

  logic [31:0] mem [0:65535];
  logic [31:0] resp_q [0:63];
  logic        err_q [0:63];
  integer      q_head, q_tail;
  integer      q_delay [0:63];

  assign mem_cmd_ready = 1'b1;
  assign mem_resp_err = (q_head != q_tail) ? err_q[q_head] : 1'b0;
  assign mem_rdata = (q_head != q_tail) ? resp_q[q_head] : 32'd0;
  assign mem_resp_valid = (q_head != q_tail) && (q_delay[q_head] == 0);

  assign query_status = 8'h00;
  assign query_reason = 8'h00;
  assign query_valid = 1'b0;

  pack_loader u_loader (
    .clk(clk),
    .rst_n(rst_n),
    .s_valid(s_valid),
    .s_ready(s_ready),
    .s_data(s_data),
    .mem_cmd_valid(mem_cmd_valid),
    .mem_cmd_ready(mem_cmd_ready),
    .mem_cmd_write(mem_cmd_write),
    .mem_addr(mem_addr),
    .mem_wdata(mem_wdata),
    .mem_resp_valid(mem_resp_valid),
    .mem_resp_ready(mem_resp_ready),
    .mem_resp_err(mem_resp_err),
    .mem_rdata(mem_rdata),
    .load_ack(load_ack),
    .load_reject(load_reject),
    .reason_code(reason_code),
    .active_generation(active_generation),
    .wr_outstanding(wr_outstanding)
  );

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      q_head <= 0;
      q_tail <= 0;
    end else begin
      if (mem_cmd_valid && mem_cmd_ready) begin
        if (mem_cmd_write) begin
          mem[mem_addr[17:2]] <= mem_wdata;
          resp_q[q_tail] <= 32'd0;
          err_q[q_tail] <= 1'b0;
        end else begin
          resp_q[q_tail] <= mem[mem_addr[17:2]];
          err_q[q_tail] <= 1'b0;
        end
        q_delay[q_tail] <= 0;
        q_tail <= (q_tail + 1) & 63;
      end
      if (q_head != q_tail && q_delay[q_head] > 0)
        q_delay[q_head] <= q_delay[q_head] - 1;
      if (mem_resp_valid && mem_resp_ready)
        q_head <= (q_head + 1) & 63;
    end
  end
endmodule
