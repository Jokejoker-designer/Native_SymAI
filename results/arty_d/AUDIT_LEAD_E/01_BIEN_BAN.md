# BIÊN BẢN BÀN GIAO — D-PACK-VALIDATION-RESET-01

Người lập: AGENT_D  
Thời điểm bàn giao: 2026-09-17T05:10+07:00 (UTC 2026-09-16T22:10)  
Người nhận phân tích: AGENT_E (Audit lead - E)  
Folder copy nguyên trạng: `D:\FPGA\arty_d\AUDIT_LEAD_E\`  
Loại văn bản: nhật ký công việc + phạm vi + lệnh + kết quả đo. Không phải kết luận PASS. Không phải kiến trúc mới.

Phân loại trong biên bản: `FACT` = lệnh/file/log đã ghi. `GHI NHẬN D` = câu AGENT_D đã ghi trong JSON/session (không phải kết luận E). `UNKNOWN` = chưa đo.

---

## 0. Phạm vi dự án (đúng lúc bàn giao)

### 0.1 Việc này là gì

TASK: `D-PACK-VALIDATION-RESET-01`  
CLASS: `PACK_VALIDATION_CLEAR_CANDIDATE`  
Mục tiêu owner: FPGA Arty A7-100T testable với Pack `VALIDATION_CLEAR` — reset Pack về trạng thái tương đương case mới **không reprogram**. `PROGRAM=YES` là mục tiêu dự án. Bit CLEAR là **identity candidate mới**, không đè bit lịch sử M4+mig.

CLEAR contract đã khóa trong RTL comment `pack_debug_clear.sv`:

- Lệnh host UART 32-bit LE: `CLEAR_REQ = 32'h44524743`
- Trả lời: ACK `32'hC1EA50A5`, BUSY `32'hC1EA50B5`, ERR `32'hC1EA50E5`
- Reset: loader FSM / txn / slot / CRC / counters
- Không reset dest BRAM/DDR payload
- Không reset generated `mig0`
- Destructive clear chỉ khi quiescent
- Controller `pack_debug_clear` reset bởi `rst_n` hệ, không bởi `debug_clear`

### 0.2 Việc này không phải

Không stamp: `PACK_ABI_24_24_PASS`, `PACK_VALIDATION_CLEAR_PASS`, `BOARD_PASS`, `TIMING_PASS`, `MIG_PASS`, `PROGRAM_PASS`, `FE256_PASS`, `ASTRA_PASS`, `M2_PASS`, `M3_PASS`, `FINAL_PASS`.

Không: FEM persist media/recovery (bị chặn đến khi Pack board classified cho B).  
Không: FE256 feature / sửa case B / QueryRecord / StructuredResult.  
Không: sửa synthesizable RTL C.  
Không: rewrite C memory để ép BRAM.  
Không: đè freeze DCP.

### 0.3 Kiến trúc runtime liên quan Pack board

Luồng host (FACT, code `uart_pack24_clear_board.py`):

1. COM FTDI `…776EB`, 115200 8N1, DTR/RTS false  
2. Drain RX  
3. Gửi 1 word CLEAR  
4. Đọc raw, tìm token ACK/BUSY/ERR (retry 3 × `read_raw` 2.0s)  
5. Nếu ACK: burst `send_words` toàn bộ `{case}.mem`  
6. Đọc 4 byte LE status Pack  
7. So với TSV B: ACK `0x01rr00A5` / NAK `0x02rr005A`

Luồng DUT (FACT, top `arty_a7_r2_top_m4_mig_candidate.sv` tại snapshot):

`uart_rx` → mailbox 32b → `pack_debug_clear` sniff CLEAR trên mailbox **trước** FIFO → `word_fifo32` DEPTH=128 → steer: `uart_fe256_host` nếu `[15:0]==0x4E51` và `!pack_lock`, else `word_cdc32` clk100→ui_clk → `pack_mig_bind` → `mig_ui32` → `mig_ui_mux` vs FEM → generated `mig0`.

Status: `pack_loader` ack/nak trên ui_clk → `word_cdc32` tx ui→100 → mux với CLEAR ack và `uart_fe256_host` tx → `uart_tx_word`.

