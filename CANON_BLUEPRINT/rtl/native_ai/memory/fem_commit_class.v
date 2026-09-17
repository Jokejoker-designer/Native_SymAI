// fem_commit_class.v — dest-domain recovery class. CANDIDATE. PROGRAM=NO.
// A-D-INTEG-01: COMMITTED_CORRUPT is FEM_DEST_INTEGRITY, not a fourth compaction state.
// Compaction recover stays OLD_VALID / CANDIDATE_NEW / COMMITTED_NEW.
// INDEX must not upgrade CORRUPT to COMMITTED_NEW. B owns ASTRA 0x06/0x56.
`timescale 1ns/1ps
`default_nettype none

module fem_commit_class (
    input  wire [31:0] dest_w0,
    input  wire [31:0] dest_w1,
    input  wire [31:0] dest_crcw,
    input  wire [31:0] dest_commit,
    input  wire [31:0] dest_index,
    output wire [1:0]  recover_state, // 0 OLD_VALID 1 CANDIDATE_NEW 2 COMMITTED_NEW (never 3)
    output wire        dest_committed_corrupt,
    output wire        crc_ok,
    output wire        commit_magic
);
    localparam [31:0] COMMIT_MAGIC = 32'hC0117ED0;
    localparam [15:0] CRC_MARK = 16'hA5A5;

    function [15:0] crc16_step;
        input [15:0] c;
        input [7:0] b;
        integer k;
        reg [15:0] x;
        begin
            x = c ^ {b, 8'h00};
            for (k = 0; k < 8; k = k + 1)
                x = x[15] ? {x[14:0], 1'b0} ^ 16'h1021 : {x[14:0], 1'b0};
            crc16_step = x;
        end
    endfunction

    function [15:0] crc16_w64;
        input [31:0] w0;
        input [31:0] w1;
        integer i;
        reg [15:0] c;
        begin
            c = 16'hFFFF;
            c = crc16_step(c, w0[31:24]);
            c = crc16_step(c, w0[23:16]);
            c = crc16_step(c, w0[15:8]);
            c = crc16_step(c, w0[7:0]);
            c = crc16_step(c, w1[31:24]);
            c = crc16_step(c, w1[23:16]);
            c = crc16_step(c, w1[15:8]);
            c = crc16_step(c, w1[7:0]);
            crc16_w64 = c;
        end
    endfunction

    wire [15:0] crc_calc = crc16_w64(dest_w0, dest_w1);
    assign commit_magic = (dest_commit == COMMIT_MAGIC);
    assign crc_ok = (dest_crcw[31:16] == CRC_MARK) && (dest_crcw[15:0] == crc_calc);

    // Dest integrity overlay. Not compaction recover state 3.
    assign dest_committed_corrupt = commit_magic && !crc_ok;

    // Fail-closed: CORRUPT does not become COMMITTED_NEW even if INDEX is set.
    assign recover_state =
        dest_committed_corrupt ? 2'd0 :
        (commit_magic && crc_ok) ? 2'd2 :
        crc_ok                    ? 2'd1 :
                                     2'd0;

    wire _index_unused = |dest_index;
endmodule
`default_nettype wire
