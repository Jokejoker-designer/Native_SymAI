# CODEX unknown register V1 — integrated delta only

## INT-U01 — S1 — Exact historical compilation identity is incomplete

- FACT: the original FAIL raw log is preserved with handoff SHA `871be467...`; original OBS JSON `223aa74e...` was not found under rkb_edge. Current log/JSON and walk/cache hashes are later versions.
- Evidence: `rkb_edge/SOURCE_IDENTITY.txt:20–25`; `rkb_edge/xsim/RKB_EDGE_INT_SRC.json:4`; `rkb_edge/xsim/rkb_edge_int_xsim_38432.backup.log:137–139`; audit `E01_LAYOUT_REPLAY/EVIDENCE_MANIFEST.json`.
- First divergence: source/artifact hash mismatch at audit entry.
- UNKNOWN: byte-complete TB/top/dependency snapshot for the exact 13:41 run. This audit does not pretend to have recovered it.
- What is resolved: replaying its 72 printed accepted words on one current integrated snapshot reproduces the exact RKB-01 miss, layout and read count. Thus the remaining provenance gap does not prevent causal attribution to those input bytes.
- One decisive check: bind a complete current integrated source/vector manifest to the next run and build; preserve the old raw log under its hash.
- Blocks bit: YES while build identity is ambiguous. Blocks program: YES. Blocks RKB diagnosis: NO for INT-B01; YES for a full historical run-equivalence claim.
- Blast radius: metadata/artifact provenance only.

## INT-U02 — S1 for board readiness — Hardware-facing clock/memory boundary is not tested here

- FACT: integrated top `arty_a7_r2_top_m4_mig_candidate.sv:65–79` assigns `ui_clk=CLK100MHZ` and uses `mig_ui_bram` under `RKB_EDGE_XSIM`. The hardware branch at lines 80–94 uses generated mig0.
- FACT: CDC SID arrives correctly in E01. No CDC failure is inferred from this unknown.
- UNKNOWN: whether the corrected candidate preserves request/response and publication behavior under actual unrelated clock phase/reset release and generated-MIG timing. Native-memory address behavior is not validated by the BRAM result alone.
- First divergence: none observed for this hardware-boundary question; it is a scope limitation, not an explanation of the reproduced FAIL.
- One decisive validation: run the pinned corrected integrated graph with the intended clock/memory boundary and observe SID, published root, accepted read addresses and response ownership through RKB-01. Keep E01's expected read sequence as the oracle for this narrow transaction.
- Blocks bit: YES for the current release-readiness verdict; not a claim that trial synthesis is technically impossible. Blocks program: YES. Blocks synchronous RKB-01 XSim: NO.
- Blast radius: integrated test configuration and evidence only; no speculative RTL change.

## Eliminated suspected unknowns for this failure

- FACT: query SID loss — not supported; post-query `sid_r` and E01 source/destination lookup SID are `00010100`.
- FACT: walk never started — contradicted; a directory read is accepted and returns.
- FACT: missing publication — contradicted in this transaction; root_valid=1 and root=0x10 before lookup.
- FACT: raw ready used as quiescence — absent in compiled bind.
- FACT: fixture answers — no fixture dependency in the integrated Directory→EdgeRecord answer provider examined here.
- FACT: Checkpoint X remains closed. No broader project UNKNOWNs were imported.

No board or milestone stamp is issued.
