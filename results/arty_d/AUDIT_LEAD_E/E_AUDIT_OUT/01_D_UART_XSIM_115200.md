# D measurement — UART XSim BAUD=115200

Not an E conclusion. Not PACK_ABI_24_24_PASS. Not BOARD_PASS.

Command:

```
cmd /c D:\FPGA\arty_d\pack_debug_clear\run_xsim_uart_115200.bat
```

TB: `D:\FPGA\arty_d\pack_debug_clear\tb_pack_debug_clear_115200.sv` (copy; CANON_BLUEPRINT TB unchanged, still BAUD=1_000_000).

DUT UART modules: live `uart_rx_word.sv` / `uart_tx_word.sv` default BAUD=115200.

Dest model: `mig_ui_bram` (not generated `mig0`).

Result FACT:

```
PACK_DEBUG_CLEAR_UART_XSIM_PASS 15 (not PACK_ABI_24_24_PASS)
$finish called at time : 126203745 ns
xsim elapsed = 00:00:26
```

Compare 1 Mbaud UART TB: PASS 15, finish 15781665 ns.

Board live bit `bbba86c1` campaign: pack_ok=2/5, CLEAR got=None from S-02. Not re-run this turn. Board lease FREE, dispatcher AGENT_E.
