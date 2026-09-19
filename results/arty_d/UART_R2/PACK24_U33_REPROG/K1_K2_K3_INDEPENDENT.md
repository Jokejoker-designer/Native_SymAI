# Independent analysis — K1 / K2 / K3

CANDIDATE_DESIGN. Not RTL. Not PACK_ABI_24_24_PASS / PROGRAM_PASS / BOARD_PASS / MIG_PASS.
Owner: AGENT_D. Date 2026-09-19. Corpus claims were re-tested against U33 board + RTL, not accepted as law.

## Architecture lock — keep

FACT: Artix-7 Arty A7-100T, generated mig0 Native UI, UART 8N1 32-bit, clk100 / ui_clk, Pack A wins FEM B, C RTL frozen size, FE256 reference only.
FACT: V04_4 GOLD dest=generated mig0 CONTRADICTS board MAG = 5th dest commit.
FACT: U32 CLEAR1 BUSY CONFIRMED dest-AND qsc. U33 qsc does not AND dest_ui_rdy.
Rejected: SmartConnect, AXI UART, AXI-VDMA, overlay H/U33, AGENT_C resize.

## Corpus “FACT” vs this tree

| Claim | Class | Why |
|---|---|---|
| Beat = VALID && READY same cycle | FACT | `pack_loader` S_IDLE/S_RX sample `s_valid && s_ready`. Harness `p_fire = p_valid && p_ready`. |
| VALID must not depend on READY | FACT at CDC | `word_cdc32` holds `b_valid` until `b_ready`. `p_valid` is not a combo of `s_ready`. |
| Ready/valid is not a CDC | FACT | Keep `word_cdc32`. |
| Registered READY extra beat → leftover BEGIN after CLEAR | CONTRADICTED as MAG hop | Probe P1 idle n=0. Phantom CDC n_ph=0. TAP_P1 expected 0 beats. |
| Extra BEGIN concurrent with V-04 | FACT FAIL_BOARD | Probe P3 MAG `0200015a`, host begin_n=1 nwritten=208. |
| Do not idle-wait dest READY | FACT | U32 BUSY. Do not revert dest-AND qsc. |
| Framing not sticky load_ack | INFERENCE for CH_B | `load_ack` pin is sticky until next BEGIN; TX already pulses `load_ack && !ack_d`. Do not rebuild CH_B. |
| Sticky `b_data` while `!b_valid` | FACT not a beat | CDC leaves `b_data` hold. Loader samples only `s_valid && s_ready`. “Ignore b_data if !b_valid” is already the law. |
| MAG = R_BAD_MAGIC after a real 128-byte BEGIN | FACT | Dummy `00010001` cannot be opcode (would TRUNC). Extra BEGIN or non-MAGIC hw0 must be an **accepted** beat. |

## K1 — execute TAP, not BARRIER

Agree: UART is a stream; BEGIN is SOF; addresses after decode; TAP `s_valid && s_ready`; no product SHA change; no bitstream overlay.

Independent correction: TAP **after CLEAR only** is the wrong MAG experiment. That hop is already empty. The hole is the **first accepted beats of the next V-04** (SOF window). Silicon TAP of those beats needs ILA = new identity. Without bitstream, K1 TAP is XSim + host inference only.

Do later BARRIER / R_LEFTOVER = new SHA, PROGRAM=NO until TAP names the extra beat or owner YES.

## K2 — do not build now

Five-channel NTC is product handshake **after** a named leftover beat. CH_B pulse already exists. CH_AR dest-complete already exists (`S_RD_*`). Mapping AW/W onto BEGIN/PAGE is an analogy, not a reason to wrap `s_axi`. New SHA only after TAP or owner YES. Never overlay U33/H.

## K3 — query-only off this lease

Agree dual-ingress so Pack leftover cannot be Query. FEM persist stays blocked until Pack is B-classifiable. Query-only must **not** take COM12/JTAG while Pack class work holds the Arty lease.

## Sequence (independent)

1. K1 TAP XSim: idle after CLEAR (expect 0 beats) + V-04 SOF (BEGIN, MAGIC) + DUP4 class A (BEGIN, BEGIN).
2. Board TAP of SOF beats only with owner YES ILA identity — not overlay U33.
3. If extra BEGIN is a valid beat: K2 SHA with R_LEFTOVER ≠ R_BAD_MAGIC.
4. Then Pack B-classifiable → FEM persist.
5. K3 query-only in parallel without this board.

## K1 TAP XSim (product SHA unchanged)

TB `tb_u33_k1_tap.sv` sha256 `3a1a9128…`. Bind U33 `eade06c8…`. Log sha256 `a277c9d6e36ce3ec7a67aacef2b19a93fcf841645710131b500f076164913871`. `$finish` 5033945 ns. Dest=BRAM. Not PACK_ABI_24_24_PASS.

| Cell | n_p | p0 | p1 | Token | Class |
|---|---|---|---|---|---|
| TAP_P1 idle after CLEAR | 0 | — | — | none | leftover after CLEAR is not a beat |
| TAP_P3 one V-04 | 8 | `00800001` | `3149414E` | GOLD `010000a5` | G |
| TAP_DUP4 extra BEGIN then V-04 | 8 | `00800001` | `00800001` | MAG `0200015a` rsn=01 | A |

FACT: after TAP_P3 GOLD, `s_valid=0` and `b_data=00000004`. Sticky CDC hold is not a beat.

FACT: TAP_P1 XSim matches board probe P1 n=0.

UNKNOWN: silicon SOF window on a MAG hop. Host begin_n=1. No ILA on frozen U33.

Board reopen-after-GOLD (2026-09-19 20:39+07): CLEAR1 ACK then first V-04 n=0. Mute class, not MAG. Not a Pack24 path.

PACK_ABI_24_24_PASS remains NO until 24/24 CLEAR-V04 GOLD n=4 and Pack24 run1/run2/fresh dest-complete.
