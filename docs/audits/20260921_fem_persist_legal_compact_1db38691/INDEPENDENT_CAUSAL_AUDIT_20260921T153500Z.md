# Independent causal audit — FEM persist board 1db38691

LANGUAGE=EN  
RUN_ID: 20260921T153500Z  
AUDITOR: independent (this turn)  
PRIMARY_COMMIT: `b9072521c7f1f8e6cd110f642c6c51ffbb93b11a`  
PRIMARY_IDENTITY: `1db38691530304e929b437774ebba9a9122590d0a38685a0bba2f646c5b56668`  
C_RTL: `fem_lifecycle.v` sha256 `45b9b93073e3e08a2525a3fc1a96573d750bedcd26570cebefba5fa9514779ed` **unedited**  
UART_SMOKE.json sha256 `822f8750d1471c2f24ff7c9291d77d6ca8572f7a5ce88f399ff278ea366cd367`

This note does **not** inherit D `20260921T143303Z` or watch `20260921T144000Z` causal conclusions. Those files remain append-only evidence of a prior inference.

```text
FEM_PERSIST_PASS=NO
PROGRAM_PASS=NO
BOARD_PASS=NO
MIG_PASS=NO
TIMING_PASS=NO
PACK_ABI_24_24_PASS=NO
DEST_POKE=NO
RED_RESET=NO
C_RTL_EDIT=NO
PROGRAM_THIS_TURN=NO
```

## ARCHITECTURE LOCK

- Live C lifecycle: `Native_SymAI/CANON_BLUEPRINT/rtl/native_ai/memory/fem_lifecycle.v` (`N_RAW=4`, `CLUSTER_THRESHOLD=2`, `N_STABLE=3`).
- Unique silicon identity: `arty_d/UART_R2/build_fem_persist/uart_r2_fem_persist_candidate.bit` (not in git).
- Board smoke script that produced `UART_SMOKE.json`: `arty_d/UART_R2/fem_persist/uart_smoke_fem_persist.py` — **no FREP**.
- XSim persist discriminator: `tb_fem_persist_int.sv` — FING x4 **then FREP x3** then FCMP.
- Media: `fem_lifecycle` T2 4-bit words → `fem_t2_ce` → `fem_t2_adapter` → `fem_req_ui` (`FEM_BASE+{addr,2'b00}`) → `mig_ui32` → `mig_ui_mux` → generated `mig0`.
- DEST_READ returns one 128-bit UI beat as four 32-bit lanes.

---

## 1. Board sequence (`UART_SMOKE.json`)

All hops COM12, `tx_iso` 2026-09-21T21:33:42..44+07. No FREP record exists.

| Order | Stimulus | UART evidence | FEM meaning (from RTL, not from echo alone) |
|---|---|---|---|
| 0 | PROGRAM 1db38691 EOS HIGH | `program.log` Labtools 27-3164 | config event; `PROGRAM.DONE=NA` |
| 1 | CLEAR `44524743` | n=4 ACK `c1ea50a5` | pack debug CLEAR; not FEM reset |
| 2 | FOBS | 6 words | virgin: `life=L_NONE(7)` |
| 3 | FING arg `5` | echo `46494e47` | domain=1 TOOL, ctx=1 — **rejected** by §11.9 |
| 4 | FING arg `6` | echo | domain=2 HOST, ctx=1 — **rejected** |
| 5 | FING arg `4` | echo | domain=0 DUT, ctx=1 — **accepted** → L_RAW, n_raw=1 |
| 6 | FING arg `4` | echo | same DUT key — **accepted** → L_CLUSTERED, n_raw=2 |
| 7 | *(no FREP)* | absent in json and in `uart_smoke_fem_persist.py` | repair never requested |
| 8 | FCMP | echo `46434d50` | `cmp_start` then `cmp_done` on **guard reject** |
| 9 | DEST_READ `0x0200010` | 4-lane beat, lane0 ≠ `C0117ED0` | A_COMMIT slot unread-as-magic |
| 10 | FOBS | see §2 AFTER_CMP | L_CLUSTERED, cmp_result=NOT_RESOLVED |
| 11 | FRST | echo | FEM-only `rst_n` 8 UI cycles |
| 12 | DEST_READ `0x0200010` | same beat as step 9 | DRAM unchanged by FRST |
| 13 | FOBS | virgin again | volatile wipe |
| 14 | FREC | echo | recovery class OLD_VALID |
| 15 | FOBS | CLUSTERED restored, recov=0 | header/raw restore, not COMMITTED_NEW |

