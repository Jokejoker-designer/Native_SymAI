# UART_ROOT_CAUSE_AND_RESILIENCE_R2 — STATUS

TASK: UART_ROOT_CAUSE_AND_RESILIENCE_R2  
OWNER: AGENT_D  
RUN_ID: 20260917T142300Z  
PROGRAM: SRAM last programmed 2026-09-18T09:52:07+07 with `UART_R2/build_u3/uart_r2_u3_candidate.bit` sha256 `17494f2c…` (End of startup HIGH, JTAG `210319BE776EA`). **PROGRAM_PASS=NO**. Identity H / m4_mig / freeze DCPs not overwritten. Other-branch VERIFY_OK n=46.  
ETHERNET: DEFERRED / ON_HOLD (not deleted, not implemented)

This run is the **isolated** campaign under `D:/FPGA/arty_d/UART_R2/`.
U1 was derived from H-class `uart_rx_word` `638f9719…`, not from the mixed
PACKAGE live file `ab1b9571…`. U3 adds physical MARK on `idle` (PACKAGE live
`idle` still omits `rx_d` / `stop_hold` / `need_mark`).

Identity H bit `cf62102f…` / H DCP / H19 / H20 JSON / B gold / FE256 gold /
freeze DCPs: **not overwritten**.

## Claim ceiling (unchanged)

```text
UART_H_ROOT_CAUSE = UNKNOWN
PACK_ABI_24_24_PASS = NO
M1_BOARD_CLOSED = NO
BOARD_PASS = NO
ASTRA_PASS = NO
FE256_PASS = NO
MIG_PASS = NO
TIMING_PASS = NO
H19_SILICON_ROOT = UNKNOWN
H20_SILICON_ROOT = UNKNOWN   # PASS_XSIM mechanism only
```

## Candidate hashes (this run)

| Artifact | SHA256 |
|---|---|
| U1 `uart_rx_word.sv` | `9433dcc179f7ceac9e54b0d1b765342285907f8a925c93a76c01827c7474a522` |
| U2 `uart_rx_word.sv` | `c7ebbf953a3b22b8661422b0896bbe520d59104657ae52f952aff6fabd657a45` |
| U3 `uart_rx_word.sv` (current RX candidate) | `79fa752f02e2a6994682c0e96cde2daee5d6021a632ad2321ef56d90e2fc7367` |
| U6 `uart_fe256_host.sv` (copy, not product-top wire) | `9e7682169bba231deb273b04d6de8a862058f01a0a668653a25156ce15220f79` |
| `word_fifo32.sv` BRANCH_A unchanged | `5d35ad1eac6bf259168a7e8e8137f4404abb9064aafddef02c3e858e221e7363` |
| H-class snapshot | `638f9719732f971828205c43b9894cc2b93529fb6e1e39ab90f6970ca0790823` |

## Split status (do not collapse)

| Line | Status | Evidence layer |
|---|---|---|
| UART_PHYSICAL_RX_STATUS | PASS_XSIM 8N1 + BREAK + short-LOW glitch recovery; silicon UNKNOWN | U2 TB finish 285825 ns; log `f3ce3d9b…` |
| UART_FRAMING_STATUS | PASS_XSIM STOP=1 required; malformed never committed | U2 |
| UART_HANDSHAKE_STATUS | PASS_XSIM words_dropped=0 on U1 and on U3 composition; w_ready=0 is not a fault | U1 log `82baaeb2…` 441715 ns; U1-on-U3 `ad0714ae…` |
| UART_FIFO_STATUS | PASS_XSIM existing word_fifo32 DEPTH=128 BRANCH_A; no vendor FIFO | U5 log `2f2222da…` 7255 ns |
| UART_CLEAR_STATUS | PASS_XSIM logical partials destroyed; rx_s/rx_d preserved; idle requires MARK | U3 log `fce43e7a…` 281995 ns |
| UART_H19_STATUS | TIMEOUT_NOT_JUSTIFIED; leftover survives 50-bit idle; silicon UNKNOWN | U4 log `49b5e49b…` 540795 ns |
| UART_H20_STATUS | PASS_XSIM causal class held-not-dropped; H-class TB still drops; not silicon root | U1 + `xsim_h20_hclass` `44b668cd…` |
| PACK24_BOARD_STATUS | NOT_RUN (stopped) | T1 ACK then V-04 n=0; no B-gold token |
| M1_RUNTIME_PACK_STATUS | PASS_XSIM_CONTRACT_AUDIT (S_COMMIT / S_REJECT); not board | U6 + pack_loader RTL |
| ACTIVE_GENERATION_ATOMICITY_STATUS | PASS_XSIM_RTL S_COMMIT single assign; VALIDATION_CLEAR resets loader gen | pack_loader |
| QUERY_GENERATION_CONSISTENCY_STATUS | PASS_XSIM snapshot-at-accept + POLICY B; M4 top snapshot **unwired**; Q4 full pack NOT_RUN in U6 TB | U6 log `f007a4a5…` 695 ns |

