# U31 S_REQ→nack leftover — live RTL (not force)

Dest = `mig_ui_bram` (not `mig0`, not board).
PACK_ABI_24_24_PASS = NO.
Does not overlay dest_ui_rdy / dest_accept. Does not patch U31.

TB `UART_R2/u31/tb_u31_sreq_nack_leftover.sv`
Log `UART_R2/xsim_u31r/xsim.log`
`$finish` 4553325 ns

## Procedure
1. CLEAR ACK + PA24-V-04 GOLD (`req_a=1 last_b=1`).
2. Send CLEAR with `dest_stall=0` so SAMPLE sees `qsc_100=1` → **S_REQ**.
3. On first cycle of S_REQ, `dest_stall=1` so `pack_clear_ui` nacks.
4. Score UART words. No `force ack_d`. No `force rst100_tx_b_n`.

## Result — FACT PASS_XSIM of this cell
```
AT_SREQ st=2 ui_req=0 rst100_tx_b_n=1 qsc_ui=1 qsc_100=1
AFTER_NACK_WIN st_valid_100=1
CLR2_WORD 1 c1ea50b5
CLR2_WORD 2 010000a5
SCORE BUSY_THEN_GOLD_N8
```

S_REQ asserts `ui_req` (registered). `rst100_tx_b_n <= ~clr_ui_req` resets TX CDC b-side while a-side `req_a`/`hold` still GOLD (`debug_clear` never rises on nack). b-side release on S_BUSY **replays GOLD**. Mux orders BUSY then GOLD.

This is the leftover **shape** on **live** U31 RTL. dest_stall-only (SAMPLE `!qsc` → S_BUSY, no `ui_req`) is BUSY n=4 **without** GOLD. L1 force `ack_d` is a different sufficient generator.

Board leftover **may** be this race (stale `qsc_c1` at SAMPLE then dest not ready). Not proven on `mig0`.

U32 overlay: `rst100_tx_b_n <= ~cdc_rst_100` (S_CDC|S_QUIET only). S_REQ probe must not reset TX CDC.

Not PACK_ABI_24_24_PASS.
