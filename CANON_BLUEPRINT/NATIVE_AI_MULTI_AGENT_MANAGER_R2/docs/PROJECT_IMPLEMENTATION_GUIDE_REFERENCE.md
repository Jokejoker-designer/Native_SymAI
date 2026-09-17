---
version: "1.1-candidate"
owner: AGENT_D
status: AUDITED_CANDIDATE
category: OPERATIONAL
last_modified: "2026-09-16T08:45:00+07:00"
---

# §33 — IMPLEMENTATION GUIDE

> This guide separates architecture locks from Arty-MVP engineering choices.
> No parameter choice becomes semantic truth merely because it is convenient for
> the first FPGA build.

## 33.1 Recommended implementation order

1. M1 Runtime Pack ABI / production loader / DDR write-drain/readback.
2. M2 Exact directory + forward/reverse posting indices.
3. M3 Bounded retrieval/walker + completeness tracking.
4. M4 ASTRA proof/status/conflict path.
5. M5 Pack/ABI + FE256 static acceptance.
6. M6 Human UART E2E with frozen host adapter.
7. M7 NSPF-X0 falsification.
8. M8 Developmental learning + capability/action binding.

Defer multi-walker, HDC proposal sidecar, DFX and HBM until profiling/causal
needs justify them.

## 33.2 CANON-LOCKED architecture rules

```text
binary/native core ABI; human language remains adapter-side
32-bit semantic references on R0.1 wire records (namespace/generation explicit)
FACT/SKILL/EPISODE/FAILURE/WEIGHT separation
T0/T1/T2 physical placement != epistemic class
forward + reverse indexes are first-class capabilities
Top-K/ranking != answer/proof
logical tick != physical clock
ASTRA owns legality/proof/conflict/completeness/status/promotion
host may map aliases/intents/units -> IDs but may not inject answer/winner/proof
semantic ACTION_INTENT must pass capability binding + legality/safety before actuation
```

## 33.3 Arty-MVP engineering choices — versioned, not timeless locks

| Parameter | R0.1 starting point | Rule |
|---|---|---|
| Board oscillator | 100 MHz board source | internal domains may differ; record actual clocks per build |
| Semantic ID active range | may use subset of 32-bit field | do not change wire/ontology meaning to save local memory |
| Relation ID | 16-bit candidate | change only by ABI version if exceeded |
| UART | 115200-8-N-1 common lab baseline | transport parameter; discover actual COM/JTAG per run |
| Cache | simple set-associative/LRU baseline acceptable | benchmark admission/eviction; TinyLFU/CMS only after evidence |
| Graph storage | indexed forward + reverse postings | page/record layouts versioned in pack ABI |
| HDC/CAM | optional accelerators | no truth authority; exact key verification required |

## 33.4 RTL/module skeleton

```text
rtl/native_ai/
  protocol/      frame_rx_tx, crc, sequence/txn
  loader/        manifest, region loader, write-drain, readback
  memory/        mig_adapter, cache, generation/coherence
  directory/     exact directory, forward/reverse postings
  working/       bindings, frontier, visited, candidate queues
  walker/        direct/reverse/value/context/provenance/multihop
  astra/         proof builder, status/conflict/completeness
  strategy/      qstar, spear (after semantic core stabilizes)
  skill/         skill table/executor
  fem/           failure capture/prototypes
  capability/    registry, binding, safety veto, primitive executor, effect readback
  event/         semantic event router/trajectory
  common/        shared types, counters, fixed-point helpers
```

Exact filenames/language (.sv/.v) are implementation choices; module contracts
and evidence are authoritative, not directory spelling.

## 33.5 Capability/action execution boundary

Physical control must follow [§05]:

```text
semantic ACTION_INTENT
→ capability class / target constraints
→ installed ModuleManifest match
→ ASTRA legality + safety veto
→ capability binding
→ Primitive Executor
→ physical command
→ effect/readback observation
→ episode/evidence
```

`NO_BINDING` or failed safety contract means `NO_ACTION`. A Knowledge Pack or
GEMINI message cannot invent a physical actuator.

## 33.6 Per-milestone workflow

```text
1 freeze CONTRACT + vectors/gold
2 record source lineage/tool versions
3 run reference/unit tests
4 run XSim integration
5 run OOC synthesis + assertions/CDC
6 run post-route when required
7 run board only for required silicon evidence
8 preserve raw logs/UART/bit/timing/readback
9 emit RESULT/EVIDENCE/SHA256SUMS
10 after any functional patch, rerun required lower gates + fresh full campaign
```

## 33.7 MIG/DDR rule

Use the Digilent/AMD board reference configuration appropriate to the exact
board revision. Wait for calibration before semantic DDR traffic. Do not assume
fixed random-access latency; instrument and measure command/data handshakes,
bytes/query, cache hits/misses and outstanding occupancy.

The R0.1 architecture does not require AXI specifically. Native MIG `app_*`, AXI
or another wrapper is acceptable if its contract is verified and does not hide
write completion/ordering.

## 33.8 Local toolchain/run manifest

Do **not** hard-code local paths, COM number, JTAG serial or license location in
architecture authority. Each run manifest discovers and records:

```text
repo/head/dirty state
Vivado version
board + FPGA part
JTAG identity
UART endpoint/config
clock domains
source/constraint/IP hashes
bit SHA256
ABI/schema/pack/case/adapter hashes
```

## Tóm tắt tiếng Việt

Implementation guide R0.1 phân biệt luật kiến trúc với lựa chọn MVP. Wire dùng
32-bit semantic ref; 24-bit/50 MHz/LRU không còn là chân lý canon. Physical action
bắt buộc qua capability binding + ASTRA/safety + effect readback.
