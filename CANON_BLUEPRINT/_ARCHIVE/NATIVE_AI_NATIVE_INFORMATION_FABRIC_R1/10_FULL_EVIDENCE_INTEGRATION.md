# 10 — FULL EVIDENCE INTEGRATION

## 1. Vai trò Lane B

Full Evidence là **verified/static domain knowledge provider**.

Không phải self-learning lane.
Không phải FG08 active teaching lane.
Không phải language-model lane.

## 2. Pipeline chuẩn

```text
SOURCE DOCUMENTS
→ evidence extraction
→ identity resolution
→ typed claim
→ value/context/provenance binding
→ validation
→ verified knowledge pack
→ DDR
→ graph retrieval
→ ASTRA proof
```

## 3. Không phụ thuộc human sentence trong lõi

Text chỉ cần convert sang structured claim/query ở adapter boundary.

## 4. Full Evidence outputs

- verified node/edge/value records
- provenance
- queryable indexes
- status/proof-compatible result

## 5. Tránh lặp lỗi C4G cũ

Cấm:

- mở rộng số facts nhưng giữ tiny parser và tiny result language như cũ
- model collapse
- relation collapse
- literal OID=0 hack
- compiler/HW ID drift

## 6. Integration tương lai

Full Evidence → ASTRA/NCG context → learner uses facts as evidence/state.

Learner không được rewrite verified fact plane trực tiếp.
