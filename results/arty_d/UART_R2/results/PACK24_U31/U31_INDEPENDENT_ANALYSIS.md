# U31 INDEPENDENT ANALYSIS — GAPS / UNKNOWNS after FAIL 24/24

```
ANALYST            = independent cold read (this session)
AUTHORITY          = READ_ONLY_AUDIT | REPORT_ONLY
DATE               = 2026-09-19
SRAM / BIT_SHA256  = 08cbb85430060acafaeee2aa9d63948be1e460e70ee02f3ca56450a5a2cce28d
JTAG               = 210319BE776EA  End of startup HIGH (Labtools 27-3164)
UART               = COM12 115200 (host json only; this run did not open COM)
PACK_ABI_24_24_PASS = NO
PROGRAM_PASS        = NO
BOARD_PASS          = NOT_EVIDENCED
TIMING_PASS         = NO
MIG_PASS            = NO
SPAWN_X16           = NO
```

**PACK_ABI_24_24_PASS is not achieved.**

This file does not treat `U31_INDEPENDENT_HANDOFF.md` INFERENCE as proof. Parent U1–U10 and session-recap interpretations were attacked against primary json, RTL, XSim logs, Vivado reports, and independently recomputed hashes. No Arty program. No edit of C RTL, identity H, freeze DCPs, Pack24 gold, PACKAGE live `pack_mig_bind`, or frozen U20–U30. No new overlay.

Original cold read did not start XSim. **Sequential merge (Ch.10):** new information is only `xsim_u31m/xsim.log` and `xsim_u31g/xsim.log` (plus their TBs). This merge did **not** re-run XSim, impl, or program. Hashes re-verified. `SPAWN_X16=NO`.

A prior draft already sat at this path. It was **not** used as evidence. Claims below are from the files listed in §0.

Handoff claims under attack:

| ID | Claim | Independent verdict |
|----|--------|---------------------|
| (A) | TX mux CLEAR-preempts-GOLD is the **cause** of leftover n=8 | **WEAKENED** as pending-Phase4-GOLD. Mux **priority** is FACT. Cause of the extra GOLD word is UNKNOWN. |
| (B) | dest/MIG hang is the **cause** of V-04 n=0 | **WEAKENED** as the unique cause. dest_accept hold is PASS_XSIM as a UART-identical mute class (Cell A). Hang is Cell B. Board which-one UNKNOWN. |
| (C) | first-ACK-miss is the **only** CLEAR n=0 class | **CONTRADICTED** |

---

## 0. What was actually read

| ID | Path | This run |
|----|------|----------|
| Handoff | `D:\FPGA\arty_d\UART_R2\results\PACK24_U31\U31_INDEPENDENT_HANDOFF.md` | full (claims, not proof) |
| E1 | `...\PACK24_U31\U31_XSIM.md` + `UART_R2\xsim_u31l\xsim.log` + `xsim_u31t\xsim.log` | full |
| E2 | `build_u31\SHA256.txt` + independent SHA256 of bit/DCP + `reports\timing_route.rpt` + `util_route.rpt` | full; hashes match |
| E3 | `build_u31\PROGRAM.txt` + `program.log` + `program_49924.backup.log` | full |
| E4 | `BOARD_BASELINE_NWP4P5_FIRST_N0.json` | full |
| E5 | `CLEAR_V04_24_P4P5_BUSY_LEFTOVER.json` | full |
| E6 | `BOARD_BASELINE.json` | full |
| E7 | `CLEAR_V04_24.json` + `RAW_UART\p5_c00.json` + `p5_v00.json` | full |
| E8 | `u31\pack_debug_clear.sv` | full (160 lines) |
| E9 | `u31\pack_clear_ui.sv` | full (90 lines) |
| E10 | `u31\pack_mig_bind.sv` | full (77 lines) |
| E11 | `u31\arty_a7_r2_top_m4_mig_candidate.sv` | full; TX mux / `qsc_100` at 343–404 |
| E12 | `PACK24_U30\U30_FAIL.md` + `PACK24_U30\CLEAR_V04_24.json` | full |
| Extra | `u31_campaign.py`, `u9\uart_r2_u9_board_test.py` `read_raw_stamped`, `u14\uart_tx_word.sv`, PACKAGE `word_cdc32.sv`, PACKAGE `pack_loader.sv`, PACKAGE `mig_ui32.sv`, PACKAGE `mig_ui_bram.sv`, `u31\tb_u31_*.sv`, `pack_uart_dualclk_harness.sv`, `u30\pack_mig_bind.sv`, `run_tb_u31.bat`, `build_u31\uart_r2_u31.xpr` | cited regions |
| E13 | `u31\tb_u31_dest_accept_mute.sv` + `xsim_u31m\xsim.log` + `U31_DEST_ACCEPT_XSIM.md` | sequential merge; not re-run |
| E14 | `u31\tb_u31_leftover_gold_hunt.sv` + `xsim_u31g\xsim.log` + `U31_LEFTOVER_GOLD_XSIM.md` | sequential merge; not re-run |

Not observed: ILA, `app_rdy`/`app_wdf_rdy`, any `pack_quiescent` term on silicon. Not re-run this merge: XSim, impl, program, COM.

Independent SHA256 this run (`hashlib.sha256`):

