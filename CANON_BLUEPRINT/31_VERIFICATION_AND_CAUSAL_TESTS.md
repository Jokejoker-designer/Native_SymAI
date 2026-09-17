---
version: "1.5-candidate"
owner: AGENT_B
status: AUDITED_CANDIDATE
category: OPERATIONAL
last_modified: "2026-09-16T18:50:00+07:00"
---

# §31 — VERIFICATION AND CAUSAL TESTS

> Verification is layered. Correct answers alone do not establish representation,
> causal dependence, learning or silicon correctness.

## 31.1 Test families

| Family | What it establishes |
|---|---|
| Unit / reference | codecs, indexes, operators, status rules |
| XSim integration | RTL subsystem behavior, not silicon |
| Pack/ABI integrity | fail-closed loader/schema/content/generation behavior |
| FE256 | static semantic correctness across 256 preregistered **cases** |
| Shuffle | order invariance of the FE256 case campaign |
| Causal ablation | runtime answer dependence on declared evidence |
| FE-UART-E2E-32 | human text→host adapter→wire→FPGA→result→render parity |
| NSPF-X0 | strong research falsification: representation/transfer/grounding/learning |
| Board | physical execution for the exact artifact/run manifest |

`XSIM_PASS != BOARD_PASS`, and `PROGRAM_PASS` proves configuration only.

## 31.2 Pack/ABI integrity campaign — 24 cases

`PACK_ABI_24_24_PASS` means the DUT matches all 24 preregistered integrity cases
in `verification/pack_abi24/pack_abi24_gold.py`. Generator `--selfcheck` is
**not** that stamp. XSim match is not `BOARD_PASS`.

```text
4 valid pack/readback              -> LOAD_OK
4 schema-hash mismatch             -> LOAD_REJECT
4 ABI mismatch                     -> LOAD_REJECT
4 content-hash mismatch            -> LOAD_REJECT
4 page/record CRC corruption       -> reject or DATA_INTEGRITY_FAIL
4 generation / A-B atomicity       -> no partial/stale activation
```

Locked case IDs (AGENT_B gold, independent of `python/m1/pack_vectors.py`):

| Group | CASE_ID | Expected |
|---|---|---|
| VALID | PA24-V-01..V-04 | LOAD_OK / OK; 128 B; gens 1, 2, 3 (2-region), 65535 |
| SCHEMA | PA24-S-01..S-04 | LOAD_REJECT / SCHEMA_MISMATCH (flip / zero / rival / schema_version=99) |
| ABI | PA24-A-01..A-04 | ABI_MISMATCH / BAD_MAGIC / HEADER_LENGTH(132) / TRUNCATED(64) |
| CONTENT | PA24-C-01..C-04 | LOAD_REJECT / CONTENT_MISMATCH |
| CRC | PA24-R-01..R-03 | LOAD_REJECT PAGE_CRC / MANIFEST_CRC / PAGE_CRC |
| CRC | PA24-R-04 | load may ACK; query DATA_INTEGRITY_FAIL / PACK_CRC; never UNKNOWN / status 0x00 |
| GEN | PA24-G-01 | two-step A-B COMMIT, active=2 |
| GEN | PA24-G-02 | pack_generation=0 → UNSUPPORTED |
| GEN | PA24-G-03 | pack_generation=0x10000 → UNSUPPORTED (no u16 truncate) |
| GEN | PA24-G-04 | stale query STALE_GENERATION; failed-B PAGE_CRC keeps active=2; rewind STALE_PACK_GENERATION |

ABI-group reason codes are **not** 4× `ABI_MISMATCH`; §04.6 splits magic /
header-length / truncate. S-04 is version uncoupled from identity (still
SCHEMA_MISMATCH). FPGA schema/content checks are stored-identity compares
(`FPGA_MANIFEST_ID_VERIFIED` + host SHA). Do not claim `FPGA_SHA256_VERIFIED`.

Appendix (not in these 24): `RESERVED_NZ`, `SENTINEL_MISMATCH`, `SEQ_GAP`,
`DRAIN_ERR`, `region_count=0`.

Harness (AGENT_B; Agent D binds DUT only):

```text
verification/pack_abi24/pack_abi24_gold.py --selfcheck --emit out
verification/pack_abi24/pack_abi24_gold.py --compare DUT.jsonl
verification/pack_abi24/tb_pack_abi24_xsim_compare.sv
```

