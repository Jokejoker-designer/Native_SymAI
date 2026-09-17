---
version: "1.7-candidate"
owner: AGENT_A
status: AUDITED_CANDIDATE
category: PRIMARY
last_modified: "2026-09-16T18:55:00+07:00"
---

# §05 — CAPABILITY AND ACTION BINDING

> Bridge between semantic intent and physical hardware. Knowledge and language do
> not directly drive pins, buses, motors, relays, or actuators.

## 5.1 Purpose

Native AI may reason about an action semantically, but execution is legal only if a
compatible installed hardware capability exists and the safety/legality contract passes.

This path matches [§01.7]. Lookup is not binding. Binding is not a command.

```text
Semantic ACTION_INTENT
  (origin Q* / Skill / HUMAN_DEMO; skill origin carries skill_id + generation)
  -> ActionResolution (capability_class, primitive_id, optional target_ref)
  -> installed CapabilityDescriptor lookup
  -> version/schema/generation compatibility
  -> ASTRA legality + safety_contract precheck
  -> CapabilityBinding BOUND
  -> PrimitiveCommand
  -> verified primitive executor
  -> physical command
  -> ObservedEffect / readback
```

If any **pre-executor** step fails, no `PrimitiveCommand` is issued (`NO_ACTION`).
Readback runs after issue. Missing readback identity is `EFFECT_UNOBSERVED`, not
`NO_ACTION`. An issued command is not evidence that the physical effect occurred.
`SKILL_STATE ≠ EXECUTION_PERMISSION` [§12.8]: lifecycle does not by itself
authorize pins. `HUMAN_DEMO` uses this same path; no teacher-to-actuator
side channel. Action-lane objects (`ACTION_INTENT`, `ActionResolution`,
`CapabilityBinding`, `PrimitiveCommand`, `ObservedEffect`) are **not**
Query/Result/`SemanticEvent` UART records [§04.13]. They stay off the §04
wire unless B adds distinct records. Action verdict codes must not reuse
query `0x01–0x06`.

## 5.2 CapabilityDescriptor

Candidate canonical descriptor:

```text
CapabilityDescriptor {
  capability_id
  capability_class
  instance_id
  version
  interface_type
  primitive_mask
  input_schema_ref
  command_schema_ref
  status_schema_ref
  fault_schema_ref
  timing_contract_ref
  safety_contract_ref
  executor_index
  knowledge_pack_dependency_ref
  flags
  crc
}
```

The descriptor states what hardware exists and what primitive operations are legal. It
must not contain semantic winners, preferred actions, benchmark answers, or learned truth.

This is the **canonical** field list. [§01.7.1] must not fork a second descriptor.
`crc` is the integrity field. `safety_contract_ref` must identify limits, units, and
generation; packing is implementation-defined [§02.9].

## 5.3 Module Manifest

A physical module may expose a manifest such as:

```text
MODULE_ID
MODULE_VERSION
CAPABILITY_CLASS
INPUT_SCHEMA
OUTPUT_SCHEMA
COMMAND_SCHEMA
FAULT_SCHEMA
TIMING_CONTRACT
SAFETY_CONTRACT
KNOWLEDGE_PACK_DEPENDENCIES
INTEGRITY_ID
```

Runtime discovery is allowed only for capabilities implemented by already-certified
generic physical interfaces. New electrical interfaces may still require new RTL and a new
bitstream lineage.

`ModuleManifest` is the install-time name set for `CapabilityDescriptor`:
`MODULE_ID` → `capability_id`; instance and generation must also map. It is not a
second hardware identity. [§33.5] must say “descriptor match,” not a second object.

## 5.4 Action Binding

`ActionResolution` is required, not an example:

```text
semantic_action_class
  -> capability_class
  -> primitive_id
  -> optional target_ref
```

Example: `REDUCE_COMPRESSOR_FREQUENCY` → `COMPRESSOR_CONTROL` / `SET_FREQ`.

Laws:

- Primitive not in the instance `primitive_mask` ⇒ `NO_BINDING` ⇒ `NO_ACTION`.
- Multiple installed instances and missing `target_ref` ⇒ `NO_BINDING` (no silent pick).
- Absent or incompatible class/instance ⇒ `NO_BINDING` ⇒ `NO_ACTION`.

