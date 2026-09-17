NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID: D-04-ASTRA-QEVAL-PRESEARCH
RUN_ID: 20260917T083900Z
OWNER_AGENT: AGENT_D
CURRENT_CLAIM: Pre-search §03.9 Q-eval (UNSUPPORTED / DIR_ILLEGAL / budget=0 / integrity) raises common-runtime FE256 from 4/256 to 12/256 without importing gold answers or emitting ANSWER.
RUN_PROVENANCE:
  astra_qeval.sv sha256 e4859a64e5b88f3b02006859351be47ddf42ecacd5b4a164d735d7eb875912a2
  query_result_bind.sv sha256 2c876e15022e1ce6c775e71191a74bf6182d24ebb2c5626ae0b4ed3a4fac68b6
  B gold hex 9a3aec0d7b54764bfcf1155ad91083bc0b4097fdb28c58f1680931acfaa35ad5 unmodified
  B TB f95b10b2… unmodified
  XSim log sha256 5da0220301f637540697d1a40dd1e790ab847414b9f6906873973877aa4ff214 finish 353815 ns
  M4 hop1 log sha256 fd591d6319abad57d8c5701da976aa0a9ea510dc92a50eacc4ff49a468e07bee hop1=122
  predict_qeval.py 12/256 before RTL
OBSERVATION:
  FACT — Python predictor and XSim both 12/256. Passes = gold INCOMPLETE 200-203 + UNSUP 196-199 (op=F/rel=3FFF) + DIR 204-207 (REV + REL_RATED).
  FACT — Never ANSWER/UNKNOWN/CONFLICT in astra_qeval.
  FACT — M4_QUERY_RESULT_XSIM_PASS hop1=122 still holds (search_budget 0 and DIRECT rel=0 stay 0x04/0x20).
  FACT — Gold ANSWER still first_fail=0. Remaining 244 classified ASTRA_STATUS (and DIRECTORY/POSTING/WALK vs gold posting scan).
  FACT — C RTL hashes unchanged. PROGRAM=NO. Freeze DCPs not touched.
HYPOTHESES:
  H1 (INFERENCE, leading): Further 256/256 requires gold-equivalent (subject,relation) posting scan + verified proof_ref, not more pre-search status bytes.
  H2 (REJECT): Copying gold proof_ref. Would be oracle import.
  H3 (HYPOTHESIS): search_budget charging during posting walk would pick up more INCOMPLETE than the 4 budget=1 two-hop cases if DUT scanned the FE256 store. Current DUT store is M2 post_a.mem, not the gold universe.
HOW_TRACE:
  gold astra_qeval Python
  -> predict 12/256 bit-exact
  -> astra_qeval.sv + query_result_bind pack
  -> xvlog/xelab/xsim D-04 and M4 hop1
EVIDENCE_MATRIX:
  DIMENSION | CLAIM | ARTIFACT | LAYER
  Predictor | 12/256 | predict_qeval.py vs gold hex | INFERENCE then PASS_XSIM
  D-04 XSim | pass=12 fail=244 | xsim.log 5da02203… | PASS_XSIM FAIL vs gold
  M4 hop1 | hop1=122 | M4_QUERY_RESULT_XSIM_PASS | PASS_XSIM CANDIDATE
  No oracle | no case-id ROM | astra_qeval.sv | RTL_FACT
SUCCESS_VS_FAILURE:
  Success: legal pre-search Q-eval, +8 UNSUP matches, hop1 regression green.
  Failure vs retirement: not 256/256; dedicated FE256 stays.
FIRST_DIVERGENCE:
  Unchanged: gold[0] ANSWER+proof vs DUT SEARCH_INCOMPLETE. New divergence class for 8 UNSUP is closed.
DECISIVE_TEST:
  Same B 256 hex; pass count 12; first_fail still 0 ANSWER.
ROOT_CAUSE_OR_UNKNOWN:
  ROOT for remaining 244: common runtime does not implement gold posting-scan Q-eval on the FE256 edge universe; hop-1 M2 walk cannot lawfully mint proof_ref. UNKNOWN: materializing fe256_gold store into post_a/dir_a without case hard-codes.
REUSABLE_DECISION_PROCEDURE:
  Implement §03.9 guards that need only QueryRecord fields first; predict bit-exact vs gold; then XSim. Do not emit ANSWER without proof objects from retrieval.
STRUCTURAL_GUARD:
  G-D04-NO-ANSWER-WITHOUT-PROOF still. astra_qeval has no 0x01 path.
BLAST_RADIUS:
  astra_qeval.sv, query_result_bind.sv, synth/xsim file lists. Not C RTL. Not freeze. Not gold. Not bitstream.
VERDICT_BY_LAYER:
  PASS_XSIM: 12/256 D-04; hop1=122 M4
  PASS_IMPLEMENTED: astra_qeval present
  PASS_BOARD: NO
  FE256_PASS: NO
  ASTRA_PASS: NO
LESSON_TO_SHARE: D-04-PRESEARCH-QEVAL-PLUS-8
NEXT_DECISIVE_EXPERIMENT:
  Materialize FE256 gold edges into directory/posting (or a pack load) and implement budget-charged posting scan + _finish_hits with edge.proof_id. Re-run same 256. PROGRAM=NO.
OWNER_AND_STOP_CONDITION:
  OWNER AGENT_D. STOP ANSWER without proof. STOP hybrid fe256_query_path. STOP FEM persist until Pack B-class. GOAL open.
HANDOFF_STATUS: COMPLETE
