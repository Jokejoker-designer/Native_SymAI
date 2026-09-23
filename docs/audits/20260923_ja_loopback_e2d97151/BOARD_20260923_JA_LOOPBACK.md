# JA external loopback UART candidate e2d97151 (2026-09-23)

Watch did **not** program. No `.bit` in git. Independent hash of the disk bit equals `e2d971512c519471541ac81e4b83eb41d77cf1b48d79092325e0b3e40b6c9349`.

LANGUAGE=EN. Not a product PASS stamp.

```text
STATUS = JA_LOOPBACK_ABA_UART_MATCH
PIN_LOCK = JA1 G13 effect_drive; JA2 B11 effect_sense
SILK = REV E
SCHEMATIC = E.2 owner-to-manufacturer
WNS = +0.279
WHS = +0.024
EOS = HIGH
PROGRAM.DONE = NA
JTAG = 210319BE776EA
TIMING_PASS = NO
PROGRAM_PASS = NO
BOARD_PASS = NO
ASTRA_PASS = NO
FEM_PERSIST_PASS = NO
MIG_PASS = NO
PACK_ABI_24_24_PASS = NO
```

XSim log `bb79156a…` finish 10595 ns and closed-top log `0a705313…` finish 45583775 ns. Open word `00000101`. Closed testbench word `01010001`. FEM stores event code 4, not the raw 1.

UART on the same SHA, COM12, 12 bytes:

| Arm | File | Words |
|---|---|---|
| Open, JA empty | `UART_OPEN.txt` | `f2a071fe 0000c001 00000101` |
| JP2 restored, still open | `UART_OPEN_JP2_RESTORED.txt` | same open words |
| Jumper not shown to be pin1–pin2 | `UART_CLOSED_MISPLACED.txt` | `00000101`, expected `01010001` |
| Adjacent JA1–JA2 | `UART_CLOSED_ADJACENT.txt` | `f2a071fe 0000c001 01010001` |

`UART_OPEN_AFTER_REMOVE.txt` is byte-identical to `UART_OPEN_JP2_RESTORED.txt` (SHA256 `dad33c9b…`). Both say open and `00000101`. A distinct third capture file was not found.

No voltmeter reading. Code 4 is not a pin voltage. Do not rebuild this SHA.
