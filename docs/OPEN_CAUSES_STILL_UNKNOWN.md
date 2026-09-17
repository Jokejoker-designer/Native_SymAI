# Open causes — retried, still UNKNOWN

This is the part of Native_SymAI that was **retried many times and still has no silicon root cause**.

Evidence is already in this repo under `results/arty_d/`. This file is the map: what was tried, what was **REJECTED**, what is still **UNKNOWN**. It is not a PASS stamp.

Labels: **FACT** / **INFERENCE** / **HYPOTHESIS** / **REJECTED** / **UNKNOWN**.

Not claimed: `PACK_ABI_24_24_PASS`, `BOARD_PASS`, `PROGRAM_PASS`, `TIMING_PASS`, `MIG_PASS`, `H19_SILICON_ROOT`, `H20_SILICON_ROOT`.

---

## 0. Three different bits (do not mix)

| Identity | SHA256 | What it is | Internals |
|---|---|---|---|
| **H** | `cf62102f21bd146976779e45dec77f912790da1000327fbc505941cdef4e7fc9` | VALIDATION_CLEAR product candidate | **NOT_ON_WIRE**. ILA=0. BASIC cannot `create_debug_core` (Vivado 12-29205). |
| **H-ILA-A** | `b037b355a7098c99b9a995554756122e09569230d3b8d02698c255e6a64f8cef` | Different P&R + UART dump | Dump latched CLEAR `44524743`. Not H. |
| **H_OBS** | `07776d516d5f46b2ccf318cc12cf33a2eae886281b1bd824ae7aa55e1f26f7d7` | UART-dump observe (BASIC path) | After clean CLEAR: `first_pack_word=00800001`. **Must not be copied onto H.** |

Lock: `results/arty_d/H_OBS/IDENTITY_LOCK.md`

SRAM after H_OBS program holds H_OBS, not H. Disk file of H is unchanged.

---

## 1. The still-open question (COMMON_ROOT)

**What, on identity H, turns a legal CLEAR ACK + exact 132-byte A-01 into UNSUP / NAK_R02 / MAG / mute?**

`COMMON_ROOT_STATUS = UNKNOWN` (see `results/arty_d/first_divergence_01/STATUS.md`).

Two failure classes on the same bit:

| Class | Symptom | Status |
|---|---|---|
| **A** | 4-byte wrong token: UNSUP `0200075a`, MAG `0200015a`, SENTINEL `0200085a` | Reproduced in XSim by **stray UART byte / leftover `bix`**. Extra-byte **SOURCE on silicon** still UNKNOWN (FTDI / PHY / FPGA). |
| **B** | Sticky mute (`n=0`, no ACK) after some pack traffic | H17 XSim can mute from incomplete pack + BUSY. Board mute after campaign **not proven** to be that path. |

FEM persist is blocked until Pack is B-classifiable.

---

## 2. Retry log (H9 → H20 → H_OBS)

Each row is a named experiment. “Rejected as sole root” means it cannot be *the* explanation of all board failures.

