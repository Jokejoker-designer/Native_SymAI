# Adversarial second-pass — FEM persist 1db38691

LANGUAGE=EN  
RUN_ID: 20260921T154800Z  
ROLE: adversarial (falsify, not confirm)  
IDENTITY: `1db38691530304e929b437774ebba9a9122590d0a38685a0bba2f646c5b56668`  
COMMIT: `b9072521c7f1f8e6cd110f642c6c51ffbb93b11a`  
PRIOR_AUDIT: `INDEPENDENT_CAUSAL_AUDIT_20260921T153500Z.md`

```text
FEM_PERSIST_PASS=NO
PROGRAM_PASS=NO
BOARD_PASS=NO
MIG_PASS=NO
TIMING_PASS=NO
PACK_ABI_24_24_PASS=NO
RTL_EDIT=NO
PROGRAM_THIS_TURN=NO
DEST_POKE=NO
```

## What was attacked

The two-paragraph working conclusion (no compact attempt; FREP omitted; FRST/FREC as candidate T2 evidence).

## Attacks that failed to reverse paragraph 1

Source used by unique synth: `94_synth_uart_r2_fem_persist.tcl` `read_verilog` of `D:/FPGA/Native_SymAI/CANON_BLUEPRINT/rtl/native_ai/memory/fem_lifecycle.v` sha256 `45b9b930…`. Netlist-in-bit not independently extracted (**UNKNOWN** bitstream↔source at LUT level). Encodings in that file:

```text
L_CLUSTERED = 3'd1
L_RESOLVED  = 3'd2
cmp_result  0 OK  1 NOT_RESOLVED  2 UNSTABLE  3 RECENT  4 CRC_FAIL
```

`state <= C_B0` occurs **once**, in `S_IDLE` `cmp_start` when `guard==0`. `C_W0` only from `C_B0`. `C_COMMIT` only from `C_VERIFY` after `rec_crc_valid`. `default: state <= S_IDLE`. No RTL path into compact-write states when `guard != 0`. **FACT** on this source.

`C_DONE` always `cmp_done <= 1`. CDC `U_WAIT` exits only on `cmp_done`. UART TX of FCMP is opcode-only after `done100`. **UART echo on rejected FCMP is required by RTL, not a bug.** `cmp_result` is **not** in that echo.

FOBS after FCMP is a **new** `OP_OBS` sample of live C pins at `U_ACK`, not the FCMP TX payload. Correspondence to that FCMP is **STRONG_INFERENCE**, not a cycle-exact FACT: `cmp_result` is held until `rst_n` or the next `cmp_start`; FOBS_PRE was 0; ingress does not assign `cmp_result`; only `cmp_start` / `C_VERIFY` / reset do; DEST_READ between FCMP and FOBS does not touch C. 0→1 with a single FCMP in between. `fem_ctrl_cdc` uses `rst_ui_n`, not `fem_rst_n`.

Zero FREP: no `46524550` in `UART_SMOKE.json`; `uart_smoke_fem_persist.py` never defines `CMD_FREP`. **FACT.**

DEST_READ `0x0200010` lanes are not `C0117ED0` / `00000001` / compact `p_w0`. **No board evidence of a compaction T2 write.** Coverage gap: A_W0/A_W1/A_CRCW live at beat `0x0200000`, **not read** this run (**NOT_TESTED** empirically). That gap does **not** re-open `C_B0` against this source.

## Attacks that refine, not reverse, paragraph 2

FRST: `fem_rst_n = rst_ui_n && !fm_rst_hold` clocks **entire** `fem_on_mig` (lifecycle + `fem_t2_ce` + adapter + `fem_req_ui`). Adapter `dest_hold` **is** cleared. MIG/DDR/`rst_ui_n` **not** cleared. **FACT.**

`fem_t2_ce.dest_hold` and `fem_t2_adapter` request/response FFs **are** cleared on `rst_n`. FREC cannot replay adapter RAM. It must issue new T2 reads. Restore of `n_raw=2` after AFTER_FRST `n_raw=0` requires `R_RRAWC` `raw_valid[i] <= t2_rdata[16]` from **post-reset** reads. CDC/UART/host do not hold `raw_valid`. **Leftover C FFs CONTRADICTED** by AFTER_FRST FOBS `life=7 n_raw=0 key=0`.

This-run isolation is incomplete: there was **no DEST_READ before FING**. `000070ea` surviving FRST is FACT for that lane; attributing the write uniquely to this smoke's FING (versus a prior same-key occupant of FEM_BASE) is **STRONG_INFERENCE**. Pack CLEAR is not shown to wipe FEM_BASE.

