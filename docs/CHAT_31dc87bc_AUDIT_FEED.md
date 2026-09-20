# Audit feed from chat `31dc87bc-7c69-45e9-8f38-a233417caeb3`

Side chat watches the parent Cursor session and publishes **completed** findings here. Not a PASS stamp.

Last published: 2026-09-20T21:02+07 unique OBS rearm BIT_OK `08c647ee…` then parent PROGRAMMED EOS HIGH; PACK_ABI=NO.

## Parent is doing (2026-09-20 21:02+07)

Unique rearm bit programmed by parent. Silicon `08c647ee…`. This watch does **not** program, does **not** Pack24, and does **not** resume Vivado/bitgen. Do not overlay `08c647ee` / `bd541f95` / `251eafa9` / `71b9198f`.

## New since GitHub `1c9b277`

### 2026-09-20 21:01–21:02+07 — unique rearm BIT_OK then parent PROGRAMMED

`BUILD.txt` **BIT_OK** sha256 `08c647ee850cb513f503448ea91c1461551450a145151f0fe02fb296f8137728` in `build_u33obs_rearm/`. Second impl DCP `16566cd8…` WNS **+0.766** WHS **+0.008** constraints MET. **TIMING_PASS=NO**. Parent `97_program_*_rearm.tcl` End of startup HIGH JTAG `210319BE776EA` `PROGRAM.txt` STATUS=PROGRAMMED **PROGRAM_PASS=NO**. Prior unique bits intact. Bit/DCP not pushed. **PACK_ABI_24_24_PASS=NO.** This watch did not nạp. Docs: `BOARD_20260920_U33OBS_REARM_BIT.md`, `BOARD_20260920_U33OBS_REARM_PROGRAM.md`.

## New since GitHub `f2e15e3`

### 2026-09-20 20:54+07 — unique rearm ROUTE_DONE WNS −1.373

`BUILD.txt` **ROUTE_DONE** TAP_CDC_XDC_AT_IMPL=YES. Post-route WNS **-1.373** (1 endpoint `debug_clear_reg`→`clr100_0_reg`) WHS **+0.010**. **TIMING_PASS=NO**. New bit **NOT_BUILT**. DCP not pushed. Prior unique bits intact. **PACK_ABI_24_24_PASS=NO.** This watch did not nạp. Doc: `BOARD_20260920_U33OBS_REARM_ROUTE.md`.

## New since GitHub `b59873c`

### 2026-09-20 20:44–20:50+07 — TAPDUMP PASS_XSIM CLEAR re-arm + unique SYNTH_DONE

`D_U33OBS_REARM_SYNTH.json`. TAPDUMP **PASS_XSIM** GOLD2 four-AND after CLEAR. `BUILD.txt` **SYNTH_DONE** TAP_CDC=1 U2UI=1 WNS **-1.227** unplaced. Unique dir; old OBS/rgoff/steer files intact. New bit **NOT_BUILT**. DCP not pushed. **PACK_ABI_24_24_PASS=NO.** This watch did not nạp. Doc: `BOARD_20260920_U33OBS_REARM_SYNTH.md`.

## New since GitHub `6d792d3`

### 2026-09-20 20:41+07 — isolated V-01 GOLD then TAP DUMP four-AND before CLEAR

`PACK24_ISO_STEER_PA24-V-01.json` sha256 `64a8e6f2…`. UART **GOLD** `010000a5` (flip not invented). DUMP TAP four-AND **flip=1** `ffffffff→00000001`. Same SHA `bd541f95…` **PROGRAM_PASS=NO**. **PACK_ABI_24_24_PASS=NO.** This watch did not nạp. Doc: `BOARD_20260920_U33OBS_STEER_ISO_V01.md`.

## New since GitHub `5c40d1e`

### 2026-09-20 20:36+07 — steer Pack24 B `--compare` 28 field fails

`COMPARE_PACK24_RUN1_STEER.txt` sha256 `b63a8c6d…`. UART outcome/reason/ack/reject **24/24** gold tokens. `generation_flipped` **24 FAIL** (absent). R-04 query 6/80 FAIL; G-04 query 6/84 FAIL. Printed **compare -4/24** (nfail counts fields). S-01 TAP omitted as prior V-04 COMMIT. **PACK_ABI_24_24_PASS=NO.** This watch did not nạp and did not run `--compare`. Doc: `BOARD_20260920_U33OBS_STEER_PACK24_RUN1_COMPARE.md`.

## New since GitHub `a25fa4b`

### 2026-09-20 20:32+07 — steer Pack24 run1 UART 24 MUTE=0

`PACK24_RUN1_STEER.json` sha256 `97961d2d…`. DUT jsonl `79962e9e…`. 24 cases **MUTE=0**. V-03 **GOLD**. A-03 `0200095a` A-04 `02000f5a` A-02 MAG. `compare_ready=false` B `--compare` **NOT_RUN**. Same SHA `bd541f95…` **PROGRAM_PASS=NO**. **PACK_ABI_24_24_PASS=NO.** This watch did not nạp and did not run Pack24. Doc: `BOARD_20260920_U33OBS_STEER_PACK24_RUN1.md`.

## New since GitHub `206e33e`

### 2026-09-20 20:28–20:30+07 — steer hops leftover MAG + GOLD four-AND + V-04×4

`D_U33OBS_STEER_HOPS.json` sha256 `37b06f4a…`. Leftover **MAG** `0200015a` TAP CLASS_A p0=p1=`00800001` flip **absent**. Isolated GOLD **`010000a5`** TAP four-AND **flip=1** `ffffffff→0000ffff`. V-04×4 **4/4 GOLD** not Pack24. Same SHA `bd541f95…` **PROGRAM_PASS=NO**. **PACK_ABI_24_24_PASS=NO.** This watch did not nạp. Doc: `BOARD_20260920_U33OBS_STEER_HOPS.md`.

## New since GitHub `d18cb92`

### 2026-09-20 20:23–20:24+07 — steer PROGRAM + isolated A-03 NAK9 / A-04 NAK15

`D_U33OBS_STEER_A03_A04.json` sha256 `caeee002…`. PROGRAM SHA MATCH `bd541f95…` EOS HIGH JTAG `210319BE776EA` **PROGRAM_PASS=NO**. Isolated A-03 **`0200095a`** TAP load0=`00840001` load1=NAI1 flip **absent**. Isolated A-04 **`02000f5a`** then DUMP MUTE TAP freeze-once. A-03 MUTE on rgoff **CONTRADICTED_THIS_IDENTITY**. **PACK_ABI_24_24_PASS=NO.** This watch did not nạp. Doc: `BOARD_20260920_U33OBS_STEER_ISO_A03_A04.md`.

## New since GitHub `9f09522`

### 2026-09-20 20:21+07 — unique OBS steer BIT_OK hashes (not programmed)

`D_U33OBS_STEER_BIT.json`. Bit sha256 `bd541f9579dfe0e2…` in `build_u33obs_steer/`. DCP `29c974a1…`. WNS +0.666 WHS +0.012 constraints MET. Old OBS `71b9198f…` and rgoff `251eafa9…` files intact. **PACK_ABI_24_24_PASS=NO.** This watch did not nạp. Doc: `BOARD_20260920_U33OBS_STEER_BIT.md`.

## New since GitHub `7872dd8`

### 2026-09-20 20:10+07 — A-03 UART steer OP_BEGIN PASS_XSIM

`u33obs_a03_steer.log` sha256 `557c467c…`. `got=0200095a` `p0=00840001` `reason=09`. `pack_begin=(f_data[7:0]==8'h01)`. New unique bit **NOT_BUILT**. **PACK_ABI_24_24_PASS=NO.** This watch did not nạp and did not patch RTL. Doc: `BOARD_20260920_U33OBS_A03_STEER_XSIM.md`.

## New since GitHub `cb834ba`

### 2026-09-20 20:06+07 — A-03 MUTE first divergence = UART pack_begin