## Per-phase distillation

### U0 FREEZE
OBSERVATION: Identity H and H-class RX frozen. Dataflow UART→word→CLEAR sniff→FIFO128→query host / CDC→pack_loader S_COMMIT. RTL_MODIFIED=NO in U0.  
EXPECTED_BEHAVIOR: no RTL in U0.  
HYPOTHESIS: n/a.  
CHANGE: freeze files only.  
FALSIFIER: overwrite of H artifacts.  
BEFORE/AFTER: PRODUCT_RTL_CHANGED=NO this phase.  
FIRST_DIVERGENCE: none.  
EVIDENCE: `U0_FREEZE.md`, `U0_DATAFLOW.json`, `CLAIM_CEILING.txt`.  
ROOT_CAUSE_STATUS: UART_H_ROOT_CAUSE=UNKNOWN.  
GENERAL_RULE: freeze identity before ingress patches.  
DECISION_PROCEDURE: new identity per functional RTL change.  
STRUCTURAL_GUARD: do not overwrite H / gold / freeze DCPs.  
TRANSFER_TO_ETHERNET: freeze the transport identity; ON_HOLD is not deletion.

### U1 H20 handshake
OBSERVATION: H-class 4th STOP with `w_valid && !w_ready` drops the word and clears `bix`. U1 `stop_hold` conserves. Case3 hold_cycles=137 both words kept. Randomized 3-word burst n_got=3 e0=W0. Composition with U3 still PASS.  
EXPECTED_BEHAVIOR: completed word is owned or handed off; w_ready=0 is not a fault.  
HYPOTHESIS: H20 class is silent drop at 4th STOP — CONFIRMED PASS_XSIM; silicon overlap UNKNOWN.  
CHANGE: hold until `can_take`. No extra FIFO. No timeout/CLEAR/STOP in U1.  
FALSIFIER: words_dropped>0 or W1 lost after drain.  
BEFORE: drop. AFTER: hold then emit.  
FIRST_DIVERGENCE: 4th STOP with output occupied.  
EVIDENCE: `xsim_u1` `82baaeb2…`; H-class still drops `44b668cd…`.  
ROOT_CAUSE_STATUS: PASS_XSIM handshake class. Not BOARD. Not H20_SILICON_ROOT.  
GENERAL_RULE: no state advance without handshake or owned storage.  
DECISION_PROCEDURE: if completed && !owned → hold; later start-bit overrun is not silent drop of the owned word.  
STRUCTURAL_GUARD: G-U1-NO-SILENT-DROP.  
TRANSFER_TO_ETHERNET: same valid/ready ownership at complete-frame boundary.

### U2 framing
OBSERVATION: STOP sample unused in H-class. U2 STOP=0 pulses `framing_error`, no commit, no bix advance, `need_mark` recover. Cases: 8N1, STOP-low, recover, BREAK, repeated malformed then valid, short LOW glitch.  
EXPECTED_BEHAVIOR: MALFORMED_FRAME never becomes VALID_DATA_BYTE.  
HYPOTHESIS: STOP-low was a silent data path — CONFIRMED PASS_XSIM.  
CHANGE: STOP check + need_mark + framing_error. No timeout.  
FALSIFIER: STOP-low emits a word.  
BEFORE: STOP-low committed. AFTER: ferr, recover.  
FIRST_DIVERGENCE: STOP sample `rx_d==0`.  
EVIDENCE: `xsim_u2` `f3ce3d9b…` finish 285825 ns.  
ROOT_CAUSE_STATUS: PASS_XSIM framing. Not silicon H19.  
GENERAL_RULE: frame valid ≠ STOP ignored; CRC ≠ truth.  
DECISION_PROCEDURE: sample STOP once; hold path must not re-sample.  
STRUCTURAL_GUARD: G-U2-STOP-MUST-BE-ONE.  
TRANSFER_TO_ETHERNET: FCS/frame validity ≠ session payload commit.

