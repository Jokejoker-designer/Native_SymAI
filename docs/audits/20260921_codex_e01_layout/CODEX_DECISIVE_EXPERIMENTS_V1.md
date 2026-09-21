# CODEX decisive experiment V1 — E01 integrated layout replay

**Status: COMPLETED. One paired experiment; no DUT/source patch.**

Question: can the pinned FAIL input bytes alone explain correct SID propagation followed by one read/miss, while a correctly aligned input traverses Directory→Posting→EdgeRecord?

## Setup and provenance

- Source graph: exactly the paths listed by the current integrated `xvlog.log`. No historical isolated TB or checkpoint test was run. Dependencies were compiled in a new audit library; no other task's simulator snapshot was resumed.
- A single audit TB is derived from the current integrated TB, stops after RKB-01, removes unused TB fixture file loading, and adds event logging. UART serialization, UNSET precheck, Pack load and semantic query are unchanged. No hierarchical DUT state/data writes are made in either RKB-01 arm.
- Failed input: all 72 accepted `PACK_W 0..71` words reconstructed in order from the byte-exact handoff FAIL log. It is a reproduced observed packet, not an asserted original generator source file.
- Control input: copied current integrated `RKB04-A2B-EDGE.mem`, SHA `9f1f2d68575c432029f1567b637949dd397088f0b895ac11a5da50d86177b81b`.
- Same compiled snapshot, fresh simulator start/reset for each arm. Only input-file selector and expected diagnostic outcome differ. Both use the same semantic SID A and destination model.
- Scope: 1 Mbaud, shared 100-MHz clock in RKB_EDGE_XSIM, mig_ui_bram stand-in. This is not a generated-MIG or board test.

## Results

| Observable | Failed-input replay | Current-vector control |
|---|---|---|
| Payload word 50 | SID A | Fourth zero padding word |
| CDC source SID | `00010100` | `00010100` |
| Walker lookup SID | `00010100` | `00010100` |
| Published root | `0x10`, valid=1 | `0x10`, valid=1 |
| First accepted read | `0x20` | `0x20` |
| Directory match | `0` | `1_00000030` |
| Destination read count | 1 | 5 |
| Result | miss, neighbor0 | hit, neighbor `00020100` |
| Finish | 3,641,925 ns | 3,682,125 ns |

**First walker divergence:** failed response at 3,601,835 ns in S_DIR_WAIT has a shifted beat. `match_dir=0`, then S_DONE ten ns later. This is the decision suppressing all four later reads. The misleading `walk_sid=0` log line is printed before `do_query`, not when this read is decided.

Control read order: Directory `0x20`, Posting Header `0x30`, Posting Entry `0x40`, EdgeRecord first beat `0x50`, second beat `0x60`.

## Reproduction

Files under `E01_LAYOUT_REPLAY/`:

- `tb_codex_rkb01_delta.sv` — audit-only TB.
- `fail_observed_72_words.mem`, `current_control.mem` — paired inputs.
- `run_replay.bat` — compile and run both arms in an empty output directory.
- `run_pair.bat` — runs only this audit-owned compiled snapshot when its output logs do not yet exist.
- `fail.log`, `control.log`, `xvlog.log`, `xelab.log` — raw results.
- `EVIDENCE_MANIFEST.json` — full hashes, dependency paths and mtimes.

Execution: copy these audit inputs/launchers to a new directory under `AUDIT_CODEX_20260921`, then run `run_replay.bat`; it refuses to overwrite an existing fail/control log. Vivado 2026.1 is selected explicitly. Expected markers are `CODEX_FAIL_VECTOR_REPRODUCED` and `CODEX_CURRENT_VECTOR_CONTROL`; neither is a milestone PASS stamp.

## Decision and limit

FACT: the old observed input reproduces the exact integrated RKB-01 failure signature on unchanged current RTL; the aligned input restores the five-read hit. Fixing SID/CDC or weakening directory matching is unjustified by this failure.

INFERENCE: the producer's 16-byte alignment is the smallest relevant correction; its dependent lengths/checksums must remain coherent. That correction already exists in current integrated vector generation; this audit changes no producer or DUT file.

UNKNOWN: E01 cannot certify the byte-complete original compilation identity or real asynchronous/generated-MIG behavior. These are explicitly registered separately and are not alternative explanations for the observed directory lane mismatch.

Severity S1; first divergence and evidence above. Blocks old-layout RKB-01/bit/program: YES. Blast radius: integrated vector packaging and evidence identity. Continue integrated XSim: YES; build/program readiness: NO as detailed in the blocker audit.
