# Purple merge — dest_accept mute split + leftover GOLD hunt

```
PATTERN     = sequential merge + adversarial (Ch.10 execution feedback)
ROLES       = lead-orchestrator (this) + independent audit + xsim_u31m + xsim_u31g
AUTHORITY   = READ_ONLY_AUDIT | REPORT_ONLY | VERIFY_ONLY
ONE_WRITER  = this session (analysis md only)
SPAWN_X16   = NO
PACK_ABI_24_24_PASS = NO
PROGRAM_PASS        = NO
BOARD_PASS          = NOT_EVIDENCED
MIG_PASS            = NO
```

Parent text was not treated as proof. Primary: TBs + `xsim.log`. Bit re-hash this run `08cbb85430060acafaeee2aa9d63948be1e460e70ee02f3ca56450a5a2cce28d`. SRAM still that U31 candidate. No impl. No program. This merge re-hashed the four hunt artifacts; all MATCH the table. No XSim re-run. `SPAWN_X16=NO`.

THIS_RUN `20260918T201143Z` (`hashlib.sha256`, not recap): bit MATCH `08cbb854…`. Hunt TB/log MATCH `U31_LEFTOVER_GOLD_XSIM.md`. dest_accept TB/log MATCH `U31_DEST_ACCEPT_XSIM.md`. `PROGRAM.txt` SHA256 same bit; SRAM still that U31 candidate. No overlay. No program.

| Artifact | SHA256 | THIS_RUN |
|----------|--------|----------|
| `tb_u31_leftover_gold_hunt.sv` | `3694467e7065b9bc99dc6ec886f903699bc3545fe8ae2b3a1cbc4dea9c8b42f1` | MATCH leftover md |
| `xsim_u31g/xsim.log` | `f257f60b000836cb5ad08f715ce248d86b556ca40d28e702593fb82a0d72fab1` | MATCH leftover md; `$finish` 6610475 ns |
| `tb_u31_dest_accept_mute.sv` | `e614789fe86f63b359ccf5c60e4222f160e7dfdc7160dde87b6cdffb94607b87` | MATCH dest_accept md |
| `xsim_u31m/xsim.log` | `8c10dcc44cb251f9650dabe1ab64622cb41c4b30e04b030f30035bc4dcc943ef` | MATCH dest_accept md; `$finish` 28807465 ns |
| `build_u31/uart_r2_u31_candidate.bit` | `08cbb85430060acafaeee2aa9d63948be1e460e70ee02f3ca56450a5a2cce28d` | MATCH |

---

## (A)(B)(C) — unchanged as board claims

| Claim | Status |
|--------|--------|
| (A) mux stole Phase4 GOLD → board n=8 | **WEAKENED.** Mux priority FACT. dest_stall alone = BUSY n=4 no GOLD. L1 force `ack_d=0` **can** make n=8; that force is not live BUSY RTL. |
| (B) dest/MIG hang is the **only** V-04 n=0 cause | **WEAKENED / OPEN.** dest_accept hold is PASS_XSIM as a mute class. Hang is a second UART-identical class. |
| (C) CLEAR n=0 is only first-ACK-miss | **CONTRADICTED.** E7. |

Dest remains `mig_ui_bram` for all these cells. Not `mig0`. Not board.

---

## U2a — two mute classes, same UART

From `xsim_u31m/xsim.log:28-36`:

| Cell | UART | On-chip | Score |
|------|------|---------|--------|
| A ACK → dest_stall → V-04 | n=0, no NAK | `p_fire=0`, BEGIN `00800001`, `f_ready=0` | MUTE_PFIRE0 |
| A release stall, no re-TX | GOLD `010000a5` | `n_p=52 load_ack=1` | RECOVERY_GOLD |
| B stall after first `p_fire` | n=0, no NAK | `dn_p=51 load_ack=0` | HANG_PFIRE_GT0 |

Host json cannot tell A from B.

Adversarial limits: Cell A host wait in TB is 400000 clk100 (~4 ms), not 12 s. RECOVERY_GOLD is the discriminator: if dest becomes ready inside the wait, A emits GOLD without re-TX. Board 12 s n=0 after ACK is A **only if** `app_rdy` stayed 0 the whole window. Otherwise B. U30 r1 (two GOLD then n=0) is INFERENCE toward B (A-that-releases is ruled out; A-stuck vs B remain).

**Overlay guard:** do not drop `dest_ui_rdy` from `dest_accept` to “fix” A. BEGIN would enter a dest that is not ready and become B.

---

## U1b — leftover n=8

From `xsim_u31g/xsim.log:28-37` plus prior dest_stall cell:

| Mechanism | Shape | On BUSY leftover RTL? | Score |
|-----------|-------|------------------------|--------|
| dest_stall only | BUSY n=4 | SAMPLE `!qsc` | BUSY_N4_NO_GOLD |
| force `ack_d=0` while `load_ack` sticky | BUSY then GOLD n=8 | **no** (`ack_d` tracks `load_ack`; BUSY does not `debug_clear`) | L1 BUSY_THEN_GOLD_N8 |
| pulse `rst100_tx_b_n` after GOLD, no CLEAR | GOLD_ONLY | **no** (`clr_ui_req=0` on BUSY) | L2 GOLD_ONLY |
| ACK-path split-reset | ACK±GOLD | ACK-path only | contradicted by two_v04 ACK-only |

L1_AT_ACKV `st=0 clr_ack_data=c1ea50a5` — join raced; first UART word was still BUSY. Force is **sufficient** for the board leftover **shape**, not a silicon cause.

Board leftover GOLD source remains UNKNOWN. Do not overlay from force-`ack_d` or dest_ui_rdy.

---

## What this merge will not do

- No overlay of `dest_ui_rdy` / `dest_accept`.
- No reprogram. No Vivado impl.
- No `PROGRAM_PASS` / `BOARD_PASS` / `PACK_ABI_24_24_PASS` / `MIG_PASS`.
- Pack1/2/3 still missing.

---

## Next 24/24 step

Still no overlay of `dest_rdy` / `dest_accept`. BRAM does not model `mig0` outstanding. Board mute class needs `p_fire` / BEGIN-at-FIFO or ILA, or a hang TB on generated `mig0`.

Leftover GOLD on silicon remains UNKNOWN. No overlay from force. ILA `load_ack` / `ack_d` / `st_valid_100` would be a new bit (D programs) — not this merge.
