---
version: "0.1-candidate"
owner: AGENT_D
status: CANDIDATE
milestone: M2
last_modified: "2026-09-16T14:35:00+07:00"
---

# M2 Exact Directory — CONTRACT (first slice)

> CANDIDATE. Not BOARD_PASS. XSim != board. PROGRAM=NO.

## Causal question

Can exact native IDs resolve to forward/reverse posting locations without
semantic collision?

## This slice

HotDirectoryEntry 128 b [§02.4.2] ROM for FE256 store-A node set.
Linear exact match. Miss is not UNKNOWN (directory miss != ASTRA status).

## Pass language

| Gate | Meaning |
|---|---|
| M2_DIR_XSIM_PASS | every exported ID hits; 4 absent IDs miss |
| BOARD_PASS | forbidden self-issue |

## Hardstops

- Do not treat T1 residency as proof.
- `PostingEntry.edge_ref` is a byte address, not packed identity.
- Do not import fe256_gold.py into DUT behavior.
