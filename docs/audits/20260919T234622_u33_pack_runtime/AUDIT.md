# Independent U33 Pack transport and runtime binding audit

FACT — Audit snapshot: 2026-09-19 23:46 +07. Evidence hashes and source paths: [evidence_manifest.json](evidence_manifest.json). This is an independent assessment, not architecture authority or an acceptance stamp.

FACT — Only this new audit directory was written. No product RTL, Canon, B gold, AGENT_C RTL, freeze DCP, H/H_OBS artifact, board state, or running simulation was changed. No simulation or board experiment was launched.

## 1. EXECUTIVE FINDING

- FACT — Current inspected U33 source has two disconnected data paths: Pack writes through `pack_loader → mig_ui32 → mig_ui_mux → generated mig0`; the candidate query chain reads initialized `dir_a.mem` / `post_a.mem`, with no MIG request interface.
- FACT — The stronger limitation is that U33 UART query ingress is disabled: `u_qhost.in_valid=0`; `tb_steer` and `tb_q_valid` initialize to zero with no product writer. Therefore “silicon is currently answering from BRAM” is not established. The query modules are INSTALLED_BUT_NOT_CAUSALLY_ACTIVE for normal UART traffic.
- INFERENCE — `PACK_TO_RUNTIME_KNOWLEDGE_BINDING_MISSING` is CONFIRMED for this inspected U33 source boundary. The literal reference claim “active query currently traverses BRAM rather than committed DDR” is PARTIALLY_CONFIRMED: the candidate read implementation is fixture-backed, but its live ingress is disabled.
- UNKNOWN — U33 MAG first causal divergence on silicon. The raw reply is known; loader P0/P1 and the upstream accepted beats are not captured on the failing board transaction. The runtime binding hole is not an explanation for MAG.
- FACT — Generated-mig0 five-V04 has now finished with five GOLD, `$finish` at 12,207,195 ns, log SHA256 `0778d0a9b939a498982758707d67cdca1e83db06610ccd27c4859b4514406256`. The earlier “still V04_2” snapshot is obsolete.

## 2. U33 MAG

### Scope and current evidence

FACT — The on-disk U33 bit hashes to `ff399e0bb9e6ff6c91caf3b769270b03ca9cfb2ea317035a5f3533031338a350`. `build_u33/program.log:28,55–59` records this identity, device `xc7a100t_0`, Digilent `210319BE776EA`, startup HIGH and no supported soft debug cores. `PROGRAM.txt` was last written at 20:39:19 +07. This proves recorded programming history, not current independent SRAM readback; current residency is UNKNOWN without board access.

FACT — Original `PACK24_U33/CLEAR_V04_24.json` records four GOLD then fifth-V04 `0200015a`, and a prior CLEAR timeout/retry. Later `PACK24_U33_REPROG/CLEAR_V04_24.json` records three GOLD then MAG within that campaign, with CLEAR timeouts/reopen in between. `PACK24_U33_PROBE/PROBE.json:103–111` records one 52-word host buffer, one BEGIN, `nwritten=208`, P0=BEGIN/P1=MAGIC; its P3 reply is MAG at lines 58–79. These are different histories, not repeated proof of a fifth-commit law.

| Boundary | Classification and actual knowledge |
|---|---|
| Host intended words | FACT: canonical V04 has 52 words, one exact BEGIN followed by MAGIC; later probe records this buffer and full serial write return. This is the first known-good source boundary, not a pin trace. |
| FPGA UART receive / FIFO / steering / CDC | UNKNOWN on the board failure. No accepted-beat trace at these hops. |
| Loader P0 / P1 | UNKNOWN on silicon. FACT in RTL: accepted OP_BEGIN sets `rx_words=0`; the next accepted payload is stored in `hw0`; BAD_MAGIC is checked later. |
| Board reply | FACT: four received bytes `5a010002`; the implemented token encoding is NAK reason 01. This is the first directly observed bad output. |
| Internal bad predicate | INFERENCE from that encoding and inspected RTL: `hw0 != 3149414E` after a 128-byte BEGIN. It does not determine the value of `hw0`, whether BEGIN was duplicated, or which hop changed data. |

