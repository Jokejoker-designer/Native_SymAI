# U31 INDEPENDENT HANDOFF — PACK_ABI_24_24_PASS

OWNER_FROM: AGENT_D (this session)
REQUEST: independent analysis of GAPS + UNKNOWNS. Do not accept this file’s INFERENCE as proof.
DATE: 2026-09-19T02:15+07
RUN_ID: 20260918T191530Z
SRAM: U31 candidate bit `08cbb85430060acafaeee2aa9d63948be1e460e70ee02f3ca56450a5a2cce28d`
JTAG: `210319BE776EA` End of startup HIGH (PROGRAM.txt)
UART: COM12 115200 FTDI `210319BE776EB`

PACK_ABI_24_24_PASS = NO
PROGRAM_PASS = NO
BOARD_PASS = NOT_EVIDENCED
TIMING_PASS = NO
MIG_PASS = NO
Do not patch U20–U30. Do not edit C RTL / identity H / freeze DCPs / Pack24 gold / PACKAGE live pack_mig_bind.

---

## What 24/24 requires (objective, not achieved)

1. Frozen identities preserved.
2. XSim GOLD-then-next-V04 class.
3. Bitstream hashed, exclusive program.
4. 24/24 CLEAR-V04 GOLD n=4.
5. Pack24 run1/run2/fresh dest-complete through pack_mig_bind.

---

## Evidence index (read these, not chat memory)

| ID | Path | What it is |
|----|------|------------|
| E1 | `UART_R2/results/PACK24_U31/U31_XSIM.md` | leftover + four V-04 PASS_XSIM dest=`mig_ui_bram` |
| E2 | `UART_R2/build_u31/SHA256.txt` | bit/DCP hashes, LUT/FF, WNS +0.503 WHS +0.026 |
| E3 | `UART_R2/build_u31/PROGRAM.txt` | exclusive program SHA match, PROGRAM_PASS=NO |
| E4 | `UART_R2/results/PACK24_U31/BOARD_BASELINE_NWP4P5_FIRST_N0.json` | nwp4p5 after 12s settle: CLEAR n=0 ×3 |
| E5 | `UART_R2/results/PACK24_U31/CLEAR_V04_24_P4P5_BUSY_LEFTOVER.json` | 02:08 warmup BUSY n=4, CLEAR ACK, V-04 GOLD n=4, p5 r0 n=8 BUSY+GOLD |
| E6 | `UART_R2/results/PACK24_U31/BOARD_BASELINE.json` | reprogram 02:13: ACK after reopen, V-04 n=0 12.007s |
| E7 | `UART_R2/results/PACK24_U31/CLEAR_V04_24.json` | 02:15 SRAM retry: Phase4 GOLD then p5 r0 leftover BUSY+GOLD then V-04 n=0 |
| E8 | `UART_R2/u31/pack_debug_clear.sv` | ui_req/cdc_rst without S_ACK |
| E9 | `UART_R2/u31/pack_clear_ui.sv` | S_DRAIN 64 then debug_clear |
| E10 | `UART_R2/u31/pack_mig_bind.sv` | qsc AND dest_ui_rdy (not mux a_rdy) |
| E11 | `UART_R2/u31/arty_a7_r2_top_m4_mig_candidate.sv` | TX mux: clr_ack preempts st_valid_100 GOLD |
| E12 | `UART_R2/results/PACK24_U30/U30_FAIL.md` | prior: 2 GOLD then r1 V-04 n=0 |

XSim dest ≠ board dest. XSim used `mig_ui_bram`. Board uses generated `mig0`.

---

## GAPS (requirement vs evidence)

G1. **24/24 CLEAR-V04 GOLD n=4** — missing. Best observed: one GOLD per successful Phase4, then fail at p5 r0. Never 24 GOLD. Never even 2 GOLD in one campaign on U31 (U30 had Phase4+r0).

G2. **Pack24 run1/run2/fresh dest-complete** — missing. No PACK24_RUN*.jsonl under PACK24_U31.

G3. **XSim vs board dest** — XSim four GOLD is `mig_ui_bram`. Board hang/BUSY is `mig0`. No XSim of U31 leftover+four V-04 through generated mig0 / UI model of app_rdy backpressure.

G4. **qsc uses dest_ui_rdy** — implemented in overlay; whether board `app_rdy`/`app_wdf_rdy` after CLEAR is the BUSY cause is **not measured** (no ILA, no probe of those nets).

G5. **Drop debug_clear before ACK TX** — RTL intent (E8). Board still produces ACK then V-04 n=0 (E6) and GOLD then next V-04 n=0 (E7). Overlay did not close 24/24. Causal link unproven.

G6. **Host BUSY retry** — `u31_campaign.py` now retries BUSY / leftover n>4. That is host protocol, not silicon dest-complete. 24/24 still fail. Do not treat retry as PACK_ABI_24_24_PASS.

G7. **Git provenance** — `D:\FPGA`, PACKAGE tree, `arty_d`, `NATIVE_AI` are **not git repositories** (rev-parse exit 128). No commit hash for U31 overlay.

G8. **PROGRAM.DONE / IR.STATUS** — PROGRAM.txt records NA. End of startup HIGH is Labtools 27-3164 only.

