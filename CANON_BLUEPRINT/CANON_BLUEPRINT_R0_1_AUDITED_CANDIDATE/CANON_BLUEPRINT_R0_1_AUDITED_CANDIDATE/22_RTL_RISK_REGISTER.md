---
version: "1.1-candidate"
owner: AGENT_D
status: AUDITED_CANDIDATE
category: REFERENCE
last_modified: "2026-09-16T08:45:00+07:00"
---

# §22 — RTL / IMPLEMENTATION RISK REGISTER

> Risks are tracked as engineering evidence. Project/tool failures are not
> automatically runtime FEM records.

## 22.1 Risk register

| ID | Class | Risk | Severity | Mitigation / gate |
|---|---|---|---|---|
| R01 | Timing | Semantic path/MIG integration misses timing | HIGH | parameterized clocks, OOC early, pipeline/shared arithmetic; do not lock 50 MHz as architecture |
| R02 | Resource | BRAM working/cache state exceeds 135 BRAM36 | HIGH | per-block budget, OOC utilization, spill canonical state to T2 |
| R03 | Resource | comparator/router/proof logic consumes excessive LUT/routing | HIGH | bounded lanes, time-multiplex, hash/posting structures, post-route evidence |
| R04 | Memory | irregular DDR access dominates traversal | HIGH | measure exact workload; indexed postings; cache/admission only where evidence shows benefit |
| R05 | Coherence | stale T1 entry survives T2 generation switch | CRITICAL | generation tags, shadow fill, atomic activate/invalidate, cache-on/off parity test |
| R06 | Protocol | drop/duplicate/retry double-commits records/events | CRITICAL | sequence/session/txn identity, CRC, idempotent commit, assertions |
| R07 | Loader | ACK emitted before DDR write drain/commit | CRITICAL | outstanding write counter, FIFO empty + response completion before ACK |
| R08 | Status | UNKNOWN emitted when search is incomplete | CRITICAL | completeness tracking, exhaustive status vectors, ASTRA assertions |
| R09 | Proof | proof/provenance refs point outside active generation | CRITICAL | generation-bound proof validation and readback |
| R10 | Host authority | host adapter performs hidden answer/reasoning | CRITICAL | freeze adapter hash; log QueryRecord; Pack-A/B ablation; host code audit |
| R11 | Capability | semantic action reaches wrong/unverified physical actuator | CRITICAL | capability manifest/binding, ASTRA legality/safety, no-binding→no-action [§05] |
| R12 | Learning | unexecuted candidate receives credit | CRITICAL | executed-action-only credit + episode/step identity |
| R13 | Teacher | teacher proposal becomes FACT/weight/proof directly | CRITICAL | candidate-only teacher contract; false-teacher/anti-parrot tests |
| R14 | Meaning | ID/alias/clock/cache placement accidentally carries semantics | CRITICAL | ID permutation, alias replacement, clock invariance, cache parity |
| R15 | Benchmark | case-specific hardcoding / derived shortcut produces false PASS | CRITICAL | shuffled order, holdouts, Pack-A/B ablation, code review, immutable gold |
| R16 | Scaling | hub/posting explosion silently truncates search | HIGH | paged adjacency, explicit budget/completeness, SEARCH_INCOMPLETE |
| R17 | Integrity | Pack/ABI/schema/content/generation mismatch is partially accepted | CRITICAL | 24 Pack/ABI integrity gates, fail-closed loader |
| R18 | CDC | unconstrained/unsafe clock-domain path causes intermittent corruption | CRITICAL | CDC handshakes/FIFOs, constraints, assertions/report review |
| R19 | Toolchain | environment/version/path drift invalidates reproducibility | MEDIUM | run manifest + exact tool/source/bit/pack hashes; local paths not canon |
| R20 | Evidence | XSim/programming result is promoted to board semantic PASS | CRITICAL | acceptance ladder and owner-only final stamp [§32] |

## 22.2 Risk response protocol

When a project/RTL risk materializes:

1. Freeze the failing run and raw evidence.
2. Record it in project issue/evidence logs and the immutable failure campaign.
3. Classify the **first causal divergence** before editing.
4. Apply the smallest justified patch.
5. Rerun targeted lower gate, then fresh full campaign after a functional change.
6. Escalate architecture after repeated failure of the same causal class.

Only DUT/runtime experience intentionally captured by the Native AI data model
belongs in **FEM**. Vivado failures, stale documentation, agent mistakes and
build-environment issues remain engineering/project evidence unless a separate
research experiment explicitly models them as DUT experience.

## 22.3 Stop conditions

Stop and request architecture review if any of the following persists:

- semantic correctness depends on cache state, physical IDs or clock spacing;
- host reasoning is required to obtain the benchmark answer;
- T1/T2 generation coherence cannot be proven;
- proof/status must be weakened to achieve acceptable outputs;
- the only repair is modifying gold/threshold/case selection;
- three repair attempts in the same causal class fail without new evidence.

## Tóm tắt tiếng Việt

Risk register R0.1 tách lỗi engineering khỏi FEM runtime, bổ sung stale-cache,
host cheating, capability binding, authority/benchmark overfit, CDC và evidence
promotion. Không khóa 50 MHz như chân lý kiến trúc.
