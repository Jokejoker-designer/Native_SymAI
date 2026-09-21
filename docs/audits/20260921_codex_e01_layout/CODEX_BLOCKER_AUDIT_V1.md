# CODEX delta blocker audit V1

Mode: DELTA_AUDIT_FROM_CHECKPOINT_X. Scope: integrated RKB-01 only. No board access, bitstream build, or DUT/source patch. All new outputs are under this audit directory.

## Result

**FACT — The integrated failure is a four-byte image-layout mismatch, not a lost query SID.** An audit-owned, paired integrated replay reproduces the failure with the 72 accepted words recovered from the pinned FAIL log, then gets five destination reads and hit B with the current aligned input vector. Both arms use the same compiled RTL snapshot, UART stimulus path, clocks, resets and query.

## Evidence identity

The handoff's FAIL still exists byte-for-byte at:

- `D:/FPGA/arty_d/UART_R2/rkb_edge/xsim/rkb_edge_int_xsim_38432.backup.log`
- SHA256 `871be4671f175d552b20d40458e9c31d6feb56437a874eeb65f0eb7805b587e3`
- Original final fatal: 14,120,835 ns, matrix 0/0/0/0/0/0/1/0.

The live paths have since been overwritten by a 13:48 run:

- Live log `bb3882e78eaab88821ae661c64cbcd9ffe457addd48cb4705de3bc77999fe59a`, finish 14,243,085 ns, reports integrated PASS_XSIM.
- Live OBS JSON `a6e83f258be3f61abefe4377c56cbf1a280a362c1c2f3a57ad807b9259207d73`, all eight fields 1. The handoff's original JSON hash `223aa74e...` was not found under the bounded rkb_edge surface.

New replay evidence and full hashes: [EVIDENCE_MANIFEST.json](E01_LAYOUT_REPLAY/EVIDENCE_MANIFEST.json), [fail.log](E01_LAYOUT_REPLAY/fail.log), [control.log](E01_LAYOUT_REPLAY/control.log).

## INT-B01 — S1 — Directory starts four bytes earlier than the reader contract

**FIRST_DIVERGENCE:** The earliest demonstrated layout-bearing payload mismatch is accepted stream word 50 at 2,401,785 ns in the audit replay: FAIL carries SID `00010100`, whereas the aligned control carries the fourth padding word `00000000`. Header metadata/CRC words also differ between the two valid input encodings; word 50 is the payload-layout divergence, not a claim that earlier serialized bytes are identical.

The failed image puts its directory SID at byte `0x1c` and its forward pointer at `0x20`. The walker reads the directory beat at `published_root + 16 = 0x20`.

| 32-bit lane of beat at 0x20, low to high | FAIL image | Aligned control |
|---|---|---|
| lane 0 | `00000030` | `00010100` — SID A |
| lane 1 | `00000000` | `00000030` — posting pointer |
| lane 2 | `000100b1` | `00000000` |
| lane 3 | `00010100` | `000100b1` |

**FACT — First failing walker decision:** at 3,601,835 ns, `S_DIR_WAIT` receives the FAIL beat at `0x20`, with `sid_r=00010100`; `match_dir=0`. At 3,601,845 ns it is done with `hit=0`. Therefore only the directory read occurs. It never issues Posting Header, Posting Entry or either EdgeRecord read.

**FACT — Control:** with the aligned input, `match_dir=1_00000030`; accepted reads are `0x20,0x30,0x40,0x50,0x60`; result is `hit=1`, `neighbor=00020100`. Its directory return is at 3,641,835 ns. The input is one word longer, so absolute time shifts by 40 us at 1 Mbaud; the request-relative path is the same through the directory response.

Evidence paths:

- Pinned FAIL log:118–122: payload RAM and actual destination layout, correct post-query `sid_r`, one read.
- `rkb_edge/dest_posting_edge_walk.sv:118–142`: SID latch, `root+0x10`, directory match and early miss exit.
- `rkb_edge/emit_rkb_edge_packs.py:19–31,53–56`: current producer explicitly pads 16 bytes and emits 100-byte payloads. The observed FAIL packet had 96-byte page payload and only 12 padding bytes before SID.
- Audit `fail.log:32,40–46` and `control.log:32–34,40–52` provide event timing and returned data.

**ROOT_CAUSE:** integrated producer/consumer disagreement over the location of Directory/Posting/EdgeRecord in the written payload. The source of the old pack generator's assumption is outside this delta audit; no isolated gate is reopened to reconstruct it.

**DECISIVE_EXPERIMENT:** E01, completed: same integrated RTL, FAIL-word replay versus current aligned vector. Exact signatures: reads=1/miss versus reads=5/hit B.

**MINIMAL_FIX_IF_PROVEN:** retain the integrated producer's 16-byte padding/layout and regenerate its dependent lengths/checksums consistently; bind that vector identity to the integration run. This producer correction was already present when the audit began. No SID/CDC change or permissive cross-beat directory scan is justified.

**BLAST_RADIUS:** integrated RKB image producer/vector packaging and run provenance. No Pack/FE256/C RTL changes; no re-opening of isolated RKB acceptance.

Blocks bit: YES if old input-layout contract can still be paired with the candidate. Blocks program: YES. Blocks integrated RKB-01: YES for the pinned FAIL input; disproved for the current aligned RKB-01 control.