| File | SHA256 |
|------|--------|
| `build_u31\uart_r2_u31_candidate.bit` | `08cbb85430060acafaeee2aa9d63948be1e460e70ee02f3ca56450a5a2cce28d` |
| `build_u31\post_route.dcp` | `72855dfe7feeae1c2b6e0c3cafbe296b2fb4f5d19bdfb4c56c3435f13ffc371d` |
| `u31\pack_debug_clear.sv` | `8801a2edb46432d6301a7f3b2196757e96b3d760baa918f5f3d4b52bb1d01935` |
| `u31\pack_clear_ui.sv` | `a2f023cb6253de0be1b6a51fca3842b77e72c7e69f2bd2f4812c4f635176858e` |
| `u31\pack_mig_bind.sv` | `72e4b8e3c485586411e718ba597e3d262888cb59e3144b57b15dd681d603869c` |
| `u31\arty_a7_r2_top_m4_mig_candidate.sv` | `2c9cc1b1edc8e44cc1126732cb561125c308a38ea1440bea70163a67314bdf02` |
| `u31\u31_campaign.py` | `cb7706e2361d07b8672252062488693bbc573fbfadcc64dabf4214fe24afc274` |
| `u31\tb_u31_dest_accept_mute.sv` | `e614789fe86f63b359ccf5c60e4222f160e7dfdc7160dde87b6cdffb94607b87` |
| `xsim_u31m\xsim.log` | `8c10dcc44cb251f9650dabe1ab64622cb41c4b30e04b030f30035bc4dcc943ef` |
| `u31\tb_u31_leftover_gold_hunt.sv` | `3694467e7065b9bc99dc6ec886f903699bc3545fe8ae2b3a1cbc4dea9c8b42f1` |
| `xsim_u31g\xsim.log` | `f257f60b000836cb5ad08f715ce248d86b556ca40d28e702593fb82a0d72fab1` |

Hunt TB/log hashes match `U31_LEFTOVER_GOLD_XSIM.md`. Bit re-hash this merge: `08cbb85430060acafaeee2aa9d63948be1e460e70ee02f3ca56450a5a2cce28d`. SRAM still that U31 candidate.

THIS_RUN `20260918T201143Z` (`hashlib.sha256`, not recap; no XSim re-run; no program):

| File | THIS_RUN SHA256 | vs leftover / dest_accept md |
|------|-----------------|------------------------------|
| `build_u31\uart_r2_u31_candidate.bit` | `08cbb85430060acafaeee2aa9d63948be1e460e70ee02f3ca56450a5a2cce28d` | MATCH want |
| `build_u31\post_route.dcp` | `72855dfe7feeae1c2b6e0c3cafbe296b2fb4f5d19bdfb4c56c3435f13ffc371d` | MATCH SHA256.txt |
| `u31\tb_u31_leftover_gold_hunt.sv` | `3694467e7065b9bc99dc6ec886f903699bc3545fe8ae2b3a1cbc4dea9c8b42f1` | MATCH leftover md |
| `xsim_u31g\xsim.log` | `f257f60b000836cb5ad08f715ce248d86b556ca40d28e702593fb82a0d72fab1` | MATCH leftover md |
| `u31\tb_u31_dest_accept_mute.sv` | `e614789fe86f63b359ccf5c60e4222f160e7dfdc7160dde87b6cdffb94607b87` | MATCH dest_accept md |
| `xsim_u31m\xsim.log` | `8c10dcc44cb251f9650dabe1ab64622cb41c4b30e04b030f30035bc4dcc943ef` | MATCH dest_accept md |

`PROGRAM.txt` SHA256 same bit. SRAM still that U31 candidate. `SPAWN_X16=NO`. No overlay.

Git: `git rev-parse` exit 128 on `D:\FPGA`, `D:\FPGA\arty_d`, `D:\FPGA\arty_d\UART_R2`, and the PACKAGE tree. No commit hash.

No `PACK24_RUN*.jsonl` under `PACK24_U31`.

---

## 1. Classification (independent)

### FACT

