---
version: "1.3-candidate"
base_version: "1.1-candidate"  # 1.2->1.3: A/B mailbox corrections + C-CODE-05 durability corollary + S11.13/S12.10 bit budgets
base_status: AUDITED_CANDIDATE
patch_version: "1.2"
patch_status: CANDIDATE
owner: AGENT_C
status: AUDITED_BASE_PLUS_UNAUDITED_ADDITIONS
category: SECONDARY
last_modified: "2026-09-16T12:55:00+07:00"
---

# §12 — SKILL, TEACHING, AND SENSOR GROUNDING

> Procedural memory, teacher boundaries, sensor grounding, and transfer.

## 12.1 SkillRecord vs Executable Skill

A `SkillRecord` may exist before it is verified. Only a skill whose lifecycle/status permits
execution in the current mode is treated as an executable production skill.

```text
SkillRecord {
  skill_id
  version
  goal_class
  preconditions
  capability_class_mask
  parameters
  max_steps
  policy_or_sequence_ref
  termination_schema
  expected_effect_schema
  cost_stats
  success_count
  failure_count
  provenance_ref
  status
  generation
}
```

Locked distinction:

```text
CANDIDATE_SKILL != VERIFIED_SKILL
SKILL != FACT
```

`success_count`, `failure_count`, `cost_stats` are **utility/execution statistics only**: they
are not proof, not FACT, and not an ASTRA status; they feed Q*/SPEAR/curriculum features and
lifecycle guards, never promotion. Production execution of a skill requires `status` to be in
the **ASTRA-legal executable set** for the current mode; otherwise the action path returns
`ASTRA_DENY` [§01.7, §05]. When an `ACTION_INTENT` originates from a skill it carries
`skill_id` + `generation` (fields per A's action-path lock).

## 12.2 Skill Lifecycle

```text
experience / demonstration / teaching
 -> CANDIDATE
 -> repeated/replayed learning evidence
 -> LEARNED
 -> causal/legality verification
 -> VERIFIED
 -> stable success window
 -> STABLE
 -> optional COMPACTED representation
 -> REOPENED on regression
```

One positive reward is insufficient to create a stable skill.

## 12.3 Parameterization and Transfer

Prefer capability classes and role/parameter bindings over literal instance IDs.

Bad:

```text
WRITE LED3
```

Better:

```text
SET_INDICATOR(target: DIGITAL_OUT, desired_state: ON)
```

Transfer requires training on instance A and examination on unseen instance B with the same
capability/effect contract, plus ID permutation to detect scripts.

## 12.4 Teacher Protocol

Teacher is a source of proposals, demonstrations, clarification, aliases, and scalar reward —
not a truth oracle.

Teacher may:

- demonstrate a primitive/procedure;
- provide scalar reward tied to exact pending identity;
- provide an alias or clarification;
- propose a candidate relation/fact;
- answer a question as `CANDIDATE` evidence.

Teacher may not:

- directly write `VERIFIED_FACT`;
- send winner action/candidate;
- write learner weight deltas;
- inject proof/provenance fabricated as FPGA evidence;
- override ASTRA status;
- drive an actuator directly.

A teacher demonstration is an `ACTION_INTENT` with origin `HUMAN_DEMO`; it goes through the
same §05 action path (ASTRA precheck → capability binding → executor) as any other intent.
There is no teacher-to-actuator side channel.

## 12.5 Teacher Learning Flow

```text
knowledge gap / teaching opportunity
 -> Q* chooses ASK_TEACHER only when teaching policy permits
 -> teacher proposal/demo/reward
 -> provenance attached
 -> CANDIDATE / EPISODE / ALIAS metadata
 -> verification / conflict checks
 -> ASTRA promote / reject / conflict
 -> versioned generation commit when applicable
```

`UNKNOWN` does not automatically mean `ASK_TEACHER` [§03.6].

## 12.6 False-Teacher / Anti-Parrot Tests

Mandatory falsification patterns:

1. Teacher proposes claim contradicting verified support → must not silently become FACT.
2. Teacher proposes unsupported claim with no contradiction → remains CANDIDATE until verified.
3. Rephrase/remove teacher wording → learned procedural/semantic behavior must not depend on verbatim text.
4. Teacher may reward selected behavior, but cannot send a hidden winner or weight update.

## 12.7 Sensor Grounding

Grounding must preserve stages:

```text
RAW_SENSOR_EVENT
 -> calibrated/typed OBSERVATION
 -> bounded feature/event abstraction
 -> EPISODE / state transition
 -> candidate concept/relation
 -> repeated evidence / intervention where relevant
 -> ASTRA-governed verification status
 -> optional HUMAN_ALIAS attachment
```

A raw sensor reading is not automatically a FACT, and clustering is not automatically meaning.
Alias attachment never changes native identity by itself.

### Example hypothesis

```text
unlabeled temperature state pattern
 -> candidate internal state C_8734
 -> action/effect associations observed
 -> stability/transfer tested
 -> human later attaches aliases: "hot", "nóng", ...
```

The claim is supported only if behavior and relations survive alias replacement and, where
applicable, unseen-sensor/capability transfer.

## 12.8 Primitive / Capability / Skill Boundary

- **Primitive**: fixed executable operation implemented by the substrate.
- **Capability**: installed hardware interface declaring which primitives/effects are available [§05].
- **Skill**: a procedure combining primitives under preconditions/termination, existing at
  any lifecycle state `CANDIDATE → LEARNED → VERIFIED → STABLE → COMPACTED → REOPENED` [§12.2].
  Skills of every lifecycle state may exist in storage (including T2); there is no
  "verified-only skill exists" rule (C-FIX-03).
- **Fact**: verified semantic proposition; not executable by itself.

Lifecycle state and execution permission are **separate fields**:

```text
SKILL != FACT
SKILL_STATE != EXECUTION_PERMISSION
execution_eligibility = f(policy, legality [§03], capability binding, current mode, skill_state)
```

A CANDIDATE skill may be executable in a TRAIN/sandbox mode and non-executable in EXAM mode;
a VERIFIED skill may still be denied when its capability is unbound [X0-15]. Eligibility is
decided on the execution path below, never by lifecycle state alone.

Execution path:

```text
Skill / Q* / HUMAN_DEMO ACTION_INTENT
 -> lookup (SkillRecord / capability table; NO command is issued here)
 -> ASTRA legality + safety_contract precheck            [§01.7, §03]
 -> CapabilityBinding == BOUND                            [§05]   (else NO_BINDING / NO_ACTION, X0-15)
 -> PrimitiveCommand
 -> Primitive Executor
 -> ObservedEffect (readback / episode; credit-only comparison against expected_effect_schema)
```

## 12.9 Falsification Hooks (cross-ref)

Skill/teacher/grounding falsifiers are mapped in the §13.8.3 matrix (mechanism · learner state ·
reset scope · control · observable · dependency · forbidden shortcut) and executed under §31.7,
which remains the benchmark/falsification authority:
unseen-instance transfer (X0-11) via class/param binding [§12.3]; 4→8→16 structural transfer
(X0-12) with the primitive shortcut disabled; sensor grounding (X0-08) [§12.7]; and
false-teacher / anti-parrot (X0-09) [§12.6]. Skill reset scope for X0-07 covers **learned and
candidate skill records only** [§13.8.1]; VERIFIED skills promoted through ASTRA are governed by
the promotion/freeze rules [§03.5], not by learned-state reset. Section is unaudited CANDIDATE.

## 12.10 Candidate Bit Budget — SKILL records are not NodeRecord-256

> `LEARNING_LOCAL_LAYOUT_CANDIDATE`. SkillRecord is its own record kind (`SKILL`), never an
> overloaded NodeRecord / NCG row. Proposal for D; ABI promotion via A/B [§04].

**SkillRecord — 256 bits / 8 words**

| Word | Field(s) | Bits |
|---|---|---|
| W0 | `skill_id` | 32 |
| W1 | `version[7:0]`, `generation[7:0]`, `goal_class[7:0]`, `status[2:0]` (§12.2 lifecycle code), pad | 8+8+8+3+5 |
| W2 | `preconditions[15:0]` (predicate bitmask), `provenance_ref[15:0]` | 16 + 16 |
| W3 | `capability_class_mask` | 32 |
| W4 | `max_steps[7:0]`, `cost_stats[7:0]` (saturating), `parameters_ref[15:0]` (§12.3 class/param binding) | 8+8+16 |
| W5 | `policy_or_sequence_ref` | 32 |
| W6 | `termination_schema_ref[15:0]`, `expected_effect_schema_ref[15:0]` | 16 + 16 |
| W7 | `success_count[7:0]`, `failure_count[7:0]` (saturating, utility-only §12.1), `crc16[15:0]` | 8+8+16 |

`status` is lifecycle state; execution permission is not stored in the record
(`SKILL_STATE != EXECUTION_PERMISSION`, §12.8) — it is decided on the action path per call.

## Tóm tắt tiếng Việt

Skill có lifecycle riêng: candidate → learned → verified → stable → compacted/reopened. Teacher
chỉ tạo candidate/demo/reward, không tạo FACT hay proof. Sensor grounding đi từ raw event →
observation → episode → candidate concept/relation → verification; alias chỉ gắn tên. Mọi skill
muốn tác động phần cứng phải qua §05 capability binding và safety.

§12.9 nối các falsifier về skill/teacher/grounding tới §13.8 và §31.7: transfer sang instance
mới (X0-11), transfer cấu trúc 4→8→16 (X0-12), sensor grounding (X0-08), false-teacher/anti-parrot
(X0-09). Reset ở X0-07 chỉ áp dụng cho skill LEARNED/CANDIDATE; skill đã VERIFIED theo luật
promotion/freeze của ASTRA [§03.5].