```text
NO_BINDING -> NO_ACTION
```

The knowledge pack cannot invent a capability that the board does not physically possess.

## 5.5 Safety Boundary

GEMINI, Human Adapter, Teacher, Q*, SPEAR and Skill memory cannot bypass the physical
safety path.

```text
GEMINI text -> actuator                    FORBIDDEN
Teacher candidate -> actuator              FORBIDDEN
SPEAR top score -> actuator                 FORBIDDEN

Q*/Skill ACTION_INTENT
 -> ActionResolution + descriptor lookup   (no command)
 -> ASTRA legality + safety_contract
 -> CapabilityBinding BOUND
 -> PrimitiveCommand
 -> primitive executor                     REQUIRED
```

ASTRA certifies legality of the intent + descriptor + safety contract. A failed
safety_contract is an ASTRA-admissible `SAFETY_VETO`. Safety is not a second
authority that can approve what ASTRA denied.

## 5.6 Readback and Causal Identity

An issued command is not evidence that the physical effect occurred. Every learning-capable
action lane must preserve:

```text
binding_id
command_id
episode_id
step_id
capability_id / instance
primitive/action parameters
state_before
command accepted
observed_effect/readback
state_after
reward source
logical tick
generation/policy versions
```

`ObservedEffect` must cite `command_id` **and** episode/step. Only executed actions
with attributable observed outcomes are eligible for causal credit.
Missing readback identity ⇒ `EFFECT_UNOBSERVED`, not a rewrite to `NO_ACTION`.

Credit chain (matches live [§10.8.4]; architecture, not a Q* ABI):

```text
proposal ≠ legal acceptance ≠ execution ≠ observed effect
  ≠ reward acceptance ≠ credit update
```

At most one unresolved pending proposal in the action-credit lane. Do not
silently overwrite a pending context. Unexecuted / `NO_ACTION` / never-issued
Top-1 ⇒ zero execution credit [§05.8]. `reward_accepted` only after matching
`(episode_id, step_id, command_id, generation)` and `ObservedEffect` citing
`command_id`. Duplicate apply is refused. C reason names are C observables.

## 5.7 Plug-and-Play Scope

Long-range product goal:

```text
fixed Native AI core
+ generic verified I/O blocks
+ runtime capability descriptors
+ runtime knowledge packs
```

This may support data-driven sensor/actuator additions without resynthesis **only where the
required physical interface already exists in the bitstream**. Otherwise a new RTL artifact is
required.

## 5.8 Acceptance Tests

These seven names are the action-path acceptance set. [§31]/[§32] must
echo them and must not substitute a second unnamed ladder.

Minimum tests before physical-action claims:

1. `CAPABILITY_ENUM_PASS` — installed capability inventory exact.
2. `NO_BINDING_NO_ACTION_PASS` — absent capability cannot execute.
3. `SAFETY_VETO_PASS` — illegal command is blocked.
4. `COMMAND_READBACK_PASS` — command and observed effect distinguished.
5. `STALE_DESCRIPTOR_REJECT_PASS` — version/generation mismatch rejected.
6. `GEMINI_NO_ACTUATOR_AUTHORITY_PASS` — language path cannot drive executor.
7. `UNEXECUTED_NO_CREDIT_PASS` — non-executed action gets no learning update.
   Includes: refused overwrite of a still-pending proposal; duplicate credit
   apply after consume.

## Tóm tắt tiếng Việt

§05 bổ sung lớp còn thiếu giữa suy luận semantic và phần cứng thật. Native AI chỉ phát
`ACTION_INTENT`; muốn tác động thiết bị phải qua lookup descriptor, ASTRA/safety,
`CapabilityBinding`, `PrimitiveCommand` và `ObservedEffect`. Các object này
không đi Query/Result UART [§04.13]. `NO_ACTION` chỉ khi chưa
phát lệnh. Proposal ≠ execution ≠ credit; tối đa một pending; Top-1 chưa chạy không
được credit. Knowledge Pack hoặc GEMINI không thể tự biến một ý nghĩa thành tín hiệu điện
nếu capability tương ứng không tồn tại. Bảy tên [§05.8] là bộ acceptance
action-path; [§31]/[§32] không được thay bằng thang X0-15 không tên.
