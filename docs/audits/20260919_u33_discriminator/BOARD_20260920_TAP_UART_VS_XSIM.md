# TAP UART dump vs XSim DUP4 — 2026-09-20

PACK_ABI_24_24_PASS=NO. PROGRAM_PASS=NO. Not loader hop until dump alignment.

Source: `U33TAP_CAPTURE_20260920/CAPTURE.json` CELL_DUP4 vs `u33tap_sof.log` DUP4_DUMP.

Script: `tap_uart_vs_xsim.py` → `TAP_UART_VS_XSIM.json`.

| Field | Silicon | XSim |
|---|---|---|
| MAG | `0200015a` | MAG then TAP |
| TAP1 | `31504154` | `31504154` |
| p0 | `00800001` BEGIN | `00800001` BEGIN |
| p1 | `414e0080` | `00800001` BEGIN |
| p2 | `00013149` | `3149414e` MAGIC |
| p3 | `00010001` | `00010001` |
| meta | `a108011a` | `a108011a` |

FACT: `p0_begin_both=true`. `p3_match=true`. `meta_match=true`. `p1_match=false`. `first_diff.byte_i=8`.

INFERENCE: TAP UART dump untrusted after p0. Programmed TAP bit `d448544f` was not rebuilt after TAP CDC hold XDC (rescore-only WNS +0.516).

HYPOTHESIS: 2-byte shift of p1/p2 on dump path vs true loader p1≠BEGIN.

Independent XSim (not TAP UART): leftover hop_log `p_fire` p0=BEGIN p1=BEGIN CLASS_A. Log sha256 `564d22e7f719d1631e0e3152e0bc5461b5c8f0f7ce62891ba378f80e80e9980c`.
