// tb_fem_media.v — D-INTEG-01 media + COMMITTED_CORRUPT. Not FEM_PERSIST_PASS.
`timescale 1ns/1ps

module tb_fem_media;
    reg clk = 0, rst_n = 0;
    always #5 clk = ~clk;

    reg req_valid, req_write, rsp_ready, force_fifo_empty, inject_tear;
    reg [3:0] req_addr;
    reg [31:0] req_wdata;
    reg [15:0] req_txn, req_gen;
    wire req_ready, rsp_valid, rsp_err;
    wire [31:0] rsp_rdata;
    wire [15:0] rsp_txn, rsp_gen, wr_outstanding;
    wire cmd_fifo_empty;

    fem_media_bridge dut (
        .clk(clk), .rst_n(rst_n),
        .req_valid(req_valid), .req_ready(req_ready), .req_write(req_write),
        .req_addr(req_addr), .req_wdata(req_wdata), .req_txn(req_txn), .req_gen(req_gen),
        .rsp_valid(rsp_valid), .rsp_ready(rsp_ready), .rsp_rdata(rsp_rdata),
        .rsp_txn(rsp_txn), .rsp_gen(rsp_gen), .rsp_err(rsp_err),
        .wr_outstanding(wr_outstanding), .cmd_fifo_empty(cmd_fifo_empty),
        .force_fifo_empty(force_fifo_empty), .inject_tear(inject_tear)
    );

    reg [31:0] w0, w1, crcw, commit, index;
    wire [1:0] rec;
    wire crc_ok, cmagic, dest_corrupt;
    fem_commit_class cls (
        .dest_w0(w0), .dest_w1(w1), .dest_crcw(crcw), .dest_commit(commit),
        .dest_index(index), .recover_state(rec),
        .dest_committed_corrupt(dest_corrupt), .crc_ok(crc_ok), .commit_magic(cmagic)
    );

    integer nfail, t;
    task wait_rsp;
        begin
            t = 0;
            while (!rsp_valid && t < 100) begin @(posedge clk); t = t + 1; end
            if (!rsp_valid) begin nfail = nfail + 1; $display("FAIL timeout"); end
        end
    endtask

    initial begin
        nfail = 0;
        req_valid = 0; req_write = 0; rsp_ready = 1;
        force_fifo_empty = 0; inject_tear = 0;
        req_addr = 0; req_wdata = 0; req_txn = 16'h11; req_gen = 16'h1;
        repeat (4) @(posedge clk);
        rst_n = 1;
        repeat (2) @(posedge clk);

        // T1: dest completion + identity
        req_write = 1; req_addr = 4'd1; req_wdata = 32'hA11CE001;
        @(posedge clk);
        req_valid = 1;
        @(posedge clk);
        req_valid = 0;
        wait_rsp;
        if (rsp_err || rsp_rdata != 32'hA11CE001 || rsp_txn != 16'h11 || rsp_gen != 16'h1 || wr_outstanding != 0)
            begin nfail = nfail + 1; $display("FAIL T1 dest"); end
        @(posedge clk);

        // T2: FIFO-empty must not complete
        force_fifo_empty = 1;
        req_write = 1; req_addr = 4'd2; req_wdata = 32'hBEEF0002;
        @(posedge clk);
        req_valid = 1;
        @(posedge clk);
        req_valid = 0;
        repeat (16) @(posedge clk);
        if (rsp_valid) begin nfail = nfail + 1; $display("FAIL T2 FIFO-empty completed"); end
        if (wr_outstanding == 0) begin nfail = nfail + 1; $display("FAIL T2 outstanding cleared by proxy"); end
        force_fifo_empty = 0;
        wait_rsp;
        if (rsp_err || rsp_rdata != 32'hBEEF0002) begin nfail = nfail + 1; $display("FAIL T2 after drop"); end
        @(posedge clk);

        // T3: torn beat -> rsp_err
        inject_tear = 1;
        req_write = 1; req_addr = 4'd0; req_wdata = 32'hCAFEBABE;
        @(posedge clk);
        req_valid = 1;
        @(posedge clk);
        req_valid = 0;
        inject_tear = 0;
        wait_rsp;
        if (!rsp_err) begin nfail = nfail + 1; $display("FAIL T3 tear not flagged"); end
        @(posedge clk);

        // T4: dest COMMITTED_CORRUPT is integrity, not recover_state=3
        w0 = 32'h11111111; w1 = 32'h22222222;
        crcw = 32'hA5A5_0000; // mark ok, crc payload wrong
        commit = 32'hC0117ED0;
        index = 32'h1; // must not upgrade
        #1;
        if (!dest_corrupt || rec !== 2'd0)
            begin nfail = nfail + 1; $display("FAIL T4 CORRUPT rec=%0d corrupt=%0d", rec, dest_corrupt); end

        // T5: COMMITTED_NEW requires dest CRC ok
        crcw = {16'hA5A5, cls_crc(w0, w1)};
        #1;
        if (rec !== 2'd2 || dest_corrupt)
            begin nfail = nfail + 1; $display("FAIL T5 NEW rec=%0d corrupt=%0d", rec, dest_corrupt); end

        if (nfail == 0) $display("FEM_MEDIA_XSIM_PASS dest-complete+CORRUPT (not FEM_PERSIST_PASS)");
        else $display("FEM_MEDIA_XSIM_FAIL nfail=%0d", nfail);
        $finish;
    end

    function [15:0] crc16_step; input [15:0] c; input [7:0] b; integer k; reg [15:0] x;
        begin
            x = c ^ {b, 8'h00};
            for (k = 0; k < 8; k = k + 1)
                x = x[15] ? {x[14:0], 1'b0} ^ 16'h1021 : {x[14:0], 1'b0};
            crc16_step = x;
        end
    endfunction
    function [15:0] cls_crc; input [31:0] a; input [31:0] b; reg [15:0] c;
        begin
            c = 16'hFFFF;
            c = crc16_step(c, a[31:24]); c = crc16_step(c, a[23:16]);
            c = crc16_step(c, a[15:8]);  c = crc16_step(c, a[7:0]);
            c = crc16_step(c, b[31:24]); c = crc16_step(c, b[23:16]);
            c = crc16_step(c, b[15:8]);  c = crc16_step(c, b[7:0]);
            cls_crc = c;
        end
    endfunction
endmodule
