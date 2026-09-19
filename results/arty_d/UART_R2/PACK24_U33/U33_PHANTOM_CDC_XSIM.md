# U33 phantom-CDC after CLEAR — no leftover BEGIN without inject

RUN_ID: 20260919T114421Z
OWNER: AGENT_D
PACK_ABI_24_24_PASS = NO. PROGRAM=NO. No overlay. xsim_u33m not killed.

## Claim tested

CLEAR (cdc_rst + debug_clear) itself emits a phantom CDC word, especially exact BEGIN `00800001`, that would MAG the next V-04 without host leftover.

## Result — CONTRADICTED on BRAM dest

After GOLD then CLEAR ACK:

```
lock=0 empty=1 f_valid=0 steer=0 dest_acc=1
cdc a_idle=1 b_idle=1 b_valid=0 hold=0 req_a=0 last_b=0 p_valid=0 n_ph=0
```

Same snapshot before the 5th V-04. Next V-04 GOLD `p0=00800001 p1=3149414e`.

`f_data=00800001` while `f_valid=0` is sticky FIFO output, **not** a transaction.

Leftover ABI word `00010001` (low byte OP_BEGIN, not exact `pack_begin`) GOLD — unlocked drop.

`$finish` 19773145 ns.

## Classification

| Hypothesis | Verdict |
|---|---|
| CDC reset phantom BEGIN after CLEAR | CONTRADICTED PASS_XSIM BRAM |
| 5th V-04 MAG without inject on BRAM | CONTRADICTED (GOLD) |
| Leftover `00010001` MAG | CONTRADICTED |
| Leftover exact BEGIN MAG | CONFIRMED earlier CELL A |
| Board leftover BEGIN source | UNKNOWN |
| dest=mig0 5th MAG | IN_PROGRESS (V04_0..2 GOLD) |

## Artifacts

```
tb   sha256 6729702fa99bf864763fef6158bd620b5c88a8e9994ddc153d8bfb76d7753b1e
log  sha256 4bbe8035e8d08d377c220d0202e68abf2096d9b43945c0ea95055885097e5ce1
cells sha256 a06cac4a4d3e9e2fe4efe8fba5c8032d62d41dcc9dbda1c1ce7803899156e423
```
