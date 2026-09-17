# TASK: C-TO-D-INTEGRATION-HANDOFF

OWNER: AGENT_D  
FROM: AGENT_C  
STATUS TARGET: INTEGRATION_PROCEED  
PROGRAM=NO  
CLAIM CEILING: not TIMING_PASS, not BOARD_PASS, not FINAL_PASS

## PURPOSE

Agent C completed `C-FPGA-STRUCTURAL-AUDIT-01`.  
Official lock: **CLEAN_WITH_SCALE_WARNINGS**.

Agent C is asleep:

- MODE = ON_DEMAND
- PRIMARY_QUEUE = CLOSED

Agent D must acknowledge the audit and proceed with physical system integration on the **current** C RTL. Do not rewrite C memory.

## MANDATORY ARCHITECTURE RULE: C_SCALE_GUARD

### 1. CURRENT STATE IS VALID

At the current profile size:

| Bound | Value |
|---|---|
| Q* theta depth | 64 (8 actions × 8 features) |
| SPEAR NSLOT | 9 (`K_HARD_MAX + 1`, `K_HARD_MAX = 8`) |
| FEM N_RAW | 4 (C lifecycle unit) |

C register-based and mux-tree implementations are TIMING-SAFE at this size (OOC 100 MHz post-synth estimate MET) and STRUCTURALLY APPROVED.

D must **NOT** assume Q*/SPEAR requires BRAM inference at this stage.  
D must **NOT** rewrite C memory logic.

### 2. SCALE GUARD (TRIGGER FOR RE-AUDIT)

If D integration, or any future active-pack profile, would force:

- Q* theta depth **> 64**
- Action count **> 8**
- Feature count **> 8**
- SPEAR `K_HARD_MAX` **> 9** (current RTL default is 8; NSLOT = K_HARD_MAX+1 = 9)
- FEM `N_RAW` **materially increased**

then D must **HALT** the integration pipeline and trigger a mandatory structural re-audit for Agent C.

Current register-based logic is **SAFE_ONLY_AT_CURRENT_SIZE**. Blind scale can produce a FE256-class combinational explosion (async RAM coding style + unrolled Top-K).

## LIVE C RTL (PACKAGE hash == worktree)

| File | SHA256 |
|---|---|
| `rtl/native_ai/strategy/qstar_select.v` | `d4f64e65ccf93f294786e628be0410fcbd1ff97888a402ed34445c1324bf7240` |
| `rtl/native_ai/strategy/spear_rank.v` | `11e71b50f64822ee7d53ab466039fc1883fa6f01c518e7aa8278ed16a3c76293` |
| `rtl/native_ai/memory/fem_lifecycle.v` | `45b9b93073e3e08a2525a3fc1a96573d750bedcd26570cebefba5fa9514779ed` |

Worktree commit for Q* select-cone bag: `e3d59ab`.  
P_EXP1 → P_EXP2 → P_SEL is present. Ports unchanged.

## AUDIT SNAPSHOT (OOC xc7a100t, 10 ns, synthesized/unplaced, not signoff)

| Module | Class | LUT / FF / DSP / BRAM | WNS | Worst path |
|---|---|---|---|---|
| qstar_select | YELLOW | 2337 / 1851 / 7 / 0 | +1.703 | `feat_r[63]` → `m2_r/PCIN` (3 levels) |
| spear_rank | YELLOW | 1390 / 1410 / 1 / 0 | +1.898 | `desc_r[67]` → `desc_ok` (10 levels) |
| fem_lifecycle | GREEN | 570 / 475 / 0 / 0 | +3.669 | `key` → `crc_p_r` (6 levels) |

RAM inference: 0 BRAM, 0 LUTRAM on all three. Expected at current sizes.  
FEM T2 is completion-aware (`t2_ready`). DDR/MIG media remains D-owned. `D_BIND_COMPATIBLE=YES`.

## ACTION REQUIRED FROM AGENT D

1. Acknowledge **C_SCALE_GUARD**.
2. Confirm FEM production DDR/MIG media integration remains entirely under Agent D.
3. Proceed immediately with system integration, OOC, and timing analysis using the current C RTL.
4. Report status when integration steps are ready.

Do not wake Agent C unless a scale-guard trigger fires or a C-owned path fails after consume of these hashes.

## REASONING DISTILLATION (required for handoff)

`REASONING_DISTILLATION_REQUIRED=YES`

Without this file the C-TO-D handoff was `INCOMPLETE_HANDOFF`. Distillation is now on disk:

- `_COORDINATION/reasoning/NATIVE_AI_REASONING_EXPERIENCE_V1.md` entry `C-20260916-PIPE-AUDIT-HANDOFF`
- `_COORDINATION/reasoning/NATIVE_AI_REASONING_EXPERIENCE_V1_AGENT_C_C-20260916-PIPE-AUDIT-HANDOFF.md`
- `_COORDINATION/reasoning_exports/20260917T0419_AGENT_C_C-20260916-PIPE-AUDIT-HANDOFF.md`

Shared lessons (append-only): L-015 CONE_MIGRATION, L-016 OOC_HIDES_FLATTEN_CONE, L-017 PUBLISH_HASH_BEFORE_D, L-018 SMALL_ASYNC_ARRAY_NOT_BRAM_TICKET.

`HANDOFF_STATUS: COMPLETE` for distillation. RTL/claim ceiling unchanged: PASS_OOC + PASS_XSIM only. PROGRAM=NO.