1. Bit and DCP hashes on disk match E2/E3/handoff. Recomputed this run.
2. Routed design `arty_a7_r2_top_m4_mig_candidate` on `xc7a100t-csg324-1`: LUT 10556, FF 8899, RAMB36=3, RAMB18=2, DSP48E1=8 (`util_route.rpt` tables). WNS +0.503 ns, WHS +0.026 ns, TNS=0, THS=0 (`timing_route.rpt:139-141`). Report text: “All user specified timing constraints are met.” That is **not** a `TIMING_PASS` stamp.
3. Two exclusive programs of this SHA: `program_49924.backup.log` and `program.log`. Both: target `210319BE776EA` / `xc7a100t_0`, `Labtools 27-3164 End of startup status: HIGH`, `IR.STATUS=NA PROGRAM.DONE=NA`, “no supported soft debug core(s)” (`program.log:54-58`).
4. `PROGRAM.txt` / `SHA256.txt` write `PROGRAM_PASS=NO`, `PACK_ABI_24_24_PASS=NO`.
5. XSim logs on disk (not re-run): leftover PASS at 4893695 ns (`xsim_u31l\xsim.log:31-32`); four-GOLD PASS at 9666815 ns (`xsim_u31t\xsim.log:31-32`). Both TBs use `pack_uart_dualclk_harness` dest `mig_ui_bram` (`harness.sv:4,201-206`; `run_tb_u31.bat:18,43`).
6. Leftover XSim CLEAR2 after GOLD+unlocked `00010001` is **ACK** `c1ea50a5`, not BUSY (`xsim_u31l\xsim.log:29`; TB requires ACK at `tb_u31_leftover_op01.sv:149-158`). two_v04 sends CLEAR immediately after GOLD and requires ACK (`tb_u31_two_v04.sv:136-138`). Board after GOLD is **not** that reply.
7. E4 nwp4p5 after settle: CLEAR n=0 ×3 including reopen (`BOARD_BASELINE_NWP4P5_FIRST_N0.json`).
8. E5 ~02:08 same SRAM: WARMUP BUSY n=4 `b550eac1`; CLEAR1 ACK n=4; V-04 GOLD n=4 `a5000001` (`word=010000a5`); next CLEAR n=8 `b550eac1a5000001`, classified BUSY from first 4 bytes. Chunks 1+7 at `t_first_s == t_last_s == 0.0045`. No `V04_0_DRAIN` rec. Campaign `stop=CLEAR` round 0.
9. E6 after 02:13 reprogram: warmup n=0; BUSY/n=0 mix; reopen ACK; V-04 n=0 for 12.007 s. **No GOLD** on that program before mute.
10. E7 02:15 p4p5: Phase4 GOLD n=4; p5 r0 CLEAR n=8 BUSY+GOLD **repeated** (six n=8 recs) interleaved with CLEAR n=0 (~3.00–3.06 s); reopen ACK n=4 (`RAW_UART\p5_c00.json`); V-04 n=0 for 12.0395 s (`p5_v00.json`). Campaign `stop=V04` round 0.
11. Host `WAIT_AFTER_GOLD_S = 0.0`, `WAIT_AFTER_ACK_S = 0.0`, `drain_idle(..., 0.2)` after GOLD (`u31_campaign.py:42-43,163`). `drain_idle` appends a rec only if `n>0` (`u31_campaign.py:88-96`). Missing DRAIN recs after Phase4 GOLD and after leftover n=8 ⇒ those drains captured **n=0**.
12. `read_raw_stamped` returns after `len(buf)>=4` plus 50 ms idle (`uart_r2_u9_board_test.py:109-133`). `word` = first 4 bytes little-endian. n=8 is one capture. ABI constants: ACK `C1EA50A5`, BUSY `C1EA50B5`, GOLD `010000A5` (`uart_r2_u9_board_test.py:25-28`).
13. U30 bit `9f999be9…`: Phase4 GOLD; p5 r0 CLEAR **ACK n=4** then GOLD n=4; p5 r1 CLEAR **ACK n=4** then V-04 n=0 12.0378 s (`PACK24_U30\CLEAR_V04_24.json:83-167`). **No n=8 leftover** on that campaign. First CLEAR1 n=0 then reopen ACK (`:9-58`).
14. U31 `pack_quiescent` includes `dest_ui_rdy && dest_ui_wdf_rdy` (`u31\pack_mig_bind.sv:74-75`). Board top ties those to `mig0` `app_rdy`/`app_wdf_rdy` (`arty_a7_r2_top_m4_mig_candidate.sv:247`). U30 qsc does **not** include dest rdy (`u30\pack_mig_bind.sv:71`).
15. CLEAR SAMPLE: `!pack_quiescent` → `S_BUSY` (`pack_debug_clear.sv:86-88`). `ui_req` / `cdc_rst_100` only while `S_REQ|S_CDC|S_QUIET` (`:61-62`). `S_BUSY` and `S_ACK` do not set `ui_req`. Leftover BUSY therefore does **not** raise `debug_clear` through `pack_clear_ui`.
16. TX mux: `mux_valid = clr_ack_valid | uart_tx_valid | st_valid_100`; `mux_data` prefers `clr_ack_data`; `st_ready_100` is 0 while `clr_ack_valid` (`top.sv:390-395`). `qsc_100 = qsc_c1 && cdc_a_idle && tx_b_idle && !st_valid_100 && !uart_tx_valid` (`:374`).
17. `uart_tx_word` snapshots `acc <= w_data` on `w_valid && w_ready`, then shifts four 8N1 bytes from that snapshot (`u14\uart_tx_word.sv:59-67,96-111`). Flush does not abort an in-flight frame (`:4-5,72`).
18. `load_ack` is set in `S_COMMIT` after write drain + sentinel readback, then `S_OK` → `S_IDLE`; `load_ack` is cleared on reset or next `OP_BEGIN` (`pack_loader.sv:577-611,339`). Status GOLD is `load_ack && !ack_d` (`top.sv:354-356`).
19. `word_cdc32` b-reset zeros `last_b`/`ack_b`/`b_valid` while a-side `req_a`/`hold` can survive (`PACKAGE word_cdc32.sv:28-65`). TX CDC `a_rst_n = rst_ui_pack_n` (`~debug_clear`), `b_rst_n = rst100_tx_b_n` (`~clr_ui_req`) (`top.sv:144-155,366-369`). BUSY path: `clr_ui_req=0` ⇒ b-side **not** reset.
20. RTL **mechanism** (not a board measurement): `dest_accept = qsc_c1 && rst100_pack_n`; `steer_pack = pack_lock || (f_valid && pack_begin && dest_accept)`; if `f_valid && pack_begin && !dest_accept`, `f_ready=0` (FIFO holds BEGIN) (`top.sv:86-87,230-232`; same in `harness.sv:47-48,162-164`). That **can** produce host V-04 n=0 with no NAK. Whether E6/E7 mute **is** this path remains **HYPOTHESIS**. Do not promote to FACT.
21. `debug_clear` resets `pack_loader` and `mig_ui32` via `rst_loc` (`pack_mig_bind.sv:45-70`). `mig_ui32` on `!rst_n` forces `st<=S_IDLE`, `out_r<=0`; combo `app_en` drops (`mig_ui32.sv:62-67,89-103`). `mig0` itself is not that reset. `wr_outstanding` in qsc is the **loader** counter, not `mig_ui32` `ui_out` (`pack_mig_bind.sv:37-38,74-75`).
22. Overlay sources in the U31 Vivado project: `u31/pack_mig_bind.sv`, `u31/pack_debug_clear.sv`, `u31/pack_clear_ui.sv`, `u31/arty_a7_r2_top_m4_mig_candidate.sv` (`uart_r2_u31.xpr`).
23. BRAM dest: `app_rdy = rst_n && !stall` (`PACKAGE mig_ui_bram.sv:34-35`). Harness exposes `dest_stall` default 0 (`harness.sv:30,202`). Scratch TB `tb_u31_dest_stall_clear.sv` forces it after GOLD; leftover/two_v04 TBs do not.
24. Host BUSY retry is protocol (`u31_campaign.py:99-114`). 24/24 still fail (FACT 8–10).
25. dest_stall XSim cell: scratch TB `u31/tb_u31_dest_stall_clear.sv`. Log `xsim_u31s/xsim.log`. After Phase4 GOLD `qsc_ui=1 d_rdy=1`; `dest_stall=1` → `qsc_ui=0 qsc_100=0 d_rdy=0 d_wdf=0`; one CLEAR → **one** UART word `c1ea50b5`; score `BUSY_N4_NO_GOLD`; `$finish` 4513945 ns (`xsim.log:28-33`). Dest remains `mig_ui_bram`, not `mig0`.
26. dest_accept mute XSim (`tb_u31_dest_accept_mute.sv` sha256 `e614789fe86f63b359ccf5c60e4222f160e7dfdc7160dde87b6cdffb94607b87`, `xsim_u31m/xsim.log` sha256 `8c10dcc44cb251f9650dabe1ab64622cb41c4b30e04b030f30035bc4dcc943ef`, `$finish` 28807465 ns):
    - Cell A: ACK → `dest_stall=1` → V-04 → `mute=1 got=0 dest_accept=0 n_p=0 f_valid=1 f_data=00800001 f_ready=0 load_ack=0` → **MUTE_PFIRE0**.
    - Cell A release: `dest_stall=0`, no extra host TX → GOLD `010000a5` `n_p=52 load_ack=1` → **RECOVERY_GOLD**.
    - Cell B: stall after first new `p_fire` (`n_p=53 dest_accept=1`) → `mute=1 n_p=103 dn_p=51 load_ack=0` → **HANG_PFIRE_GT0**.
    Host UART is n=0 / no NAK for both A and B.
