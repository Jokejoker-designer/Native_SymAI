# Integration batch law

LANGUAGE=EN
LOCK_UTC: 2026-09-22T023000Z

One meaningful board identity is one SHA. Do not build a bitstream for every substitute.

A batch may replace 2 or 3 closely related substitutes. Then:

1. One integrated XSim of the batch.
2. Independent audit of the new causal cut.
3. One new board identity, only after that audit finds no contradiction.

These four rules are not optional:

1. Unique SHA per meaningful board identity.
2. XSim before board.
3. Independent audit on every new causal cut.
4. Claim ceiling discipline. No global PASS from a candidate.

Frozen and not to be rerun for the same discriminator:

* `44546b43…` action productization board candidate
* `435bdc88…` integrated FEM → SPEAR → Q* → ASTRA board candidate
* `cf246499…` action-precheck only
* `8b632b4a…` SPEAR rank → Q*
* `52b923a6…` FEM → SPEAR semantic rank
* `1db38691…` FEM persistence

## Frozen batch

`ACTION_PRODUCTIZATION_BATCH_R1` is frozen at `44546b43…`. Do not split further ActionIntent, lookup, or PrimitiveCommand tests unless a new contradiction appears.

Question under test:

```text
Q* proposed_action
→ ActionIntent
→ capability descriptor lookup and binding
→ ASTRA precheck
→ PrimitiveCommand / NO_ACTION
```

That is three related substitutions:

1. The live Q* proposal becomes an ActionIntent. The host does not supply the action.
2. A capability descriptor is looked up from that intent, and binding uses the lookup. The tied `capability_present=1` bit is not the product path.
3. ASTRA still gates the result. BOUND emits a PrimitiveCommand. Any deny-class verdict emits NO_ACTION.

Still synthetic in this batch, because they are not the question:

* preregistered descriptors
* fixed query and generation
* fixed theta
* fixed legal_mask
* live rank0 `{0,2}` feature map
* experimental `B0–B4` verdict packing

Safety may stay a named test control only for a veto arm. It must not select the proposal.

XSim claim ceiling if clean: `ACTION_PRODUCTIZATION_XSIM_CANDIDATE` only.
Board claim ceiling, after audit and one new SHA: `ACTION_PRODUCTIZATION_BOARD_CANDIDATE` only.

## Next batch

`SEMANTIC_PRODUCTIZATION_BATCH_R1`

The action lane on `44546b43…` stays closed. This batch must show that the SPEAR candidate set comes from a runtime semantic path. It does not have to remove every remaining substitute.

Three cuts must be live:

```text
runtime QueryRecord → semantic lookup
active_generation → selected semantic records
retrieved descriptors → SPEAR candidates
```

Required path:

```text
QueryRecord
→ directory / posting / index
→ active generation
→ actual descriptor fetch
→ SPEAR
→ Q*
→ frozen action tail
```

Forbidden shape:

```text
query changes → wrapper picks a preregistered descriptor A or B
```

Still synthetic, and must be labeled as substitutes:

```text
fixed theta
fixed legal_mask
rank0 → {0,2} feature map
```

The downstream action tail stays the frozen `44546b43…` shape. Do not reopen ActionIntent, capability lookup, or PrimitiveCommand unless a new contradiction appears.

`SEMANTIC_PRODUCTIZATION_XSIM_CANDIDATE=SUPPORTED` is allowed only after one XSim shows a query or active-generation change altering the retrieved candidate set or rank through that directory/posting fetch. A testbench write of the descriptor, or a mux from the query id onto a constant descriptor, does not qualify. No board SHA before that XSim and an independent audit.

`PACK_ABI_24_24_PASS` is not a blocker until this batch requires the semantic candidates to be provisioned from a committed pack generation. Do not reopen Pack to rescue `gold.py`.
