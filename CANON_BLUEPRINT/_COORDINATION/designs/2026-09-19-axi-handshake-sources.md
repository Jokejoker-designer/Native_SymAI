# AXI READY/VALID sources → Native_SymAI

**Status:** PASS_IMPLEMENTED comparison. Not RTL. Not PACK_ABI_24_24_PASS.  
**Date:** 2026-09-19  
**Parent:** [2026-09-19-native-symai-overall.md](2026-09-19-native-symai-overall.md) · child [2026-09-19-native-transfer-contract.md](2026-09-19-native-transfer-contract.md)

## Sources (primary)

| ID | Source | Completeness | Role |
|---|---|---|---|
| S1 | `D:\FPGA\UG934.pdf` AXI4-Stream Video IP (UG934) 98 pages sha256 `cd0f0cafff7e4084f2e7453c8473c1e6343e58f3388a438011402abfafa6212d` | FACT full local PDF | READY/VALID + registered READY lag + SOF/EOL one-beat + ACLKEN/ARESETn |
| S2 | https://vhdlwhiz.com/how-the-axi-style-ready-valid-handshake-works/ Jonas Julian Jensen 2022, updated 2026-06-14 | FACT WebFetch + Playwright | Stateless RV; not for CDC; AXI VALID hold vs generic RV |
| S3 | https://docs.amd.com/r/en-US/ug934_axi_videoIP/READY/VALID-Handshake UG934 HTML 2022-11-16 | FACT Playwright screenshot; portal JS | Same handshake sentence as S1 p.6 |
| S4 | `D:\FPGA\Buoi_5.pdf` AISeQ slides 14–15 | FACT text extract | VALID must not depend on READY; dest may wait for VALID |
| S5 | `D:\FPGA\Buoi_4.pdf` slides 30–31 | FACT | Five independent channels, each RV |
| S6 | `D:\FPGA\Buoi_6.pdf` | FACT | `writes_done` one cycle (sticky ACK mismatch) |
| S7 | `D:\Jettking\PYNQ z2\Zynq_Architecture.pdf` slides 12-32…35 sha256 `967d4756c1875be0…` | FACT | Stream has no address; Lite vs Full vs Stream |

Do not copy video IP, AXI-VDMA, or AXI4-Lite register maps into Artix Pack.

## ARCHITECTURE LOCK

Artix A7-100T, UART 32-bit words, generated `mig0` Native UI, `clk100` / `ui_clk`, `word_cdc32` toggle CDC. No Cortex, no GP0 `0x40000000`.

## Laws that all sources agree on

1. **Beat = VALID ∧ READY in the same cycle** (S1 also ∧ ACLKEN ∧ ARESETn at ACLK).  
2. **Source drives VALID+DATA; sink drives READY.**  
3. **Source VALID must not combinationally depend on sink READY** (S4, S2 AXI rule). Sink **may** wait for VALID before READY.  
4. **AXI (not generic RV): once VALID is high it stays high until the beat** (S2 citing AMBA AXI A3.2.1 / AXI-Stream TVALID).  
5. **Accept ≠ complete.** W/TREADY handshake is not BRESP, not SOF meaning, not dest-commit.

## Laws that are UG934-specific (still transferable)

6. **Clock enable is part of the beat.** No VALID/READY sample on a gated clock. UART **baud is CE, not ACLK**.  
7. **Reset released is part of the beat** (`ARESETn`). Native analogue: `rst_n` and `calib_done` on dest (`mig_ui32` already gates `mem_cmd_ready` on `calib_done`).  
8. **Framing is one accepted beat wide.** SOF=`TUSER`, EOL=`TLAST`, pulse = one valid transaction. Sticky `load_ack` until next BEGIN **violates this**.  
9. **Stream carries only payload + framing.** UG934: blanks/ancillary **not** on AXI4-Stream. Native: idle UART bytes and CDC **hold** with `valid=0` are not Pack opcodes.  
10. **Registered READY has a one-beat lag.** UG934 p.89: slave READY and master VALID **must be registered** → upstream can send **one more beat** after downstream deasserts READY. Cores need a skid/FIFO almost-full. This is the **leftover BEGIN** class: CLEAR/ACK can race one in-flight CH_S word.  
11. **Do not hold READY_out until READY_in.** UG934 p.91: that **grows gaps**. Native: `pack_quiescent` must not AND `app_rdy` (U32 BUSY CONFIRMED).  
12. **Backpressure = deassert READY when buffer full**, not drop (S1 p.25 TREADY). Matches `G-U1-NO-SILENT-DROP`.  
13. **Ready/valid is not a CDC protocol** (S2). Crossing `clk100`↔`ui_clk` stays `word_cdc32` toggle, not combinational RV.

## What Native already matches (FACT RTL)

- `pack_loader` `s_ready` does **not** depend on `s_valid` (S4 dest-may-wait). It depends on `crc_busy` and state.  
- `word_cdc32`: `b_valid` stays until `b_ready` (S2 AXI VALID hold). `a_ready` independent of `a_valid`.  
- `mig_ui32` write needs **both** `app_en∧app_rdy` and `wdf` accept; dest-complete is readback (law 5).

## What Native currently violates or mixes

| Source law | Native symptom |
|---|---|
| 5, 11 idle ≠ downstream READY | U32 qsc ∧ `app_rdy` → CLEAR1 BUSY |
| 8 framing = one beat | sticky `load_ack` |
| 9 sample DATA iff VALID | `cdc.b_data` hold while `!b_valid` |
| 10 registered READY lag | leftover exact BEGIN **sufficient** for MAG; phantom without `valid` CONTRADICTED |
| 6 baud ≠ ACLK | treating bit-time as dest clock was a false MAG unique-root |

## What we do **not** take from UG934

- Video SOF/EOL pixel counters, AXI-VDMA, AXI4-Lite timing registers, dropping pixels until SOF as a **product Pack resync overlay**.  
- After MAG, **drop-until-BEGIN** is a **classified** `R_LEFTOVER` drain on a **new identity**, not pad bytes on H/U33.

## Mapping onto NTC / P1–P3

- **P1 TAP:** log only `valid∧ready` beats (laws 1, 9). After CLEAR, if one extra BEGIN with `valid=1` appears, that is UG934 law 10 (skid), class `CH_S`/`CH_AW`, not dest.  
- **P2 NTC identity:** BARRIER = empty+cdc idle+`!b_valid`; `R_LEFTOVER`; `ack_pulse` one cycle (law 8); qsc without `app_rdy` (law 11); FIFO almost-full READY (laws 10, 12).  
- **P3:** query path uses the same RV on QueryRecord stream; still no AXI IP.

## Claim ceiling

PASS_IMPLEMENTED source comparison. Board MAG leftover source still UNKNOWN. Live mig0 five independent. No overlay. No AXI video IP in the product.
