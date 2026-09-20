# U33: từ UNKNOWN đến phép đo phân biệt được

FACT — Đã chạy XSim 2026.1, UART 115200, U33 bind + U11 RX + U32 harness, destination BRAM. Nguồn product được dùng nguyên trạng. Năm trường hợp hoàn tất trong 38 giây, `$finish=79493835 ns`; xem [raw log](sim/discriminator.log) và [simulator log](sim/xsim.log). Không truy cập UART/JTAG, không nạp board.

## Kết quả mới, không chỉ là phương án

FACT — Một gap 22 bit-times sau byte đầu MAGIC làm P1 thành `01314941`; loader chỉ nhận **một BEGIN** nhưng vẫn trả `0200015a`. Đây là counterexample XSim trực tiếp đối với suy luận “MAG chứng minh extra BEGIN”. Chưa chứng minh board có gap đó.

FACT — Kết quả năm cell:

| Cell | Lỗi kiểm soát trong TB | Chặng 1 | Chặng 2 | Chặng 3 | Giá trị hw0 |
|---|---|---|---|---|---|
| 0 | Không lỗi | Im lặng | Im lặng | `0200075a` | `3149414e` |
| 1 | Thêm một BEGIN — positive control | `0200015a` | Dừng | Dừng | `00800001` |
| 2 | Đổi MAGIC, giữ số words | Im lặng | `0200015a` | Dừng | `12345678` |
| 3 | Bỏ nguyên word MAGIC | Im lặng | Im lặng | `0200015a` | `00010001` |
| 4 | Gap trong MAGIC, không thêm BEGIN | Im lặng | Im lặng | `0200015a` | `01314941` |

FACT — Tất cả cell có destination write count=0. Đây là kết quả của các state có kiểm soát trong test, không phải bảo đảm mọi state board chưa biết đều không thể ghi DDR.

## Phép thử có thể chạy trên nguyên trạng U33

Đề xuất — Sau CLEAR ACK đúng bốn byte, gửi canonical manifest theo ba chặng:

1. BEGIN + 31 payload words (128 bytes).
2. Payload word cuối (4 bytes).
3. OP_END (4 bytes), không gửi Region/Page.

INFERENCE — Token UNSUP ở chặng 3 là positive control có chủ ý vì chưa có Region/Page; không phải một pack hợp lệ hay Pack24 PASS. MAG ở chặng 1 chỉ ra manifest hoàn tất sớm trong các model đơn lỗi; chặng 2 phù hợp sai nội dung với đúng count; chặng 3 phù hợp thiếu payload/byte alignment. Các signature là có điều kiện, không phân loại duy nhất mọi lỗi kết hợp hoặc phản hồi trễ.

FACT — Hai cell 3/4 cho cùng phản hồi UART nhưng khác hw0. Vì vậy UART hiện tại có giới hạn phân biệt thực sự. Dù prefix probe sạch, nó không bác bỏ lỗi phụ thuộc timing của campaign liên tục. Tất cả im lặng phải là INCONCLUSIVE, không phải EMPTY hay PASS.

### Công cụ đã chuẩn bị

`uart_prefix_probe.py` mặc định chỉ kiểm hash và in kế hoạch, không mở COM. Chế độ UART ghi đầy đủ TX bytes/hash/write-count, timestamps monotonic, mọi RX chunk và từng checkpoint. Không kill server/process; không tự retry/reopen, không xóa receive buffer, không overwrite log cũ, không program. Dừng ở lần lệch đầu tiên. Phiên mặc định một round; tối đa 16.

Lệnh kiểm tra offline đã chạy:

```powershell
python D:\FPGA\Native_SymAI\docs\audits\20260919_u33_discriminator\uart_prefix_probe.py
```

Chỉ operator được owner phối hợp board với D mới chạy lệnh UART; thay grant-ref bằng tham chiếu phê duyệt thật, chọn output mới:

