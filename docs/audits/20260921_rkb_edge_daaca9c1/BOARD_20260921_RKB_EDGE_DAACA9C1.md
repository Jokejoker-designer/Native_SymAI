# Unique RKB-edge bit daaca9c1 PROGRAMMED + UART smoke (2026-09-21)

Watch did **not** program Arty and did **not** resume parent Vivado. This-turn Get-FileHash of the unique `.bit` equals `daaca9c1769d097cab03ccc7168aefd46cc91689b123618425531f4455fc9381`. CT1 file `build_ct1` still `8bfd993d…`. SRAM is now this unique identity. **No `.bit` in this git copy.**

LANGUAGE=EN. Not a product PASS stamp.

```text
CLASS = UART_BOARD_SMOKE_CANDIDATE
PROGRAMMED_EOS_HIGH = FACT
PROGRAM_PASS = NO
BOARD_PASS = NO
CT1_BOARD_PASS = NO
TIMING_PASS = NO
MIG_PASS = NO
PACK_ABI_24_24_PASS = NO
RUNTIME_KNOWLEDGE_BINDING_8_8_PASS = NOT_RUN
UART_NEIGHBOR = NOT_ON_WIRE
```

## Independent hashes

| Artifact | SHA256 |
|---|---|
| unique `.bit` (disk, not committed) | `daaca9c1769d097cab03ccc7168aefd46cc91689b123618425531f4455fc9381` |
| CT1 `.bit` disk keep | `8bfd993d6ebd754df0f97d96887d1a9dd3952aa56be695ae2b8f69fcf73c283c` |
| post_route.dcp (disk, not committed) | `584965e60f39779c5fa59f49954dc25855d9fb6abacdc1025dbea59831fb7eba` |
| `PROGRAM.txt` | `743dfaefbf93346b014274d69db4865dbfb248252d43e20d53913d2ca6922608` |
| `UART_RKB_EDGE_BOARD.json` | `b7e4aab5f7c5a8fc97f60cc12f22cbeb36e009eea5bf91a6e191294e087d793a` |
| ceiling txt | `74e0b6521fe768b97a9e346e2c53eb08f380ae9a051dc868733e76d32bf22b21` |
| `program.log` | `11540321789fc8c7fcf1c892a756b10e893907e0911b5140ccd6755cf05e56a9` |
| `BOARD_CANDIDATE.json` | `1f27c6c00ae101875c616a57481ad1ab39cedf3fb1792b4b58c7cd1e4a0af683` |
| `D_RKB_EDGE_INT.json` | `bedc9d10f8d067a8bd7da6f6012b12b657868259cad362c5bdd21fd440675217` |
| live walk | `4275f60d2b2b22bfeb8dfecacc98b0bc799d3d801b36b83368c8972948397132` |
| live cache | `cf79155a865f5ef5cec0f7373514ec8f18db63c23d0b763ef13a6a9db7403514` |
| OBS 13:48 | `a6e83f258be3f61abefe4377c56cbf1a280a362c1c2f3a57ad807b9259207d73` |
| live XSim log 13:48 | `bb3882e78eaab88821ae661c64cbcd9ffe457addd48cb4705de3bc77999fe59a` |
| pinned FAIL 38432 keep | `871be4671f175d552b20d40458e9c31d6feb56437a874eeb65f0eb7805b587e3` |
| CT1 PROGRAM.txt disk | `e920490d64d8e3292cd6d932f8849e203abc364167a3785a5e4520a8eda31d6d` |
| D V1 program | `d3cf88d3e482da7e5b91595225b5bafbd0c3aedfd1bd1b46a7e6fe9871a3e08b` |
| D V1 candidate | `821d8a2d3803e45e113639084de87ccd068d86f9aae3f1fb5d1b4d3baec06fad` |

## FACT — program

JTAG `210319BE776EA`. Labtools End of startup HIGH 14:21:51+07. Tcl printed `PROGRAM_PASS=NO`. Unique dir `build_rkb_edge`. CT1 path not overwritten.

## FACT — UART COM12 115200 FTDI `210319BE776EB`

UNSET `03000051` miss. A2B GOLD `010000a5` then `03010051`. A2C GOLD then same `03010051`. FLSH n=0 then still `03010051`. CLEAR ACK `c1ea50a5` then UNSET miss. Token is hit-bit, not neighbor C. RKB-02/04/05/08 UART **NOT_RUN**.

## FACT — timing report (not TIMING_PASS)

`timing_route.rpt` Design Timing Summary WNS=0.521 TNS=0 WHS=0.013 THS=0 WPWS=0.187. LUT 11440 FF 10292 RAMB36=0 RAMB18=1 DSP=8 from candidate JSON. Bitstream intends `mig0`; integrated XSim used `mig_ui_bram`.

## FACT — provenance nits (do not reopen E01)

`D_RKB_EDGE_INT.json` lists log sha `01fbee9f…`. Live `rkb_edge_int_xsim.log` is still `bb3882e7…`. `SOURCE_IDENTITY.json` default `dest_posting_edge_walk.sv` still names isolated `322e476d…` while unique walk is `4275f60d…`. Git commit field still `f862174` dirty. Keep FAIL `871be467…`.

E01 layout cause stays closed. This silicon smoke does not prove Directory→EdgeRecord.dst_id on the wire.
