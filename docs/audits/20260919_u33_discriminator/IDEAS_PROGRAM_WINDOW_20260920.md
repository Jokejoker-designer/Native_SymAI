# Đống ý — PROGRAM độc quyền tới 12h đêm 20/21-09-2026

Không stamp `PACK_ABI_24_24_PASS`. Không overlay H/U33/freeze. MUTE ≠ MAG. Host = trigger, không kết luận “Python sai”.

SRAM hiện tại: U33TAP CDC `eb99ac69…` (TAP CDC XDC trong impl). Cũ `d448544f…` giữ trên disk. DUMP leftover DUP4 giờ khớp XSim CLASS_A p0=p1=BEGIN. Not U33. Not PACK_ABI.

## Ý 1 — TAP dump p1 trên bit cũ không tin được

FACT bit `d448544f`: silicon MAG TAP1 + p0=BEGIN; p3/meta khớp XSim; p1=`414e0080`.  
FACT bit TAPCDC `eb99ac69`: leftover DUP4 dump p0=p1=BEGIN p2=MAGIC = XSim CLASS_A.  
Dump cũ sai vì TAP CDC không vào netlist nạp. Dump TAPCDC leftover tin được cho class A.

## Ý 2 — Leftover MAG class A trên loader (XSim, không TAP UART)

FACT `PASS_XSIM`: leftover BEGIN + V-04 → MAG `0200015a`; hop_log `p_fire` p0=BEGIN p1=BEGIN; first_divergent = p1 (BEGIN thứ hai).  
Starter 41-bit logger **không** phải U33OBS 7-lane. Không nạp logger này.

## Ý 3 — Rebuild TAP CDC rồi nạp — MET recapture

FACT: bit `eb99ac69…` WNS +0.355 WHS +0.027 MET trên DCP (không TIMING_PASS). PROGRAM End of startup HIGH. CELL_DUP4 MAG TAP CLASS_A p0=BEGIN p1=BEGIN p2=MAGIC. Dump cũ `414e0080` là TAP CDC unconstrained. Không Pack24 trên TAP.

## Ý 4 — MUTE dummy-open

FACT một A/B/A trên U33: dummy → mute; không dummy → GOLD. TAP identity **không** tái hiện mute (`INSTRUMENTATION_PERTURB` cho MUTE).  
U33TAP dump-sau-NAK không bắt MUTE (không NAK).  
Sau Ý 3: nạp lại U33 `ff399e0b` (không overlay) rồi dummy-open trên U33OBS khi identity sẵn, không trên TAP.

## Ý 5 — U33OBS 7-lane (hợp đồng đóng băng)

READY_TO_BUILD=YES. Query UART vẫn tied-off. Dump không cần NAK. CLEAR không wipe. Overflow = run invalid.  
Không nạp starter `{mask,data}`. Không smash pack TX CDC.

`generation_flipped` **không** phải `snap_a != snap_b` nếu giữa hai mẫu có reset/CLEAR/đổi epoch. Owner lock:

```text
generation_flipped = true  iff
  commit_event == 1
  AND generation_after != generation_before
  AND same_capture_epoch
  AND capture_valid == 1
```

`false` chỉ khi COMMIT quan sát được, cùng epoch, capture_valid, và generation không đổi. Thiếu bất kỳ điều kiện → field absent, `compare_ready=false`.

## Ý 6 — MAG lịch sử không leftover-inject

Leftover BEGIN **đủ** MAG (XSim + TAPCDC silicon p0=p1=BEGIN). MAG không inject vẫn OPEN.  
DUT.jsonl cho MAG/ACK không được gắn `generation_flipped` từ UART hay từ hai snapshot xuyên CLEAR. Cùng luật Ý 5: chỉ Pack-owner COMMIT + same_capture_epoch + capture_valid.

## Ý 7 — Pack/ABI gate

Chỉ sau bước 4 (hop + on/off + sửa hẹp). Frozen identity, `--compare DUT.jsonl` 24 case, run1/run2/fresh.  
24 V-04 GOLD ≠ PACK_ABI. `--selfcheck` / XSim DUT ≠ stamp. R-04/G-04 cần query identity riêng.

## Ý 8 — Cấm trong cửa sổ này

AXI UART; overlay dest_accept; pad/resync H; FE256 polish; C RTL; SPAWN_X16; WAIT_AFTER_ACK≠0 như “fix”; copy TSV `generation_flipped`; Pack24 mù trên TAP; E nạp board.

## Thứ tự tới 00:00

1. TAPCDC rebuild + nạp + DUP4 — MET CLASS_A p1=BEGIN  
2. Bảng first-divergent leftover MAG — MET dump TAPCDC = XSim  
3. U33OBS 7-lane cho MUTE; `generation_flipped` theo GENERATION_FLIPPED_LAW  
4. Không Pack24 đêm nay trừ khi Ý 7 đủ — hiện **không đủ**
