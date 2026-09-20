# IHI0022E (AXI3/AXI4/ACE) → Native transfer laws

**Status:** CANDIDATE_DESIGN. Not RTL. Not a PASS stamp.  
**Date:** 2026-09-19  
**Source:** `d:\FPGA\IHI0022E_amba_axi_and_ace_protocol_spec.pdf`  
ARM IHI 0022E ID033013 (22 Feb 2013), 328 pages.  
SHA256 `0a88e1f49b3a3da8c6a593f5622755df9e5a744471809681b7d6a1cfbf940974`

**This PDF is AXI-MM + ACE.** It is **not** AXI-Stream (that is IHI0051 / UG934).  
**ACE / ACE-Lite coherency is out of scope** for Artix Native_SymAI.  
Do **not** add SmartConnect, `s_axi`, GP0 `0x40000000`, or AXI UART.

`PACK_ABI_24_24_PASS=NO`. `PROGRAM_PASS=NO`. No overlay.

---

## What IHI0022E actually licenses as thinking

Five **independent one-way channels**, each with its own VALID/READY pair (A1.3.1, A3.2.1, Table A3-1):

| AXI channel | Handshake pair | Native analogue (K2) |
|---|---|---|
| Write address | AWVALID / AWREADY | CH_AW opcode BEGIN/REGION/PAGE/CLEAR |
| Write data | WVALID / WREADY + WLAST | CH_W PAGE / `app_en`+`app_wdf_*` |
| Write response | BVALID / BREADY | CH_B `ack_pulse` + `reason` |
| Read address | ARVALID / ARREADY | CH_AR targeted-lane readback command |
| Read data | RVALID / RREADY + RLAST | dest-complete lane match |

UART byte stream is **not** an AXI channel. It is a **host framing pipe** (K1 / CH_S). Mapping it to W without an AW is how leftover BEGIN becomes MAG.

---

## Laws taken from A3.2–A3.3 (paraphrase, not a copy of the spec)

Sampled on **rising ACLK**. Native: `clk100` / `ui_clk`. Baud is a **clock enable**, not ACLK (already UG934).

1. **Beat** — transfer only when VALID and READY are both HIGH at that rising edge (A3.2.1).
2. **Source must not wait for READY before VALID** (A3.2.1, A3.3.1). Once VALID is HIGH it **holds** until the handshake.
3. **Destination may wait for VALID before READY**, and may drop READY before VALID (A3.2.1).
4. **Default READY HIGH** is recommended for AW/AR so a transfer is not forced to two cycles (A3.2.2). Native: do not invent a 2-cycle “wait dest then accept UART”.
5. **WLAST / RLAST** mark the last beat of a **burst**. BRESP is for the **whole write transaction**, not each W beat (A1.3.1, A3.2.2). Native: GOLD/ACK pulse after dest-complete, not sticky `load_ack` per word.
6. **Channels have no fixed timing relationship** except listed dependencies. Write **data may appear before write address** because of register slices (A1.3.3, A3.3). Interconnect must **not** present that data as valid to the wrong slave.
7. **Deadlock rule** — master must not wait for AWREADY before driving WVALID if a slave waits for WVALID before AWREADY (A3.3.1 Caution). Native: `pack_quiescent` must not AND `app_rdy` (U32 BUSY CONFIRMED).
8. **AXI4 BVALID** only after **both** AW handshake **and** WLAST handshake (A3.3 AXI4 write response dependency). Native: do not emit GOLD/ACK until opcode accepted **and** last PAGE beat dest-complete.
9. **Reset** — after ARESETn, master VALIDs LOW; earliest VALID is the cycle **after** ARESETn goes HIGH (A3.1). Native: first V-04 n=0 after cold-plug is mute, not MAG (T0 2026-09-19).
10. **RVALID only in response to a read request** even if the slave has data (A3.2.2 Read data channel). Native: do not invent a read-data token on UART unless CH_AR happened.

---

## Map onto tonight’s silicon class

| IHI0022E shape | Native evidence |
|---|---|
| Extra W beat with payload = leftover BEGIN | MAG `0200015a` sufficient when p0=p1=BEGIN (PASS_XSIM leftover inject; DUP4) |
| 64-byte prefix retry ≠ one extra W beat | DUP16 → `0200035a` R_SCHEMA, **not** board MAG (PASS_XSIM `U33_DUP.md`) |
| B after WLAST, not after each WREADY | dest=mig0 five GOLD CONTRADICTS “5th dest commit is MAG” |
| Register slice = +1 cycle on one channel | UG934 registered READY extra beat; leftover class |
| Interconnect must realign AW and W | `mig_ui_mux` Pack A wins; do not SmartConnect |
| VALID held across clocks | **Forbidden as CDC.** Keep `word_cdc32` |

Host python `begin_n=1` CONTRADICTS “send_words injected a second BEGIN”. Extra W-beat source on the wire is still **UNKNOWN** (FTDI / uart_rx / FIFO / CDC / DUT).

---

## What this PDF does **not** authorize

- Instantiating AXI IP on Artty A7-100T as the Pack fix.
- Treating ACE snoop/cache as FEM persist.
- Mapping Cortex GP0 bases onto `mig0` 28-bit UI.
- Calling PACK_ABI_24_24_PASS from a handshake lecture.

---

## Effect on K1 / K2 / K3

- **K1** still first: CH_S is the only channel where leftover W can enter. TAP `valid&&ready` after CLEAR.
- **K2** is the IHI0022E-shaped product: five channels, B after WLAST, no AW↔W deadlock, `R_LEFTOVER` ≠ `R_BAD_MAGIC`. New SHA, not overlay.
- **K3** is two masters on one interconnect (A1.3.2), not two AXI ports: Pack vs Query namespaces, one `mig_ui_mux`.
