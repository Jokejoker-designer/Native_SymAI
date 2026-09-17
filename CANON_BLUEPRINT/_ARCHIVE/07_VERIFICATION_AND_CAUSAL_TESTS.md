\# 07\_VERIFICATION\_AND\_CAUSAL\_TESTS

&nbsp;

\#\# NATIVE AI DEVELOPMENTAL HARDWARE R1

&nbsp;

Status: RESEARCH / FORWARD DESIGN

Target: Arty A7-100T / XC7A100T-CSG324-1

&nbsp;

\---

&nbsp;

\#\# 1\. Mục tiêu verification

&nbsp;

Verification không chỉ hỏi “output đúng không?”. Với Native AI, phải tách ít nhất 6 câu hỏi:

&nbsp;

\`\`\`text

1\. Representation có đủ tín hiệu không?

2\. Action/candidate nào thật sự được chọn?

3\. Credit có đi đúng causal path không?

4\. Learned state có làm thay đổi behavior không?

5\. Behavior có transfer hay chỉ memorize ID/script?

6\. ASTRA/safety có chặn learned preference khi preference sai không?

\`\`\`

&nbsp;

Mọi test quan trọng phải trả lời một trong các câu hỏi trên.

&nbsp;

\---

&nbsp;

\# 2\. Verification ladder

&nbsp;

Dùng ladder duy nhất:

&nbsp;

\`\`\`text

L0  pure reference

L1  RTL unit

L2  XSim subsystem

L3  integrated hierarchy

L4  OOC synthesis/timing

L5  post-implementation

L6  physical board

\`\`\`

&nbsp;

Không đưa test lên L6 nếu câu hỏi đã trả lời chắc chắn ở L1–L4.

&nbsp;

Board chỉ cần khi bằng chứng phụ thuộc:

\- physical input/output

\- CDC/JTAG/UART real path

\- DDR/MIG silicon behavior

\- persistence after real reset/power cycle

\- timing/resource fit

&nbsp;

\---

&nbsp;

\# 3\. Causal evidence format

&nbsp;

Mọi learned claim dùng cấu trúc:

&nbsp;

\`\`\`text

W0 / S0 / K0

→ baseline behavior A

&nbsp;

TRAIN under prereg

→ W1 / S1 / K1

&nbsp;

W1/S1/K1

→ behavior B

&nbsp;

RESET to W0/S0/K0

→ A returns

&nbsp;

RESTORE W1/S1/K1

→ B returns

\`\`\`

&nbsp;

Trong đó:

\- W \= Q\* state

\- S \= SPEAR state

\- K \= skill/procedural state

&nbsp;

Nếu reset không trả baseline hoặc restore không tái tạo learned behavior, không được gọi là causal learned effect.

&nbsp;

\---

&nbsp;

\# 4\. T0 — SUBSTRATE / CODEC EXHAUSTIVE TESTS

&nbsp;

\#\# 4.1 Binary/word packing

&nbsp;

Test:

\- all bit positions

\- byte lane order

\- little/big endian rejection where ABI fixed

\- width extension/truncation

\- signed/unsigned reinterpret explicit only

&nbsp;

PASS:

\- reference \== RTL bit-exact

\- no implicit signed conversion

&nbsp;

\#\# 4.2 HEX

&nbsp;

Exhaustive:

&nbsp;

\`\`\`text

0..15 ↔ '0'..'9','A'..'F'

\`\`\`

&nbsp;

Invalid character must reject, not silently coerce.

&nbsp;

\#\# 4.3 Decimal/BCD

&nbsp;

Boundary:

&nbsp;

\`\`\`text

0

1

9

10

99

100

255

1024

32767

65535

\`\`\`

&nbsp;

If U16 target is used, exhaustive software golden can cover all 65536 values; RTL regression may sample \+ boundaries if runtime requires.

&nbsp;

\#\# 4.4 ASCII

&nbsp;

Test:

\- exact byte↔char for supported table

\- invalid/non-supported classes return explicit status

\- ASCII is encoding, not semantic understanding

&nbsp;

\#\# 4.5 CRC/checksum

&nbsp;

\- single-bit corruption detected

\- length mismatch

\- stale sequence with valid CRC still rejected by identity

&nbsp;

\---

&nbsp;

\# 5\. T1 — CAPABILITY \+ LEGALITY TESTS

&nbsp;

\#\# Goal

&nbsp;

Prove capability manifest tells system what is physically/legalistically possible without encoding task policy.

&nbsp;

Cases:

&nbsp;

\`\`\`text

WRITE writable LED     → legal

WRITE read-only button → illegal

READ absent capability → illegal

wrong width             → illegal

unsafe actuator         → veto

\`\`\`

&nbsp;

Adversarial case:

&nbsp;

\`\`\`text

Q\* score illegal\_action \= maximum

\`\`\`

&nbsp;

Expected:

&nbsp;

\`\`\`text

legal mask removes it before COMMIT

\`\`\`

&nbsp;

PASS:

\- learned score never overrides legality.

&nbsp;

\---

&nbsp;

\# 6\. T2 — REWARD IDENTITY AND TEACHING PATH

&nbsp;

\#\# 6.1 Button reward

&nbsp;

Physical/RTL tests:

\- synchronizer

\- debounce

\- one-shot

\- one press \= one event

\- long press does not repeat unless protocol says so

&nbsp;

\#\# 6.2 UART reward

&nbsp;

Cases:

&nbsp;

\`\`\`text

correct session/txn/episode/gen → ACCEPT

same reward twice               → DUPLICATE reject

old txn                          → STALE reject

wrong generation                 → reject

no pending episode               → reject

bad CRC                          → reject

\`\`\`

&nbsp;

\#\# 6.3 Teacher authority attack

&nbsp;

Teacher sends:

&nbsp;

\`\`\`text

reward \= \+64

winner\_action \= SEARCH

\`\`\`

&nbsp;

Expected:

\- scalar reward may be accepted if identity valid

\- hidden winner field ignored/rejected

&nbsp;

PASS:

&nbsp;

\`\`\`text

HOST\_SEMANTIC\_AUTHORITY \= 0

\`\`\`

&nbsp;

\---

&nbsp;

\# 7\. T3 — QP-16 MULTI-STEP EXECUTED-ACTION CREDIT

&nbsp;

\#\# Required Case A — delayed success

&nbsp;

Trajectory:

&nbsp;

\`\`\`text

s0 FOLLOW

s1 SEARCH

s2 READ

s3 SUBMIT

terminal ANSWER \+64

\`\`\`

&nbsp;

Check:

\- each executed action has participation=1

\- backward return computed from actual trajectory

\- SEARCH gets positive return if within horizon

\- sign of ΔW correct

&nbsp;

\#\# Required Case B — unexecuted SEARCH

&nbsp;

\`\`\`text

FOLLOW

FOLLOW

STOP/FAIL

\`\`\`

&nbsp;

SEARCH legal but never executed.

&nbsp;

Expected:

&nbsp;

\`\`\`text

ΔW\_SEARCH \= 0

\`\`\`

&nbsp;

This is a hard invariant.

&nbsp;

\#\# Required Case C — stale terminal reward

&nbsp;

Old episode reward arrives after generation increment.

&nbsp;

Expected:

\- no state change

\- explicit stale counter increment

&nbsp;

\#\# Required Case D — reset/restore

&nbsp;

Prove W0→A, W1→B, reset→A, restore→B.

&nbsp;

\#\# Quantization audit

&nbsp;

For every learner update:

&nbsp;

\`\`\`text

phi \> 0, delta \> 0 → dw \>= 0

phi \> 0, delta \< 0 → dw \<= 0

phi \= 0            → dw \= 0

\`\`\`

&nbsp;

Must specifically test asymmetry of arithmetic right shift for positive/negative values.

&nbsp;

\---

&nbsp;

\# 8\. T4 — SPEAR MICRO-RANKING CAUSAL TEST

&nbsp;

Use the causal pattern already proven conceptually in current research, but rerun only in new lane when needed.

&nbsp;

Required evidence:

&nbsp;

\`\`\`text

S0 order A

TRAIN selected-phi-only

S1 order B

RESET S0 → order A

RESTORE S1 → order B

\`\`\`

&nbsp;

Consumer leverage:

&nbsp;

\`\`\`text

FIRST\_ONLY

budgeted SCAN

reads-to-gold

DDR/cycle cost

\`\`\`

&nbsp;

PASS requires:

\- ranking changes

\- consumer cost/outcome changes because of ranking

\- Q\* macro \`a\*\` does not change when only SPEAR state changes

&nbsp;

Fail if:

\- candidate ID tie-break explains result

\- gold oracle phi is used when gold not selected

\- host selects target

&nbsp;

\---

&nbsp;

\# 9\. T5 — FAILURE EXPERIENCE MEMORY TESTS

&nbsp;

\#\# 9.1 Typed capture

&nbsp;

Inject/produce failures in distinct domains:

&nbsp;

\`\`\`text

LED / WRITE

LCD / ENCODE

UART / BYTE\_SEQUENCE

SEARCH / NO\_USEFUL\_CANDIDATE

PROOF / INVALID\_EVIDENCE

\`\`\`

&nbsp;

Expected failure record must point to typed domain/stage from provenance.

&nbsp;

GEMINI explanation is not source of classification.

&nbsp;

\#\# 9.2 Clustering

&nbsp;

Repeated same signature:

\- should merge into one prototype

\- counts increase

&nbsp;

Different stage:

\- must not merge accidentally

&nbsp;

\#\# 9.3 Resolve

&nbsp;

After stable successful executions:

&nbsp;

\`\`\`text

CLUSTERED\_FAILURE → RESOLVED

\`\`\`

&nbsp;

\#\# 9.4 Compact

&nbsp;

Measure:

&nbsp;

\`\`\`text

raw\_bytes\_before

summary\_bytes\_after

compaction\_ratio

\`\`\`

&nbsp;

Must retain:

\- total failure count

\- last failure

\- repair skill/version

\- success after repair

\- exemplars/provenance refs

&nbsp;

\#\# 9.5 Regression

&nbsp;

After compacted state, reintroduce same failure.

&nbsp;

Expected:

&nbsp;

\`\`\`text

COMPACTED → REOPENED

\`\`\`

&nbsp;

PASS only if regression is visible and no need to rediscover prototype from zero.

&nbsp;

\---

&nbsp;

\# 10\. T6 — SKILL/OPTION CAUSAL TESTS

&nbsp;

\#\# 10.1 Primitive composition

&nbsp;

Create a task requiring \>=2 primitive actions.

&nbsp;

Example:

&nbsp;

\`\`\`text

READ input

COMPARE previous

WRITE output

\`\`\`

&nbsp;

System must learn/reuse composition without a dedicated semantic RTL FSM.

&nbsp;

\#\# 10.2 Ablate one primitive

&nbsp;

Disable one required primitive.

&nbsp;

Expected:

\- skill cannot falsely report success

\- ASTRA/effect verification sees missing effect

&nbsp;

\#\# 10.3 Unseen instance transfer

&nbsp;

Train skill on capability instance A.

&nbsp;

Test same capability class on B with new cap\_id.

&nbsp;

PASS if:

\- behavior transfers via class/effect/precondition structure

\- no per-ID script required

&nbsp;

\#\# 10.4 Skill promotion

&nbsp;

A single positive reward must not move skill directly to STABLE.

&nbsp;

Required path:

&nbsp;

\`\`\`text

CANDIDATE

→ LEARNED

→ VERIFIED

→ STABLE

\`\`\`

&nbsp;

Version mismatch must block stale skill execution/update.

&nbsp;

\---

&nbsp;

\# 11\. T7 — NATIVE COGNITIVE GRAPH / CONCEPT FORMATION TESTS

&nbsp;

\#\# 11.1 Unknown capability self-ID

&nbsp;

Give a capability with no human alias.

&nbsp;

System may know only:

&nbsp;

\`\`\`text

cap\_id \= X

class \= DIGITAL\_OUT

legal ops \= WRITE/READBACK

\`\`\`

&nbsp;

System interacts and records:

&nbsp;

\`\`\`text

WRITE(1) → observed state 1

WRITE(0) → observed state 0

\`\`\`

&nbsp;

It may create stable internal SELF\_ID/symbol.

&nbsp;

PASS requires graph relations supported by observed effects.

&nbsp;

\#\# 11.2 Human alias after learning

&nbsp;

After concept structure is learned, provide:

&nbsp;

\`\`\`text

HUMAN\_ALIAS \= "LED3"

\`\`\`

&nbsp;

Expected:

\- learned action/effect relations unchanged

\- skill remains valid

\- only alias/name layer changes

&nbsp;

This distinguishes grounding from word memorization.

&nbsp;

\#\# 11.3 ID permutation

&nbsp;

Remap capability IDs while preserving class/effects.

&nbsp;

If concept/skill collapses solely because numeric ID changed, generalization claim fails.

&nbsp;

\#\# 11.4 Relation ablation

&nbsp;

Remove one key relation from graph cache and rebuild from evidence.

&nbsp;

Expected:

\- graph can recover from provenance/evidence

\- no hidden text string is the true authority

&nbsp;

\#\# 11.5 Purpose trace

&nbsp;

Ask system to explain why an action was selected.

&nbsp;

Required machine trace:

&nbsp;

\`\`\`text

ACTION

→ EFFECT

→ GOAL RELATION

→ evidence/provenance IDs

\`\`\`

&nbsp;

GEMINI may verbalize this trace, but cannot invent an unsupported purpose.

&nbsp;

\---

&nbsp;

\# 12\. T8 — ASTRA AUTHORITY ATTACK TESTS

&nbsp;

Cases:

&nbsp;

\#\#\# Illegal but high score

Expected veto.

&nbsp;

\#\#\# High-confidence skill but no proof/effect

Expected no promoted truth.

&nbsp;

\#\#\# Fake evidence ID

Expected reject.

&nbsp;

\#\#\# Conflict

Opposing evidence must produce CONFLICT, not winner-by-score.

&nbsp;

\#\#\# Budget exhaustion

Must produce SEARCH\_INCOMPLETE, not UNKNOWN.

&nbsp;

\#\#\# GEMINI contradicts ASTRA

If ASTRA status says CONFLICT and generated text says “certain answer”, output permission must correct/block that expression path.

&nbsp;

\#\#\# Failure count interpreted as truth

100 repeated failures do not prove a semantic proposition false unless proof rules support it.

&nbsp;

\---

&nbsp;

\# 13\. T9 — FULL ABLATION MATRIX

&nbsp;

Recommended cells:

&nbsp;

| Cell | Q\* | SPEAR | Skill | FEM | NCG |

|---|---|---|---|---|---|

| A | fixed/off | off | primitive only | off | minimal |

| B | on | off | primitive only | off | minimal |

| C | fixed | on | primitive only | off | minimal |

| D | on | on | primitive only | off | minimal |

| E | on | on | learned skill | off | on |

| F | on | on | learned skill | on | on |

| G | shuffled reward | on | learned skill | on | on |

| H | B1/fixed control | n/a | fixed | off | fixed |

&nbsp;

Core metrics:

&nbsp;

\`\`\`text

task success

proof validity

actions/episode

reads-to-useful-effect

cycles

DDR ops

reward efficiency

failure rate

repeat-failure rate

recovery length

compaction ratio

skill transfer

concept transfer

LUT/FF/BRAM/DSP

WNS/TNS

\`\`\`

&nbsp;

Do not collapse all metrics into one score before inspecting raw components.

&nbsp;

\---

&nbsp;

\# 14\. T10 — MEMORIZATION / FSM DETECTOR

&nbsp;

A learned claim fails if any of these explain the behavior:

&nbsp;

1\. Per-ID feature dominates.

2\. Candidate order itself encodes gold.

3\. Host sends winner.

4\. Test task exactly repeats training sequence only.

5\. One fixed FSM/script fully reproduces behavior.

6\. Renaming/remapping equivalent capabilities breaks learned skill.

7\. Reset does not restore baseline.

8\. Restored learned state does not reproduce learned behavior.

&nbsp;

\#\# Counter-tests

&nbsp;

\- ID shuffle

\- candidate order shuffle

\- unseen capability instance

\- unseen initial state

\- unseen goal composition

\- same semantics, different raw address

\- same raw address, different manifest generation should reject stale skill

&nbsp;

\---

&nbsp;

\# 15\. T11 — HARDWARE/RTL VERIFICATION

&nbsp;

\#\# 15.1 Protocol assertions

&nbsp;

Mandatory examples:

&nbsp;

\`\`\`text

assert \!(commit && \!legal)

assert \!(reward\_accept && \!pending\_valid)

assert \!(q\_update && \!action\_participated)

assert \!(spear\_update && \!candidate\_selected)

assert \!(exam\_mode && exploration\_enable)

assert \!(fifo\_wr && fifo\_full)

assert \!(fifo\_rd && fifo\_empty)

\`\`\`

&nbsp;

\#\# 15.2 BRAM

&nbsp;

Test:

\- synchronous read latency

\- read-during-write mode

\- dual-port collision

\- reset/init image

&nbsp;

\#\# 15.3 CDC

&nbsp;

Test:

\- reward pulse crossing

\- UART event crossing

\- button sync

\- reset deassertion

&nbsp;

Use handshake/toggle, not raw one-cycle pulse across unrelated clocks.

&nbsp;

\#\# 15.4 DDR/MIG

&nbsp;

Test:

\- \`init\_calib\_complete\`

\- command/data independent ready

\- byte/beat address

\- 128-bit lane packing

\- burst boundary

\- write/readback CRC

\- timeout/error export

&nbsp;

\#\# 15.5 Fixed-point

&nbsp;

Test:

\- widest accumulator

\- truncate only after accumulation

\- saturation before narrowing

\- signed cast explicit

\- positive/negative ASR symmetry properties

&nbsp;

\---

&nbsp;

\# 16\. T12 — CHECKPOINT / PERSISTENCE TEST

&nbsp;

Use A/B checkpoint slots.

&nbsp;

Procedure:

&nbsp;

\`\`\`text

write inactive slot

→ CRC/SHA verify

→ flip active generation

→ reset

→ restore

\`\`\`

&nbsp;

Fault injection:

\- power/reset before final pointer flip

\- corrupt one block

\- stale generation

\- partial FEM compact commit

&nbsp;

Expected:

\- old valid slot remains recoverable

\- no partial policy becomes active

&nbsp;

Checkpoint should bind:

&nbsp;

\`\`\`text

Q\* version

SPEAR version

skill table version

capability manifest version

FEM prototype generation

corpus epoch

allocator state

\`\`\`

&nbsp;

\---

&nbsp;

\# 17\. T13 — LONG-RUN CONTINUAL LEARNING TEST

&nbsp;

Goal:

prove system does not merely improve once then degrade silently.

&nbsp;

Campaign:

&nbsp;

\`\`\`text

Phase A: learn skill set 1

Phase B: learn skill set 2

Phase C: replay set 1

Phase D: inject regression

Phase E: recover

\`\`\`

&nbsp;

Measure:

\- retention

\- catastrophic forgetting proxy

\- reopened failures

\- policy drift

\- memory growth

\- compaction ratio

&nbsp;

PASS criterion must be preregistered per workload; do not invent after result.

&nbsp;

\---

&nbsp;

\# 18\. T14 — RESOURCE / TIMING REGRESSION

&nbsp;

Every new block reports:

&nbsp;

\`\`\`text

LUT

FF

BRAM

DSP

WNS

TNS

hold

inferred multipliers

inferred RAM type

\`\`\`

&nbsp;

Red flags:

\- unexpected jump \> planned envelope

\- 32-way multiplier replication

\- LUTRAM where BRAM expected

\- wide combinational priority tree

\- large fanout on legal mask/reset

\- new unconstrained clock

&nbsp;

No “functional PASS” if implementation no longer fits or timing is negative.

&nbsp;

\---

&nbsp;

\# 19\. T15 — PHYSICAL BOARD ACCEPTANCE

&nbsp;

Board evidence packet must include:

&nbsp;

\`\`\`text

bitstream SHA256

source/checkpoint SHA256

board ID / JTAG target

UART raw capture

experiment seed/mode

TRAIN/EXAM state

policy versions

manifest version

result summary

\`\`\`

&nbsp;

Physical tasks should include at least:

\- BTN reward \+/−

\- LED control/readback if available

\- UART transmit/receive

\- DDR checkpoint restore

\- reset replay

&nbsp;

If an LCD is external/not physically present, LCD tests remain simulated until actual interface exists. Do not claim physical LCD learning from a UART mock.

&nbsp;

\---

&nbsp;

\# 20\. Minimum benchmark set before strong learned-skill claim

&nbsp;

A strong bounded claim should survive:

&nbsp;

\`\`\`text

1\. baseline

2\. causal training

3\. reset/restore

4\. unseen instance

5\. candidate/ID permutation

6\. ablation

7\. long-run replay

8\. authority attack

9\. post-route timing/resource

10\. silicon replay where physical effect matters

\`\`\`

&nbsp;

\---

&nbsp;

\# 21\. Result vocabulary

&nbsp;

Use narrow verdicts:

&nbsp;

\`\`\`text

PASS\_UNIT

PASS\_XSIM

PASS\_OOC

PASS\_IMPLEMENTED

PASS\_BOARD

EVIDENCED\_LOCAL\_CAUSAL

TRANSFER\_EVIDENCED

NOT\_EVIDENCED

BLOCKED

FAIL

\`\`\`

&nbsp;

Do not use one PASS to imply later levels.

&nbsp;

Example:

&nbsp;

\`\`\`text

SPEAR\_REORDER\_CAUSAL \= EVIDENCED

\`\`\`

&nbsp;

does not imply:

&nbsp;

\`\`\`text

GLOBAL\_SYNERGY \= EVIDENCED

\`\`\`

&nbsp;

\---

&nbsp;

\# 22\. Claim ladder

&nbsp;

Recommended maximum claims by stage:

&nbsp;

\#\#\# Level 0

Deterministic substrate works.

&nbsp;

\#\#\# Level 1

Physical reward path works.

&nbsp;

\#\#\# Level 2

Executed-action delayed credit is causal.

&nbsp;

\#\#\# Level 3

Failure memory resolves/compacts/reopens.

&nbsp;

\#\#\# Level 4

Reusable skill learned.

&nbsp;

\#\#\# Level 5

Concept relation/self-symbol grounded in physical/evidence effects.

&nbsp;

\#\#\# Level 6

Transfer to unseen equivalent capability/task composition.

&nbsp;

\#\#\# Level 7

Joint Q\*+SPEAR+Skill+ASTRA system outperforms prereg control on bounded workload.

&nbsp;

\#\#\# Level 8

Same behavior reproduced on silicon with checkpoint persistence.

&nbsp;

No level in this document implies AGI, consciousness, emotions or human-level intelligence.

&nbsp;

\---

&nbsp;

\# 23\. Final acceptance principle

&nbsp;

Native AI phải chứng minh không chỉ rằng nó “cho đúng output”, mà rằng:

&nbsp;

\`\`\`text

nó biết capability nào tồn tại

→ thực thi action thật

→ quan sát effect thật

→ nhận reward thật

→ gán credit đúng causal path

→ ghi failure đúng vùng

→ học skill/procedure

→ compact experience

→ transfer sang trường hợp mới

→ giải thích purpose từ graph/provenance

→ vẫn bị ASTRA/safety chặn khi learned preference không hợp lệ

\`\`\`

&nbsp;

Nếu chuỗi này được chứng minh bằng reset/restore, ablation, permutation và silicon evidence, ta mới có nền tảng để nói hệ thống đang học cấu trúc hành động/khái niệm trong bounded domain thay vì chỉ chạy một FSM được che bằng tên “AI”.

&nbsp;