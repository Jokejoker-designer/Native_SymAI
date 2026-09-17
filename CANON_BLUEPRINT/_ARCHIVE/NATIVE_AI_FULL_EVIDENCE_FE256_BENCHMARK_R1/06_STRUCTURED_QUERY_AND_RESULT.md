# 06 — STRUCTURED QUERY / RESULT ACCEPTANCE

Primary input follows the Native Information Fabric semantic record:

```text
QueryRecord {
  subject_id
  relation_id
  object_ref
  object_valid
  direction
  context_id
  mode
  txn_id
}
```

Primary output:

```text
ResultRecord {
  status
  answer_kind
  answer_ref
  proof_ref
  provenance_ref
  conflict_ref
  txn_id
}
```

## Equality rules

- `txn_id`: must echo exactly.
- `status`: exact.
- `answer_kind`: exact for ANSWER.
- node answer: exact canonical ID.
- value answer: semantic equality of kind/value/unit/bounds according to gold.
- `proof_ref`: non-null when required and independently resolvable.
- `provenance_ref`: valid and allowed by gold proof policy.
- `conflict_ref`: required for CONFLICT.

Formatting and natural-language wording do not participate in FE256 semantic scoring.
