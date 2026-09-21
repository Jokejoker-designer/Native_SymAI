# NATIVE_AI_REASONING_EXPERIENCE_V1

LANGUAGE=EN
TASK_ID: ASK_D_PUBLISHED_ROOT_Q1Q5
RUN_ID: 20260921T045200Z
OWNER_AGENT: AGENT_D
HANDOFF_STATUS: COMPLETE
REASONING_DISTILLATION_REQUIRED: YES
MAILBOX: NOT_SENT (owner relays)

CURRENT_CLAIM:
After poison dest[0], lookup uses SLOT1 `app_addr=28'h010_0000`, not dest[0].
`published_root==0` at TB `load_mem` return is a same-cycle sample vs `load_ack` NBA.
Query dest-reads one published beat. `published_root` is not an M4/ASTRA object.

RUN_PROVENANCE:
- Command: `D:\FPGA\arty_d\rkb_readback\run_rkb02_xsim.bat` exit 0
- `$finish` 2775 ns `DEST_COMPLETE+RKB-02 PASS_XSIM` (isolated DUT only)
- RKB02_OBS.json sha256 `9ec76529e99a946adb749d15951d17f2dfd3c694e2484f9704d04030113321e3`
- rkb02_xsim.log sha256 `550c1fbb60661addaa5b5d601ce14018cf35e3c8319b3bceab0e96c9d60d05a2`
- tb_rkb02_reloc.sv sha256 `f07d28c460a4a8d09d564c6c0c599521348cd84d4a19708718095e7acdc3a5f`
- D_PUBLISHED_ROOT_Q1Q5.json at `D:/FPGA/arty_d/rkb_readback/`
- PROGRAM=NO. gold.py not edited. No Pack24. No mailbox send. Board left plugged (owner).

OBSERVATION:
FACT: DEST_RD phase=3 t=2545 ns after poison dest[0]: `app_addr=0100000` `pub_root=0100000` `pub_v=1` `root_valid=1` `widx=1024` `d_addr=0100000` dest[0]=0 dest[1024]=SID+B hit=1 nb=`00020100`.
FACT: SAMPLE P2 at `load_mem` return: `pub=0000000` `root_valid=1` `pending=0100000` `have_wr=1` `pub_v=1`.
FACT: First P2 WR_BEAT `wr_beat=0100000`. Later P2 DEST_RD `pub_root=0100000` `have_wr=0` `widx=1024`.
FACT: SAMPLE P1: `root_valid=0` `pub_v=0` `have_wr=1`. P1 DEST_RD: `root_valid=1` `pub_root=0000000` `widx=0`.
FACT: Each query prints one DEST_RD line. `pack_runtime_dut` does not instantiate `posting_walk`.
FACT: Poison dest[1024] DEST_RD still `app_addr=0100000` `widx=1024` hit=0.

HYPOTHESES:
H-A: After P2, published beat is SLOT0 (`pub=0` true). REJECTED by DEST_RD `widx=1024` and poison dest[1024] miss.
H-B: TB `pub2=` sample is stale vs `load_ack` NBA. CONFIRMED: SAMPLE P2 `have_wr=1` `pub=0` `pending=0100000`; dest_rd `have_wr=0` `pub_root=0100000`.
H-C: `pending_root` never latched SLOT1. REJECTED: first P2 wr_beat=`0100000`, pending=`0100000`, dest_rd pub_root=`0100000`.
H-D: UNKNOWN until dest_rd dump. CLOSED by this run.

HOW_TRACE:
Pack P2 writes SLOT1 first → `wr_beat_v` latches `pending_root=28'h010_0000` `have_wr=1`.
`pack_loader` `S_COMMIT` NBA `load_ack=1` `state=S_OK`. `S_OK` is not `loader_busy`, so `pack_quiescent=1` on the posedge where `dest_root_cache` sees `load_ack` and NBA-copies `pending_root` → `pub_root`.
TB exits `load_mem` on `pack_quiescent` and samples `published_root` in the active region before that NBA → `0000000`.
Query later: `app_addr=pub_root=0100000`, one UI read, `widx={addr[21:20],addr[13:4]}=1024`.

EVIDENCE_MATRIX:
| Claim | Class | Artifact |
| Q1 dest_rd after poison dest[0] | FACT | log DEST_RD phase=3; JSON dest_rd_after_poison_p1 |
| Q2 pick B | FACT | SAMPLE P2 vs DEST_RD phase=2/3 |
| Q3 SAMPLE root_valid | FACT | SAMPLE P1=0 SAMPLE P2=1 |
| Q4 one dest-read | FACT | dest_root_cache S_RD/S_WAIT; one DEST_RD per query |
| Q5 not M4/ASTRA | FACT | dest_root_cache published_root=pub_root 28-bit UI addr |
| RKB 8/8 | NOT_RUN | no stamp |
| PACK_ABI_24_24_PASS | NO | owner KEEP |

SUCCESS_VS_FAILURE:
Success: dest_rd-cycle $display answers Q1-Q5. Failure would have been inferring SLOT0 from SAMPLE pub=0, or walking dest[] in the TB.

FIRST_DIVERGENCE:
TB `published_root` sample at `pack_quiescent` vs `dest_root_cache` `pub_root` after `load_ack` NBA.

DECISIVE_TEST:
Instrument `always @(posedge clk) if (dest_rd_pulse)` and re-run `run_rkb02_xsim.bat`. Phase-3 line is the Q1 record.

ROOT_CAUSE_OR_UNKNOWN:
`pack_quiescent` includes `S_OK` (`loader_busy=0`). That is the same posedge `load_ack` is visible to `dest_root_cache`. Sampling the output port there is pre-NBA. Lookup address after P2 is SLOT1 `28'h010_0000`. UNKNOWN remaining: UART dest export / board `published_root` (NOT_RUN).

REUSABLE_DECISION_PROCEDURE:
1. Do not treat `published_root` sampled at `pack_quiescent` as the lookup address.
2. Print `app_addr`/`pub_root`/`root_valid`/`widx` on `dest_rd_pulse`.
3. Relocation SoT remains double-poison dest beats, not the probe.
4. Query on this DUT is one dest-read of `pub_root`, not a dest[] walk.

STRUCTURAL_GUARD:
Do not AND TB `pub==SLOT1` taken at `load_mem` return. Gate on dest_rd-cycle `app_addr`/`widx` or wait a cycle after `load_ack`. Do not stamp 8/8 / PACK_ABI / PROGRAM_PASS.

BLAST_RADIUS:
`tb_rkb02_reloc.sv` $display + JSON fields only. `dest_root_cache.sv` / C RTL / gold.py / FE256 freeze / bitstream untouched. Mailbox not sent.

VERDICT_BY_LAYER:
PASS_XSIM isolated DUT dest_rd dump. NOT_RUN UART dest, RKB-04/05/06, 8/8. NO PACK_ABI_24_24_PASS / PROGRAM_PASS / BOARD_PASS.

LESSON_TO_SHARE: PUBLISHED-ROOT-SAMPLE-RACES-LOAD-ACK-NBA-20260921T045200Z

NEXT_DECISIVE_EXPERIMENT:
RKB-04 dest-backed Posting+EdgeRecord XSim (owner ordered). Do not fake neighbor-word poison. PROGRAM=NO unless owner YES quoted SHA.

OWNER_AND_STOP_CONDITION:
Owner: no mailbox; board stays plugged. D does not UART/program this run. Do not self-stamp 8/8.