`--compare` scores a 24-row JSONL of `case_id/outcome/reason/ack/reject/generation_flipped`
(+ `query_status`/`query_reason` for R-04/G-04). Open TB keeps `s_ready=0` so it
cannot false-PASS. A 24/24 XSim match is `PACK_ABI24_XSIM_PASS` only — not
`PACK_ABI_24_24_PASS` (post-PROGRAM) and not `BOARD_PASS`.

It does **not** mean 24 nodes + 24 edges.

## 31.3 FE256 static semantic benchmark

FE256 contains **256 cases**. Canonical composition:

| Class | Cases |
|---|---:|
| DIRECT | 48 |
| VALUE | 32 |
| REVERSE | 32 |
| MULTIHOP | 32 |
| CONTEXT | 24 |
| PROVENANCE | 16 |
| NEGATIVE | 24 |
| CONFLICT | 16 |
| IDENTITY | 16 |
| ABLATION | 16 |
| **TOTAL** | **256** |

Required core acceptance:

```text
256/256 explicit StructuredResult
wrong answer = 0
false refusal = 0
EMPTY = 0
timeout = 0
txn mismatch = 0
context leak = 0
identity leak = 0
proof/provenance valid = 100% where required
```

`255/256 = FAIL_PARTIAL` for the finite preregistered suite.

The benchmark graph/pack may contain any compliant number of semantic records;
**256 is the number of cases, not a node-count requirement**.

### Status correctness

- `UNKNOWN`: complete declared search scope, no verified support.
- `SEARCH_INCOMPLETE`: completeness not established because a budget/resource limit ended search.
- `CONFLICT`: conflicting relevant support is the expected result for conflict cases, not a campaign failure by itself.
- protocol/integrity faults never become UNKNOWN.

## 31.4 FE256 shuffle

The shuffle gate replays the **same preregistered cases in a deterministic
shuffled order** and requires the same semantic outcomes. It targets hidden
order/state dependence.

ID permutation and alias replacement are separate NSPF-X0 falsification tests;
they are not redefined as FE256 `SHUFFLE_PASS`.

## 31.5 Causal Pack-A / Pack-B ablation

Preregister a support claim, e.g. Pack A contains the only supporting edge and
Pack B removes exactly that support while preserving all other intended state.
The same canonical QueryRecord must change from the Pack-A supported result to
`UNKNOWN` (or another preregistered correctly supported status) under Pack B.

If the old answer survives with no alternate support, investigate:

```text
host answer injection
hard-coded/ROM answer
stale T1 cache
duplicate edge/derived fact
wrong generation switch
hidden state
```

## 31.6 Human UART E2E — 32 cases

The final human-facing E2E path is:

```text
human text
→ frozen/preregistered host adapter
→ QueryRecord
→ UART/frame
→ FPGA semantic/proof path
→ StructuredResult
→ UART/frame
→ host renderer
→ human text
```

Freeze/log host adapter source/hash/version. The adapter may resolve aliases,
query intent, direction and units to native IDs. It may not select the answer,
generate ASTRA proof/provenance, traverse a hidden answer graph or encode gold
answers in flags/IDs.

Required: 32/32 semantic parity and zero frame/CRC/timeout/txn/status distortion.

## 31.7 NSPF-X0 falsification suite

