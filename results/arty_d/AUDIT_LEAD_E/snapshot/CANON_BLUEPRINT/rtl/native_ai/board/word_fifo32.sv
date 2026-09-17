// word_fifo32.sv — 100 MHz RX word elastic buffer. CANDIDATE. PROGRAM=NO.
// Absorbs uart_rx_word while pack CDC/loader backpressures. CLEAR flushes.
// LUTRAM. Not Pack ABI. Not FE256.
`timescale 1ns/1ps

module word_fifo32 #(
  parameter int DEPTH = 128
) (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        wr_valid,
  output logic        wr_ready,
  input  logic [31:0] wr_data,
  output logic        rd_valid,
  input  logic        rd_ready,
  output logic [31:0] rd_data,
  input  logic        flush = 1'b0,
  output logic        empty
);
  localparam int AW = $clog2(DEPTH);
  (* ram_style = "distributed" *) logic [31:0] mem [0:DEPTH-1];
  logic [AW-1:0] wadr, radr;
  logic [AW:0]   used;

  assign empty    = (used == {1'b0, {AW{1'b0}}});
  assign wr_ready = rst_n && !flush && (used != DEPTH[AW:0]);
  assign rd_valid = rst_n && !flush && (used != {1'b0, {AW{1'b0}}});
  assign rd_data  = mem[radr];

  always_ff @(posedge clk) begin
    if (wr_valid && wr_ready)
      mem[wadr] <= wr_data;
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wadr <= {AW{1'b0}};
      radr <= {AW{1'b0}};
      used <= {1'b0, {AW{1'b0}}};
    end else if (flush) begin
      wadr <= {AW{1'b0}};
      radr <= {AW{1'b0}};
      used <= {1'b0, {AW{1'b0}}};
    end else begin
      unique case ({(wr_valid && wr_ready), (rd_valid && rd_ready)})
        2'b10: begin
          wadr <= wadr + {{(AW-1){1'b0}}, 1'b1};
          used <= used + {{AW{1'b0}}, 1'b1};
        end
        2'b01: begin
          radr <= radr + {{(AW-1){1'b0}}, 1'b1};
          used <= used - {{AW{1'b0}}, 1'b1};
        end
        2'b11: begin
          wadr <= wadr + {{(AW-1){1'b0}}, 1'b1};
          radr <= radr + {{(AW-1){1'b0}}, 1'b1};
        end
        default: ;
      endcase
    end
  end
endmodule