```powershell
python D:\FPGA\Native_SymAI\docs\audits\20260919_u33_discriminator\uart_prefix_probe.py --execute --port COM12 --resident-sha256 ff399e0bb9e6ff6c91caf3b769270b03ca9cfb2ea317035a5f3533031338a350 --grant-ref "OWNER_APPROVAL_REFERENCE" --out D:\FPGA\arty_d\UART_R2\results\U33_PREFIX_OWNER_RUN_01.jsonl
```

Output: một JSONL mới, gồm identity claim, đầy đủ TX/RX, verdict từng chặng và stop reason. `resident-sha256` là owner-recorded identity; script không giả vờ đã đọc lại cấu hình SRAM. Chế độ execute cần pyserial. Không dùng kết quả này để đổi identity hay sửa product RTL.

Lệnh chạy lại mô phỏng, output phải chưa tồn tại:

```powershell
& D:\FPGA\Native_SymAI\docs\audits\20260919_u33_discriminator\run_sim.bat D:\FPGA\Native_SymAI\docs\audits\20260919_u33_discriminator\sim_run02
```

Outputs: `discriminator.log`, `xsim.log`, `xvlog.log`, `xelab.log`, copied canonical `.mem` và simulator artifacts. Runner kiểm banner hoàn tất đủ năm cell; failed run được giữ nguyên. TB chỉ tạo stimulus UART, không force nội bộ DUT; calibration dùng BRAM model tự nhiên. Positive controls có thêm/bớt dữ liệu được gắn nhãn rõ; script board không gửi các fault-injection cell đó.

FACT — Bộ phân loại host đã replay 12 checkpoint từ raw XSim log, cùng kiểm tra extra-byte reply và silence cuối; tất cả khớp. Chưa kiểm chứng serial hardware behavior.

## Cách đóng UNKNOWN đến đúng hop

INFERENCE — Không nên mở thêm chuỗi XSim five-V04 hoặc thay UART/qsc/loader trước khi có dữ liệu mới. Để kết luận tận hop cần một phép capture event nội bộ; external UART pin trace chỉ phân tách host/FTDI với FPGA, không phân tách FIFO với CDC.

Đề xuất — Một diagnostic identity riêng, chỉ thêm observer, cần owner cho phép. Không overwrite U33/H/H_OBS/freeze. Không cấp backpressure từ observer vào DUT. Ghi hai miền clock riêng, event-qualified, giữ dữ liệu qua VALIDATION_CLEAR, đóng băng tại first BAD_MAGIC. Không đọc multibit timestamp từ clock khác để giả đồng bộ.

| UNKNOWN | Dữ liệu quyết định cần giữ | Quy tắc xác định first divergence |
|---|---|---|
| Host/FTDI hay FPGA RX | Host TX bytes + passive pin RX + completed UART bytes/words | Pin sai so với host → host/transport; pin đúng nhưng decoded word sai → RX/framing. |
| Duplicate BEGIN | Ordered accepted words tại từng hop | Hop đầu có thêm BEGIN so với đầu vào hop ấy chịu trách nhiệm; chỉ đếm BEGIN toàn tuyến là chưa đủ. |
| Missing MAGIC | Chuỗi write/pop/CDC/loader và word index | Tìm ranh giới đầu có mất/lệch MAGIC; phân biệt mất byte ở RX với mất word sau RX. |
| Stale FIFO | wadr/radr/used/flush, write-data và pop-data | Pop không tương ứng với word hợp lệ còn trong queue, hoặc sau flush nhưng epoch cũ, là vi phạm FIFO/flush. |
| Unlocked pop | Actual `rd_valid&&rd_ready`, steering/lock và CDC A accept | FIFO pop nhưng không có CDC accept; kiểm tra có phải discard hợp lệ lúc CLEAR hay làm mất header sau ACK. |
| CDC replay | A accept, B accept, req/ack/last/hold và hai reset | Một A accept sinh hai B accepts, với causal reset history đầy đủ, phân loại replay. |
| Reset/CLEAR race | Assert/deassert reset, CLR request/ack, parser state và handshakes | Xác định beat nằm qua reset nào; không suy từ thời điểm UART ACK đơn độc. |
| Loader carry-over | State/opcode/rx_words/got_begin/hw0 trước CLEAR và lúc nhận payload | Ingress BEGIN→MAGIC đúng nhưng parser không khởi đầu/capture đúng → loader/reset/physical state path. |