## 2. FOBS decode from raw LE bytes (not the smoke script's partial `ft` field)

Packing is `fem_ctrl_cdc` U_ACK:

```text
s0 = {13'h0, integrity_fault, compacted, unresolved, recover_state[1:0],
      life_state[2:0], n_raw[3:0], cmp_result[2:0], txn_step[3:0]}
s1 = {failure_total, failure_recent, success_after_repair, fem_feat}
s2 = {16'h0, key}
s3 = {ing_accepted, ing_done, rep_accepted, rep_done, cmp_done, rec_done,
      fem_busy, t2_err, wr_outstanding[15:0]}
s4 = {24'h0, op_u[2:0], 5'h0}   // 0xC0 => OP_OBS=6
```

`life_state`: 0 RAW, 1 CLUSTERED, 2 RESOLVED, 3 COMPACTED, 4 REOPENED, 7 NONE.

| Field | PRE | AFTER_CMP | AFTER_FRST | AFTER_FREC |
|---|---:|---:|---:|---:|
| raw s0 | `0000380f` | `0000091f` | `0000380f` | `0000090f` |
| raw s1 | `00000000` | `02020002` | `00000000` | `02020002` |
| raw s2 | `00000000` | `000070ea` | `00000000` | `000070ea` |
| raw s3 | `00000000` | `00800000` | `00000000` | `00000000` |
| txn_step | 15 idle | 15 idle | 15 | 15 |
| cmp_result | 0 | **1 NOT_RESOLVED** | 0 | 0 |
| n_raw | 0 | **2** | 0 | **2** |
| life_state | 7 NONE | **1 CLUSTERED** | 7 NONE | **1 CLUSTERED** |
| recover_state | 0 | 0 | 0 | **0 OLD_VALID** |
| unresolved | 0 | 0 | 0 | 0 |
| compacted | 0 | **0** | 0 | **0** |
| integrity_fault | 0 | 0 | 0 | 0 |
| failure_total | 0 | **2** | 0 | **2** |
| failure_recent | 0 | **2** | 0 | **2** |
| success_after_repair | 0 | **0** | 0 | **0** |
| fem_feat (=ft) | 0 | 2 | 0 | 2 |
| key | 0 | `70ea` | 0 | `70ea` |
| wr_outstanding | 0 | 0 | 0 | 0 |
| t2_err | 0 | 0 | 0 | 0 |
| ing_accepted (sticky) | 0 | 1 | 0 | 0 |

Note: prior smoke decoder used `ft = (s1>>16)&0xFF`, which is `failure_recent` in this packing. Here both ft and fr equal 2, so the printed `ft=2` was accidentally correct for `failure_total` as well.

`s3=0x00800000` after CMP is **sticky `ing_accepted`** from the last DUT FING, not `cmp_done` (bit 19). `cmp_done` is a pulse; FOBS does not go through U_WAIT.

## 3. Compaction preconditions (`fem_lifecycle.v`)

Exact guard:

```verilog
wire [2:0] guard = (life_state != L_RESOLVED) ? 3'd1 :
                   (success_after_repair < N_STABLE8) ? 3'd2 :
                   (failure_recent != 8'd0) ? 3'd3 : 3'd0;
```

`N_STABLE=3`. `L_RESOLVED=2`.

On `cmp_start` in `S_IDLE`:

```verilog
cmp_result <= guard;
if (guard != 3'd0) state <= C_DONE;
else begin txn_step <= 4'd0; state <= C_B0; end
```

`C_DONE` pulses `cmp_done` and sets `txn_step=4'hF`. **No T2 write on the reject path.**

How the board *would* have reached `L_RESOLVED` (XSim): two accepted DUT ingresses (`CLUSTER_THRESHOLD=2` → CLUSTERED) then **three** `rep_valid` with `life_state==L_CLUSTERED` then `L_RESOLVED`, each repair clearing `failure_recent` and incrementing `success_after_repair` to 3.

§11.9: `ing_domain != 0` increments `ingress_rejected` and does **not** touch lifecycle/T2.

## 4. Were those preconditions satisfied when FCMP issued?

**No. FACT.**

At AFTER_CMP FOBS: `life_state=CLUSTERED≠RESOLVED`, `success_after_repair=0<3`, `failure_recent=2≠0`. Any one of these fails the guard. The first clause already yields `guard=1`.

