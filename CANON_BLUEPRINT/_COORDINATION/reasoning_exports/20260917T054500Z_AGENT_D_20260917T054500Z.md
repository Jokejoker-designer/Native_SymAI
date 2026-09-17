# NATIVE_AI_REASONING_EXPERIENCE_V1_AGENT_D_20260917T054500Z

```text
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: D-NATIVE-AI-TEST-IMPACT-SELECTOR-R1
RUN_ID: 20260917T054500Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: Smallest deterministic host-side Test Impact Analysis for Native AI
  FPGA is JSONL journal + rebuildable snapshot + rule selector (OPTION_B),
  canary-only. FACT that product RTL/gold/canon/program were not used as
  control knobs. Not BOARD_PASS / PROGRAM_PASS / FE256_PASS.
RUN_PROVENANCE:
  Anthropic article https://claude.com/blog/agentic-coding-is-straining-ci-heres-how-we-scaled-test-impact-analysis-at-anthropic
  Live PACKAGE CANON_BLUEPRINT tb/ rtl/native_ai/ vivado/tcl/ verification/
  AGENT_C tb/learning + ooc_synth.tcl
  Host tree D:/FPGA/host_tools/NATIVE_AI_TEST_IMPACT_SELECTOR
  unittest 15/15; backtest 5/5 ok
  catalog_sha256 4b87f7c3c3439a7bce0fde3a2fdbd4fe78715e51cbbcc297d36ee15d48fad7fa
  (catalog JSON; engine edits after demo do not change this hash)
OBSERVATION:
  FACT — PACKAGE has 35+ tb_*.sv, 13 learning TBs/scripts, 43 Vivado Tcl,
    8 XDC, B gold under verification/{fe256,pack_abi24,astra_adv}.
  FACT — qstar_select / spear_rank / fem_lifecycle instantiated in D tops
    but C-owned and frozen. uart_rx_word instantiated in the same tops.
  FACT — Anthropic TIA split listener/journal vs rollup vs selector after
    singleton lag; they used an in-memory store because CI jobs were 25x.
  FACT — Native AI change volume is agent-session scale, not CI-every-second.
  FACT — Self-tests 15/15 PASS_HOST; historical backtest ok=true.
  FACT — PRODUCT_RTL_CHANGED=NO GOLD_CHANGED=NO CANON_CHANGED=NO PROGRAM=NO.
  INFERENCE — Same-top instantiation is a false impact edge if used naively
    (UART leaf would pull Q*). Selector must use changed-module components
    plus explicit boundary rules, not "shares a top".
  INFERENCE — First bottleneck at 10x/25x is impl/board wall time, not JSONL.
  HYPOTHESIS — Two canary misses would be the real trigger to enrich the
    Verilog bind graph. UNKNOWN until canary runs on live D changes.
HYPOTHESES:
  H1 OPTION_A static YAML is enough — REJECTED (no journal, forbidden giant list).
  H2 Need SQLite/workers in R1 because Anthropic did — REJECTED (unmeasured need).
  H3 LLM as selector — REJECTED (task + Anthropic: deterministic selector).
  H4 UART change should not MUST_RUN QSTAR_UNIT — CONFIRMED by backtest.
  H5 FE256 R0→R1 must keep OOC/impl even if XSim 256 green — CONFIRMED L-001 rule.
HOW_TRACE:
  1. Inventory PACKAGE TBs, Tcl, XDC, C learning, gold, freeze hashes.
  2. Trace instantiations (grep module uses), not filenames alone.
  3. Read Anthropic article; extract principles; refuse infra copy.
  4. Compare A/B/C; choose B; implement journal/rollup/engine/CLI.
  5. Backtest five historical families; 15 self-tests; write R1.md.
EVIDENCE_MATRIX:
  | claim | class | evidence |
  | OPTION_B implemented | FACT | host_tools tree exists; unittest OK |
  | no product RTL edit | FACT | writes only under host_tools + coordination reasoning/lessons |
  | backtest no missed_critical | FACT | nai_tia backtest ok=true |
  | canary not enforced | FACT | mode CANARY; no CI hook |
  | Pack silicon still open | FACT | A-01 board mute; FEM persist blocked |
SUCCESS_VS_FAILURE:
  SUCCESS_ARTIFACT: NATIVE_AI_TEST_IMPACT_SELECTOR_R1.md; tests.test_selector 15/15
  FAILURE_ARTIFACT: none for selector self-tests. Pack CLASS B remains open elsewhere.
FIRST_DIVERGENCE:
  If we had mapped impact by "same top file instantiates both", UART demo would
  have MUST_RUN QSTAR_UNIT. Actual map uses leaf component UART_RX only.
  That is the design divergence from naive hierarchy.
DECISIVE_TEST:
  test_uart_does_not_force_qstar + backtest PACK_UART_CLEAR_A_H vs UNRELATED_SPEAR
  vs FE256_R0_R1. PASS_HOST.
ROOT_CAUSE_OR_UNKNOWN:
  N/A for a green tool MVP. Selector risk that remains: catalog drift vs new TBs
  (mitigated by UNTRACKED MUST_RUN).
REUSABLE_DECISION_PROCEDURE:
  1. Inventory real tests/layers/cost before choosing TIA infra.
  2. Split journal / rollup / select even if all three are local files.
  3. History may elevate, never waive MUST_RUN or B gates.
  4. Same-top instantiation is not automatic impact.
  5. Lesson→impact rule only when CONFIRMED.
  6. Physical tests = BOARD_RUN_REQUIRED, never auto-program.
  7. Stale snapshot → STATE_STALE + fail open.
STRUCTURAL_GUARD:
  GUARD_ID: G-TIA-R1-CANARY-NO-PASS
  Selector mode CANARY. No PASS stamps. No JTAG. No gold/RTL/canon writes.
  Journal append-only. Snapshot rebuildable. JOBS_IN==JOBS_OUT.
BLAST_RADIUS:
  host_tools/NATIVE_AI_TEST_IMPACT_SELECTOR only, plus reasoning/lesson append.
  Pack investigation, H bit, freeze DCPs, C RTL, B gold untouched.
VERDICT_BY_LAYER:
  PASS_HOST self-test/backtest.
  Not PASS_XSIM (selector does not run DUT).
  Not PASS_OOC / PASS_IMPLEMENTED / PASS_BOARD.
LESSON_TO_SHARE: D-TIA-R1-JOURNAL-SPLIT-20260917T054500Z
NEXT_DECISIVE_EXPERIMENT:
  Canary on the next real D change (likely Pack silicon or FEM persist):
  manual test list vs selector JSON; record miss/extra; ingest results.
OWNER_AND_STOP_CONDITION:
  OWNER AGENT_D. STOP: R1 canary shipped. Do not delay Pack CLASS B debug
  to enrich the catalog. Promotion to enforced selection = owner decision.
HANDOFF_STATUS: COMPLETE
```
