NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: D-04-ASTRA-GAP-GOLD-HISTOGRAM
RUN_ID: 20260917T092000Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: Common-runtime FE256 XSim 4/256 is the intersection of fail-closed SEARCH_INCOMPLETE with the 4 gold incomplete cases, not a walker/ASTRA success. Repair is M4 Q-eval+proof, not a status-byte patch or FE256 hybrid.
RUN_PROVENANCE:
  GOAL_AGENT_D continuation 2026-09-17
  D_COMMON_RUNTIME_FE256.json (updated this run)
  verification/fe256/out/fe256_gold_results.hex (B freeze; not regenerated)
  query_result_bind.sv sha256 9529fd2792440fc38c5687bedc40fe90034ac789f7aaa2f77d5ebab954c2b036
  XSim log sha256 69690ab00725b8bca84272f05e8231a7c83fffc7a076932509d0203a3a0f6cd0 finish 353815 ns
  C hashes qstar d4f64e65 / spear 11e71b50 / fem 45b9b930 PACKAGE=worktree MATCH
  §03.9.1–3.9.3 / §04.4 / §30.28 / §33.6
OBSERVATION:
  FACT — DUT query_result_bind packs CRC/magic → 0x06+0x55 else always 0x04+0x20 PARTIAL. Never ANSWER/UNKNOWN/CONFLICT/UNSUPPORTED.
  FACT — Walk outputs hit/out_of_profile/incomplete/hops_taken/end_id/last_count are unused in the pack.
  FACT — Gold n=256: ANSWER 194, UNKNOWN 34, CONFLICT 16, SEARCH_INCOMPLETE 4, UNSUPPORTED 8, DATA_INTEGRITY 0.
  FACT — Gold SEARCH_INCOMPLETE indices 200–203 are 0x04/0x20/ak=00/cm=02 refs=0. XSim pass=4. INFERENCE: those 4 are the only bit-exact matches.
  FACT — All 194 ANSWER gold have proof_ref ≠ 0 (idx0 proof=00060100 answer_ref=00020100 flags=03 cm=COMPLETE).
  FACT — rtl/native_ai/astra/ ABSENT in live PACKAGE.
  FACT — C modules instantiated on m4_mig candidate sha 382ac125… with prop_start/q_start/ing_valid tied 0. FUNCTIONAL_QUERY_PATH=NO.
  FACT — PRODUCT_RTL_CHANGED=NO this run (documentation + evidence JSON only). PROGRAM=NO.
  FACT — Pack board still not B-classifiable; FEM persist blocked.
HYPOTHESES:
  H1 (leading, INFERENCE): 4/256 = gold incomplete ∩ DUT fail-closed header (txn/gen/ns echo + zeros + CRC).
  H2 (REJECT for this slice): Emitting ANSWER when walk.hit=1 would be bit-exact vs gold. CONTRADICTED by §03.9.3 proof_ref≠0 and unused proof builder.
  H3 (HYPOTHESIS): Some of the 8 UNSUPPORTED gold could match if Q-UNSUP were implemented without touching ANSWER. Not tested this run.
  H4 (HYPOTHESIS): Identity-H Pack UNSUP remains H19 or H20 or other; independent of D-04.
HOW_TRACE:
  D-04 XSim banner COMMON_RUNTIME_FE256_XSIM_FAIL
  -> decode gold status histogram
  -> compare §03.9 Q-eval vs query_result_bind pack
  -> glob rtl/native_ai/astra (0 files)
  -> hash C RTL PACKAGE vs AGENT_C worktree
  -> document D-05 tied-off / D-06 NOT_MET
  -> mailbox B/E notify; no JTAG
EVIDENCE_MATRIX:
  DIMENSION | CLAIM | ARTIFACT | LAYER
  Bind+run | 256 loaded | xsim 353815 ns | PASS_XSIM gate D-04 letter
  Bit-exact | 4/256 | gold hist + pass indices 200-203 | PASS_XSIM FAIL vs B gold
  Classification | ASTRA_STATUS | TB CLASSIFICATION=ASTRA_STATUS | FACT
  ASTRA module | missing | glob astra/ empty | PASS_IMPLEMENTED=NO
  C integration | present tied-off | m4_mig candidate 382ac125… | PASS_IMPLEMENTED structural
  C hashes | match publish | d4f64e65/11e71b50/45b9b930 | FACT
  Pack board | classifiable | H11/H20 silicon CLASS B | UNKNOWN
SUCCESS_VS_FAILURE:
  Success for D-04 letter: same B 256-case set, DUT=query_result_bind, gold unmodified, classified ASTRA_STATUS.
  Failure for retirement law: not 256/256 bit-exact; dedicated FE256 stays in freeze top; common runtime must grow ASTRA not hybrid.
FIRST_DIVERGENCE:
  Gold[0] ANSWER 0x01/0x01 + proof_ref 00060100 vs DUT SEARCH_INCOMPLETE 0x04/0x20 + proof_ref 0. Status byte is the first mismatch; payload refs would still mismatch after a naive status flip.
DECISIVE_TEST:
  Histogram gold status vs DUT constant pack. 4 gold 0x04/0x20 cases exist and equal pass count. Do not re-run 256 until ASTRA pack changes.
ROOT_CAUSE_OR_UNKNOWN:
  ROOT: M4 ASTRA Q-eval and proof builder are not implemented; hop-1 pack is law-correct fail-closed SEARCH_INCOMPLETE. UNKNOWN: whether a complete-scope common-runtime walk can produce the 194 gold proof_refs without the dedicated engine.
REUSABLE_DECISION_PROCEDURE:
  When common-runtime FE256 is not 256/256: histogram gold status first. If pass count equals gold SEARCH_INCOMPLETE count, the DUT is the fail-closed stub, not a random 4. Do not stamp FE256_PASS. Do not copy gold refs.
STRUCTURAL_GUARD:
  G-D04-NO-ANSWER-WITHOUT-PROOF — query_result_bind must not emit 0x01 unless completeness COMPLETE and proof_ref≠0 from a real proof object. G-NO-FE256-HYBRID — do not instantiate fe256_query_path on common-runtime DUT.
BLAST_RADIUS:
  Evidence JSON, §30.28–30.29, §33.6. No C RTL. No freeze DCP. No bitstream. No gold edit.
VERDICT_BY_LAYER:
  PASS_XSIM: D-04 bind ran (FAIL vs gold 252)
  PASS_IMPLEMENTED: C blocks present tied-off; ASTRA dir absent
  PASS_OOC: not this run
  PASS_BOARD: NO
  FE256_PASS: NO
  ASTRA_PASS: NO
  PACK_ABI_24_24_PASS: NO
  PROGRAM_PASS: NO
LESSON_TO_SHARE: D-04-GOLD-4-EQUALS-INCOMPLETE
NEXT_DECISIVE_EXPERIMENT:
  Owner-authorized M4 ASTRA Q-eval using walk observables + proof_ref from common-runtime records; re-run same B 256. Not PROGRAM. Not gold rewrite. Pack silicon class still needed before FEM persist.
OWNER_AND_STOP_CONDITION:
  OWNER AGENT_D. STOP ASTRA status-byte patch. STOP hybrid FE256. STOP FEM persist until Pack B-class. GOAL remains open. PROGRAM=NO.
HANDOFF_STATUS: COMPLETE
