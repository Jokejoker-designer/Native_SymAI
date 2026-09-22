REASONING_DISTILLATION_REQUIRED=YES
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: INTEGRATED-CAUSAL-XSIM / 20260922T012300Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: INTEGRATED_CAUSAL_XSIM_CANDIDATE=SUPPORTED on one behavioral netlist. Recovered failure_total, live rank0, and Q* proposed_action are wires. Not a board candidate.
RUN_PROVENANCE: chain_xsim.log sha256 e112783e8c350633bb8111e13462e894746bc55091cdf6fb895eac52e59ed0ea. Finish 18555 ns. C RTL unedited. BITSTREAM=NOT_BUILT.
OBSERVATION: OFF1 A/0/B0/00, ON1 B/1/B0/01, OFF2 A/0/B0/00, VETO B/1/B2/FF. PRE with the same influence and safety as ON1 but ft 0 stayed A/0.
HYPOTHESES: H1 FACT connectivity. H2 FACT veto does not replace the proposal. H3 CONTRADICTED global PASS stamps.
HOW_TRACE: FREC then four arms, one snapshot per epoch.
EVIDENCE_MATRIX:
| claim | class | evidence |
| three live edges | FACT | DUT ports and the five epoch lines |
| product path complete | NOT_TESTED | listed substitutes remain |
SUCCESS_VS_FAILURE: Rerun nfail 0 after the theta sample waited for rdata 0001.
FIRST_DIVERGENCE: First log read theta before the write landed.
DECISIVE_TEST: Same influence, different recovered ft, different action; same proposal, safety fail, NO_ACTION.
ROOT_CAUSE_OR_UNKNOWN: First failure was the testbench sample point.
REUSABLE_DECISION_PROCEDURE: Ablate the recovered value while holding the test controls fixed.
STRUCTURAL_GUARD: No bitstream from this result.
BLAST_RADIUS: fem_spear_qstar_astra sim only.
VERDICT_BY_LAYER: PASS_XSIM connectivity candidate. BOARD=NOT_TESTED.
LESSON_TO_SHARE: INTEGRATED-CAUSAL-XSIM-SAME-CONTROL-DIFFERENT-FT-20260922T012300Z
NEXT_DECISIVE_EXPERIMENT: Board only on an explicit owner request.
OWNER_AND_STOP_CONDITION: Stop on any global PASS stamp from this log.
HANDOFF_STATUS: COMPLETE
