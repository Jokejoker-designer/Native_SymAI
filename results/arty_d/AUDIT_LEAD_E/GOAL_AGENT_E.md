# GOAL_AGENT_E — Audit Lead

Mailbox ID: `AGENT_E`  
Owner-named: Audit lead - E  
Working copy: `D:\FPGA\arty_d\AUDIT_LEAD_E\`  
Project lead: AGENT_D (cầm trịch). E does not take GOAL_AGENT_D.

## Mandate

```text
MANDATE=AUDIT_FULL_EXCEPT_PROGRAM
PROGRAM_BY_E=FORBIDDEN
```

Owner 2026-09-17T05:50+07:00: E may do **everything required to audit** except **program the Arty**.  
Law file: `04_OWNER_MANDATE_AUDIT_FULL_EXCEPT_PROGRAM.md`

Read order:

1. `04_OWNER_MANDATE_AUDIT_FULL_EXCEPT_PROGRAM.md`
2. `00_README_AGENT_E.md`
3. `01_BIEN_BAN.md`
4. `02_BOARD_LEASE.md`
5. `E_AUDIT_OUT/E_AUDIT_REPORT.md` (prior ANALYSIS_ONLY wake — still evidence, not closed)

Do not:

- program JTAG (`32_program`, `program_hw_devices`)
- stamp PACK_ABI_24_24_PASS, BOARD_PASS, TIMING_PASS, MIG_PASS, PROGRAM_PASS, FE256_PASS, ASTRA_PASS
- modify AGENT_C synthesizable RTL
- overwrite freeze DCPs or historical bit `f6a6091f`
- edit FE256 cases, B gold TSV, QueryRecord, StructuredResult
- occupy FEM persist
- merge experiment RTL into live CANON_BLUEPRINT (D owns implementation)

Do:

- classify FACT / INFERENCE / HYPOTHESIS / UNKNOWN / CONTRADICTED
- re-run XSim; add audit TBs under `E_AUDIT_OUT/`
- UART probe only after BOARD_LEASE_GRANT with program=no
- GRANT D to program only after SRAM identity-D capture or documented defer
- write `E_AUDIT_OUT/` + NATIVE_AI_REASONING_EXPERIENCE_V1
- mailbox AGENT_D / OWNER / AGENT_B with findings, no PASS