| ID | Test | Correct intervention | Pass condition / interpretation |
|---|---|---|---|
| X0-01 | ID Permutation | consistently remap raw semantic IDs | meaning/behavior preserved modulo remapped IDs |
| X0-02 | Alias Replacement | rename/multilingual aliases only | native semantics unchanged |
| X0-03 | Masked Slot | hide a frame slot/role while keeping supporting knowledge present | bounded resolver reconstructs/queries the slot from structure/evidence or returns lawful status; no answer table |
| X0-04 | Causal Ablation | remove declared support / intervention variable | dependent answer/behavior changes; alternate support handled explicitly |
| X0-05 | Clock-Rate / Spacing Invariance | legal physical clock/clock-enable spacing, same logical events | semantic result/proof invariant modulo timing metadata |
| X0-06 | Event Jitter Robustness | seeded delay/stall within preregistered envelope | no drop/dup/deadlock; same semantics when logical order unchanged |
| X0-07 | Reset/Restore | W0→train W1→reset→restore | baseline returns after reset; learned behavior returns after restore |
| X0-08 | Sensor Grounding | observe/action/effect before alias; attach/rename alias later | internal relation survives alias change and has causal/effect evidence |
| X0-09 | False Teacher / Anti-parrot | teacher proposes false/rephrased information | proposal remains candidate/rejected/conflicted; no direct FACT/weight/proof authority |
| X0-10 | Cache On/Off | same active generation/query with T1 semantic cache enabled/disabled | same semantic result/proof; only performance differs |
| X0-11 | Unseen Instance Transfer | train skill on instance A, test equivalent unseen B | transfer follows capability/class/effect, not hard-coded ID |
| X0-12 | 4→8→16 Structural Transfer | train bounded transition/procedure at 4-bit, disable primitive shortcut, test wider holdouts | transfer exceeds literal-table/script baseline |
| X0-13 | Runtime Knowledge Dependence | valid loaded pack vs absent/replaced support | result depends causally on active pack/generation |
| X0-14 | Stale Cache / Generation | switch generation while cached entries exist | stale generation cannot influence new result |
| X0-15 | Capability Binding | remove/mismatch required hardware capability | `NO_BINDING/NO_ACTION`; no unsafe actuation. **Not** the [§05.8] seven-name action-path set [§31.12] |

Passing this suite supplies **bounded empirical support** for the hypothesis; it
does not prove general intelligence or universal cognition.

## 31.8 Learning/teacher/sensor evidence

For any learned-state claim require, as applicable:

```text
W0/S0/K0 → behavior A
train/experience → W1/S1/K1 → behavior B
reset → A returns
restore → B returns
```

Teacher statements are source evidence/candidates, not FACT. Sensor readings are
observations, not automatically verified propositions. A predicted effect does
not substitute for readback.

## 31.9 Verification anti-patterns

Forbidden evidence shortcuts include:

- changing gold/threshold/case selection to rescue a candidate;
- counting renderer text as semantic proof;
- converting timeout/overflow into UNKNOWN;
- host injecting winner/proof/answer;
- materializing special derived facts solely to evade required reasoning;
- using program/startup HIGH as semantic board evidence;
- calling a benchmark PASS after only targeted regression without a fresh full run.

## 31.10 FE256 Python gold reference (AGENT_B)

Gold authority for XSim compare is the standalone script:

```text
verification/fe256/fe256_gold.py
```

It emits 256×32-byte `QueryRecord` and 256×48-byte `StructuredResult` using
[§03.9] Q-eval and [§04.12] encodings. Class mix is [§31.3]. Status histogram
of the frozen generator (Pack-A/B as declared per case):

```text
ANSWER 194 | UNKNOWN 34 | CONFLICT 16 | UNSUPPORTED_QUERY 8 | SEARCH_INCOMPLETE 4
```

CONFLICT rows emit `reason_code=DISTINCT_VERIFIED_REFS` (`0x30`), not `NONE`.
Status mix is unchanged.

NEGATIVE split: 12 UNKNOWN, 8 UNSUPPORTED_QUERY (4 unimplemented + 4 illegal
reverse), 4 SEARCH_INCOMPLETE (budget=1 on a 2-hop path). CONTEXT includes 6
HEAT-absent UNKNOWN contrasts. ABLATION is evaluated on Pack-B and must not
retain the Pack-A `ANSWER`.

Artifacts (regenerated deterministically by `--selfcheck --emit out`):

```text
fe256_queries.bin / fe256_gold_results.bin
fe256_queries.hex / fe256_gold_results.hex
fe256_cases.jsonl
fe256_pack_source.jsonl
fe256_shuffle_order.json   seed 0x0FE256
fe256_manifest.json
fe256_abi_constants.svh
```

Independence law: Agent D's pack compiler / RTL must not import this oracle as
the DUT encoder. DUT StructuredResult bytes are scored against
`fe256_gold_results.bin`. Dummy `fe256_cases.jsonl` files outside this directory
are not gold.

`python fe256_gold.py --selfcheck` must exit 0 before `FE256_GOLD_FROZEN`.
`--compare DUT.bin` scores a 12288-byte result image. This is host/XSim gold,
not `BOARD_PASS`. Histogram match is not `FE256_PASS`.

