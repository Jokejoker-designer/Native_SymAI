# FEM → Q* causal decision experiment (A/B/A/B)

LANGUAGE=EN  
RUN_ID: 20260921T164700Z  
STATUS: DESIGN_LOCKED  
BUILD: NOT_BUILT  
PROGRAM: NO  
IDENTITY_SHA: NOT_ASSIGNED

Accepts freeze `FEM_PERSIST_LEGAL_COMPACT_BOARD_CANDIDATE` on `1db38691…`. This experiment does not reopen FEM_BASE, A_COMMIT, compaction order, FRST media retention, or COMMITTED_NEW. It does not edit frozen C RTL.

```text
C_FEM_RTL_EDIT=NO
C_SPEAR_RTL_EDIT=NO
C_QSTAR_RTL_EDIT=NO
N_RAW=4
ACTIONS=8
FEATURES=8
K_HARD_MAX=9
C_SCALE_GUARD=HOLD
DEST_POKE=NO
RED_RESET=NO
FEM_PERSIST_PASS=NO
PROGRAM_PASS=NO
BOARD_PASS=NO
MIG_PASS=NO
TIMING_PASS=NO
PACK_ABI_24_24_PASS=NO
ASTRA_PASS=NO
DEVELOPMENTAL_BEHAVIOR_CAUSALITY=OPEN
```

## Question

Does recovered FEM experience change a later Q* greedy action when FEM is the only changed causal variable?

SPEAR is not on the pass metric of this first identity. Descriptor field `m_fem` inside `cand_desc` is a candidate-set field. Changing it would violate the fixed-candidate rule. SPEAR stays idle (`q_start=0`).

## New unique integration identity

| Item | Value |
|---|---|
| TREE | `D:/FPGA/arty_d/UART_R2/fem_qstar_causal/` |
| OUT | `D:/FPGA/arty_d/UART_R2/build_fem_qstar_causal/` |
| TOP | `arty_a7_r2_top_fem_qstar_causal.sv` |
| BIT name | `uart_r2_fem_qstar_causal_candidate.bit` |
| SHA | NOT_ASSIGNED until a later owner-authorized build |

Do not overwrite disk copies of `1db38691`, `ead830ae`, `daaca9c1`, or `8bfd993d`. Do not rebuild `1db38691` to repeat COMMIT/FRST/FREC. A bitstream exists only after a later explicit build order, and silicon only after owner PROGRAM of the quoted new SHA.

## Frozen C ports used, not edited

`fem_lifecycle.v` `45b9b930…`: `fem_feat = failure_total`. Legal compact on `1db38691` observed `failure_total=2` after FREC. That value is the experience signal. This design does not retune it.

`qstar_select.v` `d4f64e65…`:

- `feat_flat[i*8 +: 8]` is signed Q1.7 feature i
- `theta[a*8+i]` is signed Q4.12, host-writable only while idle via existing `theta_we`
- proposal MAC is raw `feat * theta` (no extra shift)
- argmax is strict `>`; equal Q keeps the lowest legal action
- `exam=1` forces `explore_hit=0`, does not advance LFSR, and does not leave `have_prop`
- `legal_mask` is an input. Q* does not create legality. Bit 7 is cleared inside Q* (`mask_r = legal_mask & 8'h7F`)

`spear_rank.v` `11e71b50…`: instantiated with `q_start=0`, `cand_valid=0`. Not observed as the decision.

## Controlled constants (identical on A, B, A2, B2)

These are fixtures, not FEM, and not an ASTRA truth claim.

| Signal | Value | Role |
|---|---|---|
| `exam` | 1 | deterministic greedy; no explore |
| `epsilon16` | 0 | unused under exam |
| `legal_mask` | `8'h03` | actions 0 and 1 legal; fixture, not FEM-made legality |
| `theta[8]` action1 feature0 | `16'h0001` | only nonzero weight |
| all other `theta` | 0 | |
| `upd_start` | 0 | no learning during the four arms |
| `lfsr_we` | 0 | seed stays reset default; exam does not step it |
| features 1..7 | 0 | only feature 0 can move |

Expected integer Q when feature0 = F:

- action 0: `q=0`
- action 1: `q = F * 1`
- if `F==0`: tie → `greedy_action=0` (`proposed_action=0`, `explored=0`)
- if `F>0`: `greedy_action=1`

Legal compact’s observed `failure_total=2` therefore predicts action 1 when influence is on. If a later run has `failure_total==0` after FREC, the arm is **INCONCLUSIVE**, not a MIG reopen.

## The only varied variable

D-only mux in the new top (not inside C RTL):

```text
feat0 = fem_infl_en ? failure_total[7:0] : 8'h00
feat_flat = {56'h0, feat0}
```

`fem_infl_en` is a UART bit. It does not write FEM media, theta, legal_mask, or candidates.

