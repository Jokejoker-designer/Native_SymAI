# Native Transfer Contract (NTC)

**Status:** CANDIDATE_DESIGN. Not implemented. Not a new bitstream identity.  
**Date:** 2026-09-19  
**Owner:** AGENT_D (product) / CURSOR_OWNER (this spec)  
**Parent spec:** [2026-09-19-native-symai-overall.md](2026-09-19-native-symai-overall.md)  
**Source of thinking:** UG934.pdf local + VHDLWhiz READY/VALID + Buoi_4/5/6 + Zynq Architecture — **transfer laws only**, not Cortex / GP0 / video IP.  
**Handshake digest:** [2026-09-19-axi-handshake-sources.md](2026-09-19-axi-handshake-sources.md)  
**Three architectures:** [2026-09-19-three-architectures.md](2026-09-19-three-architectures.md) (K1 TAP / K2 NTC not AXI clone / K3 dual-ingress)  
**Owner lock / independent eval:** [2026-09-19-independent-k1-lock.md](2026-09-19-independent-k1-lock.md)  
**Claim ceiling:** PASS_IMPLEMENTED design. `PACK_ABI_24_24_PASS=NO`. `MIG_PASS=NO`. `BOARD_PASS=NO`.  
**Hard gates:** Do not overlay identity H / U33 product. Do not kill live `xsim_u33m`. Do not add AXI Interconnect / SmartConnect / AXI UART. Do not edit AGENT_C RTL.

---

## 1. Problem this design exists to stop

The project does not mainly fail because Artix lacks a Cortex. It fails because **several transfer meanings share one wire**, then the next experiment cannot tell them apart.

Observed collapse (FACT from UART_R2 / MAG_CLASS / U32):

| Meaning that AXI keeps separate | What we currently mix |
|---|---|
| Slave idle vs slave accept-ready | U32 `pack_quiescent` ANDed `mig0.app_rdy` → CLEAR1 BUSY |
| Data valid vs last held data | `word_cdc32.b_data` holds BEGIN while `b_valid=0` |
| Write accept vs write complete | FIFO-empty / `app_rdy` used as dest-complete historically |
| New address-phase vs leftover stream | Extra exact BEGIN after CLEAR IDLE is **sufficient** for MAG `0200015a` (PASS_XSIM). Board leftover-after-CLEAR CONTRADICTED (probe P1). |
| Pulse response vs sticky status | `load_ack` stays 1 until next BEGIN |

Board MAG source is still **UNKNOWN**. BRAM five-V-04 is five GOLD. That is exactly what happens when channels are mixed: the expensive dest TB cannot classify a stream leftover.

**Success criterion for NTC:** every fail returns a **channel class** in ≤ one cheap TB (BRAM / CDC / UART), and a dest TB (mig0) is illegal until CH_RX and CH_CMD are CLEAN. No RTL “fix” without a named class.

---

## 2. ARCHITECTURE LOCK

```text
BOARD          = Arty A7-100T xc7a100tcsg324-1   (no PS, no GP/HP/ACP)
HOST           = UART 8N1 32-bit Pack words
DDR            = generated mig0 Native UI
                 app_addr[27:0] app_cmd app_en app_rdy
                 app_wdf_data/end/mask/wren app_wdf_rdy
                 app_rd_data / app_rd_data_valid
CLOCKS         = clk100 fabric ; ui_clk MIG PLL ~83.333 MHz
                 UART baud is clock-enable, not a clock
INTERCONNECT   = mig_ui_mux exclusive grant (pack A wins FEM B)
WINDOWS        = Pack slot0 0x0 ; slot1 0x0100000 ; FEM 0x0200000
FORBIDDEN      = AXI IP, 0x40000000 GP0, overlay qsc/UART on live identity,
                 AGENT_C RTL, FE256 feature creep, PASS self-stamp
```

NTC is a **semantic contract on this lock**, not a bus rewrite.

---

## 3. What AXI transfer thinking actually is

Ignore CPU bases. Keep these laws:

