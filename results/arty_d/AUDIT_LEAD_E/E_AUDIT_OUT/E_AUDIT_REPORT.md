# AGENT_E AUDIT — D-PACK-VALIDATION-RESET-01

```text
TASK_ID: D-PACK-VALIDATION-RESET-01
RUN_ID: 20260916T230400Z
OWNER_AGENT: AGENT_E
MANDATE: AUDIT_FULL_EXCEPT_PROGRAM (ANALYSIS_ONLY SUPERSEDED)
BOARD_LEASE_THIS_WAKE: HOLD AGENT_E READ_ONLY_UART_CAPTURE program=no -> RELEASE -> GRANT AGENT_D program=yes
XSIM_RERUN:
  cmd /c D:\FPGA\arty_d\pack_debug_clear\run_xsim_hold.bat
    -> PACK_HOLD_FLOOD_XSIM_PASS 2  T10 HOLD_WR_MAX=0 used=0  $finish 240195 ns
       xsim banner Start Thu Sep 17 06:00:43 2026  Exit 06:00:46
  cmd /c D:\FPGA\arty_d\pack_debug_clear\run_xsim_uart_115200.bat
    -> PACK_DEBUG_CLEAR_UART_XSIM_PASS 15  $finish 126203745 ns  elapsed 00:00:26
       xsim banner Start Thu Sep 17 06:01:01 2026  Exit 06:01:29
       (TB 15 tests; T10 hold is in run_xsim_hold / 1 Mbaud UART TB, not this 115200 TB)
  cmd /c D:\FPGA\arty_d\AUDIT_LEAD_E\E_AUDIT_OUT\run_xsim_e_rtl.bat
    -> E_RTL_AUDIT_XSIM_PASS 8  $finish 7705 ns
       xsim banner Start Thu Sep 17 06:02:27 2026  Exit 06:02:29
NOT: PACK_ABI_24_24_PASS / BOARD_PASS / TIMING_PASS / MIG_PASS / PROGRAM_PASS
```

Không nạp. Không sửa C RTL. Không đè freeze DCP / historical `f6a6091f`. Không stamp PASS.

Mailbox processed (then mark-read): OWNER_MANDATE_AUDIT_FULL_EXCEPT_PROGRAM; HANDSHAKE_XSIM_AFTER_E_H3; BOARD_LEASE_REQUEST 20260916T223550; HANDSHAKE_BIT_READY_WAIT_GRANT.

---

## 1. Kết luận (claim ceiling)

CLEAR candidate **không** đạt Pack board classify. XSim **không** chứng minh board.

| Stamp | E |
|---|---|
| PACK_ABI_24_24_PASS | NO |
| PACK_VALIDATION_CLEAR_PASS | NO |
| BOARD_PASS | NO |
| TIMING_PASS | NO |
| MIG_PASS | NO |
| PROGRAM_PASS | NO |
| FE256_PASS / ASTRA_PASS / M2_PASS / M3_PASS / FINAL_PASS | NO |
| C_RTL_MODIFIED | false |
| freeze_dcp_overwritten | false (E did not write; name-search this wake did not relocate freeze DCP files) |
| GUARD_VIOLATION | NO |
| FEM_PERSIST | NOT_STARTED (still blocked) |
| BOARD_LEASE_GRANT_TO_D | YES (after SRAM-D UART probe n=0) |

**STALE_FILE vs SRAM (FACT):** live path `.bit` and unique `_cf62102f.bit` are identity H `cf62102f…`. `PROGRAM.txt` still records programmed SHA256 `bbba86c1…` STATUS=PROGRAMMED. Identity D `.bit` and identity D DCP `33310a44…` **NONE** under `D:/FPGA/arty_d` (walk `.bit` and `.dcp`). Historical M4+mig bit `f6a6091f…` and `m4_mig/post_route.dcp` `91c9f084…` UNTOUCHED.

**UART probe (FACT, program=no):** COM12 `210319BE776EB` present. One CLEAR. `n=0 hex=` `tok=None`. Mute-class at idle after prior campaign. Not ACK/BUSY/ERR/R_UNSUP.

Packing gold `.mem` **không** phải root của hang (unchanged). CLEAR mute root on SRAM-D **UNKNOWN** (no ILA). DUT not emitting 4B after CLEAR this capture.

---

## 2. Provenance re-hash (FACT)

Command: python SHA256 of named files + walk `D:/FPGA/arty_d` `*.bit`. Details: `E_HASH_RECHECK.json`.

