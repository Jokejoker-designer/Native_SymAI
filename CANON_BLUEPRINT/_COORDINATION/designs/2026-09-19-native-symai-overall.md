# Native_SymAI — overall design and three usable options

**Status:** CANDIDATE_DESIGN. Not implemented. Not a PASS stamp.  
**Date:** 2026-09-19  
**Owner:** AGENT_D product / CURSOR_OWNER this spec  
**Child spec:** [2026-09-19-native-transfer-contract.md](2026-09-19-native-transfer-contract.md) (NTC / AXI transfer laws)  
**Claim ceiling:** `PACK_ABI_24_24_PASS=NO` `MIG_PASS=NO` `BOARD_PASS=NO` `FEM_PERSIST_PASS=NO` `FE256_PASS=NO` `ASTRA_PASS=NO`

This document is the **system** design. NTC is the **transfer** contract inside it. Neither authorizes overlay, AXI IP, AGENT_C RTL edits, FE256 freeze overwrite, or killing live `xsim_u33m`.

---

## 1. What we are building

A **common runtime** on Arty A7-100T (Artix-7 fabric, no Cortex, no Zynq PS):

```text
Host (UART Pack ABI + QueryRecord)
        │
        ▼
   clk100 fabric
        │
        ├─ Pack loader ──► mig_ui32 ─┐
        │                             ├─ mig_ui_mux (Pack wins) ─► mig0 Native UI ─► DDR3
        └─ FEM T2 ──────► fem_req_ui ┘         windows: slot0 / slot1 0x0100000 / FEM 0x0200000
        │
        └─ Query walk: directory → posting → bounded frontier → ASTRA → StructuredResult
```

C blocks (Q*, SPEAR, FEM lifecycle) stay **frozen size** (`theta=64`, actions=8, features=8, `K_HARD_MAX=9`, FEM `N_RAW=4`). FE256 R1 freeze is **reference only**; product target is the common runtime executing the same 256 cases without a dedicated FE256 engine.

Ethernet remains **ON_HOLD**. Host transport is UART.

---

## 2. ARCHITECTURE LOCK

```text
CHIP        xc7a100tcsg324-1 Arty A7-100T
DDR         generated mig0 Native UI (28-bit app_addr, 128-bit beat, 32-bit lane)
HOST        UART 8N1 Pack words + QueryRecord / StructuredResult
CLOCKS      clk100 ; ui_clk ~83.333 MHz ; baud = CE not clock
MUX         exclusive grant, Pack A > FEM B
C RTL       ON_DEMAND, PRIMARY_QUEUE CLOSED — do not edit
FE256       REFERENCE_FREEZE; no feature creep; retire from final top only if
            common runtime 256/256 bit-exact AND timing legal AND no canon violation
PASS        D does not self-stamp PROGRAM/BOARD/MIG/PACK_ABI/ASTRA/FE256
```

AXI thinking used here is **channel / handshake / dest-complete**, not GP0 `0x40000000`. Handshake sources: [2026-09-19-axi-handshake-sources.md](2026-09-19-axi-handshake-sources.md) (`UG934.pdf` local).

---

## 3. Why an overall design now

Pack24 is two stacked classes, not one bug:

1. **U32 CLEAR1 BUSY** — `pack_quiescent` ANDed `app_rdy` (CONFIRMED). U33 removed that AND. Option A on silicon **CONTRADICTED** as Pack24 close.
2. **U33 MAG** — 4 GOLD then 5th `0200015a` = `R_BAD_MAGIC`. Leftover exact BEGIN is **sufficient** (PASS_XSIM). Autogenous CDC leftover **CONTRADICTED** on BRAM. Board leftover source **UNKNOWN**. BRAM 5× GOLD. **generated mig0 five GOLD** `$finish` 12207195 ns V04_4 GOLD — dest=mig0 5th MAG **CONTRADICTED**.

FEM persist is **blocked** until Pack is B-classifiable. If we keep shipping unclassed overlays, FEM never starts and common-runtime FE256 never runs.

The overall design therefore has one non-negotiable process law:

> **No product RTL and no dest-hour TB until the fail has a channel class (`CH_S|AW|W|B|AR|HOST`).**

---

## 4. Target runtime (final silicon)

| Stage | Contract | Owner |
|---|---|---|
| Ingress | UART word `valid/ready` (CH_S). No DDR address on the wire. | D |
| Pack | BEGIN/REGION/PAGE → DDR windows. BARRIER before next BEGIN. GOLD/NAK = CH_B. Dest-complete = lane readback (CH_AR). | D |
| Query | QueryRecord → directory/index → PostingEntry64 → bounded walk → frontier | D (M2/M4 candidates) |
| Decide | ASTRA → StructuredResult. Fail-closed SEARCH_INCOMPLETE until proven otherwise. | D + B gold |
| Memory | FEM persist in `FEM_BASE`, mux-shared with Pack, T2 `t2_ready` dest-complete | D after Pack class |
| Strategy | Q* / SPEAR at approved size only | C frozen |