1. **Independent channels.** Address, write data, write response, read address, read data do not share ready/idle.
2. **VALID does not depend on READY.** A source may raise VALID while READY=0. A sink samples DATA only when VALID=1.
3. **Accept ≠ complete.** WREADY/WVALID handshake is not BRESP. `app_rdy` is not dest-complete.
4. **One address-phase per transaction.** A second AW while the previous txn is live is a new ID or an error — never silent reuse of stale WDATA.
5. **Stream has no address.** AXI-Stream is master→slave data only. UART is this. Addresses appear only after the Pack decoder issues MIG commands.
6. **Clock crossing is a FIFO problem.** Zynq HP uses 1 KB AFI FIFOs and converts to the PS clock. Data that sits in a hold register after VALID falls is **not** a beat.
7. **Classified response.** BRESP/RRESP is OKAY / SLVERR / DECERR — not one MAG token for leftover, bad magic, and dest fail.

---

## 4. Three approaches

### A — AXI-ize Pack (SmartConnect + AXI-Lite/Full)

Put GP-style slaves at `0x40000000`, wrap `pack_loader`.

- **Pro:** textbook.  
- **Con:** new identity, LUT/timing, does not create leftover classification, no CPU to mmap it.  
- **Verdict:** REJECT. Guard `G-NO-AXI-WITHOUT-BUS-REQUIREMENT`.

### B — Overlay another qsc/UART patch on the live identity

AND/OR strip `dest_ui_*`, pad bytes, resync.

- **Pro:** feels fast.  
- **Con:** already produced U32 CLEAR1 BUSY; MAG still UNKNOWN; destroys comparability with identity H / U33.  
- **Verdict:** REJECT. Overlay STOP still in force.

### C — Native Transfer Contract (recommended)

Keep UART + MIG UI. Give the path **five named Native channels**, a **scoreboard**, classified commit/reject, and a **cheap-first TB ladder**. Not an AXI-MM clone.

- **Pro:** one wire, one meaning; MAG leftover vs dest vs host separable; FEM persist reuses the same contract.  
- **Con:** product RTL is a **new identity** (not an overlay). Classifier TBs can start **now** without that identity.  
- **Verdict:** ADOPT as design. Implement in two layers (below).

---

## 5. Channel map (Native names; AXI is a warning not a port list)

```text
CH_RX      accepted Pack words     s_valid && s_ready
CH_CMD     decoded operation       BEGIN/REGION/PAGE/CLEAR after accept
CH_MEM_REQ DDR request             app_en / app_wdf_*
CH_MEM_RSP DDR completion/readback targeted lane
CH_STATUS  commit/reject event     pulse + reason  (not sticky load_ack)
OBS        probe only              last accepted word; never cdc.b_data while !b_valid
```

Physical path stays:

```text
Host UART 8N1
  → uart_rx_word (clk100, baud CE)
  → word_fifo32 DEPTH=128
  → word_cdc32 (clk100 → ui_clk, 1-deep toggle)
  → pack_loader (PAGE_RAM 64)
  → mig_ui32 (32b lane in 128b beat)
  → mig_ui_mux (pack wins)
  → mig0 Native UI
  → DDR3
CH_STATUS: commit_event → CDC ui→100 → uart_tx_word → Host
```

---

## 6. Contract laws (normative)

**L1 VALID-GATES-DATA.** A decoder, ILA, or TB may treat `*_data` as a beat iff `*_valid==1`. Sticky `word_cdc32.b_data` / FIFO `rd_data` after valid falls is **not leftover**. Phantom CDC TB already used this: `n_ph` requires `f_valid`.

**L2 IDLE ≠ ACCEPT-READY.**  
- `ch_rx_idle` = UART assembler idle AND fifo `empty` AND CDC `a_idle && b_idle && !b_valid`.  
- `ch_cmd_idle` = loader `S_IDLE` and no accepted opcode this cycle.  
- `mem_req_ready` = `app_rdy` / `app_wdf_rdy` (MIG). Never `system_quiescent`.  
- `pack_quiescent` **must not** AND `mem_req_ready`. U32 CONTRADICTED this.  
- U33 qsc dropped `app_rdy`, but first BEGIN steer still ANDs `dest_accept=qsc_c1`. That is the same mixed-meaning class at CH_RX unlock. NTC forbids it.

**L3 ACCEPT ≠ COMPLETE.**  
`mig_ui32` dest-complete = targeted 32-bit lane readback matches + `wr_outstanding==0`. FIFO-empty, `app_rdy`, `cmd_fifo_empty` are **not** complete (`PROXY_METRIC_FALSE_PASS_GUARD`).

