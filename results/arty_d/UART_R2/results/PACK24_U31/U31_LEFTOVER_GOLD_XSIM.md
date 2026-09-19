# U31 leftover GOLD hunt XSim — U1b/U7

Dest = `mig_ui_bram` (not `mig0`, not board).
PACK_ABI_24_24_PASS = NO.
No overlay. No program.

TB `UART_R2/u31/tb_u31_leftover_gold_hunt.sv` sha256 `3694467e7065b9bc99dc6ec886f903699bc3545fe8ae2b3a1cbc4dea9c8b42f1`.
Log `UART_R2/xsim_u31g/xsim.log` sha256 `f257f60b000836cb5ad08f715ce248d86b556ca40d28e702593fb82a0d72fab1`.
`$finish` 6610475 ns.

A first run missed `S_BUSY` (waited `st==6` after CLEAR TX already finished). That log is not this score. This file is the clean re-run only.

## L2 — pulse `rst100_tx_b_n` after Phase4 GOLD, no CLEAR

After GOLD handshake: `load_ack=1 ack_d=1 st_valid_ui=0 st_valid_100=0 req_a=1 last_b=1`.

Force `rst100_tx_b_n=0` for 8 clk100, release.

```
L2_WORD 1 010000a5
SCORE L2 GOLD_ONLY nw=1
```

FACT PASS_XSIM: TX CDC **b-reset replays GOLD from `hold`** without a new `load_ack` edge. Matches `word_cdc32` (`last_b` cleared, `req_a` still 1).

BUSY leftover does **not** assert `clr_ui_req`, so this path is **not** the leftover SAMPLE→BUSY RTL. ACK-path CLEAR **does** pulse `rst100_tx_b_n`. `tb_u31_two_v04` still expects ACK-only after GOLD and PASSed — ACK-path replay is **not** hit at 1 Mbaud BRAM.

Board `drain_idle` after Phase4 GOLD was n=0. Spontaneous L2 (b-reset while idle) did not happen on that campaign.

## L1 — `dest_stall` CLEAR + force `ack_d=0`

`dest_stall=1`, send CLEAR, force `ack_d=0` for 2 ui cycles while `load_ack` sticky.

```
L1_AFTER_FORCE ack_d=0 st_valid_ui=1
L1_WORD 1 c1ea50b5
L1_WORD 2 010000a5
SCORE L1 BUSY_THEN_GOLD_N8
```

FACT PASS_XSIM: **sufficient** leftover n=8: BUSY then GOLD. Mux priority orders them. GOLD source is `load_ack && !ack_d` (harness `st_valid_ui`).

`L1_AT_ACKV st=0 clr_ack_data=c1ea50a5` — join raced to IDLE; BUSY was still the first UART word. Force is not a live RTL event: leftover BUSY does not raise `debug_clear` / `rst_ui_pack_n`, so `ack_d` should stay 1 after Phase4.

## U1b / U7

| Mechanism | Shape | On BUSY leftover RTL? | This XSim |
|-----------|-------|------------------------|-----------|
| dest_stall only | BUSY n=4 | SAMPLE `!qsc` | prior dest_stall cell; no GOLD |
| force `ack_d=0` | BUSY then GOLD n=8 | no (`ack_d` tracks `load_ack`) | L1 |
| pulse TX CDC b-reset | GOLD without CLEAR | no (`clr_ui_req=0`) | L2 |
| ACK-path split-reset | ACK±GOLD | ACK-path only | contradicted by two_v04 ACK-only |

Board leftover GOLD source remains UNKNOWN. Do not overlay from force-`ack_d` or dest_ui_rdy.

Not PACK_ABI_24_24_PASS / BOARD_PASS / MIG_PASS.
