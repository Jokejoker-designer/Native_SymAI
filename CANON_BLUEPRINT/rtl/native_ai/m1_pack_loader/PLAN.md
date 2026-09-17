# M1 Pack Loader Implementation Plan

> For agentic workers: first-slice only. One unknown: 128-byte ManifestHeader candidate pending Agent B. PROGRAM=NO.

**Goal:** Fail-closed `pack_loader` that ACKs only after drain + sentinel.

**Architecture:** 32-bit command stream → buffer → decode → mock/MIG memory writes to inactive generation slot → drain → sentinel read → commit.

**Tech stack:** SystemVerilog, Vivado 2026.1 XSim + OOC, Python zlib CRC-32/ISO-HDLC candidate gold.

## Tasks

- [x] RCA / scientific gate in [§30.6] [§33.9]
- [x] CONTRACT.md
- [x] crc32_iso_hdlc.sv + pack_loader.sv + tb
- [x] Generate vectors (`python python/m1/pack_vectors.py`)
- [x] XSim 5 vectors — PASS
- [x] OOC synth recorded (LUT 1427, WNS -1.811 ns; estimate exceeded)
- [x] Mailbox Agent B for gold sign-off
- [x] D-01 BRAM page buffer — RAMB18 inferred; XSim 5/5; WNS still -1.663 (CRC path)
- [x] D-02 CRC one-byte/cycle — XSim 5/5; OOC WNS +2.004 ns MET unplaced (not TIMING_PASS)
- [ ] PACK_ABI_24 vs B gold (24 cases)
- [ ] FE256 DUT bind to B comparator
- [ ] Post-route / HD.CLK_SRC / CDC when M1 implementation bag opens