**L4 ONE BEGIN TRANSACTION = ONE ACCEPTED BEAT.** BEGIN is not “BEGIN was seen on the wire.” GOLD/ACK is a `commit_event` then CH_STATUS, not sticky `load_ack`.

**Do not product-lock BARRIER / `R_LEFTOVER`.** Eligible only if TAP on `s_valid && s_ready` proves an extra exact `00800001` was accepted, or a previous-transaction word survived CLEAR as a real beat. Host `begin_n=1` means an extra BEGIN, if any, is after host TX.

Also FACT: `fifo_flush = uart_flush || st_fire`. Status fire of the previous txn must not reset CH_RX. Treat flush-during-ingress as OBS, not as BARRIER.

**L5 SPLIT STATUS.** Two signals, never one sticky bit doing both jobs:

| Signal | Shape | Meaning |
|---|---|---|
| `ack_pulse` | 1 cycle on `ui_clk` (CDC to 1 cycle on clk100) | edge for host |
| `status_hold` | level until next CH_CMD | ILA / LED / poll |
| `reason[7:0]` | stable from pulse until next CH_CMD | commit/reject reason |

Host must sample GOLD/NAK on **pulse**, not on level. Sticky `load_ack` until next BEGIN is a known lecture mismatch.

**L6 NO SILENT DROP.** If CH_RX `valid && !ready` for > `N` bit-times, count `ch_rx_backpressure`. Never drop the word. If CH_CMD is busy, backpressure FIFO — do not overwrite CDC hold and call it a new BEGIN. Unlocked drop of non-BEGIN (`00010001`) is a named CH_RX policy, not a loader accept.

**L7 CLASSIFIED RESPONSES.** Do not reuse MAG for leftover, dest fail, and trunc:

| Code | Class | Typical p0/p1 |
|---|---|---|
| `R_OK` | CH_STATUS GOLD | BEGIN, MAGIC |
| `R_BAD_MAGIC` | CH_CMD accepted BEGIN, hw0 ≠ `3149414E` | BEGIN, not-MAGIC |
| `R_LEFTOVER` **not locked** | only if TAP shows extra BEGIN accepted | BEGIN, BEGIN |
| `R_BUSY` | CLEAR while !quiescent | (U32 cell) |
| `R_SENTINEL` | CH_MEM_RSP mismatch | dest class |
| `R_UNSUP` / trunc / seq / crc | CH_CMD decode | existing |

**L8 WINDOW DISJOINT.** `slot_base + rg_ddr` must not alias `FEM_BASE=0x0200000`. Pack vs FEM coherency is mux grant, not ACP.

**L9 DEST TB IS LAST.** mig0 / ddr3_model (~70–85 min/GOLD) is legal only for CH_MEM_REQ / CH_MEM_RSP / CH_STATUS dest-complete. Illegal as the first test of leftover, CLEAR, UART, CDC.

---

## 7. Failure taxonomy (mandatory before any next experiment)

A fail that cannot be labeled is **not allowed to trigger RTL**.

```text
CH_RX      host extra byte/word, baud CE, assembler, FIFO drop vs hold, fifo_flush
CH_CMD     leftover BEGIN, CLEAR vs loader S_RX, opcode vs MAGIC
CH_MEM_REQ PAGE write, lane/mask, wr_idx
CH_STATUS  pulse vs sticky, CDC tx, GOLD/NAK packing
CH_MEM_RSP sentinel, calib, app_rdy dip, mux steal by FEM
CLK    ui_clk vs clk100 vs baud-as-clock (baud-as-clock = CONTRADICTED as unique MAG root)
HOST   Python window, WAIT_AFTER_ACK_S=0, COM overlap
```

Board MAG `0200015a` is **CH_CMD `R_BAD_MAGIC`** until TAP names the accepted sequence (A extra BEGIN / B wrong MAGIC / C missing MAGIC / G GOLD path). It is **not** automatically CH_MEM_RSP/mig0. BRAM five GOLD and mig0 five GOLD CONTRADICT dest=5th MAG. Leftover-after-CLEAR CONTRADICTED on probe P1.

---

## 8. Experiment ladder (cheap → expensive)

Do these in order. Skip a rung only with written CONTRADICTED on the previous.