There is **zero** FREP in `UART_SMOKE.json` and **zero** `CMD_FREP` in `uart_smoke_fem_persist.py`.

## 5. Observed `cmp_result` vs RTL assignment

Comment and assignment: `cmp_result` `0 OK, 1 NOT_RESOLVED, 2 UNSTABLE, 3 RECENT, 4 CRC_FAIL`.

`1` is **only** written as `guard` when `life_state != L_RESOLVED` at `cmp_start`, or held until reset. `C_VERIFY` would overwrite with `4` only after the write/verify path. AFTER_CMP still shows `1` and `txn_step=15`, so this is the **idle-guard reject**, not CRC_FAIL.

UART FCMP echo means CDC `U_WAIT` saw `cmp_done`. That is **C_DONE**, which both success and guard-reject use. **Echo ≠ compact OK.**

## 6. Did the FSM enter the compaction write sequence?

**No. STRONG_INFERENCE from RTL + FOBS, not a C_B0 probe.**

`C_B0` is entered only if `guard==0`. Observed `cmp_result=1` is the stored guard. Therefore:

| State | Reached this run? |
|---|---|
| C_B0 | **No** |
| C_W0 / C_W1 / C_WCRC | **No** |
| C_VERIFY | **No** |
| C_COMMIT (`t2_we` + `A_COMMIT` + `C0117ED0`) | **No** |
| C_B3 / C_INDEX / C_RET* / C_B6 | **No** |
| C_DONE (reject) | **Yes** (needed for FCMP echo + `txn_step=F`) |

`compacted` stays 0; `n_raw` stays 2 (raw not retired). That matches never reaching `C_B6`/`C_RET*`.

## 7. Is missing `C0117ED0` at COMMIT sufficient to blame MIG/T2/addressing?

**No. CONTRADICTED as a first-cause claim.**

Absence of magic is the **expected media image** if `C_COMMIT` never ran. It does not distinguish MIG write failure from a lifecycle refuse.

Further, the **same DEST_READ beat** contains `000070ea` in lane2, which is exactly `hdr2_word={skill_id=0, skill_ver=0, key=70ea}` at `A_HDR2=6`. That word is written on the **ingress** path (`ING_HDR2`), not compact. So this run **did** complete at least one FEM T2 write through `mig0` at FEM_BASE, and DEST_READ lane mapping of that beat is consistent.

D `20260921T143303Z` H5/H6 (“compact did not dest-complete on mig0” / “UNKNOWN address/T2/MIG”) and NEXT_DECISIVE_EXPERIMENT “classify MEMORY\|T2\|ADDRESS\|MIG” are **the wrong next question**. Watch `T144000Z` inherited that UNKNOWN.

## 8. COMMIT write path — request/complete vs this run

`A_COMMIT` write only from `C_COMMIT`. This run did not enter `C_COMMIT`. Ingress T2 writes (HDR/HDR2/RAW) **did** use the same downstream stack.

| Boundary | Request | Accept / complete | COMMIT this run | Ingress this run |
|---|---|---|---|---|
| `fem_lifecycle` T2 | `t2_we`+`t2_addr`+`t2_wdata` while `busy` | `t2_ready` CE; write completes on `t2_we && t2_ready` | **not issued** | **issued** HDR/HDR2/RAW |
| `fem_t2_ce` | `c_busy` → HOLD; `c_req` pulse when `adp_ready` | `adp_ack` → PULSE (`t2_ready`) | **not for COMMIT** | **yes if C busy** |
| `fem_t2_adapter` | `c_req` latches into `req_valid` | `req_ready` then `rsp_valid` + txn/gen match → `t2_ack` | **not for COMMIT** | **yes** |
| `fem_req_ui` | `req_valid/write/addr/wdata` | `req_ready`; `rsp_valid` dest-complete | **not for COMMIT** | **yes** |
| `mig_ui32` | `mem_cmd_*` | UI `app_en/rdy` + wdf; then **readback** of lane | **not for COMMIT** | **yes** (HDR2 visible) |
| `mig_ui_mux` | B when `fem_busy` | `d_*` to media | **not for COMMIT** | **yes** |
| generated `mig0` | native 128b UI | calib + UI complete | **COMMIT not proven** | **HDR2 lane proven by DEST_READ** |

FIFO-empty is explicitly not complete (`PROXY_METRIC_FALSE_PASS_GUARD`).

## 9. `FEM_BASE` and `A_COMMIT=4`

