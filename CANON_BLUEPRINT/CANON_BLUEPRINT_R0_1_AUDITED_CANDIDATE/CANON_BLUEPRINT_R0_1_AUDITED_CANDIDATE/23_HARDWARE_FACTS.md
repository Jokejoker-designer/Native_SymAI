---
version: "1.1-candidate"
owner: AGENT_D
status: AUDITED_CANDIDATE
category: REFERENCE
last_modified: "2026-09-16T08:20:00+07:00"
---

# §23 — HARDWARE FACTS

> Canonical physical facts for the Arty A7-100T target. This document separates
> board/device facts from machine-local environment state. Only the former are
> architecture facts.

## 23.1 Canonical Board Facts

| Parameter | Canonical value | Evidence class |
|---|---:|---|
| Board | Digilent Arty A7-100T | Board identity |
| FPGA | XC7A100T-CSG324-1 | Board/device fact |
| Family | Artix-7 | Device fact |
| Logic cells | 101,440 | Device fact |
| 6-input LUTs | 63,400 | Device fact |
| Flip-flops | 126,800 | Device fact |
| DSP48E1 | 240 | Device fact |
| BRAM36 blocks | 135 | Device fact |
| Maximum block RAM | 4,860 Kb as specified by AMD/Digilent | Device fact |
| External memory | 256 MB DDR3L | Board fact |
| Physical DDR bus | 16 bit | Board fact |
| Memory clock | ~333 MHz | Board fact |
| Effective transfer rate | ~667 MT/s | Derived from DDR signaling |
| Theoretical peak transfer bandwidth | ~1.334 GB/s decimal, ~1.24 GiB/s | `667e6 × 2 bytes` |

### BRAM unit normalization

AMD/Digilent specify the device as **4,860 Kb** block RAM and 135 × 36-Kb
blocks. Do not equate decimal `KB` and binary `KiB` casually. Using the FPGA
block-RAM convention:

```text
135 × 36 × 1024 bits = 4,976,640 bits
                     = 622,080 bytes
                     ≈ 607.5 KiB
```

The architectural statement is therefore:

> The XC7A100T has 135 BRAM36 blocks, approximately 607.5 KiB of raw block-RAM capacity before implementation overhead and allocation to other subsystems.

## 23.2 DDR3L Performance Truth Boundary

The **1.334 GB/s** figure is a theoretical physical peak for ideal sustained
transfers. It is **not** measured semantic-graph throughput and it is not a
random-read guarantee.

Do not freeze any universal end-to-end DDR latency such as `50 ns`, `100 ns`,
`200–400 ns`, or `N cycles/hop` into the architecture without measurement from
the exact generated MIG configuration and workload.

Observed user-visible latency depends on, among other things:

- MIG user-interface ratio and scheduling;
- row/bank state and refresh;
- command/data handshakes;
- burst length and alignment;
- arbitration and outstanding requests;
- CDC and buffering;
- directory/posting indirection;
- cache hit/miss behavior;
- proof/provenance fetches.

Required measurements before a performance claim:

```text
sequential read bandwidth
sequential write bandwidth
mixed read/write bandwidth
random-address latency distribution
random posting-page latency
cache hit latency
cache miss penalty
forward lookup latency
reverse lookup latency
bounded multi-hop latency
DDR bytes/query
outstanding-request occupancy
```

## 23.3 Memory-Device Revision Rule

The board-level canonical contract is capacity/bus/rate, not a single memory
part number across all manufacturing revisions. Use the exact Digilent board
files/reference design for the physical board revision being built.

## 23.4 Board Interfaces

Canonical board capabilities include:

- shared USB-JTAG / USB-UART bridge;
- 4 user switches;
- 4 user push buttons;
- 4 standard LEDs;
- 4 RGB LEDs;
- 4 Pmod connectors;
- Arduino/chipKIT headers;
- 10/100 Ethernet.

User push buttons are active-high on the Arty design. Do **not** assume hardware
debounce; debounce is an RTL/software responsibility when required.

## 23.5 Local Environment Snapshot — NOT Architecture Authority

The following values are local-lab state and may change without changing the
Native AI architecture:

```text
Vivado/Vitis installation path
Vivado/Vitis version
COM port number
JTAG serial selected for a run
license location
MCP server path/port
local drive letters
```

These belong in an evidence/run manifest, not in a timeless hardware-constants
table. A board run must record its actual values at execution time.

Current project convention may use UART 115200-8-N-1 as the R0 laboratory
baseline, but baud rate is a transport parameter, not semantic identity.

## 23.6 DFX Scope

XC7A100T is supported by AMD Dynamic Function eXchange flows. This establishes
**feasibility of partial reconfiguration as a future tool**, not a requirement
for the Arty MVP and not a mechanism for autonomous runtime synthesis.

R0/R1 default remains full-bitstream rebuild for hardware specialization unless
a later experiment proves a DFX partition, rollback, timing, and lineage flow.

## 23.7 Claim Rules

- Peak bandwidth != sustained application bandwidth.
- Sustained bandwidth != random graph performance.
- Device capacity != available subsystem budget.
- Tool installation state != silicon capability.
- `PROGRAM_PASS` != semantic correctness.
- Hardware numbers must be sourced or measured, never inferred from metaphors.

## Tóm tắt tiếng Việt

Arty A7-100T dùng XC7A100T, có 135 BRAM36 (~607.5 KiB raw), 256 MB DDR3L,
bus 16-bit, khoảng 333 MHz / 667 MT/s, peak lý thuyết ~1.334 GB/s. Peak này
không phải băng thông truy vấn graph thực tế. Không khóa latency DDR bằng số ns
hay số cycle nếu chưa đo trên MIG thật. COM, JTAG serial, đường dẫn Vivado và
license chỉ là local run metadata, không phải chân lý kiến trúc.
