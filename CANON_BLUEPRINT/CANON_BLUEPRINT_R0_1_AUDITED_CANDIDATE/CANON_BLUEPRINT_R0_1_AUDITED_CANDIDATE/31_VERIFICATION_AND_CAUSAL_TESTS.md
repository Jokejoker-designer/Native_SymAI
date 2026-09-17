---
version: "1.1-candidate"
owner: AGENT_B
status: AUDITED_CANDIDATE
category: OPERATIONAL
last_modified: "2026-09-16T08:45:00+07:00"
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

`PACK_ABI_24_24_PASS` means all 24 preregistered integrity cases pass:

```text
4 valid pack/readback              -> LOAD_OK
4 schema-hash mismatch             -> LOAD_REJECT
4 ABI mismatch                     -> LOAD_REJECT
4 content-hash mismatch            -> LOAD_REJECT
4 page/record CRC corruption       -> reject or DATA_INTEGRITY_FAIL
4 generation / A-B atomicity       -> no partial/stale activation
```

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
| X0-15 | Capability Binding | remove/mismatch required hardware capability | `NO_BINDING/NO_ACTION`; no unsafe actuation |

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

## Tóm tắt tiếng Việt

FE256 = 256 case, Pack/ABI = 24 integrity case. SHUFFLE là đổi thứ tự case,
không phải ID permutation. Masked Slot che slot nhưng giữ support; ablation mới
là test bỏ support. UART E2E bắt đầu từ text người dùng và đóng băng host adapter.
