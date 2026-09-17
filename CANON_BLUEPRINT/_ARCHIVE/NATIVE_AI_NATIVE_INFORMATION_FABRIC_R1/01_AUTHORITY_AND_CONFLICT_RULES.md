# 01 — AUTHORITY AND CONFLICT RULES

## 1. Mục tiêu

Ngăn các session, lane, compiler, RTL hoặc tài liệu phát triển độc lập rồi tự tạo semantic khác nhau.

## 2. Canon authority hierarchy

Khi giải thích hoặc triển khai Native Information Fabric, ưu tiên:

1. `09_IMPLEMENTATION_START_AND_LOCKED_DECISIONS` — semantic/architectural authority cao nhất.
2. `02_MEMORY_ARCHITECTURE_BRAM_DDR` — physical storage / BRAM-DDR / checkpoint authority.
3. `07_VERIFICATION_AND_CAUSAL_TESTS` — evidence / causal acceptance authority.
4. `05_SKILL_OPTIONS_AND_BOARD_TEACHING` — procedural/skill/teaching specialization.
5. `04_FAILURE_EXPERIENCE_MEMORY_AND_COMPACTION` — failure/experience specialization.
6. `03_ALGORITHMS_AND_LEARNING` — learning/update algorithms.
7. `01_MASTER_ARCHITECTURE_AND_BRAIN_PARTITION` — brain partition / ownership.
8. `08_RTL_FAILURE_RISK_REGISTER` — implementation hazards/assertions.
9. `06_SIMPLE_MILESTONE_ROADMAP` — sequencing/milestones.
10. `00_README...` — overview.

## 3. Quy tắc xung đột

- Nếu package này khác Canon: **Canon thắng**.
- Nếu hai lane khác nhau dùng semantic IDs khác nhau: **không merge**; tạo ABI migration.
- Nếu compiler và RTL dùng schema khác nhau: **LOAD_REJECT**, không “best effort”.
- Nếu alias human khác SELF_ID: SELF_ID thắng semantic identity.
- Nếu learned score mâu thuẫn ASTRA proof: ASTRA thắng.
- Nếu candidate teacher mâu thuẫn verified fact: candidate không được promote tự động.
- Nếu prediction mâu thuẫn verified fact: prediction không được gọi truth.

## 4. Single source of truth

Schema logic nên có một nguồn authority duy nhất, ví dụ:

`CANON_KNOWLEDGE_SCHEMA.yaml`

Từ đó generate:

- Python enums
- SystemVerilog enums/includes
- relation registry
- unit/value kinds
- ABI manifest
- reference test IDs

Cấm duy trì cùng một registry thủ công ở Python + JSON + SVH.

## 5. Owner authority

Các trạng thái như BOARD_PASS, LDA, freeze lineage hoặc owner stamp chỉ được xác nhận khi owner thật sự phê duyệt. Session/tool không tự stamp.
