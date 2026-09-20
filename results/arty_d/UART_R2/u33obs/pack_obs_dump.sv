// pack_obs_dump.sv — TAP dump after freeze (NAK or HOST_DUMP). Dedicated CDC.
// Magic 31504154. Does not reuse product TX CDC. PROGRAM=NO. Not PACK_ABI.
`timescale 1ns/1ps

module pack_obs_dump (
  input  logic        clk100,
  input  logic        ui_clk,
  input  logic        rst100_n,
  input  logic        rst_ui_n,
  input  logic        arm_100,
  input  logic        arm_ui,
  input  logic        freeze,
  input  logic [3:0]  freeze_reason,
  input  logic        uart_fire,
  input  logic [31:0] uart_data,
  input  logic        p_fire,
  input  logic [31:0] p_data,
  output logic        tap_b_valid,
  input  logic        tap_b_ready,
  output logic [31:0] tap_b_data
);
  localparam logic [31:0] TAP1 = 32'h31504154;

  logic [31:0] u0, u1, l0, l1;
  logic [1:0]  nu, nl;
  logic        freeze_d, freeze_ui0, freeze_ui, freeze_ui_d;

  always_ff @(posedge clk100 or negedge rst100_n) begin
    if (!rst100_n) begin
      u0 <= 32'h0; u1 <= 32'h0; nu <= 2'd0; freeze_d <= 1'b0;
    end else begin
      freeze_d <= freeze;
      if (arm_100) begin
        u0 <= 32'h0; u1 <= 32'h0; nu <= 2'd0;
      end else if (uart_fire) begin
        if (nu == 2'd0) u0 <= uart_data;
        else if (nu == 2'd1) u1 <= uart_data;
        if (nu < 2'd2) nu <= nu + 2'd1;
      end
    end
  end

  always_ff @(posedge ui_clk or negedge rst_ui_n) begin
    if (!rst_ui_n) begin
      l0 <= 32'h0; l1 <= 32'h0; nl <= 2'd0;
      freeze_ui0 <= 1'b0; freeze_ui <= 1'b0; freeze_ui_d <= 1'b0;
    end else begin
      freeze_ui0 <= freeze; freeze_ui <= freeze_ui0; freeze_ui_d <= freeze_ui;
      if (arm_ui) begin
        l0 <= 32'h0; l1 <= 32'h0; nl <= 2'd0;
      end else if (p_fire) begin
        if (nl == 2'd0) l0 <= p_data;
        else if (nl == 2'd1) l1 <= p_data;
        if (nl < 2'd2) nl <= nl + 2'd1;
      end
    end
  end

  logic u_a_valid, u_a_ready, u_b_valid, u_b_ready;
  logic [31:0] u_a_data, u_b_data;
  logic [1:0]  usend;
  logic        send_u;

  assign send_u = freeze && !freeze_d;
  always_ff @(posedge clk100 or negedge rst100_n) begin
    if (!rst100_n) begin
      u_a_valid <= 1'b0; u_a_data <= 32'h0; usend <= 2'd0;
    end else if (send_u) begin
      u_a_data <= u0;
      u_a_valid <= 1'b1;
      usend <= 2'd1;
    end else if (u_a_valid && u_a_ready) begin
      u_a_valid <= 1'b0;
      if (usend == 2'd1) begin
        u_a_data <= u1;
        u_a_valid <= 1'b1;
        usend <= 2'd2;
      end else
        usend <= 2'd0;
    end
  end

  word_cdc32 u_cdc_u2ui (
    .a_clk(clk100), .a_rst_n(rst100_n),
    .a_valid(u_a_valid), .a_ready(u_a_ready), .a_data(u_a_data),
    .b_clk(ui_clk), .b_rst_n(rst_ui_n),
    .b_valid(u_b_valid), .b_ready(u_b_ready), .b_data(u_b_data),
    .a_idle(), .b_idle()
  );

  logic [31:0] ru0, ru1;
  logic [1:0]  ngot;
  logic        dump_go;
  assign u_b_ready = (ngot < 2'd2);

  always_ff @(posedge ui_clk or negedge rst_ui_n) begin
    if (!rst_ui_n) begin
      ru0 <= 32'h0; ru1 <= 32'h0; ngot <= 2'd0; dump_go <= 1'b0;
    end else begin
      dump_go <= 1'b0;
      if (arm_ui || (freeze_ui && !freeze_ui_d))
        ngot <= 2'd0;
      if (u_b_valid && u_b_ready) begin
        if (ngot == 2'd0) ru0 <= u_b_data;
        else if (ngot == 2'd1) ru1 <= u_b_data;
        ngot <= ngot + 2'd1;
        if (ngot == 2'd1)
          dump_go <= 1'b1;
      end
    end
  end

  logic tap_a_valid, tap_a_ready;
  logic [31:0] tap_a_data;
  logic [3:0]  dump_n;
  logic [31:0] dump_w [0:5];

  always_ff @(posedge ui_clk or negedge rst_ui_n) begin
    if (!rst_ui_n) begin
      tap_a_valid <= 1'b0; tap_a_data <= 32'h0; dump_n <= 4'd0;
      dump_w[0] <= 32'h0; dump_w[1] <= 32'h0; dump_w[2] <= 32'h0;
      dump_w[3] <= 32'h0; dump_w[4] <= 32'h0; dump_w[5] <= 32'h0;
    end else begin
      if (dump_go) begin
        dump_w[0] <= TAP1;
        dump_w[1] <= ru0;
        dump_w[2] <= ru1;
        dump_w[3] <= l0;
        dump_w[4] <= l1;
        dump_w[5] <= {8'hA1, 4'h0, freeze_reason, 6'h0, nl, 8'h1A};
        dump_n <= 4'd6;
        tap_a_valid <= 1'b0;
      end
      if (tap_a_valid && tap_a_ready) begin
        tap_a_valid <= 1'b0;
        dump_w[0] <= dump_w[1];
        dump_w[1] <= dump_w[2];
        dump_w[2] <= dump_w[3];
        dump_w[3] <= dump_w[4];
        dump_w[4] <= dump_w[5];
        dump_w[5] <= 32'h0;
        dump_n <= dump_n - 4'd1;
      end else if (!tap_a_valid && dump_n != 4'd0) begin
        tap_a_data <= dump_w[0];
        tap_a_valid <= 1'b1;
      end
    end
  end

  word_cdc32 u_cdc_tap (
    .a_clk(ui_clk), .a_rst_n(rst_ui_n),
    .a_valid(tap_a_valid), .a_ready(tap_a_ready), .a_data(tap_a_data),
    .b_clk(clk100), .b_rst_n(rst100_n),
    .b_valid(tap_b_valid), .b_ready(tap_b_ready), .b_data(tap_b_data),
    .a_idle(), .b_idle()
  );
endmodule