### U3 CLEAR
OBSERVATION: flush zeros logical assembler; FIFO flush zeros used; host/CDC/loader rst destroy partials. Physical `rx_s/rx_d` not flushed. `idle` now requires MARK (`rx_d`) so CLEAR QUIET cannot fire while the line is low. Preload bix=1/2/3, pending output, FIFO, partial query, CDC, partial BEGIN: after CLEAR no pre-CLEAR mix. First post-CLEAR word is FRESH.  
EXPECTED_BEHAVIOR: CLEAR destroys logical partial transaction state; preserve PHY sample.  
HYPOTHESIS: existing flush/rst is sufficient if idle is physical — CONFIRMED PASS_XSIM. PACKAGE live `idle` still logical-only (gap vs this candidate).  
CHANGE: `idle` += `!stop_hold && !need_mark && rx_d`; flush sets `need_mark <= !rx_d`. No timeout.  
FALSIFIER: pre-CLEAR byte combines with post-CLEAR; idle true while rx_d=0.  
BEFORE: idle true during flush-while-low. AFTER: idle false until MARK.  
FIRST_DIVERGENCE: flush while line low.  
EVIDENCE: `xsim_u3` `fce43e7a…` 281995 ns.  
ROOT_CAUSE_STATUS: PASS_XSIM CLEAR boundary.  
GENERAL_RULE: FIFO empty ≠ destination complete. VALIDATION_CLEAR ≠ failed-pack (failed pack must keep generation N).  
DECISION_PROCEDURE: preload every partial phase then CLEAR.  
STRUCTURAL_GUARD: G-U3-CLEAR-LOGICAL-PARTIAL.  
TRANSFER_TO_ETHERNET: session abort drops partial records, not necessarily PHY idle flops.

### U4 H19 / idle-gap
OBSERVATION: extra byte + continuous stream shifts (`b2c3d400`). extra byte + 50 bit-time gap still leftover (`22334400`). Valid burst, paced 20-bit, paced 50-bit OK without timeout. H10 paced 0.5 ms/byte vs 115200 char ~86.8 us vs Windows/Python ms gaps: **no safe timing separation**.  
EXPECTED_BEHAVIOR: do not call timeout an H19 fix without separation.  
HYPOTHESIS: idle-gap timeout would recover leftover — REJECTED as product fix.  
CHANGE: no timeout RTL.  
FALSIFIER: a proven gap strictly > max legal inter-byte and < min OS gap. Not shown.  
BEFORE/AFTER: timeout still absent.  
FIRST_DIVERGENCE: extra 0x00 vs aligned word remains leftover assembler, not solved by timeout.  
EVIDENCE: `xsim_u4` `49b5e49b…`; H10 paced historical.  
ROOT_CAUSE_STATUS: TIMEOUT_NOT_JUSTIFIED. H19 silicon SOURCE UNKNOWN.  
GENERAL_RULE: EXTRA_BYTE_WITH_CONTINUOUS_STREAM ≠ PARTIAL_WORD_WITH_IDLE_GAP.  
DECISION_PROCEDURE: measure burst/paced/OS gaps before adding timers.  
STRUCTURAL_GUARD: G-U4-NO-TIMEOUT-WITHOUT-SEPARATION.  
TRANSFER_TO_ETHERNET: inter-packet gap ≠ semantic; do not use idle timers as the integrity layer.

### U5 FIFO
OBSERVATION: `word_fifo32` DEPTH=128 width=32 clk100 LUTRAM. FULL used=128 wr_ready=0; almost-full 127; simul RW 16/16; stall drain 32/32; flush; reset. Branch A. No second FIFO. No vendor FIFO.  
EXPECTED_BEHAVIOR: prove existing FIFO or replace, not both.  
HYPOTHESIS: existing FIFO sufficient for bounded host window — PASS_XSIM occupancy/order. Infinite UART burst cannot be guaranteed (no RTS/CTS).  
CHANGE: none to FIFO RTL.  
FALSIFIER: reorder or used mismatch.  
EVIDENCE: `xsim_u5` `2f2222da…`.  
ROOT_CAUSE_STATUS: PASS_XSIM BRANCH_A.  
GENERAL_RULE: pacing is not correctness; need MAX_HOST_BURST ≤ 128 **or** Pack/ACK + 8-word query window.  
DECISION_PROCEDURE: product host already ACK-windows packs; do not stack FIFOs.  
STRUCTURAL_GUARD: G-U5-ONE-FIFO-PLUS-HOST-WINDOW.  
TRANSFER_TO_ETHERNET: one elastic buffer + credit/ACK window.