FACT — Relevant assignments are `pack_loader.sv:333–349`, `385–391`, `416–439`, `618–620`; U33 top status packing is at `375–376`. No MIG read response is assigned to `hw0`; memory readback is used separately at loader `590–594`.

### A materially wrong inference in the latest probe

CONTRADICTED — `u33_leftover_probe.py:4–6` and `U33_PROBE.md` infer “P1/P2 silent, therefore extra BEGIN is concurrent with P3.” The loader does not reject immediately when it receives BEGIN or the first non-MAGIC payload. It waits until `rx_words+1 == need_words`, then S_CRC_WAIT/S_DEC. A pre-existing accepted BEGIN can wait silently; one dummy payload word still does not complete its 32-word manifest. Therefore `P1 n=0` and `P2 n=0` do not prove an empty loader and do not locate the extra beat in P3. The phase string `V04_CONCURRENT` is a host classifier, not a hardware observation.

FACT — K1 TAP simulation measures internal idle/accepted beats in its own BRAM test. Board probe P1 measures only absence of UART output. Those observables are different; agreement on “nothing returned” cannot transfer the internal-empty conclusion from simulation to board.

| Hypothesis | Verdict and discriminator |
|---|---|
| duplicate BEGIN | SUPPORTED as a sufficient injected XSim mechanism; UNKNOWN on silicon. Count accepted BEGIN separately at UART, FIFO, CDC source, CDC sink and loader; capture P1 value. |
| missing MAGIC / shifted header | UNKNOWN on silicon, NOT_TESTED for its actual wire history. Compare accepted sequence, not just BEGIN count. |
| stale FIFO word | UNKNOWN as a cause. FACT: `rd_data` may retain BEGIN while `rd_valid=0`; that is not a beat. Capture actual FIFO pop and flush. |
| CDC replay | CONTRADICTED in sampled normal CLEAR BRAM tests; UNKNOWN for board reset/timing histories. Stable-reset req/ack protocol does not normally duplicate a request. Capture both reset domains and both acceptance counts. |
| unlocked pop | FACT: top discards unlocked non-BEGIN. UNKNOWN as board cause. `f_ready` can pop during CLEAR hold while CDC valid is gated; this can discard words, not by itself create an exact BEGIN. |
| UART residual/gap/framing | UNKNOWN. U11 partial-word gap reset and bad-stop handling provide possible shifted-word paths. A gap after the first BEGIN byte producing mute does not test a gap within MAGIC after a valid BEGIN. |
| reset/CLEAR race | UNKNOWN on board. CELL B overlap gives mute, not this four-byte NAK. Capture reset/flush and transfer ordering rather than patching overlap. |
| loader carry-over | CONTRADICTED as an unconditional “every GOLD poisons next” model; UNKNOWN for ineffective reset or physical fault. Capture state/opcode/rx_words across CLEAR and first payload. |

FACT — `WAIT_AFTER_ACK_S=0` does not remove the imported reader's ≥50 ms RX-idle tail (`u9/uart_r2_u9_board_test.py:126–133`); GOLD also gets a 0.2 s drain. Original CELL D's 1000-cycle timeout is 10 µs, not the recorded 3-second board timeout. The original aggregate `n0=0` omits transient CLEAR timeouts that are still visible in `recs`.

INFERENCE — A code-level alternative requiring no extra BEGIN is: correct BEGIN; MAGIC bytes `4e 41 49 31`; gap after `4e` exceeding U11's partial-word MARK limit; then `41 49 31 01` forms `01314941`. `uart_rx_word.sv:89–95` implements the partial reset. Occurrence on the board is UNKNOWN; this is not a newly executed test or grounds to patch UART.

FACT — The existing harness `fifo_rd_fire` at `u32/pack_uart_dualclk_harness.sv:294` excludes CLEAR hold/take, whereas actual FIFO pop is `f_valid && f_ready`. An observer that trusts this exported signal can hide drops. Measure actual handshakes in any new diagnostic.

CONTRADICTED — “Generated MIG necessarily causes fifth MAG” is contradicted by the completed five-GOLD test. UNKNOWN — board-only memory-related timing/backpressure effects remain possible; a clean sampled XSim does not eliminate them universally.

## 3. PACK WRITE PATH

FACT — Source → sink:

