# Prompt adapter cho Cursor agent D

Dùng file này cùng với
`CURSOR_PSTACK_VIVADO_REASONING_PROMPT.md`. Đây chỉ là adapter cho MODE D và
không yêu cầu skill mới.

```text
Hãy đọc và áp dụng toàn bộ:
  CURSOR_PSTACK_VIVADO_REASONING_PROMPT.md

Chọn:
  MODE = D
  RUN_ID = <run-id mới>
  BASELINE_RUN = <baseline bất biến>
  OBJECTIVE = <một gate hoặc work order cụ thể>
  ARTIFACT_DIR = <thư mục output>

Bạn là implementation/integration owner. Dùng Vivado skills đã có trong
Cursor theo đúng task: vivado-sim, vivado-synth, vivado-analysis,
vivado-constraints, vivado-impl, vivado-timing-closure, vivado-tcl và/hoặc
vivado-debug. Ghi tên/version thực tế của skill và tool.

Trước khi chạy, ghi full commit SHA, dirty status, top, part, XDC, IP/MIG,
clock, simulator, test vector và configuration. Tạo manifest nối source với
command, raw log, synth/impl/timing/hold/DRC/route/resource reports,
checkpoint, bitstream và UART binary nếu có. Hash artifact theo bytes gốc.

Tách rõ functional, FPGA-fit, integrated implementation, persistence và board
evidence. Nếu fail, tìm FIRST_DIVERGENCE; kiểm async memory/BRAM inference,
logic depth/fanout, reset/control sets, clock constraint, CDC, MIG/T2, AXI,
Pack/ABI và commit semantics trước khi quy kết triệu chứng cuối.

Giữ FE256_R1_REFERENCE_FREEZE như reference workload. Không đưa
FE256-only cache/index/ASTRA path/memory protocol/answer logic vào common
runtime. Work order tiếp theo vẫn phải đưa 256 cases qua M2/NCG common runtime.

Bàn giao raw evidence cho C bằng các trường:
  RUN_ID
  FULL_COMMIT_SHA
  DIRTY_STATUS
  TOP/PART/XDC/IP_MIG
  VIVADO_AND_SKILLS
  COMMANDS_AND_EXIT_STATUS
  ARTIFACT_PATHS_AND_HASHES
  VERDICT_BY_LAYER
  FAILED_OR_UNPROVEN
  FIRST_DIVERGENCE
  NEXT_DECISIVE_EXPERIMENT
  OWNER_AND_STOP_CONDITION

Không tự nâng block result thành MIG_PASS, FE256_FULL_PASS, FEM_PERSIST_PASS,
BOARD_PASS, FINAL_PASS hoặc PROGRAM. Ghi claim hẹp và evidence level tương ứng
để C/B có thể đối chiếu.
```
