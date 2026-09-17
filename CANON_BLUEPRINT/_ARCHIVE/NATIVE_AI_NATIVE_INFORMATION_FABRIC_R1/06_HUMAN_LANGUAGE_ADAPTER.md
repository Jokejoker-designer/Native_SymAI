# 06 — HUMAN LANGUAGE ADAPTER

## 1. Vai trò

Ngôn ngữ tự nhiên là codec giao tiếp, không phải lõi tri thức.

## 2. Human → Native

```text
text / voice / manual
→ parser / GEMINI / resolver
→ identity resolution
→ structured query / structured claim
→ Native Semantic Bus
```

Ví dụ:

`"RAC_WALL uses refrigerant?"`

→

```text
subject_id = RAC_WALL_ID
relation_id = USES_REFRIGERANT_ID
object_valid = 0
context = ...
```

## 3. Native → Human

ASTRA trả structured result:

```text
status
answer_kind
answer_ref/value
proof_id
provenance_id
```

GEMINI/renderer diễn đạt thành câu người dùng đọc được.

## 4. GEMINI boundary

GEMINI được phép:

- parse/propose symbol mappings
- verbalize structured result
- generate explanation text from proof trace

GEMINI không được:

- invent fact
- override ASTRA status
- promote candidate into truth
- choose actuator action ngoài policy/legality path

## 5. Alias independence

Thay alias không được thay graph meaning.
