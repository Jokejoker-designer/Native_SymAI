# U33 leftover-BEGIN MAG XSim (M4) — BRAM dest

RUN_ID: 20260919T111705Z
OWNER: AGENT_D
PACK_ABI_24_24_PASS = NO. PROGRAM_PASS = NO. BOARD_PASS = NO. MIG_PASS = NO.
PROGRAM=NO. No product overlay. Did not kill mig0 five-V-04 xsim_u33m.

## Claim

If an extra exact BEGIN `00800001` sits in pack ingress after VALIDATION_CLEAR has returned IDLE, the next V-04 produces board MAG `0200015a` (`R_BAD_MAGIC`) because loader hw0 is the second BEGIN, not `MAGIC_NAI1`.

## Cells (dest=mig_ui_bram, bind=U33, BAUD=1M)

| Cell | Stimulus | Result | Class |
|---|---|---|---|
| A | CLEAR ACK, extra BEGIN, then V-04 | MAG `0200015a` p0=`00800001` p1=`00800001` p2=`3149414e` rej=1 rsn=01 | FACT PASS_XSIM — leftover BEGIN **sufficient** for board MAG token |
| C | CLEAR ACK, extra GOLD `010000a5`, then V-04 | GOLD p0=BEGIN p1=MAGIC | FACT PASS_XSIM — unlocked non-BEGIN leftover **does not** MAG |
| B | extra BEGIN while CLEAR `ack_valid` | CLEAR ACK then V-04 **mute** n_p=0 | FACT PASS_XSIM — ACK-overlap ≠ board MAG (board was n=4 NAK). Overrun/mute class |
| D | CLEAR short mute, retry ACK, V-04, then CLEAR+V-04 | both GOLD | FACT PASS_XSIM — r2 n=0-retry **not sufficient** for MAG on BRAM |
| E | CLEAR ACK, V-04 with no DIV*8 settle (`WAIT_AFTER_ACK_S=0`) | GOLD | FACT PASS_XSIM — zero-settle **not** MAG on BRAM 1M |

`$finish` 34548945 ns. Elapsed wall ~6 s.

## What this does **not** prove

- Board host does not intentionally send an extra BEGIN (campaign sends CLR then `v04` mem).
- Source of leftover `00800001` on exclusive U33 silicon is **UNKNOWN**.
- dest=generated mig0 5th V-04 still IN_PROGRESS (`xsim_u33m`, last printed GOLD V04_2).
- Not a license to overlay FIFO/CDC/UART/qsc/dest_accept or spawn U34.

## Artifacts

```
tb     D:/FPGA/arty_d/UART_R2/u33/tb_u33_leftover_begin_mag.sv
       sha256 7eba977d09a5958be2634d3a694df4c8e139f95bc739cae04d903097cc715909
log    D:/FPGA/arty_d/UART_R2/xsim_u33mag/xsim_u33mag.log
       sha256 020506a7c2451861e63bfeff66ff17dd029f35c00aff75dbc34e11c3fa57a63b
cells  D:/FPGA/arty_d/UART_R2/xsim_u33mag/u33_leftover_mag.log
       sha256 efbf8e842b0e01812c4797415da62e566e0c7ee6ee7079f05f2641a36f5f8c7e
```

## Next

Keep mig0 5× running. Overlay only if a TB shows leftover BEGIN (or equivalent hw0≠MAGIC) **without** TB injection, or board RX capture shows extra `00800001`. PROGRAM=NO until owner.
