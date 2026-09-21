# Next experiment — recovered FEM experience → bounded SPEAR/Q* decision

LANGUAGE=EN  
RUN_ID: 20260921T162400Z  
STATUS: DESIGN_ONLY  
OWNER_TARGET: AGENT_D (integration) after owner PROGRAM of a **new unique identity**  
NOT_THIS_BIT: `1db38691…` cannot execute this test

```text
C_FEM_RTL_EDIT=NO
N_RAW=4
C_SCALE_GUARD=HALT if theta>64 or actions>8 or features>8 or K_HARD_MAX>9 or material FEM N_RAW increase
DEST_POKE=NO
FEM_PERSIST_PASS=NO
PROGRAM_PASS=NO
BOARD_PASS=NO
ASTRA remains truth/proof/legality authority
EXPERIENCE != FACT
FEM != ASTRA
```

## Why 1db38691 cannot prove decision influence

Unique persist top `arty_d/UART_R2/fem_persist/arty_a7_r2_top_m4_mig_candidate.sv`:

- SPEAR: `q_start=0`, `cand_valid=0`, `w_flat=0`
- Q*: `prop_start=0`, `feat_flat=0`, `legal_mask=0`
- `fem_feat` (C `failure_total`) is packed into FOBS only

Legal compact on that identity proves storage/recovery. It does **not** place FEM on a ranking/selection path. Do not pretend FOBS `fem_feat` is a decision.

A new unique integration bit is required. That is **not** a persist-repeat rebuild. Owner PROGRAM of a quoted new SHA is required before silicon. Do not overwrite dest TAP `ead830ae` / `daaca9c1` / `8bfd993d` / persist `1db38691` disk copies.

## Question

`DOES RECOVERED FEM EXPERIENCE CAUSALLY CHANGE FUTURE DECISION-MAKING?`

Milestone is not “FEM can be read back.” That is already a board-candidate.

Milestone: recovered experience changes a future bounded ranking/selection **because FEM is on the causal path**.

## Causal discriminator (mandatory)

Hold fixed:

- same input / context
- same active semantic knowledge
- same generation / root
- same candidate set
- same Q* seed unless the seed is an explicit controlled factor
- same ASTRA legality / truth outputs

Vary **only** FEM influence:

```text
FEM experience absent
→ decision A

FEM experience present / recovered after FEM-only FRST+FREC
→ decision B

disable/remove only FEM influence (mux/gate; do not change candidates, query, or ASTRA)
→ decision returns to A

restore the same FEM influence
→ decision returns to B
```

Require A ≠ B on at least one observable (SPEAR admitted ref, SPEAR score order, Q* `proposed_action` / `greedy_action`). If A=B, the test is inconclusive, not a PASS.

## Forbidden

- host-selected answer
- manually changed candidate set between A/B
- altered semantic generation
- hidden fixture fallback
- different query
- uncontrolled Q* seed
- ASTRA truth changes
- DEST_POKE used to manufacture the expected decision
- hard-coded answers for the test ID
- routing the “B” path around SPEAR/Q* into a FEM-only cheat mux that copies an expected opcode

## Suggested bounded hook (D integration, not C FEM edit)

Keep frozen C `fem_lifecycle.v` / `spear_rank.v` / `qstar_select.v`.

D-only wrapper, one influence at a time (do not mix in the first silicon):

1. **Q\* feat lane (preferred first):** after FREC, map `fem_feat` (8-bit `failure_total`) or a saturated function of recovered prototype fields into **one** `feat_flat` byte (Q1.7). Keep the other seven lanes and `legal_mask` identical. `legal_mask` stays ASTRA/capability, never FEM-manufactured legality.
2. **SPEAR weight/score bias (alternative):** keep `cand_desc` identical; apply a documented bounded bias from recovered FEM to `w_flat` or to a D-side score addend **after** SPEAR descriptor decode, with a 1-bit `fem_infl_en` that drops the addend without restimulating candidates.

Observable: Q* `proposed_action`/`greedy_action`/`q_sel` and/or SPEAR `adm_ref_flat`/`adm_score_flat` via a UART observe plane analogous to FOBS (not opcode echo).

Disable path: `fem_infl_en=0` must restore decision A with the recovered FEM media still present (proves the change was the influence mux, not a hidden second stimulus).

## Sequence sketch (silicon)

1. CLEAR (pack) → FEM-only FRST → FOBS virgin. No DEST_POKE.
2. Fixed candidate/query/generation fixture. Decision capture **A** with FEM absent / influence off.
3. Legal FEM compact on the same DUT (FING DUT×2, FREP×3, FCMP gated on FOBS). Optional: DEST_READ COMMIT once as a provenance check, not as the pass metric.
4. FEM-only FRST → FOBS virgin → FREC → FOBS COMMITTED_NEW. Influence on. Decision capture **B**.
5. Influence off only. Decision capture **A2**; require A2=A.
6. Influence on only. Decision capture **B2**; require B2=B.

Do not red-reset (MIG recalib wipes DRAM). Do not treat Compact/COMMIT as the success metric.

## Epistemic lock

FEM may affect ranking, search priority, strategy, avoidance, preference, skill selection.

FEM must not independently manufacture semantic truth. ASTRA remains the truth/proof/legality authority.

```text
EXPERIENCE != FACT
FAILURE != TRUTH
FEM != ASTRA
UTILITY != TRUTH
CANDIDATE != VERIFIED
```

## Stop conditions

Do not stamp `FEM_PERSIST_PASS`, `PROGRAM_PASS`, `BOARD_PASS`, `MIG_PASS`, `TIMING_PASS`, `PACK_ABI_24_24_PASS`, `ASTRA_PASS`, or developmental-intelligence PASS from this experiment even if A/B/A/B holds.

If the first integration bit fails, classify first divergence (STIMULUS | CDC | INFLUENCE_MUX | SPEAR | QSTAR | ASTRA | PACK_GEN | UART_DECODE | IDENTITY). Do not reopen FEM_BASE/COMMIT mapping unless that divergence is media.