Pack gold: `CANON_BLUEPRINT/verification/pack_abi24/out/pack_abi24_expect.tsv` — 24 case `PA24-V/S/A/C/R/G-01..04`. B owns TSV. D không sửa TSV.

ISO baseline (reprogram mỗi case, bit lịch sử `f6a6091f…`): `D:\FPGA\arty_d\m4_mig\UART_PACK24_ISO_BOARD.jsonl` — 14/24. Metric `CLEAR_EQ_REPROGRAM` so `got` round0 PACK với ISO `got`, **tách** `GOLD_MATCH`.

### 0.4 Ràng buộc còn hiệu lực (copy từ AGENTS.md workspace)

- AGENT_C MODE=ON_DEMAND, PRIMARY_QUEUE=CLOSED. C RTL chỉ `qstar_select.v` SHA256 `d4f64e65ccf93f294786e628be0410fcbd1ff97888a402ed34445c1324bf7240`, `spear_rank.v` `11e71b50f64822ee7d53ab466039fc1883fa6f01c518e7aa8278ed16a3c76293`, `fem_lifecycle.v` `45b9b93073e3e08a2525a3fc1a96573d750bedcd26570cebefba5fa9514779ed`. Snapshot copy read-only khớp 3 hash này (đo 2026-09-16T22:10Z).
- C_SCALE_GUARD: HALT nếu integration ép Q* theta>64, actions>8, features>8, K_HARD_MAX>9, FEM N_RAW tăng vật chất.
- FE256_R1_REFERENCE_FREEZE = reference, không product. `FE256_DEVELOPMENT=CLOSED`.
- Owner PROGRAM=YES 2026-09-17 cho bit M4+mig lịch sử `f6a6091f…` (UART hop-1 StructuredResult). D không tự stamp PROGRAM_PASS.
- NEXT_MAIN_D_TASK=FEM persist **sau** Pack classified to B.
- LUTAR-1: LUT không được drive async CLR (glitch reset). D-owned paths đã chuyển FF combiner. LUTAR-1 còn 1: generated `mig0` `rstdiv2_sync_r` — D không sửa.

### 0.5 Phần cứng / tool

| Hạng mục | Giá trị |
|---|---|
| Vivado | 2026.1 SW Build 6511674 |
| License | BASIC, log “valid … expire 13-aug-2027” |
| Synth/impl | `vivado -mode batch -notrace -source 29/30/31/32_*.tcl` |
| XSim | `xvlog`/`xelab`/`xsim` qua `run_xsim_uart.bat` / `run_xsim_word.bat` |
| Python host | `C:\Users\phant\AppData\Local\Programs\Python\Python311\python.exe` |
| JTAG | `localhost:3121/xilinx_tcf/Digilent/210319BE776EA` `xc7a100t_0` |
| UART | FTDI `210319BE776EB` (script `find_port` theo serial suffix) |

