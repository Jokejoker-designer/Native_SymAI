// H-ILA-A capture: first 4 RX bytes after reset AND first 4 after CLEAR take.
// Observe-only. BASIC license (no ILA IP). Not PACK_ABI / not BOARD_PASS.
`timescale 1ns/1ps

module h_ila_a_cap #(
  parameter int CLK_HZ = 100_000_000,
  parameter int BAUD = 115200
) (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        clr_take,
  input  logic        w_valid,
  input  logic [31:0] w_data,
  input  logic        fifo_wr_valid,
  input  logic        fifo_wr_ready,
  input  logic [1:0]  dbg_bix,
  input  logic [7:0]  dbg_sh,
  input  logic        dbg_rx_d,
  input  logic [1:0]  dbg_st,
  output logic        captured,
  output logic [7:0]  sh0,
  output logic [7:0]  sh1,
  output logic [7:0]  sh2,
  output logic [7:0]  sh3,
  output logic [3:0]  n_bytes,
  output logic [1:0]  bix_at_arm,
  output logic [9:0]  wire10,
  output logic        false_start,
  output logic        have_word,
  output logic [31:0] first_word,
  output logic        wv_at_sh0,
  output logic        fifo_wr_at_sh0
);
  localparam int DIV = CLK_HZ / BAUD;
  logic take_d, wv_d, rx_d_d;
  logic [1:0] bix_d;
  logic sampling, wire_done, post_clear;
  logic [15:0] divc;
  logic [3:0] nbit;
  logic [7:0] rst0, rst1, rst2, rst3;
  logic [3:0] n_rst;
  logic [7:0] post0, post1, post2, post3;
  logic [3:0] n_post;

  assign captured = (n_rst != 4'h0) || (n_post != 4'h0);
  assign sh0 = (n_post != 4'h0) ? post0 : rst0;
  assign sh1 = (n_post != 4'h0) ? post1 : rst1;
  assign sh2 = (n_post != 4'h0) ? post2 : rst2;
  assign sh3 = (n_post != 4'h0) ? post3 : rst3;
  assign n_bytes = (n_post != 4'h0) ? n_post : n_rst;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      take_d <= 1'b0;
      wv_d <= 1'b0;
      rx_d_d <= 1'b1;
      bix_d <= 2'h0;
      bix_at_arm <= 2'h0;
      wire10 <= 10'h0;
      false_start <= 1'b0;
      have_word <= 1'b0;
      first_word <= 32'h0;
      wv_at_sh0 <= 1'b0;
      fifo_wr_at_sh0 <= 1'b0;
      sampling <= 1'b0;
      wire_done <= 1'b0;
      post_clear <= 1'b0;
      divc <= 16'h0;
      nbit <= 4'h0;
      rst0 <= 8'h0;
      rst1 <= 8'h0;
      rst2 <= 8'h0;
      rst3 <= 8'h0;
      n_rst <= 4'h0;
      post0 <= 8'h0;
      post1 <= 8'h0;
      post2 <= 8'h0;
      post3 <= 8'h0;
      n_post <= 4'h0;
    end else begin
      take_d <= clr_take;
      wv_d <= w_valid;
      rx_d_d <= dbg_rx_d;
      bix_d <= dbg_bix;
      if (clr_take && !take_d) begin
        post_clear <= 1'b1;
        n_post <= 4'h0;
        post0 <= 8'h0;
        post1 <= 8'h0;
        post2 <= 8'h0;
        post3 <= 8'h0;
        have_word <= 1'b0;
        first_word <= 32'h0;
        bix_at_arm <= dbg_bix;
      end
      if (!post_clear && (dbg_bix != bix_d) && (n_rst < 4'h4)) begin
        unique case (n_rst)
          4'h0: begin
            rst0 <= dbg_sh;
            wv_at_sh0 <= w_valid;
            fifo_wr_at_sh0 <= fifo_wr_valid && fifo_wr_ready;
          end
          4'h1: rst1 <= dbg_sh;
          4'h2: rst2 <= dbg_sh;
          default: rst3 <= dbg_sh;
        endcase
        n_rst <= n_rst + 4'h1;
      end
      if (post_clear && (dbg_bix != bix_d) && (n_post < 4'h4)) begin
        unique case (n_post)
          4'h0: post0 <= dbg_sh;
          4'h1: post1 <= dbg_sh;
          4'h2: post2 <= dbg_sh;
          default: post3 <= dbg_sh;
        endcase
        n_post <= n_post + 4'h1;
      end
      if (w_valid && !wv_d && !have_word && post_clear) begin
        first_word <= w_data;
        have_word <= 1'b1;
      end else if (w_valid && !wv_d && !have_word && !post_clear) begin
        first_word <= w_data;
        have_word <= 1'b1;
      end
      if (!wire_done && !sampling && (dbg_st == 2'h0) && rx_d_d && !dbg_rx_d) begin
        sampling <= 1'b1;
        divc <= DIV[15:0] / 16'd2;
        nbit <= 4'h0;
      end else if (sampling) begin
        if (divc == 16'h0) begin
          wire10[nbit] <= dbg_rx_d;
          if (nbit == 4'h0 && dbg_rx_d)
            false_start <= 1'b1;
          if (nbit == 4'd9) begin
            sampling <= 1'b0;
            wire_done <= 1'b1;
          end else begin
            nbit <= nbit + 4'h1;
            divc <= DIV[15:0];
          end
        end else
          divc <= divc - 16'h1;
      end
    end
  end
endmodule
