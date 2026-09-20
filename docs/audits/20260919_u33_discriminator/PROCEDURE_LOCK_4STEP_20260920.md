# OWNER LOCK — quy trình 4 bước đóng MUTE/MAG tới module

STATUS: ACTIVE  
DATE: 2026-09-20T16:54+07  
OWNER: Anh  
OPERATOR: AGENT_D  
BIT: frozen U33 `ff399e0bb9e6ff6c91caf3b769270b03ca9cfb2ea317035a5f3533031338a350`  
PROGRAM_PASS=NO  PACK_ABI_24_24_PASS=NO  BOARD_PASS=NO  overlay=NO

ARCHITECTURE LOCK: common-runtime Pack path. Không AXI UART, không overlay H/U33, không patch product `pack_loader`/MIG để “né” token. FE256 freeze không đụng. Identity quan sát = bitstream mới, không ghi đè U33.

## Luật sắt

Không sửa chức năng trước khi có first-divergent hop trên capture.  
Cùng token MAG/mute không đủ để đóng root cause.  
Quyền nạp lại U33 (`program_exact_u33.tcl` + `OWNER_AUTHORIZED`) **không** gồm nạp identity quan sát. Bước 2 cần YES riêng.

Hai lớp lỗi không được gộp:

| Class | Token | Step 1 trên silicon này |
|---|---|---|
| MUTE | V-04 n=0, không NAK | MET một A/B/A sau nạp 2026-09-20 16:49+07 |
| MAG | `0200015a` R_BAD_MAGIC | NOT_MET trên A/B/A và CONTROL2 |

Capture mute không chứng minh MAG. Capture MAG không được suy từ mute.

---

## Bước 1 — Khóa điều kiện thử và tái hiện

Hằng số mỗi lần chạy:

- Bit U33 hash khóa (trên).
- Một host: `aba_dummy_open_20260920.py` (hoặc copy hash-locked).
- Một vector: Pack mem `PA24-V-04`.
- Log mới mỗi run (cấm ghi đè OUT cũ).
- Timeout, purge, bytes, WAIT_AFTER_ACK=0 giữ nguyên.
- Ghi CLEAR/retry/reopen đầy đủ.
- Không tự nạp lại giữa A1 / B / A2.
- Sau JTAG: kill `hw_server`/`cs_server` rồi mới mở COM.

Biến duy nhất: preliminary COM open–close.

| Arm | Preliminary open–close |
|---|---|
| A | dummy-open MARK 2 s → close → 200 ms → real-open MARK 2 s |
| B | bỏ đúng dummy-open/close |
| A | đưa dummy-open trở lại |

Điều kiện chuyển bước: có trình tự tái hiện mute **hoặc** MAG trên biến đó.  
Nếu lỗi không đi theo open–close: đổi **một** biến tiếp (purge rồi timeout). Không đổi nhiều biến cùng lúc.

### Điểm hiện tại — FACT

Nguồn: `U33_ABA_DUMMYOPEN_20260920_POSTPROG/ABA.json` sha256 `01e2cd64…d6322d08`. Program `U33_OWNER_PROGRAM_20260920_ABA` DONE=1 CRC=0.

| Arm | dummy | CLEAR | V-04 |
|---|---|---|---|
| A1 | yes | n=0 rồi reopen ACK | mute n=0 / 12 s |
| B | no | ACK | GOLD `010000a5` |
| A2 | yes | ACK (không reopen) | mute n=0 / 12 s |

Trình tự kích hoạt ngắn nhất cho **MUTE**: nạp U33 → kill hw_server → dummy-open → CLEAR (ACK hoặc reopen-ACK) → TX V-04 208 B → n=0.  
Control: bỏ dummy → GOLD.  
A/B/A trước nạp (CLEAR n=0 / `6e6f00`) **không** đếm.

MAG lịch sử: chưa có trình tự A/B/A. CONTROL2 24 V-04 GOLD trên host không dummy. Không tuyên bố MAG đã chết.

Bước 1 MUTE: **PASS_BOARD một A/B/A**. Bước 1 MAG: **OPEN**.

Xếp hạng giả thuyết owner: [HYPOTHESIS_RANK_20260920.md](HYPOTHESIS_RANK_20260920.md).  
Hạng 1 (open/close kích hoạt UART/CLEAR) là giả thuyết **ưu tiên**. A/B/A đã xác nhận dummy-open là trigger MUTE, chưa khoanh FTDI vs RTL, chưa đụng MAG. Không kết luận “Python sai”.