`D_U33OBS_RGOFF_A03_MUTE.json` sha256 `fc2a6a3e…`. TAP `uart1=00840001` loader empty. Top `pack_begin = (f_data == 32'h00800001)`. Flip absent (four-AND). Steer XSim **NOT_RUN**. **PACK_ABI_24_24_PASS=NO.** This watch did not nạp and did not change RTL. Doc: `BOARD_20260920_U33OBS_RGOFF_A03_STEER.md`.

## New since GitHub `8dd4c5a`

### 2026-09-20 20:02+07 — isolated A-03 MUTE, TAP LOADER_EMPTY

`PACK24_ISO_RGOFF_PA24-A-03.json` sha256 `4a795670…`. UART **MUTE n=0**. DUMP TAP **U33OBS_GEN LOADER_EMPTY** flip **absent** `gen_stat=47000002`. Same bit `251eafa9…` (no new program). **PACK_ABI_24_24_PASS=NO.** This watch did not nạp. Doc: `BOARD_20260920_U33OBS_RGOFF_ISO_A03.md`.

## New since GitHub `0741aa3`

### 2026-09-20 19:56+07 — isolated V-03 GOLD on rg_off silicon

`D_U33OBS_RGOFF_V03_GOLD.json` sha256 `9f34226e…`. PROGRAM SHA MATCH `251eafa9…` EOS HIGH JTAG `210319BE776EA` **PROGRAM_PASS=NO**. Isolated first V-03 **GOLD** `010000a5`. DUMP TAP four-AND `ffffffff→00000003` flip=1 U33OBS_GEN. R_SENTINEL on this identity **CONTRADICTED**. **PACK_ABI_24_24_PASS=NO.** This watch did not nạp. Doc: `BOARD_20260920_U33OBS_RGOFF_ISO_V03.md`.

## New since GitHub `7383a26`

### 2026-09-20 19:54+07 — unique OBS rg_off BIT_OK hashes (not programmed)

`D_U33OBS_RGOFF_BIT.json`. Bit sha256 `251eafa9451cabd8…` in `build_u33obs_rgoff/` (new dir). DCP `c6d75f58…`. WNS +0.834 WHS +0.022 constraints MET. `BUILD.txt` still ROUTE_DONE; `bit.log` BIT_OK. Old OBS file `71b9198f…` intact. **PACK_ABI_24_24_PASS=NO.** This watch did not nạp. Doc: `BOARD_20260920_U33OBS_RGOFF_BIT.md`.

## New since GitHub `52ca392`

### 2026-09-20 19:40+07 — V-03 sentinel read-address RCA

`D_U33OBS_V03_SENTINEL_RDADDR.json` sha256 `632dc91e…`. `pack_loader.sv` sha256 `bb59f068…` (`rg_off` on sentinel read). Dirty XSim `V03_DIRTY_DEST_LOAD_OK`. Silicon still `71b9198f` (`new_bit=NOT_BUILT`). **PACK_ABI_24_24_PASS=NO.** This watch did not nạp. Doc: `BOARD_20260920_U33OBS_V03_SENTINEL_RDADDR.md`.

## New since GitHub `422e6ba`

### 2026-09-20 19:34+07 — isolated V-01 GOLD

`PACK24_ISO_PA24-V-01.json` sha256 `9f5ab8e5…`. V-01 **GOLD** `010000a5`. DUMP after GOLD **MUTE n=0**. Isolated V-03-first still `0200085a`. **PACK_ABI_24_24_PASS=NO.** This watch did not run Pack24. Doc: `BOARD_20260920_U33OBS_ISO_V01.md`.

## New since GitHub `464c72d`

### 2026-09-20 19:33+07 — isolated V-03 first still R_SENTINEL

`PACK24_ISO_V03_FIRST.json` sha256 `2ad33654…`. V-03 NAK `0200085a` with TAP `47000002` flip **absent** identity U33OBS_GEN. **PACK_ABI_24_24_PASS=NO.** This watch did not run Pack24. Doc: `BOARD_20260920_U33OBS_ISO_V03_FIRST.md`.

## New since GitHub `29255fe`

### 2026-09-20 19:27+07 — Pack24 run1 compare + V-03/A-03 probe

`D_U33OBS_PACK24_RUN1.json` sha256 `18ae5afb…`. B `--compare` printed **-16/24 match, 40 fail** (field-fail count). Isolated probe: V-03 still `0200085a`; A-03 still MUTE. TAP four-AND absent. **PACK_ABI_24_24_PASS=NO.** This watch did not run Pack24. Doc: `BOARD_20260920_U33OBS_PACK24_RUN1_COMPARE.md`.

## New since GitHub `2509ef0`

### 2026-09-20 19:24+07 — Pack24 run1 (not 24/24)

`PACK24_RUN1.json` sha256 `f8379872…` stop=`PACK24_RUN1_DONE`. LOAD_OK GOLD: V-01 V-02 V-04 R-04 G-01. V-03 reject 8. A-02 MAG. A-03/A-04 MUTE n=0. DUT jsonl omits `generation_flipped`. **PACK_ABI_24_24_PASS=NO.** This watch did not run Pack24. Doc: `BOARD_20260920_U33OBS_PACK24_RUN1.md`.

## New since GitHub `1412517`

### 2026-09-20 19:22+07 — board V-04 jsonl B --compare 1/24

`D_U33OBS_BOARD_HOPS.json` sha256 `b9f14275…`. `U33OBS_BOARD_V04.jsonl` sha256 `12608ffe…`. Parent `--compare` **1/24** (V-04 only). **PACK_ABI_24_24_PASS=NO.** **PROGRAM_PASS=NO.** **BOARD_PASS=NOT_EVIDENCED.** This watch did not `--run`. Doc: `BOARD_20260920_U33OBS_BOARD_V04_COMPARE.md`.

## New since GitHub `586620e`

### 2026-09-20 19:20+07 — isolated leftover / GOLD DUMP / V-04×4

Leftover MAG `0200015a` TAP **CLASS_A_p1_BEGIN** flip **absent**. GOLD DUMP UART GOLD + TAP `470f0002` `ffffffff→0000ffff` **flip=1**. V-04×4 **4/4 GOLD**. **PACK_ABI_24_24_PASS=NO.** **PROGRAM_PASS=NO.** This watch did not `--run`. Doc: `BOARD_20260920_U33OBS_ISOLATED_HOPS.md`.

## New since GitHub `c001dbf`

### 2026-09-20 19:15+07 — OBS program + hops (not PROGRAM_PASS)

Parent `OWNER_AUTHORIZED` Tcl: EOS HIGH, `PROGRAM.txt` STATUS=PROGRAMMED sha `71b9198f…`, **PROGRAM_PASS=NO**. Hops `U33OBS_GEN` gate; dummy-open **GOLD** `010000a5`; leftover **MAG** `0200015a`; TAP after V-04 **MUTE n=0** so silicon four-AND on GOLD TAP **not captured**. **PACK_ABI_24_24_PASS=NO.** This watch did not nạp and did not `--run` hops. Doc: `BOARD_20260920_U33OBS_PROGRAM_HOPS.md`.

## New since GitHub `fb1779a`

### 2026-09-20 19:10+07 — Pack observe DUT XSim 24/24 load, B --compare not 24/24

`PACK_ABI24_OBS_DUT_XSIM_LOAD` 24/24 dest-complete at 23885 ns (`mig_ui_bram`, not board). `DUT.jsonl` sha256 `035636d3…` four-AND only. 17 rejects omit `generation_flipped`. B `--compare` prints 2/24 (22 field fails); V-01..V-04 and G-01 fully match. **PACK_ABI_24_24_PASS=NO.** Campaign leftover MAG now field **absent**. **Not programmed.** Doc: `BOARD_20260920_PACK_ABI24_OBS_DUT.md`.

## New since GitHub `66c6111`

### 2026-09-20 19:03+07 — TAP four-AND DUT mapper PASS_SELFCHECK

