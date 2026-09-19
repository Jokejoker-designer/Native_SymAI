# AGENT_D independent PACK_ABI_24_24_PASS closure investigation

RUN_ID: 20260919T052400Z
OWNER: AGENT_D
PACK_ABI_24_24_PASS = NO. BOARD_PASS = NO. MIG_PASS = NO. PROGRAM_PASS = NO.
Owner/user stamps. This document does not stamp.

Prompt hypotheses were treated as claims to disprove, not as a work order.
No product overlay this turn. No UART / dest_accept / FIFO-depth / Ethernet change.

---

## A. INDEPENDENT_DIAGNOSIS

There are **two stacked failure classes**, not one Pack24 root.

**Class 1 — CLEAR1 BUSY (`c1ea50b5`).**  
U32 `pack_quiescent` ANDs `dest_ui_rdy`/`dest_ui_wdf_rdy` which on the U33/U32 top are raw `mig0.app_rdy`/`app_wdf_rdy` (cycle accept-ready). OBS01-MIG0: while loader/ui IDLE and outstanding=0, `qsc===app_rdy` and CLEAR1 BUSY. PACKAGE-qsc A/B (force dest ready 1 in TB, same UART/FIFO/CDC/loader/mig_ui32/mux/mig0): CLEAR1 ACK, txn1+txn2 P0–P15, GOLD1+GOLD2, Q4 NEW_COMMIT. U33 product qsc drops those ANDs. Exclusive board U33: CLEAR1 ACK.  
Verdict: Class 1 mechanism `RAW_MIG_READY_USED_AS_QUIESCENCE` is **CONFIRMED** for U32 CLEAR1 (XSim) and **SUPPORTED** as the reason U33 unblocked CLEAR1 on board. It is **not** a sufficient explanation of Pack24.

**Class 2 — current Pack24 blocker on the qsc-repaired identity.**  
U33 exclusive nwp4p5: four GOLD then 5th V-04 `0200015a` = `load_reject` `R_BAD_MAGIC` (`hw0 != 3149414E` after OP_BEGIN). BRAM dest five CLEAR→V-04: all GOLD, p0=`00800001` p1=`3149414e`. So MAG is not “5th commit on BRAM”. CLOCK_RATIO as CLEAR1 root is CONTRADICTED. MAG root **UNKNOWN** (leftover on CDC/loader after CLEAR, including after r2 CLEAR n=0; unlocked FIFO pop; UART hold-overrun). Do not patch `pack_loader`. Do not rebuild qsc.

Invariant still false for Pack24: **one accepted V-04 must produce exactly one GOLD commit with hw0=MAGIC_NAI1**. First divergence on current silicon: 5th V-04, not CLEAR1.

---

## B. STRONGEST_EVIDENCE

| Claim | Layer | Artifact |
|---|---|---|
| U32 qsc ANDs dest ready | FACT RTL | `UART_R2/u32/pack_mig_bind.sv` sha256 `7cee4df2…` |
| dest_ui_* = mig0.app_* on top | FACT RTL | `u33/arty_a7_r2_top_m4_mig_candidate.sv` `.dest_ui_rdy(app_rdy)` |
| PACKAGE live qsc has no dest AND | FACT RTL | PACKAGE `pack_mig_bind.sv` sha256 `581777cf…` |
| U33 qsc = client idle + out0 + rst_loc && !debug_clear | FACT RTL | `UART_R2/u33/pack_mig_bind.sv` sha256 `eade06c8…` |
| U32 board CLEAR1 BUSY, no GOLD | FACT BOARD | `PACK24_U32/U32_FAIL.md` bit `0df4de2e…` |
| OBS01-MIG0 dest-AND CLEAR1 BUSY; qsc===app_rdy idle | FACT PASS_XSIM | dest_ui_clk_mig0.csv `134b5956…` |
| PACKAGE-qsc A/B GOLD2 NEW_COMMIT | FACT PASS_XSIM | xsim_mig0_pkgqsc.log `63eb8e3e…` `$finish` 4958414625 ps |
| U33 board CLEAR1 ACK + 4 GOLD + 5th MAG | FACT BOARD | CLEAR_V04_24.json `b289fd4e…` bit `ff399e0b…` |
| `0200015a` = NAK reason 0x01 = R_BAD_MAGIC | FACT RTL | top `{8'h02,8'h00,reason,8'h5A}` + `pack_loader` `R_BAD_MAGIC` |
| BRAM 5× V-04 GOLD | FACT PASS_XSIM | xsim_u33f.log `c4011529…` `$finish` 12083475 ns |
| word_cdc32 holds until ack; reset drops in-flight | FACT RTL | `word_cdc32.sv` sha256 `8e356cf4…` |
| Unlocked non-BEGIN: `f_ready=1` (FIFO pop, not to CDC) | FACT RTL | U33 top `f_ready` mux |
| mig_ui32 stays `ui_busy` until cmd AND wdf then readback | FACT RTL | `mig_ui32.sv` S_WR both acc → S_RD |
| debug_clear resets loader+ui32, not generated mig0 | FACT RTL | `rst_loc <= ~debug_clear` |