---

## Bước 2 — Bắt transaction lỗi tại ranh giới

Cần **diagnostic identity riêng**: chỉ quan sát, logic chức năng U33 giữ nguyên, bản gốc U33 không overwrite.

| Điểm đo | Phải ghi | U33TAP `d448544f…` |
|---|---|---|
| Chân UART RX | Bytes tới FPGA, timing, framing | KHÔNG |
| UART decoder | Word, valid/ready, framing error | KHÔNG |
| FIFO | Write/pop thật, data, pointers, flush | KHÔNG |
| Steering | pack_lock, forward/drop | KHÔNG |
| CDC | Source/sink accept, data, req/ack, reset hai phía | KHÔNG |
| Loader | Accepted data, state, rx_words, hw0, reject | MỘT PHẦN: 8 beat `p_fire`, đóng băng lúc NAK |

U33TAP **không** đủ bước 2:

- Dump UART **sau NAK** → class MUTE (n=0, không NAK) sẽ không dump.
- GOLD re-arm; không phải circular log xuyên CLEAR.
- Không pin-level; không FIFO/steer/CDC.
- TX mux TAP đã từng đụng TX CDC trên silicon path.

Recorder đạt chuẩn:

1. Giữ dữ liệu qua CLEAR.
2. Không thêm wait-state / back-pressure lên DUT.
3. Không mất event khi nhiều hop cùng chu kỳ (mỗi hop một slot, không overwrite).
4. Cửa sổ: **trước CLEAR** đến **header lỗi** (mute: hết cửa sổ V-04; MAG: inclusive NAK), không chỉ P0/P1 sau khi đã thấy NAK.

STOP: không nạp U33TAP, không build identity mới, cho đến YES chủ identity quan sát.

Nếu identity quan sát **không** tái hiện mute (dummy-open) hoặc MAG (khi có trigger): ghi `INSTRUMENTATION_PERTURB`. Không tuyên bố U33 sạch.

---

## Bước 3 — First divergent hop

| Quan sát | Khoanh |
|---|---|
| Host buffer đúng, bytes tại chân FPGA sai | Host/driver/FTDI/đường truyền |
| Bytes chân đúng, decoded word sai | UART RX/framing |
| FIFO ghi đúng, pop sai hoặc thiếu | FIFO/flush |
| FIFO pop nhưng CDC không nhận ngoài discard hợp lệ | Steering/handshake |
| CDC nhận một lần, phát hai lần | CDC/reset replay |
| Loader nhận đúng BEGIN→MAGIC nhưng hw0/state sai | Loader/reset hoặc triển khai vật lý |

Tiêu chí: hop trước còn đúng, hop sau bắt đầu sai.  
Không đóng root cause vì một giả thuyết XSim tạo cùng token MAG.

---

## Bước 4 — Đóng nguyên nhân rồi mới sửa

Root cause chỉ đóng khi đủ năm mục:

1. Capture transaction lỗi chỉ ra first divergent hop.
2. Tái tạo cơ chế đó trong test cô lập.
3. Bỏ đúng điều kiện gây lỗi → lỗi mất; đưa lại → lỗi quay lại.
4. Bản sửa hẹp vượt trình tự gây lỗi **và** negative controls.
5. **Sau đó** mới chạy lại gate Pack/ABI đầy đủ.

Sửa hẹp = identity mới, không overlay U33/H. Frozen U33 giữ làm đối chứng.

1 GOLD hoặc 24 V-04 cùng case **không** phải PACK_ABI_24_24_PASS.

---

## Lựa chọn owner (khóa)

A/B/A host trước → dùng đúng trình tự đó cho capture nội bộ.  
Identity quan sát không tái hiện lỗi → kiểm tra instrumentation, không tuyên bố U33 sạch.  
Capture = phê duyệt identity mới. Quyền nạp U33 hiện tại không gồm bước đó.

## Next (chỉ sau YES)

Owner YES identity quan sát cho **MUTE trigger** (dummy-open) và/hoặc chờ MAG trigger riêng.  
Optional trước đó: một biến DTR/RTS vs close, không đổi timeout/purge.  
Không Pack24 mù. Không patch loader. FEM persist vẫn blocked.