HDR2 `000070ea` in DEST_READ **after FRST** (bit-identical beat) is **direct DRAM** via dest_diag, which does **not** use `fem_rst_n`. That is stronger than FREC for **that word**.

`hdr2_word={skill_id,skill_ver,key}` with skill 0 → `000070ea`. Alternatives checked:

| Candidate | Expected word | Beat/lane | Match? |
|---|---|---|---|
| A_HDR2 | `000070ea` | `0x0200010` L2 | yes |
| A_COMMIT | `C0117ED0` | L0 | no (`fffffff7`) |
| A_INDEX | `1` | L1 | no |
| A_W0 `p_w0` | `70ea0200` | beat `0x0200000` L1 | not this DEST_READ |
| RAW `{15'0,1,key}` | `000170ea` | `0x0200020+` | no (`000070ea` lacks bit16) |
| A_HDR | `00020201` | beat `0x0200000` L0 | no |

Lane-reversal would not put exact `hdr2` in L2 while L0 looks unwritten. Coincidence of 32-bit `000070ea` with live FOBS key is not a serious alternative.

**Too strong:** “Pre-compaction FEM media persistence across FEM-only reset is causally observed on silicon” as a global FEM_BASE claim. DEST_READ covered **one beat**. A_HDR/A_RAW0 were **not** DEST_READ.

**Narrower justified claim:** After FRST, dest_diag still returned `000070ea` at A_HDR2’s lane in beat `0x0200010` (FACT). FREC then restored CLUSTERED counters/key/`n_raw=2` matching the pre-FRST FOBS and requiring T2 RAW valid-bit readback (STRONG_INFERENCE). COMMIT slot was never written; COMMIT persistence **NOT_TESTED**.

## Earliest stimulus vs first causal divergence

XSim: `ck_rst`, FOBS, FING 5/6/4/4, **FREP×3**, FOBS, FCMP.  
Silicon: **CLEAR**, FOBS, FING 5/6/4/4, **FCMP**.

**Earliest opcode difference: CLEAR.** It does not explain CLUSTERED-after-FING or `cmp_result=1`. **First causal divergence for compact: FREP vs FCMP.** The T153500Z wording “first stimulus divergence = FREP” is slightly loose, not causally wrong.

## D T143303Z / watch T144000Z

FIRST_DIVERGENCE=DEST_READ and ROOT=UNKNOWN MEMORY|T2|ADDRESS|MIG are **contradicted as the current implication** for this dataset. DEST_READ remaining non-magic is a **consistent later symptom** of `C_COMMIT` never running. Those exports stay append-only; their dest-miss ROOT is not defensible once FOBS `cmp_result=1` and missing FREP are used.

## Next experiment — real flaws

1. **FCMP echo does not carry `cmp_result`.** The proposal “FCMP → require cmp_result==0” is non-causal unless an FOBS (or equivalent live sample) is inserted after FCMP.  
2. **`cmp_result==0` is also reset/virgin.** Must also require `compacted==1` and `life_state==L_COMPACTED(3)` (XSim does).  
3. **Clean state underspecified.** Live C is still CLUSTERED from this smoke; CLEAR wipes pack DRAM but **not** C and is **not shown** to wipe FEM_BASE. CLEAR then FING without FRST → T2/C split-brain. Need **FRST after CLEAR**, then FOBS virgin, then FING.  
4. FREP UART echo **≠** `rep_accepted` (RAW repair still `rep_done`). Keep the FOBS gate after FREP×3.  
5. Do not CLEAR/FRST/red RESET between FREP and DEST_READ.  
6. Optional: DEST_READ `0x0200000` (HDR/W0) as well as `0x0200010`. Pre-FING DEST_READ of `0x0200010` would close this-run isolation.  
7. Mute/timeout class if pack not idle so `cmp_start` never issues.

No new bitstream required for FREP: `fem_ctrl_cdc` OP_REP is in the unique tree that built `1db38691`. Re-**program that SHA** only if SRAM identity is lost — not a new build.

## Verdict

Paragraph 1 (no legal compact; missing magic ≠ MIG-first) **not falsified**.  
Paragraph 2 already said **candidate**; upgrading it to global “causally observed FEM_BASE persist” **would** require revision. The quoted working conclusion **survives** if persistence stays scoped as above.

ADVERSARIAL_VERDICT: WORKING_CONCLUSION_SURVIVES_ADVERSARIAL_AUDIT