## INT-B02 — S1 — The integration handoff no longer pins one runnable identity

**FACT:** `SOURCE_IDENTITY.txt:20–21` names baseline walk/cache `322e476d...` / `62ba5f1c...`. Current local files are `4275f60d...` / `cf79155a...`, both modified at 13:47:46. Current `RKB_EDGE_INT_SRC.json` pins only the new walk. Current xvlog and OBS/log are from the later run, not the pinned FAIL.

**FIRST_DIVERGENCE:** the artifacts at the handed-off live paths already have different hashes before this audit runs any experiment. An old manifest combined with a new log cannot establish a reproducible candidate.

**DECISIVE_EXPERIMENT/CHECK:** freeze one manifest containing the actual integrated top, both lookup modules, CDC, TB, input vectors, compile flags and source hashes; compare it with the build invocation. E01 provides an audit replay manifest, but does not replace the owner's full bitstream-candidate manifest.

**BLAST_RADIUS:** evidence/packaging only. Blocks bit: YES until the build candidate is unambiguously pinned. Blocks program: YES. Blocks causal explanation: NO; the byte-exact FAIL log and E01 suffice for INT-B01.

One baseline source comparison was used because a concrete new hash mismatch required it: `rkb_readback/dest_posting_edge_walk.sv`, hash `322e476d...`. The delta to the current local walk materializes `match_dir` into `md`; it does not change the lookup SID capture or intended directory addressing. No isolated TB or gate was reopened. The A/B replay uses the same current walk in both arms, so that refactor cannot account for the A/B difference.

## Questions resolved from this FAIL

- **Q-INT-1 / Q-INT-2 — FACT:** `walk_sid=0` in the FAIL log is a pre-query diagnostic (TB prints before `do_query`). The same FAIL log's next line has `sid_r=00010100`. E01 observes `eval_sid=00010100`, CDC lookup SID `00010100`, and directory-response `sid_r=00010100`. No SID loss is demonstrated. The walk does start; directory layout makes it exit after one read.
- **Q-INT-3 — FACT:** the compiled `u33/pack_mig_bind.sv` hash is `eade06c8...`; its `pack_quiescent` at lines 74–75 has no `dest_ui_rdy` or `app_rdy` AND. No raw-MIG-ready-as-quiescence reintroduction on this source graph.
- **Q-INT-4 — FACT:** xvlog selects local `dest_root_cache` and `dest_posting_edge_walk`. The top binds the walker to destination read data at lines 335–345; no directory/posting fixture module feeds that path. The only TB fixtures are independent `fx_dir/fx_post` arrays at TB:29–35, with no connection to DUT ports. `hits=[]` alone is not the proof; instance wiring and the actual five destination responses are.
- **Q-INT-5 — FACT:** E01 is the smallest completed discriminator: swap only the transaction input between the FAIL packet and aligned current packet, keeping compiled RTL and semantic query fixed.
- **Q-INT-6 — INFERENCE:** continuing integrated XSim is safe. Bitstream release/build selection and board programming remain NO until the corrected candidate identity/layout is pinned and its hardware-facing integration coverage is reviewed.

## Final required block

```text
FIRST_DIVERGENCE = Payload layout at accepted word 50; first wrong walker decision is S_DIR_WAIT on beat 0x20 (E01 FAIL at 3601835 ns).
TOP_BLOCKER = INT-B01: 12-byte payload padding versus reader's root+16 directory contract; PROVEN by integrated A/B.
SECONDARY_BLOCKERS = INT-B02: live FAIL paths overwritten; source manifest stale/incomplete.
ROOT_CAUSE_OR_UNKNOWN = ROOT_CAUSE_PROVEN_FOR_PINNED_RKB01_FAILURE: producer/consumer layout mismatch. No proven SID/CDC loss.
UNKNOWN_THAT_MOST_THREATENS_BOARD = Current XSim binds both domains to CLK100MHZ and uses BRAM stand-in; asynchronous/generated-MIG behavior is not exercised by E01.
FALSE_BLOCKERS_ELIMINATED = Checkpoint X remains closed. No isolated-walk, FE256, historical fixture or old UART gate reopened as a blocker.
DECISIVE_NEXT_TEST = E01 COMPLETED; next validation is the corrected, fully pinned integrated build graph under the intended clock/memory boundary.
NEXT_DECISIVE_EXPERIMENT = Do not repeat broad isolated tests; retain E01 as the old-layout-fails/current-layout-hits control.
MINIMAL_FIX_IF_PROVEN = Integrated vector/layout alignment and regenerated dependent metadata; already present in current producer. No product RTL patch by this audit.
BLAST_RADIUS = Integrated image producer/vector packaging and source/run manifest.
SHORTEST_PATH_TO_BOARD = Pin corrected sources+vectors; retain E01; validate hardware-facing integration; build isolated candidate; review exact hash/timing before any owner-authorized program.
SAFE_TO_CONTINUE_INTEGRATED_XSIM = YES
SAFE_TO_BUILD_BITSTREAM = NO
SAFE_TO_PROGRAM_BOARD = NO
REASON = Failure mechanism is explained, but the handed-off identity changed and current coverage is synchronous BRAM XSim. No board authorization or acceptance follows from this audit.
```
