# Independent evaluation — K1 TAP, no BARRIER, K2 as NTC

**Status:** OWNER_LOCK + CURSOR_OWNER independent read of UART_R2 / U33 RTL.  
**Not RTL. Not PACK_ABI_24_24_PASS. PROGRAM_PASS=NO.**  
**Date:** 2026-09-19  
**Owner lock:** K1 TAP on `s_valid && s_ready`; no BARRIER/`R_LEFTOVER` until TAP proves an extra BEGIN was **accepted**; K2 is Native Transfer Contract, not an AXI-MM clone.

---

## Verdict

K1 TAP on **pack_loader accepted beats** is the correct next experiment.

Independent split vs the leftover-BEGIN story that K1 was first sold with:

| Claim | Independent now |
|---|---|
| Leftover BEGIN sitting after CLEAR is the MAG class | **CONTRADICTED** this hop (probe P1 n=0). Not the reason to TAP. |
| Dummy `00010001` + leftover BEGIN MAG | **CONTRADICTED** as loader MAG. Unlocked drop. Token is MAG not TRUNC. |
| TAP because leftover is proven | TAP because MAG is `R_BAD_MAGIC` and **only the loader** may say that |
| BARRIER / `R_LEFTOVER` as next product | **Not locked.** |
| K2 = AXI-MM analogue | **Reject the name.** Keep one-meaning wires. U32 is the proof. |

`PACK_ABI_24_24_PASS=NO`. No overlay. Do not implement TAP until owner YES.

---

## What MAG is allowed to mean (RTL FACT)

`pack_loader` `S_DEC` for `OP_BEGIN`:

1. `begin_trunc` (len < 128) → `R_TRUNC` (`0x0F`)
2. `begin_badlen` (len != 128) → `R_HDR_LEN`
3. **then** `hw0 != MAGIC_NAI1` → `R_BAD_MAGIC` (`0x01`) → token `0200015a`

Board MAG is `0200015a`. Therefore the MAG transaction **did** accept a 128-byte BEGIN opcode word, then accepted some `hw0` that was not `3149414E`.

Dummy `00010001` has `[7:0]=OP_BEGIN` and `[31:16]=1`. If that word had been the accepted opcode, S_DEC would have stopped at **TRUNC**, not MAG.

U33 steer (FACT, `arty_a7_r2_top_m4_mig_candidate.sv`):

```text
pack_begin  = (f_data == 00800001)     // exact word, not "opcode 0x01"
dest_accept = qsc_c1 && rst100_pack_n  // idle-sync, not app_rdy
steer_pack  = pack_lock || (f_valid && pack_begin && dest_accept)
unlocked non-BEGIN: f_ready=1          // DROP
exact BEGIN && !dest_accept: f_ready=0 // HOLD in FIFO
```

Phantom CDC leftover `00010001` GOLD is the same law: unlocked drop. Probe P2 `begin_n=0` n=0 is expected. P3 MAG is **not** dummy-as-MAGIC.

Host `begin_n` only counts `00800001`. That is the right host counter for steer. It is **not** a loader-accept log.

---

## Why TAP must sit on `s_valid && s_ready`

`R_BAD_MAGIC` is decided only on words the loader **accepted**. These surfaces cannot name the sequence:

| Surface | Why it is not MAG class |
|---|---|
| `uart_rx_word` | Sees dummy and framing; U33 may drop before CDC |
| FIFO `f_data` while `!f_valid` | Sticky, not a beat (phantom CDC CONTRADICTED this as leftover) |
| FIFO occupancy / `pack_lock` | Steer/drop, not `hw0` |
| Status token `0200015a` | Packed NAK. Does not name p0/p1 |

The only sequences that close the class, **after CLEAR ACK**, at loader handshake:

```text
A  00800001, 00800001, …     extra exact BEGIN accepted as hw0
B  00800001, not-MAGIC        MAGIC slot is another accepted word
C  00800001, <gap>, next      MAGIC never accepted; next_word became hw0
G  00800001, 3149414E, …      GOLD path; extra BEGIN was not an accepted beat
```

A is **sufficient** in XSim (DUP4). Host `begin_n=1` CONTRADICTS python emitting A. If TAP shows A on silicon, the extra `00800001` was born **after** host TX (FTDI / UART assembler / FIFO / CDC registered-READY lag).

B/C are live because WAIT=0 first V-04 was GOLD and the probe first V-04 MAG after dummy+gap — packetization is still HYPOTHESIS, not class.

If TAP shows G on a MAG hop, MAG is **not** an accept-sequence bug; look at `hw0` register vs sampled `s_data` (RTL sample bug). That would be a different identity.

---

## Independent addition (not in the owner lock)

U33 still mixes meanings **in front of** the loader:

| Wire | Mixed as | One-meaning NTC |
|---|---|---|
| `dest_accept = qsc_c1` | system idle gates first BEGIN steer | CH_RX ready must not AND quiescent |
| `fifo_flush = uart_flush \|\| st_fire` | status TX of previous txn can flush the RX FIFO | CH_STATUS fire is not CH_RX reset |

`fifo_flush` on `st_fire` is **FACT in RTL**. Causal for board MAG is **HYPOTHESIS**. WAIT=0 overlap makes it eligible. TAP should timestamp `fifo_flush` beside the accept log. That is still observe-only. It is **not** a product BARRIER.

This is the same U32 lesson at a different wire: a completion/idle/status event must not be upgraded into ingress accept or ingress reset.

---

## K2 (NTC), not AXI clone

IHI0022E is a warning about mixed READY/IDLE/COMPLETE. It is not a port list.

| Channel | One meaning |
|---|---|
| CH_RX | accepted Pack words (`s_valid && s_ready`) |
| CH_CMD | decoded operation |
| CH_MEM_REQ | DDR request |
| CH_MEM_RSP | DDR completion / readback |
| CH_STATUS | commit/reject **event** + reason, not sticky `load_ack` |

`mem_req_ready` never becomes `system_quiescent`. `qsc_c1` never becomes `CH_RX_ready`. No `s_axi`. No AW/W/AR unless Pack needs those phases.

K2 SHA waits until TAP returns A/B/C/G or owner YES.

---

## BARRIER / R_LEFTOVER

Do not lock.

Eligible **only if** TAP shows A (extra exact BEGIN accepted) **or** a previous-transaction word that survived CLEAR as a real `s_valid && s_ready` beat.

Host `begin_n=1` means a product BARRIER now would be guessing an extra BEGIN the host did not send.

---

## Sequence

```text
K1 TAP observe-only (same SHA if nets unnamed; named identity if ILA/UART dump)
  → classify A / B / C / G
  → BARRIER only if A
  → NTC product identity
  → Pack B-classifiable
  → FEM persist
K3 query-only may run beside TAP, not instead of it
```

Independent confidence (0–10, not a PASS stamp):

| Item | Score | Layer |
|---|---|---|
| K1 TAP is the next decisive test | 9 | INFERENCE from RTL+token law |
| Leftover-after-CLEAR | 1 | CONTRADICTED probe P1 |
| Extra BEGIN accepted on historical MAG hops | 4 | sufficient PASS_XSIM; not observed as accept |
| Dummy caused probe MAG | 1 | CONTRADICTED (drop + not TRUNC) |
| `fifo_flush`/`st_fire` as MAG class | 4 | HYPOTHESIS |
| BARRIER now | 1 | not locked |
| K2 as AXI-MM clone | 0 | reject |

---

## Stop

No TAP RTL this turn. No overlay on H/U33. No AXI IP. `PACK_ABI_24_24_PASS=NO`.