| Arm | What was tried | Result | Still open? |
|---|---|---|---|
| **H9 JP2 CK/RST installed** | Hardware strap | Correlates with **CLASS B sticky mute** from S-01 | Not sole root of CLASS A. |
| **H9 JP2 removed** | Owner reported removed | CLASS A still present | Yes — CLASS A independent of JP2. |
| **H10 paced vs burst** | 0.5 ms gap vs burst, 24 cases | GOLD 13/24 burst vs 19/24 paced. **V-03 SENTINEL on both rates** | Rate helps GOLD count; **not sole root**. |
| **H11 repeat V-04** | Same case 8× | i=0 PACK UNSUP; later MAG; then CLASS B mute | Same case is **unstable** A then B. |
| **H12 extra byte XSim** | 1 stray `0x00` then CLEAR | UNSUP `0200075a` word `52474300` — token match H11 | Mechanism in sim **yes**; silicon source of the byte **UNKNOWN**. |
| **H12 extra 2–3 bytes** | leftover `bix` | MUTE (CLEAR not assembled as `44524743`) | Possible CLASS B path; not proven on H campaign mute. |
| **H12 board V-04 pad0** | No pad | CLEAR UNSUP then ACK×3; PACK mix GOLD/MAG/UNSUP | CLASS A live. |
| **H12 A-01 isolate board** | Loop A-01 | `UNSUP, NAK_R02, MAG, NAK_R02, NAK_R02, CLEAR n=0` | Mute at i=5. XSim 6× A-01 is NAK then CLEAR ACK — **BRAM leftover REJECTED**. |
| **H12 pad3 after UNSUP** | Host pad | XSim: CLEAR ACK + GOLD | **Rejected as product fix** (owner: no pad/resync on H). |
| **H13 FIFO/CDC** | overflow arm | `n_drop=0`; R_STALE after dest stall | **Not FIFO-drop proven**. Board NOT_RUN for full CDC. |
| **H14 reset domain** | RTL table | Written, not board-proven | Open. |
| **H15 CLEAR gate** | — | **NOT_RUN** | Open. |
| **H16 A-01 @115200 XSim** | dualclk BRAM, silicon baud | NAK_R02, `first_p=BEGIN`, `bix=0` | UNSUP **not** reproduced without extra byte. 1 Mbps baud-gap **REJECTED**. |
| **H16 hold-overlap** | start A-01 during S_ACK `w_ready=0` | still `first_p=BEGIN` `n_drop=0` | **BEGIN-drop-during-ACK REJECTED**. |
| **H17 MIG stall XSim** | incomplete pack + CLEAR | BUSY + sticky S_RX + MUTE; SENTINEL not produced | CLASS B **candidate** in sim. Not shown to be H campaign mute. |
| **H18 host raw stream** | timestamps | `t_first~0.06s`, not delayed >1s on CLASS A | Host-delay **REJECTED** as CLASS A. |
| **H19 ACK+pad A-01 XSim** | extra `0x00` after ACK | PACK UNSUP, `first_p=80000100`, `bix=1` | Classifier for leftover. |
| **H19 board A-01** | exact 132/132, idle 0.15s after ACK | i0 ACK+UNSUP; i1–i2 ACK+NAK_R02; `in_waiting=0` | **Python extra-byte REJECTED**. Extra-byte source below Python **UNKNOWN**. |
| **H20 4th-byte backpressure XSim** | `w_ready=0` at 4th STOP while a word sits | whole BEGIN **dropped**, alignment stays, token can still be UNSUP `0200075a` | Classifier only. Pin dump of RX bytes **cannot** see this (bytes still on the wire). |
| **Identity H first_word+bix** | no RTL, no pad | ILA=0; trial0 too-soon UNSUP; trial1 ACK+NAK_R02 | `first_pack_word=null` `bix=null`. Class **UNKNOWN**. |
| **H-ILA-A dump** | different P&R | first H11 window GOLD, dump CLEAR word; trial2 stale dump | **Does not classify H**. |
| **H_OBS UART dump** | BASIC observe identity | TB 3 classes PASS_XSIM; board AFTER CLEAR: BEGIN `00800001` class OTHER; pack token **MAG** | Explains **H_OBS only**. H trial1 was **NAK_R02**. |

---

## 3. Hypotheses REJECTED (do not revive without new evidence)

1. **Python joined an extra TX byte** — H19 board `tx_n==tx_expect==132`.
2. **Host started A-01 during ACK shift** — `read_raw` idle 0.15s after ACK.
3. **Pad/resync as product solution** — owner forbidden on identity H.
4. **BEGIN dropped during CLEAR ACK hold at 115200** — H16 hold-overlap `n_drop=0`.
5. **A-01 leftover sitting in BRAM UART** — H12 A-01 XSim 6/6 CLEAR ACK, `bix=0`, fifo empty.
6. **1 Mbps TB baud gap as UNSUP root** — H16 115200 still NAK not UNSUP.
7. **JP2 as sole CLASS A root** — CLASS A after JP2 removed.
8. **Pacing as sole root** — V-03 SENTINEL at both rates.
9. **`0200075a` unique to H19 (or unique to H20)** — both XSim paths can emit it.
10. **H-ILA-A / H_OBS dump classifies H** — different bit SHA; H-ILA-A latched CLEAR; H_OBS MAG ≠ H NAK_R02.
11. **H20 is a silicon fix** — classifier only; no RTL change authorized.
12. **Too-soon CLEAR UNSUP is H19 leftover** — host timing (also `cmd timeout` stdin abort). Wait 5–8s → ACK.

---

## 4. What is still UNKNOWN (the actual holes)

### 4.1 Extra-byte SOURCE on identity H (CLASS A)

XSim: one stray `0x00` after ACK shifts BEGIN `00800001` → `80000100` (H19).  
Board H19: first A-01 after program is UNSUP with **exact** 132 B Python TX.

**UNKNOWN:** who inserted the byte — FTDI 210319BE776EB, PHY, FPGA RX, or none (then H19 is not the board path).

ILA on **H netlist** blocked (BASIC). Pin LA of `uart_rx` cannot distinguish H20 (dropped word still sent as bytes).

Evidence:

- `results/arty_d/first_divergence_01/H19_BOARD_A01.json`
- `results/arty_d/first_divergence_01/H19_ACK_PAD_A01_XSIM.json`
- `results/arty_d/first_divergence_01/H12_CLASS_A_XSIM.json`
- `results/arty_d/H_CLASSIFY_H19_H20/D_IDENTITY_H_FIRST_WORD_BIX.json`

### 4.2 Identity H first pack-accepted word

Required classifier inputs `first_pack_word` and `bix` are **not exported** by H.

