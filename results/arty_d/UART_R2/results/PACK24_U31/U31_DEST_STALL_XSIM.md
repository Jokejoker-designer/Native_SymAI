# U31 dest_stall XSim — independent S5

Dest = `mig_ui_bram` (not `mig0`, not board).
PACK_ABI_24_24_PASS = NO.

TB `UART_R2/u31/tb_u31_dest_stall_clear.sv` (scratch). Does not patch U30 / two_v04 / C / H / gold.

## Procedure
1. CLEAR ACK + PA24-V-04 GOLD (same as two_v04 first pack).
2. `dest_stall=1` → `mig_ui_bram` `app_rdy`/`app_wdf_rdy` = 0.
3. One CLEAR. Capture all UART words (~2 ms window, 8 slots).

## Result — FACT PASS_XSIM of this cell only
```
PHASE4_GOLD qsc_ui=1 d_rdy=1 d_wdf=1
AFTER_STALL qsc_ui=0 qsc_100=0 d_rdy=0 d_wdf=0
CLEAR_WORD 1 c1ea50b5
UART_R2_U31_DEST_STALL_SCORE BUSY_N4_NO_GOLD
$finish 4513945 ns
```

Log: `D:/FPGA/arty_d/UART_R2/xsim_u31s/` (xvlog/xelab/xsim, exit 0).

## Interpretation (analyst table)
BUSY n=4, no second GOLD ⇒ dest-ready qsc explains **U1a**. Mux pending-GOLD **(A) fails this cell**. Board n=8 leftover GOLD is **not** dest_stall on BRAM.

Does not measure `mig0 app_rdy`. Does not explain board leftover GOLD source (U1b/U1c). Does not close 24/24.
