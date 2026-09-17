# NATIVE_AI_REASONING_EXPERIENCE_V1_CURSOR_OWNER_20260917T092700Z

```text
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: OWNER-OBSERVE-PATH-METHOD
RUN_ID: 20260917T092700Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: Observe path for first_pack_word+bix must be a named non-H identity.
  Sample pack-accepted word after CLEAR, and bix in the ACK-to-first-pack gap.
  UART-byte dump cannot distinguish H20. ILA needs non-BASIC license.
  H20 remains classifier-only. No RTL this turn. GUARD_ADDED=NO.
RUN_PROVENANCE:
  Prior H capture D_IDENTITY_H_FIRST_WORD_BIX.json; D_H_ILA_A.json;
  h_ila_a_cap.sv; tcl 34_ila_m4_mig_clear.tcl; Vivado 2026.1 BASIC 12-29205.
OBSERVATION:
  FACT — identity H has no ILA/dump.
  FACT — create_debug_core blocked BASIC.
  FACT — H-ILA-A dump bit is a different P&R; first_word dump included CLEAR 44524743.
  FACT — uart_rx_word sets bix=0 at 4th STOP, so bix-at-commit is not an H19 leftover.
  INFERENCE — H20 drop still presents BEGIN bytes on the wire; pack-side first word is required.
HYPOTHESES:
  H1 identity H can grow probes without a new bit — REJECTED
  H2 LA on uart_rx pin classifies H20 — REJECTED (bytes present even if word dropped)
HOW_TRACE:
  Compare H_ILA_A cap latch vs pack-accept; ILA tcl vs BASIC; classifier rule.
EVIDENCE_MATRIX:
  | claim | class | evidence |
  | H UART internals | FACT | ila=0 |
  | ILA on BASIC | FACT | 12-29205 |
  | H20 needs pack-side word | INFERENCE | H20 case5 BEGIN dropped, bytes sent |
SUCCESS_VS_FAILURE:
  SUCCESS_ARTIFACT: this method. FAILURE_ARTIFACT: internals still unnamed on H.
FIRST_DIVERGENCE: pack-accepted word vs UART token vs UART bytes.
DECISIVE_TEST: owner-authorized H_OBS with pack-side latch, or Standard-license ILA copy.
ROOT_CAUSE_OR_UNKNOWN: observability, not H20-as-fix.
REUSABLE_DECISION_PROCEDURE:
  1. Name the observe identity; never call it H.
  2. Latch first pack-accepted w_data after clr_take.
  3. Sample bix at arm and before that handshake, not at 4th STOP.
  4. Reset capture each trial. No pad. H20 classifier-only.
STRUCTURAL_GUARD: GUARD_ADDED=NO. Do not overwrite H/freeze.
BLAST_RADIUS: method only. No RTL this turn.
VERDICT_BY_LAYER: method. Not BOARD_PASS.
LESSON_TO_SHARE: OWNER-OBSERVE-PACK-SIDE-NOT-H-20260917T092700Z
NEXT_DECISIVE_EXPERIMENT: Owner pick UART-dump H_OBS repair or ILA-if-license.
OWNER_AND_STOP_CONDITION: OWNER Anh. STOP: method delivered; no build unless authorized.
HANDOFF_STATUS: COMPLETE
```
