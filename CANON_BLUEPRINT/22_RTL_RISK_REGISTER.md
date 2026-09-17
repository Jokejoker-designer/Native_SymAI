---
version: "1.1-candidate"
owner: AGENT_D
status: AUDITED_CANDIDATE
category: REFERENCE
last_modified: "2026-09-17T01:38:00+07:00"
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
| R07 | Loader | ACK emitted before dest write drain/commit | CRITICAL | dest-complete = dest readback + matching txn/generation (outstanding retirement after matching response). FIFO-empty is a local/test hint only, not dest-completion authority (PROXY_METRIC_FALSE_PASS_GUARD). `load_ack` forbidden while dest outstanding. |
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
| R21 | Timing | post-route `hold_fix` / `ExploreWithHoldFix` skip when WHS already MET (fabric WHS +0.021, 0-level FEM `req_wdata`→`wdata_r`) | LOW | freeze `R2_TOP_ROUTE_BASELINE_WHS_0P021`; no delay-chain RTL; no false paths; no ROUND 3; not TIMING_PASS |
| R22 | Timing / mapping | FE256 R0 OOC LUT ROM + combo `S_FINISH` (unplaced WNS −75.723, 144 levels, 0 BRAM) | HIGH | R1 reference freeze `FE256_R1_REFERENCE_FREEZE`; no FE256 feature creep; not TIMING_PASS |
| R23 | Architecture | dedicated FE256 engine remains on integrated freeze top after POST-GUARD | HIGH | NEW candidate `arty_a7_r2_top_m4_query_result_candidate` has no `fe256_query_path`; freeze top still YES; retire only after 256/256 + legal timing; not FE256_PASS |

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

## 22.4 M1 first-slice watchlist (2026-09-16)

Active on the `pack_loader` bag. Not FEM records.

| ID | Watch | First falsifier |
|---|---|---|
| R07 | ACK before dest drain | TB holds dest (`force_fifo_empty` / stall `mem_resp`); `load_ack` must stay 0. FIFO-empty must not ACK. |
| R17 | Partial/mismatch pack activates generation | bad magic/ABI/CRC vectors; `active_generation` unchanged |
| R06 | Duplicate DATA_PAGE seq double-commits | duplicate seq → reject; no second write |
| R19 | Toolchain path drift | run manifest records `C:\2026.1\Vivado` as **local** metadata only |
| R20 | XSim promoted to board PASS | this bag emits `XSIM_SMOKE` / OOC only |
| R22/M2 | dir/post async-ROM LUT | OOC of `query_posting_bind` must show RAMB not LUT ROM; last-ID XSim must hit |

§04.6 now locks ManifestHeader **128 B / reserved=12**; 132 B is a failed candidate (Agent B).
M1 loader already decodes that layout as **CANDIDATE**. Dest-complete 24/24
(`PACK_ABI24_MIG_DUT_XSIM_PASS`) is XSim only; not `PACK_ABI_24_24_PASS`.
Board sequential (`PACK_ABI24_BOARD_SEQ_CANDIDATE` 2/24) is sticky-state
diagnostic, not gold. Board isolated (`PACK_ABI24_BOARD_ISOLATED_CANDIDATE`
14/24) is raw ACK/NAK for B; D does not self-stamp. If Agent B changes the
frozen header, patch **only** the header decoder (one unknown).

## Tóm tắt tiếng Việt

Risk register R0.1 tách lỗi engineering khỏi FEM runtime, bổ sung stale-cache,
host cheating, capability binding, authority/benchmark overfit, CDC và evidence
promotion. Không khóa 50 MHz như chân lý kiến trúc.
