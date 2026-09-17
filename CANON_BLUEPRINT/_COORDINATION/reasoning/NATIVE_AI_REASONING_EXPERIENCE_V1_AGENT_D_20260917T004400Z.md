NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: D-PACK-SILICON-FIRST-DIVERGENCE-01
RUN_ID: 20260917T004400Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: earliest internal divergence among fresh CLEAR, wrong-token, and sticky mute is measurable; H9 CK_RST may separate them.
RUN_PROVENANCE: frozen identities FROZEN_IDENTITIES.json; H reprogram 2026-09-17 07:44+07 End of startup HIGH; host uart_pack24_clear_board.py; no RTL edit; no Identity I.
OBSERVATION:
  FACT — post-program probe ACK c1ea50a5 n=4 a550eac1 (same as FACT A).
  FACT — campaign process first CLEAR n=4 hex=5a070002 tok=find_known None = 0200075a R_UNSUP (CLASS 1).
  FACT — V-02 CLEAR ACK then PACK 0200075a; V-03 0200085a SENTINEL; V-04 0200075a; then S-01 CLEAR n=0 sticky through r1.
  FACT — pack_ok=0/3 this campaign vs historical 7/11 (different run; jumper state of hist UNKNOWN).
  FACT — post-campaign probe n=0.
  FACT — artifacts of prior campaigns copied under FROZEN_20260917T004100Z; not rewritten in place as sole copy.
HYPOTHESES:
  H9 CK_RST/FT2232 — UNKNOWN; installed arm only.
  H_MULTIROOT — still permitted.
  H18 find_known None ≠ hardware mute — SUPPORTED this run (5a070002).
HOW_TRACE: freeze logs → hash bit/host/TSV → program H → probe ACK → --mode clear --rounds 2 → post probe n=0 → STOP for JP2 removal.
EVIDENCE_MATRIX:
  DIMENSION | RESULT | LAYER
  Fresh CLEAR | ACK | UART_BOARD CANDIDATE
  First campaign CLEAR | 0200075a WRONG_VALID | UART_BOARD CANDIDATE
  After 3 packs | sticky n=0 | UART_BOARD CANDIDATE
  JP2 removed | missing | WAITING_OWNER
SUCCESS_VS_FAILURE:
  Success of this step: installed arm saved without RTL change.
  Failure to close H9: removed arm not run.
FIRST_DIVERGENCE: host-visible: ACK after program vs WRONG_VALID on first campaign CLEAR vs later NO_BYTE. Internal net UNKNOWN.
DECISIVE_TEST: H9 jumper A/B. Installed done. Removed waiting.
ROOT_CAUSE_OR_UNKNOWN: UNKNOWN
SURPRISING_OBSERVATIONS: Campaign open after a successful probe produced R_UNSUP on first CLEAR (not n=0). pack_ok 0/3 vs prior 7/11 on same bit.
WRONG_INITIAL_ASSUMPTIONS: Do not treat find_known tok=None as n=0. Do not treat hist 7/11 as this jumper arm.
DECISIVE_CLUES: CLASS 1 then CLASS 2 in one campaign; CLASS 1 is 4-byte valid NAK.
NOT_THE_CAUSE: packing .mem (H1 already rejected). XSim PASS not used as board proof.
DECISION_TREE_FOR_SIMILAR_FAILURE: raw hex first → class WRONG_VALID vs NO_BYTE → only then ILA TX vs ingress.
SMALLEST_DECISIVE_TEST: H9 remove JP2 power-off, same H bit, same host, compare MUTE/UNS counts.
STRUCTURAL_GUARD: freeze logs before campaign overwrite; classify 5a070002 as UNSUP.
LESSON_FOR_C: none (C RTL untouched; C_SCALE_GUARD not tripped).
LESSON_FOR_D: H9 before ILA/RTL. Host parser hid UNSUP as mute.
BLAST_RADIUS: UART CLEAR/Pack on H. Freeze DCPs untouched.
VERDICT_BY_LAYER: PASS_IMPLEMENTED not claimed. UART_BOARD CANDIDATE only.
LESSON_TO_SHARE: D-FIRST-DIV-H9-INSTALLED-20260917
NEXT_DECISIVE_EXPERIMENT: OWNER H9-JP2-ISOLATION
OWNER_AND_STOP_CONDITION: Stop until owner reports jumper removed and board re-powered. D will then reprogram H and rerun the same campaign.
HANDOFF_STATUS: INCOMPLETE_HANDOFF
