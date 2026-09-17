# D-EXPLORE-ACCURACY-FIRST-TRANSPORT

TASK: D-EXPLORE-ACCURACY-FIRST-TRANSPORT
STATUS: COMPLETE (architecture review only; no prototype)
OWNER: AGENT_D
MODE: OPEN ARCHITECTURE REVIEW
RUN_ID: 20260917T060400Z
PROGRAM=NO
PRODUCT_RTL_CHANGED=NO
PACK_GOLD_CHANGED=NO
CANON_CHANGED=NO
CURRENT_H_ROOT_CAUSE_STATUS: UNCHANGED
PACK_ABI_24_24_PASS: NO
BOARD_PASS: NO

## ARCHITECTURE LOCK (live, not docs-only)

| Item | Lock |
|---|---|
| Product UART on identity H / M4+mig candidate | 115200 8N1, little-endian **32-bit words**, no §4.9 SOF/LEN/CRC on the wire |
| CLEAR | exact 32-bit `0x44524743` on assembled word; debug/validation only |
| Pack semantic ABI | BEGIN/REGION/PAGE/END streaming; B-owned gold; **do not change meaning** |
| Query path | 32-byte QueryRecord + CRC16 after **8 words** collected |
| Dest | silicon `mig0`; XSim harness `mig_ui_bram` |
| Forbidden this task | product RTL edit, gold edit, new identity bit, replacing H/ILA work |

Older nested MASTER UART nibble maps are **reference-only**. Live path is the candidate top + `uart_rx_word`.

---

## REQUIRED OUTPUT (compact)

CURRENT_TRANSPORT_ARCHITECTURE: serial 8N1 → `uart_rx_word` 4-byte assembler (`bix`) → exact-word CLEAR → LUTRAM word FIFO → toggle CDC → streaming `pack_loader` → MIG/BRAM writes **during PAGE** → generation flip at END → ACK/NAK muxed with query TX.

CURRENT_TRANSACTION_BOUNDARY:
- CLEAR: 1 assembled word (4 bytes) if and only if `in_data == 0x44524743`.
- Query: 8 words after first word `[15:0]==0x4E51`.
- Pack: multi-command stream (BEGIN length then REGION/PAGE/END); **not** one sealed UART frame.

CURRENT_COMMIT_BOUNDARY:
- PHYSICAL_BYTE: UART stop-bit sample (`uart_rx_word` STOP).
- WORD: `w_valid` after `bix==3`.
- TRANSPORT_FRAME: **none implemented** (canon §4.9 recommended, not on this UART).
- SEMANTIC_PACK_CMD: `pack_loader` S_DEC after command CRC (BEGIN/PAGE).
- PERSISTENCE: PAGE already wrote dest; `S_COMMIT` flips `active_generation` after sentinel readback.
- CLEAR: `debug_clear` resets loader/UI CDC; **does not** wipe dest payload.

CURRENT_BUFFER_OWNERSHIP_MODEL: slot/handshake FIFOs, not a sealed frame buffer. Ambiguous: 4th RX byte dropped if `w_valid && !w_ready` while `bix` still resets.

CURRENT_TIMING_DEPENDENCIES: UART PHY required; protocol uses host stop-and-wait per CLEAR+pack and ~50 ms host sleep; `QUIET_N=20000` (~200 µs) is implementation; consumer service rate can drop a completed word (RTL_FACT).

CURRENT_TEST_VS_BOARD_GAP: word TB skips UART/`bix`/FTDI/mig0; UART TB models serial+assembler+FIFO+CDC+BRAM, not FTDI/JP2/mig0; board has all physical layers. Extra `0x00` CLASS A is PASS_XSIM on UART TB and PRESENT on board; source of the extra byte on silicon is UNKNOWN.

EXISTING_FEATURES: see table below.

IS_ACCURACY_FIRST_TRANSPORT_NEW: **PARTIAL**

COMPATIBILITY_WITH_CURRENT_PACK: **OPTION B feasible** (outer §4.9 wrapper → existing 32-bit word stream → unchanged `pack_loader`). OPTION A (zero wire change) cannot add frame CRC. OPTION C/D not required for a transport experiment.

ARCHITECTURE_OPTIONS: OPTION_1 keep word UART + H measurement; OPTION_2 implement canon §4.9 wrapper (TRANSPORT_EXPERIMENT); OPTION_3 seal entire pack + delay all dest writes until END (conflicts with live PAGE write and §4.8 page flow).