`generation_flipped` only Pack-owner S_COMMIT four-AND. Leftover/DUMP/idle snapshot → field **absent**. GOLD TAPDUMP `0x470F0002` `ffffffff→0000ffff` → `1`. Synthetic DUT jsonl V-04 `SYNTHETIC_TAPDUMP_XSIM_NOT_SILICON`. Parent gold `--compare` 1/24 match 23 missing — **not silicon, not PACK_ABI**. `u33obs_capture.py` sha256 `a33e82a2…`. **Not programmed.** `READY_TO_PROGRAM=NO`. `PACK_ABI_24_24_PASS=NO`. Doc: `BOARD_20260920_U33OBS_DUT_MAP.md`.

## New since GitHub `1dbd4ac`

### 2026-09-20 18:54+07 — TAP four-AND decoder PASS_SELFCHECK; program Tcl gated

`u33obs_capture.py` sha256 `6587bf62…`: GOLD four-AND `before=ffffffff after=0000ffff`; leftover CLASS_A no fake flip; DUMP empty no flip; TAPCDC 6-word `NOT_U33OBS_GEN`. `97_program_uart_r2_u33obs.tcl` requires `OWNER_AUTHORIZED` and bans frozen SHAs. Bat exit 4 without that arg. **Not programmed.** `READY_TO_PROGRAM=NO`. `PACK_ABI_24_24_PASS=NO`. Doc: `BOARD_20260920_U33OBS_PREPROG.md`.

## New since GitHub `007ae22`

### 2026-09-20 18:50+07 — U33OBS BIT_OK `71b9198f…`

`uart_r2_u33obs_candidate.bit` sha256 `71b9198f512972bae75af04e406d26c17d7940ecadd324e5b5ffecaedcbf6762` (verified). DCP `168359bc…`. Unique vs U33/TAPCDC/TAP/H. `write_bitstream` 0 errors `PROGRAM=NO`. WNS +0.303 WHS +0.008. **Not programmed.** `TIMING_PASS=NO`. `READY_TO_PROGRAM=NO`. `OWNER_YES_REQUIRED=YES`. `PACK_ABI_24_24_PASS=NO`. Doc: `BOARD_20260920_U33OBS_BIT_OK.md`.

## New since GitHub `9bfaac0`

### 2026-09-20 18:49+07 — U33OBS XDC `-from/-to` ROUTE_DONE, constraints MET

Post-route WNS **+0.303** TNS 0 (0 fail) WHS **+0.008**. `impl.log` 18-540 count **0**. XDC sha256 `cd8b7494…`. LUT 10921 FF 9800 RAMB36=3 RAMB18=2 DSP 8. `post_route.dcp` sha256 `168359bc…` (not pushed). dump-SOF `d3e26d3d…` and gen WNS-fail `37953849…` preserved. **No bitstream. Not programmed.** Parent BUILD **`TIMING_PASS=NO`**. `READY_TO_PROGRAM=NO`. `PACK_ABI_24_24_PASS=NO`. Doc: `BOARD_20260920_U33OBS_ROUTE_XDC_FROM.md`.

## New since GitHub `143f2ba`

### 2026-09-20 18:43+07 — U33OBS gen+XDC ROUTE_DONE, timing not met

`TAP_CDC_XDC_AT_IMPL=YES`. Post-route WNS **−1.507** TNS −9.850 (**20** setup). WHS +0.016→**+0.028** MET. LUT 10929 FF 9802 RAMB36=3 RAMB18=2 DSP 8. `post_route.dcp` sha256 `37953849…` (not pushed). **Constraints 18-540 ×7** at impl — OBS `-to` without `-from` still ignored. Fail class: a0/cal0/nak0 + 17 `epoch_ui` 100→ui. dump-SOF `d3e26d3d…` preserved. **No bitstream. Not programmed.** `TIMING_PASS=NO`. `READY_TO_PROGRAM=NO`. `PACK_ABI_24_24_PASS=NO`. Doc: `BOARD_20260920_U33OBS_ROUTE_GEN.md`.

## New since GitHub `8151cc2`

### 2026-09-20 18:39+07 — U33OBS gen+XDC SYNTH_DONE

`TAP_CDC_CELLS=1` `U2UI_CDC_CELLS=1`. Unplaced WNS **−1.243** (3 setup: cal0/nak0/a0, still 2.000 ns). WHS −1.631 unplaced. LUT 11938 FF 10901. `post_synth.dcp` sha256 `88f3310e…`. OBS `set_max_delay -datapath_only -to` without `-from`: **Constraints 18-540 ×7** — exceptions **not applied**. dump-SOF `d3e26d3d…` preserved. **Not programmed.** `TIMING_PASS=NO`. `READY_TO_PROGRAM=NO`. `PACK_ABI_24_24_PASS=NO`. Doc: `BOARD_20260920_U33OBS_SYNTH_GEN.md`.

## New since GitHub `855d186`

### 2026-09-20 18:33+07 — U33OBS TAPDUMP GOLD four-AND PASS_XSIM

`tb_u33obs_tapdump` `$finish` 6690235 ns. Leftover MAG CLASS_A p0=p1=BEGIN `before=after=0`. DUMP-without-NAK `44554D50` fr=3. GOLD `stat=470f0002` `before=ffffffff after=0000ffff` four-AND Pack-owner COMMIT. `pack_obs_gen` sha256 `c4c79eb8…`. Display log sha256 `61e2e3e1…`. Expanded OBS 2FF XDC **not** on dump-SOF DCP. **Not programmed.** `READY_TO_PROGRAM=NO`. `PACK_ABI_24_24_PASS=NO`. Doc: `BOARD_20260920_U33OBS_TAPDUMP_GEN.md`.

## New since GitHub `78ca615`

### 2026-09-20 18:27+07 — U33OBS ROUTE_DONE, timing not met

`TAP_CDC_XDC_AT_IMPL=YES`. Post-route WNS **-1.516** TNS -6.011 (7 endpoints). WHS +0.016 MET. LUT 10751 FF 9507 RAMB36=3 RAMB18=2 DSP 8. `post_route.dcp` sha256 `d3e26d3d…a32ead` (not pushed). TAP XDC covers dump TAP/U2UI + busy only; failing paths are `obs_ctrl` 2FF, freeze/reason into dump, MIG `cal0`, `load_reject→nak0` (2.000 ns related-clock). **No bitstream. Not programmed.** `TIMING_PASS=NO`. `READY_TO_PROGRAM=NO`. `PACK_ABI_24_24_PASS=NO`. Doc: `BOARD_20260920_U33OBS_ROUTE.md`.

## New since GitHub `9addd26`

### 2026-09-20 18:22+07 — U33OBS synth SYNTH_DONE

`TAP_CDC_CELLS=1` `U2UI_CDC_CELLS=1`. Post-synth WNS -1.245 (unplaced). LUT 11750 FF 10601. Unique `build_u33obs`. Frozen U33/H/TAPCDC not overwritten. **Not programmed.** `TIMING_PASS=NO`. `READY_TO_PROGRAM=NO`. `PACK_ABI_24_24_PASS=NO`. Doc: `BOARD_20260920_U33OBS_SYNTH.md`.

## New since GitHub `6d3513b`

### 2026-09-20 18:14+07 — U33OBS TAP dump CDC PASS_XSIM

Dedicated TAP CDC (`pack_obs_dump.sv`) after freeze: TAP1 `31504154`. Leftover MAG CLASS_A UART CLEAR/BEGIN loader BEGIN/BEGIN. DUMP `44554D50` no NAK, loader empty. GOLD has no TAP1. Path for MUTE silicon (DUMP after timeout). Log sha256 `80746a77…` 6125375 ns. **Not programmed.** Product Pack TX CDC is not dump path. `READY_TO_PROGRAM=NO`. `PACK_ABI_24_24_PASS=NO`. Doc: `BOARD_20260920_U33OBS_TAPDUMP.md`.

## New since GitHub `6713712`

### 2026-09-20 18:09+07 — U33OBS 9-lane PASS_XSIM