### U6 transport/compute
OBSERVATION: pack_loader writes via `slot_base`, drains `wr_outstanding`, sentinel, **one FF** `S_COMMIT: active_generation <= man_generation`. S_REJECT leaves generation. Partial BEGIN keeps UNSET. uart_fe256_host gates `q_bytes` on `q_valid` and snapshots at 8th word. M4 candidate top does **not** CDC-wire `active_generation` into the host. Query walk uses BRAM directory, not DDR pack slot. Concurrent load+reason NOT_PROVEN. POLICY **B** serialize (`pack_lock` + `pack_quiescent`).  
EXPECTED_BEHAVIOR: RECEIVE→STAGE→VALIDATE→COMMIT→REASON. Preserve loader.  
HYPOTHESIS: loader already supplies staging atomicity — CONFIRMED for Pack path. Query snapshot on product top incomplete (unwired).  
CHANGE: no product-top edit this run (would be a new bit). Host copy lives in `UART_R2/u6/`.  
FALSIFIER: q_valid with partial q_bytes; failed pack mutating generation.  
EVIDENCE: `xsim_u6` `f007a4a5…`; pack_loader S_COMMIT. Q4 = historical PACK_ABI24_MIG_DUT_XSIM, not this TB.  
ROOT_CAUSE_STATUS: PASS_XSIM_CONTRACT. Not M1_BOARD_CLOSED.  
GENERAL_RULE: LOADED ≠ ACTIVE; FIFO_EMPTY ≠ DEST_COMPLETE; CRC ≠ TRUE; ONE QUERY ONE SNAPSHOT.  
DECISION_PROCEDURE: patch missing edge only; serialize R1.  
STRUCTURAL_GUARD: G-U6-NO-REASON-FROM-UNCOMMITTED.  
TRANSFER_TO_ETHERNET: deliver complete validated command/record into the same ingest contract.

### U7 transport boundary
See `U7_TRANSPORT_BOUNDARY.md`. Ethernet remains ON_HOLD.

## Board / M1 / query campaign

UART_R2_U3_BOARD_TEST 20260918T025207Z. Evidence only under `build_u3/board_test/` (plus `run_a_contaminated_break/`). Identity H `m4_mig_clear/PROGRAM.txt` not written (mtime 2026-09-17).

T1: ACK `c1ea50a5` when COM stays closed 12 s after program, then 0.25 s drain, CLEAR immediately.  
T2 H11: first extra CLEAR n=0 (same COM).  
T4: PA24-V-04 52 words after ACK → n=0 for 12 s; CLEAR2 n=0.  
T9 Pack24 vs B gold: **NOT_RUN** (stop rule: CLEAR/Pack not ACK).  
T7 H20: NOT_RUN. T8 H19 extra-byte: not reproduced on a live ACK.  
T5/T6 BREAK on run_a then mute/UNSUP — do not treat as Pack result.

PACK24_BOARD = NOT_RUN  
(required later wording if closed: 24/24 EXACT MATCH TO AGENT-B GOLD, including expected REJECT)

See `build_u3/board_test/FIRST_DIFFERENCE.md`, `LIKELY_CAUSAL_CLASS.md`, `ROOT_CAUSE_STATUS.md`, `NEXT_ACTION.md`.

## 12 key lessons

1. TRANSPORT_RECEIVED ≠ SEMANTICALLY_ACTIVE
2. FIFO_EMPTY ≠ DESTINATION_COMPLETE
3. CRC_VALID ≠ SEMANTICALLY_TRUE
4. READY_LOW ≠ PROTOCOL_FAILURE
5. NO STATE ADVANCE WITHOUT HANDSHAKE OR OWNED STORAGE
6. PARTIAL_QUERY ≠ QUERY
7. LOADED_GENERATION ≠ ACTIVE_GENERATION
8. ACTIVE_GENERATION_SWITCH MUST BE ATOMIC (S_COMMIT)
9. ONE QUERY MUST OBSERVE ONE GENERATION SNAPSHOT (port exists; M4 top unwired)
10. PHYSICAL TRANSPORT DELAY MAY CHANGE LATENCY BUT MUST NOT CHANGE SEMANTIC RESULT
11. PACK LOAD AND REASONING MAY BE DECOUPLED; CONCURRENCY OPTIONAL; SERIALIZE FOR R1
12. UART LESSONS TRANSFER TO ETHERNET AS STRUCTURAL GUARDS, NOT ASSUMED ROOT CAUSES

## Narrowest supported claim

PASS_XSIM on UART handshake (no silent completed-word drop), STOP framing, CLEAR logical partials with physical-MARK idle, FIFO occupancy, idle-gap measurement (timeout not added), and pack/query uncommitted-state unit checks.

NOT claimed: silicon H19/H20 root, PACK_ABI_24_24_PASS, BOARD_PASS, PROGRAM_PASS, M1 board close, ASTRA_PASS, FE256_PASS, MIG_PASS, TIMING_PASS, Ethernet.
