NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: GITHUB-AUDIT-WATCH-U33-MAG-CLASS
RUN_ID: 20260919T052200Z
OWNER_AGENT: CURSOR_OWNER (publish) / AGENT_D (parent)
CURRENT_CLAIM: Board token 0200015a is pack_loader load_reject R_BAD_MAGIC. Five CLEAR→V-04 on BRAM dest is PASS_XSIM five GOLD; board MAG is not that cell. Not PACK_ABI_24_24_PASS.
RUN_PROVENANCE:
  Parent 31dc87bc MAG_CLASS.md; xsim_u33f.log sha256 c4011529… $finish 12083475 ns
  Board p5_v03.json 01962c63… word 0200015a
OBSERVATION:
  FACT — NAK packing {02,00,reason,5A} + R_BAD_MAGIC=01 → 0200015a
  FACT — pack_loader S_DEC OP_BEGIN hw0 != MAGIC_NAI1 3149414E sets R_BAD_MAGIC
  FACT — five_v04 BRAM XSim five GOLD p1=3149414e
  FACT — mig0 5× cell NOT_RUN
HYPOTHESES:
  H1 5th V-04 on BRAM dest causes MAG. CONTRADICTED PASS_XSIM
  H2 Board host/UART presented non-NAI1 at BEGIN. POSSIBLE
  H3 mig0 dest leftover corrupts later BEGIN. NOT TESTED
HOW_TRACE:
  board MAG token → UART packing → pack_loader reason → BRAM 5× XSim → GitHub
EVIDENCE_MATRIX:
  token | 0200015a | MAG_CLASS.md + pack_loader | FACT
  BRAM 5× | five GOLD | xsim_u33f.log c4011529 | PASS_XSIM
  board MAG | p5 r3 | FAIL_BOARD | FACT
  mig0 5× | not run | UNKNOWN
SUCCESS_VS_FAILURE:
  Success: BRAM dest survives 5th V-04.
  Failure: board 5th V-04 is R_BAD_MAGIC reject.
FIRST_DIVERGENCE: already p5 r3 MAG vs r2 GOLD; class now R_BAD_MAGIC not GOLD scramble.
DECISIVE_TEST: five_v04 BRAM vs board; next is mig0 5× (not this publish).
ROOT_CAUSE_OR_UNKNOWN: MAG means BEGIN magic mismatch at loader. Why hw0 != NAI1 on board UNKNOWN.
REUSABLE_DECISION_PROCEDURE: Decode UART token through packing before overlay. Do not treat MAG as scramble of GOLD.
STRUCTURAL_GUARD: Do not patch pack_loader. No UART/dest_accept overlay. No new identity until mig0 cell.
BLAST_RADIUS: audit publish. U32/H/freeze untouched.
VERDICT_BY_LAYER:
  PASS_XSIM: five_v04 BRAM
  FAIL_BOARD: U33 MAG
  PACK_ABI_24_24_PASS: NO
LESSON_TO_SHARE: UART_0200015A_IS_R_BAD_MAGIC
NEXT_DECISIVE_EXPERIMENT: U33 qsc + generated mig0 5× CLEAR-V-04 XSim (parent).
OWNER_AND_STOP_CONDITION: Watch publish. Stop: no overlay, no PASS stamp.
HANDOFF_STATUS: COMPLETE