---

## C. WHAT_THIS_PROMPT_GOT_WRONG

1. **Current blocker is not CLEAR1 BUSY.** That was U32. Live identity U33 already has CLEAR1 ACK and four GOLD. Treating Pack24 as “still stuck in SAMPLE non-qsc” is stale.
2. **M2 “create minimal qsc candidate” is already U33**, programmed, FAIL_BOARD MAG. Do not spawn U34 that only repeats PACKAGE qsc.
3. **PACKAGE-qsc GOLD2 does not prove board Pack24.** TB forces dest ready on U32 bind; only two V-04; dest is XSim mig0 not the 5th-commit MAG cell.
4. **UART 4th-byte “return IDLE without emit” is overstated.** `uart_rx_word` `bix==3 && !can_take` sets `stop_hold` and **stays in STOP** until `can_take`, then emits. Bytes arriving during hold are unsynchronized (latent overrun), not that exact FSM story.
5. **“Repair qsc then Pack24 closes” is CONTRADICTED on board** (U33). Option A is already on silicon.
6. **H1 as sufficient Pack24 explanation** is CONTRADICTED. H1 remains the CLEAR1 explanation.
7. **FIFO 128 / 44 ms as Pack24 proof** does not address MAG after BEGIN reached the loader.
8. **Do not implement Option B/C, Ethernet, clock-stop, or UART PHY overlay** for this MAG cell.

---

## D. CURRENT_ROOT_CLASS

| Class | Verdict | Note |
|---|---|---|
| BANDWIDTH | CONTRADICTED | 115200 vs FIFO 128 not CLEAR1; MAG is reject after BEGIN |
| CLOCK_RATIO | CONTRADICTED | same clocks GOLD2 on PACKAGE-qsc; U33 board GOLD×4 |
| CDC_LOSS | POSSIBLE | MAG; `cdc_rst` + in-flight hold; r2 CLEAR n=0 |
| BUFFER_OVERFLOW | CONTRADICTED as CLEAR1; UNKNOWN as MAG | unlocked pop is policy drop not overflow |
| READY_VALID | SUPPORTED | app_rdy is THIS-CYCLE ready; U32 used it as qsc |
| RESET_LIFECYCLE | POSSIBLE | debug_clear / cdc_rst vs leftover; U8 MAG was S_DROP cdc_rst (closed) |
| QUIESCENCE | CONFIRMED U32 CLEAR1; CONTRADICTED as remaining Pack24 root | U33 qsc repair on board |
| MIG_HANDSHAKE | SUPPORTED as U32 mechanism; UNKNOWN as MAG | half-write gated by ui_busy INFERENCE |
| UART_RX_DROP | POSSIBLE latent; CONTRADICTED as CLEAR1 root | stop_hold overrun |
| OTHER (R_BAD_MAGIC leftover) | SUPPORTED current blocker | 5th V-04 board; not BRAM 5th |

---

## E. MINIMAL_FIX_HYPOTHESIS

**Do not change qsc again until MAG is reproduced.** Smallest justified change is **none of product RTL** until a TB shows hw0 on the 5th V-04 with dest=mig0 and/or leftover-after-CLEAR.

If MAG XSim shows first loader word after BEGIN ≠ `3149414E` because a CDC/FIFO word survived CLEAR: the minimal fix is **make VALIDATION_CLEAR empty the pack ingress (CDC hold/req/ack + unlocked FIFO) before ACK**, without holding `cdc_rst` through S_ACK (U8 MAG class) and without AND-ing `app_rdy` back into qsc.

If MAG XSim is CLEAN on mig0 5×: board MAG is UART-align / collision / host leftover — isolate that cell, still no qsc/UART PHY overlay.

---

## F. SAFETY_RISKS

| Risk | Status |
|---|---|
| Half-write (`cmd_acc XOR wdf_acc`) vs debug_clear | INFERENCE protected: `ui_busy` while S_WR; CLEAR DRAIN_N=64 requires qsc. Need explicit XSim (M3). Putting `app_rdy` back in qsc recreates CLEAR1 BUSY. |
| Premature qsc vs MIG calendar | H5 UNKNOWN. Client idle ≠ DRAM idle. Not MAG’s token. |
| CDC reset | FACT: A/B reset clears req/ack/hold. U32 `cdc_rst` = S_CDC\|S_QUIET only. |
| Sticky ACK / duplicate GOLD | U32 TX busy-hold leftover TB PASS_XSIM; board MAG is NAK not duplicate GOLD. |
| Stale generation | UNKNOWN this MAG dump (reason 0x01 not 0x0E R_STALE). |
| Silent drop | FACT unlocked non-BEGIN FIFO pop; POSSIBLE UART hold overrun. |
| Duplicate commit | Not this fail token. |