`failure_total` is produced on `ui_clk` inside `fem_on_mig`. Q* runs on `clk100`. The new top must CDC `failure_total` and sample it only when FEM is idle (`fem_busy=0`) in the same cycle `prop_start` is issued. A stale CDC sample is first divergence `CDC`, not `MEMORY`.

## Discriminator

```text
same theta
same legal_mask fixture
same exam=1
no candidate stream
no query change
no generation change
no ASTRA status change
no DEST_POKE
no theta write between arms

A   FEM virgin,            fem_infl_en=1  → greedy 0
B   FEM recovered (FREC),  fem_infl_en=1  → greedy 1
A2  same recovered media,  fem_infl_en=0  → greedy 0
B2  same recovered media,  fem_infl_en=1  → greedy 1
```

Pass condition for this experiment’s **candidate** claim only: `A=0`, `B=1`, `A2=0`, `B2=1`, and FOBS after A2/B2 still shows recovered life (compacted, key `0x70ea`). A2 proves the flip is the influence mux, not a second stimulus.

If `A=B`, result is INCONCLUSIVE. Do not stamp a PASS. Do not edit C. Do not reopen COMMIT mapping unless the first divergence is actually media (FOBS/DEST_READ disagree with the already-frozen legal-compact behavior).

## UART plane (new opcodes, disjoint from DPK)

Reuse persist opcodes for experience setup: FING, FREP, FCMP, FREC, FRST, FOBS. No `DPK1` (`44504B31`).

New opcodes, values chosen so they do not collide with FING `46494E47`, FREP `46524550`, FCMP `46434D50`, FREC `46524543`, FRST `46525354`, FOBS `464F4253`, DRD `44524431`, DPK `44504B31`:

| Opcode | Word | Effect |
|---|---|---|
| QTHW | `57544851` | arg = `{8'h0, theta_wdata[15:0], theta_addr[5:0]}` while Q* idle |
| QARM | `4D524151` | arg[0]=`fem_infl_en`; then one `prop_start` with the fixed mask/exam |
| QOBS | `53424F51` | 4 words: greedy, proposed, explored, q_sel[15:0], feat0, infl, fem_feat, life |

QOBS is the decision record. Opcode echo is not a decision.

Theta load happens **once**, before arm A, and is read back through QOBS or a theta read before any proposal. Arms must not rewrite theta.

## Host sequence

1. Confirm programmed SHA is the new unique bit. If SRAM identity is unknown, stop. Do not reprogram `1db38691`.
2. FRST → FOBS virgin (`life=7`, `key=0`, `failure_total=0`).
3. QTHW `theta[8]=1`. Confirm no other theta writes.
4. QARM `infl=1` → QOBS = arm A. Expect greedy 0.
5. Experience setup, gated on FOBS, same recipe as the frozen legal compact: FING tool reject, FING host reject, DUT FING, DUT FING, FREP `0x0111` ×3, FCMP. Success of this step is FOBS `life=3 compacted=1 failure_total=2`. COMMIT magic is provenance, not the decision metric. Do not DEST_POKE.
6. FRST → FOBS virgin → FREC → FOBS `recover_state=2 life=3 key=0x70ea failure_total=2`.
7. QARM `infl=1` → QOBS = arm B. Expect greedy 1.
8. QARM `infl=0` → QOBS = arm A2. Expect greedy 0. FOBS still recovered.
9. QARM `infl=1` → QOBS = arm B2. Expect greedy 1. FOBS still recovered.

No red-board reset between arms. No pack generation change. No candidate descriptor.

## XSim before any bitstream

A new testbench in the new tree, using the existing MIG UI stand-in, must show greedy `0,1,0,1` with the theta and mask above. That result is `PASS_XSIM` only. It is not `BOARD_PASS`, not `FEM_PERSIST_PASS`, not permission to program.

## First-divergence classes if silicon disagrees

`STIMULUS | CDC | INFLUENCE_MUX | THETA_LOAD | QSTAR | UART_DECODE | IDENTITY`

Use `MEMORY` only when FOBS after FREC is not the frozen recovered picture (`recov=2`, `life=3`, `key=0x70ea`, `failure_total=2`) **and** a DEST_READ then disagrees with the frozen legal-compact beats. A wrong greedy action with a correct FOBS is not a MIG failure.

## Epistemic lock

```text
EXPERIENCE != FACT
FAILURE != TRUTH
FEM != ASTRA
UTILITY != TRUTH
CANDIDATE != VERIFIED
```

Q* output is a preference among a fixture-legal pair. It does not create semantic truth. ASTRA stays the legality authority; this identity does not claim an ASTRA result.

## Out of scope

- Power-loss persistence
- SPEAR score order
- Multiple prototypes or `N_RAW>4`
- Learning (`upd_start`) during the four arms
- Host-written expected action
- Editing `fem_lifecycle.v`, `spear_rank.v`, or `qstar_select.v`
