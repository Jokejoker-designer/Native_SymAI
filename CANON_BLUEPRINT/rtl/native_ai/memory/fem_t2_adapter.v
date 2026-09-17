// fem_t2_adapter.v — dest-complete stall between C word-atomic T2 and media bridge.
// CANDIDATE. PROGRAM=NO. XSim != board.
// Completion = dest readback + matching txn/generation. FIFO-empty is not complete.
// C fem_lifecycle.t2_ready is the dest clock-enable. Drive it from fem_t2_ce
// (t2_ready = dest-complete / t2_ack), not from this adapter's IDLE flag alone.
`timescale 1ns/1ps
`default_nettype none

module fem_t2_adapter (
    input  wire        clk,
    input  wire        rst_n,

    // C-facing (stall until dest complete)
    input  wire        c_req,
    input  wire        c_we,
    input  wire [3:0]  c_addr,
    input  wire [31:0] c_wdata,
    input  wire [15:0] c_txn,
    input  wire [15:0] c_gen,
    output wire        t2_ready,
    output reg         t2_ack,
    output reg  [31:0] t2_rdata,
    output reg         t2_err,

    // media bridge
    output reg         req_valid,
    input  wire        req_ready,
    output reg         req_write,
    output reg  [3:0]  req_addr,
    output reg  [31:0] req_wdata,
    output reg  [15:0] req_txn,
    output reg  [15:0] req_gen,
    input  wire        rsp_valid,
    output wire        rsp_ready,
    input  wire [31:0] rsp_rdata,
    input  wire [15:0] rsp_txn,
    input  wire [15:0] rsp_gen,
    input  wire        rsp_err
);
    localparam [1:0] S_IDLE = 2'd0, S_ISSUE = 2'd1, S_WAIT = 2'd2, S_ACK = 2'd3;
    reg [1:0] state;

    assign t2_ready = (state == S_IDLE);
    assign rsp_ready = 1'b1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE;
            req_valid <= 1'b0;
            t2_ack <= 1'b0;
            t2_rdata <= 32'h0;
            t2_err <= 1'b0;
            req_write <= 1'b0;
            req_addr <= 4'h0;
            req_wdata <= 32'h0;
            req_txn <= 16'h0;
            req_gen <= 16'h0;
        end else begin
            t2_ack <= 1'b0;
            case (state)
                S_IDLE: begin
                    req_valid <= 1'b0;
                    if (c_req) begin
                        req_write <= c_we;
                        req_addr <= c_addr;
                        req_wdata <= c_wdata;
                        req_txn <= c_txn;
                        req_gen <= c_gen;
                        req_valid <= 1'b1;
                        state <= S_ISSUE;
                    end
                end
                S_ISSUE: begin
                    if (req_ready) begin
                        req_valid <= 1'b0;
                        state <= S_WAIT;
                    end
                end
                S_WAIT: begin
                    if (rsp_valid) begin
                        t2_rdata <= rsp_rdata;
                        t2_err <= rsp_err || (rsp_txn != req_txn) || (rsp_gen != req_gen);
                        t2_ack <= 1'b1;
                        state <= S_ACK;
                    end
                end
                S_ACK: state <= S_IDLE;
                default: state <= S_IDLE;
            endcase
        end
    end
endmodule
`default_nettype wire
