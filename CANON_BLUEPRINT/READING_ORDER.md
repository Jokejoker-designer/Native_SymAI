---
version: "1.7-candidate"
owner: AGENT_A
status: AUDITED_CANDIDATE
category: PRIMARY
last_modified: "2026-09-16T20:30:00+07:00"
---

# READING ORDER — R0.1 AUDITED CANDIDATE

## Level 0 — Governance first

1. `README.md`
2. `PROJECT_GOAL_LOCK.md`
3. `AUTHORITY_PRECEDENCE.md`
4. `AUDIT_REPORT_R0_1.md`
5. `R0_1_ERRATA_AND_PATCHES.md`
6. `00_INDEX.md`

## Level 1 — Physical and semantic foundation

7. `23_HARDWARE_FACTS.md` [§23]
8. `20_GLOSSARY_AND_LOCKED_TERMS.md` [§20]
9. `01_MASTER_ARCHITECTURE.md` [§01]
10. `02_MEMORY_STRATIFICATION.md` [§02]
11. `04_ABI_AND_PROTOCOL.md` [§04]
12. `05_CAPABILITY_AND_ACTION_BINDING.md` [§05]
13. `03_ASTRA_AUTHORITY.md` [§03]

## Level 2 — Cognitive/adaptive layer

14. `13_INFORMATION_NEURONALIZATION.md` [§13]
15. `10_LEARNING_AND_STRATEGY.md` [§10]
16. `11_FAILURE_EXPERIENCE_MEMORY.md` [§11]
17. `12_SKILL_AND_TEACHING.md` [§12]
18. `21_PRIOR_ART_AND_NOVELTY.md` [§21]

## Level 3 — Evidence and implementation

19. `31_VERIFICATION_AND_CAUSAL_TESTS.md` [§31]
20. `32_ACCEPTANCE_LADDER.md` [§32]
21. `22_RTL_RISK_REGISTER.md` [§22]
22. `30_MILESTONE_ROADMAP.md` [§30]
23. `33_IMPLEMENTATION_GUIDE.md` [§33]

## Task shortcuts

| Task | Minimum reading |
|---|---|
| architecture change | GOAL, precedence, §20, §01, §02, §03 |
| open unowned contradictions | §00 coordination `OPEN_CONTRADICTIONS` (ledger only; not authority) |
| live tree / split-brain | §00 A-05 LIVE TREES table |
| NCG T1/T2 bit-widths | live §20.9, §02.4, R1 §04.2; **not** MASTER_CANON |
| Query/Result/Event vs NCG | §20.1 `NCG_RECORD` ≠ `QUERY_UART_RECORD`; remain [§04] |
| SemanticEvent 24 bytes vs ID | §20.1, live §04.5; 192-bit/24-byte size ≠ 24-bit identity |
| PostingEntry 64 vs 128 group | §02.4.1, §02.9, §20.1; packing ≠ 128-bit entry type |
| ID width vs active range | §02.4.1, §02.4.1b, §20.1 `SEMANTIC_ID_WIDTH` ≠ `ACTIVE_ID_RANGE` |
| SPEAR 24-bit MAC vs ID | §20.1, §02.4.1, live §10.7.5 Q5.19 product ≠ identity |
| Pack/ABI-24 cases vs ID | §20.1, §02.4.1, live §31.2; 24 gold cases ≠ 24-bit identity |
| K_HARD vs K_HARD_MAX | §02.4.1b, §20.1; profile capacity ≠ C SPEAR slot ceiling |
| MIG_APP_W vs NCG width | §02.4.1, §02.9, §20.1, live §23.9 snapshot; not freeze |
| Null T2 pointer vs identity 0 | §02.4.8, §20.1 `NULL_T2_PTR` ≠ `SEMANTIC_ID_ZERO`; byte 16 not frozen |
| FEM persist / recover class | §02.4.1c, §20.1 `FEM_COMPACTION_RECOVER` ≠ `FEM_DEST_INTEGRITY`; live §11 when C publishes |
| BRAM stand-in vs FEM persist | §02.4.1c, §02.9, §20.1 `BRAM_STANDIN` ≠ `FEM_PERSIST_STORE`; `MIG_BIND_SYNTH` ≠ `MIG_PASS`; `FEM_UI_XSIM` ≠ `FEM_PERSIST_PASS`; live §23.9 18:50 + §33.9 tree |
| FIFO-empty vs dest complete | §02.4.1c, §02.9, §20.1 `FIFO_EMPTY` ≠ `DEST_COMPLETE`; live §22 R07 (17:35) agrees (hint only) |
| RTL pipeline vs logical stages | §02.4.1c, §02.9, §20.1, live §10.7.2; `RTL_PIPELINE_DEPTH` ≠ `LOGICAL_STAGE_COUNT`; `LEARNER_UI_CLK` ≠ `TIMING_PASS`; D +1.549 / −1.482 / −1.160 ≠ TIMING_PASS |
| Board osc vs MIG sys_clk | §02.4.1c, §02.9, §20.1 `BOARD_OSC` ≠ `MIG_SYS_CLK`; T2 null ≠ DDR beat 0 |
| XSim vs BOARD_PASS | §20.1, §02.9, live §22 R20; `XSIM_PASS` ≠ `BOARD_PASS` |
| EpisodeRecord class | §01.4, §02.4, §20.4; bits/fields UNKNOWN; not the §20.9 NCG table |
| D implementation contract | §02.9, §01.7, §02.4.10, §33.7 |
| ABI encodings / gold | §04.12, §03.9, §20.5, §31 |
| ABI/loader | §04, §33 M1, §23, §31, §32 |
| physical action/control | §01.7, §05, §20.5.1, §03, live §12.8, §31 |
| action-lane vs Query UART | §05.1, §01.7, live §04.13; ACTION_LANE_OBJECT ≠ QUERY_UART_RECORD |
| SKILL_STATE vs EXECUTION_PERMISSION | §20.1, §01.7, §05.1, live §12.8; lifecycle ≠ per-call eligibility |
| Skill Engine vs Primitive Executor | §20.1 `SKILL_ENGINE` ≠ `PRIMITIVE_EXECUTOR`; live §03.1/§03.12 Skill may originate ACTION_INTENT; does not authorize pins |
| action credit chain | §01.7, §05.6, live §10.8.4; proposal ≠ execution ≠ credit |
| §05.8 action-path pass names | §05.8, §01.7, §20.1 `ACTION_PATH_PASS_SET` ≠ `X0_15_BINDING_FAMILY`; live §31.12/§32.5 echo the seven names |
| learning | §10, §11, §12, §03, §31 |
| board acceptance | §23, §31, §32, §33 |
| novelty claim | §21 + dedicated external patent/literature search |

## Tóm tắt tiếng Việt

Đọc Governance trước, sau đó hardware/glossary/architecture/memory/ABI/capability/
ASTRA, rồi learning, cuối cùng verification/acceptance/implementation.