`host RegionDescriptor.ddr_offset → OP_REGION hw1 → rg_ddr[n_rg] → slot_base + rg_ddr[wr_sel][27:0] + page_offset_low16 + 4*wr_idx → mig_ui32.mem_addr → beat_r / lane_r → mux A → generated mig0.app_* → DDR interface`.

FACT — `pack_abi24_gold.py:239–267` serializes host-supplied `ddr_offset`. Loader `488–490` copies it into a two-entry region array; `511` / `535` capture page offset low 16 bits. Loader `636` performs address addition. No semantic allocator chooses these offsets. FPGA placement contribution is fixed slot base 0 or `0x00100000` (`30`, `215`).

FACT — `mig_ui32.sv:109–116` uses lane `mem_addr[3:2]` and assigns `beat_r={mem_addr[27:4],4'b0}`; `65–76` emit address/data/mask. `mig_ui_mux.sv:94–104` passes Pack A's address and command without remapping. Top `255–277` connects Pack to mux A, FEM to B; top `53–62` connects the mux output to generated mig0. These are actual assignments, not an assertion that all byte/native-address geometry has been independently validated.

FACT — Address narrowing occurs: region bits `[31:28]` and page-offset bits `[31:16]` do not participate in the write address; the sum is 28 bits. No corresponding full-address bounds/alignment validation is present in those Region/Page branches. INFERENCE — outside the narrow tested profile this permits aliasing/wrap hazards. It cannot explain BAD_MAGIC, which precedes these operations.

FACT — The adapter waits for both command and WDF acceptance, reads back the targeted lane and checks data, then responds. The loader drains outstanding writes and checks a region first word before S_COMMIT. At S_COMMIT (`603–608`) it sets `active_generation=man_generation`, toggles `slot_bit`, raises `load_ack`, and returns through S_OK to IDLE.

FACT — Region descriptors remain local loader scratch until reset/overwrite; no semantic-ID→pointer table, directory refill, public committed root descriptor, or runtime profile update is generated by the loader. `slot_bit` toggles to the next write slot; it is not exported as a committed reader root. VALIDATION_CLEAR resets loader state, region scratch, active_generation and slot selection; it does not erase DDR bytes.

INFERENCE — Current COMMIT is loader acceptance plus storage checks, not atomic publication of a queryable knowledge image. Pack24 V04's small sentinel payload is also not evidence that a graph image has been materialized.

## 4. QUERY READ PATH

FACT — Candidate source → sink if stimulated:

`QueryRecord → query_result_bind → query_walk_bind.sid={qb[17:14]} → bounded_walk.cur → exact_directory semantic_id comparison → fixture posting page → first_neighbor → bounded_walk.end_id`.

FACT — `subject_id` is a full 32-bit semantic ID: ABI §04.3, `query_walk_bind.sv:120`, and directory `86`. It is not used directly as a DDR address.

FACT — `exact_directory.sv:25–31` initializes/reads a local 128-bit array from `dir_a.mem`. `posting_walk.sv:25–31` does the same with `post_a.mem`. Neither module has a dynamic memory-write/fill port or MIG command port. The exporter builds these files from `fe256_gold.build_store_a`, allocates sequential posting byte offsets, and derives edge refs as `edge_id*32` (`export_directory.py:11,38–47,50–95`); this is offline fixture construction, not a loader-updated address map.

FACT — These are actual U33 synthesis inputs: live PACKAGE `94_synth_uart_r2_u33.tcl:55–61,79–82`; `build_u33/synth.log:543,545` confirms both files were read. Synthesis also reports BRAM instances under `u_cr` at `2070–2075`. The 13 checked repo/package RTL and fixture pairs match hashes. This does not substitute for a complete historical input manifest or prove UART can trigger those instances.

FACT — `posting_walk.sv:108–109` indexes only `fwd_ptr[15:4]` / `rev_ptr[15:4]`. Upper 16 bits are ignored; lower alignment bits are discarded without checking; default N_POST=2048 is smaller than the 4096-index range of that slice. For example `0x00000010` and `0x00010010` select the same index. INFERENCE — this is a restricted fixture implementation, not lossless general T2 pointer resolution required by §02.4.1.3a.

FACT — Posting reads only header node/count, then the first 64-bit entry (`116–136`). It does not walk next-page pointers, iterate all candidates or validate a dereferenced EdgeRecord. `first_edge_ref` reaches `bounded_walk.eref` (`28,40`) and is never used. The walker updates `cur=nb` (`98`) directly from fixture neighbor_id.

