# Integration-debt audit — causal chain is not one product path

LANGUAGE=EN
RUN_ID: 20260922T075000Z
RTL_EDIT=NO
BITSTREAM=NO

```text
ASTRA_ACTION_PRECHECK_BOARD_CANDIDATE=SUPPORTED
IDENTITY=cf246499c6e5c09b57fefdd89dc5d6602fc7ded5dc2426d635a0987fc2bc8dae
CAUSAL_BOARD_CANDIDATES=SUPPORTED
PRODUCT_PATH_COMPLETE=NO
ASTRA_PASS=NO
BOARD_PASS=NO
TIMING_PASS=NO
B0_B4=EXPERIMENTAL_PACKING
```

The accidental arm D stimulus set the stale bit and the DUT returned `STALE_DESCRIPTOR`. That is predicate priority, not a hardcoded arm-name lookup.

The chain below is a sequence of separate silicon identities. No single bitstream wires all of them.

| Segment | Identity | Class | What is real | What is not product |
|---|---|---|---|---|
| FEM persistence | `1db38691…` | RESEARCH WRAPPER on C `fem_lifecycle` + MIG media | COMMIT / FRST / FREC on that bit | SPEAR `q_start=0`, Q* `prop_start=0`. Not a decision. |
| SPEAR semantic rank | `52b923a6…` | RESEARCH WRAPPER | Frozen SPEAR scores two fixed descriptors. FEM delta is D-side. | Query, generation, weights, and both descriptors are hardcoded. Not directory/posting candidates. |
| Q* proposed action | `8b632b4a…` | TEMP MUX | Feature is 2 only when rank-0 is `0xB1`, else 0. Exam mode. | `legal_mask=8'h03` and `theta[8]=1` are constants. Not an ASTRA legality input. |
| ASTRA action-precheck | `cf246499…` | UART-ONLY CONTROL | Predicate priority: stale, deny, safety, binding, else BOUND. | No FEM, no SPEAR, no Q*. Proposal hardcoded `3'd1`. Capability and safety are UART bits, not a binding lookup. |
| Final action | `cf246499…` | HARDCODED CONSTANT plus UART predicates | `01` or `FF` from the precheck | Not a `PrimitiveCommand`. Not executor readback. `BOUND` here is not a product capability commit. |

Unbound production interfaces that this chain does not close:

- Query ASTRA: `astra_edge_qeval.sv` (XSim 256/256, not on the M4 top) and `astra_walk_qeval.sv` (on bit `fccc21ec…`, verified/proof tied off, never ANSWER).
- Action ASTRA numeric ABI: `B0–B4` are not a B lock.
- Capability binding lookup and safety-contract object from §03.12.
- One top where recovered FEM, live candidates, Q* proposal, and action-precheck are the same nets.

```text
ASTRA_PASS=NO
BOARD_PASS=NO
PROGRAM_PASS=NO
TIMING_PASS=NO
MIG_PASS=NO
FEM_PERSIST_PASS=NO
FE256_PASS=NO
PACK_ABI_24_24_PASS=NO
```
