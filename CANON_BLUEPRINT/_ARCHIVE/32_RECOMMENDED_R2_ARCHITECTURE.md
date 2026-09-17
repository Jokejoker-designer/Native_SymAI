# 32 — RECOMMENDED R2 ARCHITECTURE

## 32.1 Recommendation

Adopt **NSPF R2 candidate architecture** only as a forward Developmental integration target after R0 falsification gates pass. It must not replace or reinterpret frozen V1 evidence.

## 32.2 Top-level architecture

```text
                         HUMAN / SENSOR WORLD
                                 |
                 +---------------+---------------+
                 |                               |
          LANGUAGE ADAPTER                SENSOR ADAPTER
                 |                               |
                 +---------------+---------------+
                                 |
                       NATIVE EVENT/QUERY BUS
                                 |
          +----------------------+----------------------+
          |                                             |
          v                                             v
  BINARY SEMANTIC PLANE                         TEMPORAL EVENT PLANE
 Node/Edge/Value/Context                       Event/State/Action/Reward
 Provenance/Proof refs                         Logical tick/trajectory
          |                                             |
          +----------------------+----------------------+
                                 v
                         WORKING MEMORY
                  bindings / goal / frontier
                                 |
                    +------------+------------+
                    |            |            |
                    v            v            v
                   NCG          Q*           FEM
             exact retrieval   macro       experience
                    |            |            |
                    +-------> SPEAR <---------+
                               |
                               v
                        SKILL / OPTION
                               |
                               v
                       PRIMITIVE EXECUTOR
                               |
                               v
                          PHYSICAL EFFECT
                               |
                               v
                             ASTRA
               legality / proof / conflict / status
                               |
                               v
                      STRUCTURED RESULT
```

## 32.3 Physical memory stratification

```text
T0 IMMUTABLE SEMANTIC CONTROL PLANE
  primitives, exact compare, protocol rules,
  ASTRA control laws, safety, routing

T1 HOT COGNITIVE WORKING STORE
  active frontier, bindings, hot semantic cache,
  skill/proof caches, learner hot state

T2 CANONICAL COGNITIVE MEMORY STORE
  DDR/HBM verified graph, candidates, episodes,
  failures, skills, provenance, checkpoints
```

Placement never changes epistemic class.

## 32.4 Runtime information flow

Query path:

```text
text/sensor
 -> native record
 -> exact ID/context resolution
 -> active frontier
 -> directory/postings
 -> bounded retrieval/inference
 -> candidate set
 -> ASTRA proof/status
 -> structured result
 -> optional human rendering
```

Learning path:

```text
state_before + action + effect + state_after + reward
 -> episode
 -> learner/FEM updates
 -> candidate relation/skill
 -> verification
 -> promotion or reject
```

## 32.5 Recommended Arty realization

Implement first:

- one production UART/frame interface;
- one runtime Knowledge Pack loader;
- MIG DDR path;
- BRAM exact-directory/posting/edge caches;
- one bounded graph walker;
- one event router;
- one frame/binding unit;
- one ASTRA proof/status path;
- small Q*/SPEAR/Skill integration only after core semantic correctness is stable.

Do not begin with multi-walker/HDC/DFX.

## 32.6 Recommended HBM realization

After profiling:

```text
HBM partitions
 -> parallel exact directories/postings
 -> multiple bounded walkers
 -> merge frontier/proof candidates
 -> single or partitioned ASTRA authority
```

HDC may remain a proposal sidecar; exact graph/proof remains authority.

## 32.7 “Sleep cycle” recommendation

Treat consolidation as two separate processes:

### Runtime consolidation

```text
cold DDR object -> hot BRAM cache
```

Pure placement optimization; no semantic status change.

### Offline semantic hardware specialization

```text
stable repeated operator/skill/motif
 -> export statistics
 -> benefit + causal review
 -> RTL specialization
 -> synthesis/P&R/timing/regression
 -> new bitstream candidate
```

Full bitstream rebuild is preferred initially. DFX is deferred until the static/reconfigurable boundary, rollback, timing and artifact lineage are proven.

## 32.8 Minimum acceptance before R2 promotion

```text
FE256 core acceptance intact
FE-UART-E2E-32 pass
NSPF-X0 pass
ROLE_ORDER pass
MASKED_SLOT holdout pass
CAUSAL_ABLATION pass
CLOCK_RATE_INVARIANCE pass
EVENT_JITTER_ROBUSTNESS pass
sensor grounding local causal evidence
ID permutation / unseen-instance transfer evidence
resource/timing fit
no host semantic authority leak
```

## 32.9 Final claim ceiling

If the above passes, a defensible research claim is:

> A bounded FPGA-native semantic/event substrate can execute exact typed knowledge, maintain sparse logical activation and role bindings, retrieve and compose bounded evidence paths, preserve explicit proof/status authority, and acquire selected grounded procedural/relational state while remaining causally dependent on runtime memory and robust to representational/timing perturbations.

This still does not imply AGI, consciousness, universal reasoning or human-equivalent language learning.
