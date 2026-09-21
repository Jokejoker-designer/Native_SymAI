# Codex handoff — integrated RKB-01 delta audit

Date: 2026-09-21  
Scope: `D:/FPGA/arty_d/UART_R2/rkb_edge/` only  
Closed scope preserved: Checkpoint X, isolated RKB gates, Pack, FE256, U33.

## FIRST_DIVERGENCE

The pinned integrated FAIL is preserved at:

`D:/FPGA/arty_d/UART_R2/rkb_edge/xsim/rkb_edge_int_xsim_38432.backup.log`

SHA256: `871be4671f175d552b20d40458e9c31d6feb56437a874eeb65f0eb7805b587e3`.

The first causal divergence is the Directory beat returned at `published_root + 0x10` (`0x20`). The pinned FAIL image places SID A one word earlier, so the reader sees a shifted beat and `match_dir=0`. The walk then completes after one destination read.

The pre-query log text `walk_sid=0` is not the causal failure: it is printed before `do_query`. The post-query FAIL line has `sid_r=00010100`, and the audit replay records the same SID at CDC source and walker lookup.

## TOP_BLOCKER

`INT-B01 — integrated producer/consumer payload-layout mismatch.`

Evidence: the audit-owned paired replay under `E01_LAYOUT_REPLAY/` uses the same compiled RTL snapshot and semantic query:

- FAIL-word replay: one read at `0x20`, shifted directory beat, miss.
- Current aligned vector: reads `0x20, 0x30, 0x40, 0x50, 0x60`, hit B.

Raw outputs:

- [fail.log](E01_LAYOUT_REPLAY/fail.log)
- [control.log](E01_LAYOUT_REPLAY/control.log)
- [EVIDENCE_MANIFEST.json](E01_LAYOUT_REPLAY/EVIDENCE_MANIFEST.json)

The producer/consumer contract must keep the 16-byte root padding and all dependent lengths/CRCs coherent. No SID/CDC patch is justified by this FAIL.

## SECONDARY_BLOCKER

`INT-B02 — the live integrated files were changed after the pinned FAIL.`

The pinned FAIL log is from 13:41. Current local walk/cache hashes differ from `SOURCE_IDENTITY.txt` baselines and the live log/OBS JSON are from a later PASS run. The handoff does not contain a complete byte manifest for the exact historical compilation. The paired replay closes the layout cause for the observed 72-word packet, but a new candidate still requires a complete source/vector/compiler manifest.

## ROOT_CAUSE_OR_UNKNOWN

`ROOT_CAUSE_PROVEN_FOR_PINNED_RKB01_FAILURE`: payload layout disagreement at the Directory boundary.

Still UNKNOWN for board release readiness:

- generated-MIG/asynchronous clock-reset behavior;
- whether the corrected producer/vector is the exact candidate intended for synthesis;
- timing/CDC closure of the corrected integrated graph.

No evidence supports query SID loss, a missing walk start, raw-MIG-ready quiescence, or fixture-directory lookup as the explanation of this FAIL.

## DECISIVE_NEXT_TEST

Run a fresh integrated XSim with a frozen manifest of top, walk, cache, CDC, compiler defines, input vectors and source hashes. Preserve the E01 FAIL/control pair. The test is invalid if any source or vector changes between arms.

Then validate the corrected graph at its intended memory/clock boundary. The current E01 proof uses `RKB_EDGE_XSIM` with `mig_ui_bram` and a shared 100-MHz simulation clock; it does not prove generated `mig0` or hardware behavior.

## SAFE STATUS

```text
SAFE_TO_CONTINUE_INTEGRATED_XSIM = YES
SAFE_TO_BUILD_BITSTREAM          = NO
SAFE_TO_PROGRAM_BOARD            = NO
RUNTIME_KNOWLEDGE_BINDING_8_8_PASS = NOT_RUN
BOARD_PASS = NO
PROGRAM_PASS = NO
TIMING_PASS = NO
MIG_PASS = NO
PACK_ABI_24_24_PASS = NO
```

No board action, bitstream build, product RTL change, or closed-gate re-audit was performed by this delta audit.
