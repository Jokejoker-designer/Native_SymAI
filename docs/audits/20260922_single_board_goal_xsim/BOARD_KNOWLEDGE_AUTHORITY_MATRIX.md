# BOARD_KNOWLEDGE_AUTHORITY_MATRIX

Facts about what this repository contains. Not a permission to import them.

| KNOWLEDGE_TYPE | SOURCE | AUTHORITY_LEVEL | MACHINE_READABLE | CURRENTLY_IMPORTED | PROVENANCE_AVAILABLE | TRUST_BOUNDARY | CONFLICT_RULE |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Current-image pin constraint | `arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.xdc` | High for that top only | YES | NO | File path only | Does not describe buttons, RGB, or DDR | If the top RTL has no port, the XDC line is not a runtime capability |
| Current-image ports | `arty_a7_pack_gen_vis.sv` | High for that top only | YES | NO | File path only | Ports are not semantic roles | Port name is an implementation fact |
| Vendor full pin list | `REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc` | Medium as vendor collateral | YES, mostly commented | NO | File path and line | Commented lines are not implemented | Vendor pin present and current top silent means NOT in this runtime |
| Action capability | `action_product_r1.sv` constants `CAP_ID=32'hC1`, `MASK=8'h03` | High as what that module does | YES | Hardcoded, not packed | None beyond the file | One substitute descriptor | Do not treat it as the Arty manifest |
| Query epistemic status | `CANON_BLUEPRINT/03_ASTRA_AUTHORITY.md` | High as vocabulary | Prose | NO | Canon version header | Not an action verdict | `0x01`–`0x06` stay query-only |
| Capability schema | `CANON_BLUEPRINT/05_CAPABILITY_AND_ACTION_BINDING.md` | High as schema, not as filled data | Prose | NO | `AUDITED_CANDIDATE` | Must not hold benchmark answers | Schema is not a corpus |
| Skill schema and grounding order | `CANON_BLUEPRINT/12_SKILL_AND_TEACHING.md` | High as schema | Prose | NO | Canon header | Alias is not identity | Lifecycle is not permission |
| Synthetic semantic records | `pack_gen_vis` G1/G2 memories, subjects `0x00010100` / `0x00010101` | High as test stimulus | YES | Used in XSim and one board candidate | Generation in the record | Not board objects | Do not retitle them as LED or UART knowledge |
| Experience counters | `fem_lifecycle.v` `fem_feat` | High as the counter the RTL exports | YES | Wired in XSim wrappers | Ingress key fields | Not a fact and not an action | A count is not a pin effect |
| Observed effect substitute | `primitive_executor_r1.sv` table | Low | YES | Testbench table | Labeled substitute | Not a sensor | Table success is not readback |
| Programmed-image identity | Bitstream SHA notes under `arty_d/UART_R2/results` | High for "what was programmed" | PARTIAL | NO | SHA and UART logs | Not live SRAM | Do not promote smoke to `BOARD_PASS` |
| Chat or summary paraphrase | Conversation summary | None | NO | NO | NO | Forbidden as a source | Read the file named in the plan |

Conflict rule for the specialist: when two sources disagree, keep both records, mark `CONFLICT`, and do not pick a winner. D resolves conflicts later. A commented vendor pin never overrides a missing port.