```text
mem_addr = FEM_BASE + {req_addr, 2'b00}
FEM_BASE = 28'h0200000
A_COMMIT = 4  =>  0x0200000 + (4<<2) = 0x0200010
```

`mig_ui32`: `beat={addr[27:4],4'h0}`, `lane=addr[3:2]`. So `0x0200010` is beat `0x0200010`, lane 0.

Same beat:

| T2 addr | byte | lane | DEST_READ word | Observed |
|---|---|---:|---|---|
| 4 A_COMMIT | `0x0200010` | 0 | `rdata[31:0]` | `fffffff7` (not magic) |
| 5 A_INDEX | `0x0200014` | 1 | `rdata[63:32]` | `ff7fffff` |
| 6 A_HDR2 | `0x0200018` | 2 | `rdata[95:64]` | **`000070ea` = key** |
| 7 unused | `0x020001C` | 3 | `rdata[127:96]` | `00010000` |

**`0x0200010` is the correct DEST_READ address for COMMIT.** Lane2 matching HDR2 is STRONG_INFERENCE that this mapping is the one silicon used.

## 10. FRST → FREC

FRST (`fem_ctrl_cdc`): `fem_rst_hold` 8 UI cycles on `fem_rst_n` only. Does **not** `ck_rst`, does **not** reset MIG.

Volatile cleared (C `rst_n`): `life_state`, counters, `key`, `raw_valid`, `cmp_result`, `compacted`, `recover_state`, `integrity_fault`, FSM `S_IDLE`. AFTER_FRST FOBS matches reset values (`life=7`, all zeros).

Physical DRAM **intentionally not reset**. DEST_READ after FRST **bit-identical** to after CMP (`fffffff7 ff7fffff 000070ea 00010000`).

FREC: recovery always reads T2. `R_CLASS`:

- `rec_committed && !crc` → integrity_fault (not seen)
- `rec_committed` → `recover_state=2` COMMITTED_NEW (not seen)
- else `rec_crc_valid` → 1 CANDIDATE_NEW (not seen)
- else **`recover_state=0` OLD_VALID**, restore **volatile from `rd_hdr`/`rd_hdr2`/`raw_valid`**, `R_DONE` (no compact roll-forward)

AFTER_FREC matches OLD_VALID restore of the **ingress header** (CLUSTERED, ft=2, fr=2, sar=0, key=70ea, n_raw=2, compacted=0, recov=0).

Those values **do not require persistent COMMIT**. They **do** require persistent A_HDR / A_HDR2 / RAW valid bits across FRST — i.e. **some** T2 media survived FEM-only reset. That is weaker than the persist discriminator (COMMITTED_NEW).

## 11. Silicon vs prior XSim stimulus

XSim `tb_fem_persist_int.sv`: FOBS virgin → FING 5,6,4,4 → **FREP `0x0111` ×3** → FOBS expect `life=2` → FCMP → FOBS `life=3` compacted → DEST_READ COMMIT → FRST → DEST_READ COMMIT → FREC → recov=2.

Isolated XSim `drive_to_resolved`: tool/host ingress (reject) + two DUT + **repair ×3** then `cmp_start`, expect `cmp_result=0`.

Silicon script omitted **all three FREP**, omitted the mid-sequence FOBS RESOLVED check, then FCMP. CLEAR is extra vs XSim (pack wipe); it occurred **before** FING, so it does not explain CLUSTERED-after-FING.

## 12. FIRST DIVERGENCE (XSim persist vs this silicon experiment)

**First stimulus divergence:** after the second DUT FING, XSim issues FREP; silicon issues FCMP.

**First lifecycle divergence:** silicon remains `L_CLUSTERED` with `sar=0`; XSim is `L_RESOLVED` with `sar>=3` and `failure_recent=0` **before** `cmp_start`.

DEST_READ ≠ `C0117ED0` is a **later symptom** of never entering `C_COMMIT`.

## 13. Classification

**FIRST_DIVERGENCE class: TEST HARNESS**

Secondary (not first):

- CONTROL/LIFECYCLE — FEM correctly refused compact (`cmp_result=1`). Not a silicon bug on this evidence.
- FEM MEMORY STATE — CLUSTERED raw/header present; COMMIT slot never written.
- T2 ADAPTER / MIG WRITE / MIG READBACK / ADDRESS MAPPING — **not implicated for COMMIT**; HDR2 lane argues mapping+ingress write+readback worked.
- CDC — BIT_OK CDC sample is a **prior** implementation issue, already closed for this identity; it does not explain `cmp_result=1`.

