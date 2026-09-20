# Xếp hạng giả thuyết — MUTE vs MAG — 2026-09-20

OWNER: Anh (bảng gốc) + overlay FACT sau A/B/A  
BIT: U33 `ff399e0b…338a350`  
PACK_ABI_24_24_PASS=NO  PROGRAM_PASS=NO  overlay=NO

Giả thuyết mạnh nhất **để kiểm tra trước** (khóa):

> Host mở/đóng cổng kích hoạt lỗi nhạy trạng thái trong transport UART/CLEAR của U33.

Đây **không** phải kết luận “Python sai”. Host là tác nhân kích hoạt. FTDI và RTL đều còn mở cho đến first-divergent hop.

**MUTE vừa tái hiện ≠ MAG lịch sử.** Có thể cùng nguồn hoặc hai lỗi. Không gộp.

## Overlay A/B/A lên hạng 1

Phép thử hạng 1 (“A/B/A chỉ bỏ preliminary open–close”) **đã chạy** sau nạp U33 16:47+07.

Nguồn: `U33_ABA_DUMMYOPEN_20260920_POSTPROG/ABA.json` sha256 `01e2cd64…`. CONTROL2: host mới GOLD → host cũ mute → host mới GOLD không nạp lại.

| Class | Hạng 1 sau A/B/A |
|---|---|
| MUTE V-04 n=0 | **Đi theo dummy-open** trên một A/B/A: A1 mute, B GOLD, A2 mute. CLEAR ACK không cần dummy (A2). |
| MAG `0200015a` | **Không tái hiện.** CONTROL2 24 V-04 GOLD trên host không dummy. Trigger MAG vẫn OPEN. |

Ô “chưa cô lập biến mở cổng” **hết hạn cho MUTE**. Còn hạn cho MAG, và cho FTDI vs RTL (cùng biến dummy-open).

---

## Bảng xếp hạng (khóa)

| Hạng | Giả thuyết | MUTE | MAG | Phép thử còn lại |
|---|---|---|---|---|
| **1** | Open/close COM tạo byte/mức ngoài dự kiến; UART/CLEAR không hết trạng thái | **Ủng hộ mạnh** (dummy-open đủ mute). Chưa tách DTR/RTS vs close vs MARK vs FTDI vs RTL | **Chưa test.** Mute không suy thành MAG | Capture chân RX + decoder trên đúng dummy-open. Optional: một biến DTR/RTS trước identity mới |
| **2** | Sai lệch byte/word tại RX làm mất/biến dạng MAGIC | UNKNOWN trên board mute (không NAK, không hw0) | PASS_XSIM: một BEGIN + gap MAGIC → `hw0=01314941` MAG (`discriminator/README.md`). **Chưa waveform board** | TX tại chân vs word decoder; sai trước hay sau UART RX |
| **3** | CLEAR ACK ≠ toàn bộ ingress sạch | A2 ACK rồi vẫn mute V-04 → ACK không chứng minh RX sẵn sàng hop sau | P1/P2 n=0 ≠ parser rỗng. XSim CLEAR thử đều sạch | Capture reset/flush/accepted beats từ trước CLEAR đến payload đầu |
| **4** | FIFO pop nhưng không sang CDC ở CLEAR/steer | Đường discard trong code là FACT; chưa chứng minh mất MAGIC/mute sau ACK | UNKNOWN | FIFO pop vs CDC source accept; discard chủ ý vs mất giao dịch mới |
| **5** | CDC replay do reset hai miền lệch | Yếu. XSim thường không replay | Yếu | Một source accept, hai sink accept + lịch sử reset |

Hai giả thuyết **rất yếu** (giữ):

- **MIG luôn hỏng commit thứ năm:** CONTRADICTED bởi CONTROL2 24 V-04 GOLD.
- **Directory/posting gây BAD_MAGIC:** không nhân quả; BAD_MAGIC ở nhận header, trước REGION/query.

---

## Phân loại claim

| Claim | Loại |
|---|---|
| Dummy-open đủ để mute hop-1 V-04 trên A/B/A này | FACT / PASS_BOARD một run |
| Host mới GOLD, host cũ mute, host mới GOLD không nạp | FACT CONTROL2 |
| Nguyên nhân là Python / pyserial bug | **KHÔNG** — chưa có first hop |
| Nguyên nhân là bug RTL UART/CLEAR | HYPOTHESIS — host có thể chỉ kích hoạt |
| Mute và MAG cùng root | UNKNOWN |
| Gap MAGIC `01314941` trên board | UNKNOWN (PASS_XSIM only) |
| 5th MIG commit / directory → MAG | CONTRADICTED / no causal path |

## Next (không tự chạy)

1. **Không** lặp A/B/A dummy-open trừ khi nghi ngờ run 16:49.  
2. Rẻ, chưa identity mới: tách **một** biến DTR/RTS vs close — chỉ nếu owner muốn khoanh FTDI trước capture.  
3. Đúng luật 4 bước: capture identity mới trên **đúng** dummy-open MUTE; cửa sổ trước CLEAR → hết V-04 câm. U33TAP dump-sau-NAK **không** đủ (mute không NAK).  
4. MAG: chờ trigger riêng; không dùng mute capture để đóng MAG.  
5. Không patch loader/MIG. Không Pack24 mù. Không stamp PACK_ABI.

Quyền nạp U33 hiện tại **không** gồm bước 2.