| Artifact | SHA256 | Note |
|---|---|---|
| live CLEAR `.bit` path | `cf62102f21bd146976779e45dec77f912790da1000327fbc505941cdef4e7fc9` | identity H; STALE vs PROGRAM.txt |
| unique H copy `_cf62102f.bit` | same `cf62102f…` size 1940501 | MATCH live path |
| PROGRAM.txt **content** programmed SHA | `bbba86c1…9b23dd0` | SRAM claim; file blob sha256 `78e8eed1…` |
| identity D `.bit` under arty_d | **NONE** | cannot restore SRAM-D from disk |
| identity D `post_route_clear.dcp` `33310a44…` | **NONE** | path now `beab0263…` (H) |
| `post_route_clear.dcp` / `_cf62102f.dcp` | `beab0263e094dbf2e7bdebfaffb120d1cdc379492b1cc68b82c851183c6e17a9` | identity H |
| historical M4+mig `.bit` | `f6a6091f…ba368d7` | UNTOUCHED |
| historical `m4_mig/post_route.dcp` | `91c9f084…9216d2ce` | UNTOUCHED |
| live top `.sv` | `382ac125eec20578101a62b88ffe4be4baab408ce188a2b6550742ae0362cf40` | handshake H; not SRAM |
| live host py | `515eba9eccb6a6b9150e48949f85d3c706416de2090bf06f53e0780519e91790` | MATCH E_AUDIT_OUT copy |
| C `qstar_select.v` | `d4f64e65…4bf7240` | MATCH locked |
| C `spear_rank.v` | `11e71b50…a3c76293` | MATCH locked |
| C `fem_lifecycle.v` | `45b9b930…4779ed` | MATCH locked |
| `32_program` want_sha | `cf62102f…` | would program H if D runs Tcl |

---

## 3. UART probe (FACT)

```text
python uart_pack24_clear_board.py --mode probe
COM12 210319BE776EB
CLEAR attempt=0 n=0 hex= tok=None
PROBE tok=None n=0 hex=
exit_code=1
```

Logs: `E_AUDIT_OUT/UART_CLEAR_PROBE_E.txt`, `UART_CLEAR_PROBE_host.txt`.

No 24-case campaign. No JTAG. Discriminates idle SRAM-D after identity-D campaign hang: **zero UART bytes in 3 s**, not host false ACK.

---

## 4. Hypothesis table (this wake)

| ID | Claim | Status this wake |
|---|---|---|
| H1 | Gold `.mem` packing sai as hang root | **REJECTED** (unchanged) |
| H2 | Leftover/misaligned word → R_UNSUP | **CONFIRMED** PASS_XSIM T4/T5 (re-run). Board V-02 injector **UNKNOWN** (probe did not send pack) |
| H3 | snapshot `wr_valid` flood / silent drop | **CONFIRMED** PASS_XSIM E T1/T3. Live formula **CONFIRMED** hold-flood HOLD_WR_MAX=0 used=0. **Not on SRAM** |
| H4 | V-03 SENTINEL dest persist | **SUPPORTED** (unchanged) |
| H5 | CLEAR mute root | Symptom **FACT** (campaign + this probe n=0). Root **UNKNOWN**. Competing: hung FSM after S-02; RX never take; TX mux/uart_tx stuck. **CONTRADICTED** as “host false ACK” (0 bytes). T6 S_REJECT is pack-status mute-class, not this 0-byte ACK |
| H8 | Host false ACK | **REJECTED** for live host `find_known` (ACK/BUSY/ERR only). **REJECTED** as mute cause (got=null / n=0). Old `find_token` first-4 fallback **cannot** invent `C1EA50A5` if `find()` missed it |
| H9 | STOP-bit drop identity C | **REJECTED** for live D (unchanged) |

Search against leading H8: live `find_known`; probe n=0; campaign CLEAR `got=null` implies `len(raw)<4` on old 3-retry path.

Search against “CLEAR ACK happened but host missed”: probe drain+3s still n=0. INFERENCE: DUT not transmitting after this CLEAR (or never assembled). Not proof of which FSM state.

---

## 5. Handshake RTL (FACT)

Live PACKAGE top `382ac125…`:

```text
wr_valid = w_valid && !clr_take && !clr_hold
w_ready  = clr_take || (!clr_hold && fifo_wr_ready)
```

Snapshot (SRAM D sources): `wr_valid = w_valid && !clr_take`; `w_ready = clr_take || !clr_hold`.

Identity H bit on disk implements live handshake. SRAM still claimed D. E did not program H.

---

## 6. GRANT to D

After probe complete (not DEFER): `BOARD_LEASE_GRANT` AGENT_D `program=yes` duration_min=45 purpose=PROGRAM_HANDSHAKE_CLEAR_IDENTITY.

Warnings for D (not a DENY):

- Identity D `.bit` **not on disk**. Programming H is not roll-backable to D from `arty_d`.
- SRAM UART mute n=0 on claimed D.
- Do not overwrite `f6a6091f` or freeze DCPs.
- Do not self-stamp PROGRAM_PASS / BOARD_PASS / PACK_ABI_24_24_PASS.

---

## 7. Commands actually run this wake

```text
python mailbox.py AGENT_E check  -> 4 unread (processed)
python SHA256 named files + walk .bit
cmd /c run_xsim_hold.bat
cmd /c run_xsim_uart_115200.bat
cmd /c run_xsim_e_rtl.bat
python list_ports -> COM12 210319BE776EB
python uart_pack24_clear_board.py --mode probe
```

Not run: `32_program*.tcl`, `program_hw_devices`, 24-case campaign, FEM persist, C RTL edit.

---

## 8. Prior wake (20260916T223500Z) — not closed, superseded mandate

Prior ANALYSIS_ONLY: packing hang-root REJECTED; H3 snapshot flood CONFIRMED; no UART. This wake executed UART probe + XSim rerun + GRANT D.
