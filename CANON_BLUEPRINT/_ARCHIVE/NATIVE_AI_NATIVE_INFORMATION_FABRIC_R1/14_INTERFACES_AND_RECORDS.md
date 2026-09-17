# 14 — INTERFACES AND RECORDS

## 1. Native Semantic Query

Conceptual record:

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

## 2. Native Result

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

## 3. Temporal Event

```text
EventRecord {
  source_id
  event_type
  timestamp
  payload/value
  context_id
  provenance_ref
}
```

## 4. Episode

```text
EpisodeRecord {
  pre_state_ref
  action_ref
  trajectory_ref
  post_state_ref
  effect_ref
  reward
  context_ref
  provenance_ref
}
```

## 5. Candidate relation

```text
CandidateEdge {
  src_id
  relation_id
  dst_ref
  context_id
  evidence_ref
  support_count
  oppose_count
  status
}
```

## 6. Exact widths

Bit widths phải derive từ active ABI/board resource target; tài liệu này khóa semantics, không tự khóa width nếu Canon/current implementation chưa khóa.
