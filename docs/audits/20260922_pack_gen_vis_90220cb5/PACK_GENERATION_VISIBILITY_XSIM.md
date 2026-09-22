# PACK_GENERATION_VISIBILITY XSim

Status: `PACK_GENERATION_VISIBILITY_XSIM_CANDIDATE=SUPPORTED`  
Date: 2026-09-22  
Owner: AGENT_D  
Board: not used. No bitstream. No program.

Log: `D:/FPGA/arty_d/UART_R2/pack_gen_vis/xsim/pack_vis_xsim.log`  
sha256 `5e9a787d685a79542dd445eeb0d65d0960d7c42745894be62448dd001752c3db`  
finish 9705 ns, xsim exit 0.

Ceiling: not `PACK_ABI_24_24_PASS`, not `BOARD_PASS`, not `PROGRAM_PASS`, not `MIG_PASS`, not `ASTRA_PASS`.

## What was tested

Same QueryRecord on every arm. Subject `0x00010100`. QueryRecord generation byte stays 1. The testbench has no generation-select port.

Visibility root is `pack_loader.active_generation`.

| Arm | Root | Window | Descriptor | Command |
|---|---|---|---|---|
| UNCOMMITTED | `ffffffff` | none read | 0 | none, writes=0 |
| commit G1 | `00000001` | base `0000000` win `00` | `025bb7b4…99bc` | `c001` primitive 0 |
| commit G2 | `00000002` | base `0100000` win `01` | `f2a071fe…9421` | `c002` primitive 1 |
| resend G1 | stays `00000002`, reason `0e`, writes stay 24 | window 1 | same G2 word | `c003` primitive 1 |

Before any commit both windows read `00000000`. After G2, window 0 still holds the G1 descriptor.

On fetch arms, `posting_payload_word` equals `spear_descriptor`. Verdict `B0`, capability `0xC1`.

## What is live

- Unmodified `pack_loader` accepts the stream, writes `mem_addr`, and updates `active_generation` only on commit.
- Stale generation `hw3 <= active_generation` takes `R_STALE` (`0x0E`) in BEGIN decode, before a page write.
- The query RAM index is `window = addr[21:20]`, `word = addr[13:2]`. Slot 1 base observed on the write is `28'h010_0000` (bit 20), window `01`.
- The 12 words the query reads are the words that commit wrote. `xvlog` does not include `exact_directory` or `posting_walk`. `dir_a.mem`, `post_a.mem`, and `desc_sem.mem` are deleted from the sim directory if present.
- `gold.valid_pack` builds the stimulus files only. The DUT does not instantiate gold.

## What stays a labeled substitute

- `theta[8]=1`, `legal_mask=8'h03`.
- `REF_G2 = 32'hf2a071fe` maps rank0 to feature 2. That is why G2's primitive is 1 and G1's primitive is 0. It is not a policy record.
- The committed page is one 48-byte directory row + posting header + SPEAR word for subject S. It is not a multi-page pack and not the canon `dir_a`/`post_a` image.
- The RAM is the address-window stand-in. It is not generated `mig0`.

## Not claimed

- Re-selecting G1 after G2. The stale arm keeps root G2.
- `PACK_ABI_24_24_PASS`.
- A board identity. `RECOMMEND_BOARD_BUILD=NO` until an independent audit of these cuts.
