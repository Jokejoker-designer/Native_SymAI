---
version: "1.1-candidate"
owner: AGENT_C
status: AUDITED_CANDIDATE
category: SECONDARY
last_modified: "2026-09-16T08:38:00+07:00"
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
- **Skill**: learned/verified procedure combining primitives under preconditions/termination.
- **Fact**: verified semantic proposition; not executable by itself.

Execution path:

```text
Skill / Q* ACTION_INTENT
 -> ASTRA legality/safety
 -> Capability Binding [§05]
 -> Primitive Executor
 -> physical effect
 -> readback/episode
```

## Tóm tắt tiếng Việt

Skill có lifecycle riêng: candidate → learned → verified → stable → compacted/reopened. Teacher
chỉ tạo candidate/demo/reward, không tạo FACT hay proof. Sensor grounding đi từ raw event →
observation → episode → candidate concept/relation → verification; alias chỉ gắn tên. Mọi skill
muốn tác động phần cứng phải qua §05 capability binding và safety.
