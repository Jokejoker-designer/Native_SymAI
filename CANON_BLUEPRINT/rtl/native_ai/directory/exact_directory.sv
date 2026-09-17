// M2 exact directory — AGENT_D CANDIDATE. §02.4.2 HotDirectoryEntry 128b.
// UG901 sync 1R BRAM: dout <= ram[addr] on clk; no async reset on RAM.
// Lookup is exact semantic_id match. Not ASTRA. PROGRAM=NO. XSim != board.
`timescale 1ns/1ps

module exact_directory #(
  parameter int N_DIR = 235
) (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        req_valid,
  output logic        req_ready,
  input  logic [31:0] semantic_id,
  input  logic [31:0] active_id_max,
  output logic        rsp_valid,
  input  logic        rsp_ready,
  output logic        hit,
  output logic        out_of_profile,
  output logic [31:0] fwd_ptr,
  output logic [31:0] rev_ptr,
  output logic [15:0] generation,
  output logic [7:0]  kind,
  output logic [7:0]  flags
);
  (* ram_style = "block" *) logic [127:0] rom [0:255];
  initial $readmemh("dir_a.mem", rom);

  logic [7:0]   rom_addr;
  logic [127:0] rom_q;
  always_ff @(posedge clk) begin
    rom_q <= rom[rom_addr];
  end

  typedef enum logic [1:0] { S_IDLE, S_WAIT, S_SCAN, S_RSP } state_t;
  state_t state;
  logic [7:0] idx;
  logic [31:0] sid;
  logic found, oop;
  logic [31:0] fptr, rptr;
  logic [15:0] gen;
  logic [7:0]  knd, fl;

  assign req_ready = (state == S_IDLE);
  assign rsp_valid = (state == S_RSP);
  assign hit = found;
  assign out_of_profile = oop;
  assign fwd_ptr = fptr;
  assign rev_ptr = rptr;
  assign generation = gen;
  assign kind = knd;
  assign flags = fl;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= S_IDLE;
      idx <= 8'h0;
      rom_addr <= 8'h0;
      found <= 1'b0;
      oop <= 1'b0;
      fptr <= 32'h0;
      rptr <= 32'h0;
      gen <= 16'h0;
      knd <= 8'h0;
      fl <= 8'h0;
    end else begin
      case (state)
        S_IDLE: begin
          if (req_valid) begin
            sid <= semantic_id;
            idx <= 8'h0;
            rom_addr <= 8'h0;
            found <= 1'b0;
            oop <= (semantic_id > active_id_max);
            fptr <= 32'h0;
            rptr <= 32'h0;
            gen <= 16'h0;
            knd <= 8'h0;
            fl <= 8'h0;
            if (semantic_id > active_id_max) state <= S_RSP;
            else state <= S_WAIT;
          end
        end
        S_WAIT: state <= S_SCAN;
        S_SCAN: begin
          if (idx >= N_DIR[7:0]) state <= S_RSP;
          else if (rom_q[31:0] == sid) begin
            found <= 1'b1;
            fptr <= rom_q[63:32];
            rptr <= rom_q[95:64];
            gen <= rom_q[111:96];
            knd <= rom_q[119:112];
            fl <= rom_q[127:120];
            state <= S_RSP;
          end else begin
            idx <= idx + 8'h1;
            rom_addr <= idx + 8'h1;
            state <= S_WAIT;
          end
        end
        S_RSP: if (rsp_ready) state <= S_IDLE;
        default: state <= S_IDLE;
      endcase
    end
  end
endmodule