Tcl synth đọc RTL từ `CANON_BLUEPRINT\rtl\native_ai\`, top `arty_a7_r2_top_m4_mig_candidate`, IP `D:/FPGA/miggen/p/mig0.srcs/sources_1/ip/mig0/mig0.xci`. Output `D:/FPGA/arty_d/m4_mig_clear\` (`post_synth.dcp`, `post_route_clear.dcp`, `arty_a7_r2_top_m4_mig_validation_clear.bit`). Không ghi `D:/FPGA/arty_d/m4_mig/post_route.dcp`.

---

## 1. Live RTL tại bàn giao (khớp bit đang program)

Bit đang program: `D:\FPGA\arty_d\m4_mig_clear\arty_a7_r2_top_m4_mig_validation_clear.bit`  
SHA256 FACT: `bbba86c10a40f502611e18d98fbdcd0565238f28f891fa8747e6a0aa29b23dd0`  
DCP: `post_route_clear.dcp` SHA256 `33310a4455127e51f88c5b8fa5a05620a36ab0de6ad5be9d26bfac3609811b25`  
`32_program_m4_mig_clear.tcl` `want_sha` = đúng hash trên.  
Labtools: `End of startup status: HIGH` (log `vivado_prog.log` / terminal 965695).  
`PROGRAM.DONE=NA` `IR.STATUS=NA` như các lần trước.  
`PROGRAM.txt` STATUS=PROGRAMMED, `PROGRAM_PASS=NO`.

SHA256 file live (cũng trong `SHA256MANIFEST.json`):

| File | SHA256 |
|---|---|
| `arty_a7_r2_top_m4_mig_candidate.sv` | `35c49b2ceb4995c5cca3328e5b42c9b8121ae6c82b6e4813c173c4e843789ef3` |
| `uart_rx_word.sv` | `638f9719732f971828205c43b9894cc2b93529fb6e1e39ab90f6970ca0790823` |
| `uart_tx_word.sv` | `805344670271169ea3312c175d123eacbc7b9be8d2436b0171baf82d7b076e33` |
| `word_fifo32.sv` | `e8d73a3ac97b8c7c4593f04c20291ca39306857988d70eb438def21b52816dd0` |
| `pack_debug_clear.sv` | `77e3dc26cebacbc2e975fb8748635b7c364263f3f52a5f31538ac7e49fd752ec` |
| `pack_mig_bind.sv` | `581777cfcbcd1cdf71d3c5f383ec8b93fa2e41281d9c3ef554738a916d1f060f` |
| `tb_pack_debug_clear.sv` | `728ff7c7c3fee04f9d07915aa469673a8ea45f8661df2a43dffcbe80fdedb8e8` |
| `uart_pack24_clear_board.py` | `5bbdad67829a7c4bb98eb00112d64e8ade72bd27de9926e7272695f4bba6bcd8` |

Route bit `bbba86c1` (reports copy trong snapshot):

- WNS +0.608 ns, WHS +0.008 ns, WPWS +0.187 ns  
- “All user specified timing constraints are met.”  
- LUT 10926, FF 9855, RAMB36=4, RAMB18=2, DSP 8  
- nets 19108/19108, routing errors 0  
- LUTAR-1 count 1: `u_mig/u_mig0_mig/u_iodelay_ctrl/rstdiv2_sync_r[11]_i_1` → PRE `rstdiv0_sync_r1_reg_rep*`  
- TIMING_PASS: không stamp

---

## 2. Việc AGENT_D đã làm (theo identity bit)

Mỗi identity là bitstream khác. Không trộn số liệu.

### 2.1 Bit lịch sử M4+mig (không phải CLEAR top)

- File: `D:\FPGA\arty_d\m4_mig\arty_a7_r2_top_m4_mig_candidate.bit`  
- SHA256: `f6a6091fccab5bdb331932195d34c984f3101cdf52d3959c172706b33ba368d7`  
- Owner PROGRAM=YES 2026-09-17. UART hop-1: StructuredResult magic `0x4E52` status `0x04` reason `0x20` completeness `0x02`.  
- ISO 14/24 và SEQ 2/24 đo trên **bit này**, không phải CLEAR bit. Log: `D:\FPGA\arty_d\m4_mig\UART_PACK24_ISO_BOARD.jsonl`.

ISO raw (FACT, mailbox D→B 20260916T183909 và jsonl):

```
PA24-V-01 010000a5 OK
PA24-V-02 0200015a FAIL
PA24-V-03 0200015a FAIL
PA24-V-04 0200075a FAIL
PA24-S-01 0200015a FAIL
PA24-S-02 0200035a OK
PA24-S-03 0200035a OK
PA24-S-04 0200015a FAIL
PA24-A-01 0200025a OK
PA24-A-02 0200015a OK
PA24-A-03 0200095a OK
PA24-A-04 02000f5a OK
PA24-C-01 0200015a FAIL
PA24-C-02 02000d5a OK
PA24-C-03 02000d5a OK
PA24-C-04 02000d5a OK
PA24-R-01 0200055a OK
PA24-R-02 0200015a FAIL
PA24-R-03 0200015a FAIL
PA24-R-04 0200075a FAIL
PA24-G-01 010000a5 OK
PA24-G-02 0200015a FAIL
PA24-G-03 0200075a OK
PA24-G-04 0200055a OK
```

SEQ (cùng bit, không CLEAR, 1 program): pass=2 fail=22; V-03 `0200085a`; V-04 trở đi nhiều `got=None` dt≈12s; R-04 `06014e52`.

### 2.2 CLEAR candidate — việc RTL đã đưa vào live (snapshot = trạng thái cuối)

FACT các thay đổi D-owned (không đụng 3 file C):

1. `pack_debug_clear.sv`  
   - `ui_req`, `cdc_rst_100`, `uart_flush` qua FF (`ui_req_r`, `cdc_rst_r`, `flush_r`).  
   - `DIRECT_RESET` trên `cdc_rst_r`.  
   - SAMPLE_N=8, CDC_N=4, QUIET_N=20000, TO_N=65535.  
   - S_QUIET: ACK khi `uart_rx_mark && cnt==QUIET_N-1` hoặc `wall==TO_N`.  
   - S_ACK / S_BUSY / S_ERR: thoát khi `ack_ready` hoặc `cnt==TO_N`.  
   - S_DROP / S_DROP_B: IDLE khi `!ui_ack && !ui_nack` hoặc `cnt==TO_N`.  
   - BUSY: không CDC rst, không flush UART.  
   - `take` chỉ `S_IDLE && in_valid && in_data==CMD`.

2. `uart_rx_word.sv`  
   - Port `flush` default 0. Flush → IDLE, `w_valid=0`, `bix=0`.  
   - Idle không gated bởi flush trên `assign idle`.  
   - STOP: hết stop → IDLE luôn; nếu `bix==3` và `(!w_valid || w_ready)` thì phát word, không thì bỏ word (không kẹt STOP).  
   - Nhánh `if (!rx_d)` lúc hết STOP (drop byte, `bix=0`) **đã đưa vào bit `097c7795` rồi revert** trước bit `bbba86c1`. Live snapshot **không** còn nhánh đó.

3. `uart_tx_word.sv`  
   - Port `flush` default 0. `else if (flush)`: IDLE, `tx=1`, `w_ready=1`.  
   - Instance khác (query/FE256/r2_top freeze) không nối flush → default 0. Freeze top không sửa.

4. `word_fifo32.sv` (file mới)  
   - DEPTH=128 LUTRAM, flush, `wr_ready` khi `!full && !flush`.

5. `arty_a7_r2_top_m4_mig_candidate.sv`  
   - FIFO giữa uart_rx và steer.  
   - `wr_valid = w_valid && !clr_take`.  
   - `w_ready = clr_take || !clr_hold` (không stall theo `fifo_wr_ready`).  
   - `pack_lock` SET khi `f_valid && f_ready && !q_taking && pack_op` với `pack_op=(f_data[7:0]==8'h01)` (BEGIN only). CLEAR khi `uart_flush || cdc_rst_100` hoặc `st_valid_100 && st_ready_100`.  
   - `qhost.in_valid = f_valid && !clr_take && !clr_hold && !pack_lock`.  
   - `qsc_100 = qsc_c1 && cdc_a_idle && tx_b_idle && !st_valid_100 && !uart_tx_valid` (không gồm `fifo_empty`/`pack_lock`).  
   - `clr_ack_ready = mux_ready && !uart_flush`.  
   - `u_tx.flush = uart_flush`.  
   - `uart_rx.idle` nối `rx_idle` → `pack_debug_clear.uart_rx_mark`.  
   - `rst100_pack_n` / `rst_ui_pack_n` FF combiner.

6. `pack_mig_bind.sv`  
   - `rst_loc` FF: async `rst_n`, else `rst_loc <= ~debug_clear`. Không rewrite C BRAM.

7. Host `uart_pack24_clear_board.py`  
   - `drain_until_idle`, `find_token` ACK/BUSY/ERR, `do_clear` 3 retry, `read_raw` 2.0s.  
   - Open: sleep 8s + drain.  
   - `compare_iso` trên PACK round 0.

8. TB `tb_pack_debug_clear.sv`  
   - FIFO + qhost + T9 R-04. `qsc` công thức gốc. Không gán `calib_ui` (output của `mig_ui_bram`).

9. `29_synth_m4_mig_clear.tcl` thêm `word_fifo32.sv`.

### 2.3 Lệnh chạy (lặp lại mỗi identity)

PowerShell không dùng `if not exist` cmd và không dùng `&`.

Synth:

```
cmd /c "call C:\2026.1\Vivado\settings64.bat && vivado -mode batch -notrace -source D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\vivado\tcl\29_synth_m4_mig_clear.tcl -log D:\FPGA\arty_d\m4_mig_clear\vivado_synth.log -journal D:\FPGA\arty_d\m4_mig_clear\vivado_synth.jou"
```

Impl: `30_impl_m4_mig_clear.tcl` → `vivado_impl.log`  
Bit: `31_bit_m4_mig_clear.tcl` → `vivado_bit.log`  
Hash: `certutil -hashfile <bit> SHA256`  
Sửa `want_sha` trong `32_program_m4_mig_clear.tcl`  
Program: `32_program_m4_mig_clear.tcl`  
Campaign:

```
C:\Users\phant\AppData\Local\Programs\Python\Python311\python.exe D:\FPGA\arty_d\m4_mig\uart_pack24_clear_board.py --mode clear --rounds 2
```

XSim UART: `cmd /c D:\FPGA\arty_d\pack_debug_clear\run_xsim_uart.bat`  
XSim word: `cmd /c D:\FPGA\arty_d\pack_debug_clear\run_xsim_word.bat`

### 2.4 XSim (simulation only)

Word `tb_pack_abi24_clear` (mig_ui_bram, không uart, không mig0):

```
PACK_ABI24_CLEAR_XSIM_PASS T1-T8+round0 24/24
round1=23/24  (V-03 ack=0/1 rej=1/0 reason=08/00 cả round1)
seq_no_clear pass=2 fail=22
finish 10673555 ns
```

Banner TB: `NOTE round1/seq dest payload persists; SENTINEL is dest-assumption evidence, not gold edit`

UART `tb_pack_debug_clear` (BAUD=1_000_000, FIFO, qhost, T9 R-04), lần cuối sau revert framing:

```
PACK_DEBUG_CLEAR_UART_XSIM_PASS 15
finish 15781665 ns
MATCH: CLEAR ACK, V-01 010000a5, STALE 02000e5a, CLEAR, V-01, CLEAR×3, 010000a5, CLEAR, T8 no ghost, BUSY c1ea50b5, 010000a5, CLEAR, R-04 010000a5
```

Regression XSim đã quan sát trong session:

- Gắn `flush` TX mà `clr_ack_ready=mux_ready` (không `&& !uart_flush`): `PACK_DEBUG_CLEAR_UART_XSIM_FAIL fail=7 pass=8` — TIMEOUT `exp=c1ea50a5`.  
- Sau `clr_ack_ready = mux_ready && !uart_flush`: PASS 15.  
- `qsc_100` gồm `fifo_empty && pack_lock`: UART FAIL 11 (T2 leftover REGION). Revert qsc → PASS.  
- `calib_ui` assign trong TB vs output `mig_ui_bram`: multiple drivers. Bỏ assign.

### 2.5 Identity CLEAR đã program + campaign board

#### Identity A — FIFO + pack_lock, chưa TX flush

- Bit SHA256: `71061d8407259e3de7106b11ffe2c3f0a3ba0221a03f60b8823c70db2f29d245`  
- Route (ghi nhận D): WNS +0.236 WHS +0.008 LUT 10911 FF 9855 RAMB36=4 RAMB18=2 DSP 8 nets 19113/19113  
- DCP ghi nhận D: `dfbf9aa56813ad3cedbb92b6cf73e44b6842c26bfd8513926e9e00c7d2912438`  
- Campaign r0: pack_ok=17/23 (C-01 CLEAR FAIL). R-04 GOLD `010000a5`. V-03 `0200085a`. r1: 24 CLEAR FAIL `got=None`.  
- CLEAR_VS_ISO eq=14 ne=9/24 (trên pack r0 quan sát được).

#### Identity B — + TX flush + S_ACK timeout + ack_ready gate

- Bit: `f64fc1afebff2c67ef1da8011e1ed5674abefcb3ba9757d4bfc9d08b6421ea03`  
- DCP: `5522abdf068c6a084b9ec8d91d5f0c61466559409f7182ba1fc4cf5d79ea0c6e`  
- Route: WNS +0.599 WHS +0.012 LUT 10924 FF 9855 nets 19114/19114  
- Labtools End of startup HIGH (terminal 965685)  
- Campaign (terminal 965686): pack_ok=19/20. r0 V-01/V-02/V-04 GOLD; V-03 `0200015a`; S-01 CLEAR FAIL None; S-02..G-01 GOLD trừ G-02/G-03/G-04 CLEAR FAIL None; r1 24 CLEAR FAIL None.  
- CLEAR_VS_ISO eq=13 ne=7/24 (chỉ case có PACK r0).  
- Probe hung sau campaign: `port COM12 n 0 hex` (python 1 CLEAR, `read_raw` 3s, 0 byte).

#### Identity C — + RX stop-bit drop nếu `rx_d==0` + `uart_rx_mark=idle` + `w_ready` không FIFO-stall

- Bit: `097c7795205fa1f0d0817b022a5abc812bc0f6c182408dc1ecf3671e675432a1`  
- DCP: `d0818971e8533ee94135e887f36664ea8c35e635f54a6f23692c9483e5ea22c3`  
- Route: WNS +0.598 WHS +0.009 LUT 10929 FF 9855 nets 19110/19110  
- Campaign (terminal 965691): pack_ok=21/31. Nhiều `0200075a`. r1 không chết hết (có PACK GOLD: V-02, S-03, S-04, A-01, A-02, C-01, C-02, R-02, R-04, G-01, G-02, G-03). r1 A-04 PACK `got=None` dt=12.214s. r1 V-03 CLEAR FAIL got=`0200075a` (token không phải ACK).  
- CLEAR_VS_ISO eq=7 ne=7/24 trên subset r0 PACK.

`0200075a` = NAK reason `0x07` (`R_UNSUP` trong `pack_loader.sv`). Opcode byte `[7:0]` của CLEAR_REQ là `0x43`.

#### Identity D — live — revert nhánh framing `!rx_d`, giữ overrun-leave-STOP + idle mark + w_ready không FIFO-stall + TX flush

- Bit: `bbba86c1…` (mục 1)  
- Campaign file: `D:\FPGA\arty_d\m4_mig_clear\UART_PACK24_CLEAR_BOARD.jsonl`  
- pack_ok=2/5  
- r0: V-01 `010000a5` OK; V-02 `0200075a`; V-03 `0200085a`; V-04 `010000a5` OK; S-01 `0200015a`; S-02..G-04 CLEAR `got=null`; r1 24 CLEAR `got=null`.  
- CLEAR_VS_ISO eq=2 ne=3/24  
- `exit_code=1` elapsed_ms=315834

Reason codes Pack (FACT `pack_loader.sv`):

| code | name |
|---|---|
| 0x01 | R_BAD_MAGIC (`hw0 != 32'h3149414E`) |
| 0x07 | R_UNSUP |
| 0x08 | R_SENTINEL (`mem_rdata != rg_first[chk_i]` sau dest readback) |
| 0x0E | R_STALE |

Status word: ACK `8'h01, 8'h00, reason, 8'hA5`; NAK `8'h02, 8'h00, reason, 8'h5A`.

---

## 3. Lỗi / hiện tượng đã gặp (chỉ liệt kê)

1. PowerShell `if not exist` → `Missing '(' after 'if'`. Synth không chạy. Đổi `cmd /c`.  
2. PowerShell `&` → `AmpersandNotAllowed`.  
3. Synth XDC 12-4739 combo CDC `ui_req` — đã register `ui_req_r` / `qsc_ui_r`.  
4. Program SHA mismatch nếu không cập nhật `want_sha`.  
5. LUTAR-1 combo AND vào async CLR CDC/loader — D-owned sửa FF; còn 1 trên mig0.  
6. TB UART FAIL khi `qsc` thêm `fifo_empty && pack_lock`.  
7. TB `calib_ui` multiple drivers.  
8. `pack_lock` mọi opcode 01–04: leftover REGION sau NAK set lock. Đổi BEGIN-only.  
9. Payload `PA24-R-04.mem` chứa word `03014e51` — `uart_fe256_host` QMAGIC `0x4E51`. Board/XSim trước lock: StructuredResult `06014e52` / 48-byte. T9 sau lock: LOAD_OK `010000a5`.  
10. TX leftover: r1 24× CLEAR None trên identity A. Thêm `uart_tx.flush`. XSim FAIL nếu ACK handshake trùng 1 cycle flush. Gate `!uart_flush`.  
11. Identity B: r0 19/20 rồi hang; probe 0 byte.  
12. Identity C: `0200075a` xen kẽ; r1 không câm hoàn toàn.  
13. Identity D: r0 2 PACK OK rồi CLEAR câm từ S-02.  
14. Word XSim round1 V-03 reason 0x08 lặp; seq 2/24. TB ghi dest persist.  
15. `create_project -force` mỗi synth xóa project `m4_mig_clear.xpr` rồi synth lại.  
16. `uart_tx_word` port `idle` unconnected trên host RX trong TB — warning VRFC 10-3645.  
17. `$fscanf` used as task — XSim warning.

### 3.1 Việc đã thử rồi (không lặp nếu không có dữ liệu mới)

- FIFO 128  
- pack_lock BEGIN-only  
- qsc không gồm fifo/lock  
- FF reset pack/CDC  
- QUIET 20000 + wall timeout  
- TX flush + ACK timeout + ack_ready∧¬flush  
- RX flush  
- STOP không hold mailbox  
- stall UART theo FIFO: **bỏ** (w_ready không phụ thuộc fifo_wr_ready)  
- stop-bit==0 drop+reset bix: **thử trên 097c7795, revert**  
- `uart_rx_mark = idle` (không còn `rx_sync`/`rx_d`) trên live  
- Host drain/settle/find_token/retry 3  
- Không sửa gold TSV, không xóa dest trong CLEAR, không touch mig0, không sửa C RTL

---

## 4. Câu hỏi packing (ghi nhận, không kết luận E)

Owner hỏi: packing kí ức có sai không.

FACT dùng được:

- Cùng `.mem` gold: XSim word round0 24/24.  
- Board identity B: V-01, V-02, V-04, R-04, G-01 GOLD khi CLEAR ACK và UART giao đủ word.  
- `PA24-V-03.mem` word sau BEGIN: `3149414e`. XSim round0 V-03 PASS. Board identity D r0 V-03 `0200085a` (R_SENTINEL), identity B r0 V-03 `0200015a`.  
- FEM W0/W1/CRCW không kích (`ing_valid=0`).  
- `mig_ui32`: lane `addr[3:2]`, mask 4 byte trong beat 128b; SENTINEL so `mem_rdata` vs `rg_first` (word đầu region đã ghi).

E phân tích tiếp. D không stamp packing đúng/sai.

---

## 5. Việc D chưa làm / để trống

- Campaign SEQ trên CLEAR bit live  
- Campaign paced vs burst trên live `bbba86c1` (`uart_clear_diag.py` có trong snapshot)  
- Mailbox B classify Pack CLEAR (chưa gửi classify; ISO/SEQ cũ đã gửi trên bit `f6a6091f`)  
- FEM persist  
- ILA / MARK_DEBUG  
- Sửa `uart_fe256_host` QMAGIC  
- Stop-bit framing checker (đã revert)  
- RTS hardware flow  
- Tăng FIFO >128  
- Break UART / extra 0x00 pad trước CLEAR  
- Phân tích CDC drop/duplicate word trên board

---

## 6. Hướng dẫn AGENT_E chạy

1. Đọc `00_README_AGENT_E.md`.  
2. Làm việc trên `D:\FPGA\arty_d\AUDIT_LEAD_E\` (copy). Không sửa live trừ owner cho implement.  
3. XSim: bat gốc trỏ live CANON_BLUEPRINT; muốn snapshot thì đổi `ROOT` trong copy bat.  
4. Board: `BOARD_LEASE_REQUEST` trước JTAG/COM. Dispatcher `AGENT_E`, file `board_lease.json`.  
5. Output: `E_AUDIT_OUT\` + mailbox. ANALYSIS ONLY.  
6. Không đè `D:\FPGA\arty_d\m4_mig\*.bit` / freeze DCP.  
7. Python mailbox:

```
cd D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\_COORDINATION
python mailbox.py AGENT_E check
```

---

## 7. Đường dẫn evidence

| Mô tả | Path |
|---|---|
| Copy audit | `D:\FPGA\arty_d\AUDIT_LEAD_E\` |
| Manifest SHA | `D:\FPGA\arty_d\AUDIT_LEAD_E\SHA256MANIFEST.json` |
| Live RTL | `CANON_BLUEPRINT\rtl\native_ai\` |
| Live out | `D:\FPGA\arty_d\m4_mig_clear\` |
| Campaign live | `UART_PACK24_CLEAR_BOARD.jsonl` |
| ISO | `D:\FPGA\arty_d\m4_mig\UART_PACK24_ISO_BOARD.jsonl` |
| TSV | `CANON_BLUEPRINT\verification\pack_abi24\out\pack_abi24_expect.tsv` |
| Transcript session | `C:\Users\phant\.cursor\projects\d-FPGA\agent-transcripts\31dc87bc-7c69-45e9-8f38-a233417caeb3` |
| Terminal campaign D | `...\terminals\965696.txt` (bbba86c1), `965691.txt` (097c7795), `965686.txt` (f64fc1af) |
| Goal E | `CANON_BLUEPRINT\_COORDINATION\prompts\GOAL_AGENT_E.md` |
| Reasoning export | `AUDIT_LEAD_E\03_REASONING_EXPORT.md` ; ledger `CANON_BLUEPRINT\_COORDINATION\reasoning\NATIVE_AI_REASONING_EXPERIENCE_V1.md` entry D-PACK-VALIDATION-CLEAR-20260917 |
| Board lease JSON | `CANON_BLUEPRINT\_COORDINATION\board_lease.json` (copy `AUDIT_LEAD_E\board_lease.json`) |

---

## 8. Stamp tại bàn giao

```
PACK_ABI_24_24_PASS=NO
BOARD_PASS=NO
TIMING_PASS=NO
MIG_PASS=NO
PROGRAM_PASS=NO
FE256_PASS=NO
ASTRA_PASS=NO
C_RTL_MODIFIED=false
freeze_dcp_overwritten=false
GUARD_VIOLATION=NO
FEM_PERSIST=NOT_STARTED
AGENT_E_MANDATE=ANALYSIS_ONLY
BOARD_LEASE=FREE
```

---

## 9. OWNER ADDENDUM 2026-09-17T05:50+07:00 (không sửa mục 0–8)

Owner: AGENT_D vẫn cầm trịch. AGENT_E `MANDATE=AUDIT_FULL_EXCEPT_PROGRAM`. Cấm E nạp board. Chi tiết: `04_OWNER_MANDATE_AUDIT_FULL_EXCEPT_PROGRAM.md`.

FACT sau mục 8: handshake identity H on-disk `cf62102f…`; unique copy `arty_a7_r2_top_m4_mig_validation_clear_cf62102f.bit`; SRAM still `bbba86c1` per PROGRAM.txt until D programs. Host `do_clear` default 1 attempt + `find_known` (no first-4 ACK fallback). D BOARD_LEASE_REQUEST still open; D did not JTAG.

---

## 10. AGENT_E wake 20260916T230400Z (append-only; không sửa §0–8)

MANDATE=AUDIT_FULL_EXCEPT_PROGRAM. E không nạp.

FACT hash: live `.bit` path = unique H = `cf62102f…` size 1940501. PROGRAM.txt content still `bbba86c1…` STATUS=PROGRAMMED (file blob sha256 `78e8eed1…`). STALE_FILE vs SRAM. Walk `D:/FPGA/arty_d` `*.bit` = hist `f6a6091f` + two H copies. Identity D `.bit` NONE. Identity D DCP `33310a44` NONE; `post_route_clear.dcp` = `beab0263…`. Live top `382ac125…`. Host `515eba9e…`. C RTL locked hashes MATCH.

FACT XSim (cmd /c):
- `run_xsim_hold.bat` PACK_HOLD_FLOOD_XSIM_PASS 2 HOLD_WR_MAX=0 used=0 finish 240195 ns (06:00:43–06:00:46)
- `run_xsim_uart_115200.bat` PACK_DEBUG_CLEAR_UART_XSIM_PASS 15 finish 126203745 ns (06:01:01–06:01:29)
- `run_xsim_e_rtl.bat` E_RTL_AUDIT_XSIM_PASS 8 finish 7705 ns (06:02:27–06:02:29)

FACT UART: GRANT E program=no. COM12 `210319BE776EB`. `python uart_pack24_clear_board.py --mode probe` → tok=None n=0 hex empty. RELEASE then GRANT D program=yes. H8 REJECTED as mute cause. H5 root UNKNOWN. No PASS.

Evidence: `E_AUDIT_OUT/E_AUDIT_REPORT.md` RUN_ID 20260916T230400Z.