Đề xuất — Recorder khởi điểm: 1024×256-bit events clk100 và 512×256-bit events ui_clk, điều chỉnh sau khi đo coverage. Mỗi cycle có thể có nhiều hop: record dùng multi-hot mask và các payload song song, không ưu tiên một event làm mất event khác. Không ghi các idle cycles.

Đề xuất — Arm-time snapshot phải chứa trạng thái đầy đủ, kể cả parser đã ở giữa BEGIN. Giữ prior completion/CLEAR và toàn manifest lỗi; observer không reset cùng loader. Capture event/reset transitions; không ghi mỗi cycle `load_reject=1` sticky. Đếm overflow/wrap và đánh dấu capture thiếu lịch sử là INVALID. Correlate hai miền bằng req/ack transitions đã ghi; không tự giả hai CLEAR counters bằng nhau vì BUSY/timeout có thể chặn request sang UI.

INFERENCE — Nếu diagnostic bit không tái hiện U33, không được đóng UNKNOWN: thay placement/timing do observer là một khác biệt thật. Giữ trace pin trên U33 gốc, so sánh với diagnostic, thu hẹp bằng replay đúng timing. Không dùng clean diagnostic để tha lỗi cho original identity.

## Tiêu chí dứt điểm

Đề xuất — Một causal finding chỉ được đóng khi có: (1) transaction lỗi với identity/hash rõ; (2) hop trước còn đúng và hop sau sai, từ actual accepted beats; (3) thay đúng điều kiện gây lỗi trong test cô lập làm xuất hiện/biến mất lỗi; (4) sửa hẹp được kiểm lại bằng negative controls và campaign gốc. Sau đó Pack cần gate riêng; tìm được root không tự tạo PACK_ABI_24_24_PASS.

Đề xuất — Thứ tự thực thi: một prefix session trên U33 nguyên trạng để lấy thêm phân biệt rẻ; nếu vẫn cần tách hop, thực hiện event capture trên diagnostic identity đã được duyệt. Không lặp prefix vô hạn: sau tối đa 16 rounds hoặc một bất thường, chuyển sang capture. Giai đoạn local simulation/tooling đã hoàn tất; board session và diagnostic build/program chưa được thực hiện.

FACT — PACK_ABI_24_24_PASS=NO; BOARD_PASS=NO; PROGRAM=NO; overlay=NO; không kill/resume simulation của task khác. Board vẫn theo quyền sử dụng riêng của AGENT_D; cần owner phối hợp trước khi mở COM12 hoặc nạp diagnostic identity.

## Bổ sung sau owner approval 2026-09-20

FACT — Owner đã cho phép UART, rồi cho phép nạp lại chính xác U33. Xem [kết quả CONTROL2](BOARD_20260920_CONTROL2.md) cho mốc identity mới, 36 V04 GOLD của host mới và đối chứng host cũ mute/phục hồi. Các dòng PROGRAM=NO ở phần simulation phía trên chỉ mô tả pha offline ban đầu.

Host tool bổ sung các lựa chọn đã dùng trong campaign: `--warmup-packs 4` để có bốn V04 hoàn chỉnh trước prefix; `--reply-tail-s 0.05 --post-gold-drain-s 0.2` để quan sát tail/drain; `--warmup-packs 24 --full-v04-only` để kiểm 24 lần cùng V04, không gọi là 24 ABI cases. Các full V04 ghi test payload vào DDR; default vẫn offline và không mở COM. Mọi live run cần output mới và phạm vi board được owner giao.