27. leftover GOLD hunt (`tb_u31_leftover_gold_hunt.sv` sha256 `3694467e7065b9bc99dc6ec886f903699bc3545fe8ae2b3a1cbc4dea9c8b42f1`, `xsim_u31g/xsim.log` sha256 `f257f60b000836cb5ad08f715ce248d86b556ca40d28e702593fb82a0d72fab1`, `$finish` 6610475 ns):
    - L2: pulse `rst100_tx_b_n` after GOLD, no CLEAR → **GOLD_ONLY** `010000a5` (`xsim.log:31-32`).
    - L1: `dest_stall` CLEAR + force `ack_d=0` while `load_ack` sticky → **BUSY_THEN_GOLD_N8** `c1ea50b5` then `010000a5` (`xsim.log:35-37`). Force is not a live BUSY-path RTL event.

### INFERENCE (from FACT; not on-chip proof)

1. Leftover `b550eac1a5000001` is two intact ABI words, BUSY then GOLD, not a mid-word mux splice. Follows from FACT 8+12+17: the 1+7 FTDI split is the same pattern as 4-byte replies; `t_first==t_last` fits one ~0.7 ms 8-byte UART burst at 115200 (8 bytes × 10 bits / 115200 ≈ 0.69 ms).
2. Host 50 ms idle did **not** glue a late Phase4 GOLD still in the COM buffer onto a later CLEAR reply. Drain after GOLD was n=0 (FACT 11). Buffer leftover would prepend GOLD; observed order is BUSY then GOLD.
3. Pending `st_valid_100` from Phase4 was **not** asserted for 0.2 s after the host already had GOLD. If it were, `mux_valid` would be 1 with no CLEAR (`top.sv:390`) and `drain_idle` would have logged bytes. E7 repeating n=8 after a capture that already contained `a5000001`, then a drain with n=0, requires a **new** GOLD per CLEAR.
4. U31 leftover BUSY after GOLD vs U30 ACK after GOLD is explained at least as well by the **qsc formula delta** (FACT 13–14) as by a mux bug: U31 SAMPLE can go BUSY solely because `mig0 app_rdy` is 0; U30 would still ACK.
5. E6/E7 V-04 n=0 after **ACK** means `qsc_100` was true at SAMPLE (includes synced dest rdy on U31). Sticky `app_rdy=0` **before** that CLEAR is the wrong picture for those mutes.
6. Campaign `read_raw_stamped` 50 ms idle after ACK, then V-04 TX (`WAIT_AFTER_ACK_S=0` only starts after that return). FPGA has left `S_ACK` (ACK was captured) and the one-cycle `S_DROP` flush (`pack_debug_clear.sv:63,145-148`) is long over. **RX flush overlapping V-04 is a weak explanation of E6/E7 mute as the campaign is written.**
7. Host BUSY retry is not dest-complete and did not produce 24/24.

### HYPOTHESIS (plausible, unproven)

1. After GOLD, `dest_ui_rdy`/`dest_ui_wdf_rdy` (`mig0 app_*`) is the false `pack_quiescent` term that makes p5 r0 SAMPLE→BUSY. No on-chip sample (U4).
2. GOLD bytes in the n=8 burst are **created during that CLEAR window**, then ordered BUSY-then-GOLD by mux priority. That is still “mux ordering,” not “CLEAR stole the Phase4 GOLD.” Source of the new GOLD on the BUSY path is unidentified (U1b). Candidates: GOLD `st_valid_100` rising while `S_BUSY` waits `ack_ready`; unobserved `debug_clear` glitch; a second `S_COMMIT`; CDC hold replay despite BUSY not asserting `clr_ui_req`.
3. V-04 n=0 after ACK-path CLEAR (E6, E7 reopen, U30 r1) is `mig_ui32` client reset while `mig0` still has a UI transaction: fabric forgets outstanding (`mig_ui32.sv:89-103`); qsc can look idle via loader `wr_outstanding==0`.
4. Board mute **is** dest_accept hold (Cell A) vs hang (Cell B). Mechanism of both is PASS_XSIM on BRAM (FACT 26). Assignment of E6/E7/U30 r1 to A vs B remains unproven (host n=0).
5. First CLEAR n=0 after JTAG/COM open (E4, E6 warmup, U30 CLEAR1) is FTDI/COM-open / RX `need_mark`, distinct from mid-campaign n=0.

### UNKNOWN

See §4. Includes which qsc term is false, GOLD source on BUSY CLEAR, whether mute is dest_accept vs MIG vs TX, git commit, PROGRAM.DONE.

### CONTRADICTED