TRADEOFFS: wrapper DETECT/CONTAIN byte-phase; does not name extra-byte source; changes diagnostic tokens; needs host+bit; Pack gold can stay if payload bytes identical inside the frame.

RESOURCE_ESTIMATE: per-command max PAGE 256 B ≈ 1 RAMB18 or LUTRAM; full A-01 (33 words) ≈ 132 B FF/LUTRAM; full multi-page pack as one buffer = several KB (avoid for R1).

LATENCY_ESTIMATE: 115200, 10 bits/byte → 86.8 µs/byte, 347 µs/word. §4.9 header+CRC ≈ 10 B ≈ 0.87 ms/frame. Host already waits for pack ACK. Collect-before-commit adds overlap delay (Pack CRC/MIG write starts later), not a different baud.

EXPECTED_EFFECT_ON: MAG DETECT/CONTAIN; UNSUP DETECT/CONTAIN; PARTIAL DETECT; MUTE DETECT or CONTAIN if length timeout; STICKY_MUTE NOT_ADDRESS or UNKNOWN (BUSY/no `debug_clear` / dest persist). Source of extra byte NOT_ADDRESS.

ROOT_CAUSE_MASKING_RISK: **HIGH** if a wrapper ships before ILA/first-divergence names the extra byte. Tokens would become FRAME_CRC/NAK instead of `0200075a` / mute.

MINIMUM_REVERSIBLE_EXPERIMENT: debug-only §4.9 RX wrapper + host framer; identity H / Pack gold / `pack_loader` unchanged; keep 0/1/2/3 extra-byte vectors on the **inner** word path.

RECOMMENDATION: **DEFER**
WHY: The accuracy-first UART frame is already canon §4.9 and is feasible as a wrapper, but H CLASS A/B first divergence on silicon is still UNKNOWN. Implementing now would hide the diagnostic that extra `0x00` maps to R_UNSUP/MUTE. Measure that source first. Do not replace H/ILA with a protocol rewrite.

OWNER_AUTH_REQUIRED: **YES** (any prototype RTL/host/bit). **NO** for this review document.

---

## 1. Is this actually a new transport architecture?

**PARTIAL.**

It is **new relative to the implemented UART** on the M4+mig / identity-H path.

It is **not new relative to Native AI architecture**: AGENT_B canon already recommends exactly this class of frame.

```281:291:NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT/04_ABI_AND_PROTOCOL.md
Recommended frame:

[SOF16] [PROTO_VER8] [FRAME_TYPE8] [LENGTH16] [SEQ16]
[PAYLOAD N bytes]
[CRC16]

Length and CRC make a dedicated EOF byte unnecessary. The transport uses explicit
ACK/NAK/sequence handling and host pacing.
```

Live silicon/candidate UART does **not** emit or parse that frame. It groups every 4 bytes into a word and lets CLEAR/Pack/Query interpret those words.

QueryRecord is already “collect 32 bytes → CRC → issue.” Pack UART is “interpret opcode on the first word of a command while later words are still arriving.”

---

## 2. Existing Native AI pieces (do not rebuild what already works)

