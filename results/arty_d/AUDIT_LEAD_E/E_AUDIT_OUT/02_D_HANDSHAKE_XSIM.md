# D after E experiment 1 — handshake XSim

AGENT_E `E_AUDIT_REPORT.md` §9.1 / H3.

RTL (live CANON_BLUEPRINT, **not** on programmed bit `bbba86c1`):

```
wr_valid = w_valid && !clr_take && !clr_hold
w_ready  = clr_take || (!clr_hold && fifo_wr_ready)
```

Commands:

```
cmd /c D:\FPGA\arty_d\pack_debug_clear\run_xsim_hold.bat
  -> PACK_HOLD_FLOOD_XSIM_PASS 2  HOLD_WR_MAX=0 used=0  finish 240195 ns
cmd /c D:\FPGA\arty_d\pack_debug_clear\run_xsim_uart.bat
  -> PACK_DEBUG_CLEAR_UART_XSIM_PASS 17  T10 PASS HOLD_WR_MAX=0  finish 16077475 ns
cmd /c D:\FPGA\arty_d\pack_abi24_mig_dut\run_xsim.bat
  -> PACK_ABI24_MIG_DUT_XSIM_PASS 24/24 finish 21965 ns
```

Not PACK_ABI_24_24_PASS. Not BOARD_PASS. Board not used. `board_lease` FREE.
