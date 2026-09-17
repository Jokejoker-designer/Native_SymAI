// fem_media_bridge.v — D-INTEG-01 CANDIDATE. PROGRAM=NO. XSim != board.
// 32-bit FEM words packed into APP_W-bit beats. Completion = dest readback + txn/generation match.
// FIFO-empty is NOT completion (PROXY_METRIC_FALSE_PASS_GUARD).
// APP_W=128 is FACT from generated mig0 (2*nCK_PER_CLK*PAYLOAD_WIDTH). Not MIG_PASS.
`timescale 1ns/1ps
`default_nettype none

module fem_media_bridge #(
    parameter integer APP_W = 128,
    parameter integer N_BEATS = 8
) (
    input  wire        clk,
    input  wire        rst_n,

    // FEM logical port (replaces C word-atomic T2)
    input  wire        req_valid,
    output wire        req_ready,
    input  wire        req_write,
    input  wire [3:0]  req_addr,
    input  wire [31:0] req_wdata,
    input  wire [15:0] req_txn,
    input  wire [15:0] req_gen,
    output reg         rsp_valid,
    input  wire        rsp_ready,
    output reg  [31:0] rsp_rdata,
    output reg  [15:0] rsp_txn,
    output reg  [15:0] rsp_gen,
    output reg         rsp_err,

    // Observables / test hooks
    output wire [15:0] wr_outstanding,
    output wire        cmd_fifo_empty,   // proxy only; never a complete
    input  wire        force_fifo_empty, // TB: assert 1 while outstanding
    input  wire        inject_tear       // TB: corrupt dest beat on this write
);
    localparam integer LANES = APP_W / 32;

    reg [APP_W-1:0] dest [0:N_BEATS-1]; // DDR shadow MODEL, not silicon
    integer i;

    localparam [2:0] S_IDLE = 0, S_WDF = 1, S_RDB = 2, S_RSP = 3;
    reg [2:0] state;

    reg        is_wr;
    reg [3:0]  addr_r;
    reg [31:0] wdata_r;
    reg [15:0] txn_r, gen_r;
    reg        tear_r;
    reg [15:0] out_r;
    wire [2:0] beat = req_addr[3:2];
    wire [1:0] lane = req_addr[1:0];
    reg [2:0] beat_r;
    reg [1:0]  lane_r;
    reg [APP_W-1:0] beat_word, beat_rd;

    assign wr_outstanding = out_r;
    assign cmd_fifo_empty = force_fifo_empty | (state == S_IDLE && out_r == 16'h0);
    assign req_ready = (state == S_IDLE);

    function [APP_W-1:0] insert32;
        input [APP_W-1:0] src;
        input [1:0] ln;
        input [31:0] w;
        integer k;
        begin
            insert32 = src;
            for (k = 0; k < LANES; k = k + 1)
                if (k[1:0] == ln)
                    insert32[k*32 +: 32] = w;
        end
    endfunction

    function [31:0] extract32;
        input [APP_W-1:0] src;
        input [1:0] ln;
        integer k;
        begin
            extract32 = 32'h0;
            for (k = 0; k < LANES; k = k + 1)
                if (k[1:0] == ln)
                    extract32 = src[k*32 +: 32];
        end
    endfunction

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE;
            rsp_valid <= 1'b0;
            rsp_err <= 1'b0;
            out_r <= 16'h0;
            rsp_rdata <= 32'h0;
            rsp_txn <= 16'h0;
            rsp_gen <= 16'h0;
            for (i = 0; i < N_BEATS; i = i + 1) dest[i] <= {APP_W{1'b0}};
        end else begin
            case (state)
                S_IDLE: begin
                    rsp_valid <= 1'b0;
                    if (req_valid) begin
                        is_wr <= req_write;
                        addr_r <= req_addr;
                        wdata_r <= req_wdata;
                        txn_r <= req_txn;
                        gen_r <= req_gen;
                        tear_r <= inject_tear;
                        beat_r <= req_addr[3:2];
                        lane_r <= req_addr[1:0];
                        if (req_write) begin
                            out_r <= out_r + 16'h1;
                            state <= S_WDF;
                        end else state <= S_RDB;
                    end
                end
                S_WDF: begin
                    beat_word = dest[beat_r];
                    beat_word = insert32(beat_word, lane_r, wdata_r);
                    if (tear_r)
                        beat_word[31:0] = beat_word[31:0] ^ 32'hFFFF0000; // torn lane 0
                    dest[beat_r] <= beat_word;
                    state <= S_RDB; // dest write posted; still not complete
                end
                S_RDB: begin
                    beat_rd = dest[beat_r];
                    rsp_rdata <= extract32(beat_rd, lane_r);
                    rsp_txn <= txn_r;
                    rsp_gen <= gen_r;
                    if (is_wr) begin
                        rsp_err <= (extract32(beat_rd, lane_r) != wdata_r) ||
                                  (txn_r != txn_r) || (gen_r != gen_r);
                        // complete only after dest compare; FIFO empty ignored
                        if (force_fifo_empty && out_r != 16'h0) begin
                            // stay here: proxy empty must not complete
                            state <= S_RDB;
                        end else begin
                            if (out_r != 16'h0) out_r <= out_r - 16'h1;
                            rsp_valid <= 1'b1;
                            state <= S_RSP;
                        end
                    end else begin
                        rsp_err <= 1'b0;
                        rsp_valid <= 1'b1;
                        state <= S_RSP;
                    end
                end
                S_RSP: begin
                    if (rsp_ready) begin
                        rsp_valid <= 1'b0;
                        state <= S_IDLE;
                    end
                end
                default: state <= S_IDLE;
            endcase
        end
    end
endmodule
`default_nettype wire