`tb_u33obs_9lane` `$finish` 5164993750 ps. Log sha256 `2f94eb34…`. CONTROL/STATE/TERMINAL live. Leftover MAG `flip_present=0` CLASS_A p0=p1=BEGIN. DUMP freeze 3 no NAK. GOLD V-04 `generation_flipped=1` from `S_COMMIT` four-AND (`ffffffff`→`0000ffff`). Peek is parser state, not ACK edge. `pack_loader` unmodified. **Not programmed.** `READY_TO_PROGRAM=NO`. `PACK_ABI_24_24_PASS=NO`. Doc: `BOARD_20260920_U33OBS_9LANE.md`.

## New since GitHub `ecb804e`

### 2026-09-20 18:02+07 — U33OBS DUMP hops PASS_XSIM

`tb_u33obs_dump_hops` `$finish` 2763675 ns. Log sha256 `b36151b8…`. Leftover MAG CLASS_A UART/FIFO/CDC/LOADER: `got=0200015a` loader `p0=p1=BEGIN` first-divergent=p1. DUMP `44554D50` without NAK: `freeze_reason=3` `load_reject=0` DUMP never enters FIFO. `armed` sticky-to-freeze fix (`pack_obs_ctrl` no longer `armed=handshake ack`). `generation_flipped` 4-AND unchanged (`pack_obs_gen` `5a43f604…`). **Not programmed.** `READY_TO_PROGRAM=NO`. `PACK_ABI_24_24_PASS=NO`. Doc: `BOARD_20260920_U33OBS_DUMP_HOPS.md`.

## Parent is doing (archived 2026-09-20 17:52+07)

U33OBS 7-lane identity **IN_PROGRESS** (XSim core COMPLETE, not programmed). Exclusive PROGRAM window for AGENT_D until 00:00 +07 2026-09-21. No overlay H/U33. Do not resume parent xelab from this watch.

## New since GitHub `03b4b94`

### 2026-09-19 23:17+07 — semantic→physical (side-chat D audit, COMPLETE)

Class **`SEMANTIC_TO_PHYSICAL_RESOLUTION_INCOMPLETE`**. Pack `mem_addr` = slot + host `ddr_offset` + page. COMMIT does not install T1. Query `$readmemh`. MAG firewall. Spec: `CANON_BLUEPRINT/_COORDINATION/designs/2026-09-19-semantic-to-physical.md`.

### 2026-09-20 16:23+07 — CONTROL2 reprogram exact U33 `ff399e0b…`

Owner reprogrammed U33. New host: 24 consecutive CLEAR→V-04 ACK/GOLD (same V-04 vector, **not** ABI-24). Old host mute then new host recovered without reprogram. Fifth-V-04-always-MAG **CONTRADICTED_THIS_SEQ**. Mute ≠ MAG until hop capture. `PACK_ABI_24_24_PASS=NO`. Docs: `docs/audits/20260919_u33_discriminator/BOARD_20260920_CONTROL2.md`.

### 2026-09-20 16:45–16:56+07 — A/B/A COM / DTR / close-phase

Dummy-open MUTE reproduced on U33 after reprogram. Close-phase matrix GOLD on all arms (not MUTE). MUTE follows old-host session, not close-phase alone. `BOARD_20260920_ABA_POSTPROG.md`, `BOARD_20260920_DTR_CLOSE.md`.

### 2026-09-20 17:14+07 — U33TAP `d448544f…` silicon dump

Leftover extra BEGIN → MAG. TAP dump p1 `414e0080` ≠ XSim BEGIN. Dump untrusted (bit not rebuilt after TAP CDC XDC). Dummy-open did **not** mute on TAP (`INSTRUMENTATION_PERTURB`). `BOARD_20260920_TAP_UART_VS_XSIM.md`.

### 2026-09-20 17:33+07 — U33TAP_CDC `eb99ac69…` recapture COMPLETE

CELL_DUP4: ACK then MAG `0200015a`. TAP CLASS_A `p0=p1=00800001` `p2=3149414e`. Matches leftover XSim class A. Historical natural MAG still OPEN. `results/arty_d/UART_R2/results/U33TAP_CDC_CAPTURE_20260920/CAPTURE.json`.

### 2026-09-20 17:46+07 — `generation_flipped` 4-AND lock + U33OBS core XSim

`generation_flipped` iff `commit_event && gen_after!=gen_before && same_capture_epoch && capture_valid`. U33OBS core `PASS_XSIM` leftover CLASS_A on 112-bit lane. **Not programmed.** Query UART still tied off. `BOARD_20260920_U33OBS_CORE.md`.

```
PACK_ABI_24_24_PASS = NO
PROGRAM_PASS = NO
```

## Parent is doing (archived 2026-09-19)

Independent K1/K2/K3 **COMPLETE** (XSim TAP). Watch loop PID 47724 **aborted** 2026-09-19T13:44:22Z. No overlay. Do not resume parent xelab.

## New since GitHub `e97895b`

### 2026-09-19 08:31+07 — RAW_MIG_READY_USED_AS_QUIESCENCE

Parent reviewed Anh’s hypothesis **before overlay**.

| Layer | Verdict |
|---|---|
| `MISSING_APP_RDY_GATE` | **WEAK** — idle `mig_ui32` does not need `app_rdy`; mux `G_NONE` zeros `p_rdy` on purpose |
| U31/U32 `pack_quiescent` ANDs raw `mig0.app_rdy`/`app_wdf_rdy` | **FACT** (`pack_mig_bind.sv` + top wiring) |
| PACKAGE live qsc | **FACT** — loader+ui+outstanding only; no `dest_ui_*` |
| BRAM `app_rdy = rst_n && !stall` | **FACT** — OBS01 BRAM CLEAN cannot refute dest-ready dips |
| Board CLEAR1 BUSY / BEGIN hold caused by that AND | **HYPOTHESIS** at 08:31; XSim later **SEEN_THIS_SEQ** (board still open) |
| Root cause | **UNKNOWN** (not PACK_ABI / BOARD) |

Do not UART-overlay. Do not strip `dest_ui_*` from product qsc until PACKAGE-qsc A/B ACK.

Sources:

- `CANON_BLUEPRINT/_COORDINATION/reasoning/NATIVE_AI_REASONING_EXPERIENCE_V1_AGENT_D_20260919T013100Z.md`
- `results/arty_d/D_DEST_LIFECYCLE_OBS_01/tb_dest_lifecycle_obs_01_mig0.sv` sha256 `fb36a2b88b677a0e7feebbe1a58fc484f1ae292e67d281e660842fc6e1d17a6c`

### 2026-09-19 08:34–08:36+07 — OBS01-MIG0 compile (superseded)

Two `xvlog`/`xelab` hangs were killed (`exit 4294967295`). Compile into `-work obs` then XSim completed. See next entry.

### 2026-09-19 08:55–09:00+07 — OBS01-MIG0 XSim COMPLETE

Parent: `run_obs01_mig0.bat`. `$finish` 211565 ns. calib_done 122810625 ps. xsim elapsed ~7m25s after calib.

```
MIG0_PATH_THIS_SEQUENCE          = FAIL_XSIM_CLEAR1_BUSY
LAST_EQUIVALENT_EVENT            = CALIB_DONE
FIRST_DIVERGENCE                 = CLEAR1_ACK
got                              = c1ea50b5 (CLR_BUSY) mute=0
RAW_MIG_READY_USED_AS_QUIESCENCE = SEEN_THIS_SEQ (PASS_XSIM)
MISSING_APP_RDY_GATE             = CONTRADICTED_THIS_SEQ (qsc path)
PACK_ABI_24_24_PASS              = NO
MIG0_BOARD_CAUSAL_CLASS          = STILL_OPEN
```

P0–P15 not armed (`t1_arm` after CLEAR1 ACK). `DEBUG_CLEAR_RISE` never occurred.

Independent csv check (this publish): 186 rows. `qsc===app_rdy` 186/186. All `ld=IDLE ui=IDLE ld_out=0 ui_out=0 mux_g=0`. `p_rdy=0` and `p_wdf_rdy=0` all rows. `app_wdf_rdy=1` all rows. Idle+qsc=0: 93 rows, all `app_rdy=0`. Idle+qsc=0 while dest_rdy=1 and dest_wdf=1: **0**. `debug_clear=1`: 0.

Hashes:

