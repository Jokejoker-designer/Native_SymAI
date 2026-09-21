# NSPF-X0 R1 — Strengthened Research Falsification

The existing X0 direction remains correct and becomes the primary research benchmark after L0–L2 are closed.

## Keep these tests

```text
X0-01 ID Permutation
X0-02 Alias Replacement
X0-03 Masked Slot
X0-04 Causal Ablation
X0-05 Clock/Spacing Invariance
X0-06 Event Jitter
X0-07 Reset/Restore
X0-08 Sensor Grounding
X0-09 False Teacher / Anti-parrot
X0-10 Cache On/Off
X0-11 Unseen Instance Transfer
X0-12 4→8→16 Structural Transfer
X0-13 Runtime Knowledge Dependence
X0-14 Stale Cache / Generation
X0-15 Capability Binding
```

## R1 strengthening

### ID permutation

Permutation must cover IDs that influence directory/posting/proof references, not only renderer labels.

Pass only if behavior is preserved modulo the declared permutation.

### Masked slot

The hidden slot cannot be reconstructed from a special-case answer table.

Control:

```text
new IDs
same structural rule
held-out composition
```

### Causal ablation

Remove only the declared causal support. Require result/proof change.

If result survives, inspect:

```text
duplicate support
stale cache
host answer injection
fixture answer
precomputed derived fact
```

### Unseen-instance transfer

Training and test instances must differ in raw IDs and physical placement.

At least one memorization baseline must be preregistered.

### 4→8→16 transfer

Mandatory controls:

```text
disable literal table shortcut
disable primitive shortcut where the claim requires structural inference
new IDs
held-out widths/compositions
same rule semantics
```

The transfer claim passes only if performance exceeds the preregistered literal/script baseline.

### Runtime knowledge dependence

This X0 test consumes the earlier L1 evidence rather than duplicating it. X0 adds research-level perturbations; L1 proves the production runtime path.

### Sensor grounding

Raw observation is not VERIFIED_FACT. Require:

```text
observation
→ candidate/episode
→ causal/effect evidence
→ promotion law
```

### False teacher

A false/rephrased teacher proposal must remain candidate/rejected/conflicted and may not silently become FACT or a proof authority.

## Research claim ceiling

Passing X0 gives bounded empirical support for the representation hypothesis. It does not prove general intelligence or biological cognition.