1. **(C) first-ACK-miss is the only n=0 CLEAR class.** E7 `CLEAR_BUSY0` / `CLEAR_BUSY4` / `CLEAR_BUSY7` are n=0 **after** leftover n=8 on the same SRAM. E6 mixes CLEAR n=0 with BUSY after reprogram. V-04 n=0 after ACK is a different mute class.
2. **AXI UART / “this bit cannot emit GOLD.”** E5 and E7 Phase4 GOLD n=4. U30 two GOLD.
3. **uart_tx_word non-atomic mux switch as the n=8 pattern.** Two complete LE ABI words. Capture is word-atomic (FACT 17).
4. **Host 50 ms idle concatenating Phase4 GOLD with CLEAR as the leftover source.** Drain empty; order is BUSY then GOLD (INFERENCE 2).
5. **U31 overlay closed dest-in-reset-during-ACK as a 24/24 fix.** E6 ACK then V-04 n=0; E7 reopen ACK then V-04 n=0.
6. **XSim leftover+four GOLD is board 24/24.** Dest is BRAM; leftover TB expects ACK after junk+CLEAR and gets ACK; two_v04 expects ACK after GOLD and PASSES; board returns BUSY+GOLD.
7. **Pending `st_valid_100` from Phase4 remaining asserted until CLEAR (strict form of A).** Drain n=0 plus `mux_valid=st_valid_100` would have transmitted GOLD without CLEAR (INFERENCE 3). E7 repeats n=8 after GOLD bytes were already consumed. dest_stall after GOLD emits BUSY without GOLD (FACT 25) — dest-not-ready is not the leftover-GOLD source.
8. **U7 reset-inject GOLD on leftover BUSY CLEARs** (as written: `rst_ui_pack_n` falling while `load_ack` stays 1). BUSY path does not set `ui_req` (FACT 15). `rst_ui_pack_n` and `rst_loc` are both registered `~debug_clear`. If `debug_clear` actually asserted, both `load_ack` and `ack_d` would clear. BUSY leftover should assert neither.
9. **RX flush of V-04 as the primary E6/E7 mute** (campaign as written). ACK n=4 was received; 50 ms idle then V-04 (INFERENCE 6). Flush-during-DROP can still bite a different host that writes V-04 in the same millisecond as ACK; that is not this campaign.

### SPECULATION (do not act on)

- FTDI loopback of TX into RX.
- LUTAR glitch on `debug_clear` despite `DIRECT_RESET`.
- `word_cdc32` req metastability re-emit without reset.

---

## 2. Attack on (A) (B) (C)

### (A) TX mux CLEAR-preempts-GOLD as n=8 leftover cause — WEAKENED (split)

**Still FACT:** mux priority is CLEAR over GOLD (`top.sv:390-395`). If both valids are 1, UART emits BUSY then GOLD. That **matches leftover byte order**.

**Not shown:** that a **pending Phase4 GOLD** was the second word.

Evidence **against** pending-GOLD preemption:

1. After Phase4 GOLD the campaign drains 0.2 s and logs nothing (FACT 11). Pending `st_valid_100` is `mux_valid` without CLEAR (`top.sv:390`).
2. Host already received GOLD n=4. A second GOLD still in CDC after a successful handshake is a **second** status event.
3. E7 repeats n=8 **after** the previous capture already included `a5000001`. `drain_idle` after n>4 (`u31_campaign.py:104-106`) logs nothing. One preempted pending word cannot do that unless GOLD is **regenerated per CLEAR**.
4. Leftover CLEAR is **BUSY**, so SAMPLE took `!qsc` and never entered `S_REQ` (`pack_debug_clear.sv:86-88`). CDC TX b-reset (`~clr_ui_req`) and `debug_clear` are not on that path. Repeating GOLD on BUSY needs a GOLD source this path does not obviously have.
5. XSim GOLD-then-CLEAR is ACK (`tb_u31_two_v04.sv:136-138`, `xsim_u31t\xsim.log`). If mux preemption of pending GOLD were easy to hit at 1 Mbaud BRAM with immediate CLEAR, that TB would have failed. It passed.
6. dest_stall after GOLD: BUSY n=4, **no** GOLD (`xsim_u31s/xsim.log:28-31`). Dest-not-ready does not manufacture leftover GOLD.

Evidence **for** mux **ordering** (not pending Phase4 GOLD): if GOLD `st_valid_100` rises **while** `S_BUSY` waits `ack_ready`, mux sends BUSY first then GOLD. Cause of leftover is then “why qsc was false” + “why GOLD rose during BUSY.”

**Split U1:**

| ID | Question | Status |
|----|----------|--------|
| U1a | Why is p5 r0 CLEAR **BUSY** after GOLD + ≥0.2 s drain? | **Strengthened** toward dest/`app_rdy` qsc (U31-only `dest_ui_rdy`; U30 ACK’d the same step). Term UNKNOWN. |
| U1b | Why are GOLD bytes in that BUSY capture? | **Weakened** pending-mux-GOLD. GOLD-during-CLEAR still HYPOTHESIS. Source UNKNOWN. |
| U1c | Why does BUSY+GOLD **repeat** (E7)? | **Contradicts** one-shot pending GOLD. Requires per-CLEAR GOLD. UNKNOWN. |
| U1d | uart_tx_word non-atomic mix | **Contradicted** (FACT 17). |
| U1e | host 50 ms concatenating two delayed replies | **Contradicted** for Phase4 leftover (INFERENCE 2). Back-to-back FPGA TX in one burst still FACT. |

### (B) dest/MIG hang as V-04 n=0 cause — WEAKENED as unique cause; OPEN as one class

Evidence **against** “mute = leftover MIG outstanding from a completed pack”:

1. **E6 V-04 n=0 with no GOLD on that program.** There is no completed pack to leave outstanding writes.
2. **ACK immediately before mute** (E6, E7, U30 r1) ⇒ `qsc_100` true at SAMPLE, including `dest_ui_rdy` on U31. Hang if any **starts during/after that ACK CLEAR**.
3. **U30 got two GOLD then r1 ACK + V-04 n=0 with no leftover n=8.** Mute exists **without** (A). Overlay U31 did not create the mute class; it also did not close it. U31 never got two GOLD in one campaign (worse than frozen U30 at GOLD-then-next).
4. **Competing dest_accept stall is live** (FACT 20): BEGIN held in FIFO, no NAK, 12 s n=0. Host cannot tell this from MIG hang.

Evidence **for** dest/MIG as **a** class (not proof):

