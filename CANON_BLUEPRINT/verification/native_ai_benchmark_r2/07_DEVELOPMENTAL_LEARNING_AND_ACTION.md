# 07 — DEVELOPMENTAL LEARNING AND ACTION

## 1. Learning acceptance

The project now contains Q*, SPEAR and FEM components, but R2 does not award a
learning pass merely because those blocks synthesize, update state or pass local
vectors.

The decisive criterion is **decision causality**.

### DL01 — learner on decision path
Show the learned state is read by the exact path that selects/ranks the later
candidate/action.

### DL02 — scalar reward, no winner injection
The host/teacher may provide an allowed scalar/ordinal reward and transaction
identity. It may not provide the desired selected candidate, final answer,
gradient, delta-weight or semantic winner.

### DL03 — controlled pre/post decision change
For a preregistered context, capture the decision before learning, apply one
attributed experience/reward sequence, then repeat the same decision context.
The changed decision/rank must match the preregistered causal expectation.

### DL04 — freeze counterfactual
Repeat the same episode with `learn=0` or frozen state.
If behavior changes identically, the learning claim fails.

### DL05 — reset causality
Reset volatile learned state. The learned effect must disappear unless the
contract explicitly reloads persistence.

### DL06 — persistence/reload
Persist, reset/reprogram as specified, reload the exact generation/version and
show the learned effect returns bit-exact or within a preregistered tolerance.

### DL07 — FEM causal effect
A recorded failure prototype must alter a later legal decision/rank in the
declared context. A stored record that is never consumed is not persistence
acceptance.

### DL08 — SPEAR fixed-budget value
At the same search budget, learned ranking must improve the preregistered
needed-candidate-in-Top-K metric over the frozen heuristic/control, or the
learning advantage claim is rejected.

### DL09 — Q* selection effect
Q* learned/value state must causally alter proposed-action selection under a
controlled counterfactual while remaining subordinate to legality/safety.

### DL10 — held-out transfer
A skill/relational policy learned on one instance must work on a preregistered
unseen instance without injecting its answer/trajectory.

### DL11 — anti-parrot
Incorrect teacher language/reward identity must not become verified FACT merely
because it was presented by the teacher.

### DL12 — no unexecuted credit
Top-1 proposal, refused action, safety veto or unissued command gets zero
execution credit.

## 2. Action acceptance

Preserve the canonical action chain:

```text
ACTION_INTENT
→ ActionResolution
→ CapabilityDescriptor
→ ASTRA legality/safety precheck
→ CapabilityBinding
→ PrimitiveCommand
→ executor
→ physical effect/readback
→ attributed reward/credit
```

The seven canonical acceptance names are:

1. `CAPABILITY_ENUM_PASS`
2. `NO_BINDING_NO_ACTION_PASS`
3. `SAFETY_VETO_PASS`
4. `COMMAND_READBACK_PASS`
5. `STALE_DESCRIPTOR_REJECT_PASS`
6. `GEMINI_NO_ACTUATOR_AUTHORITY_PASS`
7. `UNEXECUTED_NO_CREDIT_PASS`

## 3. Grounding

A grounding claim additionally requires a real sensor/action/effect causal loop:

- sensor state is captured with identity/time/generation;
- action is issued through a valid binding;
- readback/effect is attributed to the command;
- altering the physical effect or sensor evidence changes later state/credit as
  preregistered;
- fabricated/mismatched readback is rejected.

This is intentionally stronger than a semantic demo.
