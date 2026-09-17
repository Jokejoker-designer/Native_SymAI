# AGENT_E — Audit Lead

ID mailbox: `AGENT_E`  
Folder làm việc độc lập (copy nguyên trạng tại thời điểm bàn giao): `D:\FPGA\arty_d\AUDIT_LEAD_E\`  
Không ghi đè freeze DCP. Không sửa RTL C (`qstar_select.v` / `spear_rank.v` / `fem_lifecycle.v`). Không tự stamp PASS.

## Nhiệm vụ

Owner 2026-09-17: `AUDIT_FULL_EXCEPT_PROGRAM`. Luật: `04_OWNER_MANDATE_AUDIT_FULL_EXCEPT_PROGRAM.md`.

E làm mọi việc audit cần thiết. **Cấm nạp board.** AGENT_D cầm trịch implementation + program sau GRANT.

Đọc theo thứ tự:

0. `04_OWNER_MANDATE_AUDIT_FULL_EXCEPT_PROGRAM.md` — luật hiện hành.
1. `01_BIEN_BAN.md` — nhật ký FACT, phạm vi, lệnh, kết quả, lỗi đã gặp, việc đã làm.
2. `02_BOARD_LEASE.md` — chia board.
3. `SHA256MANIFEST.json` — SHA256 từng file copy.
4. `snapshot/` — RTL/TB/Tcl/gold/host/report y nguyên.

Kết quả audit ghi vào `D:\FPGA\arty_d\AUDIT_LEAD_E\E_AUDIT_OUT\` (tự tạo). Gửi mailbox `AGENT_D`, `OWNER`, `AGENT_B`. Không stamp `PACK_ABI_24_24_PASS` / `BOARD_PASS` / `TIMING_PASS` / `MIG_PASS` / `PROGRAM_PASS`.

Reasoning export D (không phải kết luận E): `03_REASONING_EXPORT.md`. Lessons L-019 / L-020 trong `NATIVE_AI_SHARED_REASONING_LESSONS.md`.

## Mailbox

```
cd D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\_COORDINATION
python mailbox.py AGENT_E check
python mailbox.py AGENT_E send AGENT_D BOARD_LEASE_REQUEST "AGENT_E need JTAG+UART duration_min=30 purpose=READ_ONLY_UART_CAPTURE"
python mailbox.py AGENT_E send AGENT_D BOARD_LEASE_RELEASE "AGENT_E release ARTY_A7_100T"
```

## XSim (không cần board)

Word:

```
cmd /c D:\FPGA\arty_d\pack_debug_clear\run_xsim_word.bat
```

UART:

```
cmd /c D:\FPGA\arty_d\pack_debug_clear\run_xsim_uart.bat
```

Bản copy bat nằm `snapshot\arty_d\pack_debug_clear\`. Bat gốc trỏ RTL live `CANON_BLUEPRINT`. Muốn XSim trên snapshot: sửa `ROOT` trong bản copy bat sang `...\AUDIT_LEAD_E\snapshot\CANON_BLUEPRINT`.

## Board

Một Arty A7-100T. JTAG `210319BE776EA`. UART FTDI `210319BE776EB` COM (thường COM12) 115200 8N1. Xem `02_BOARD_LEASE.md`.
