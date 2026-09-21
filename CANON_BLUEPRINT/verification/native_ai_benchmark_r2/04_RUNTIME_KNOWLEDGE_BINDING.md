# 04 — RUNTIME KNOWLEDGE BINDING

## Why this gate is mandatory

The recent audit found a decisive architecture gap: Pack writes can reach MIG/DDR
while the candidate query path can still resolve from build-time directory/posting
fixtures. A semantic benchmark can therefore appear correct without proving the
runtime knowledge image is the causal source.

R2 turns this into a first-class acceptance campaign.

## Required experiment pair

Use two physically different Packs with controlled semantic changes:

```text
Pack A:
  generation = G
  semantic fact F = value/object A
  physical placement = slot/address map A

Pack B:
  generation = G+1
  same schema/ABI
  one preregistered semantic change F -> value/object B
  physical placement deliberately relocated
```

The semantic query is the same except the required knowledge generation field is
updated according to the canonical generation contract.

### Control C0 — same semantics, relocated physical placement
Build A and A' with identical semantics but different valid physical locations.

Expected:
- same semantic result;
- different physical addresses/read trace;
- no dependence on fixture addresses.

### Intervention I1 — semantic content mutation
Build B with one sole-support fact changed.

Expected:
- targeted query changes exactly as gold specifies;
- unrelated queries remain unchanged.

### Intervention I2 — stale generation poison
Keep old slot/cache contents intentionally incompatible/stale.

Expected:
- new generation never returns the old answer;
- stale mapping is rejected or bypassed according to the contract.

### Intervention I3 — cache off
Disable/flush T1 cache without changing Pack.

Expected:
- same semantics;
- latency/work may change;
- physical DDR reads must become observable where expected.

### Intervention I4 — support ablation
Remove the only verified proof support.

Expected:
- previous ANSWER disappears into the preregistered explicit status;
- no stale answer survives.

## Required observables

At minimum retain:

```text
pack_hash
schema_hash
abi_hash
generation
active_slot/root
semantic_id
directory pointer
posting pointer
query txn id
query-tagged DDR command address
returned read data / integrity result
walker evidence ref
ASTRA proof/status
StructuredResult
cache hit/miss state
```

A raw MIG read count is insufficient. The read must be attributable to the query
and its returned data must be causally necessary for the downstream result.

## Hard fail conditions

Any of these blocks L1:

- query path has no connection to committed Pack state;
- `active_generation` is not consumed by the runtime;
- runtime directory/posting remains build-initialized fixture-only;
- physical relocation changes semantics;
- content mutation does not change the targeted result;
- stale old-generation answer survives;
- Pack ACK occurs before required writes are drained;
- query result can be generated without the required physical record;
- host/gold code directly writes winners/results into DUT-visible state.
