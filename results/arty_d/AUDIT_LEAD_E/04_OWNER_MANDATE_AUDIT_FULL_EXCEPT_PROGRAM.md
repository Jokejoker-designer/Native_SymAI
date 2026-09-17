# OWNER MANDATE — 2026-09-17T05:50+07:00

Issuer: owner (Anh) via AGENT_D (project lead).  
Receiver: AGENT_E (Audit lead - E).

## Authority

| Role | Agent | Bound |
|---|---|---|
| Project lead (cầm trịch) | AGENT_D | GOAL_AGENT_D FINAL R2, live RTL, synth/impl/bitgen, program **after GRANT** |
| Audit lead | AGENT_E | Deep audit of Pack CLEAR / handshake / host / evidence |
| Board dispatcher | AGENT_E | `board_lease.json` |
| Program FPGA (nạp) | AGENT_D only | Tcl `32_program_m4_mig_clear.tcl` after `BOARD_LEASE_GRANT` |

## Mandate (replaces ANALYSIS_ONLY)

```text
MANDATE=AUDIT_FULL_EXCEPT_PROGRAM
PROGRAM_BY_E=FORBIDDEN
ANALYSIS_ONLY=SUPERSEDED
```

E **được phép làm mọi việc cần thiết để audit**, trừ **nạp bitstream lên Arty**.

### E được làm

- Đọc / hash / diff live vs `snapshot/` vs `E_AUDIT_OUT/`
- Copy thêm evidence vào `AUDIT_LEAD_E/` (không đè freeze DCP, không đè bit lịch sử `f6a6091f`)
- XSim: word / UART 115200 / hold-flood / TB mới **trong** `E_AUDIT_OUT/` hoặc copy bat snapshot
- Mở DCP có sẵn, `report_timing` / util / DRC (analysis)
- Synth/impl/bitgen **chỉ** nếu cần artifact audit, output dưới `E_AUDIT_OUT/` — **không** `program_hw_devices`
- UART **READ_ONLY / probe** sau `BOARD_LEASE_GRANT` với `program=no` (1 CLEAR, log hex, `--mode probe`)
- Tạo TB/script audit; mailbox; cập nhật `E_AUDIT_OUT/`
- GRANT/DENY lease cho AGENT_D (D mới được nạp)

### E không được làm

- Nạp board: `32_program*.tcl`, `program_hw_devices`, `open_hw_target` rồi program, write_cfgmem SRAM/flash
- Sửa RTL C: `qstar_select.v` / `spear_rank.v` / `fem_lifecycle.v`
- Đè freeze DCP `858d0e99…` / `b48b7c88…` / `f25fdf64…`
- Đè bit lịch sử `D:/FPGA/arty_d/m4_mig/arty_a7_r2_top_m4_mig_candidate.bit` (`f6a6091f…`)
- Sửa FE256 cases / B gold TSV / QueryRecord / StructuredResult
- FEM persist
- Tự stamp: PACK_ABI_24_24_PASS BOARD_PASS TIMING_PASS MIG_PASS PROGRAM_PASS FE256_PASS ASTRA_PASS FINAL_PASS
- Merge RTL thí nghiệm vào live `CANON_BLUEPRINT` (D cầm implementation)

Thí nghiệm RTL của E: copy trong `AUDIT_LEAD_E/`. D mới được đưa vào live nếu D chấp nhận.

## Board lease

Một Arty. JTAG `210319BE776EA`. UART FTDI `210319BE776EB` (COM12 115200).

- E không tự nạp dù đang HOLD.
- GRANT cho E: UART/JTAG **read/capture only**, `program=no`.
- GRANT cho D: có thể `program=yes` khi E xong capture identity đang trên SRAM hoặc E ghi rõ defer.

**Thứ tự bắt buộc:** SRAM hiện tại vẫn identity D `bbba86c1` (PROGRAM.txt). File `.bit` cùng path đã bị bitgen identity H ghi đè (`cf62102f`). Bản H giữ `arty_a7_r2_top_m4_mig_validation_clear_cf62102f.bit`. Identity D **có thể không còn trên disk**. E nên UART-probe identity D **trước** khi GRANT D nạp H.

## Live vs snapshot (sau bàn giao)

| Item | FACT |
|---|---|
| SRAM | `bbba86c1…` (PROGRAM.txt) until D programs |
| Disk path `arty_a7_r2_top_m4_mig_validation_clear.bit` | identity H `cf62102f…` |
| Unique H copy | `D:/FPGA/arty_d/m4_mig_clear/arty_a7_r2_top_m4_mig_validation_clear_cf62102f.bit` |
| Host | `uart_pack24_clear_board.py` — 1 CLEAR default, `find_known` (no first-4 as ACK), `--mode probe` |
| Handshake RTL | live top `382ac125…`; **not** on SRAM |
| C RTL hashes | unchanged |

## Output

`D:/FPGA/arty_d/AUDIT_LEAD_E/E_AUDIT_OUT/`  
Mailbox: AGENT_D, OWNER, AGENT_B. Classify FACT/INFERENCE/HYPOTHESIS/UNKNOWN/CONTRADICTED.  
Reasoning export V1 required. HANDOFF_STATUS COMPLETE only when export written.
