# NATIVE_AI_REASONING_EXPERIENCE_V1_CURSOR_OWNER_20260920T125400Z

```text
NATIVE_AI_REASONING_EXPERIENCE_V1
TASK_ID / RUN_ID: U33OBS-RGOFF-BIT / 20260920T125400Z
OWNER_AGENT: CURSOR_OWNER
CURRENT_CLAIM: Unique OBS rg_off bitstream exists in a new dir; hashes are
  public-audit complete; silicon still old OBS; PACK_ABI remains NO.
RUN_PROVENANCE:
  parent jsonl 31dc87bc unchanged 4581876 @ 2026-09-20T12:43:11Z (V-03 RCA already 7383a26)
  disk: build_u33obs_rgoff synth 19:45+07, route 19:52+07, bit.log BIT_OK 19:54:09+07
  this watch copied hashes/sources to Native_SymAI; did not program; did not Pack24
OBSERVATION:
  FACT — BIT sha256 251eafa9451cabd83089fc5cba0c6351f1955c27a70dd9a60e7e2321f4910764
    file uart_r2_u33obs_rgoff_candidate.bit 1940149 bytes in build_u33obs_rgoff/
  FACT — DCP sha256 c6d75f58ffdf15d9d335bc7e34b4122e3af366ad58ca45ea98b4c6b3b22dd5c5
  FACT — old OBS file still 71b9198f512972bae75af04e406d26c17d7940ecadd324e5b5ffecaedcbf6762
  FACT — BUILD.txt STATUS=ROUTE_DONE; bit.log uart_r2_u33obs_rgoff_BIT_OK PROGRAM=NO
  FACT — timing_route Design Timing Summary WNS=0.834 WHS=0.022 constraints MET
  FACT — util_route LUT=10950 FF=9832 RAMB36=3 RAMB18=2 DSP=8
  FACT — pack_loader.sv sha256 bb59f068… (rg_off) PACKAGE + UART_R2 lib match
  FACT — 97_program_uart_r2_u33obs_rgoff.tcl want_sha=251eafa9… bans 71b9198f
  FACT — this watch did not invoke Vivado program / hops / Pack24
  FACT — bit and DCP binaries not pushed
HYPOTHESES:
  H1 — parent launched rgoff synth/impl/bit after jsonl turn_ended (INFERENCE)
  H2 — programming this SHA will change isolated V-03 from R_SENTINEL (HYPOTHESIS; not tested)
HOW_TRACE:
  Tick 37 jsonl delta=0 vs 7383a26. Disk BUILD.txt newer than publish. Synth_DONE then
  place/route. Awaited bitgen. Measured unique SHA vs old OBS. Copied hashes only.
EVIDENCE_MATRIX:
  bit file hash | FACT | Get-FileHash live bit
  old OBS intact | FACT | Get-FileHash build_u33obs bit
  BIT_OK in log | FACT | bit.log write_bitstream + uart_r2_u33obs_rgoff_BIT_OK
  BUILD.txt ROUTE_DONE | FACT | impl tcl does not rewrite after bitgen
  silicon identity | FACT | last PROGRAM.txt 71b9198f; this watch did not program
  V-03 GOLD on new SHA | UNKNOWN | not programmed
SUCCESS_VS_FAILURE:
  SUCCESS — unique dir + unique SHA + old OBS file not overwritten
  FAILURE — PACK_ABI still NO; silicon still old loader
FIRST_DIVERGENCE:
  Parent jsonl idle vs disk BIT_OK in new dir (watch used disk as source of COMPLETE)
DECISIVE_TEST:
  Independent SHA256 of new bit vs 71b9198f / H / U33 / TAPCDC / TAP
ROOT_CAUSE_OR_UNKNOWN:
  Unique bit built (FACT). Silicon still old loader (FACT). V-03 board after this SHA UNKNOWN.
REUSABLE_DECISION_PROCEDURE:
  Treat bit.log BIT_OK + unique SHA as publishable even if BUILD.txt lags ROUTE_DONE.
  Never copy .bit/.dcp to GitHub. Never program from this watch.
STRUCTURAL_GUARD:
  New out dir build_u33obs_rgoff; 96_bit refuses overwrite of old OBS path;
  97_program OWNER_AUTHORIZED + ban list includes 71b9198f; READY_TO_PROGRAM=NO
BLAST_RADIUS:
  New files under UART_R2/build_u33obs_rgoff and u33obs *rgoff*. C RTL untouched.
  Frozen DCPs / H / U33 / old OBS file untouched. SRAM still 71b9198f.
VERDICT_BY_LAYER:
  PASS_IMPLEMENTED unique bit on disk
  NOT TIMING_PASS (constraints MET is not that stamp)
  NOT PROGRAM_PASS / BOARD_PASS / PACK_ABI_24_24_PASS / MIG_PASS
LESSON_TO_SHARE: BITGEN-LOG-BIT-OK-BUILD-TXT-MAY-LAG-ROUTE-DONE-20260920T125400Z
NEXT_DECISIVE_EXPERIMENT:
  Owner-authorized program of 251eafa9… then isolated V-03; expect GOLD if loader fix on silicon.
  This watch must not run that program.
OWNER_AND_STOP_CONDITION:
  OWNER CURSOR_OWNER watch. Stop on user "dừng theo dõi". Do not program.
HANDOFF_STATUS: COMPLETE
```
