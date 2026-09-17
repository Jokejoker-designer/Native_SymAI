# Prompt adapter cho Cursor agent C

Dùng file này cùng với
`CURSOR_PSTACK_VIVADO_REASONING_PROMPT.md`. Đây chỉ là adapter cho MODE C và
không yêu cầu skill mới.

```text
Hãy đọc và áp dụng toàn bộ:
  CURSOR_PSTACK_VIVADO_REASONING_PROMPT.md

Chọn:
  MODE = C
  RUN_ID = <run-id cần audit>
  BASELINE_RUN = <baseline bất biến>
  OBJECTIVE = <claim hẹp của D cần kiểm>
  ARTIFACT_DIR = <thư mục audit độc lập>

Bạn là independent verifier. Dùng các Vivado skills đã có trong Cursor,
chỉ chọn skill cần thiết từ vivado-synth, vivado-analysis,
vivado-constraints, vivado-impl, vivado-timing-closure, vivado-sim,
vivado-tcl và vivado-debug.

Đọc raw source/log/report/checkpoint/capture theo RUN_ID trước khi kết luận.
Tự đóng băng full SHA, dirty status, top, part, XDC, IP/MIG, tool và artifact
hash. Rerun smallest decisive check với test/control giữ nguyên. So sánh run
tốt, run lỗi và baseline theo cùng dimension; xác định FIRST_DIVERGENCE trước
khi nêu triệu chứng cuối.

Đối với FE256, kiểm đồng thời semantics và FPGA mapping: async hay sync
memory, BRAM inference, logic depth/fanout, registered/sequential reduction,
resource, WNS/WHS, DRC và route. Đối với Native AI path, kiểm query leak,
role reversal, ID permutation, actual key, width preservation, common-runtime
path và accepted-versus-committed.

Không sửa product RTL, frozen oracle, threshold, test vector, baseline hoặc
failed artifact trong lượt audit. Ghi mọi finding vào audit output và append
lesson mới theo template trong NATIVE_AI_SHARED_REASONING_LESSONS.md.

Bắt buộc trả:
  CURRENT_CLAIM
  RUN_PROVENANCE
  EVIDENCE_MATRIX
  SUCCESS_VS_FAILURE
  FIRST_DIVERGENCE
  ROOT_CAUSE_OR_UNKNOWN
  BLAST_RADIUS
  VERDICT_BY_LAYER
  LESSON_TO_SHARE
  STRUCTURAL_GUARD_OR_TEST
  NEXT_DECISIVE_EXPERIMENT
  OWNER_AND_STOP_CONDITION

Nếu không nối được claim với raw artifact đúng run, dùng NOT_EVIDENCED hoặc
BLOCKED; không dùng một chữ PASS cho toàn bộ hệ thống.
```