| Concept | Classification | Evidence |
|---|---|---|
| Transaction buffering | PARTIALLY_EXISTS | Query: 8-word `qw[]` then issue. Pack: `page_ram[0:63]` for **one PAGE**, not whole pack. UART FIFO DEPTH=128 words elastic, not a sealed frame. |
| Pack framing | ALREADY_EXISTS | Opcode + length in `[31:16]` of command word (`pack_loader` S_IDLE). |
| Magic recognition | ALREADY_EXISTS / EXISTS_BUT_AT_DIFFERENT_LAYER | Pack `MAGIC_NAI1` after BEGIN body; Query `0x4E51` on first word `[15:0]`; CLEAR exact `0x44524743`. No transport SOF. |
| Length knowledge | ALREADY_EXISTS | Pack command length; Query fixed 32 B / result 48 B. CLEAR implicit 4 B. UART frame LENGTH16 missing. |
| Transaction ID | EXISTS_BUT_AT_DIFFERENT_LAYER | QueryRecord `txn_id`. Pack has `pack_generation`, not a UART SEQ16. |
| Generation ID | ALREADY_EXISTS | `pack_generation` vs `knowledge_generation` (§4.2/4.6). Flip at `S_COMMIT`. |
| CRC | EXISTS_BUT_AT_DIFFERENT_LAYER | Pack manifest CRC32 + page CRC32. Query CRC16. Result CRC16. **No UART transport CRC.** FEM persist CRC is another layer. |
| FIFO ownership | PARTIALLY_EXISTS | `word_fifo32` slot FIFO; simultaneous wr+rd is defined. Not a SEALED whole-buffer lock. |
| Commit semantics | PARTIALLY_EXISTS | Pack: PAGE writes dest **before** END; `S_COMMIT` is generation flip + ACK. Query: `q_valid` after 8 words. |
| ACK/NAK | ALREADY_EXISTS | Pack load ACK/NAK; CLEAR ACK/BUSY/ERR. Canon §4.8 also wants **per-page** ACK; live loader does **one** ACK/NAK at end. |
| Backpressure | ALREADY_EXISTS | valid/ready on word/FIFO/CDC/loader. |
| Request/response ordering | PARTIALLY_EXISTS | Host CLEAR then pack then wait. TX mux: CLEAR > query host > pack status. |
| Resynchronization | MISSING at byte phase | Only `uart_flush` (CLEAR success path) zeros `bix`. No SOF hunt. 2–3 extra bytes → CLEAR never matches → no flush → MUTE. |

---

## 3. Commit boundaries (traced from RTL, not assumed)

Path:

```text
PC → USB → FTDI → UART bits
 → uart_rx_word (byte sample + bix assembler)
 → pack_debug_clear (exact 32-bit CMD)
 → word_fifo32
 → uart_fe256_host OR word_cdc32
 → pack_mig_bind / pack_loader
 → mig_ui_mux → mig0 (board) or mig_ui_bram (XSim)
 → status CDC → TX mux → uart_tx_word
```

### Does downstream see partial / stale / mixed words?

**Partial frame as a Pack command:** YES, by design. S_IDLE consumes the first word as opcode immediately. Remaining words are accepted in S_RX. Downstream loader **does** observe a command before it is complete. After PAGE CRC, S_WRITE issues dest writes **before** END.

**Partial word as `w_valid`:** NO. `w_valid` is raised only on the 4th byte.

**Malformed complete word:** YES. One extra byte is folded into `acc`; the next three bytes complete a **valid-looking** wrong word. H12 PASS_XSIM: 1 extra `0x00` then CLEAR → `0200075a` (word `52474300`). That is transport phase error presented as Pack semantics.

**Word assembled from two logical host transactions:** YES if byte phase is leftover (`bix!=0`) after a previous message. CLEAR flush is supposed to zero `bix` **only on the success/quiet path**. BUSY path: no UART flush (comment + RTL in `pack_debug_clear`).

**Buffer while producer still filling:**
- `acc` in `uart_rx_word`: producer-only until 4th byte. Safe **until** phase error.
- FIFO: consumer reads committed slots. Standard.
- CDC `hold`: written when A handshake accepts; B copies on toggle. Safe if resets aligned.
- `page_ram`: filled during S_RX; read in S_WRITE. Not sealed against a following command until S_WRITE finishes; `s_ready` is 0 during write (`s_ready` only IDLE/RX/REJECT/EDRAIN).

Proven drop (not hypothetical):

```80:93:NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT/rtl/native_ai/board/uart_rx_word.sv
            if (bix == 2'd3) begin
              if (!w_valid || w_ready) begin
                w_data <= {sh, acc[31:8]};
                w_valid <= 1'b1;
                acc <= {sh, acc[31:8]};
              end
              bix <= 2'h0;
              st <= IDLE;
```

If the 4th byte completes while `w_valid && !w_ready`, the word is **discarded** and `bix` still returns to 0. That is a missing-word at the assembler, not a sealed retry.

CLEAR take is exact, not a scan:

```48:48:NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT/rtl/native_ai/board/pack_debug_clear.sv
  assign take = (st == S_IDLE) && in_valid && (in_data == CMD);
```

Pack dest mutation before generation commit:

```563:571:NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT/rtl/native_ai/loader/pack_loader.sv
        S_WRITE: begin
          ...
          else if (mem_cmd_valid && mem_cmd_ready) begin
            wr_idx <= wr_idx + 16'd1;
```