`PACK_ABI_24_24_PASS` still requires frozen identities + 24/24 CLEAR→V-04 GOLD n=4 + dest-complete through `pack_mig_bind`. This spec does not grant that stamp.

---

## 5. Three usable options

AXI-ize and live-identity overlay are **not** options (already REJECTED). These three can actually be executed on this board.

### P1 — Observe-first (Layer 0)

**Do:** Keep current U33 RTL and live `xsim_u33m`. Tag every result `CH_*`. Add TAP TB: log words accepted (`s_valid && s_ready`) for 8 beats after CLEAR ACK on **BRAM dest**. Dump first host words after ACK. Wait for live mig0 V04_4 / MAG / `$finish` as rung 6 only.

**Do not:** Overlay qsc/UART. New Pack identity. FEM persist. AXI.

| | |
|---|---|
| Time to first class | hours–1 day (TAP is minutes; live xsim may already be on V04_4) |
| New bitstream | No (TAP TB sim-only). Optional later debug identity ≠ H for board TAP |
| Risk | MAG stays UNKNOWN until TAP/board dump |
| Unblocks | Decision for P2 vs dest-repair; stops unclassed RTL |

**Use when:** we still do not know whether MAG is leftover/host vs dest. **That is now.**

### P2 — New-identity Native Transfer Contract

**Do:** New SHA (not overlay H / U33). Encode NTC L1–L9: BARRIER, `R_LEFTOVER` ≠ `R_BAD_MAGIC`, `ack_pulse` + `status_hold`, qsc never ANDs `app_rdy`, VALID-gates-data. Same MIG UI, same UART PHY class.

**Do not:** SmartConnect, `0x40000000`, product-strip `dest_ui_*` on old identity.

| | |
|---|---|
| Time | days after MAG class (or wasted weeks if MAG is dest/mig0) |
| New bitstream | Yes, new identity, new lease |
| Risk | If MAG is CH_AR/mig0, leftover RTL will not close Pack24 |
| Unblocks | Classified NAK; cleaner FEM persist handshake |

**Use when:** Layer 0 shows leftover **valid** BEGIN (CH_AW/HOST), or owner accepts a new identity to encode the contract even before silicon leftover is seen — still **not** as an overlay.

### P3 — Dual-track: classify Pack + advance common runtime without FEM persist

**Do:** P1 on Pack (mandatory). In parallel, only work that **does not** share dest-commit with Pack MAG: M4 QueryRecord→StructuredResult evidence, directory/posting XSim, ASTRA fail-closed stays fail-closed. No FEM persist. No Ethernet. No FE256 polish.

| | |
|---|---|
| Time | Pack class on P1 clock; query work can proceed same days |
| New bitstream | Query candidates already exist (M4 / M4+mig). Do not program without lease |
| Risk | Two D threads; must not steal the live xsim or Arty lease |
| Unblocks | Common-runtime progress without pretending Pack24 is closed |

**Use when:** owner wants the project to move while MAG is being classified — **with an explicit wall**: FEM persist and Pack identity changes stay on P1/P2.

---

## 6. Recommendation

**Now: P1.** It is the only option that cannot make MAG harder. Live mig0 five is already the expensive dest rung; do not start a second one.

**Next: P2 if and only if** TAP/host dump shows a **valid** leftover BEGIN (or owner YES for contract identity after that). If live mig0 5th is MAG with p0/p1 dest-class, P2 leftover RTL is the wrong patch — stay on CH_AR.

**P3 is optional parallelism**, not a Pack24 close. Allowed only if it does not kill xsim, overlay, or start FEM persist.

Sequence:

```text
P1 TAP + live xsim finish
    ├─ leftover/host valid BEGIN  → P2 new identity → Pack B-classifiable → FEM persist
    ├─ dest/mig0 MAG with p0/p1   → dest class repair (still NTC laws, not AXI)
    └─ still UNKNOWN after TAP    → board dump identity ≠ H (P1 rung 5), still no overlay
P3 may run beside P1 for query-only work
COMMON_RUNTIME_FE256 gate only after Pack no longer blocks media/recovery
```

---

## 7. Stop conditions (all options)

- No RTL without `CH_*`.
- No overlay on `cf62102f` / U33 FAIL_BOARD.
- No AXI IP / SmartConnect / AXI UART.
- No AGENT_C size change (C_SCALE_GUARD).
- No FE256 freeze overwrite.
- Do not kill xsim 44192 / xsimk 5488.
- Do not stamp PASS from this document.

---

## 8. What “done” looks like (still not stamped)

| Gate | Evidence required |
|---|---|
| MAG class | p0/p1 + `valid` at loader or host dump; named CH_* |
| Pack B-classifiable | 24/24 GOLD n=4 dest-complete through bind on frozen identity |
| FEM persist | window-guard TB + T2 dest-complete on mux; Pack class first |
| Common-runtime FE256 | same B 256-case set, bit-exact, no dedicated engine, no case weaken |

Until those exist, options P1–P3 are **how we work**, not a claim that the product passed.
