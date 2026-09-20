# Three architectures from the handshake corpus

**Status:** CANDIDATE_DESIGN. Not RTL. Not a PASS stamp.  
**Date:** 2026-09-19  
**Corpus:** UG934.pdf (`cd0f0caf…`) · VHDLWhiz READY/VALID · Buoi_4/5/6 · Zynq Architecture 12 · **IHI0022E** (`0a88e1f4…`) · NTC · mig0 five GOLD [`6b69435`](https://github.com/Jokejoker-designer/Native_SymAI/commit/6b69435) · U33_REPROG MAG r2 host begin_n=1 [`5daba27`](https://github.com/Jokejoker-designer/Native_SymAI/commit/5daba27)

**ARCHITECTURE LOCK**

```text
CHIP     Artix-7 Arty A7-100T   (no Cortex, no GP0 0x40000000)
DDR      generated mig0 Native UI  28-bit addr, 128-bit beat
HOST     UART 8N1 32-bit words
CLOCKS   clk100 ; ui_clk ~83.333 ; baud = CE not ACLK
MUX      Pack A wins FEM B
C RTL    frozen size   FE256 = reference only
PASS     PACK_ABI_24_24_PASS=NO  MIG_PASS=NO  BOARD_PASS=NO
```

**FACT that all three architectures must obey**

- Beat = `VALID && READY` same cycle; sample DATA only then (UG934 p.6, Buoi_5 p.14, VHDLWhiz).
- VALID must not depend on READY; AXI VALID holds until the beat (Buoi_5 p.15, VHDLWhiz/AMBA).
- Ready/valid is **not** a CDC (VHDLWhiz) → keep `word_cdc32`.
- Registered READY can deliver **one extra beat** (UG934 p.89) → leftover BEGIN class.
- Do not hold idle until dest READY (UG934 p.91, U32 BUSY CONFIRMED).
- Framing is **one accepted beat** (UG934 SOF/EOL) → not sticky `load_ack`.
- Stream has **no DDR address** (Zynq AXI-Stream, Buoi_4 MM vs Stream).
- **V04_4 GOLD dest=generated mig0** CONTRADICTS “board MAG = 5th dest commit”. Dest-centric architectures that exist only to “fix the 5th MIG write” are **wrong**.
- Probe 20260919T132346Z: after CLEAR, idle and dummy n=0. MAG concurrent with V-04. Leftover BEGIN **sitting after CLEAR** is CONTRADICTED for that hop. Host `begin_n=1`.
- **IHI0022E A3.2–A3.3:** five independent channels; source must not wait for READY; B after WLAST; write data may precede address (register slice); deadlock if AW waits W and W waits AW. ACE out of scope. AXI-Stream is **not** this PDF (IHI0051). See `2026-09-19-ihi0022e-handshake.md`.

**Owner lock 2026-09-19:** K1 TAP on `s_valid && s_ready` now. No BARRIER / `R_LEFTOVER` until TAP proves an extra BEGIN was **accepted**. K2 = Native Transfer Contract (`CH_RX/CMD/MEM_REQ/MEM_RSP/STATUS`), not an AXI-MM clone. Independent eval: `2026-09-19-independent-k1-lock.md`.

---

## K1 — Stream-native (observe accepted beats)

**Idea:** UART is a stream. BEGIN is **one accepted beat** (`s_valid && s_ready`), not “BEGIN was seen on the wire.” MAG class is the loader-accepted sequence after CLEAR, not FIFO contents and not the status token.

```text
Host UART 8N1
  → uart_rx_word (clk100, baud CE)
  → word_fifo32 (almost-full READY, no drop)
  → word_cdc32 (toggle CDC, not RV across clocks)
  → pack_loader TAP: log DATA only when s_valid && s_ready
  → mig_ui32 lane/mask → mux A → mig0
CH_STATUS later: commit_event → status response (not sticky load_ack)
```

**Do now:** TAP observe-only, same product SHA. After CLEAR ACK, record accepted sequence: BEGIN / MAGIC / REGION / PAGE. Classify:

```text
A  BEGIN, BEGIN, …          extra BEGIN accepted
B  BEGIN, not-MAGIC         wrong word accepted as MAGIC
C  BEGIN, <gap>, next_word  MAGIC missing
G  BEGIN, MAGIC, …          GOLD path; extra BEGIN not an accepted beat
```

**Do not lock:** BARRIER before next BEGIN; `R_LEFTOVER`. Only if TAP returns A (or a previous-transaction word that survived CLEAR).

**Use when:** MAG is still unclassified as an **accept** sequence. Current board: leftover-after-CLEAR CONTRADICTED; MAG concurrent with V-04; host begin_n=1.

**Risk:** TAP identity must be named if it changes nets; observe-only preferred.

---

## K2 — Native Transfer Contract (not an AXI-MM clone)

**Idea:** One wire, one meaning. Five **Native** channels. AXI/IHI0022E is a warning about mixed READY/IDLE/COMPLETE, not a port list.

| Channel | One meaning |
|---|---|
| CH_RX | accepted Pack words (`s_valid && s_ready`) |
| CH_CMD | decoded operation |
| CH_MEM_REQ | DDR request (`app_en` / `app_wdf_*`) |
| CH_MEM_RSP | DDR completion / lane readback |
| CH_STATUS | commit/reject **event** + reason |

Law from U32: `mem_req_ready` (`app_rdy`) is never `system_quiescent`. Interconnect stays `mig_ui_mux`. Windows `0` / `0x0100000` / `0x0200000`. No `s_axi`. No AW/W/AR unless Pack needs those phases.

**Do:** New SHA only after TAP returns extra BEGIN **accepted**, or owner YES. Never overlay U33/H. Do not product-lock `R_LEFTOVER` yet.

**Use when:** we need named commit/reject after the accept sequence is known.

**Risk:** Calling this AXI-MM invites SmartConnect. Forbidden.

---

## K3 — Dual-ingress common runtime

**Idea:** Two **logical** ingresses on the same UART PHY so a leftover Pack BEGIN cannot be a Query, and Query cannot look like Pack. Shared dest mux and DDR windows stay.

```text
UART PHY (one FTDI)
        ├─ Pack namespace   OP_BEGIN/REGION/PAGE/CLEAR
        └─ Query namespace  QueryRecord → directory → posting → ASTRA → StructuredResult
DDR: pack_mig_bind || fem_req_ui → mig_ui_mux → mig0
FEM persist: only after Pack is B-classifiable
FE256 dedicated engine: reference; retire if common runtime 256/256
```

**From the books:** Zynq Stream vs MM split; UG934 timing on a **side channel** (Lite) vs pixels on Stream — here: Query vs Pack namespaces, not AXI-Lite.

**Do:** Query-only work in parallel (old P3) **without** FEM persist and **without** stealing Pack class work.

**Use when:** MAG must not freeze the whole product.

**Risk:** Two D threads. Opcode collision if namespaces are not hard-split.

---

## How to choose

| If | Pick |
|---|---|
| Need MAG class this week | **K1** TAP first |
| Leftover `valid` BEGIN shown, need product handshake | **K2** new identity |
| Want query/common-runtime to move while Pack classifies | **K1 + K3** (K3 query-only) |
| Tempted to add AXI IP or overlay U33 | none of these |

**Recommendation:** **K1 TAP observe-only** (owner lock). No BARRIER until TAP shows extra BEGIN accepted. **K2 NTC** after that class. **K3** query-only beside TAP.

Sequence: `K1 TAP → A/B/C/G → BARRIER only if A → NTC SHA → Pack B-classifiable → FEM persist`.
