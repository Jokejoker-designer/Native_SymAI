# NATIVE_AI_AGENT_GUARD_R1

Bộ công cụ Python **stdlib-only** để điều phối nhiều agent cùng phát triển Native AI FPGA mà không làm hỏng lineage, timing evidence, benchmark authority hay bitstream reproducibility.

## Mục tiêu

Tool này không thay Vivado. Nó đứng **bên ngoài Vivado** và cưỡng chế workflow:

```text
Agent task
→ lease / dependency check
→ source contract hash
→ isolated execution
→ Vivado/XSim raw evidence
→ timing/CDC/DRC gate
→ artifact hash chain
→ candidate only
→ owner review
```

## Cài đặt

Windows PowerShell:

```powershell
cd NATIVE_AI_AGENT_GUARD_R1
py -m pip install -e .
native-guard --root D:\FPGA\YOUR_PROJECT init
```

Không cần package ngoài Python chuẩn.

## Workflow khuyến nghị cho mỗi agent

```powershell
# 1. Mỗi agent dùng git worktree riêng
# 2. Init guard
native-guard --root . init

# 3. Claim task và file/resource
native-guard --root . task-claim synth --agent AGENT_TIMING
native-guard --root . claim vivado_impl --agent AGENT_TIMING --ttl 14400

# 4. Freeze source contract
native-guard --root . freeze-contract M3_SYNTH_INPUT

# 5. Run tool under watchdog
native-guard --root . run synth --agent AGENT_TIMING --timeout 14400 -- vivado -mode batch -source scripts/synth.tcl

# 6. Generate sign-off Tcl and run in Vivado
native-guard --root . vivado-tcl --out scripts/native_guard_signoff.tcl --reports-dir reports/signoff

# 7. Parse sign-off evidence
native-guard --root . vivado-check --timing reports/signoff/timing_summary.rpt --util reports/signoff/utilization.rpt --drc reports/signoff/drc.rpt --methodology reports/signoff/methodology.rpt --cdc reports/signoff/cdc.rpt --clock-interaction reports/signoff/clock_interaction.rpt

# 8. Verify source did not drift
native-guard --root . verify-contract M3_SYNTH_INPUT

# 9. Mark task with evidence (only if the required human/automated review is complete)
native-guard --root . task-finish synth PASS --agent AGENT_TIMING --evidence '{"timing":"reports/signoff/timing_summary.rpt"}'
```

## Quy tắc timing

Timing **không** chỉ là WNS. Post-route acceptance tối thiểu cần setup, hold, unconstrained path, clock interaction, CDC, methodology, DRC, utilization/congestion và high-fanout review. Nếu parser không đọc được một trường sign-off bắt buộc, tool trả `REVIEW_REQUIRED`, không tự suy đoán PASS.

## Quy tắc parallel agent

- Một agent không được build trên source đang bị agent khác sửa.
- Không dùng chung Vivado run directory.
- Board/JTAG/UART là exclusive resource.
- Gold/GOAL/ABI/acceptance được bảo vệ.
- Functional patch làm invalidate downstream evidence.
- Failure evidence append-only, không overwrite.
- Tool không cấp `BOARD_PASS`; nó chỉ tạo evidence/candidate state.

Đọc `docs/THREAT_MODEL.md`, `docs/TIMING_SIGNOFF.md`, `docs/AGENT_PROTOCOL.md` trước khi đưa vào repo thật.
