# U33 nạp lại rồi A/B/A dummy-open — 2026-09-20

FACT — Owner: “Phải nạp lại board nhé”. Nạp đúng frozen U33 `ff399e0bb9e6ff6c91caf3b769270b03ca9cfb2ea317035a5f3533031338a350` vào `xc7a100t_0` / Digilent `210319BE776EA`. Không build mới, không sửa product RTL, không ghi flash, không nạp U33TAP `d448544f…`, không nạp H. `PROGRAMMED_CANDIDATE_ONLY`. `PROGRAM_PASS=NO`.

FACT — A/B/A trước nạp (`U33_ABA_DUMMYOPEN_20260920`) không phải discriminator dummy-open: cả ba arm CLEAR1 n=0, reopen `6e6f00`. SRAM lúc đó UNKNOWN.

## Program

| Field | Value |
|---|---|
| PROGRAM_BEGIN | unix 1789897643 ≈ 2026-09-20 16:47:23 +07 |
| End of startup | HIGH |
| CRC error BIT00 | 0 |
| DONE internal BIT13 | 1 |
| DONE pin BIT14 | 1 |
| STATUS | PROGRAMMED_CANDIDATE_ONLY |
| After program | `taskkill` hw_server PID 19220; cs_server tree killed; COM12 FTDI `210319BE776EB` present |

Record: [PROGRAM_RECORD.txt](D:/FPGA/arty_d/UART_R2/results/U33_OWNER_PROGRAM_20260920_ABA/PROGRAM_RECORD.txt) sha256 `8da16eda…efed3ea3`.

## A/B/A sau nạp (một biến: dummy-open/close)

Script: `aba_dummy_open_20260920.py` sha256 `ae7191d8…7034c75a`. Giữ MARK 2 s, timeout 0.05, real-open purge, TX V-04 208 B, `WAIT_AFTER_ACK=0`, CLEAR rồi một V-04, `UART_TIMEOUT_S=12`. Biến duy nhất: dummy-open MARK 2 s → close → 200 ms → real-open.

JSON: [ABA.json](D:/FPGA/arty_d/UART_R2/results/U33_ABA_DUMMYOPEN_20260920_POSTPROG/ABA.json) sha256 `01e2cd64…d6322d08`. iso `2026-09-20T16:49:39+07:00`.

| Arm | dummy | CLEAR1 | V-04 | Drain | Verdict |
|---|---|---|---|---|---|
| A1 | True | n=0 (3.05 s) rồi reopen ACK `c1ea50a5` | n=0 12.05 s | n=0 | V04_FAIL |
| B | False | ACK `c1ea50a5` 0.06 s | GOLD `010000a5` n=4 0.08 s | n=0 | GOLD |
| A2 | True | ACK `c1ea50a5` 0.06 s (không cần reopen) | n=0 12.01 s | n=0 | V04_FAIL |

FACT — Không MAG/NAK/BUSY/STALE/UNSUP trên ba arm này. Mute là n=0, không phải `0200015a`.

FACT — A2 CLEAR ACK ngay lần đầu sau dummy-open. Dummy-open **không** phải nguyên nhân duy nhất của CLEAR1 n=0. Cả hai arm dummy đều mute V-04; arm không dummy GOLD.

FACT — Các phép thử tiếp theo trên cùng bit U33 cho kết quả GOLD trong mọi nhánh: DTR/RTS matrix (`DTR=false/RTS=false`, DTR-only, RTS-only, cả hai) đều CLEAR ACK + V04 GOLD; close-phase matrix (baseline, đóng dummy ngay, đọc/purge rồi đóng) cũng đều CLEAR ACK + V04 GOLD. Các kết quả này có cùng V04 SHA256 `a2cbeb8c...6148be`, nạp/RTL không đổi.

INFERENCE — Trên một chuỗi A/B/A cụ thể sau nạp, dummy-open/close **đủ** để mất GOLD hop-1 V-04 trong protocol đó. Các matrix sau đó đều GOLD, nên đây là trigger có tính lịch sử/timing hoặc xác suất, chưa phải nguyên nhân tất định. Path FPGA/UART/Pack V-04 không chết vĩnh viễn: B GOLD ngay sau A1 mute, và các matrix sau không nạp lại.

INFERENCE — Khớp CONTROL2: host cũ (có dummy-open) mute; host mới (không dummy-open) GOLD. A/B/A này thu hẹp biến so với CONTROL2 (không đổi timeout/purge/retry song song).

UNKNOWN — Cơ chế vật lý còn lại là một trạng thái/timing tương tác khó lặp lại: USB/FTDI open-close lifecycle, framing/byte timing, UART RX state, hoặc CLEAR/FIFO/CDC state. DTR/RTS mức cuối và close/mark riêng lẻ chưa tái hiện được mute. MAG lịch sử P0/P1 vẫn UNKNOWN. Mute ≠ MAG.

CONTRADICTED (chạy này) — “Cần dummy-open mới CLEAR được.” A2 CLEAR ACK với dummy; B CLEAR ACK không dummy.

## Stamps

PACK_ABI_24_24_PASS=NO. BOARD_PASS=NOT_EVIDENCED. PROGRAM_PASS=NO. TIMING_PASS=NO. MIG_PASS=NO. Overlay=NO. 1 GOLD ≠ 24 ABI cases. 24 V-04 GOLD trước đó cũng không phải Pack24.

## Next

Không patch `pack_loader` / MIG / UART PHY vì mute này. Không nạp TAP trừ khi MAG trở lại và owner YES.

Nếu campaign Pack24 cần hop-1 GOLD: bỏ dummy-open trên host là biện pháp giảm rủi ro thực dụng, nhưng chưa phải root-cause fix. Không patch product RTL theo mute. Để đóng MAG thật sự cần accepted-beat capture nội bộ; FEM persist vẫn blocked.