| Artifact | SHA256 |
|---|---|
| `out/dest_ui_clk_mig0.csv` | `134b59561bf07f125e3b419ac16e5170a4ce9a77682505310007b8249331b5dc` |
| `out/xsim_mig0.log` | `169061f9f8b577e8e78e0dd1012798eac098b6433d623fb2a730084a2fde70ad` |
| `tb_dest_lifecycle_obs_01_mig0.sv` | `fb36a2b88b677a0e7feebbe1a58fc484f1ae292e67d281e660842fc6e1d17a6c` |
| U32 `pack_mig_bind.sv` | `7cee4df21b69f5eb05728473c755f3f067b6c702502f0ac97af59f19093b0fbe` |

No UART overlay. No dest_accept overlay. No program. Next parent test (not done): PACKAGE-qsc A/B.

```
PACK_ABI_24_24_PASS = NO
```

### 2026-09-19 09:34+07 — PACKAGE-qsc A/B CLEAR1 ACK

First `xvlog -d QSC_USE_DEST_RDY=0` split `=0` as a filename. Parent switched to `-d OBS01_QSC_PKG`.

```
USE_DEST_RDY=0  CLEAR1 ACK  c1ea50a5  qsc_ui=1 qsc_c1=1 dest_accept=1
BRANCH H1_CAUSAL_CLEAR1_ACK PACKAGE_QSC dest_rdy_not_in_qsc
P0_BEGIN_ACCEPT t=451550625.0 ps
V-04 / P1–P15 / GOLD1 = IN_PROGRESS (xsim still holds the log)
PACK_ABI_24_24_PASS = NO
```

Contrast published U32 dest-AND seq: CLEAR1 BUSY `c1ea50b5`.

TB-only: harness forces dest ready 1 into `pack_mig_bind` dest_ui ports. Product `pack_mig_bind.sv` still `7cee4df2…` (AND dest_ui_*). No overlay. No program.

Snapshot log sha256 `c182aeed392e97b979690abe1c47288b8a5a4bc667a7919d30b0ffb3535a88a7` (155 lines). Write-up: `results/arty_d/D_DEST_LIFECYCLE_OBS_01/OBS01_MIG0_PKGQSC.md`.

### 2026-09-19 10:42+07 — PACKAGE-qsc GOLD1 + P0–P15

Live log (not parent chat text). `xsim`/`xsimk` still running. csv snapshot truncated; score from `$display`.

```
PACKAGE_QSC_MIG0_TXN1_P0_P15 = PASS_XSIM  t1_seen=ffff last=P15_SETTLE_IDLE div=NONE
PACKAGE_QSC_GOLD1            = PASS_XSIM  mute=0 got=010000a5
Q1_MIG_UI32_IDLE_AFTER_GOLD1 = YES
P0  t=451550625.0 ps
P1  t=2451602625.0 ps   (~2.00 ms sim after P0 = UART 52-word ingest)
P2+P3 same cycle 2451626625.0 ps
P15 t=2492666625.0 ps   ui/ld idle out=0 cmd_acc=0 wdf_acc=0
CLEAR2 / GOLD2 / Q3 / Q4     = IN_PROGRESS
PACK_ABI_24_24_PASS          = NO
MIG0_PATH_THIS_SEQUENCE      = FAIL_XSIM_CLEAR1_BUSY  (U32 dest-AND seq; not overwritten)
```

Wall: calib+CLEAR ~09:20–09:35; UART ingest ~09:35–10:38; GOLD1 on log by 10:40. Slow because `mig0`+`ddr3_model`+1ps+gui/wdb, not because “52 integers”.

Also on log: `OBS01_QSC0_WHILE_IDLE t=2581202625.0 ps dest_rdy=1` after BEFORE_CLEAR2. **UNKNOWN** until `OBS01_CLEAR2` prints. Not classified as CLEAR2 BUSY.

Hashes this publish:

| Artifact | SHA256 |
|---|---|
| snapshot `out/xsim_mig0_pkgqsc.log` | `564d2eb444e26599a66f8d5a93ed744a591e1850950c811204e4ecf9c698e076` (177 lines) |
| snapshot `out/xsim_mig0_pkgqsc_ckpt.txt` | `124b1f6816f52dea6e7623809d7bb12b97a657d3246ab30dc387fc3db22e4997` |
| snapshot `out/dest_ui_clk_mig0_pkgqsc.csv` | `b59272b5e160c99a48873c5b942bdc3530a41f28c6412719eafbc67d2f6ac087` (truncated) |

No UART overlay. No dest_accept overlay. No program. Product `pack_mig_bind.sv` still `7cee4df2…`.

### 2026-09-19 10:49+07 — PACKAGE-qsc CLEAR2 ACK

```
PACKAGE_QSC_CLEAR2         = PASS_XSIM  mute=0 got=c1ea50a5 dclr_busy=0 lack_fell=1
Q2_DEST_IDLE_AT_CLEAR2     = YES
OBS01_V04_2_ARM            n_commit=1 n_lack_rise=1 n_stv_rise=1
BEGIN2 P0_BEGIN_ACCEPT     t=2869094625.0 ps
GOLD2 / Q4 / P1–P15        = IN_PROGRESS
PACK_ABI_24_24_PASS        = NO
```

`lack_fell=1` is CLEAR reset of sticky `load_ack`, not BEGIN2. QSC0_WHILE_IDLE with dest_rdy=1 is **not** CLEAR2 BUSY (ACK followed).

Hashes this publish:

| Artifact | SHA256 |
|---|---|
| snapshot `out/xsim_mig0_pkgqsc.log` | `d44f4cd5dba330513fc509fbe045982e720884db6bebe057131cdfa600fa5adb` (180 lines) |
| snapshot `out/xsim_mig0_pkgqsc_ckpt.txt` | `15ce6ba4ab18b916f34bd1cbef6fa12c5db5a11dcc5b245b1a9c328a3c13b228` |

### 2026-09-19 11:44+07 — PACKAGE-qsc BEGIN2 P0–P15

```
PACKAGE_QSC_MIG0_TXN2_P0_P15 = PASS_XSIM
BEGIN2 P0  t=2869094625.0 ps
BEGIN2 P1  t=4869146625.0 ps  (~2.00 ms sim after P0 = UART 52-word ingest)
BEGIN2 P2+P3 same cycle 4869170625.0 ps
BEGIN2 P15 t=4910258625.0 ps  ui/ld idle out=0 cmd_acc=0 wdf_acc=0
GOLD2 / Q4                   = IN_PROGRESS
PACK_ABI_24_24_PASS          = NO
```

Hashes this publish:

| Artifact | SHA256 |
|---|---|
| snapshot `out/xsim_mig0_pkgqsc.log` | `aa7a038f319f74cea9aed5b58768a2be03f79f356b492fd4a4fb0eafd15e2658` (195 lines) |
| snapshot `out/xsim_mig0_pkgqsc_ckpt.txt` | `7860510a689228d7c97d2957a11545cc3e07e5dd8780dc3bb7ac232839f8ad4b` |
| snapshot `out/dest_ui_clk_mig0_pkgqsc.csv` | `4a7ace74d8f9bbc07e991b337d02fb70f57c5f6bdd240de68993b5198dec7035` |

### 2026-09-19 11:45+07 — PACKAGE-qsc GOLD2 `$finish`

Sim ended. `xsimk` gone.

```
PACKAGE_QSC_GOLD2                    = PASS_XSIM mute=0 got=010000a5 begin2=1
Q1 YES  Q2 YES  Q3 NO  Q4 NEW_COMMIT d_commit=1 d_lack=1 d_stv=1
NO_STUCK_STATE_OBSERVED_ON_MIG0_THIS_SEQ = YES
PACKAGE_QSC_MIG0_PATH_THIS_SEQUENCE  = CLEAN (TB; dest ready forced)
U32 dest-AND MIG0_PATH_THIS_SEQUENCE = FAIL_XSIM_CLEAR1_BUSY (unchanged)
LAST_EQUIVALENT_EVENT                = P15_SETTLE_IDLE
$finish                              = 4958414625 ps
PACK_ABI_24_24_PASS                  = NO
```

