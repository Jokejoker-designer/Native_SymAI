from pathlib import Path

src = Path(r"D:\FPGA\arty_d\UART_R2\u12\tb_u12_targeted.sv").read_text(encoding="utf-8")
src = src.replace("tb_u12_targeted", "tb_u14_targeted")
src = src.replace("UART_R2_U12", "UART_R2_U14")
src = src.replace("TX U10", "TX U14")

old = """  logic tx_valid, tx_ready, tx_flush, tx;
  logic [31:0] tx_data;
"""
new = """  logic tx_valid, tx_ready, tx_flush, tx;
  logic [31:0] tx_data;
  logic mux_en;
  logic tx_valid_drv, tx_flush_drv, ack_ready_drv;
  logic [31:0] tx_data_drv;
"""
if old not in src:
    raise SystemExit("decl block missing")
src = src.replace(old, new, 1)

marker = """  pack_clear_ui u_ui (
    .clk, .rst_n, .req(ui_req), .pack_quiescent(pack_qsc),
    .ack(ui_ack), .nack(ui_nack), .debug_clear
  );
"""
assign = marker + """
  assign tx_valid = mux_en ? ack_valid : tx_valid_drv;
  assign tx_data  = mux_en ? ack_data  : tx_data_drv;
  assign tx_flush = mux_en ? uart_flush : tx_flush_drv;
  assign ack_ready = mux_en ? (tx_ready && !uart_flush) : ack_ready_drv;
"""
if marker not in src:
    raise SystemExit("ui marker missing")
src = src.replace(marker, assign, 1)

src = src.replace("tx_valid =", "tx_valid_drv =")
src = src.replace("tx_valid <=", "tx_valid_drv <=")
src = src.replace("tx_data =", "tx_data_drv =")
src = src.replace("tx_data <=", "tx_data_drv <=")
src = src.replace("tx_flush =", "tx_flush_drv =")
src = src.replace("tx_flush <=", "tx_flush_drv <=")
src = src.replace("ack_ready =", "ack_ready_drv =")
src = src.replace("ack_ready <=", "ack_ready_drv <=")

src = src.replace(
    "    rst_n = 1'b0;\n",
    "    mux_en = 1'b0;\n    rst_n = 1'b0;\n",
    1,
)

old3 = """    if (u_tx.st != 2'd0 || tx !== 1'b1)
      tfail($sformatf("T3 idle flush started frame st=%0d tx=%0b", u_tx.st, tx));
    else
      tpass("T3 idle flush no frame");
"""
new3 = """    if (u_tx.st != 2'd0 || tx !== 1'b1)
      tfail($sformatf("T3 idle flush started frame st=%0d tx=%0b", u_tx.st, tx));
    else
      tpass("T3 idle flush no frame");
    if (tx_ready)
      tfail("T3 idle flush w_ready=1 (would drop ACK)");
    else
      tpass("T3 idle flush w_ready=0");
"""
if old3 not in src:
    raise SystemExit("T3 block missing")
src = src.replace(old3, new3, 1)

old9 = """    $display("COUNTERS mag=%0d unsup=%0d n0=%0d timeout=%0d phantom=%0d trunc=%0d shift=%0d warn=%0d",
"""
new9 = """    mux_en = 1'b1;
    pack_qsc = 1'b1;
    uart_mark = 1'b1;
    pulse_cmd;
    recv_tx_word(30000 + 80 * DIV, nbyte, tw);
    if (nbyte != 4 || tw != ACK) begin
      tfail($sformatf("T10 product mux ACK nbyte=%0d tw=%08h", nbyte, tw));
      n0_n = n0_n + 1;
    end else
      tpass("T10 CLEAR ACK on UART via product mux");
    mux_en = 1'b0;
    c = 0;
    while (c < 70000 && hold) begin
      @(posedge clk);
      c = c + 1;
    end

    $display("COUNTERS mag=%0d unsup=%0d n0=%0d timeout=%0d phantom=%0d trunc=%0d shift=%0d warn=%0d",
"""
if old9 not in src:
    raise SystemExit("counters marker missing")
src = src.replace(old9, new9, 1)

out = Path(r"D:\FPGA\arty_d\UART_R2\u14\tb_u14_targeted.sv")
out.write_text(src, encoding="utf-8")
print("wrote", out)