`S_COMMIT` later sets `active_generation`. Comment on bind: dest payload is **not** cleared by VALIDATION_CLEAR.

---

## 4. Ownership audit

| Buffer | OWNER_WHILE_FILLING | OWNER_WHILE_VALID | OWNER_WHILE_PROCESSING | WHEN_REUSABLE | Ambiguous? |
|---|---|---|---|---|---|
| UART `sh`/`acc`/`bix` | RX FSM | `w_valid` holds `w_data` | consumer on `w_ready` | after handshake or **drop** | YES: drop resets `bix` without delivering |
| `word_fifo32` | wr port / slot | `rd_valid` | rd handshake | after rd or CLEAR flush | NO for slots; YES that flush is only CLEAR success |
| CDC `hold` | A on accept | B `b_valid` | `b_ready` | ack toggle | NO if both reset together; query bind reset domain differs on top |
| `pack_loader` cmd regs | S_RX | S_DEC | S_WRITE/S_DRAIN | S_IDLE/S_OK/S_REJECT | NO |
| `page_ram` | S_RX PAGE | after PAGE CRC | S_WRITE | next PAGE | NO given `s_ready` |
| TX `acc` | `uart_tx_word` IDLE capture | shifting | UART PHY | word complete | NO |
| Query `qw[0:7]` | S_RX | S_ISSUE | walk | S_IDLE after TX | closer to sealed record |

---

## 5. Timing dependencies

| Dependency | Class |
|---|---|
| Start/data/stop sampling, `DIV=CLK_HZ/BAUD` | REQUIRED_BY_UART_PHY |
| 8N1, 10 bit-times / byte | REQUIRED_BY_UART_PHY |
| Host inter-byte delay | NOT required by RTL if bytes stay in one `bix` session; USB/FTDI grouping is UNKNOWN on silicon |
| Inter-word delay | IMPLEMENTATION_ARTIFACT (elastic FIFO 128). Backpressure can **drop** a word |
| CLEAR then pack spacing | REQUIRED_BY_CURRENT_PROTOCOL (host); FPGA `clr_hold` backpressures RX |
| ACK after CLEAR | REQUIRED_BY_CURRENT_PROTOCOL; `S_ACK` completes when TX **accepts** the word (start of shift), not end of UART (~347 µs remaining) — H16 hold-overlap PASS_XSIM |
| `QUIET_N=20000` | IMPLEMENTATION_ARTIFACT (~200 µs quiet / 1 Mbaud TB stray) |
| Host `timeout=0.05/0.2`, `sleep(0.05)`, pack `UART_TIMEOUT_S` | REQUIRED_BY_CURRENT_PROTOCOL (host) |
| `s_ready` low during CRC/write | REQUIRED_BY_CURRENT_PROTOCOL (consumer service) |
| No RTS/CTS | FACT (canon §4.9; host `dtr=False, rts=False`) |

Accuracy-first framing **cannot** remove PHY sampling. It can remove **semantic** dependence on leftover `bix` if a frame CRC fails closed and a resync rule resets `bix`.

---

## 6. Compatibility with Pack ABI

| Option | Feasible? | Notes |
|---|---|---|
| A. No Pack ABI change **and** no new outer bytes | NO for integrity | Cannot detect extra `0x00` without a check that is not already the Pack opcode. Guards (hold `w_valid`, ILA `bix`) are option A-ish but not accuracy-first transport. |
| B. Outer framing layer, Pack payload unchanged | YES | Canon §4.9. Wrapper outputs the same 32-bit words `pack_loader` already consumes. |
| C. Pack ABI version extension | NOT REQUIRED for experiment | Only if payload layout changes. |
| D. Fundamental ABI redesign | NO for R1 | Would smash B gold and Pack/ABI-24. |

Transport vs semantic: Pack CRC32 proves **manifest/page bytes after they are already word-aligned**. It does not prove UART byte phase. Query CRC16 **does** fail if the 32-byte record is shifted — that is record integrity, still after 4-byte grouping.

---

## 7. Wrapper sketch (not implemented)

```text
UART bytes
  → SOF/VER/TYPE/LEN/SEQ + payload + CRC16
  → validate length+CRC; freeze payload
  → emit existing LE 32-bit words
  → pack_debug_clear + pack_loader UNCHANGED
```

