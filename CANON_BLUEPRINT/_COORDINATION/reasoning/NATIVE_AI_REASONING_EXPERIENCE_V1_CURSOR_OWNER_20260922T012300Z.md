REASONING_DISTILLATION_REQUIRED=YES
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: INTEGRATED-CAUSAL-XSIM / 20260922T012300Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: One behavioral netlist connects recovered FEM.failure_total to SPEAR fem_delta, live rank0 to the Q* feature, and Q* proposed_action to the action-precheck. Four-arm discriminator matched. INTEGRATED_CAUSAL_XSIM_CANDIDATE=SUPPORTED. Not a board candidate.
RUN_PROVENANCE: xvlog/xelab/xsim behavioral. Log sha256 e112783e8c350633bb8111e13462e894746bc55091cdf6fb895eac52e59ed0ea. Finish 18555 ns. C RTL hashes unchanged. Frozen bits not rebuilt. BITSTREAM=NOT_BUILT.
OBSERVATION: PRE influence-on with ft 0 stayed rank A action 0. After FREC, OFF/ON/OFF/VETO produced A/X BOUND, B/Y BOUND, A/X BOUND, B/Y SAFETY_VETO final FF. theta_we_count stayed 1.
HYPOTHESES: H1 FACT the three edges are module ports, not TB constants. H2 FACT the same influence bit does not select the action when recovered ft differs. H3 FACT the veto arm keeps the upstream proposal. H4 CONTRADICTED any global PASS.
HOW_TRACE: Legal compact, FRST, pre-recovery ablation, FREC, then four arms with no FEM reset between them. One snapshot per decision_done.
EVIDENCE_MATRIX:
| claim | class | evidence |
| failure_total drives delta | FACT | PRE dB=0 at ft=0; ON1 dB=256 at ft=2 |
| rank0 drives feature and proposal | FACT | rank A feat 0 prop 0; rank B feat 2 prop 1 qsel 2 |
| proposal drives precheck | FACT | apro equals prop; VETO final FF while prop stays 1 |
| end-to-end product path | NOT_TESTED | descriptors, theta, mask, safety, binding, PrimitiveCommand still synthetic |
SUCCESS_VS_FAILURE: First run failed only the theta readback sample, one cycle before the write. The arms already showed qsel 2. The rerun waits until theta8 reads 0001. nfail 0.
FIRST_DIVERGENCE: TB sampled theta_rdata on the write-enable schedule cycle.
DECISIVE_TEST: Epochs 2-5 plus the ft 0 ablation on epoch 1.
ROOT_CAUSE_OR_UNKNOWN: The first nfail was a testbench sample, not a broken edge.
REUSABLE_DECISION_PROCEDURE: Keep producer outputs as the only drivers of the next stage. Add one ablation that holds every test control fixed and changes only the recovered upstream value.
STRUCTURAL_GUARD: Do not build a bitstream from this XSim. Do not stamp ASTRA_PASS, BOARD_PASS, PROGRAM_PASS, TIMING_PASS, FE256_PASS, or PACK_ABI_24_24_PASS.
BLAST_RADIUS: New sim directory fem_spear_qstar_astra. Frozen identities untouched.
VERDICT_BY_LAYER: PASS_XSIM for this connectivity candidate only. BOARD=NOT_TESTED. PROGRAM=NO.
LESSON_TO_SHARE: INTEGRATED-CAUSAL-XSIM-SAME-CONTROL-DIFFERENT-FT-20260922T012300Z
NEXT_DECISIVE_EXPERIMENT: A new board identity only if the owner asks. Do not repeat this XSim to raise the claim.
OWNER_AND_STOP_CONDITION: Stop if this log is cited as ASTRA_PASS or as a programmed identity.
HANDOFF_STATUS: COMPLETE
