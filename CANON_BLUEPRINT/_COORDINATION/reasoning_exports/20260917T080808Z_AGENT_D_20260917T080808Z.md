# NATIVE_AI_REASONING_EXPERIENCE_V1_AGENT_D_20260917T080808Z

```text
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: H-ILA-A SILICON FIRST DIVERGENCE
RUN_ID: 20260917T080808Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: Unexpected extra 0x00 is either already on uart_rx at sample,
  or bix/assembly creates the H11 i=0 UNSUP later. Debug build only. JP2 OPEN.
RUN_PROVENANCE:
  Identity H bit cf62102f… UNTOUCHED (not ILA-probed)
  create_debug_core BLOCKED Vivado 12-29205 BASIC license
  Observe debug bit b037b355a7098c99b9a995554756122e09569230d3b8d02698c255e6a64f8cef
  WNS +0.155 (not TIMING_PASS)
  JTAG 210319BE776EA End of startup HIGH
  Host frozen send_words/open_ser; H11 PA24-V-04
  TB_H_ILA_A_CAP_PASS; JSON D:/FPGA/arty_d/H_ILA_A/D_H_ILA_A.json
OBSERVATION:
  FACT — ILA IP create_debug_core is not in BASIC. Cannot probe identity H nets.
  FACT — Observe debug identity (same RX assembler + cap/dump, new P&R) programmed.
  FACT — First H11 after that program: CLEAR ACK c1ea50a5; PACK GOLD 010000a5.
  FACT — Dump magic 31414c48; bix_at_arm=0; sh=01 00 80 00; first_word=44524743.
  FACT — First UART frame wire10=0x286: start=0 data=0x43 stop=1 (CLEAR 'C').
  FACT — Post-CLEAR assembled bytes are BEGIN 00800001 LE, not 00-prefixed.
  FACT — Second H11 without reprogram: CLEAR itself UNSUP 0200075a; dump STALE.
  INFERENCE — On this debug P&R first trial, extra 0x00 is not at RX and not
    inserted by bix/assembly before BEGIN.
  INFERENCE — H i=0 UNSUP is P&R / leave-state dependent, not a constant host 0x00.
  UNKNOWN — identity-H first-divergence waveform (ILA IP blocked).
HYPOTHESES:
  H1 host Python always sends extra 0x00 — REJECTED this trial (wire=0x43, sh=01..)
  H2 extra 0x00 already on uart_rx first frame — REJECTED this trial (first=0x43)
  H3 bix/assembly inserts 0x00 after CLEAR take — REJECTED this trial (sh=01 00 80 00)
  H4 identity-H UNSUP is the same event as this first trial — CONTRADICTED (GOLD here)
  H5 leftover RX state after a completed txn causes later CLEAR-miss — HYPOTHESIS
     (second trial CLEAR UNSUP; dump stale)
HOW_TRACE:
  1. Netlist ILA insert aborted BASIC license.
  2. Observe copy of uart_rx_word + cap + UART dump after pack status.
  3. XSim extra-00 path PASS_XSIM. Silicon first H11 GOLD + dump.
EVIDENCE_MATRIX:
  | claim | class | evidence |
  | ILA IP blocked | FACT | Vivado 12-29205 BASIC |
  | H bit untouched | FACT | sha cf62102f… still on disk |
  | first frame CLEAR 0x43 | FACT | wire10=0x286 dump |
  | post-CLEAR BEGIN aligned | FACT | sh=01 00 80 00 |
  | first H11 GOLD | FACT | 010000a5 n_raw=20 incl dump |
  | identity-H i0 UNSUP waveform | UNKNOWN | no ILA on H |
SUCCESS_VS_FAILURE:
  SUCCESS_ARTIFACT: D_H_ILA_A.json; dump HLA1; TB_H_ILA_A_CAP_PASS
  FAILURE_ARTIFACT: create_debug_core abort; identity-H still unprobed;
    second-trial dump stale
FIRST_DIVERGENCE:
  This debug bit first H11: no extra 0x00 (GOLD). Identity H first H11: UNSUP.
  Divergence is between bitstreams/P&R and/or leave-state, not this host script.
DECISIVE_TEST:
  Observe dump after first post-program H11. PASS_IMPLEMENTED + UART_BOARD_SMOKE
  class only. Not ILA_IP. Not BOARD_PASS.
ROOT_CAUSE_OR_UNKNOWN:
  Named for this debug-bit first trial: 0x00 not at RX, not from assembly.
  Identity-H extra-byte SOURCE still UNKNOWN (cannot ILA H on BASIC).
REUSABLE_DECISION_PROCEDURE:
  1. Do not assume ILA IP on BASIC; use observe+dump if authorized.
  2. A GOLD first trial with sh=01 00 80 00 rejects host-always-sends-0x00.
  3. Do not treat a different P&R GOLD as identity-H PASS.
  4. Reset capture banks per trial or dump is stale.
STRUCTURAL_GUARD:
  GUARD_ID: G-H-ILA-A-BASIC-NO-ILA-IP
  Identity H / freeze DCPs / C RTL / gold not overwritten.
BLAST_RADIUS:
  D:/FPGA/arty_d/H_ILA_A only. H bit cf62102f… and freeze DCPs untouched.
VERDICT_BY_LAYER:
  PASS_XSIM cap TB. PASS_IMPLEMENTED debug bit WNS+0.155 (not TIMING_PASS).
  UART capture this trial: extra 0x00 ABSENT at RX and assembly.
  Not PASS_BOARD / PROGRAM_PASS / PACK_ABI_24_24_PASS / ILA_IP.
LESSON_TO_SHARE: D-H-ILA-A-BASIC-RX-00-20260917T080808Z
NEXT_DECISIVE_EXPERIMENT:
  Standard-license ILA on identity H, or observe-bit capture with per-trial
  cap reset around a leave-state UNSUP. Do not edit uart_rx_word.
OWNER_AND_STOP_CONDITION:
  OWNER AGENT_D. STOP this ILA-A arm: first-trial RX vs assembly named on
  debug bit; H waveform still UNKNOWN without ILA IP.
HANDOFF_STATUS: COMPLETE
```