---

## UNKNOWNS (independent analysis required)

Do not promote these to FACT.

U1. After GOLD n=4, why is the next CLEAR `n=8` `b550eac1a5000001` (BUSY then GOLD) in one UART chunk? Candidates to **disprove**: TX mux preemption of pending `st_valid_100`; second `load_ack` edge; CDC TX word surviving CLEAR; host read-raw 50ms idle concatenating two replies; uart_tx_word non-atomic mux switch.

U2. Why does V-04 after that leftover/BUSY storm return **n=0 for 12s** (no GOLD, no NAK, no BUSY)? Same class as U29/U30 dest hang or a different mute (RX lock, pack_lock, MIG calib, ui_busy stuck)?

U3. Why is first exclusive nwp4p5 **CLEAR n=0** (E4) while a later p4p5 on the same SRAM (E5) got ACK+GOLD? First-ACK-miss after JTAG vs qsc=0 vs FTDI? E6 after **reprogram** still needed reopen to ACK then V-04 n=0 — not only “cold SRAM”.

U4. Why is CLEAR often **BUSY n=4** (`c1ea50b5`) immediately after JTAG/warmup? Which term of `pack_quiescent` is false: `loader_busy`, `ui_busy`, `wr_outstanding`, `rst_loc`, `debug_clear`, `dest_ui_rdy`, `dest_ui_wdf_rdy`, or `qsc_100` extras (`cdc_a_idle`, `tx_b_idle`, `st_valid_100`, `uart_tx_valid`)? **No on-chip sample.**

U5. `pack_clear_ui` holds `debug_clear=1` until `!req`. 100-side `ui_req` drops only after S_QUIET→S_ACK. How many ui_clk cycles is dest in reset **after** host has seen ACK? Cross-domain measurement missing.

U6. Does `mig0` `app_rdy` go 0 for long enough after a pack/CLEAR that qsc is sticky BUSY, while `mig_ui_bram` in XSim does not?

U7. Does RESET of `rst_ui_pack_n` / `word_cdc32` on CLEAR **inject a spurious GOLD** (`load_ack && !ack_d` first cycle out of reset)? Not proven. Would explain repeating BUSY+GOLD every CLEAR (seen once on wedged SRAM, not on E5 first leftover only).

U8. `ui_busy` / `wr_outstanding` after GOLD: is GOLD (`load_ack`) allowed **before** dest drain complete? If yes, host GOLD is not dest-complete. Objective requires dest-complete through pack_mig_bind.

U9. Alternating BUSY n=4 and CLEAR n=0 (E6, E7 retries): UART PHY drop vs SAMPLE qsc vs flush killing RX? UNKNOWN.

U10. Whether a longer post-JTAG wait (MIG calib) would change E6 V-04 n=0. Not tested this session after the 17s settle that still n=0.

---

## Claims classification (author)

| Claim | Class |
|-------|--------|
| U31 bit sha `08cbb854…` programmed End of startup HIGH | FACT |
| XSim leftover+four GOLD dest=BRAM | FACT PASS_XSIM |
| Board 24/24 | FAIL (not run to completion; stopped r0) |
| UART PHY can emit GOLD on this bit | FACT (E5, E7 Phase4) |
| AXI UART would fix 24/24 | CONTRADICTED (prior U30; GOLD exists) |
| mux a_rdy must not be qsc | FACT in XSim (first leftover FAIL CLEAR BUSY); board relevance INFERENCE |
| TX mux CLEAR preempts GOLD | FACT in RTL (E11); cause of n=8 leftover HYPOTHESIS |
| dest hang is mig0 outstanding | HYPOTHESIS |
| U31 overlay closed dest-in-reset-during-ACK | UNKNOWN / not sufficient (E6 ACK then n=0) |

---

## Constraints for the independent analyst

- Do not stamp PACK_ABI_24_24_PASS / PROGRAM_PASS / BOARD_PASS / MIG_PASS / TIMING_PASS.
- Do not modify AGENT_C RTL, identity H, freeze DCPs, Pack24 gold.
- Do not patch frozen U20–U30.
- Prefer a **smallest decisive experiment** that distinguishes U1–U10, not another overlay guess.
- Search for evidence **against** “dest hang” and **against** “UART leftover mux”.
- If ILA/probe is proposed: GRANT/program policy still D programs, E does not.

---

## Smallest experiments (suggestions, not ordered as truth)

S1. XSim U31 leftover TB but force `dest_ui_rdy` low for N cycles after GOLD; expect BUSY then ACK; must not emit second GOLD unless RTL does.

S2. XSim CLEAR during `st_valid_100=1` GOLD; capture mux order BUSY vs GOLD vs n=8.

S3. Board: after Phase4 GOLD, drain RX to idle **without** CLEAR; hex dump leftover; then one CLEAR. Distinguishes leftover-in-UART vs CLEAR-generated GOLD.

S4. Board: ILA or bring-up bits on `pack_quiescent` terms and `load_ack`/`st_valid_ui` around GOLD→CLEAR. Needs owner if new bit.

S5. Do not call host WAIT_AFTER_GOLD dest-complete. If used, label HOST_WAIT not silicon law.