FACT — Directory generation/kind/flags reach local wires but do not govern this traversal. Query generation/namespace are not compared against the committed pack's generation. QueryResult echoes those fields; echo is not validation. Relation handling in astra_qeval is limited precheck, not edge validation.

FACT — `query_result_bind.sv:101–131` packs status from `astra_qeval` plus echoes/CRC; `w_end`, `w_hit`, `w_cnt` do not populate an answer. `astra_qeval.sv:37–64` has no graph evidence input and emits fail-closed SEARCH_INCOMPLETE for supported ordinary queries. Changing a fixture neighbor need not change StructuredResult bytes at all, although traversal latency can change.

FACT — Actual U33 top disables UART query input (`209`), initializes TB steering off (`190–195`), and has no product writer for that steering. DDR involvement in the candidate query data path: NO. Live semantic-query execution through U33 UART: NOT_ENABLED, not demonstrated BRAM reasoning.

## 5. PACK ↔ RUNTIME BINDING

| State / module | FACT: actual behavior |
|---|---|
| active_generation | Loader sets it at commit; top only connects the output wire to u_ld. No query/profile consumer. CLEAR resets it to UNSET. |
| active_id_max | runtime_profile reset value FFFFFFFF; top ties prof_wr_valid=0, so Pack cannot update it. |
| K_hard | runtime_profile reset value 8; same disabled write path. |
| directory contents | Build-initialized fixture, no Pack fill/update port. |
| posting contents | Build-initialized fixture, no Pack fill/update port. |
| T2 base | Loader has fixed two-slot bases; FEM has separate compile-time FEM_BASE=0x0200000. No query root/base register published from commit. |
| slot selection | Internal loader bit toggled by commit, reset by CLEAR; no committed-slot output to query. |
| generation metadata | Manifest generation is stored locally; fixture directory generation is separately initialized and ignored by traversal. No shared committed-generation boundary. |
| runtime_profile | INSTALLED_BUT_NOT_CAUSALLY_ACTIVE as a loadable Pack profile: prof_wr_valid=0. Its default outputs do fan out. |
| SPEAR | INSTALLED_BUT_NOT_CAUSALLY_ACTIVE: q_start=0, cand_valid=0, q_end=0; no candidate stream. |
| Q* | INSTALLED_BUT_NOT_CAUSALLY_ACTIVE: prop_start=0, upd_start=0; no retrieve/search control. |
| FEM learner | INSTALLED_BUT_NOT_CAUSALLY_ACTIVE for learning: ing_valid/rep_valid/etc. tied off. Memory adapter connection alone is not learning/persistence integration. |
| query chain | INSTALLED_BUT_NOT_CAUSALLY_ACTIVE from live UART as above; standalone/TB stimulation is a different boundary. |

FACT — Primary top anchors: `u33/arty_a7_r2_top_m4_mig_candidate.sv:207–232,250–277,284–322,334–354`; `spear_profile_bind.sv:34–40`; `runtime_profile.sv:15–21`. There is no `Pack COMMIT → runtime_profile → directory/posting` connection in this top.

## 6. HYPOTHESIS VERDICT

| Claim | Verdict | Evidence scope |
|---|---|---|
| Pack→runtime knowledge binding missing | CONFIRMED / INFERENCE from complete inspected port/assignment trace | U33 source, with matching current repo/package modules; not every possible repository top. |
| Semantic query bound to committed DDR | CONTRADICTED for this U33 path | No query memory port, no commit publication; live ingress disabled. |
| Runtime currently answers from BRAM | PARTIALLY_CONFIRMED | BRAM fixture source is FACT; active semantic answering is contradicted by disabled ingress and fail-closed result pack. |
| Binding hole causes MAG | CONTRADICTED as a direct causal explanation | Loader header rejection has no directory/posting/ASTRA dependency. |
| Exact extra BEGIN was observed on board | INSUFFICIENT_EVIDENCE / UNKNOWN | Host buffer and NAK only; injected test gives sufficiency, not occurrence. |
| P1/P2 silence proves no leftover | CONTRADICTED | Header decision requires complete BEGIN payload. |
| Repeating generated-MIG five is the best next test | CONTRADICTED as information-gain priority | It already finished clean and still lacks the failing silicon accepted beats. |

