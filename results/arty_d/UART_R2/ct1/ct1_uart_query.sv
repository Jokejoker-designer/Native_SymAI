// ct1_uart_query.sv — steal QueryRecord 0x4E51 before pack FIFO; dest eval, not dir_a.mem.
// TX 03|hit|00|51 after dest lookup (or fail-closed UNSET / unpublished root).
// Unique CT1 identity. PROGRAM=NO. Not PACK_ABI_24_24_PASS.
`timescale 1ns/1ps

module ct1_uart_query (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        w_valid,
  input  logic [31:0] w_data,
  input  logic        dump_take,
  input  logic        clr_take,
  input  logic        debug_clear,
  input  logic        pack_done,
  input  logic [31:0] active_generation,
  input  logic        root_valid100,
  output logic        q_take,
  output logic        eval_req,
  output logic [31:0] eval_sid,
  input  logic        eval_busy,
  input  logic        eval_done,
  input  logic        eval_hit,
  input  logic [31:0] eval_nb,
  output logic        tx_valid,
  input  logic        tx_ready,
  output logic [31:0] tx_data,
  output logic        q_hit,
  output logic [31:0] q_nb
);
  localparam logic [15:0] MAGIC_QUERY = 16'h4E51;
  localparam logic [31:0] UNSET_GEN = 32'hFFFF_FFFF;

  function automatic [15:0] crc_feed(input [15:0] c0, input [7:0] b);
    logic [15:0] c;
    integer k;
    begin
      c = c0 ^ {b, 8'h00};
      for (k = 0; k < 8; k = k + 1)
        c = c[15] ? ({c[14:0], 1'b0} ^ 16'h1021) : {c[14:0], 1'b0};
      crc_feed = c;
    end
  endfunction

  function automatic [15:0] crc16_q(input [255:0] p);
    integer ii;
    logic [15:0] c;
    begin
      c = 16'hFFFF;
      for (ii = 0; ii < 30; ii = ii + 1)
        c = crc_feed(c, p[8*ii +: 8]);
      crc16_q = c;
    end
  endfunction

  logic        collecting, uart_busy, issued, mag_fail, crc_fail;
  logic [2:0]  wix;
  logic [255:0] q_pack;
  typedef enum logic [1:0] { S_IDLE, S_EVAL, S_TX } st_t;
  st_t st;
  logic        hit_r;
  logic [31:0] nb_r;

  assign q_take = collecting ||
                  (w_valid && !dump_take && !clr_take && !uart_busy &&
                   (w_data[15:0] == MAGIC_QUERY));
  assign q_hit = hit_r;
  assign q_nb = nb_r;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      collecting <= 1'b0;
      uart_busy <= 1'b0;
      wix <= 3'h0;
      q_pack <= 256'h0;
      st <= S_IDLE;
      eval_req <= 1'b0;
      eval_sid <= 32'h0;
      tx_valid <= 1'b0;
      tx_data <= 32'h0;
      hit_r <= 1'b0;
      nb_r <= 32'h0;
      mag_fail <= 1'b0;
      crc_fail <= 1'b0;
      issued <= 1'b0;
    end else begin
      eval_req <= 1'b0;
      if (debug_clear || pack_done)
        uart_busy <= 1'b0;
      else if (w_valid && !dump_take && !clr_take && !collecting && !q_take &&
               (w_data[7:0] == 8'h01))
        uart_busy <= 1'b1;
      if (tx_valid && tx_ready)
        tx_valid <= 1'b0;

      if (q_take && w_valid && !dump_take && !clr_take && (st == S_IDLE)) begin
        if (!collecting) begin
          q_pack[31:0] <= w_data;
          wix <= 3'h1;
          collecting <= 1'b1;
        end else begin
          q_pack[32*wix +: 32] <= w_data;
          if (wix == 3'h7) begin
            collecting <= 1'b0;
            wix <= 3'h0;
            mag_fail <= (q_pack[15:0] != MAGIC_QUERY);
            crc_fail <= (crc16_q({w_data, q_pack[223:0]}) != w_data[31:16]);
            st <= S_EVAL;
            issued <= 1'b0;
          end else
            wix <= wix + 3'h1;
        end
      end

      unique case (st)
        S_IDLE: ;
        S_EVAL: begin
          if (mag_fail || crc_fail) begin
            hit_r <= 1'b0;
            nb_r <= 32'h0;
            tx_data <= {8'h03, 8'h06, 8'h55, 8'h51};
            tx_valid <= 1'b1;
            issued <= 1'b0;
            st <= S_TX;
          end else if ((active_generation == UNSET_GEN) || !root_valid100) begin
            hit_r <= 1'b0;
            nb_r <= 32'h0;
            tx_data <= {8'h03, 8'h00, 8'h00, 8'h51};
            tx_valid <= 1'b1;
            issued <= 1'b0;
            st <= S_TX;
          end else if (!issued && !eval_busy) begin
            if (eval_sid != {q_pack[143:136], q_pack[135:128],
                             q_pack[127:120], q_pack[119:112]}) begin
              eval_sid <= {q_pack[143:136], q_pack[135:128],
                           q_pack[127:120], q_pack[119:112]};
            end else begin
              eval_req <= 1'b1;
              issued <= 1'b1;
            end
          end else if (issued && eval_done) begin
            hit_r <= eval_hit;
            nb_r <= eval_nb;
            tx_data <= {8'h03, eval_hit ? 8'h01 : 8'h00, 8'h00, 8'h51};
            tx_valid <= 1'b1;
            issued <= 1'b0;
            st <= S_TX;
          end
        end
        S_TX: begin
          if (!tx_valid)
            st <= S_IDLE;
        end
        default: st <= S_IDLE;
      endcase
    end
  end
endmodule
