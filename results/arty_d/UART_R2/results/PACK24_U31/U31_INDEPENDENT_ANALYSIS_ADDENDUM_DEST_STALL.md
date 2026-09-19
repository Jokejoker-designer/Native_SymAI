# Purple merge — dest_stall XSim scored

```
PATTERN     = sequential merge + adversarial (Ch.10 execution feedback)
ROLES       = lead-orchestrator (this) + independent analyst report + XSim log
AUTHORITY   = READ_ONLY_AUDIT | REPORT_ONLY | VERIFY_ONLY
ONE_WRITER  = this session (analysis md only)
SPAWN_X16   = NO (linear; new information is the xsim.log, not another debate)
PACK_ABI_24_24_PASS = NO
PROGRAM_PASS        = NO
BOARD_PASS          = NOT_EVIDENCED
```

Parent confirmation was **not** treated as proof. Primary evidence: `u31/tb_u31_dest_stall_clear.sv`, `xsim_u31s/xsim.log`, `top.sv:86-87,230-232`, bit re-hash.

BIT SHA256 (this run) = `08cbb85430060acafaeee2aa9d63948be1e460e70ee02f3ca56450a5a2cce28d`  
TB SHA256 = `c77172b1479ad315c0dea70b8b9a09b9d7283d9a8e921e9bcb8305266c8af998`

---

## Cell result (FACT PASS_XSIM of this cell only)

From `xsim_u31s/xsim.log:28-33`:

```
PHASE4_GOLD qsc_ui=1 d_rdy=1 d_wdf=1
AFTER_STALL qsc_ui=0 qsc_100=0 d_rdy=0 d_wdf=0
CLEAR_WORD 1 c1ea50b5
UART_R2_U31_DEST_STALL_SCORE BUSY_N4_NO_GOLD
UART_R2_U31_DEST_STALL_XSIM_DONE nw=1 PACK_ABI_24_24_PASS=NO
$finish 4513945 ns
```

TB procedure matches the demanded cell (`tb_u31_dest_stall_clear.sv:112-163`): GOLD first with `dest_stall=0`, then `dest_stall=1`, 64 ui + 32 clk100 settle, one CLEAR, up to 8 UART words.

Does not patch U30 / two_v04 / leftover TB / C / H / gold. Dest = `mig_ui_bram`.

---

## (A)(B)(C) after the cell

| Claim | Audit | After dest_stall XSim |
|-------|--------|------------------------|
| (A) mux stole Phase4 GOLD → n=8 | WEAKENED | **Holds.** Cell = BUSY n=4, **no** second GOLD. Mux **priority** still FACT (`top.sv:390-395`). Pending GOLD does **not** explain board leftover n=8. |
| (B) dest/MIG is the **only** V-04 n=0 cause | WEAKENED / OPEN | **Holds.** E6 mute had no prior GOLD. U30 mute had no n=8. dest_stall did not test mute. |
| (C) CLEAR n=0 is only first-ACK-miss | CONTRADICTED | **Holds.** E7 n=0 interleaved with leftover n=8. |

XSim leftover CLEAR2 `c1ea50a5` (`xsim_u31l`) vs board `b550eac1a5000001` vs dest_stall `c1ea50b5` n=4: **three classes**. FACT.

---

## dest_accept (competing mute)

RTL matches the citation (`top.sv:86-87,230-232` and `harness.sv:47-48,162-164`):

```systemverilog
wire dest_accept = qsc_c1 && rst100_pack_n;
wire steer_pack = pack_lock || (f_valid && pack_begin && dest_accept);
assign f_ready = q_taking ? qh_in_ready :
                 (steer_pack ? cdc_a_ready :
                  ((f_valid && pack_begin && !dest_accept) ? 1'b0 : 1'b1));
```

BEGIN while `dest_accept=0` holds the FIFO; host can see 12 s n=0 with no NAK. That is **HYPOTHESIS** as the board mute path, competing with dest-hang / RX. **Not FACT.** dest_stall XSim did not send V-04 after stall.

---

## U1–U10

- **U1a:** PASS_XSIM on BRAM stall (dest not ready → BUSY n=4). `mig0 app_rdy` still unmeasured.
- **U1b/U1c:** UNKNOWN. dest_stall did **not** produce leftover GOLD. Board n=8 is a **separate bug** from dest-ready qsc.
- **U2–U10:** unchanged from the independent audit. Overlay “drop clear before ACK” is not sufficient (E6/E7). U31 never two GOLD in one campaign; U30 had two.

---

## What this merge will not do

- No new overlay from `dest_ui_rdy` / qsc AND.
- No reprogram.
- No `PROGRAM_PASS` / `BOARD_PASS` / `PACK_ABI_24_24_PASS`.
- Pack1/2/3 still missing.

---

## Remaining open (two classes)

1. **Leftover board n=8** — GOLD source on BUSY CLEAR (U1b/U1c). Not dest-ready qsc.
2. **Mute ACK → V-04 n=0** — dest_accept hold vs dest hang vs RX. No closing experiment yet.

Next smallest scratch TB (no overlay, no program): after ACK-path CLEAR, `dest_stall=1`, send V-04; score mute vs GOLD vs NAK. That is the dest_accept analog of this cell. Leftover GOLD still needs a GOLD-source TB or ILA (new bit, D programs).

Adversarial limits of dest_stall: 1 Mbaud not 115200; BRAM not `mig0`; 2 ms window not 12 s mute; does not prove board BUSY **is** `app_rdy=0`.