1. ACK-path CLEAR **does** `debug_clear` → `rst_loc` → `mig_ui32` async reset (FACT 21). VALIDATION_CLEAR ≠ MIG_RESET in comments; the **client** is still reset.
2. After client reset, qsc can look idle (loader `wr_outstanding==0`) while `mig0` is not.
3. XSim dest is BRAM, `stall` default 0. Four GOLD PASS_XSIM does not test `mig0` outstanding-across-CLEAR.
4. U30 r1 ACK then V-04 n=0 is the same **symptom class** as E7 after reopen ACK.

**Split U2:**

| ID | Question | Status |
|----|----------|--------|
| U2a | V-04 n=0 after ACK-path CLEAR (E6, E7 reopen, U30 r1) | **SPLIT PASS_XSIM** (FACT 26): Cell A hold vs Cell B hang, UART-identical. Board which-one **OPEN**. |
| U2b | V-04 n=0 caused by leftover mux (A) | **Contradicted** as necessary: E6 and U30 mute without n=8. |
| U2c | Mute = MIG hung from leftover BUSY storm | WEAKENED: E6 had no leftover storm; E7 mute follows **ACK** CLEAR (which **does** `debug_clear`), not the BUSY leftovers. |
| U2d | Mute = RX flush of V-04 | WEAKENED for this campaign (INFERENCE 6). |

### (C) first-ACK-miss as only n=0 CLEAR class — CONTRADICTED

n=0 CLEAR appears as at least:

| Class | Evidence | After JTAG only? |
|-------|----------|------------------|
| C1 first exclusive / COM open | E4 CLEAR×3 n=0; U30 CLEAR1 n=0 then reopen ACK | often first |
| C2 post-reprogram warmup | E6 WARMUP n=0, several CLEAR n=0 mixed with BUSY | after JTAG, not first-only |
| C3 mid leftover retry | E7 CLEAR_BUSY0/4/7 n=0 **between** n=8 BUSY+GOLD | **no** |
| C4 V-04 n=0 after ACK | E6, E7, U30 r1 | not a CLEAR miss |

E4 then E5: same SRAM, first nwp4p5 CLEAR n=0; later p4p5 GOLD without reprogram. That **supports** a transient first-ACK/COM class **and** proves the FPGA was not dead. It does **not** exhaust n=0.

E7 C3 is the strongest contradiction to “only first-ACK-miss.”

Silence is **not** the BUSY ABI: `!qsc` at SAMPLE emits BUSY n=4, not n=0 (`pack_debug_clear.sv:86-88`). n=0 means the CLEAR word was not taken, TX never completed a reply the host saw, or PHY dropped it. `S_ACK` has **no timeout** (`pack_debug_clear.sv:130-133`): if `ack_ready` never arrives, `hold=1` and later CLEARs are not `take`n. E5 warmup BUSY on the same SRAM as E4 shows the FSM **was** in `S_IDLE` by 02:08, so a permanent `S_ACK` stick is not the E4→E5 story. Mid-campaign E7 n=0 remains unexplained by C1.

**Split U3:** keep C1 as a real class; do not fold C3/C4 into it.

---

## 3. U1–U10: strengthen / weaken / split

### U1 leftover n=8 BUSY+GOLD — SPLIT (see §2 A)

- **U1a CLOSED on BRAM dest_stall XSim** (FACT 25): dest-not-ready ⇒ BUSY n=4, **no** second GOLD. Still **not** a measurement of `mig0 app_rdy`.
- Strengthen U1a as a **possible** board BUSY term: U31 qsc vs U30; U30 p5 r0 ACK; two_v04 ACK after GOLD.
- **Board leftover n=8 is a separate bug from dest-ready qsc.** dest_stall did not emit GOLD.
- **U1b sufficient shape CLOSED only under force:** L1 `ack_d=0` + BUSY CLEAR → BUSY then GOLD n=8 (FACT 27). Live BUSY path does **not** drop `ack_d`. Silicon GOLD source remains UNKNOWN. Do not overlay from force.
- **U7 CDC b-reset replay CLOSED as GOLD_ONLY, not leftover BUSY:** L2 pulse `rst100_tx_b_n` → GOLD without CLEAR (FACT 27). BUSY leftover does not assert `clr_ui_req`. two_v04 ACK-only ⇒ ACK-path replay not hit at 1 Mbaud BRAM.
- Weaken U1 as mux-preempt-pending-GOLD: drain n=0; dest_stall cell; E7 repeats.
- Contradict U1d / U1e as before.

### U2 V-04 n=0 — SPLIT into UART-identical classes (FACT 26)

- **U2a Cell A MUTE_PFIRE0 PASS_XSIM:** dest_accept hold. BEGIN `00800001` at FIFO head, `f_ready=0`, `p_fire` never rises, host n=0 no NAK.
- **U2a Cell A RECOVERY_GOLD PASS_XSIM:** release stall, no re-TX → GOLD `n_p=52`. If dest becomes ready inside the host wait, Cell A **cannot** stay mute.
- **U2a Cell B HANG_PFIRE_GT0 PASS_XSIM:** stall after first `p_fire`. `dn_p=51 load_ack=0`, host n=0 no NAK. UART-identical to A.
- Host json cannot tell A from B. Independent (B) dest/MIG hang is **no longer the unique mute cause**. dest_accept hold is a mute class on BRAM.
- Board 12 s n=0 after ACK is Cell A **only if** `app_rdy` stayed 0 the whole window (A never released). Otherwise B. U30 r1 (two GOLD then n=0) is **INFERENCE toward B**, not FACT: dest recently completed packs; 12 s with no recovery GOLD rules out A-that-releases, leaves A-stuck vs B.
- **Overlay guard:** do **not** drop `dest_ui_rdy` from `dest_accept` to “fix” A. BEGIN would flow into a dest that is not ready and convert A into B.
- Weaken RX-flush mute for this campaign (INFERENCE 6). BRAM still cannot model `mig0` outstanding.

### U3 first exclusive CLEAR n=0 vs later ACK — SPLIT; first-only CONTRADICTED

