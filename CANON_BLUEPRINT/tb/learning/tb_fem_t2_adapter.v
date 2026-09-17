// tb_fem_t2_adapter.v — dest-complete stall. Not FEM_PERSIST_PASS.
`timescale 1ns/1ps

module tb_fem_t2_adapter;
    reg clk = 0, rst_n = 0;
    always #5 clk = ~clk;

    reg c_req, c_we;
    reg [3:0] c_addr;
    reg [31:0] c_wdata;
    reg [15:0] c_txn, c_gen;
    wire t2_ready, t2_ack, t2_err;
    wire [31:0] t2_rdata;

    wire req_valid, req_ready, req_write, rsp_valid, rsp_err, adp_rsp_ready;
    wire [3:0] req_addr;
    wire [31:0] req_wdata, rsp_rdata;
    wire [15:0] req_txn, req_gen, rsp_txn, rsp_gen, wr_outstanding;
    wire cmd_fifo_empty;
    reg force_fifo_empty, inject_tear;

    fem_t2_adapter adp (
        .clk(clk), .rst_n(rst_n),
        .c_req(c_req), .c_we(c_we), .c_addr(c_addr), .c_wdata(c_wdata),
        .c_txn(c_txn), .c_gen(c_gen),
        .t2_ready(t2_ready), .t2_ack(t2_ack), .t2_rdata(t2_rdata), .t2_err(t2_err),
        .req_valid(req_valid), .req_ready(req_ready), .req_write(req_write),
        .req_addr(req_addr), .req_wdata(req_wdata), .req_txn(req_txn), .req_gen(req_gen),
        .rsp_valid(rsp_valid), .rsp_ready(adp_rsp_ready), .rsp_rdata(rsp_rdata),
        .rsp_txn(rsp_txn), .rsp_gen(rsp_gen), .rsp_err(rsp_err)
    );

    fem_media_bridge br (
        .clk(clk), .rst_n(rst_n),
        .req_valid(req_valid), .req_ready(req_ready), .req_write(req_write),
        .req_addr(req_addr), .req_wdata(req_wdata), .req_txn(req_txn), .req_gen(req_gen),
        .rsp_valid(rsp_valid), .rsp_ready(adp_rsp_ready), .rsp_rdata(rsp_rdata),
        .rsp_txn(rsp_txn), .rsp_gen(rsp_gen), .rsp_err(rsp_err),
        .wr_outstanding(wr_outstanding), .cmd_fifo_empty(cmd_fifo_empty),
        .force_fifo_empty(force_fifo_empty), .inject_tear(inject_tear)
    );

    integer nfail, t, nstep;

    task issue;
        input we;
        input [3:0] a;
        input [31:0] w;
        begin
            @(posedge clk);
            while (!t2_ready) @(posedge clk);
            c_we = we; c_addr = a; c_wdata = w;
            c_req = 1;
            @(posedge clk);
            c_req = 0;
            t = 0;
            while (!t2_ack && t < 80) begin @(posedge clk); t = t + 1; end
            if (!t2_ack) begin nfail = nfail + 1; $display("FAIL ack timeout a=%0d", a); end
        end
    endtask

    initial begin
        nfail = 0; nstep = 0;
        c_req = 0; c_we = 0; c_addr = 0; c_wdata = 0;
        c_txn = 16'h22; c_gen = 16'h7;
        force_fifo_empty = 0; inject_tear = 0;
        repeat (4) @(posedge clk);
        rst_n = 1;
        repeat (2) @(posedge clk);

        // compaction order on dest: W0,W1,CRCW then readback, then COMMIT
        issue(1, 4'd1, 32'hAAAA0001);
        if (t2_err) begin nfail = nfail + 1; $display("FAIL W0"); end
        nstep = nstep + 1;
        issue(1, 4'd2, 32'hBBBB0002);
        issue(1, 4'd3, 32'hA5A50003);
        issue(0, 4'd1, 32'h0);
        if (t2_rdata !== 32'hAAAA0001) begin nfail = nfail + 1; $display("FAIL readback W0"); end
        issue(1, 4'd4, 32'hC0117ED0);
        issue(0, 4'd4, 32'h0);
        if (t2_rdata !== 32'hC0117ED0) begin nfail = nfail + 1; $display("FAIL COMMIT readback"); end

        // FIFO-empty must not ack
        force_fifo_empty = 1;
        @(posedge clk);
        while (!t2_ready) @(posedge clk);
        c_we = 1; c_addr = 4'd5; c_wdata = 32'h11110005; c_req = 1;
        @(posedge clk);
        c_req = 0;
        repeat (12) @(posedge clk);
        if (t2_ack) begin nfail = nfail + 1; $display("FAIL proxy ack"); end
        if (t2_ready) begin nfail = nfail + 1; $display("FAIL ready during dest"); end
        force_fifo_empty = 0;
        t = 0;
        while (!t2_ack && t < 40) begin @(posedge clk); t = t + 1; end
        if (!t2_ack) begin nfail = nfail + 1; $display("FAIL drain ack"); end

        if (nfail == 0) $display("FEM_T2_ADAPTER_XSIM_PASS dest-stall (not FEM_PERSIST_PASS)");
        else $display("FEM_T2_ADAPTER_XSIM_FAIL nfail=%0d", nfail);
        $finish;
    end
endmodule