Hashes this publish:

| Artifact | SHA256 |
|---|---|
| `out/xsim_mig0_pkgqsc.log` | `63eb8e3e1145d5d668d16a989d33e7a1eaec7df566de41f0a6b1069c832455d1` (213 lines) |
| `out/xsim_mig0_pkgqsc_ckpt.txt` | `75cd2edd637a2a2cacff19e6e566726c71312a13993cb58864aba71c6e574a33` |
| `out/dest_ui_clk_mig0_pkgqsc.csv` | `34b68c2b22abeac30356b0229c1f0603a0222b9fb0e0c7543e1e19208a018b5b` |

### 2026-09-19 12:07–12:16+07 — U33 owner-program FAIL_BOARD MAG

Parent programmed U33 after owner “Board ready program được rồi đó”. Not identity H. D does not self-stamp PROGRAM_PASS.

```
U33_BOARD_THIS_SEQUENCE = FAIL_BOARD_P5_V04_R3_MAG
CLEAR1                  = ACK c1ea50a5 n=4
PHASE4 V-04             = GOLD 010000a5 n=4
p5 r0–r2                = GOLD (r2 CLEAR n=0 then retry ACK)
FIRST_DIVERGENCE        = p5 V-04 round 3 MAG 0200015a n=4
LAST_EQUIVALENT         = p5 V-04 round 2 GOLD
Pack24 run1/run2/fresh  = not started
PACK_ABI_24_24_PASS     = NO
```

Contrast U32 exclusive: CLEAR1 BUSY `c1ea50b5`, no GOLD. U33 board CLEAR1 ACK supports dest-ui-not-in-qsc on silicon for CLEAR, then a later MAG class (root UNKNOWN). Bit not copied (overlay candidate). Evidence only.

| Artifact | SHA256 |
|---|---|
| bit (not in git) | `ff399e0bb9e6ff6c91caf3b769270b03ca9cfb2ea317035a5f3533031338a350` |
| `PROGRAM.txt` | `81ae5dd569cfcd3f68aaa50f42cbf2318ff9a13e4f217eaaa3f4617bc02a9505` |
| `CLEAR_V04_24.json` | `b289fd4e9796ccbc2c31bb7039d334ad8a4a99d9b49bea80c51dafc3e8b8855f` |
| `RAW_UART/p5_v03.json` | `01962c633adca31e3992b7702d8cc2bca2fa7cb14c307f911964fd7a71012d4f` |
| `U33_FAIL.md` | `ede3a506437450357b70909301bfa27476f54bf3df64db045731c8f6aa31968f` |

### 2026-09-19 12:20+07 — MAG `0200015a` = `R_BAD_MAGIC`; 5×V-04 BRAM GOLD

Parent classified the board MAG token before overlay. Do not patch `pack_loader`.

```
UART NAK packing     = {02, 00, reason, 5A}
R_BAD_MAGIC          = 8'h01 → word 0200015a
Board p5 r3          = load_reject after OP_BEGIN iff hw0 != 3149414E
U33 five_v04 BRAM    = PASS_XSIM five GOLD 12083475 ns p1=3149414e
Board MAG ≠ 5th V-04 on BRAM dest
mig0 5× CLEAR-V-04   = NOT_RUN this log
PACK_ABI_24_24_PASS  = NO
```

| Artifact | SHA256 |
|---|---|
| `MAG_CLASS.md` | `7fb04e9f3a53976400d0d4b505c1bb05d35353b7043dfe6664898b50e673cabc` |
| `xsim_u33f.log` | `c4011529721270fe063043ae640911b7017d4b4ffdb4613924832fa8e3efc5d0` |

### 2026-09-19 12:27+07 — D independent two-class closure (disk, jsonl not yet flushed)

Parent wrote `D_PACK24_CLOSURE_INVESTIGATION.md` RUN_ID `20260919T052400Z` without a new chat line. Two stacked classes; Option A already on U33 silicon.

```
Class 1 CLEAR1 BUSY     = CONFIRMED U32 (app_rdy-in-qsc); U33 board ACK
Class 2 remaining       = 5th V-04 load_reject R_BAD_MAGIC
Option A                = U33; CONTRADICTED as Pack24 close
mig0 5× CLEAR-V-04      = NOT_RUN (next; PROGRAM=NO)
PACK_ABI_24_24_PASS     = NO
```

Correction vs earlier RX-drop story: `uart_rx_word` `bix==3 && !can_take` holds STOP until take (latent overrun), not “return IDLE without emit”.

| Artifact | SHA256 |
|---|---|
| `D_PACK24_CLOSURE_INVESTIGATION.md` | `9d8b7d268b229cc0644223040df6be6317ae5d7251bb438a5757bf67e0b292fa` |

### 2026-09-19 13:42+07 — U33 mig0 five V04_0 GOLD (IN_PROGRESS)

`xsim_u33m` flushed first round after ~68 min post-calib. Not `$finish`. Rounds 1–4 still running.

```
V04_0 mute=0 got=010000a5 n_p=8 p0=00800001 p1=3149414e rej=0 rsn=00 qsc_ui=1 dest_rdy=1
CALIB_DONE t=122810625.0 ps
dest=generated_mig0 bind=U33
PACK_ABI_24_24_PASS=NO
```

| Artifact | SHA256 |
|---|---|
| snapshot `xsim_u33m.log` | `a073edb094c2d2947d04d0f346b9e69233bacfd94cf8ae053dfb33ba0f74df12` (152 lines) |

### 2026-09-19 14:55+07 — U33 mig0 five V04_1 GOLD (IN_PROGRESS)

`xsim_u33m` flushed round 1 (~73 min after V04_0). Not `$finish`. Rounds 2–4 still running. Same GOLD token as round 0.

```
V04_1 mute=0 got=010000a5 n_p=8 p0=00800001 p1=3149414e rej=0 rsn=00 qsc_ui=1 dest_rdy=1
dest=generated_mig0 bind=U33
PACK_ABI_24_24_PASS=NO
```

| Artifact | SHA256 |
|---|---|
| snapshot `xsim_u33m.log` | `db41c208094424b39029785b7401ded347829cb207c61b267073ad6c7172355d` (153 lines) |

### 2026-09-19 16:20+07 — U33 mig0 five V04_2 GOLD (IN_PROGRESS)

`xsim_u33m` flushed round 2 (~85 min after V04_1). Not `$finish`. Rounds 3–4 still running. Same GOLD token as rounds 0–1.

```
V04_2 mute=0 got=010000a5 n_p=8 p0=00800001 p1=3149414e rej=0 rsn=00 qsc_ui=1 dest_rdy=1
dest=generated_mig0 bind=U33
PACK_ABI_24_24_PASS=NO
```

| Artifact | SHA256 |
|---|---|
| snapshot `xsim_u33m.log` | `835300c175d22ede67bff03d714b6ced4a259c7375e6d40ceb5b9c8a5bd10b63` (154 lines) |

### 2026-09-19 18:44+07 — U33 mig0 five V04_3 GOLD (IN_PROGRESS)

`xsim_u33m` flushed round 3 (~18:44 after host sleep 16:55–18:02). Awake work since V04_2 ~77 min. Not `$finish`. Round 4 still running. Same GOLD token as rounds 0–2.

```
V04_3 mute=0 got=010000a5 n_p=8 p0=00800001 p1=3149414e rej=0 rsn=00 qsc_ui=1 dest_rdy=1
dest=generated_mig0 bind=U33
PACK_ABI_24_24_PASS=NO
```

| Artifact | SHA256 |
|---|---|
| snapshot `xsim_u33m.log` | `e608ba7ae444e83f8cbf2f209ce0525ed5883ae153932bf6c6b78050c7448005` (155 lines) |


### 2026-09-19 18:17+07 — leftover BEGIN MAG inject (PASS_XSIM, not board close)

Parent AGENT_D ran `tb_u33_leftover_begin_mag.sv` on BRAM dest (not generated mig0). Did not kill `xsim_u33m`. CELL A reproduces board MAG token; leftover source on silicon still UNKNOWN. No overlay. PROGRAM=NO.