- Strengthen C1 exists: E4; U30 CLEAR1 n=0; E6 warmup n=0.
- Strengthen “not dead silicon”: E5 GOLD on same SRAM as E4.
- Contradict “only first-ACK-miss”: E7 mid-retry n=0; E6 ACK then V-04 n=0.
- E6 after **reprogram** still needed reopen for ACK (`BOARD_BASELINE.json:100-137`) — COM-open class, not only “cold SRAM.”

### U4 which qsc term is false on BUSY — still UNKNOWN; dest_ui_rdy STRENGTHENED as a candidate

No on-chip sample. Comparative evidence only: U30 without `dest_ui_rdy` ACK’d after GOLD; U31 with `dest_ui_rdy` BUSY’d. That is **not** a measurement of `app_rdy`. Other U31 extras on `qsc_100` (`top.sv:374`: `cdc_a_idle`, `tx_b_idle`, `!st_valid_100`, `!uart_tx_valid`) are weaker after 0.2 s drain.

`ui_out` from `mig_ui32` is **not** in qsc (`pack_mig_bind.sv:37-38,74-75`). If the false term is MIG-side outstanding, qsc may see it only via `app_rdy`/`ui_busy`.

### U5 dest-in-reset duration after host ACK — still UNKNOWN; overlay intent STRENGTHENED as RTL, sufficiency CONTRADICTED

RTL: `ui_req` drops before `S_ACK` (`pack_debug_clear.sv:61,130-133`); `debug_clear` held until `!req` (`pack_clear_ui.sv:68-75`). Cross-domain cycles after ACK TX are unmeasured. E6/E7 ACK then V-04 n=0: dropping clear before ACK TX is **not sufficient** for 24/24.

### U6 mig0 `app_rdy` long-low vs BRAM — still UNKNOWN; BRAM stall cell CLOSED; board dest still unmeasured

FACT: dest_stall on BRAM drops `d_rdy` and makes CLEAR BUSY n=4 without GOLD (FACT 25). Board leftover is BUSY**+GOLD** on `mig0`. XSim leftover CLEAR2 is ACK (`xsim_u31l`). Three different replies after GOLD: ACK (BRAM idle) / BUSY n=4 (BRAM stall) / BUSY+GOLD n=8 (board). `mig0 app_rdy` still unmeasured.

### U7 reset injects spurious GOLD — L2 CLOSED as GOLD_ONLY; not leftover BUSY

L2 PASS_XSIM: TX CDC b-reset replays GOLD from `hold` without a new `load_ack` edge (FACT 27). Leftover SAMPLE→BUSY does not pulse `clr_ui_req` / `rst100_tx_b_n`. two_v04 still ACK-only after GOLD. Board `drain_idle` after Phase4 was n=0, so spontaneous L2 did not happen on that campaign. Do not overlay from L2.

### U8 GOLD before dest-complete — OPEN, not contradicted, not proven

`load_ack` is after write drain + sentinel readback in the loader (`pack_loader.sv:577-606`). That is dest-complete **for `mig_ui32` readback of this pack**, not for `mig0` after a later CLEAR client reset. Board GOLD n=4 is not 24/24 dest-complete through `pack_mig_bind` on `mig0`. Do not treat `WAIT_AFTER_GOLD_S` as silicon law (`u31_campaign.py:43` is 0).

### U9 alternating BUSY n=4 / CLEAR n=0 — STRENGTHENED as a real pattern; cause UNKNOWN

E6: BUSY, n=0, BUSY, n=0, n=0, reopen, n=0, ACK. E7 leftover: n=8, n=0, n=8, n=8, n=0, n=8, n=8, n=0, reopen, n=0, ACK. Not explained by first-ACK-miss. If `st_valid_100` were stuck, drain would see repeating GOLD without CLEAR (INFERENCE 3) — U9 is **not** stuck GOLD TX.

### U10 longer post-JTAG wait — WEAKENED as E6 fix

E6: End of startup in `program.log` at `2026-09-19 02:13:27`; V-04 n=0 at `02:14:21` (`BOARD_BASELINE.json:137-148`) ≈ 54 s later, plus warmup/BUSY/reopen. Longer than 17 s. Still mute. E4 12 s settle still CLEAR n=0; E5 later GOLD without extra JTAG wait. Does not test an hour-long calib.

---

## 4. What must remain UNKNOWN

Do not fill these with narrative:

1. Which boolean in `pack_quiescent` / `qsc_100` is 0 on leftover SAMPLE (U4).
2. Hardware source of the extra GOLD word on **board** BUSY CLEAR (U1b/U1c). L1 force is sufficient in XSim, not shown on silicon. RTL BUSY path does not drop `ack_d` or pulse `clr_ui_req`.
3. Whether **board** E6/E7/U30 V-04 n=0 is Cell A (dest_accept hold, `p_fire==0`) or Cell B (hang, `p_fire>0`). Host n=0 cannot distinguish. Both are PASS_XSIM as UART-identical mutes.
4. `mig0` `app_rdy`/`app_wdf_rdy` after GOLD or CLEAR. No ILA; no debug core (`program.log:54`).
5. Cross-domain duration of `debug_clear` after host ACK (U5).
6. Whether board `load_ack` is dest-complete through generated `mig0` (U8).
7. Git commit of the U31 overlay (rev-parse exit 128).
8. `PROGRAM.DONE` / `IR.STATUS` (NA). End of startup HIGH is Labtools 27-3164 only.
9. Whether a `mig0` UI-accurate XSim of leftover+four V-04 would fail (G3). Not run.
10. Whether ILA/bring-up bits would change the next overlay. Out of scope without owner GRANT and a new bit. This analyst must not program.

---

## 5. dest_stall cell — SCORED (do not overlay from this)

Scratch TB ran after the original report. Score **BUSY_N4_NO_GOLD** (FACT 25).

| Predicted cell | Actual |
|----------------|--------|
| BUSY n=4, no second GOLD | **HIT** `c1ea50b5` only, `nw=1`, 4513945 ns |
| BUSY then GOLD n=8 | not this cell |
| ACK | not this cell |
| mute | not this cell |

