REASONING_DISTILLATION_REQUIRED=YES
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: ASTRA-DISCOVERY-AUDIT / 20260922T071900Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: ASTRA in current Canon is two machines, query status and action precheck. Current RTL implements query-status candidates only. ACTION_VERDICT_IMPLEMENTATION_NOT_FOUND. The FEM-SPEAR-Q* chain is not ready for ASTRA integration. No ASTRA_PASS. No RTL edit. No bitstream.
RUN_PROVENANCE: Native_SymAI/CANON_BLUEPRINT §03, §20, §30, MASTER action path, rtl/native_ai/astra, verification/astra_adv, verification_r1/05. No board program.
OBSERVATION: astra_qeval never emits ANSWER and is called from query_result_bind. astra_edge_qeval can emit ANSWER and is called from an XSim TB only. astra_adv_dut ties ready low. No ASTRA_DENY module.
HYPOTHESES: H1 FACT two Canon machines. H2 FACT no action-verdict RTL. H3 FACT query RTL does not take SPEAR or Q* ports. H4 CONTRADICTED that ASTRA simply follows Q* as one block. H5 NOT_TESTED common-runtime FE256 and action precheck on silicon.
HOW_TRACE: Read §03.1, §03.7, §03.8, §03.9, §03.12, glossary 20.5.1, module ports, instantiation grep.
EVIDENCE_MATRIX:
| claim | class | evidence |
| Two ASTRA machines | FACT | §03.9 and §03.12 |
| Action RTL missing | FACT | no ASTRA_DENY module |
| Adv gold is DUT | CONTRADICTED | astra_adv_dut header and tied ready |
SUCCESS_VS_FAILURE: Success is a source split without a new design forced onto the utility chain. Failure would be treating astra_qeval as an action veto.
FIRST_DIVERGENCE: Previous chat placed one ASTRA box after Q*. Canon splits query proof/status from action precheck.
DECISIVE_TEST: This document. No new sim.
ROOT_CAUSE_OR_UNKNOWN: The after-Q* picture collapsed two Canon machines.
REUSABLE_DECISION_PROCEDURE: Do not reuse query status codes for an action veto. Do not import astra_adv gold as the encoder.
STRUCTURAL_GUARD: No C RTL edit. No bitstream. No ASTRA_PASS. New action identity only after a separate precheck module exists.
BLAST_RADIUS: Classification only.
VERDICT_BY_LAYER: RTL_FACT plus Canon. PASS_XSIM of edge Q-eval is not this audit and is not ASTRA_PASS. BOARD_PASS=NO.
LESSON_TO_SHARE: ASTRA-QUERY-STATUS-IS-NOT-ACTION-VERDICT-20260922T071900Z
NEXT_DECISIVE_EXPERIMENT: Fixed Q* proposal, flip only safety or capability, expect veto versus allow. Not another SPEAR to Q* repeat.
OWNER_AND_STOP_CONDITION: Stop if FEM or Q* writes legal_mask or the verdict.
HANDOFF_STATUS: COMPLETE
