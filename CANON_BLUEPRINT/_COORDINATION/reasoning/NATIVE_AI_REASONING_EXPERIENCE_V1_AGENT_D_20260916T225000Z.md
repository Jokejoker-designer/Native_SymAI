```text
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: D-PACK-VALIDATION-RESET-01
RUN_ID: 20260916T225000Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: Owner (Anh) keeps AGENT_D as project lead and authorizes AGENT_E to do all audit work except program the Arty. Claim under test: this mandate is operational law, not a PASS stamp, and does not complete GOAL_AGENT_D FINAL R2.
RUN_PROVENANCE:
  Owner utterance 2026-09-17T05:50+07:00
  Law: D:/FPGA/arty_d/AUDIT_LEAD_E/04_OWNER_MANDATE_AUDIT_FULL_EXCEPT_PROGRAM.md
  GOAL_AGENT_E.md (AUDIT_LEAD_E + CANON_BLUEPRINT/_COORDINATION/prompts)
  board_lease.json dispatcher=AGENT_E state=FREE holder=null
  Unique H bit copy hashed cf62102f21bd146976779e45dec77f912790da1000327fbc505941cdef4e7fc9
  Host uart_pack24_clear_board.py: do_clear retries default 1; find_known; --mode probe
OBSERVATION:
  FACT — prior E wake 20260916T223500Z MANDATE=ANALYSIS_ONLY; XSIM_RERUN=NOT_EXECUTED that wake; packing hang-root REJECTED; H3 handshake RTL_FACT.
  FACT — D handshake identity H bit on disk sha256 cf62102f… unique file arty_a7_r2_top_m4_mig_validation_clear_cf62102f.bit size 1940501.
  FACT — PROGRAM.txt still records SRAM identity D bbba86c1; D did not run 32_program (no GRANT).
  FACT — same path arty_a7_r2_top_m4_mig_validation_clear.bit now hashes as H (bitgen -force overwrite). Identity D bit may be absent on disk.
  FACT — host find_token first-4 fallback removed; do_clear default retries=1; --mode probe added.
  FACT — C RTL hashes unchanged (not rehashed this run; no C files written).
HYPOTHESES:
  H1 E ANALYSIS_ONLY was interpreted as skip XSim/UART even when those are audit tools — INFERENCE from E_AUDIT_REPORT XSIM_RERUN=NOT_EXECUTED.
  H2 Programming identity H before UART-probe of SRAM D destroys the only remaining D identity — HYPOTHESIS; disk copy of D not located this run.
  H3 Host 3x CLEAR retry was a flood injector on hold path — HYPOTHESIS (E H3); XSim HOLD_WR_MAX=0 after D fix is PASS_XSIM not PASS_BOARD.
HOW_TRACE:
  owner mandate
  -> write 04_OWNER_MANDATE
  -> update GOAL/README/lease/AGENTS/registry
  -> unique-name H bit
  -> host E §9.2
  -> mailbox AGENT_E/OWNER/AGENT_B
  -> wake E AUDIT_FULL_EXCEPT_PROGRAM
  -> D does not JTAG
EVIDENCE_MATRIX:
  DIMENSION | CLAIM | ARTIFACT | LAYER
  Mandate | AUDIT_FULL_EXCEPT_PROGRAM | 04_OWNER_MANDATE md | OWNER_LAW
  Program | E forbidden; D after GRANT | 32_program not run this run | NOT_PROGRAMMED
  SRAM | still bbba86c1 | PROGRAM.txt (not re-read this distill) | PRIOR_FACT; re-hash on E wake
  Disk bit path | H cf62102f | unique copy hash this run | FACT
  Host | one CLEAR + find_known | uart_pack24_clear_board.py | PASS_IMPLEMENTED host; not PASS_BOARD
SUCCESS_VS_FAILURE:
  Success for this run: E law expanded; D still lead; no nạp; unique H preserved; host no longer 3x CLEAR / first-4 ACK.
  Failure-to-complete GOAL: CLEAR on Arty not classified; H not on SRAM; FEM persist blocked.
FIRST_DIVERGENCE:
  ANALYSIS_ONLY vs owner intent "everything for audit except nạp". First E wake stopped at file/hash analysis without XSim re-run.
DECISIVE_TEST:
  E re-run hold-flood + UART 115200 XSim; then UART --mode probe on SRAM D after GRANT program=no. Do not 32_program as E.
ROOT_CAUSE_OR_UNKNOWN:
  Mandate mismatch is FACT (owner restated). CLEAR mute root still UNKNOWN.
REUSABLE_DECISION_PROCEDURE:
  Separate audit tools (XSim, DCP open, UART capture) from nạp (program_hw_devices). Dispatcher GRANT program=yes only to D.
STRUCTURAL_GUARD:
  PROGRAM_BY_E=FORBIDDEN
  Unique bit filename by sha256 prefix after bitgen
  Host find_known only ACK/BUSY/ERR
  BOARD_LEASE before COM/JTAG
BLAST_RADIUS:
  Coordination law + host script + E folder docs. Live C RTL and freeze DCPs not written. SRAM not changed.
VERDICT_BY_LAYER:
  PASS_XSIM: prior D handshake tests; not re-run this distill
  PASS_IMPLEMENTED: host+docs this run
  PASS_BOARD: NOT_EVIDENCED
  PROGRAM_PASS / PACK_ABI_24_24_PASS / BOARD_PASS: NO
LESSON_TO_SHARE: L-022 AUDIT_EXCEPT_PROGRAM_NE_ANALYSIS_ONLY
NEXT_DECISIVE_EXPERIMENT:
  AGENT_E: hash live bit vs PROGRAM.txt; XSim hold-flood; UART probe SRAM D after GRANT program=no; then GRANT D for H or defer.
OWNER_AND_STOP_CONDITION:
  OWNER AGENT_D for GOAL_AGENT_D and nạp after GRANT.
  OWNER AGENT_E for audit except nạp.
  STOP: E does not 32_program. D does not 32_program until GRANT and E SRAM-D capture or documented defer.
HANDOFF_STATUS: COMPLETE
```
