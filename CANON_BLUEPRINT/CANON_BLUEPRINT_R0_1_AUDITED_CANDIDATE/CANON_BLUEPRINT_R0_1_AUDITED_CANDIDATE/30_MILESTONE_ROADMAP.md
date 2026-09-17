---
version: "1.1-candidate"
owner: AGENT_D
status: AUDITED_CANDIDATE
category: OPERATIONAL
last_modified: "2026-09-16T08:45:00+07:00"
---

# §30 — MILESTONE ROADMAP

> One milestone answers one primary causal question. Historical negative evidence
> is retained; milestone success cannot rewrite earlier FAIL evidence.

## 30.1 Evidence package law

Every milestone has at least four **control artifacts**:

```text
CONTRACT.md
RESULT.json
EVIDENCE.md
SHA256SUMS.txt
```

These are a minimum, not a maximum. A board/transport/memory milestone must also
retain the raw evidence needed to reproduce its claim, for example UART bytes,
program logs, bitstream/hash, timing/utilization reports, DDR readback, pack and
schema identities, test vectors and waveform traces.

Standard progression:

```text
SPEC / preregistration
→ independent/reference gold
→ RTL unit
→ XSim integration
→ OOC synth/timing
→ post-route when required
→ board only when silicon evidence is required
```

## 30.2 Arty MVP milestones

| # | Milestone | Primary causal question | Required output |
|---|---|---|---|
| M1 | **Runtime Pack ABI & Loader** | Can the production loader receive a versioned pack, commit it to DDR, drain outstanding writes, verify integrity/generation and read back sentinels? | loader + manifest/integrity + write-drain/readback evidence |
| M2 | **Exact Directory / Posting Index** | Can exact native IDs resolve to forward/reverse posting locations without semantic collision? | directory/index + full-key verification + cache/miss parity |
| M3 | **Bounded Retrieval / Walker** | Can a bounded walker retrieve direct/reverse/value/context/provenance and bounded multi-hop evidence with explicit completeness? | traversal + proof-parent tracking + SEARCH_INCOMPLETE behavior |
| M4 | **ASTRA Core** | Does ASTRA map machine evidence to legal proof/status/conflict/completeness outputs without utility/host override? | proof/status engine + attack vectors |
| M5 | **Full Evidence FE256** | Does the static semantic core pass all 256 preregistered FE256 cases plus Pack/ABI/runtime-load/readback requirements? | FE256/pack integrity evidence; 256 cases, not 256 nodes |
| M6 | **Human UART E2E** | Can human text pass through frozen host adapter→QueryRecord→UART→FPGA→StructuredResult→renderer with no host answer/proof authority? | 32-case human E2E + adapter hash/version |
| M7 | **NSPF Falsification** | Does behavior survive representational/timing/cache perturbations while remaining causally dependent on real support? | NSPF-X0 campaign |
| M8 | **Developmental Loop + Capability Binding** | Can executed physical experience create candidate relation/skill/failure state, survive reset/restore and transfer without teacher/host becoming truth authority? | bounded learning/skill/grounding/capability evidence |

## 30.3 Dependencies

```text
M1 → M2 → M3 → M4 → M5 → M6
                         ├→ M7
                         └→ M8 (with M6 and capability gate)
```

M7 and M8 may share infrastructure but their claims remain separate: static
semantic correctness does not prove developmental learning, and learning does
not retroactively certify FE256.

## 30.4 Resource-budget discipline

Any LUT/FF/BRAM/DSP table before synthesis is an **engineering estimate only**.
The actual budget is set by OOC/post-route reports for the exact candidate.
Reserve capacity for MIG/interface buffers, event FIFOs, proof scratch and
future debug/observability; do not allocate all 135 BRAM36 to semantic cache.

The implementation clock is likewise a measured design parameter. The Arty
board provides a 100 MHz system oscillator, but an internal semantic/MIG domain
may differ. Frequency is not semantic identity.

## 30.5 Developmental continuation after M8

Only after M8 evidence should the project consider:

```text
multi-walker / HBM partitioning
optional HDC proposal sidecar
advanced cache admission/profiler
sensor concept formation at larger scale
offline Semantic Hardware Specialization
DFX research
```

These are not prerequisites for the Arty correctness MVP.

## Tóm tắt tiếng Việt

Roadmap R0.1 sửa M1 thành runtime load vào DDR + write-drain/readback; FE256 là
256 case, không phải 256 node; UART E2E bắt đầu từ text người dùng; bốn artifact
chỉ là bộ control tối thiểu, raw evidence vẫn bắt buộc khi cần.