**Do not implement a new overlay from `dest_ui_rdy`.** Do not program. Do not stamp PASS. Pack1/2/3 still missing.

Limits of this cell (adversarial): baud 1 M vs board 115200; dest is BRAM not `mig0`; 2 ms capture window is enough for mux-immediate GOLD at 1 Mbaud (~40 µs/word) but is not a 12 s board mute test; hierarchical `u_h.qsc_ui` printed so qsc coupling is observed, not inferred.

### dest_accept + leftover-GOLD cells — SCORED (still no overlay)

Mute analog (U2a) and leftover hunt (U1b/U7) ran on `mig_ui_bram`. Scores in FACT 26–27. **Do not overlay `dest_ui_rdy` / `dest_accept`.** Dropping dest rdy from `dest_accept` turns Cell A into Cell B.

### Next 24/24 step (still no overlay dest_rdy / dest_accept, no program)

Still no overlay of `dest_rdy` / `dest_accept`. BRAM does not model `mig0` outstanding. Host json cannot split A vs B.

Board mute class needs **on-chip** `p_fire` / BEGIN-at-FIFO or ILA, **or** a hang TB on generated `mig0`.

Leftover GOLD on silicon still UNKNOWN. No overlay from force. ILA on `load_ack` / `ack_d` / `st_valid_100` would be a new bit (D programs), not this merge.

Do not call host `WAIT_AFTER_GOLD` dest-complete. If used, label HOST_WAIT.

---

## 6. GAPS (requirement vs evidence)

G1. 24/24 CLEAR-V04 GOLD n=4: **missing**. Best U31: one Phase4 GOLD then fail p5 r0. Never two GOLD in one U31 campaign. U30 had two. U31 overlay is **worse** at GOLD-then-next-CLEAR than frozen U30.

G2. Pack24 run1/run2/fresh dest-complete: **missing**. No jsonl.

G3. XSim dest ≠ board dest: **FACT**. leftover TB does not reproduce board leftover (XSim ACK vs board BUSY+GOLD).

G4. `app_rdy` after CLEAR: **not measured**.

G5. Drop `debug_clear` before ACK: implemented in overlay; **not sufficient** (E6/E7).

G6. Host BUSY retry: not silicon dest-complete; 24/24 still fail.

G7. Git: UNKNOWN (exit 128).

G8. PROGRAM.DONE NA. No debug core.

---

## 7. Adversarial review

- **review_id:** U31-IND-20260919-COLD
- **reviewer_role:** independent analyst / devil-advocate
- **intent_anchor:** user_goal = classify GAPS/UNKNOWNS after U31 FAIL 24/24 without accepting parent inference; current_priority = one smallest decisive experiment, no overlay; allowed_scope = read evidence E1–E12 + named RTL/campaign, write this report; forbidden_scope = program Arty, edit C/H/freeze DCP/Pack24 gold/frozen U20–U30, stamp any PASS
- **claim_under_review:** leftover n=8 is TX mux CLEAR preempting pending GOLD; V-04 n=0 is dest/MIG hang; n=0 CLEAR is first-ACK-miss
- **what_i_accept:** mux priority exists; BUSY is ABI for `!qsc`; GOLD PHY exists on this bit; XSim BRAM four GOLD; exclusive program End of startup HIGH; 24/24 not met
- **what_i_challenge:** pending-GOLD as leftover **cause**; dest hang as **the** V-04 n=0 cause; first-ACK-miss as **only** n=0 CLEAR class
- **strongest_counter_argument:** drain-empty + repeating n=8 + U30 ACK-after-GOLD without `dest_ui_rdy`, plus E6 mute with no prior GOLD and no leftover
- **missing_evidence:** dest_stall / dest_accept / leftover-GOLD XSim scored on BRAM; still missing on-chip `mig0 app_rdy`, board `p_fire`/BEGIN, silicon leftover GOLD source
- **scope_drift_risk:** overlay that drops `dest_ui_rdy` from `dest_accept` to “fix” Cell A — converts hold into Cell B hang
- **final_verdict:** BRAM mute split closed (A hold vs B hang, UART-identical). Leftover n=8 shape is force-sufficient, not silicon-causal. Do not overlay. Do not stamp PASS.
- **self_audit:** preserved_user_intent=true; did_not_invent_objection=true; evidence_based=true; no_scope_hijack=true

---

## 8. Explicit stamps (ceiling)

```
PACK_ABI_24_24_PASS = NO     # not achieved; never 24 GOLD; no pack1/2/3
PROGRAM_PASS        = NO
BOARD_PASS          = NOT_EVIDENCED
TIMING_PASS         = NO     # WNS/WHS are report observations, not a stamp
MIG_PASS            = NO
UART_R2_U31         = CANDIDATE_FAIL_BOARD_24_24
```

WNS +0.503 / WHS +0.026 in `timing_route.rpt` are **not** `TIMING_PASS`.

This analyst did not program the Arty, did not edit C RTL / identity H / freeze DCPs / Pack24 gold / frozen U20–U30 / PACKAGE live bind.

---

## 9. Commands actually run this analysis

Cold read:

```
python hashlib.sha256  (bit, dcp, four u31 overlay SV files, u31_campaign.py)
git rev-parse --is-inside-work-tree  (D:\FPGA, arty_d, UART_R2, PACKAGE)  → exit 128 all four
```

Sequential merge (this pass; verify-only):

```
python hashlib.sha256  (bit, tb_u31_dest_accept_mute.sv, xsim_u31m/xsim.log,
                        tb_u31_leftover_gold_hunt.sv, xsim_u31g/xsim.log)
```

THIS_RUN `20260918T201143Z` same four hunt files + bit; all MATCH. Hunt TB/log MATCH `U31_LEFTOVER_GOLD_XSIM.md`. Bit `08cbb85430060acafaeee2aa9d63948be1e460e70ee02f3ca56450a5a2cce28d`. No Vivado. No XSim re-run. No COM/JTAG. No overlay. `SPAWN_X16=NO`.
