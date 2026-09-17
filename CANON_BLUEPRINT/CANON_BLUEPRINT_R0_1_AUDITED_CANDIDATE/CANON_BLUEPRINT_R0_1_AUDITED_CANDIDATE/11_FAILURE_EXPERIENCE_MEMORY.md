---
version: "1.1-candidate"
owner: AGENT_C
status: AUDITED_CANDIDATE
category: SECONDARY
last_modified: "2026-09-16T08:36:00+07:00"
---

# §11 — FAILURE EXPERIENCE MEMORY (FEM)

> Typed runtime failure experience, compaction, regression reopening, and repair linkage.
> FEM is part of the DUT's developmental memory. It is not the developer project issue tracker.

## 11.1 Purpose

FEM answers:

> What failed before, under what context, what repaired it, how often did it recur, and did it regress?

Locked separation:

```text
FACT != SKILL != EPISODE != FAILURE != WEIGHT
FAILURE_RECORD != NEGATIVE_FACT
SEMANTIC_CONFLICT != FAILURE by default
```

A valid `CONFLICT` result may be correct epistemic behavior; it becomes a FEM failure only
if the experiment contract says the system mishandled conflict or the conflict itself caused an
execution failure.

## 11.2 FailureRecord R0.1

```text
FailureRecord {
  failure_id
  episode_id
  step_id
  logical_tick
  domain
  stage
  capability_id
  capability_class
  capability_instance
  macro_action
  primitive_action
  candidate_id
  skill_id
  skill_version
  expected_effect
  observed_effect
  error_code
  reward_value
  reward_source
  state_signature
  action_signature
  effect_signature
  q_policy_version
  spear_policy_version
  capability_manifest_version
  knowledge_generation
  source_mode
  crc
}
```

`source_mode` distinguishes, for example:

```text
AUTONOMOUS
HUMAN_DEMO
UART_TEACHER
BOARD_TEST
BENCHMARK_HARNESS
```

Reward is evaluation metadata, not truth.

## 11.3 Typed Failure Key

Do not cluster by raw text or exact episode ID. Candidate prototype key:

```text
hash(domain,
     stage,
     capability_class,
     macro_action_class,
     primitive_class,
     effect_class,
     context_bucket)
```

The purpose is transferable failure memory while preserving enough context to avoid global
blacklisting of one isolated instance.

## 11.4 Lifecycle

```text
RAW_FAILURE
 -> repeated typed match
CLUSTERED_FAILURE
 -> corrective behavior succeeds
RESOLVED_FAILURE
 -> stable success window
COMPACTED_EXPERIENCE
 -> recurrence
REOPENED_FAILURE
```

A first failure need not immediately form a prototype.

## 11.5 FailurePrototype

```text
FailurePrototype {
  prototype_id
  prototype_key
  domain
  stage
  capability_class
  action_class
  effect_class
  first_seen_episode
  last_seen_episode
  last_failure_episode
  failure_total
  failure_recent
  success_after_repair
  regression_count
  unresolved
  compacted
  repair_skill_id
  repair_skill_version
  exemplar_refs[small_k]
  mean_recovery_steps
  mean_failure_cost
  version
  crc
}
```

Counters should saturate or widen explicitly; silent wrap is forbidden.

## 11.6 Atomic Compaction

Compaction is storage optimization, not deletion of history without evidence.

Required commit order:

```text
build prototype summary
 -> write target T2 record
 -> verify integrity/CRC
 -> mark COMMITTED
 -> update index
 -> only then retire eligible raw records
```

A power/reset interruption must not lose both the raw evidence and its replacement prototype.

## 11.7 Regression Reopen

When a compacted failure pattern reappears:

```text
new typed failure
 -> exact/prototype match
 -> REOPENED
 -> regression_count++
 -> repair skill/version re-evaluated
```

Regression must not silently mutate the original evidence record.

## 11.8 FEM Authority Boundary

FEM may provide features/signals to Q*, SPEAR, curriculum selection, and Skill Memory.

FEM may **not**:

- select final action on its own;
- override Q* or SPEAR;
- override ASTRA legality/proof/status;
- promote semantic truth;
- let a host inject winner/weight delta;
- reinterpret a hardware safety-limit state as a failure-memory truth object.

## 11.9 Engineering Failure vs DUT Failure

Vivado failures, documentation errors, CI failures, or agent mistakes belong in project evidence,
issue tracking, and the audit changelog. They do **not** automatically become runtime FEM data.
Only failures deliberately captured from the DUT/runtime experiment through the defined ingress
belong in FEM.

## 11.10 Acceptance

Minimum FEM gate:

```text
CAPTURE_CAUSAL = PASS
CLUSTER_TYPED = PASS
SEPARATION_BY_STAGE = PASS
COMPACTION_NO_DATA_LOSS = PASS
REGRESSION_REOPEN = PASS
ASTRA_AUTHORITY_PRESERVED = PASS
HOST_SEMANTIC_AUTHORITY = 0
PERSIST/RESTORE = PASS when claimed
```

## Tóm tắt tiếng Việt

FEM là bộ nhớ kinh nghiệm thất bại của chính Native AI, không phải nơi ghi lỗi phát triển
project. Failure được capture có identity, context, action/effect, version; lặp lại thì cluster,
sửa ổn định thì compact, tái phát thì reopen. FEM không phải FACT và không được vượt quyền
ASTRA/Q*/SPEAR.