---

## G. PACK24_MILESTONE_TABLE

See canvas. Summary:

- M0 YES (hashes in this file)
- M1 YES for READY/IDLE/QSC/COMPLETE/COMMITTED map; H5 still UNKNOWN
- M2 BUILT = U33; do not rebuild
- M3 PARTIAL (BRAM 5× PASS; mig0 5× **not run**; forced app_rdy dips **not run** on U33 bind)
- M4 NOT_RUN
- M5 CLEAR1 CONFIRMED (U32 BUSY vs U33 ACK); Pack24 MAG remaining
- M6/M7/M8 blocked

---

## H. NEXT_ACTION

XSim **generated mig0 + U33 `pack_mig_bind`**, five CLEAR→V-04, capture `p0/p1/reason_code` on any NAK. PROGRAM=NO. No overlay.

---

## M0 hashes

```
U32 bind     7cee4df21b69f5eb05728473c755f3f067b6c702502f0ac97af59f19093b0fbe
U33 bind     eade06c85af164a00cf6c35bb5e31cc51547fa7dbab2a5a3ccf801ce72e596c5
PACKAGE bind 581777cfcbcd1cdf71d3c5f383ec8b93fa2e41281d9c3ef554738a916d1f060f
U32 bit      0df4de2ec075bfdbe567bb661702da088a1be5322cc9112ad2ebf959d116f6ff
U33 bit      ff399e0bb9e6ff6c91caf3b769270b03ca9cfb2ea317035a5f3533031338a350
word_cdc32   8e356cf46b97100c5437c247da044c8964924bcfc4d814ccbf32e40892c310a3
word_fifo32  5d35ad1eac6bf259168a7e8e8137f4404abb9064aafddef02c3e858e221e7363
mig_ui32     c463af9514255f59c2899311d53f0a71b987820b6700c42a056b8241963821ff
uart_rx_word 6a9ac5272bc3f1c1a4c7b93b03b68f01fbb8dcb6830ff5a143b3782474924ae9
pack_clear_ui b0b1db2705102dad521d4422d7089f7b3f54c03562d2cde52f2418c81eb172aa
pack_debug_clear 58a3961aaee067dc1a025bec02dfedc6308f716890e1719edb39fc294f512b00
u33_campaign a4ab4cb86ee948be706e02df1182439a68894edc436c710b5fb9d571b0fd1b79
```

## M1 contract (D)

| Term | Meaning | Signals |
|---|---|---|
| READY_THIS_CYCLE | handshake this ui_clk | `app_rdy`, `app_wdf_rdy`, `s_ready` |
| CLIENT_IDLE | no client FSM work | `!loader_busy`, `!ui_busy` (`st==S_IDLE`) |
| IN_FLIGHT | accepted not retired | loader `wr_outstanding`, `mig_ui32.out_r` |
| QUIESCENT | safe to VALIDATION_CLEAR | U33: idle + in_flight=0 + `rst_loc` && `!debug_clear`. **Not** app_rdy |
| COMPLETE | dest write+readback done for that beat | ui S_HOLD→S_RSP |
| COMMITTED | pack accepted this generation | `load_ack` rise; UART GOLD `{01,00,reason,A5}` |

`qsc_100` on top is stricter: `qsc_c1 && cdc_a_idle && tx_b_idle && !st_valid_100 && !uart_tx_valid`. CLEAR SAMPLE uses that, not bind qsc alone.

## H1–H6

| ID | Verdict |
|---|---|
| H1 app_rdy-in-qsc sufficient for **board Pack24** | CONTRADICT (U33 MAG). SUPPORT for U32 CLEAR1. |
| H2 word_cdc32 fully safe Pack24 | UNKNOWN (reset/leftover). SUPPORT exact-once if no reset mid-word. |
| H3 FIFO 128 makes overflow irrelevant | SUPPORT vs UART 115200 if downstream flows. CONTRADICT as “no drop”: unlocked pop. |
| H4 UART drop cannot contribute after CLEAR repair | UNKNOWN. CONTRADICT as CLEAR1 root. POSSIBLE for MAG. |
| H5 qsc without dest_ui cannot idle too early | UNKNOWN vs MIG calendar. CONTRADICT vs U32 CLEAR1 (that was idle-too-late / false-busy). |
| H6 mig0 XSim representative enough for board candidate | PARTIAL. GOLD2 XSim matched U33 CLEAR1+GOLD; 5th MAG not in that TB. |

## Options A/B/C

A: already U33. Insufficient for Pack24.  
B/C: not justified. Defer.
