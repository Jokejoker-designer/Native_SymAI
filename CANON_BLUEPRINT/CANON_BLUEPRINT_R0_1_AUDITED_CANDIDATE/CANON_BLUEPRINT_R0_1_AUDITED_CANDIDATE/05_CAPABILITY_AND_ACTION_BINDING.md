---
version: "1.0-candidate"
owner: AGENT_A
status: NEW_CANDIDATE
category: PRIMARY
last_modified: "2026-09-16T08:29:00+07:00"
---

# §05 — CAPABILITY AND ACTION BINDING

> Bridge between semantic intent and physical hardware. Knowledge and language do
> not directly drive pins, buses, motors, relays, or actuators.

## 5.1 Purpose

Native AI may reason about an action semantically, but execution is legal only if a
compatible installed hardware capability exists and the safety/legality contract passes.

```text
Semantic ACTION_INTENT
  -> capability-class resolution
  -> installed capability lookup
  -> version/schema compatibility
  -> ASTRA legality/safety precheck
  -> primitive executor binding
  -> physical command
  -> readback / observed effect
```

If any step fails, no actuator command is issued.

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

## 5.4 Action Binding

Example:

```text
semantic action: REDUCE_COMPRESSOR_FREQUENCY
        -> CAPABILITY_CLASS = COMPRESSOR_CONTROL
        -> installed instance COMPRESSOR_V1
        -> primitive SET_FREQ(parameter)
        -> safety veto check
        -> executor
        -> readback
```

If `COMPRESSOR_CONTROL` is absent or incompatible:

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

Q*/Skill intent
 -> ASTRA legality
 -> safety veto
 -> capability binding
 -> primitive executor                     REQUIRED
```

## 5.6 Readback and Causal Identity

An issued command is not evidence that the physical effect occurred. Every learning-capable
action lane must preserve:

```text
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

Only executed actions with attributable observed outcomes are eligible for causal credit.

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

Minimum tests before physical-action claims:

1. `CAPABILITY_ENUM_PASS` — installed capability inventory exact.
2. `NO_BINDING_NO_ACTION_PASS` — absent capability cannot execute.
3. `SAFETY_VETO_PASS` — illegal command is blocked.
4. `COMMAND_READBACK_PASS` — command and observed effect distinguished.
5. `STALE_DESCRIPTOR_REJECT_PASS` — version/generation mismatch rejected.
6. `GEMINI_NO_ACTUATOR_AUTHORITY_PASS` — language path cannot drive executor.
7. `UNEXECUTED_NO_CREDIT_PASS` — non-executed action gets no learning update.

## Tóm tắt tiếng Việt

§05 bổ sung lớp còn thiếu giữa suy luận semantic và phần cứng thật. Native AI chỉ phát
`ACTION_INTENT`; muốn tác động thiết bị phải qua capability descriptor, ASTRA/safety,
binding tới primitive executor và readback. Knowledge Pack hoặc GEMINI không thể tự biến
một ý nghĩa thành tín hiệu điện nếu capability tương ứng không tồn tại.