| # | TB / probe | Channel | Cost | Stops if |
|---|---|---|---|---|
| 1 | UART loopback / word dump first 3 words after CLEAR ACK | CH_RX/HOST | seconds | extra BEGIN on wire |
| 2 | `tb_u33_leftover_begin_mag` (already PASS_XSIM: inject sufficient) | CH_CMD | seconds | inject mechanism known |
| 3 | `tb_u33_phantom_cdc` (already: no phantom without inject) | CH_RX CDC | seconds | autogenous CDC leftover CONTRADICTED on BRAM |
| 4 | Scoreboard TAP: `s_valid&&s_ready` log 8 words around CLEAR→V-04 (BRAM dest) | CH_CMD | minutes | accepted sequence A/B/C/G |
| 5 | Same TAP on **board ILA or UART dump identity** (new identity or debug bit, not H) | CH_RX/HOST | program | accepted sequence on silicon |
| 6 | mig0 five-V-04 (already five GOLD) | CH_MEM_RSP | hours | dest MAG CONTRADICTED |

Rule: **do not start another multi-hour dest sim to answer a CH_RX question.** Live `xsim_u33m` may finish; it is not a new start.

---

## 9. Observability contract (OBS)

Not product Pack ABI. A debug identity may expose a 32-bit tap:

```text
{ loader_state[3:0], opcode[7:0], s_valid, s_ready,
  cdc_b_valid, fifo_empty, qsc, dest_rdy,
  fifo_flush, dest_accept }
```

Plus the last **accepted** word (`s_valid && s_ready`), never `cdc.b_data` while `!b_valid`.

CLEAR must not reset generated `mig0`. `debug_clear` already resets loader+ui32 only — keep that (VALIDATION_CLEAR ≠ MIG_RESET).

---

## 10. Implementation layers (approval required)

**Layer 0 — now, no product RTL.**  
Adopt this spec as the stop-fail process. Tag every UART_R2 result with `CH_*`. Add TAP TB (rung 4) on BRAM dest. Do not overlay U33. Do not stamp PASS.

**Layer 1 — new identity only after owner YES.**  
RTL that encodes L5 pulse+hold, L1 sampling, and L4 BARRIER/`R_LEFTOVER` **only if TAP showed extra BEGIN accepted**. New SHA. Ban overlay onto `cf62102f` / U33 frozen FAIL_BOARD. FEM persist uses L8 + same CH_STATUS/CH_MEM_RSP.

**Layer 2 — FEM persist.**  
Blocked until Pack is B-classifiable **or** Layer 0 has classified MAG as HOST/CH_RX (not dest). Then FEM on mux with window guard TB.

This spec does **not** authorize Layer 1 in this turn.

---

## 11. Non-goals

- Cortex-A9 / PYNQ overlay / GP0 base addresses  
- AXI UART Lite / 16550 as Pack PHY  
- Product-strip `dest_ui_*` without owner overlay identity  
- Speeding the live mig0 kernel with extra cores  
- `PACK_ABI_24_24_PASS` from this document  

---

## 12. Stop conditions

- HALT RTL if the next change cannot name `CH_*`.  
- HALT if a dest TB is started to test leftover/CLEAR/UART.  
- HALT if anyone proposes AXI IP to close MAG.  
- HALT overlay on live identities.  
- Live xsim 44192 / xsimk 5488: do not kill.

---

## 13. Evidence for this spec

- PDF `D:\Jettking\PYNQ z2\Zynq_Architecture.pdf` sha256 `967d4756c1875be0409e94e3e3b63575a7d404db048da7a6f6fd820236986468` slides 12-20…12-35.  
- `pack_mig_bind.sv` U33 qsc = `!loader_busy && !ui_busy && outstanding==0`.  
- `word_cdc32.sv` hold + `b_valid`.  
- `mig_ui32.sv` lane/beat + dest readback.  
- `MAG_CLASS.md` leftover inject sufficient; phantom CDC negative; board source UNKNOWN.  
- Prior lessons: `BUOI5-AXI-HANDSHAKE-NOT-BUS-REWRITE`, `BUOI-4-6-NO-SMARTCONNECT`.  
- `D:\FPGA\UG934.pdf` sha256 `cd0f0cafff7e4084f2e7453c8473c1e6343e58f3388a438011402abfafa6212d` p.6 beat; p.89 registered READY lag; p.91 READY_out vs READY_in.  
- VHDLWhiz: RV not for CDC; AXI VALID holds until handshake.
