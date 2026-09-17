# NATIVE_AI_REASONING_EXPERIENCE_V1_AGENT_D_20260917T070305Z

```text
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: NEXT-B-4TH-BYTE-BACKPRESSURE
RUN_ID: 20260917T070305Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: 4TH_BYTE_BACKPRESSURE → WORD_DROP → RATE_DEPENDENT_FAILURE
  is a named uart_rx_word mechanism at PASS_XSIM. Not BOARD_PASS.
  PRODUCT_RTL_CHANGED=NO.
RUN_PROVENANCE:
  tb/native_ai/board/tb_h20_4th_byte_bp.sv
  uart_rx_word.sv unmodified
  xsim snap_h20_bp finish 501445 ns
  xsim.log sha256 826a3adfc0fd6b4fc6451110fa4197345e879ec42e26cb62cb73bd783b7044e5
  JSON tb/native_ai/board/build_h20_4th_byte_bp/H20_4TH_BYTE_BP_XSIM.json
OBSERVATION:
  FACT — STOP at bix==3: if (!w_valid || w_ready) emit else drop; bix<=0 either way.
  FACT — Case1 always-high: bytes 8/8 emit 2 drop 0 ALIGNED.
  FACT — Case2 low before byte4 of first word: emit 1 drop 0 (commit still !w_valid).
  FACT — Case3 W0 sits w_valid=1; W1 4th STOP drop=1; sitting A1B2C3D4; bix=0.
         After take, W2 emits 55667788 ALIGNED (W1 lost, not byte-shifted).
  FACT — Case4 stall after valid, UART idle, then take, then W1: drop 0 emit 2.
  FACT — Case5 dummy sits, BEGIN+MAGIC dropped (drop=2), then MAGIC first opcode
         pack_token 0200075a UNSUP reason=07.
  INFERENCE — Drop requires a held previous word overlapping the next 4th STOP.
  INFERENCE — Rate dependence is UART finishing another 4 bytes before take,
    not baud by itself (TB used 1 Mbps; predicate is baud-independent).
  INFERENCE — This is lost-word, not H12/H19 leftover-bix shift.
  UNKNOWN — whether silicon CLASS B after A-01 is this overlap.
HYPOTHESES:
  H1 any w_ready low drops the in-flight word — REJECTED (cases 2 and 4)
  H2 4th-byte overlap with sitting w_valid drops the new word — CONFIRMED PASS_XSIM
  H3 drop misaligns bix like extra 0x00 — REJECTED (bix=0; W2 exact)
  H4 lost BEGIN then MAGIC-as-opcode yields UNSUP — CONFIRMED PASS_XSIM
  H5 this is the silicon extra-byte SOURCE — UNKNOWN (not ILA / not board)
HOW_TRACE:
  1. Read uart_rx_word STOP 4th-byte branch.
  2. TB-force w_ready around that window; no RTL edit.
  3. Five cases + pack_loader token on case 5.
EVIDENCE_MATRIX:
  | claim | class | evidence |
  | drop iff sitting && 4th STOP !ready | FACT | case3 vs 2/4 |
  | next word aligned after drop | FACT | e0=A1B2C3D4 e1=55667788 |
  | Pack UNSUP from lost BEGIN | FACT | 0200075a |
  | silicon | UNKNOWN | PROGRAM=NO |
SUCCESS_VS_FAILURE:
  SUCCESS_ARTIFACT: H20_4TH_BYTE_BP_XSIM.json; CHECK_OK all 5 + 3b + UNSUP
  FAILURE_ARTIFACT: none this XSim. Silicon CLASS B still UNKNOWN.
FIRST_DIVERGENCE:
  Case3 W1 4th STOP with W0 still valid vs case4 same stall without a following UART word.
DECISIVE_TEST:
  tb_h20_4th_byte_bp XSim. PASS_XSIM.
ROOT_CAUSE_OR_UNKNOWN:
  Named RTL drop at 4th STOP. Not proven as board mute root.
REUSABLE_DECISION_PROCEDURE:
  1. Backpressure without a following 4th STOP does not drop.
  2. 4th-byte drop loses a word and keeps 32-bit alignment.
  3. Do not treat this as leftover-bix; do not pad3 for it.
  4. No RTL change until silicon ILA shows this overlap.
STRUCTURAL_GUARD:
  GUARD_ID: G-H20-4TH-BYTE-BP-XSIM
  PRODUCT_RTL_CHANGED=NO PROGRAM=NO
BLAST_RADIUS:
  new TB + xsim dir + reasoning. uart_rx_word / gold / freeze / C RTL untouched.
VERDICT_BY_LAYER:
  PASS_XSIM mechanism. Not PASS_BOARD / PACK_ABI_24_24_PASS.
LESSON_TO_SHARE: D-H20-4TH-BYTE-BP-20260917T070305Z
NEXT_DECISIVE_EXPERIMENT:
  ILA w_valid/w_ready/bix at 4th STOP on silicon, or keep Pack CLASS B isolate.
OWNER_AND_STOP_CONDITION:
  OWNER AGENT_D. STOP this arm: mechanism named at PASS_XSIM.
  Do not edit uart_rx_word without ILA-A / owner RTL grant.
HANDOFF_STATUS: COMPLETE
```
