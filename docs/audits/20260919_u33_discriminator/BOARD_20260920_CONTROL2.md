# U33 nạp lại và đối chứng host — 2026-09-20

FACT — Owner xác nhận chương trình trên board đã bị thay đổi và yêu cầu nạp lại. Phiên CONTROL2 nạp đúng bit U33 `ff399e0bb9e6ff6c91caf3b769270b03ca9cfb2ea317035a5f3533031338a350` vào xc7a100t_0 / Digilent 210319BE776EA; startup HIGH lúc 16:23:13 +07, DONE internal/pin=1, configuration CRC error=0. Không build mới, không sửa product RTL, không ghi flash. `PROGRAMMED_CANDIDATE_ONLY`, không PROGRAM_PASS.

FACT — Các lỗi UART trước mốc nạp lại, trong khoảng owner báo thiết kế đã đổi, không được tự quy cho U33. `PROGRAM.txt` lịch sử hoặc hash bit trên đĩa không chứng minh identity lúc đó trong SRAM.

## Kết quả sau mốc CONTROL2

| Thứ tự | Phép đo | Kết quả thô |
|---|---|---|
| A1 | Một COM session, 4 V04 hoàn chỉnh, reply window dài; rồi prefix | 4 GOLD; prefix im lặng / im lặng / `0200075a` |
| A2 | Một COM session, reply quiet-tail 50 ms, GOLD drain 200 ms; 4 V04 rồi prefix | 4 GOLD; prefix im lặng / im lặng / `0200075a` |
| A3 | Cùng kiểu host mới; 24 CLEAR→V04 liên tiếp | 24 ACK chính xác; 24 GOLD chính xác; TX mỗi V04=208 bytes, đúng một BEGIN; không byte dư ở drain, không stop/error |
| B | Bản sao campaign host hiện tại, mode nwp4p5, chỉ chuyển output mới và tắt process-kill | CLEAR1 n=0; retry n=0; reopen có ACK; V04 đầu n=0 trong 12 giây; dừng |
| A4 | Trở lại host mới, không nạp lại; 4 V04 rồi prefix | 4 GOLD; prefix im lặng / im lặng / `0200075a` |

FACT — Tổng host mới: 36 V04 GOLD trong bốn phiên, trong đó một phiên có 24 liên tiếp; ba prefix controls đúng chữ ký dự kiến. Host cũ/copy không chạy tới 24 vòng vì dừng ngay V04 đầu. Không quan sát MAG trong chuỗi CONTROL2 này.

FACT — Header prefix cố ý chưa có Region/Page, nên UNSUP `0200075a` ở END là positive control parser, không phải valid full-pack acceptance. 24 lần cùng V04 không phải bộ 24 test cases Pack/ABI.

INFERENCE — Lỗi “mọi fifth V04 trên U33 đều MAG” không phù hợp kết quả board này. FPGA/DDR không ở trạng thái hỏng vĩnh viễn: path có thể GOLD trước và sau host mute mà không nạp lại. Điều này không chứng minh toàn bộ MIG hoặc Pack24 đạt acceptance.

INFERENCE — Chuỗi A-good/B-mute/A-good hỗ trợ điều tra host/UART session + protocol state/timing trước khi sửa product RTL. Đây chưa phải A/B đơn biến: B khác open/reopen, input purge, read timeout và reply/drain behavior; state history cũng thay đổi theo thứ tự. Chưa đủ để kết luận chính xác open COM, FIFO, CDC hay RX là root cause; cũng chưa chứng minh mute này cùng nguyên nhân với MAG lịch sử.

FACT — Timestamp host có lượng tử hóa khoảng mili-giây/15–16 ms trong log; không dùng chúng để suy ra timing từng byte trên dây UART. Current host copy đã có các dòng TX_V04 diagnostics từ source hiện tại; không coi nó là executable nguyên xi của lần lỗi lịch sử.

UNKNOWN — Internal accepted P0/P1 trên transaction MAG lịch sử. Các token prefix phù hợp mô hình nhận header đúng; không phải ILA capture của P0/P1.

## Bằng chứng

FACT — Summary cùng hash các log: [U33_CONTROL2_DIFFERENTIAL_20260920.json](D:/FPGA/arty_d/UART_R2/results/U33_CONTROL2_DIFFERENTIAL_20260920.json).

- [Program record](D:/FPGA/arty_d/UART_R2/results/U33_OWNER_PROGRAM_20260920_CONTROL2/PROGRAM_RECORD.txt)
- [4 V04 + prefix, window dài](D:/FPGA/arty_d/UART_R2/results/U33_PREFIX_CONTROL2_20260920T162324.jsonl)
- [4 V04 + prefix, tail 50 ms](D:/FPGA/arty_d/UART_R2/results/U33_PREFIX_FASTTAIL_20260920.jsonl)
- [24 V04 liên tiếp](D:/FPGA/arty_d/UART_R2/results/U33_REPEAT_V04_24_20260920.jsonl)
- [Host cũ mute](D:/FPGA/arty_d/UART_R2/results/U33_ORIGINAL_HOST_CONTROL_20260920T1627_REPROG/BOARD_BASELINE.json)
- [Phục hồi không nạp lại](D:/FPGA/arty_d/UART_R2/results/U33_PREFIX_RECOVERY_AFTER_OLDHOST_20260920.jsonl)

FACT — Copy host B: `campaign_original_control_20260920.py`; không sửa `u33/u33_campaign.py`, không overwrite các fail bags cũ. Các server của phiên khác không bị kill. Mọi COM session của audit đã đóng. Sau B, A4 kết thúc bằng deliberate UNSUP; board vẫn giữ bit U33 theo lần nạp mới nhất của task, không được giả định đang ở parser IDLE cho công việc sau. Công việc tiếp theo cần CLEAR như giao thức.

## Hành động tiếp theo có thông tin cao

ĐỀ XUẤT — Phép tiếp theo cụ thể là A/B/A trên cùng host flow gốc: A giữ dummy-open→đọc MARK 2 s→purge→close→200 ms→real-open; B bỏ duy nhất dummy-open/close, vẫn giữ reader/timeout 50 ms, real-open purge, TX bytes và ACK/GOLD timing của A. Ghi log đồng đều ở cả ba arm; dừng ở first divergence từng arm, không tự nạp lại. Nếu lỗi đi theo A cả trước/sau B thì hỗ trợ lifecycle-sensitive transport/RTL interaction; chưa phân biệt FTDI với UART/reset. Không đồng thời đổi purge và read timeout. Nếu board MAG xuất hiện, capture pin UART hoặc accepted-beat observer mới phân biệt được host/FTDI/RX/FIFO/CDC; không sửa loader để né MAGIC.

FACT — PACK_ABI_24_24_PASS=NO; BOARD_PASS/MIG_PASS/PROGRAM_PASS không stamp; overlay=NO. Kết quả này xác nhận các chuỗi đo cụ thể, không tuyên bố MAG root cause đã đóng.
