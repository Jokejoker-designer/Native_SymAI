---
version: "0.1-candidate"
owner: AGENT_D
status: CANDIDATE
milestone: M1
last_modified: "2026-09-16T13:35:00+07:00"
---

# M1 Pack Loader — CONTRACT (first slice)

> CANDIDATE engineering contract. Not Agent B gold. Not BOARD_PASS.
> Cross-refs: [§04], [§30.6], [§31.2], [§32], [§33.9].

## Causal question

Can the production loader receive a versioned pack, write the inactive generation
slot, drain outstanding writes, verify manifest/page integrity and sentinels,
and only then flip `active_generation`?

## Integrity labels allowed this slice

```text
FPGA_MANIFEST_ID_VERIFIED
FPGA_PAGE_CRC_VERIFIED
FPGA_SENTINEL_READBACK_VERIFIED
```

Forbidden this slice: `FPGA_SHA256_VERIFIED`, `BOARD_PASS`, `PACK_ABI_24_24_PASS`
(requires Agent B's 24 gold cases).

## Pass language

| Gate | Meaning |
|---|---|
| XSIM_SMOKE | preregistered 5 vectors pass in XSim |
| OOC_UTIL | OOC report exists; LUT/BRAM recorded; estimate is not the budget |
| AGENT_B_SIGNOFF | Agent B matches Python gold; this contract does not self-stamp that |

`XSim != board`. `PROGRAM=NO`.

## Preregistered vectors (unit of analysis = one pack transaction)

| ID | Stimulus | Expected |
|---|---|---|
| V1 | valid 1-region pack | `load_ack=1`, generation flipped, sentinel match |
| V2 | bad magic | `load_reject`, reason `BAD_MAGIC`, generation unchanged |
| V3 | abi_version != 1 | `load_reject`, `ABI_MISMATCH` |
| V4 | payload CRC wrong | `load_reject`, `PAGE_CRC`, generation unchanged |
| V5 | `mem_resp` stalled | `load_ack` remains 0 while `wr_outstanding!=0` |

## Reason codes

| Code | Name |
|---|---|
| 0x00 | OK |
| 0x01 | BAD_MAGIC |
| 0x02 | ABI_MISMATCH |
| 0x03 | SCHEMA_MISMATCH |
| 0x04 | MANIFEST_CRC |
| 0x05 | PAGE_CRC |
| 0x06 | SEQ_GAP |
| 0x07 | UNSUPPORTED |
| 0x08 | SENTINEL_MISMATCH |
| 0x09 | HEADER_LENGTH |
| 0x0A | RESERVED_NZ |
| 0x0B | REGION_COUNT |
| 0x0C | DRAIN_ERR |

## Hardstops

- Do not overwrite `rtl/native_graph/` (A7 freeze).
- Do not program the Arty.
- Do not map protocol faults to semantic `UNKNOWN`.
- One unknown per patch: PACK_ABI_24 hardware compare; header 128-byte matches live [§04.6] as CANDIDATE.