Residual gold defects (not this campaign's freeze; do not treat as PASS):

- FE-IDENTITY alias-A/B pairs currently share `subject_id` on the wire; they
  do not test identity-leak.
- DIRECT `answer_ref`/`proof_ref` are affine in the ID allocator; Pack-B
  ABLATION is the causal control.
- MULTIHOP `proof_ref` is `path_proof(kind, subject_id&0xFF)`, not the store
  edge `proof_id`.
- Q-INC-TIE / Q-DESC are **not** in the 256-case mix: zero
  `DATA_INTEGRITY_FAIL` **status** rows (`0x06`), and no row with
  `reason_code` `TIE_OVERFLOW` (`0x22`) or `INVALID_DESCRIPTOR` (`0x55`).
  Those reason bytes are never FE256 `status` values. Pack/ABI-24 covers
  loader integrity; SPEAR observables remain C-owned conditions. Independent
  Q-eval invariant gold is [§31.11].

## 31.11 ASTRA adversarial / status-proof Q-eval gold (AGENT_B)

Next B-owned READY verifier after Pack/ABI-24 gold. Not DUT RTL. Not a
ladder stamp. Independent of `python/m1/pack_vectors.py` and of the FE256
256-case histogram.

```text
verification/astra_adv/astra_adv_gold.py
verification/astra_adv/test_astra_adv_gold.py
verification/astra_adv/tb_astra_adv_xsim_compare.sv
verification/astra_adv/astra_adv_dut.sv
```

XSim harness is PROGRAM=NO and XSim≠board. Open `astra_adv_dut` keeps
`q_ready`/`s_ready` stuck 0 (fail-closed) until Agent D binds. Compare DUT
`StructuredResult` against this gold. Never treat status `0x22`/`0x55` as a
lawful primary status. `iverilog`-friendly: `$fscanf` mem, no string
localparam arrays.

`--selfcheck --emit out` writes per-case `.mem` plus
`astra_adv_expect.svh` / `astra_adv_fopen.svh`. Host compare:
`python astra_adv_gold.py --compare DUT.jsonl`.

Locked case IDs (namespace + Q-eval invariants [§03.9] [§04.12]). First 11
are retained; later IDs append coverage:

| CASE_ID | Expect |
|---|---|
| AA-ILLEGAL-00 | `status=0x00` is PROTOCOL_FAULT; never coerce to UNKNOWN/CONFLICT |
| AA-NS-ST22 | `status=0x22` illegal (TIE_OVERFLOW is reason only) |
| AA-NS-ST55 | `status=0x55` illegal (INVALID_DESCRIPTOR is reason only) |
| AA-TIE-01 | status `SEARCH_INCOMPLETE` `0x04` + reason `TIE_OVERFLOW` `0x22`; never status `0x22` |
| AA-DESC-01 | `invalid_count>0` → status `DATA_INTEGRITY_FAIL` `0x06` + reason `0x55`; never status `0x55` |
| AA-ANS-PROOF0 | verified support with `proof_ref=0` cannot be ANSWER |
| AA-INC-BUDGET | budget exhaust (hits may exist) → `SEARCH_INCOMPLETE`, not UNKNOWN |
| AA-UNK-ABSENT | complete empty scope → UNKNOWN, not SEARCH_INCOMPLETE |
| AA-CONFLICT-01 | ≥2 distinct verified refs → CONFLICT + reason `0x30`, not ANSWER |
| AA-ANS-DIAMOND | multiple proofs of the same `answer_ref` remain ANSWER |
| AA-CAND-01 | CANDIDATE-only complete scope → UNKNOWN / `CANDIDATE_ONLY`; never ANSWER |
| AA-NS-ST80 | `status=0x80` adapter-only; illegal on FPGA path |
| AA-TXN-ECHO | result `txn_id` must echo query; mismatch is protocol fault, not UNKNOWN |
| AA-QTRUNC-01 | truncated QueryRecord → `DATA_INTEGRITY_FAIL` `0x06` + `0x55`; never UNKNOWN |
| AA-QCRC-01 | bad QueryRecord CRC16-CCITT-FALSE → `0x06` + `0x55`; never UNKNOWN |
| AA-STALE-GEN | stale `knowledge_generation` → status `0x06` + `STALE_GENERATION` `0x54`; not UNKNOWN |
| AA-PROTO-01 | SEQ_GAP/TIMEOUT/CRC_ERROR protocol fault never maps to UNKNOWN |
| AA-REW-DUP | same causal reward `(episode_id,step_id,command_id,generation)` → at most one learner update |
| AA-REW-ID | reward identity mismatch → `reward_accepted=0`; no Q* credit |
| AA-KINV-01 | `k_invalid=1` → status `DATA_INTEGRITY_FAIL` `0x06` + reason `K_INVALID` `0x23`; never ANSWER/UNKNOWN; never status `0x23` |
| AA-FEM-CRC | COMMIT present + prototype CRC invalid → status `0x06` + `COMMITTED_CORRUPT` `0x56`; never UNKNOWN; never a valid committed prototype |

Field coupling checked by gold/selfcheck/XSim (FPGA path):

```text
ANSWER            → proof_ref≠0, answer_kind≠NONE, completeness=COMPLETE, conflict_ref=0
SEARCH_INCOMPLETE → completeness=PARTIAL; never UNKNOWN; never ANSWER
CONFLICT          → conflict_ref≠0, reason DISTINCT_VERIFIED_REFS 0x30 (not 0x00 as status)
FPGA illegal      → status ∈ {0x00, 0x22, 0x55, 0x80} is FAIL
```

`--selfcheck` is generator hygiene, not `ASTRA_ADV_PASS` / `FE256_PASS` /
`PACK_ABI_24_24_PASS` / `BOARD_PASS`. An `ASTRA_ADV_XSIM_PASS` banner is
simulation-only and is not those stamps.

## 31.12 Action-path acceptance names (echo [§05.8]; not stamped)

These seven names are the action-path acceptance set [§01.7] [§05.8].
They are B-owned ladder/test **names** pointing at A-owned results. This
section does **not** stamp any of them PASS. Live X0-15
`Capability Binding` / `NO_BINDING/NO_ACTION` is **not** this set.

1. `CAPABILITY_ENUM_PASS` — installed capability inventory exact.
2. `NO_BINDING_NO_ACTION_PASS` — absent capability cannot execute.
3. `SAFETY_VETO_PASS` — illegal command is blocked.
4. `COMMAND_READBACK_PASS` — command and observed effect distinguished.
5. `STALE_DESCRIPTOR_REJECT_PASS` — version/generation mismatch rejected.
6. `GEMINI_NO_ACTUATOR_AUTHORITY_PASS` — language path cannot drive executor.
7. `UNEXECUTED_NO_CREDIT_PASS` — non-executed action gets no learning update.
   Includes: refused overwrite of a still-pending proposal; duplicate
   credit apply after consume.

Action-precheck verdicts (`ASTRA_DENY`, `SAFETY_VETO`, `STALE_DESCRIPTOR`)
are not query `0x01–0x06` [§03.12]. Claim ceiling unchanged: naming these
tests is not `PACK_ABI_24_24_PASS`, `FE256_FULL_PASS`, `BOARD_PASS`, or
`FINAL_PASS`.

## 31.13 M2 posting width (not a 128-bit PostingEntry type)

```text
PostingEntry = 64 bit
2 × 64 = PACK_GROUP
PACK_GROUP ≠ 128-bit PostingEntry type
POSTING_ENTRY_WIDTH ≠ PACK_GROUP_WIDTH
QueryRecord / StructuredResult / SemanticEvent stay [§04] 256 / 384 / 192 bits
```

When extending §31 M2 posting tests, check **64-bit entries** (two packed
per 128-bit group). Do not promote `PostingEntry` to a 128-bit ontology.
Grouping is packing, not identity, not MIG freeze.

## Tóm tắt tiếng Việt

FE256 = 256 case, Pack/ABI = 24 integrity case, ASTRA adv = Q-eval invariant
(status ≠ reason; `0x22`/`0x23`/`0x55`/`0x56` không phải status) plus XSim harness
`tb_astra_adv_xsim_compare.sv` (fail-closed, PROGRAM=NO). Bảy tên [§05.8] là
bộ action-path; §31.12 chỉ echo tên, không đóng dấu PASS. `PostingEntry` = 64 bit;
`2×64 = PACK_GROUP` ≠ kiểu PostingEntry 128-bit. SHUFFLE là đổi thứ tự case,
không phải ID permutation. Gold Python `verification/fe256/fe256_gold.py` phát
binary 32/48-byte; Agent D phải khớp bit-exact trên XSim. Masked Slot che slot
nhưng giữ support; ablation mới là test bỏ support. UART E2E bắt đầu từ text
người dùng và đóng băng host adapter.