## 7. FALSE-PASS RISKS

- INFERENCE — Relocation-only A→B at P1 and P2 can pass while static BRAM continues answering B. Require content intervention and observed, causally necessary memory reads.
- FACT — Current StructuredResult tests validate status/echo/CRC, not graph answers (`tb_query_result_bind.sv:104–126,140–151`). Constant SEARCH_INCOMPLETE across images is not semantic invariance.
- FACT — Shadow-bind TB forces `tb_steer` and query signals (`tb_m4_query_result_shadow_bind.sv:107–122,159–166`). Passing it does not demonstrate live UART ingress.
- INFERENCE — Counting any MIG reads can falsely pass using Pack write-readback/sentinel reads. Count query-tagged reads after commit/drain; require their returned bytes to affect traversal.
- INFERENCE — Poison only directory/posting and a neighbor-only walker can appear correct without dereferencing edge_ref. Keep posting identical while changing only canonical EdgeRecord relation/validity to require fail-closed behavior for inconsistent evidence.
- FACT — Fixture and expected-neighbor files share one exporter; agreement alone does not establish independent truth or DDR authority.
- INFERENCE — Ignored generation, low-bit address aliasing, dummy DDR reads, TB-provided pointers, precomputed host answers and direct hierarchical writes to DUT caches can all conceal the missing binding.
- FACT — “EXACT SAME QueryRecord across successive new-generation commits” conflicts with the current generation contract: QueryRecord carries required knowledge_generation, and loader rejects non-increasing pack_generation. A test must distinguish unchanged semantics from unchanged 32-byte request.

## 8. MINIMUM CAUSAL EXPERIMENT

NOT_TESTED — Future semantic gate design, not the next action and not implemented now. Use one direct relation A→B (a second B→C edge is unnecessary for this first gate), then A→C. A=0x1001, B=0x1002, C=0x1003 are semantic IDs, never pointers in the query.

| Cell | Pack / memory intervention | Required observation |
|---|---|---|
| S1 | Graph A→B at P1; incompatible static fixture | Query semantic result B from the chosen canonical runtime source; actual query-tagged record reads. |
| S2 | Same graph moved to disjoint P2; old P1 poisoned | Same semantic result B; memory reads use P2 and do not alias P1. Choose address differences above bit 15 as well as low bits. |
| S3 | Committed graph A→C at P2; stale fixture and P1 still say B | Result changes to C. Static-fixture B is failure. |
| S4 | Leave posting A→B unchanged but invalidate/change the referenced EdgeRecord; or suppress the required read response | Query must not return the old accepted B as valid evidence. It must fail closed or visibly wait for the required read. This kills unused-edge_ref/dummy-DDR-read passes. |

INFERENCE — For byte-identical QueryRecord, run S1/S2/S3 in isolated fresh DUT epochs with the same legal generation and identical query bytes. This proves only the bounded mapping/content intervention, not crash-safe persistence or continuous updates. A continuous multi-commit variant must advance query generation and CRC; only semantic query fields remain identical. Never disable generation checks just to preserve a test slogan.

INFERENCE — Keep graph objects in one bounded region if possible: the current loader accepts only 1/2 regions and uses a 64-word page RAM. A proposed dir/post/edge three-region image is not automatically supported. The gate must use legal pack encoding and an explicitly approved root/layout contract; no B-gold changes or synthetic loader bypass.

INFERENCE — Pass evidence must include commit epoch/root, accepted query, query memory addresses/responses, dereferenced record checks and selected semantic result. A BRAM destination model is a pre-board causal test only; a board gate requires generated MIG and controlled memory/caching observations. Current U33 cannot execute this gate without a future binding candidate; its present fail-closed output must not be relabeled as a semantic answer.

## 9. YOUR INDEPENDENT ARCHITECTURE OPINION

INFERENCE — The intended separation of semantic identity, directory resolution and typed T2 records is sound. The inspected implementation is a set of partial slices, not a closed knowledge runtime. The problem is not that the directory uses BRAM; Canon itself specifies T1 BRAM hot directory entries and T2 canonical records.

