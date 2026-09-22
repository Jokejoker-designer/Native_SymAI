# Unique ASTRA action-precheck identity cf246499 (2026-09-22)

Watch did **not** program. No `.bit` in git. Independent Get-FileHash equals `cf246499c6e5c09b57fefdd89dc5d6602fc7ded5dc2426d635a0987fc2bc8dae`. Frozen SPEAR-Q* file keep `8b632b4a…`. C RTL unedited.

LANGUAGE=EN. Not `ASTRA_PASS`.

```text
XSIM = PASS_XSIM finish 6 ns ASTRA_PASS=NO
BIT_OK WNS = +5.404 WHS = +0.074
PROGRAMMED EOS = HIGH
PROGRAM.DONE = NA
UART nfail = 0
verdicts packing = B0,B2,B0,B3,B4 (not a locked ABI)
ASTRA_ACTION_PRECHECK_BOARD_CANDIDATE = SUPPORTED
ASTRA_PASS = NO
PROGRAM_PASS = NO
BOARD_PASS = NO
TIMING_PASS = NO
```

## Independent hashes

| Artifact | SHA256 |
|---|---|
| precheck `.bit` (disk, not committed) | `cf246499c6e5c09b57fefdd89dc5d6602fc7ded5dc2426d635a0987fc2bc8dae` |
| `astra_action_precheck_v1_xsim.log` | `8671a43c38a575e95b3ce0ba16a873fb17ccc786615ba71915e1e011c2e9a85b` |
| `UART_ACTION_PRECHECK.json` | `9394fd9827f68c657f1f99d276bceea2176e062e567f469f7deeaea73f8784c7` |
| `PROGRAM.txt` | `b5d405664f5a6f57c69c4b367e5b52ee134d22ab077b2de3074751b9680297db` |

JSON steps A/B/A2/C/D verdict 176/178/176/179/180 (`0xB0/B2/B0/B3/B4`) final 1/255/1/255/255 nfail=0. First host D miss used stale-inclusive flags; this JSON is the corrected `flags=0x03` capture. JTAG `210319BE776EA`.
