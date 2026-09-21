# NATIVE_AI_REASONING_EXPERIENCE_V1

LANGUAGE=EN
TASK_ID: D-RKB-DIR-POST-EDGE-BOARD-CANDIDATE
RUN_ID: 20260921T070318Z
OWNER_AGENT: AGENT_D
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED: YES
MAILBOX: NOT_SENT (owner relays)
PROGRAM: NO

CURRENT_CLAIM:
Unique `RKB_DIR_POST_EDGE_BOARD_CANDIDATE` bitstream exists and is
`READY_FOR_OWNER_PROGRAM_DECISION`. Owner chat “Đồng ý cho sử dụng board”
is `USE_BOARD=YES`, not SHA-quoted `PROGRAM=YES`. This candidate SHA is
`daaca9c1769d097cab03ccc7168aefd46cc91689b123618425531f4455fc9381`.
CT1 `8bfd993d…` was not reused and was not overwritten. Not 8/8. Not
PROGRAM_PASS / BOARD_PASS / TIMING_PASS / MIG_PASS / PACK_ABI_24_24_PASS.

RUN_PROVENANCE:
- Unique out: `D:/FPGA/arty_d/UART_R2/build_rkb_edge`
- Bit: `uart_r2_rkb_edge_candidate.bit` 1974637 bytes
- Bit sha256 `daaca9c1769d097cab03ccc7168aefd46cc91689b123618425531f4455fc9381`
- CT1 bit still `8bfd993d6ebd754df0f97d96887d1a9dd3952aa56be695ae2b8f69fcf73c283c`
- post_route.dcp sha256 `584965e60f39779c5fa59f49954dc25855d9fb6abacdc1025dbea59831fb7eba`
- post_synth.dcp sha256 `e6acdcbef8a6c57d11ecb9747e13222c8f8219562a5b978dbb3d280c1fb2ad57`
- BOARD_CANDIDATE.json sha256 `1f27c6c00ae101875c616a57481ad1ab39cedf3fb1792b4b58c7cd1e4a0af683`
- SHA256SUMS.txt sha256 `3c46c3217cf03719d457e543adf58d7bde94cdc42eea2ce88f65674652cf3c91`
- Unique walk sha256 `4275f60d2b2b22bfeb8dfecacc98b0bc799d3d801b36b83368c8972948397132`
- Unique cache sha256 `cf79155a865f5ef5cec0f7373514ec8f18db63c23d0b763ef13a6a9db7403514`
- Unique mux sha256 `d0443a4e941bc8303abb4fba5e5de48e1c7472bb59809c483e61a6c0205f7521`
- Unique top sha256 `acb033980246cb22a26a5cfe9daeca19c29d490659f232d338bfc1602bac6559`
- RKB_EDGE_INT_OBS sha256 `a6e83f258be3f61abefe4377c56cbf1a280a362c1c2f3a57ad807b9259207d73`
- RKB_EDGE_INT_SRC sha256 `ac057b77a615cc33703454a3ed69e86385189a02012044f4498b5656f40fcca7` hits=[]
- Isolated walk `322e476d…` not overwritten (XSim-only, function part-select)
- Native_SymAI HEAD `f862174c5ec90b8e1629748c69dd847f715e13ed` dirty_tree=YES
- Vivado 2026.1 SW Build 6511674; part `xc7a100tcsg324-1`
- `run_bit_rkb_edge.bat` first vivado.bat `exit` ended parent after synth; impl resumed via `call vivado`
- PROGRAM=NO. gold.py not edited. No Pack24. No mailbox. No program_hw_devices.

OBSERVATION:
FACT: Synth completed 0 errors. Guards TAP=1 QCDC=1 WALK=1 DIR_A=0 exact_directory=0 posting_walk=0.
FACT: Post-route timing_route.rpt WNS=+0.521 TNS=0 WHS=+0.013 THS=0 WPWS=+0.187; “All user specified timing constraints are met.”
FACT: check_timing unconstrained_internal_endpoints=0; final unrouted nets=0; route verification completed successfully.
FACT: util_route LUT=11440 FF=10292 RAMB36=0 RAMB18=1 DSP=8.
FACT: DRC 0 Errors, 38 checks, max severity Warning.
FACT: write_bitstream DRC 0 Errors; BIT_OK printed with sha `daaca9c1…`.
FACT: CT1 unique file hash unchanged.
FACT: Owner grant this turn is board-resource yes, not a quoted-SHA program yes.
FACT: Integrated XSim used `mig_ui_bram` (`ifdef RKB_EDGE_XSIM`); bitstream top instantiates real `mig0`.
INFERENCE: Post-route WNS/WHS met is not TIMING_PASS / MIG_PASS.
UNKNOWN: Silicon Directory→Posting→EdgeRecord behavior on this SHA.

