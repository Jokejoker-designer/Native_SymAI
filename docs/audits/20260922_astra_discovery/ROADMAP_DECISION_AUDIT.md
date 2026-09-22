# Roadmap decision audit

LANGUAGE=EN
RUN_ID: 20260922T080800Z
RTL_EDIT=NO
BITSTREAM=NO
FROZEN_IDENTITIES_UNCHANGED=YES

```text
PROVEN_ON_SEPARATE_BITS != PROVEN_END_TO_END
```

No bitstream implements `FEM → SPEAR → Q* → ASTRA → final action`.

## System as it exists

| Stage | Where it is real | Research-only on the frozen bits |
|---|---|---|
| FEM persistence | C `fem_lifecycle` plus MIG media on `1db38691…` | That top ties SPEAR `q_start=0` and Q* `prop_start=0` |
| FEM feature | `failure_total` after FREC on the SPEAR and SPEAR-Q* tops | Not a product feature bus |
| SPEAR rank | Frozen `spear_rank.v` on `52b923a6…` and `8b632b4a…` | Two preregistered descriptors, fixed query, generation, and weights |
| Rank output | `rank0` id `0xA1` or `0xB1` | Not a directory hit |
| Q* input | `8b632b4a…` sets feature 2 iff `rank0==0xB1` | `legal_mask=8'h03`, `theta[8]=1`, exam mode |
| Q* proposal | `greedy_action` on that bit | Not wired into action-precheck |
| Action-precheck | `cf246499…` predicate priority | Proposal hardcoded `3'd1`. Safety and capability are UART bits |
| Capability binding | Canon §03.12 name only | No lookup |
| PrimitiveCommand | Canon name only | Final code is `01` or `FF` |

`3ccd03f8…` remains a frozen Q* mux with SPEAR idle. It is not a stage of the later chain.

## Substitute classification

| Substitute | Class | Why |
|---|---|---|
| Fixed descriptors, query, generation, weights | `ACCEPT_TEMPORARILY_FOR_CAUSAL_INTEGRATION` | The varied variable is FEM, so the candidate bytes must stay identical. Live directory lookup is a product interface. |
| Fixed base scores 127 and 0 | `PRODUCT_INTERFACE_ALREADY_EXISTS` | They are SPEAR outputs for those constants, not a second score table. |
| `rank0 → {0,2}` | `ACCEPT_TEMPORARILY_FOR_CAUSAL_INTEGRATION` | Allowed only if the input is the live rank wire. Forbidden if an arm id selects the feature. |
| `theta[8]=1` | `ACCEPT_TEMPORARILY_FOR_CAUSAL_INTEGRATION` | One fixed weight makes the proposal a function of that feature. Learning between arms is forbidden. |
| `legal_mask=8'h03` | `ACCEPT_TEMPORARILY_FOR_CAUSAL_INTEGRATION` | Fixture, not ASTRA legality. |
| Hardcoded proposal `3'd1` | `REMOVE_BEFORE_INTEGRATION` | It cuts Q* off from ASTRA. |
| UART safety/capability bits | `ACCEPT_TEMPORARILY_FOR_CAUSAL_INTEGRATION` | Only for the veto arm. BOUND arms must not change them. |
| `B0–B4` packing | `ACCEPT_TEMPORARILY_FOR_CAUSAL_INTEGRATION` | Experimental. Not an ABI lock. |
| Real capability lookup | `NOT_RELEVANT` to the first connectivity proof | Blocks product binding, not the first XSim. |
| `PrimitiveCommand` | `NOT_RELEVANT` to the first connectivity proof | Blocks executor acceptance. |

## Dependency

Items that block the next causal XSim: wire Q* `proposed_action` into the precheck; feed recovered `failure_total` into the SPEAR delta; feed live `rank0` into the Q* feature.

Items that block product acceptance only: action ABI lock, real `legal_mask`, capability lookup, `PrimitiveCommand`, query-ASTRA ANSWER path, Pack formal `PACK_ABI_24_24_PASS`, timing and board stamps.

Doing the product-only items now widens scope before connectivity is shown.

Pack 24/24 is `CURRENTLY_ORTHOGONAL` to this causal experiment. Reopen it only when the integrated runtime must load semantic candidates from a pack generation. It is not a reason to run another Pack24 campaign.

Query ASTRA is not required before the action chain is a valid connectivity claim. Integrate it when the product query path must emit `ANSWER` from real `verified` and `proof_ref`. That is the common-runtime FE256 / M4 completeness milestone.

## Options

| Option | Evidence | Risk | Debug | Rework | Dependencies | Decision |
|---|---|---|---|---|---|---|
| 1. One XSim top, labeled substitutes | Proves the missing edges | Medium if a mux still bypasses | One log, four observables | Low if substitutes stay explicit | Real FEM, live rank, live proposal | `RECOMMEND` |
| 2. Remove substitutes first | Local cleanup | Low per step | Many identities | High before the chain is even wired | Each substitute is its own project | `DEFER` |
| 3. Binding and PrimitiveCommand first | Product-shaped tail | High | Unrelated to FEM propagation | High | Unbound §03.12 objects | `DEFER` |
| 4. Pack 24/24 first | None for this chain | Reopens a closed campaign | High | High | Pack is not the candidate source here | `REJECT` |
| 5. Query ASTRA first | Query lane only | Mixes two authorities | High | High | Different status namespace | `DEFER` |

## First integrated claim ceiling

`INTEGRATED_CAUSAL_XSIM_CANDIDATE` only.

Forbidden: `ASTRA_PASS`, `BOARD_PASS`, `PROGRAM_PASS`, `TIMING_PASS`, `FE256_PASS`, `PACK_ABI_24_24_PASS`, and any statement that the product path is complete.

## Discriminator

One capture per arm, same descriptors, same query, same generation, same theta, same mask.

```text
influence off, safety ok → rank A → proposal X → BOUND → final X
influence on,  safety ok → rank B → proposal Y → BOUND → final Y
influence off, safety ok → rank A → proposal X → BOUND → final X
influence on,  safety fail → rank B → proposal Y → SAFETY_VETO → NO_ACTION
```

The fourth arm keeps the upstream path and changes only the safety predicate. A/B/A is required so a latch cannot fake the flip. The veto arm is required so the final code cannot ignore ASTRA.

## False-pass checks

| Failure | Required observation |
|---|---|
| UART writes the expected action | Proposal register equals Q* `greedy_action` |
| Feature mux ignores rank | `feat` changes only when `rank0` changes |
| FEM constant | `failure_total` in the delta equals FREC state, and influence-off keeps that state |
| Arm-id verdict | Stale or safety bits follow the predicate priority already shown on `cf246499…` |
| Theta rewritten | No `theta_we` between arms |
| Different descriptors | Both descriptor words identical across arms |
| Reset between arms | No FRST between the four rank/action arms |

## Roadmaps

Roadmap A phases: this map; one XSim top with the allowed substitutes; a new board identity only after that XSim; later removal of substitutes one at a time. Do not touch frozen bits. Claim allowed: `INTEGRATED_CAUSAL_XSIM_CANDIDATE`, then a board candidate only after silicon. Claim forbidden: every global PASS.

Roadmap B would replace the mux, theta, mask, binding, command, query ASTRA, and pack before connectivity is shown. That is a product program, not the next evidence step.

Recommend Roadmap A. The unknown is the missing wire between proven pieces. Removing every substitute first, or building the executor first, does not answer that unknown.
