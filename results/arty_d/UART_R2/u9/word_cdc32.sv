// word_cdc32.sv — UART_R2_U9: 16-cycle holdoff after each side leaves reset.
// Toggle CDC must not accept a_valid until async req/ack samples settle.
// CANDIDATE. PROGRAM=NO. Identity != PACKAGE live.
`timescale 1ns/1ps

module word_cdc32 (
  input  logic        a_clk,
  input  logic        a_rst_n,
  input  logic        a_valid,
  output logic        a_ready,
  input  logic [31:0] a_data,
  input  logic        b_clk,
  input  logic        b_rst_n,
  output logic        b_valid,
  input  logic        b_ready,
  output logic [31:0] b_data,
  output logic        a_idle,
  output logic        b_idle
);
  localparam int REL_N = 16;
  logic        req_a, ack_b;
  (* ASYNC_REG = "TRUE" *) logic ack_a0, ack_a1;
  logic [31:0] hold;
  (* ASYNC_REG = "TRUE" *) logic req_b0, req_b1;
  logic        req_b2, last_b;
  logic [4:0]  rel_a, rel_b;
  wire a_go = a_rst_n && (rel_a == REL_N[4:0]);
  wire b_go = b_rst_n && (rel_b == REL_N[4:0]);

  assign a_ready = a_go && (req_a == ack_a1);
  assign a_idle = a_go && (req_a == ack_a1);
  assign b_idle = b_go && !b_valid;

  always_ff @(posedge a_clk or negedge a_rst_n) begin
    if (!a_rst_n)
      rel_a <= 5'h0;
    else if (rel_a != REL_N[4:0])
      rel_a <= rel_a + 5'h1;
  end

  always_ff @(posedge b_clk or negedge b_rst_n) begin
    if (!b_rst_n)
      rel_b <= 5'h0;
    else if (rel_b != REL_N[4:0])
      rel_b <= rel_b + 5'h1;
  end

  always_ff @(posedge a_clk or negedge a_rst_n) begin
    if (!a_rst_n) begin
      req_a <= 1'b0;
      hold <= 32'h0;
      ack_a0 <= 1'b0;
      ack_a1 <= 1'b0;
    end else begin
      ack_a0 <= ack_b;
      ack_a1 <= ack_a0;
      if (a_valid && a_ready) begin
        hold <= a_data;
        req_a <= ~req_a;
      end
    end
  end

  always_ff @(posedge b_clk or negedge b_rst_n) begin
    if (!b_rst_n) begin
      req_b0 <= 1'b0;
      req_b1 <= 1'b0;
      req_b2 <= 1'b0;
      last_b <= 1'b0;
      ack_b <= 1'b0;
      b_valid <= 1'b0;
      b_data <= 32'h0;
    end else begin
      req_b0 <= req_a;
      req_b1 <= req_b0;
      req_b2 <= req_b1;
      if (!b_go) begin
        b_valid <= 1'b0;
      end else if (!b_valid && (req_b2 != last_b)) begin
        b_data <= hold;
        b_valid <= 1'b1;
        last_b <= req_b2;
      end else if (b_valid && b_ready) begin
        b_valid <= 1'b0;
        ack_b <= last_b;
      end
    end
  end
endmodule