HYPOTHESES:
H1: Owner “use the board” authorizes programming CT1 `8bfd993d` or this new bit without quoting SHA. REJECTED — owner freeze: PROGRAM only after YES quoting THIS candidate SHA; CT1 must not be reused.
H2: Unique bit would overwrite `build_ct1`. REJECTED — unique dir `build_rkb_edge`; CT1 hash still `8bfd993d…`.
H3: Post-route WNS>0 is TIMING_PASS. REJECTED — claim ceiling; TIMING_PASS=NO written into BUILD.txt / BOARD_CANDIDATE.json.
H4: Integrated XSim 01..08 is RUNTIME_KNOWLEDGE_BINDING_8_8_PASS. REJECTED — PASS_INTEGRATED_XSIM only; 8/8 NOT_RUN.
H5: Parent bat would run impl after synth without `call vivado`. CONTRADICTED — first bat exited 0 after synth; `vivado.bat` `exit` killed parent.

HOW_TRACE:
Unique identity tree → integrated XSim RKB-01..08 PASS_INTEGRATED_XSIM (PAD=16, pack-3 A2C SLOT0, synth-legal `md=match_dir`) → synth unique dir (Synth 8-660 fixed via `logic [32:0] md`) → first bat died after SYNTH_OK → `call vivado` impl+bit → post_route WNS/WHS met → write_bitstream unique name → SHA → STOP.

EVIDENCE_MATRIX:
| Claim | Class | Artifact |
| Unique bit exists | FACT / PASS_IMPLEMENTED | BIT_SHA256.txt / uart_r2_rkb_edge_candidate.bit daaca9c1 |
| CT1 not reused | FACT | build_ct1 bit 8bfd993d still matches |
| Post-route setup/hold met | FACT | timing_route.rpt WNS 0.521 WHS 0.013; TIMING_PASS=NO |
| Integrated RKB 01-08 | PASS_INTEGRATED_XSIM | RKB_EDGE_INT_OBS a6e83f25 all 1 |
| 8/8 | NOT_RUN | no UART campaign on this SHA |
| PROGRAM_PASS / BOARD_PASS | NO | STOP_BEFORE_PROGRAM=YES |
| PACK_ABI_24_24_PASS | NO | owner KEEP |
| XSim vs bit MIG | FACT | mig_ui_bram in XSim; mig0 in bitstream |

SUCCESS_VS_FAILURE:
Success this handoff: unique routed bit + full SHA + STOP, CT1 untouched, no global PASS stamps, no program.
Failure would be programming without quoted SHA, writing `build_ct1`, stamping TIMING_PASS from WNS, or treating XSim 8/8 as board 8/8.

FIRST_DIVERGENCE:
CT1 silicon answers SID→fwd. This candidate walk is dest Directory→Posting→EdgeRecord.dst_id. Pack payload PAD=16 so Directory sits at published_root+16 (UART pack_loader writes payload only; isolated GOLD historically had CRC in dest[1]).

DECISIVE_TEST:
Independent sha256 of unique `.bit` equals BIT_SHA256.txt and differs from CT1. Owner program test is not run.

ROOT_CAUSE_OR_UNKNOWN:
Board campaign on this SHA is UNKNOWN until owner quotes `daaca9c1…` and silicon is exercised. XSim/MIG media mismatch remains a classified divergence, not a PASS.

REUSABLE_DECISION_PROCEDURE:
1. Freeze a unique CLASS and out-dir before synth.
2. Do not reuse a prior silicon SHA as the new architecture.
3. Integrated XSim first; then unique synth/impl/bit; then STOP with full SHA.
4. Treat owner “use board” as lease, not program approval.
5. On Windows, `call vivado` or the parent bat dies after the first Vivado.
6. Do not stamp TIMING_PASS from met WNS/WHS.
7. Disclose XSim stand-in vs bitstream MIG.

STRUCTURAL_GUARD:
96_bit.tcl aborts if WNS<0; refuses overwrite of CT1 path; PROGRAM=NO; no program_hw_devices.
BUILD.txt READY_TO_PROGRAM=NO STOP_BEFORE_PROGRAM=YES.

BLAST_RADIUS:
`arty_d/UART_R2/rkb_edge` and `build_rkb_edge` only. Isolated rkb_readback, CT1, freeze DCPs, gold.py, C RTL, FE256 freeze untouched.

VERDICT_BY_LAYER:
- PASS_INTEGRATED_XSIM: RKB-UNSET and RKB-01..08 on unique top with mig_ui_bram
- PASS_IMPLEMENTED: unique post_route DCP + unique bitstream file+hash
- TIMING_PASS: NO (ceiling)
- MIG_PASS: NO
- PASS_BOARD: NO / NOT_RUN
- RUNTIME_KNOWLEDGE_BINDING_8_8_PASS: NOT_RUN
- PROGRAM_PASS: NO
- PACK_ABI_24_24_PASS: NO

LESSON_TO_SHARE:
USE_BOARD_GRANT != PROGRAM_SHA. Windows vivado.bat `exit` kills parent cmd unless CALLed. Unique architecture needs unique bit dir.

NEXT_DECISIVE_EXPERIMENT:
Owner YES quoting `daaca9c1769d097cab03ccc7168aefd46cc91689b123618425531f4455fc9381` then program this bit only. Until then PROGRAM=NO.

OWNER_AND_STOP_CONDITION:
Stop here. Do not program. Do not stamp 8/8. Do not Pack24. Do not edit gold.py.

HANDOFF_STATUS: COMPLETE
