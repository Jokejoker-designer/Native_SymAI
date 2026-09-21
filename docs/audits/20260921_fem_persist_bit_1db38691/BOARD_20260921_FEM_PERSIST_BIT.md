# Unique FEM persist bit 1db38691 PROGRAMMED + UART smoke (2026-09-21)

Watch did **not** program. No `.bit` in git. Independent Get-FileHash of live persist bit equals `1db38691530304e929b437774ebba9a9122590d0a38685a0bba2f646c5b56668`. Disk keep: dest TAP `ead830ae…`, RKB-edge `daaca9c1…`, CT1 `8bfd993d…`. C `fem_lifecycle.v` sha256 `45b9b93073e3e08a2525a3fc1a96573d750bedcd26570cebefba5fa9514779ed` unedited.

LANGUAGE=EN. Not a product PASS stamp.

```text
CLASS = FEM_PERSIST_UART_UNIQUE
PROGRAMMED_EOS_HIGH = FACT (21:33:03+07 Labtools 27-3164)
UART_BOARD_SMOKE_CANDIDATE = YES
DEST_COMMIT_MAGIC = NO
FEM_PERSIST_PASS = NO
PROGRAM_PASS = NO
BOARD_PASS = NO
TIMING_PASS = NO
MIG_PASS = NO
PACK_ABI_24_24_PASS = NO
RUNTIME_KNOWLEDGE_BINDING_8_8_PASS = NOT_RUN
PROGRAM.DONE = NA
```

## Independent hashes

| Artifact | SHA256 |
|---|---|
| persist `.bit` (disk, not committed) | `1db38691530304e929b437774ebba9a9122590d0a38685a0bba2f646c5b56668` |
| `post_route.dcp` (disk, not committed) | `bd942e0ff56a88030bb8149075454cca038c43f33dcbb21f8c1c726f50eca771` |
| dest TAP `.bit` disk keep | `ead830aef3ec2ebc78519700dedf718f1ded9c135c6d390b26367bd5caf0a6a0` |
| RKB-edge `.bit` disk keep | `daaca9c1769d097cab03ccc7168aefd46cc91689b123618425531f4455fc9381` |
| CT1 `.bit` disk keep | `8bfd993d6ebd754df0f97d96887d1a9dd3952aa56be695ae2b8f69fcf73c283c` |
| `BUILD.txt` | `5468987c66be91e058c404c55678a8aa1bd2ec697f3f369c34b6912166c5dc6b` |
| `BIT_SHA256.txt` | `38fad910f620a5cfba66596aa9f128d99e8660e5325a9fb3718494479d49789e` |
| `TIMING_SUMMARY.txt` | `f9cd88aa91905d3c840e3347ca2d6d86f2b5dc05db3139a6b61176fa1a46e924` |
| `PROGRAM.txt` | `4c47930a14f9eae4e409d0f06d31bb0e5d4aaf8425507b8c4025a897caa78214` |
| `UART_SMOKE.json` | `822f8750d1471c2f24ff7c9291d77d6ca8572f7a5ce88f399ff278ea366cd367` |
| `program.log` | `e285663a681cf45bcb549848b5a37da570e695c59e701fab2cd071dabb5e7ace` |
| `program.jou` | `bc41e8d81123a6b0cb300980c38476032a27547c12245419a1e1ff7ada78dee1` |
| D V1 20260921T143303Z | `3f102b8c3a7fc4c9cae0e9fab2132b8fd2039385d20ce96baea9d88adbf75c57` |
| `fem_ctrl_cdc.sv` | `cdf8cc37ea77b5d8056706b7513dfda19697999e1230b0225ba326755dfa24af` |
| `rkb_lookup_cdc.xdc` | `84d72329cea5edb2d22acd1318c4eb3c13403c4dd938767e712c0f29b08fabdc` |
| C `fem_lifecycle.v` | `45b9b93073e3e08a2525a3fc1a96573d750bedcd26570cebefba5fa9514779ed` |

Hashes match D `RESULTS_SHA256SUMS.txt` for bit / BUILD / TIMING / PROGRAM / UART_SMOKE / program.log.

## FACT — unique BIT_OK (not TIMING_PASS)

Unique out `D:/FPGA/arty_d/UART_R2/build_fem_persist`. First unique route aborted `SETUP_NOT_MET` WNS=−2.497 (combo loops). Rebuild after loop fix aborted WNS=−2.514 with `check_timing` loops=0. CDC sample of `op_hold`/`arg_hold` into `op_u`/`arg_u` plus XDC `set_max_delay -datapath_only 8.0` then BIT_OK.

`BUILD.txt` `STATUS=BIT_OK` WNS=0.737. `TIMING_SUMMARY.txt` WNS=0.737 WHS=0.027. Design Timing Summary in `timing_route.rpt` WNS=0.737 WHS=0.027. `check_timing.rpt` combinational loops=0. Route util LUT=12075 FF=12726 Block RAM Tile=0.5 DSP=8. `TIMING_PASS=NO`.

Prior abort WNS files kept as `post_route_WNS_m2p497.dcp` / `post_route_WNS_m2p514.dcp` in the unique build dir (not committed).

## FACT — parent programmed this SHA (watch did not)

JTAG `210319BE776EA`. Tcl `97_program_uart_r2_fem_persist.tcl`. `program.log` `fem_persist_SHA_OK` then Labtools **End of startup HIGH** then `fem_persist_PROGRAM_OK … PROGRAM_PASS=NO`. Unique `PROGRAM.txt` `STATUS=PROGRAMMED` SHA MATCH `PROGRAM.DONE=NA`. `PROGRAM.txt` also records leftover `UART_BOARD_SMOKE=NOT_RUN` written at program time; smoke evidence is `UART_SMOKE.json`.

## FACT — UART COM12 smoke CANDIDATE (not FEM_PERSIST_PASS)

CLEAR n=4 ACK `c1ea50a5`. FOBS/FING/FCMP/FRST/FREC echo. DEST_READ 0x0200010 after FCMP and after FRST beats `fffffff7 ff7fffff 000070ea 00010000` `commit_magic=0`. FOBS_AFTER_CMP `compacted=0` `life=1` `n_raw=2` `cmp_result=1` `key=0x70ea`. FOBS_AFTER_FRST `life=7` `key=0`. FOBS_AFTER_FREC `recov=0` `life=1` `key=0x70ea`. Red RESET=NO. DEST_POKE=NO.

XSim dest COMMIT was `c0117ed0` and recover=2. Board dest magic missing. FOBS key is **not** dest COMMIT proof.

Do not overlay dest-TAP / CT1 unique dirs. Next persist close needs DEST_READ magic then FRST then magic then FREC recover=2 on this quoted SHA, without C RTL edit.