Feasible if:
- CLEAR and Pack and Query are **payloads** of FRAME_TYPE, or CLEAR remains a separate TYPE;
- host writes frames, not raw words;
- experiment top only; identity H bit untouched.

Not feasible as a silent on-the-wire compatible upgrade: current host `send_words` writes raw LE words with **no** SOF. Old hosts would fail CRC. That is a **host+FPGA pair** change, not a Pack meaning change.

Magic-scan of `NAI1` or `44524743` inside PAGE payload is **unsafe** (payload may contain those values). SOF without length is also unsafe. Length+CRC (canon) is the lock; SOF is only a hint.

---

## 8. Resynchronization today vs proposed

| Event | Current recovery | Proposed frame recovery |
|---|---|---|
| 1 extra byte | Phase shift; CLEAR→UNSUP or Pack MAG/UNSUP | CRC fail; NAK; if `bix`/scanner reset, next frame OK |
| 2–3 extra bytes | Often MUTE (CLEAR never exact) | Length timeout / CRC fail; must still reset assembler |
| Framing error (bad stop) | START abort if line high; else wrong byte | Still PHY; CRC may catch |
| Malformed Pack word | Semantic NAK; `bix` unchanged | Inner path still NAK if wrapper passed |
| Partial transaction | S_RX busy; BUSY CLEAR does not flush | Needs explicit abort + flush |
| Reset mid-frame | system `rst_n` / CK_RST | same |

Desired property “malformed frame must not permanently phase-shift later frames” is **false today**. It is the main correctness argument for a wrapper, independent of finding the extra-byte **source**.

---

## 9. Single sealed buffer

Lifecycle EMPTY→FILLING→COMPLETE→VALIDATING→SEALED→PROCESSING→RESPONSE→EMPTY is **simpler for CLEAR and QueryRecord**.

For Pack it is **restrictive** if the sealed object is the **entire** pack (BEGIN+pages+END): max size is much larger than 256 B, MIG writes would wait until END, and §4.8 already allows page-level ACK after each DATA_PAGE.

Better experimental grain: **one UART frame = one Pack command** (BEGIN or PAGE or END) or **one QueryRecord**, not the whole campaign.

Stop-and-wait at **that** grain: host already waits for final pack ACK. Adding per-frame ACK is closer to unimplemented §4.8 page ACK. Throughput loss at 115200 is dominated by UART bits, not FPGA compute. Extra ACK word ≈ 347 µs per command. For A-01 (~few commands) milliseconds. Fine for development/teaching/Pack load. Later high-throughput knowledge load would want windowing — out of R1 scope.

---

## 10. Integrity layers (do not collapse)

| Layer | What it proves | Live? |
|---|---|---|
| TRANSPORT_INTEGRITY | bytes received = bytes sent (phase, drop, extra) | NO on UART. YES as Query CRC **after** word assemble |
| SEMANTIC_VALIDITY | opcode, ABI, schema, generation, reason codes | YES `pack_loader` / ASTRA status law |
| PERSISTENCE_INTEGRITY | dest words match PAGE CRC + sentinel | YES at END; dest already written; FEM CRC is separate |

A transport CRC that passes does **not** make a pack semantically legal. A Pack CRC that fails after a shift is a **mis-diagnosed** transport error (UNSUP/MAG).

---

## 11. Test vs silicon gap (remains even with a new packet layer)

| Layer | Word TB (`tb_pack_abi24_xsim_compare`) | UART TB (dualclk harness) | Board |
|---|---|---|---|
| Physical serial | NO | YES (bit-bang) | YES |
| 8-bit RX + `bix` | NO | YES | YES |
| FTDI/USB | NO | NO | YES |
| clk100 vs ui_clk | NO (single clk DUT) | YES (independent TB clocks, not MMCM) | YES (MMCM+mig ui_clk) |
| FIFO+CDC | NO | YES | YES |
| `query_result_bind` live | NO | NO (`r_valid=0`) | YES |
| generated `mig0` | NO | NO (BRAM) | YES |
| JP2/`ck_rst` | NO | NO | YES (owner: jumper removed) |
| Host timing / drain / `find_known` | NO | TB wait_word | YES (frozen campaign host) |
| Long campaign | 24 cases word-atomic | selected UART cases | 24-case + isolate |