```
CELL_A MAG  got=0200015a p0=00800001 p1=00800001 p2=3149414e rej=1 rsn=01
CELL_C GOLD leftover 010000a5 does not MAG
CELL_B mute n_p=0 (ACK-overlap BEGIN ≠ board n=4 NAK)
CELL_D GOLD n=0-retry not sufficient on BRAM
CELL_E GOLD zero-settle not MAG on BRAM 1M
$finish 34548945 ns  wall ~6 s  dest=mig_ui_bram bind=U33
PACK_ABI_24_24_PASS=NO
```

| Artifact | SHA256 |
|---|---|
| `tb_u33_leftover_begin_mag.sv` | `7eba977d09a5958be2634d3a694df4c8e139f95bc739cae04d903097cc715909` |
| `xsim_u33mag.log` | `020506a7c2451861e63bfeff66ff17dd029f35c00aff75dbc34e11c3fa57a63b` |
| `u33_leftover_mag.log` | `efbf8e842b0e01812c4797415da62e566e0c7ee6ee7079f05f2641a36f5f8c7e` |
| `U33_LEFTOVER_MAG_XSIM.md` | `2b6d5822d581e3079449a49d7ae9af7e5728e4874feb01545e50846dad64e252` |

### 2026-09-19 18:44+07 — phantom CDC after CLEAR (PASS_XSIM negative)

Parent AGENT_D ran `tb_u33_phantom_cdc.sv` on BRAM dest. CLEAR does **not** emit leftover BEGIN. 5th V-04 without inject GOLD. Leftover `00010001` GOLD. Sticky `f_data=BEGIN` with `f_valid=0` is not a transaction. Did not kill `xsim_u33m`. No overlay. PROGRAM=NO.

```
AFTER_CLEAR1 n_ph=0 hold=0 a_idle=b_idle=1 f_valid=0
FIFTH_GOLD_WITHOUT_INJECT p0=00800001 p1=3149414e
ABI01_LEFTOVER_GOLD unlocked drop
$finish 19773145 ns dest=mig_ui_bram bind=U33
PACK_ABI_24_24_PASS=NO
```

| Artifact | SHA256 |
|---|---|
| `tb_u33_phantom_cdc.sv` | `6729702fa99bf864763fef6158bd620b5c88a8e9994ddc153d8bfb76d7753b1e` |
| `xsim_u33ph.log` | `4bbe8035e8d08d377c220d0202e68abf2096d9b43945c0ea95055885097e5ce1` |
| `u33_phantom_cdc.log` | `a06cac4a4d3e9e2fe4efe8fba5c8032d62d41dcc9dbda1c1ce7803899156e423` |
| `U33_PHANTOM_CDC_XSIM.md` | `2e0604884e93887925b1512a2421ed44aedb88b498084c677700b4770f1a0cc8` |

### 2026-09-19 19:58+07 — U33 mig0 five V-04 COMPLETE (PASS_XSIM)

Live `xsim_u33m` `$finish`. Five GOLD dest=**generated mig0** bind=U33. V04_4 (board MAG cell analogue) GOLD `010000a5` p0=`00800001` p1=`3149414e`. **CONTRADICTS** dest=mig0 5th MAG. Board leftover BEGIN source still UNKNOWN. No overlay. PACK_ABI_24_24_PASS=NO.

```
V04_0..V04_4 GOLD 010000a5 n_p=8 p0=BEGIN p1=MAGIC rej=0 rsn=00
U33_MIG0_FIVE_XSIM_PASS five GOLD dest=generated_mig0 bind=U33
$finish 12207195 ns  wall 07:26:23  CPU 15517312 ms
```

| Artifact | SHA256 |
|---|---|
| snapshot `xsim_u33m.log` | `0778d0a9b939a498982758707d67cdca1e83db06610ccd27c4859b4514406256` (163 lines) |
| `U33_MIG0_FIVE_XSIM.md` | `b8e070cee19a771a1e7ce618102e77cf21a722884ff8f0cbd58b28812f18683c` |

### 2026-09-19 20:02+07 — U33 115200 cells COMPLETE (PASS_XSIM)

Parent AGENT_D `tb_u33_baud115200.sv` dest=BRAM BAUD=115200 WAIT_AFTER_ACK=0. Five GOLD nosettle. r2 short mute then retry GOLD + r3 GOLD. First-byte MARK gap = mute, not MAG `0200015a`. Closed as MAG roots: dest=mig0 5th, BRAM 5th, 115200 nosettle, n=0-retry, CDC phantom, unlocked non-BEGIN, first-byte gap. Board leftover BEGIN / FTDI still UNKNOWN. No overlay. PACK_ABI_24_24_PASS=NO.

```
FIVE115_0..4 GOLD 010000a5 p0=00800001 p1=3149414e
R2_SHORT mute; R2_RETRY ACK; R2_V04 GOLD; R3 GOLD
GAP_ABORT_B0 mute n_p=0
$finish 234454805 ns  wall 36 s  dest=mig_ui_bram bind=U33
PACK_ABI_24_24_PASS=NO
```

| Artifact | SHA256 |
|---|---|
| `tb_u33_baud115200.sv` | `3eb5f786cf0ad7a97c087809931d2e29fb6c20ed7892ee4c42ef9f326fb3b093` |
| `xsim_u33b115.log` | `6e5fcb6e9ab6edaebf82e330fb821d3ebb0fd1205dab28acc13acd28a3a286a8` |
| `u33_baud115200.log` | `a5f6463d5e24d55f8cacf2a2b729106d5d4600d61fbbff0d3be19c7fd8924803` |
| `U33_BAUD115200_XSIM.md` | `bc1e2484d43b6407835093131e2453461ac8d12116bf776103cdc27141dfd25e` |

### 2026-09-19 20:08–20:11+07 — U33 exclusive after replug (FAIL_BOARD)

Parent programmed frozen U33 `ff399e0b…` End of startup HIGH (device was DONE=0). Immediate nwp4p5: CLEAR ACK then V-04 NONE n=0. Extra 30 s settle then nwp4p5: 3 GOLD, CLEAR n=0, then V04_2 MAG `0200015a` n=4. PROGRAM_PASS=NO. PACK_ABI_24_24_PASS=NO. No overlay. Side chat did not JTAG.

```
PROGRAM_OK sha=ff399e0bb9e6ff6c91caf3b769270b03ca9cfb2ea317035a5f3533031338a350 HIGH
A: CLEAR1 ACK / V04 NONE n=0
B: PHASE4 GOLD; V04_0 GOLD; CLEAR n=0; V04_1 GOLD; V04_2 OTHER_0200015a
```

| Artifact | SHA256 |
|---|---|
| `term_547668_reprogram_nwp4p5.txt` | `e380fb47f4c43955ad978da80dc417b54525ac65c0402afde6bae1e6d10a79e3` |
| `term_547669_settle30_nwp4p5.txt` | `98403b2a83b2241144f1b1032fcf86b327fd78bda6363138f16e36e300a1bbd2` |
| `PROGRAM_20260919T130846.txt` | `81ae5dd569cfcd3f68aaa50f42cbf2318ff9a13e4f217eaaa3f4617bc02a9505` |
| `U33_EXCLUSIVE_REPLUG_20260919.md` | `f6edc29388a4b57de5fd0d446075db762a9412c2c9107e28541c8bc8af7f6fb5` |

### 2026-09-19 20:14+07 — parent lock: host begin_n=1, MAG at p5 r2

AGENT_D COMPLETE write-up `PACK24_U33_REPROG/` (frozen `PACK24_U33` json not overwritten). Python TX **begin_n=1** every V-04 — python duplicate BEGIN **CONTRADICTED**. T0 mute n=0 after 12s. T1 LAST_EQUIVALENT=r1 GOLD, FIRST_DIVERGENCE=r2 MAG `0200015a`. FTDI/DUT leftover source UNKNOWN. PACK_ABI_24_24_PASS=NO. PROGRAM_PASS=NO. No overlay.

