# U0 — freeze / dataflow inventory

TASK: UART_ROOT_CAUSE_AND_RESILIENCE_R2  
OWNER: AGENT_D  
RTL_MODIFIED this phase: **NO**  
ETHERNET: ON_HOLD, not deleted/overwritten.

## Claim ceiling (locked)

```
UART_H_ROOT_CAUSE = UNKNOWN
PACK_ABI_24_24_PASS = NO
M1_BOARD_CLOSED = NO
BOARD_PASS = NO
H19/H20 = classifiers until board evidence on identity H
```

Identity H bit `cf62102f…` on disk is untouched. H_OBS / H-ILA-A / freeze DCPs / B gold / FE256 gold untouched.

## Two UART RX sources (do not mix)

| Copy | SHA256 | Behavior at 4th STOP if `w_valid && !w_ready` |
|---|---|---|
| H-class (AUDIT snapshot, Native_SymAI) | `638f9719…` | **silent drop**: no emit, `bix<=0`, FSM IDLE. This is the confirmed **H20 causal class in RTL**, not yet silicon root on H. |
| LIVE PACKAGE before this task | `ab1b9571…` | `stop_hold` + STOP=1 check already mixed in. **Not identity H.** Not a board identity. |

U1 candidate is derived from **H-class only** (phase isolation). LIVE mixed file is frozen as `frozen/uart_rx_word_LIVE_PRE_U0.sv` and is not overwritten onto H.

## Dataflow (identity-H / m4_mig_clear candidate top)

```
uart_rx  115200 8N1
  → uart_rx_word          (assembler; H-class can DROP completed 4th word)
  → w_valid/w_ready/w_data
  → pack_debug_clear.take if word==44524743
  → else word_fifo32 DEPTH=128  wr=w_valid && !clr_take && !clr_hold
  → uart_fe256_host       QueryRecord 8 words → q_valid
  → query_result_bind     hop-1 walk (fail-closed SEARCH_INCOMPLETE)
  → word_cdc32            100 MHz → ui_clk pack_loader
  → pack_loader           BEGIN/PAGE → MIG writes → drain → sentinel readback → S_COMMIT
  → active_generation     updated only in S_COMMIT
  → M2/M3/ASTRA           see q_bytes only when q_valid (LIVE host gates unpack)
```

`w_ready = clr_take || (!clr_hold && fifo_wr_ready)`.

## Where transport can backpressure, drop, or become visible

| Site | Mechanism | Visible to reasoning? |
|---|---|---|
| **uart_rx_word STOP bix==3** (H-class) | completed word dropped if `w_valid && !w_ready` | Not directly; **lost word** can shift opcode into pack_loader (H20 XSim UNSUP). |
| **word_fifo32 full** | `wr_ready=0` → `w_ready=0` → H-class drop at RX | Transport. |
| **clr_hold** | `w_ready=0` during CLEAR non-idle (except clr_take) | Can recreate 4th-byte stall. H16 XSim: hold window << 1 UART word so BEGIN still completes. |
| **word_cdc32** | 1-word toggle CDC; `a_ready` low while in flight | Backpressures FIFO drain, not RX directly until FIFO fills. |
| **pack_loader S_RX** | `s_ready` low in some states | Backpressure through CDC/FIFO. |
| **uart_fe256_host S_RX** | fills `qw[0:7]` before `q_valid` | LIVE: `q_bytes` gated by `q_valid`. Internal `qw` still holds partial. CLEAR via `rst100_pack_n` if debug_clear. |
| **query_result_bind** | consumes `q_valid` 32-byte record | Must not see partial (depends on host gate). |
| **pack_loader S_COMMIT** | `active_generation <= man_generation` after sentinel | Existing atomic activation. Writes go to `slot_base` (inactive slot) before commit. **PRESERVE.** |
| **Top does not connect** `active_generation` into `uart_fe256_host` | snapshot pin defaults `0xFFFFFFFF` | U6 missing integration edge (not U1). |
| **STOP bit** H-class | not checked | U2. Malformed STOP can become a data byte. |
| **No RTS/CTS** | host can overrun FIFO 128 | U5. Pacing ≠ correctness. |

## Existing generation atomicity (audit, do not redesign)

`pack_loader` writes pages using `slot_base` / `slot_bit`, drains `wr_outstanding`, readback first word vs `rg_first`, then **one FF update** of `active_generation` in `S_COMMIT`. Failed packs go `S_REJECT` without that update.

FIFO empty is not used as destination-complete. UART idle is not used as commit.

## H20 / H19 status entering U1

- H20 4th-byte drop: **CONFIRMED_PASS_XSIM** on H-class `uart_rx_word` (`H20_4TH_BYTE_BP_XSIM.json`). Silicon class on identity H: **UNKNOWN**.
- H19 leftover `bix`: **CONFIRMED_PASS_XSIM** + board first-A-01 UNSUP with exact 132 B TX; extra-byte SOURCE **UNKNOWN**. Timeout **not** authorized in U1.

## U0 falsifier

Any RTL edit in this phase, or overwrite of H bit/DCP/jsonl, fails U0.

## TRANSFER_TO_ETHERNET (guard only)

Future Ethernet must still: complete record → validate → commit → reason. Must not stream session bytes into ASTRA. Not implemented.