INFERENCE — Prefer a generation-tagged T1 directory cache/materialized index plus canonical T2 posting/EdgeRecord reads. Add one D-owned memory-resolution boundary which validates full-width pointer, range, alignment, region membership and generation before explicit native-MIG packing. Q* should choose search actions; it should not discover physical addresses.

INFERENCE — Use a committed root descriptor containing the active placement/region map and generation. Build/validate the new image and inactive directory bank, drain writes, then publish root/profile/cache epoch atomically. Invalidate stale T1 copies on publication. A two-bank directory simplifies atomicity at BRAM cost; a single bank with generation-tagged invalidation costs less memory but complicates refill/availability.

INFERENCE — Deterministic address derivation can work for a tightly bounded dense ID domain, but must be an explicit checked mapping; `semantic_id == address` or truncation is not acceptable. A full relocation table is useful when independent objects move frequently but adds capacity, latency and consistency costs. A generation-root plus BRAM index is a smaller first implementation here.

FACT — Canon §02.4.8 currently defines `edge_ref` as a 32-bit T2 EdgeRecord byte address, not semantic edge ID/handle. INFERENCE — preserve that meaning for the minimum gate and relocate/validate physical references consistently at load/publication. A future handle/relative-offset design could reduce rewrites, but would change the current field contract; it requires authority review and must not be silently substituted.

INFERENCE — Host packer may know placement while constructing a valid image; ABI already carries ddr_offset. The semantic query client should know IDs, relation/context and generation, not per-query DDR pointers or a host-computed traversal. FPGA runtime owns resolving the query against the committed image.

INFERENCE — Keep P0/P1 transport as the board priority. P2 read-only binding audit can proceed without waiting for transport; it has now identified the gap. P3 should remain a bounded causal gate specification until the binding work is authorized. P4 live ingest and P5 ASTRA semantics are not acceptance substitutes for P3. SPEAR/Q*/FEM remain later; FEM persistence remains blocked until Pack is B-classifiable.

## 10. NEXT SINGLE ACTION

INFERENCE — Highest information gain: one owner-authorized silicon accepted-beat capture campaign on a new, isolated observation-only U33-derived identity. This is a proposal, not authorization to build/program and not an overlay of frozen U33/H/H_OBS.

NOT_TESTED — Concrete diagnostic contract:

1. Preserve all functional product sources byte-for-byte, no pad/resync/barrier/MAGIC change. Add only debug observation in an isolated diagnostic build, with its own source/bit hash and timing report. Current bit has no supported ILA; no claim of observing it retroactively.
2. Observe clk100 UART word handshakes, actual FIFO write/pop, pack_lock/steer, CLEAR/flush/reset and CDC source acceptance; observe ui_clk CDC sink/loader acceptance, state/opcode/rx_words/hw0 and reject reason. Capture from CLEAR through the failing header, not only after the next recognized BEGIN; a pre-existing BEGIN must remain visible. Use domain-local event-qualified capture and a common observed CLEAR epoch for correlation.
3. Drive canonical V04 with exactly one BEGIN and preserve host bytes/write counts/timestamps. Trigger on a non-MAGIC first payload or BAD_MAGIC with pre-trigger accepted-beat history; compare complete word sequences including missing/extra words. If possible correlate a passive physical UART trace to separate host/FTDI wire behavior from FPGA decoding.
4. Stop at the first reproducible failing trace and name the earliest divergent boundary. If the diagnostic identity does not reproduce within the bounded session, record NO_REPRO_ON_DIAGNOSTIC_IDENTITY and stop; instrumentation/timing differences cannot absolve U33. No speculative fix follows a clean run.

FACT — This audit did not take COM12/JTAG. The current lease ledger says HELD by AGENT_D exclusively (`board_lease.json:7–19`), and the user explicitly requires owner approval for such actions. Build/program/board access for the proposed new diagnostic therefore remain unexecuted pending explicit owner scope and coordination with D; no lease or programming authority was inferred from older mandates.

FACT — PACK_ABI_24_24_PASS=NO; BOARD_PASS=NO; PROGRAM_PASS=NO; MIG_PASS=NO; TIMING_PASS=NO; ASTRA_PASS=NO; M2_PASS/M3_PASS not stamped; overlay=NO; kill xsim_u33m=NO. The original mig0 simulation exited on its own according to its completed log.