```
T0 CLEAR ACK / V04 NONE n=0
T1 Phase4 GOLD, r0 GOLD, r1 n=0-reopen GOLD, r2 MAG n=4
host nwords=52 begin_n=1 w0=00800001 w1=3149414e
```

| Artifact | SHA256 |
|---|---|
| `U33_REPROG.md` | `8514ebc6052d0645c3f11c8a87cd57e2fafec9bed560e5725f2168466e92d858` |
| `CLEAR_V04_24.json` | `4d2317ef20913f0d35be2889dfa3df00e92e77af4d368a679db0dec9a9120b6f` |
| `BOARD_BASELINE_T0_V04_N0.json` | `eca5b720911d78fa8285fd66baeb8359459e2b9f2c4da3b2fdfc6f63a1449ffd` |
| `u33_campaign.py` | `e9cec162b107f8df38206bc2b99e3b7cb0de2c29290a971d4940bb4a6e783927` |

### 2026-09-19 20:18+07 — DUP4 vs DUP16 XSim COMPLETE (PASS_XSIM)

`tb_u33_dup_begin.sv` dest=BRAM. DUP4 extra BEGIN then V-04 → MAG `0200015a` p1=BEGIN (same token as board). DUP16 extra first 16 words (64B) → `0200035a` R_SCHEMA, **not** board MAG. LATE extra BEGIN after GOLD → next CLEAR BUSY `c1ea50b5`, not MAG. HostTX after MAG: CLEAR n=0, retry ACK, V-04 n=0, nwritten=208 begin_n=1. PACK_ABI_24_24_PASS=NO. No overlay.

```
DUP4 MAG 0200015a p0=00800001 p1=00800001 p2=MAGIC
DUP16 OTHER 0200035a p0=BEGIN p1=MAGIC p2=00010001
LATE_PRE_GOLD then CLEAR BUSY
$finish 7978465 ns
```

| Artifact | SHA256 |
|---|---|
| `tb_u33_dup_begin.sv` | `842850c9615eac026b4cd153595609f75a920a4a09582b602a20212f47f1fa4a` |
| `xsim_u33dup.log` | `2296ae6a5b1f59e1b5b0ca7ea259b99cd3fddd17ce2e2c680ad81a16af0bf364` |
| `u33_dup_begin.log` | `e97b02e151cddf74207e6bd53605bff62e25aef1d94990520bbe9f6056aa8601` |
| `U33_DUP.md` | `6fa61fdd61499f21c7744cfc82a45da63244b53a86cbca0c1ec439fc4984da1d` |
| `HOSTTX.json` | `890f00a3f39eda3801e57c30c030d3ebe4310b151919c8c446c841a1fd8e922a` |

### 2026-09-19 20:23+07 — leftover dummy probe FAIL_BOARD

Reprogram frozen U33 End of startup HIGH. Probe: CLEAR ACK, idle n=0, dummy `00010001` n=0, first V-04 MAG `0200015a` (`MAG_CONCURRENT_WITH_V04`). Dummy itself did not MAG. PACK_ABI_24_24_PASS=NO. PROGRAM_PASS=NO. No overlay.

```
CLEAR1 ACK c1ea50a5
P2_DUMMY n=0 w0=00010001 begin_n=0
P3_V04 OTHER_0200015a n=4
```

| Artifact | SHA256 |
|---|---|
| `PROBE.json` | `16ddaa3625b8716b32a1976f103566532bc17dc4d3c2b501fe7f0fff9fd655e5` |
| `U33_PROBE.md` | `3498503c7cef0b2867461f13a2a63fed27c02e088e57d425c423067a5b37da71` |

### 2026-09-19 20:29+07 — uart_rx stop_hold COMPLETE (RTL read)

`uart_rx_word` STOP with `stop_hold` emits **one** word when `can_take`; bits during hold are not a second BEGIN. Extra BEGIN / DUP4 MAG from uart_rx **CONTRADICTED**. Next parent test was host write granularity.

| Artifact | SHA256 |
|---|---|
| `U33_OVERRUN_RTL.md` | `5c6c64c1b2af5e607ccaae9cfc85343fe1570085dc02894cd4eb001e2d87117e` |

### 2026-09-19 20:29+07 — word-flush nwp4p5 FAIL_BOARD (not MAG)

52×4-byte `write+flush` (not 208-byte bulk). Phase4 GOLD, r0 GOLD, r1 n=0-retry GOLD, r2 NAK **`0200035a` R_SCHEMA** (same class as XSim DUP16). Not board MAG `0200015a`. Word-flush changes NAK class; does not close Pack24. PACK_ABI_24_24_PASS=NO. No overlay.

| Artifact | SHA256 |
|---|---|
| `U33_WORDS.md` | `b67045a1ea699414bedd264e17479134862e4418962d6c15b9a3311465bdef12` |
| `WORDS.json` | `f5239ecc8bd360f58c5fe41f8fb19e242845cb543ee3f9a32b6e4fc521dd6b8a` |

### 2026-09-19 20:34+07 — GAP50 bulk nwp4p5 FAIL_BOARD mute

WAIT_AFTER_ACK=0.05 WAIT_AFTER_GOLD=0.05, original 208-byte bulk. Phase4 GOLD, r0 CLEAR n=0 retry GOLD, r1 GOLD, r2 V-04 **n=0 mute** (not MAG, not SCHEMA). 50ms settle changes NAK class to mute; does not yield 24/24. WAIT=0 path remains MAG. PACK_ABI_24_24_PASS=NO. PROGRAM_PASS=NO. No overlay.

| Artifact | SHA256 |
|---|---|
| `U33_GAP50.md` | `cb120dec9523b649c842cbb49a43672b676ba85fd7a15c43ec48286bad2a291d` |
| `CLEAR_V04_24.json` | `ccb9488724ee6c7d1f7116788be56f67eaa76b026738ec7ab954237ee7b212e5` |

### 2026-09-19 20:40+07 — reopen COM FAIL_BOARD first V-04 mute

Frozen U33. Intended reopen COM after each GOLD (USB leftover), bulk WAIT=0. Observed CLEAR1 ACK then V-04_0 **n=0 mute** 12.056 s (`stop=V04_0`). No GOLD, so reopen-after-GOLD did not run. Same first-V-04 mute class as exclusive T0. Not MAG. PACK_ABI_24_24_PASS=NO. PROGRAM_PASS=NO. No overlay.

| Artifact | SHA256 |
|---|---|
| `U33_REOPEN.md` | `49388f4a450be5b91278985d5de21c11106a56a9a01ea170aeace622809cb4d7` |
| `REOPEN.json` | `fe6482714150ba57e6a856756c8d0a64772f37500f4b16616fc3036c1ff3f07c` |

### 2026-09-19 20:42+07 — K1 TAP XSim COMPLETE (PASS_XSIM)

Observe-only TB `tb_u33_k1_tap.sv` dest=BRAM. Product SHA unchanged. TAP_P1 after CLEAR: n_p=0 (leftover-after-CLEAR not a valid beat). TAP_P3 V-04: class **G** BEGIN+MAGIC GOLD `010000a5`. TAP_DUP4 extra BEGIN: class **A** MAG `0200015a` p1=BEGIN. TAP after CLEAR only is the wrong MAG experiment; MAG class is the V-04 SOF window. BARRIER not locked. PACK_ABI_24_24_PASS=NO. No overlay.

```
TAP_P1 n_p=0
TAP_P3 class G p0=00800001 p1=3149414e GOLD
TAP_DUP4 class A p0=p1=00800001 MAG 0200015a
```

| Artifact | SHA256 |
|---|---|
| `tb_u33_k1_tap.sv` | `3a1a91289556629d08e71c7fbb52615bebaebca8990601d94258cd99160af865` |
| `u33_k1_tap.log` | `a277c9d6e36ce3ec7a67aacef2b19a93fcf841645710131b500f076164913871` |
| `K1_K2_K3_INDEPENDENT.md` | `d285ab2e5e7acf622274a4f9d701ba1123b947b2944291357adfc6bae77341f4` |