B comparator 2026-09-17T13:01: `PACK_ABI24_XSIM_PASS 24/24` at 15805 ns. **PASS_XSIM only.** Not PACK_ABI_24_24_PASS.

A new packet layer would still miss FTDI, mig0, and JP2 until board+ILA. **Do not treat wrapper XSim as silicon root cause.**

---

## 12. Effect on observed failure classes (not a fix claim)

| Class | Likely effect of accuracy-first UART | Extra-byte **source** |
|---|---|---|
| MAG (`0200015a`) | DETECT/CONTAIN if shift is inside a framed payload CRC; inner MAG still possible if wrapper delivers shifted words | NOT_ADDRESS |
| UNSUP (`0200075a`) | DETECT/CONTAIN for 1 extra before CLEAR/BEGIN; token becomes transport NAK unless inner path still used | NOT_ADDRESS |
| SENTINEL | NOT_ADDRESS (dest/MIG/readback). Wrapper does not create sentinel | NOT_ADDRESS |
| PARTIAL | DETECT if length not reached | UNKNOWN if PHY truncates |
| MUTE (n=0, 2–3 extra) | DETECT/CONTAIN **if** timeout+resync resets `bix`; else still mute | NOT_ADDRESS |
| STICKY MUTE after A-01 | NOT_ADDRESS / UNKNOWN (H17 BUSY no flush; dest persist; loader S_RX) | NOT_ADDRESS |

H12 extra-byte mapping remains the regression oracle:

| Extra bytes | Current token |
|---|---|
| 0 | CLEAR ACK |
| 1 | R_UNSUP `0200075a` |
| 2–3 | no CLEAR word / MUTE |

Those vectors must be **kept**, not “improved” by changing gold.

---

## 13. Blast radius if a prototype were authorized later

| Module | Change class |
|---|---|
| `uart_rx` bit sampler | WRAPPER_ONLY (keep PHY) |
| `uart_rx_word` | SMALL if reused under wrapper; MEDIUM if replaced |
| CLEAR | WRAPPER_ONLY if CMD is a frame type; SMALL if still raw word beside wrapper (two ingresses = risk) |
| FIFO/CDC | NONE if wrapper sits **before** FIFO and still emits words |
| `pack_loader` | NONE for option B |
| TX mux | SMALL (transport ACK vs pack ACK) |
| Host script | MEDIUM (must frame; frozen campaign host must not be silently edited) |
| Pack ABI gold | NONE if payload identical |
| MIG/FEM | NONE |
| Word TB | NONE (still valid inner) |
| UART TB | MEDIUM (new frames + keep extra-byte inner tests) |
| Board TB | MEDIUM |

---

## 14. Resource estimate (engineering, not synth)

| Buffer | Data | Control | Comment |
|---|---|---|---|
| 4 B (one word) | 32 FF | already exist | not a frame |
| 64 B command | ~512 FF or LUTRAM | ~1 FSM | CLEAR/Query-sized |
| 256 B (max PAGE) | 1 RAMB18 or dist RAM | FSM + CRC16 | matches `PAGE_RAM_WORDS=64` |
| 132 B (A-01 whole) | LUTRAM | FSM | one pack case, not general |
| Parameterized multi-KB pack | BRAM, C_SCALE_GUARD if tied to C | do not build for R1 | |

Control CRC16-CCITT is cheap (Query already has it). Do not add a large packet BRAM “because accuracy.”

Identity H / freeze DCP LUT budget: any **product** insert needs owner RESOURCE authorization. Experiment top can be a separate debug wrapper.

---

## 15. Latency (115200)

Current CLEAR: 4 B TX + 4 B ACK ≈ 0.70 ms UART + `QUIET_N` ~0.20 ms.

Current A-01: 33 words ≈ 11.5 ms UART + pack/MIG work overlapped on BRAM (XSim NAK_R02).

Wrapper: +10 B / frame ≈ +0.87 ms. If one frame for whole A-01, UART ≈ 12.4 ms. Collect-then-commit delays `pack_loader` start until CRC OK: lose overlap of BEGIN CRC with remaining UART — on this baud, UART dominates.

Acceptable for development, teaching, Pack load, QueryRecord. Later high-rate ingest: windowed frames, not R1.

---

## 16. Sequence vs H work

Keep the task’s sequence. No stronger evidence to invert it.