## 14. Smallest next experiment (no C edit, no new bit unless this identity is lost, no DEST_POKE, no red RESET)

On **current** `1db38691` COM12, **do not CLEAR** after setup (or CLEAR once then wait calib):

1. FOBS — expect NONE.
2. FING 5, 6, 4, 4 (same args).
3. **FREP `0x00000111` three times** (`skill_id=0x11`, `skill_ver=0x01`).
4. FOBS — **gate**: `life_state==2`, `success_after_repair>=3`, `failure_recent==0`, `cmp_result` ignore. **STOP** if gate fails (still CONTROL/HARNESS).
5. FCMP; FOBS — expect `cmp_result==0`, `compacted==1`, `life==3`, `n_raw==0`.
6. DEST_READ `0x0200010` — expect lane0 `C0117ED0` (lane2 may still hold hdr2/key).
7. FRST (FEM-only); DEST_READ still magic; FREC; FOBS `recover_state==2`.

If step 4 passes and step 5 still `cmp_result=1`: reclassify CONTROL.  
If step 5 compact OK and step 6 still no magic: **then** MEMORY/T2/MIG/ADDRESS.  
If step 6 magic and step 7 recov≠2: recovery/readback.

## 15. Epistemic table

| Claim | Class | Evidence |
|---|---|---|
| Identity 1db38691 programmed EOS HIGH | FACT | `program.log` 27-3164; PROGRAM.txt SHA; independent hashes in audit dir |
| `PROGRAM.DONE` recorded | FACT | NA |
| CLEAR ACK COM12 | FACT | `c1ea50a5` |
| Opcode echo of FING/FCMP/FRST/FREC/FOBS | FACT | UART_SMOKE.json |
| FREP issued on silicon this run | CONTRADICTED | json + `uart_smoke_fem_persist.py` |
| Compact preconditions held at FCMP | CONTRADICTED | life=1, sar=0, fr=2 vs guard |
| `cmp_result=1` means NOT_RESOLVED | FACT | `fem_lifecycle.v` guard + comment |
| C_COMMIT ran | CONTRADICTED | guard reject; compacted=0; n_raw=2 |
| DEST_READ `0x0200010` lane0 is COMMIT_MAGIC | CONTRADICTED | `fffffff7` |
| `0x0200010` is A_COMMIT byte address | FACT | `fem_req_ui` + `A_COMMIT=4` |
| Lane2 `000070ea` is A_HDR2 key | STRONG_INFERENCE | `hdr2_word` packing + lane map |
| Ingress T2 write reached mig0 and DEST_READ | STRONG_INFERENCE | HDR2 in same beat |
| FRST wipes C volatile, not DRAM | FACT | FOBS NONE vs DEST_READ unchanged |
| FREC restored CLUSTERED from T2 header/raw | STRONG_INFERENCE | AFTER_FREC vs AFTER_CMP fields; recov=0 |
| FREC COMMITTED_NEW (`recov=2`) | CONTRADICTED | recov=0, compacted=0 |
| Missing magic proves MIG/T2/address fail | CONTRADICTED | compact never armed |
| `FEM_PERSIST_PASS` | CONTRADICTED as stamp | discriminator not run |
| mig0 COMMIT dest-complete | NOT_TESTED | C_COMMIT not entered |
| Full T2 adapter COMMIT handshake | NOT_TESTED | same |
| Whether FREP×3 on this bit reaches RESOLVED | NOT_TESTED | next experiment |
| XSim 24/24 pack ABI | NOT_TESTED this run | `PACK_ABI_24_24_PASS=NO` |
| Why `PROGRAM.DONE` is NA | UNKNOWN | Labtools vs Tcl property |
| Exact DRAM contents of unused lane3 `00010000` | UNKNOWN | not in T2 map |
| Whether CLEAR wiped FEM_BASE before FING | UNKNOWN | FING after CLEAR rewrote HDR2 anyway |

## 16. Claim ceiling (unchanged)

```text
FEM_PERSIST_PASS=NO
PROGRAM_PASS=NO
BOARD_PASS=NO
MIG_PASS=NO
TIMING_PASS=NO
PACK_ABI_24_24_PASS=NO
```

BIT_OK WNS=+0.737 remains `PASS_IMPLEMENTED` only, not `TIMING_PASS`.
