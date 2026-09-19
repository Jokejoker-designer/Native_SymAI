# U33 115200 board-UART cells — five GOLD, r2-retry GOLD, gap mute

RUN_ID: 20260919T130222Z
OWNER: AGENT_D
PACK_ABI_24_24_PASS = NO. PROGRAM=NO. No overlay.

## Results dest=BRAM BAUD=115200 WAIT_AFTER_ACK=0

| Cell | Result | Class |
|---|---|---|
| FIVE115_0..4 nosettle | GOLD p0=BEGIN p1=MAGIC | FACT PASS_XSIM — 115200 + zero-settle **not** MAG |
| R2 short mute + retry + V-04 + R3 V-04 | both GOLD | FACT PASS_XSIM — board r2 n=0-retry **not** MAG at 115200 |
| GAP abort after first BEGIN byte | mute n_p=0 | FACT PASS_XSIM — MARK gap **mute**, not board n=4 NAK |

`$finish` 234454805 ns. Wall 36 s.

Board MAG `0200015a` is still **not** reproduced without leftover exact BEGIN inject. Closed: dest=mig0 5th, BRAM 5th, 115200 nosettle, n=0-retry, CDC phantom, unlocked non-BEGIN, first-byte gap (mute ≠ MAG).

## Artifacts

```
tb    sha256 3eb5f786cf0ad7a97c087809931d2e29fb6c20ed7892ee4c42ef9f326fb3b093
log   sha256 6e5fcb6e9ab6edaebf82e330fb821d3ebb0fd1205dab28acc13acd28a3a286a8
cells sha256 a5f6463d5e24d55f8cacf2a2b729106d5d4600d61fbbff0d3be19c7fd8924803
```
