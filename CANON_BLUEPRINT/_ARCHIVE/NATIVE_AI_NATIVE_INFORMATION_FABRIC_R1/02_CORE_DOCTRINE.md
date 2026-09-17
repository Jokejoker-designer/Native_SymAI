# 02 — CORE DOCTRINE

## 1. Lõi không học bằng câu chữ

Không lấy:

`"RAC_WALL uses refrigerant R32"`

làm đơn vị tri thức lõi.

Lõi nhận:

`ENTITY_ID --RELATION_ID--> ENTITY_ID/VALUE_ID`

Ví dụ khái niệm:

`0x012C --0x0009--> 0x0133`

Tên `RAC_WALL`, `USES_REFRIGERANT`, `R32` chỉ là human aliases bên ngoài.

## 2. Tri thức và học là hai lớp khác nhau

- **Verified knowledge**: graph/record có identity, relation, context, provenance.
- **Learned behavior**: Q*/SPEAR weights, affordance statistics, skills, failure prototypes.
- **Experience**: episode/trajectory/event streams.

Cấm:

- FACT → tự động biến thành weight.
- Weight cao → tự động biến thành FACT.
- Alias → tự động định nghĩa meaning.
- Co-occurrence → tự động thành CAUSES.

## 3. Meaning đến từ structure + effect

Meaning của một capability/action được xác lập qua:

- stable identity
- before state
- action/opcode
- after state/effect
- context
- repeated evidence
- provenance
- ASTRA status/promotion khi cần

## 4. Hardware-native

“Hardware-native” nghĩa là phần lõi có thể hoạt động bằng mã native mà không cần language model để suy luận cơ bản.

Nếu GEMINI bị tháo ra:

- graph retrieval vẫn chạy
- ASTRA proof vẫn chạy
- skill execution vẫn chạy
- self-learning vẫn có thể cập nhật bounded learner state

Chỉ mất giao tiếp ngôn ngữ tự nhiên phong phú.