| Trial | CLEAR | A-01 | Internals |
|---|---|---|---|
| 0 immediate | `0200075a` UNSUP | not sent | n/a |
| 1 wait 5s | ACK `c1ea50a5` | `NAK_R02` `0200025a` 132/132 | null |

Classifier on H = **UNKNOWN**. NAK_R02 is **not** the H19/H20 UNSUP token; that still does not name the first pack word.

### 4.3 CLASS B sticky mute

Campaign identity H (`results/arty_d/m4_mig_clear/`):

- `pack_ok=7/11` then CLEAR mute from r0 S-02 (recovered), then sticky mute A-04 through r1
- post-campaign probe `n=0`
- leave-state reprogram → ACK again

H17 XSim: incomplete pack → CLEAR BUSY, no `debug_clear`, sticky S_RX, MUTE.

**UNKNOWN:** whether the board campaign mute is H17, leftover `bix` (H12 extra 2–3), FTDI, or something else.

### 4.4 Why H_OBS MAG vs H NAK_R02

Same host sequence (CLEAR ACK + A-01 132 B) on two P&Rs:

| Bit | Pack token | Dump first word |
|---|---|---|
| H | `0200025a` NAK_R02 | none |
| H_OBS | `0200015a` MAG | `00800001` BEGIN |

**UNKNOWN:** MAG vs NAK is a later pack/magic/dest issue on H_OBS, not proof about H. Copying OTHER_ALIGNED_BEGIN onto H is forbidden.

### 4.5 H20 on silicon

PASS_XSIM: 4th STOP with `w_valid && !w_ready` drops the whole word; `bix` returns to 0; token can still be UNSUP.

On H_OBS clean CLEAR, `drop_seen=0`, first word BEGIN — H20 **not observed** there (expected unless a word already sat).

On H: **UNKNOWN** (need pack-accepted word).

### 4.6 Arms never run

H13 full CDC board, H14 board, **H15 CLEAR gate NOT_RUN**.

---

## 5. Tokens (not classifiers by themselves)

| Token | Name | Notes |
|---|---|---|
| `c1ea50a5` | CLEAR ACK | Handshake worked. Not a pack class. |
| `c1ea50b5` | CLEAR BUSY | H17 incomplete pack. |
| `0200075a` | UNSUP reason 07 | H19 leftover **or** H20 drop **or** CLEAR eaten as pack opcode `0x43`. |
| `0200025a` | NAK_R02 | H A-01 after ACK; H16 XSim aligned BEGIN. |
| `0200015a` | MAG | H_OBS A-01; also H12 extra-after-BEGIN. |
| `0200085a` | SENTINEL | H10 V-03 both rates. |
| `010000a5` | GOLD | Pack dest-complete candidate. |

---

## 6. Pointers (raw evidence in this repo)

```text
results/arty_d/first_divergence_01/STATUS.md
results/arty_d/first_divergence_01/H9_JP2_INSTALLED/
results/arty_d/first_divergence_01/H9_JP2_REMOVED/
results/arty_d/first_divergence_01/H10_COMPARE.json
results/arty_d/first_divergence_01/H11_V04/
results/arty_d/first_divergence_01/H12_*.json
results/arty_d/first_divergence_01/H16_*.json
results/arty_d/first_divergence_01/H17_*.json
results/arty_d/first_divergence_01/H18_OFFLINE.json
results/arty_d/first_divergence_01/H19_*.json
results/arty_d/H_CLASSIFY_H19_H20/
results/arty_d/H_ILA_A/D_H_ILA_A.json
results/arty_d/H_OBS/D_H_OBS.json
results/arty_d/m4_mig_clear/D_PACK_VALIDATION_CLEAR.json
results/arty_d/m4_mig_clear/UART_PACK24_CLEAR_BOARD.jsonl
results/arty_d/pack_abi24_mig_dut/D_PACK_ABI24_MIG_DUT.json
CANON_BLUEPRINT/tb/native_ai/board/build_h20_4th_byte_bp/H20_4TH_BYTE_BP_XSIM.json
```

XSim Pack 24/24 dest-complete is **`mig_ui_bram`**, not `mig0`, not board (`PACK_ABI24_MIG_DUT_XSIM_PASS` only).

---

## 7. What would actually close COMMON_ROOT

A capture of **pack-accepted** `w_data` after CLEAR ACK **on bit `cf62102f…`**:

- `80000100` + leftover → H19 on H
- `3149414e` + drop → H20 on H
- `00800001` → OTHER (then NAK_R02 is a later ABI/dest problem, not first-word shift)

BASIC UART-dump **on that exact netlist** would be a **new identity**, not H. Standard-license ILA on H is the other legal observe path. Do not pad H to force GOLD.

---

## 8. Claim ceiling

`GOAL_AGENT_D` Pack board: **NOT_DONE**.  
`FEM persist`: **BLOCKED**.  
`COMMON_ROOT`: **UNKNOWN**.
