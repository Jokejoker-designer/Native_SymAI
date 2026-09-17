# NATIVE AI FULL EVIDENCE — FE256 BENCHMARK R1

**Purpose:** acceptance benchmark for Lane B / Full Evidence under `Native Information Fabric R1`.

This package replaces the old text-centric D1–D5 benchmark as the **primary V2 acceptance benchmark**. Historical D1–D5 evidence remains immutable regression evidence and is not rewritten.

## Core rule

The benchmark tests the Full Evidence contract itself:

`canonical pack → DDR/load → Native Semantic Query → indexed graph retrieval → ASTRA proof/status → Structured Result`

Human language parsing and GEMINI wording are tested only in a separate adapter gate. They are not allowed to hide or rescue failures in the semantic core.

## FE256 composition

FE256 contains **256 preregistered semantic cases**:

| Group | Cases | Purpose |
|---|---:|---|
| FE-DIRECT | 48 | exact node→relation→node retrieval |
| FE-VALUE | 32 | typed scalar/range/unit values; no `OID=0` |
| FE-REVERSE | 32 | inverse/directional retrieval |
| FE-MULTIHOP | 32 | bounded 2-hop / 3-hop reasoning |
| FE-CONTEXT | 24 | context isolation and applicability |
| FE-PROVENANCE | 16 | traceable evidence/proof |
| FE-NEGATIVE | 24 | UNKNOWN / UNSUPPORTED / SEARCH_INCOMPLETE semantics |
| FE-CONFLICT | 16 | opposing evidence and conflict state |
| FE-IDENTITY | 16 | model≠family, alias invariance, exact identity |
| FE-ABLATION | 16 | causal removal/mutation tests |
| **TOTAL** | **256** | |

In addition there are **24 Pack/ABI integrity gates** and optional scale profiles.

## Hard acceptance summary

A Full Evidence FE256 PASS requires, in the same frozen artifact lineage:

- `256/256` cases produce an explicit `ResultRecord`.
- `EMPTY = 0`.
- deadlock/transaction timeout = `0`.
- wrong semantic answer = `0`.
- false refusal on answerable cases = `0`.
- exact expected status = `256/256`.
- proof/provenance requirements pass for every case that requires them.
- identity/context leakage = `0`.
- all 24 Pack/ABI gates pass.
- historical evidence is preserved; no old FAIL is overwritten.

**No single “0 hallucination” number is sufficient for PASS.** Reachability, false refusal, explicit status, proof and integrity are reported separately.

## Authority boundary

This package does not certify Self-Learning, FG08, Q*, SPEAR, GEMINI generation, or general language understanding. It certifies Full Evidence as a verified/static domain knowledge provider.