1. Name silicon extra-byte / first PACK word (ILA / mig0 / FTDI) — **open**.
2. Close causal class as far as evidence permits — **open** (`COMMON_ROOT=UNKNOWN`).
3. Freeze 0/1/2/3 extra-byte UART TB vectors — **already exist (H12)**.
4. Evaluate §4.9 wrapper **against those vectors** — this review only.
5. Owner decides experiment vs keep.

Implementing a wrapper **now** would be architecture theatre over an unmeasured PHY/FTDI/mig0 gap.

---

## Options compared

### OPTION_1 — KEEP_CURRENT + H measurement (+ optional guards)

Keep word UART. ILA `bix`/first word after CLEAR ACK. Do not drop 4th byte without a sticky error (guard, needs RTL auth). Preserve H12 vectors.

Pros: does not mask tokens; smallest change. Cons: leftover `bix` remains a footgun after the source is found.

### OPTION_2 — ADD_OUTER_FRAME_WRAPPER / EXPERIMENT (§4.9)

Debug top: `uart_rx` bytes → §4.9 → words → existing CLEAR/Pack. New host framer. Label `TRANSPORT_EXPERIMENT`. Not a product identity.

Pros: matches canon; DETECT/CONTAIN phase errors; Pack gold untouched. Cons: new bit/host; HIGH masking risk if it replaces H; two ACK namespaces (transport vs pack).

### OPTION_3 — REDESIGN_TRANSPORT (seal entire pack, no PAGE write until END)

Pros: true atomic dest. Cons: contradicts live `S_WRITE`; large buffer; B/D ABI+MIG work; not needed to answer extra `0x00`.

---

## Recommendation

**DEFER_UNTIL_ROOT_CAUSE_CLOSED**

Not because framing is a bad idea. Because:

1. FACT: extra 1 byte already maps to R_UNSUP in UART XSim; silicon source UNKNOWN.
2. FACT: canon already specified the wrapper; this is a **gap to implement later**, not a green-field invention.
3. INFERENCE: shipping the wrapper before ILA would change tokens and invite a false “transport fixed CLASS A.”
4. Query path already shows collect+CRC at record layer; Pack UART is the hole.

After H names the extra byte (or proves it is not on the wire), OPTION_2 is the **minimum reversible experiment**, with OWNER_AUTH.

### If owner later authorizes OPTION_2

PROTOTYPE_SCOPE: experimental top only; `pack_loader` / B gold / identity H frozen.

FILES_AFFECTED (preview): new `tb` + `host_tools` framer + debug wrapper SV; **not** `pack_loader.sv`; **not** frozen `uart_pack24_clear_board.py` (copy).

ABI_IMPACT: none on Pack payload; new transport header.

RTL_IMPACT: wrapper + mux of framed vs legacy (legacy off on experiment top).

HOST_IMPACT: new script; do not edit frozen campaign host in place.

TEST_PLAN: 0/1/2/3 extra, missing byte, bad CRC, bad length, partial, reset, CLEAR after malformed, next good frame. Inner H12 vectors still run on word path.

ROLLBACK: experiment top unused; program identity H.

EXPECTED_RESOURCE_COST: ≤1 RAMB18 + CRC16 FSM if PAGE-sized; else LUTRAM 256 B.

EXPECTED_LATENCY: +~1 ms/frame at 115200.

RISKS: dual ingress; SOF in payload; transport ACK vs pack ACK confusion; masking.

---

## Provenance (this review)

| File | SHA256 |
|---|---|
| `uart_rx_word.sv` | `638f9719732f971828205c43b9894cc2b93529fb6e1e39ab90f6970ca0790823` |
| `pack_debug_clear.sv` | `77e3dc26cebacbc2e975fb8748635b7c364263f3f52a5f31538ac7e49fd752ec` |
| `pack_loader.sv` | `58302aec460323059facf5856ee2cbdedc0c489506ac911e20b299c9a8c1a35a` |
| `uart_fe256_host.sv` | `95f273fa18d30746cc1f81c0518e415c8749332c9e14e3c10715a9ac709639c9` |

H status file was **not** edited. ILA/board/program not run.

NOT_CLAIMED: PACK_ABI_24_24_PASS, BOARD_PASS, PROGRAM_PASS, MIG_PASS, ASTRA_PASS, FE256_PASS, FINAL_PASS, TRANSPORT_PASS.
