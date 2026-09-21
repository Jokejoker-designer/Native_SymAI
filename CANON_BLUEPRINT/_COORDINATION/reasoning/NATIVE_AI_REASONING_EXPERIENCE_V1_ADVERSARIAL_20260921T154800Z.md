REASONING_DISTILLATION_REQUIRED=YES
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: ADVERSARIAL-2ND-FEM-PERSIST-1DB38691 / 20260921T154800Z
OWNER_AGENT: INDEPENDENT_AUDIT
CURRENT_CLAIM: Working conclusion paragraph 1 survives: missing C0117ED0 is not MIG/T2/address first-cause because FCMP was guard-rejected (cmp_result=1) after a harness with zero FREP. Persistence language must stay scoped to HDR2 DEST_READ plus FREC restore, not all FEM_BASE. Next experiment must not use cmp_result==0 alone. FEM_PERSIST_PASS=NO PROGRAM_PASS=NO BOARD_PASS=NO MIG_PASS=NO TIMING_PASS=NO PACK_ABI_24_24_PASS=NO.
RUN_PROVENANCE: Adversarial pass on identity 1db38691 commit b9072521. Did not program, edit C RTL, or DEST_POKE. Source fem_lifecycle.v 45b9b930…; UART_SMOKE.json 822f8750…; uart_smoke_fem_persist.py; tb_fem_persist_int.sv; fem_on_mig.sv rst sharing; dest_diag_ui beat align.
OBSERVATION: Sole C_B0 assign is S_IDLE cmp_start && guard==0. C_DONE pulses cmp_done on reject. No FREP in json or Python. DEST_READ did not include beat 0x0200000 (A_W0). FRST resets whole fem_on_mig including adapter dest_hold; dest_diag beat after FRST still 000070ea lane2. AFTER_FRST FOBS is NONE then FREC restores n_raw=2. Earliest silicon opcode vs XSim is CLEAR; causal compact fork is FREP vs FCMP.
HYPOTHESES: H1 FACT encodings L_CLUSTERED=1 L_RESOLVED=2 cmp_result 1=NOT_RESOLVED on this source. H2 FACT no compact-write RTL when guard!=0. H3 STRONG_INFERENCE AFTER_CMP cmp_result is this FCMP. H4 CONTRADICTED leftover C FFs as FREC source. H5 CONTRADICTED 000070ea as COMMIT/A_W0/RAW-valid. H6 NOT_TESTED A_W0 beat contents. H7 UNKNOWN bitstream LUT-level identity vs source.
HOW_TRACE: Attacked C_B0 entry, FOBS staleness, echo-on-reject, compact-write search, FREP presence, address aliases, FRST rst cone, FREC read list, next-experiment gates.
EVIDENCE_MATRIX:
| claim | class | evidence |
| C_B0 if guard!=0 | CONTRADICTED | single assign site |
| FCMP echo on reject | FACT | C_DONE cmp_done<=1; CDC U_WAIT |
| FREP this UART run | CONTRADICTED | json + Python |
| compact T2 write seen | CONTRADICTED for COMMIT/INDEX lanes; NOT_TESTED A_W0 beat | DEST_READ 0x0200010 only |
| HDR2 persist across FRST | FACT | DEST_READ identical including 000070ea |
| global FEM_BASE persist | NOT_TESTED | one beat only |
| D dest-miss ROOT=MIG | CONTRADICTED as current implication | cmp_result=1 + no FREP |
SUCCESS_VS_FAILURE: Working paragraph 1 would fail if life==RESOLVED sar>=3 fr==0 or C_B0 reachable with guard!=0 or FREP present. Those were not found.
FIRST_DIVERGENCE: Causal: TEST HARNESS FREP omitted. Earliest opcode: silicon CLEAR (not causal for cmp_result=1).
DECISIVE_TEST: Still FREP x3 + FOBS RESOLVED/compacted gates then DEST_READ; add FRST after CLEAR; do not treat cmp_result==0 as success.
ROOT_CAUSE_OR_UNKNOWN: Unchanged for missing magic this run: guard NOT_RESOLVED. Compact on mig0 NOT_TESTED.
REUSABLE_DECISION_PROCEDURE: 1) Earliest opcode != first causal fork. 2) cmp_result==0 is reset default. 3) FRST resets T2 issue path so FREC restore is new reads. 4) DEST_READ coverage is per-beat.
STRUCTURAL_GUARD: Next persist UART: FRST after CLEAR; FOBS after FREP; after FCMP require compacted==1 and life==3 not only cmp_result==0; no CLEAR mid-sequence.
BLAST_RADIUS: Classification and next-experiment recipe. Bit 1db38691 and C RTL unchanged.
VERDICT_BY_LAYER: UART_BOARD_SMOKE_CANDIDATE; compact/COMMIT NOT_TESTED; HDR2 beat persist FACT; FEM_PERSIST_PASS=NO; MIG_PASS=NO; PROGRAM_PASS=NO.
LESSON_TO_SHARE: FEM-PERSIST-CMP-RESULT-ZERO-IS-RESET-DEFAULT-20260921T154800Z
NEXT_DECISIVE_EXPERIMENT: Reuse 1db38691. CLEAR+FRST then XSim opcode list including FREP x3. Gate FOBS life==2 sar>=3 fr==0 then FCMP then FOBS compacted==1 life==3 cmp_result==0 then DEST_READ 0x0200010 lane0 C0117ED0 then FRST/FREC recov==2.
OWNER_AND_STOP_CONDITION: Stop if C edit, DEST_POKE COMMIT, new PASS stamp, or treating DEST_READ miss as MIG-first without FOBS gate.
HANDOFF_STATUS: COMPLETE
