# SKILL_CONDITIONAL_BRANCH_R1 — contract change request

LANGUAGE=EN
CONTRACT_CHANGE_REQUIRED=YES
RTL_FOR_THIS_CHANGE=NOT_STARTED

The identity-guard batch did not need this change and is already simulated.
This request blocks only the branch encoding.

```text
CURRENT_CONTRACT:
  STEP_WORD_R1
  [2:0] primitive_id
  [7:3] reserved = 0
  [15:8] step_tag
  [31:16] reserved = 0
  The only legal tag is STEP_TAG_PRIM = 8'h00.
  Any other tag, or any nonzero reserved field, is skill_fail with no step_valid.

PROBLEM:
  A bounded conditional successor cannot be data.
  The current word has no legal place to name a SUCCESS step and a FAILURE step.
  Encoding that in RTL from skill_id would violate SEMANTIC SKILL != DEDICATED RTL FSM.

MINIMUM_CHANGE:
  Add one tag. Do not change STEP_TAG_PRIM.
  STEP_TAG_BRANCH = 8'h01
  [2:0]   must be 0
  [7:3]   must be 0
  [15:8]  8'h01
  [23:16] success_step_id
  [31:24] failure_step_id
  A PRIM word is unchanged: [31:16] and [7:3] stay 0.
  R1 still does not recurse and does not add a retry loop.
  An unknown tag remains skill_fail.

WHY_CANON_REQUIRES_IT:
  A skill is a procedure with termination, not only a straight list.
  The successor must come from the sequence body so two skills can branch differently
  on the same engine.

INTEGRATION_IMPACT:
  No port width change.
  No ActionIntent, ASTRA, PrimitiveCommand, Q*, Pack, or MIG change.
  D's adapter still sees only primitive_id on STEP_TAG_PRIM steps.
  A BRANCH word never raises step_valid.
```
