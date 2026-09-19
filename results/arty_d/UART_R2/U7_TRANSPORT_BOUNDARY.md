# UART_R2_U7 — transport boundary (Ethernet ON_HOLD)

TASK: UART_ROOT_CAUSE_AND_RESILIENCE_R2  
PHASE: U7  
OWNER: AGENT_D  
RUN_ID: 20260917T142300Z  
ETHERNET: DEFERRED / ON_HOLD. Do not implement. Design/evidence not deleted.

## Common ingest contract (reusable)

```text
TRANSPORT
  → complete validated COMMAND or QueryRecord
  → COMMON INGEST
       Pack:  loader (inactive/staging dest) → drain → integrity → sentinel
              → atomic active_generation
       Query: full QueryRecord ABI/integrity → one q_valid beat → snapshot generation
              → reason on that snapshot only
```

M2/M3/ASTRA must not see UART baud, `bix`, COM port, byte timing, host pacing,
or future Ethernet session IDs.

## TRANSPORT-SPECIFIC (UART, this campaign)

- 8N1 bit sampler, `bix` 4-byte assembler, STOP=1, `need_mark` BREAK recover
- `w_valid`/`w_ready` ownership (U1 hold, not silent drop)
- `word_fifo32` DEPTH=128 clk100 (no RTS/CTS)
- `pack_debug_clear` 0x44524743 / ACK / BUSY (validation only)
- COM12 115200 FTDI, identity H bitstream (frozen, not this candidate)
- Host Pack/ACK window and paced vs burst scheduling
- CLEAR quiet uses **physical MARK** (`rx_d`) plus empty logical partials

## REUSABLE (must survive TRANSFER_TO_ETHERNET)

- Complete record/command before ingest
- Staging vs active generation (physical storage ≠ semantic visibility)
- Atomic `S_COMMIT` of `active_generation`
- Failed N+1 leaves N
- Query snapshot of one generation (POLICY B serialize for R1)
- Distinct layers: framing ≠ transport CRC ≠ Pack ABI ≠ ASTRA VERIFIED
- Finite buffer + **bounded host window** (pacing is not correctness)
- CLEAR/abort destroys **logical partial** state, not necessarily PHY sample flops
- FIFO empty / link idle / host-done / PROGRAMMED are not destination-complete
- Link-quiet for abort must be physical idle, not “assembler forced idle”

## STRUCTURAL GUARDS to carry to Ethernet

| Guard | Rule |
|---|---|
| G-U1-NO-SILENT-DROP | No complete frame/word advance without handshake or owned storage |
| G-U2-STOP-MUST-BE-ONE | Malformed framing never becomes payload |
| G-U3-CLEAR-LOGICAL-PARTIAL | Abort drops partial assembler/FIFO/CDC/command/record; quiet is PHY mark |
| G-U4-NO-TIMEOUT-WITHOUT-SEPARATION | Do not use idle timers as integrity without proven gap |
| G-U5-ONE-FIFO-PLUS-HOST-WINDOW | One elastic buffer; credit/ACK window; no stacked mystery FIFOs |
| G-U6-NO-REASON-FROM-UNCOMMITTED | No M2/M3/ASTRA visibility from partial or uncommitted generation |

Do not assume UART H19/H20 is the Ethernet root cause.
