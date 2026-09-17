# 04 — BINARY SEMANTIC PLANE

## 1. Mục tiêu

Đây là “ngôn ngữ mẹ đẻ” của Native AI cho tri thức cấu trúc.

## 2. Thành phần tối thiểu

- `node_id`
- `node_type`
- `relation_id`
- `dst_kind`
- `dst_ref`
- `context_id`
- `provenance_id`
- `polarity/status`
- `generation/version`

## 3. Identity rules

Phải phân biệt:

- SELF_ID
- HUMAN_ALIAS
- semantic role
- product family
- model
- model variant
- instance
- error code
- refrigerant/concept
- capability
- state
- action
- goal

Không collapse model vào family chỉ để tiết kiệm ID.

## 4. Values/Literals

Numeric/range/unit không được rơi về `OID=0`.

Ví dụ:

```text
ValueRecord:
  kind = RANGE
  min = 220
  max = 240
  unit = VOLT
```

Edge:

`MODEL --EXPECT_RANGE--> ValueRecord`

## 5. Inverse relations

`MODEL --HAS_ERROR_CODE--> F72`

và

`F72 --ERROR_OF--> MODEL`

là inverse pair nếu registry định nghĩa như vậy. Không chỉ đổi relation ID mà giữ nguyên chiều.

## 6. Fail closed

Cấm:

- unknown entity → generic entity
- unknown object → 0
- unknown relation → nearest relation
- unknown model → family node

Nếu không resolve được: `UNRESOLVED/UNSUPPORTED`, không fabricate semantic mapping.
