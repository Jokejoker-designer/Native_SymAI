# FE256 and ASTRA R1

## 1. FE256-R0 remains frozen regression

Do not rewrite the existing 256-case gold to rescue an implementation.

FE256-R0 remains valuable as a **static semantic functional suite**.

It does not by itself prove:

- runtime DDR dependence;
- semantic→physical resolution;
- placement invariance;
- generalization;
- the Native AI research hypothesis.

## 2. New prerequisite

Before FE256 can become board semantic evidence:

```text
RUNTIME_KNOWLEDGE_BINDING_8_8_PASS
```

must already be closed.

Otherwise 256/256 can be explained by static BRAM fixtures or baked paths.

## 3. FE256-R1 candidate deltas

Create a versioned FE256-R1 rather than editing FE256-R0 in place.

Required fixes:

### Identity cases

Alias-A/B pairs must not share the same `subject_id` on the wire when the purpose is to test identity leakage.

Include:

```text
different semantic IDs
controlled alias mapping
ID permutation intervention
same intended meaning where declared
```

### Proof references

Avoid proof references that are trivially affine in the ID allocator.

For multi-hop, `proof_ref` should resolve to real runtime proof/edge objects used by the path.

### Fixture independence

The generator that builds Pack fixtures must not be the sole independent authority for expected-neighbor/proof answers.

Gold truth and DUT storage compilation must have an independence boundary.

### Explicit causal subset

At least a preregistered subset of FE256 cases must be rerun under:

```text
Pack-A support
Pack-B support removed
content mutation
cache on/off
generation switch
```

## 4. ASTRA adversarial suite remains separate

Keep ASTRA adversarial/status-proof tests separate from FE256 histogram coverage.

They must verify distinctions such as:

```text
ANSWER
UNKNOWN
CONFLICT
SEARCH_INCOMPLETE
UNSUPPORTED_QUERY
DATA_INTEGRITY_FAIL
```

and must preserve:

```text
FALSE != UNKNOWN
UNKNOWN != SEARCH_INCOMPLETE
NOT_APPLICABLE != FALSE
NOT_OBSERVED != FALSE
```

The Pack24 generation lesson should be propagated into all future ASTRA observability schemas.
