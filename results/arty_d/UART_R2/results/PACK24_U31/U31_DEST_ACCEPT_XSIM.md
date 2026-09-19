# U31 dest_accept mute XSim — U2a split

Dest = `mig_ui_bram` (not `mig0`, not board).
PACK_ABI_24_24_PASS = NO.
No overlay. No program.

TB `UART_R2/u31/tb_u31_dest_accept_mute.sv` sha256 `e614789fe86f63b359ccf5c60e4222f160e7dfdc7160dde87b6cdffb94607b87`.
Log `UART_R2/xsim_u31m/xsim.log` sha256 `8c10dcc44cb251f9650dabe1ab64622cb41c4b30e04b030f30035bc4dcc943ef`.
`$finish` 28807465 ns.

## Cell A — ACK then dest_stall then V-04 (E6-shaped)

After CLEAR ACK, `dest_stall=1` then PA24-V-04.

```
CELL_A_AFTER_STALL dest_accept=0 qsc_c1=0 rst100_pack_n=1 qsc_ui=0 d_rdy=0 n_p=0 f_valid=0 fifo_empty=1
CELL_A_AFTER_V04 mute=1 got=00000000 dest_accept=0 n_p=0 dn_p=0 f_valid=1 f_data=00800001 f_ready=0 fifo_empty=0 load_ack=0
SCORE CELL_A MUTE_PFIRE0
```

FACT PASS_XSIM: `dest_accept=0` holds BEGIN at FIFO head (`f_data=00800001`, `f_ready=0`). Host sees n=0, no NAK, `p_fire` never rises. This is the competing mute in independent (B), not leftover mux.

Release stall, no extra host TX:

```
CELL_A_RELEASE dest_accept=0 qsc_ui=0 d_rdy=1 fifo_empty=0
CELL_A_RECOVERY mute=0 got=010000a5 n_p=52 load_ack=1
SCORE CELL_A RECOVERY_GOLD
```

FACT PASS_XSIM: when dest ready returns, the held pack completes and GOLD is emitted without the host re-sending V-04. `dest_accept` print stays 0 after release because the loader is already busy (`qsc_ui=0`); `pack_lock` carries BEGIN.

Board 12 s V-04 n=0 after ACK is **not** this cell unless `app_rdy` stayed 0 for the whole wait. Independent E6/E7/U30 r1 waited 12 s and got no GOLD ⇒ either dest never became ready (Cell A never released) or Cell B.

## Cell B — dest_stall after first `p_fire`

Second V-04 starts, stall on first new `p_fire` (`n_p=53`, `dest_accept=1`).

```
CELL_B_AFTER mute=1 got=00000000 n_p=103 dn_p=51 load_ack=0 qsc_ui=0
SCORE CELL_B HANG_PFIRE_GT0
```

FACT PASS_XSIM: pack has already left the UART FIFO (`p_fire` +51). Mute with no GOLD/NAK. UART-identical to Cell A from the host.

## U2a split (XSim only)

| Class | UART | On-chip | This TB |
|-------|------|---------|---------|
| dest_accept hold | n=0, no NAK | `p_fire==0`, BEGIN at FIFO head | Cell A MUTE_PFIRE0 |
| dest hang mid-pack | n=0, no NAK | `p_fire>0`, `load_ack=0` | Cell B HANG_PFIRE_GT0 |

Host json cannot tell them apart. Independent (B) “dest hang as unique cause” stays WEAKENED; dest_accept hold is now PASS_XSIM as **a** mute class, not as the board cause.

## Overlay guard

Do **not** drop `dest_ui_rdy` from `dest_accept` to “fix” Cell A: that converts hold into Cell B (BEGIN flows into a dest that is not ready). U30 r1 (two GOLD then V-04 n=0) already looks like Cell B. NAK-on-hold is protocol only and does not dest-complete.

Not PACK_ABI_24_24_PASS / BOARD_PASS / MIG_PASS.
