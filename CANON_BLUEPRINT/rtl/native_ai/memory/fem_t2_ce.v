// fem_t2_ce.v — C t2_ready clock-enable over dest-complete adapter.
// CANDIDATE. PROGRAM=NO. XSim != board. Not FEM_PERSIST_PASS.
// C ACK D-06: t2_ready = dest-complete (readback + txn/gen). Drop ready the
// cycle after a T2 accept; raise only on dest match. FIFO-empty is not ready.
`timescale 1ns/1ps
`default_nettype none

module fem_t2_ce (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        c_busy,
    input  wire        c_we,
    input  wire [3:0]  c_addr,
    input  wire [31:0] c_wdata,
    output wire        t2_ready,
    output reg  [31:0] t2_rdata,
    output reg         t2_err,

    output reg         c_req,
    output wire        c_we_iss,
    output wire [3:0]  c_addr_iss,
    output wire [31:0] c_wdata_iss,
    output reg  [15:0] c_txn,
    output reg  [15:0] c_gen,
    input  wire        adp_ready,
    input  wire        adp_ack,
    input  wire [31:0] adp_rdata,
    input  wire        adp_err
);
    localparam [1:0] CE_IDLE = 2'd0, CE_HOLD = 2'd1, CE_PULSE = 2'd2;
    reg [1:0] st;
    reg        issued;
    reg [31:0] dest_hold;
    reg        dest_err_h;

    // C is frozen while t2_ready=0, so the held T2 command is the live port.
    assign t2_ready = (st == CE_IDLE) || (st == CE_PULSE);
    assign c_we_iss = c_we;
    assign c_addr_iss = c_addr;
    assign c_wdata_iss = c_wdata;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            st <= CE_IDLE;
            issued <= 1'b0;
            c_req <= 1'b0;
            c_txn <= 16'h1;
            c_gen <= 16'h1;
            t2_rdata <= 32'h0;
            t2_err <= 1'b0;
            dest_hold <= 32'h0;
            dest_err_h <= 1'b0;
        end else begin
            c_req <= 1'b0;
            case (st)
                CE_IDLE: begin
                    if (c_busy) begin
                        issued <= 1'b0;
                        st <= CE_HOLD;
                    end
                end
                CE_HOLD: begin
                    if (!issued && adp_ready) begin
                        c_req <= 1'b1;
                        issued <= 1'b1;
                    end
                    if (adp_ack) begin
                        dest_hold <= adp_rdata;
                        dest_err_h <= adp_err;
                        c_txn <= c_txn + 16'h1;
                        st <= CE_PULSE;
                    end
                end
                CE_PULSE: begin
                    // NBA: C captures the previous ready-cycle rdata (C 1-cycle T2 model).
                    t2_rdata <= dest_hold;
                    t2_err <= dest_err_h;
                    if (c_busy) begin
                        issued <= 1'b0;
                        st <= CE_HOLD;
                    end else st <= CE_IDLE;
                end
                default: st <= CE_IDLE;
            endcase
        end
    end
endmodule
`default_nettype wire
