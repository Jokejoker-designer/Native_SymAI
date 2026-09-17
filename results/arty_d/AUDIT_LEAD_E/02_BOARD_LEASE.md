# BOARD_LEASE — Arty A7-100T

Một board. Không JTAG/UART song song.

## Định danh phần cứng

| Mục | Giá trị |
|---|---|
| Part | `xc7a100tcsg324-1` |
| Board | Digilent Arty A7-100T |
| JTAG serial | `210319BE776EA` |
| UART FTDI serial | `210319BE776EB` |
| UART | 115200 8N1, DTR/RTS off |
| Host script | `D:\FPGA\arty_d\m4_mig\uart_pack24_clear_board.py` |
| Program Tcl | `CANON_BLUEPRINT\vivado\tcl\32_program_m4_mig_clear.tcl` |
| Freeze DCP (không đụng) | `858d0e997214e36074cc67f66f42af85c7f4da18f0590148ea509e8bb276d6dd` và rollback `b48b7c8858a39d2a7da0e005b1fb0cc01c2de6e0b1e829f2dbe14531a4b73388` |
| Historical M4+mig bit (không đè) | `D:\FPGA\arty_d\m4_mig\arty_a7_r2_top_m4_mig_candidate.bit` sha256 `f6a6091fccab5bdb331932195d34c984f3101cdf52d3959c172706b33ba368d7` |

## File trạng thái

`D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\_COORDINATION\board_lease.json`

## Giao thức mailbox

Subject bắt buộc:

- `BOARD_LEASE_REQUEST` — gửi `AGENT_E` và `AGENT_D`. Body: agent, duration_min, purpose, JTAG yes/no, UART yes/no, program yes/no.
- `BOARD_LEASE_GRANT` — `AGENT_E` (dispatcher) gửi holder. Body: until timestamp UTC, resource ARTY_A7_100T.
- `BOARD_LEASE_DENY` — đang HOLD.
- `BOARD_LEASE_RELEASE` — holder gửi khi xong. Cập nhật `board_lease.json` `state=FREE`, `holder=null`.

Không program khi `holder` khác mình. Không `vivado -mode batch` 32_program khi không có GRANT.

**Owner 2026-09-17:** AGENT_E **không được nạp** dù đang HOLD. E GRANT UART/JTAG capture `program=no` cho chính E. E GRANT `program=yes` **chỉ** cho AGENT_D. SRAM identity D `bbba86c1` nên được UART-probe trước khi D nạp identity H `cf62102f`.

## Trạng thái lúc bàn giao (2026-09-16T22:10Z)

- Campaign AGENT_D trên bit `bbba86c1…` đã `exit_code=1`, UART đóng.
- `state=FREE`, `holder=null`.
- AGENT_D không giữ lease sau bàn giao này.
