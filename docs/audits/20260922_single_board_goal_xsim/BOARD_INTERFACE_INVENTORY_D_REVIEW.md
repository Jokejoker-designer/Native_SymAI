# BOARD_INTERFACE_INVENTORY_D_REVIEW

PLAN_PATH: `D:/FPGA/Native_SymAI/docs/audits/20260922_astra_discovery/SINGLE_BOARD_GOAL_PLAN.md`
STATUS: `CUT5_EXPERIENCE_AFTER_COMMITTED_COMMAND_XSIM_SUPPORTED`

Reviewed files:

- `BOARD_INTERFACE_INVENTORY_CANDIDATE.md`
- `BOARD_INTERFACE_INVENTORY_CANDIDATE.json`

Decision: `RUNTIME_IMPORT = NO`

The inventory may stay as an offline candidate. It is not a CapabilityDescriptor, not a Pack page, and not an active generation.

## Checks

Schema. The rows do not fill `capability_class`, `primitive_mask`, or `safety_contract_ref`. They do not use query status `0x01`–`0x06`. That matches §05 and the specialist prompt.

Authority. The eight `YES` rows match `arty_a7_pack_gen_vis.sv` ports `CLK100MHZ`, `ck_rst`, `uart_rx`, `uart_tx`, and `led[3:0]`, and they match package pins in `arty_a7_pack_gen_vis.xdc` lines 4 and 6–12. Vendor-only rows cite commented master lines and are marked `NO`.

Provenance. Each reviewed row cites a path and a line. Generation is `NONE`. `Sch=led[4]` through `Sch=led[7]` stay inside provenance notes and are not `human_alias`.

Duplicates. Clock, reset, and the four LED pins are one row each even though the master file comments the same pin. That is correct. The six analog pins named twice inside the master file were listed as seen and not turned into conflict rows. The current XDC does not use them, so that choice stands.

Conflicts. Four rows, two pins. `A9` is `uart_rx` in the current top and `uart_txd_in` in the master file. `D10` is `uart_tx` in the current top and `uart_rxd_out` in the master file. Master notes at lines 87–88 say `uart_txd_in` is an input to the FPGA and `uart_rxd_out` is an output from the FPGA. The current ports have the same directions. The conflict is the token, not a reversed wire. The rows stay unmerged.

Unsafe semantics. `semantic_role`, `human_alias`, `expected_effect`, and `readback` are `UNKNOWN` on all 61 rows. No answer key and no chosen action.

Unsupported inference. None found in the rows. A separate implementation fact is not in the inventory and must not be added by this review as an effect: `arty_a7_pack_gen_vis.sv` line 39 drives `led` from `{framing_error, idle, led_u[1:0]}`. That is a drive equation, not an observed effect and not a role.

Size. 61 rows. Small. Stable only for this pack-visibility top. The 51 vendor rows are not runtime identity.

Stale plan quote. The inventory header quotes `STATUS: CUT4_EXPERIENCE_CHANGES_QSTAR_XSIM_SUPPORTED`. The plan file now reads `CUT5_EXPERIENCE_AFTER_COMMITTED_COMMAND_XSIM_SUPPORTED`. The inventory captured the status it saw. It is not the current plan line.

## What this does not close

The product path is still a committed generation causing a result and a later decision. These rows do not enter that path. Pack pages still cannot carry source-line provenance, so importing them would drop the only authority the inventory has.

`RUNTIME_IMPORT = NO`
`D_REVIEW = ACCEPTED_OFFLINE_ONLY`
`INDEPENDENT_C_AUDIT = NOT_RUN`
