# BOARD_KNOWLEDGE_FOUNDATION_AUDIT

PLAN_PATH: `D:/FPGA/Native_SymAI/docs/audits/20260922_astra_discovery/SINGLE_BOARD_GOAL_PLAN.md`
STATUS: `CUT4_EXPERIENCE_CHANGES_QSTAR_XSIM_SUPPORTED`
CURRENT_FRONTIER: `PHYSICAL_DDR_ONLY_IF_SIM_CANNOT_ANSWER`

This audit does not reopen frozen RTL or board identities. It does not change that frontier.

Answer: Native_SymAI currently possesses the architecture for knowledge. It does not possess a canonical board-native knowledge corpus loaded or loadable as runtime evidence.

`BOARD_KNOWLEDGE_FOUNDATION = PARTIAL`

## CURRENT_KNOWLEDGE_ARCHITECTURE

Five layers exist as designs or as local mechanisms. They are not one corpus.

Substrate. Widths, opcodes, and address rules live in RTL. Pack slot bases, SPEAR descriptor fields, Q* `proposed_action[2:0]`, action verdicts `B0`–`B4`, and query statuses `0x01`–`0x06` are implementation facts. Class: `IMPLEMENTED` for the modules that contain them. They are not runtime records the query lane can retrieve.

Board capability. The recent pack-visibility top constrains clock `E3`, reset `C2`, UART `A9`/`D10`, and four LEDs `H5 J5 T9 T10` in `D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.xdc`. The top `arty_a7_pack_gen_vis.sv` uses UART and those LED ports. Buttons, switches, RGB LEDs, and Pmod pins appear only as commented lines in `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`. Class of the master file: `DESIGN_CANDIDATE` vendor collateral, not `RUNTIME_ACTIVE`.

Semantic objects. Canon `D:/FPGA/Native_SymAI/CANON_BLUEPRINT/05_CAPABILITY_AND_ACTION_BINDING.md` defines `CapabilityDescriptor` as `AUDITED_CANDIDATE`. Canon `12_SKILL_AND_TEACHING.md` defines `SkillRecord` and says a raw sensor event is not a fact and an alias does not change identity. The live tail `action_product_r1.sv` installs one constant descriptor, id `32'hC1`, mask `8'h03`. Pack visibility records are solved SPEAR payloads for subjects `0x00010100` and `0x00010101`, not board objects. Class: `SCHEMA_ONLY` for the canon descriptor, `SIM_ONLY` for the constant and the synthetic records.

Experience. `fem_lifecycle.v` accepts domain-0 ingress and exports `fem_feat` as `failure_total`. XSim log `e3f45e07…` shows one ingress changes the next Q* proposal while `command_valid` stays 1. `t2_ready` is tied 1. Class: `IMPLEMENTED` mechanism, `SIM_ONLY` for that causal cut. Persist identity `1db38691` is a board candidate for compact media, not a catalog of effects. `FEM_PERSIST_PASS=NO`.

External reference. Canon chapters and the Digilent master XDC are on disk. They are not imported into an active generation.

## CURRENT_BOARD_GROUNDING

| Item | What exists | What runtime knows |
| --- | --- | --- |
| Clock E3, reset C2 | XDC of the pack-vis top | Pin constraint only. No capability record. |
| UART A9/D10, 115200 | XDC plus UART smoke on frozen identities | Host protocol. Not a semantic object. |
| LED[0:3] H5 J5 T9 T10 | XDC and top ports | Writable pins. No readback record. No alias. No role. |
| Buttons, switches, RGB | Commented vendor XDC only | `NOT_FOUND` in the current top. |
| DDR / mig0 | Generated-core candidates exist historically. Current window is `mig_ui_bram`. | `SIM_ONLY` stand-in. `MIG_PASS=NO`. |
| JTAG `210319BE776EA`, UART FTDI `210319BE776EB` | Workspace notes from earlier programs | Not a runtime record. |

Physical presence of a pin is not runtime knowledge of that pin, and neither is a semantic role.

## EXISTING_RUNTIME_KNOWLEDGE

Active generation selects pack bytes. Query evidence and a primitive command can follow that generation in XSim (`4f053828…`). The evidence is a projection of the same descriptor. Status stays `0x04` `SEARCH_INCOMPLETE`, not `0x01` `ANSWER`.

Skill start can come from a testbench record word (`41035b83…`). That record is not a pack commit.

One capability constant binds primitives 0 and 1. Primitive 2 misses. There is no manifest the runtime can enumerate.

## EXISTING_BOARD_KNOWLEDGE_SOURCES

Authoritative for pin package and IOSTANDARD of the current image: the XDC actually applied to that top.

Authoritative for what the current image instantiates: the top RTL ports.

Authoritative for the vendor board's full pin list, including parts this image does not use: the commented master XDC. Low trust for "this runtime has it."

Authoritative for epistemic vocabulary: `D:/FPGA/Native_SymAI/CANON_BLUEPRINT/03_ASTRA_AUTHORITY.md` statuses `0x01` ANSWER through `0x06` DATA_INTEGRITY_FAIL, and `12_SKILL_AND_TEACHING.md` §12.7 grounding order. These are schemas, not filled records.

Not authoritative as board facts: chat summaries, synthetic pack subjects, theta constants, and `8'h03` masks.

## IMPLEMENTED_VS_DESIGN_CANDIDATE

| Object | Class |
| --- | --- |
| `fem_lifecycle.v`, `spear_rank.v`, `qstar_select.v` | `IMPLEMENTED`, frozen |
| `action_product_r1.sv` one descriptor | `IMPLEMENTED` substitute |
| `primitive_executor_r1.sv` effect table | `SIM_ONLY` substitute |
| `skill_select_from_record_r1.sv` | `SIM_ONLY`, records not from Pack |
| `CapabilityDescriptor` field list §05 | `SCHEMA_ONLY` |
| `SkillRecord` 256-bit layout §12 | `DESIGN_CANDIDATE`, unit uses a subset |
| Master Arty XDC | `DESIGN_CANDIDATE` external |
| Pack G1/G2 SPEAR words | `SIM_ONLY` synthetic |
| UART board smokes | `BOARD_PROVEN` only for those frames, not a knowledge corpus |
| Board capability manifest | `NOT_FOUND` |

## CURRENT_PROVENANCE_PATH

Identity of a programmed image is a bitstream SHA plus program notes. FEM compact provenance is UART and SHA, not a live SRAM hash. Skill records have a `provenance_ref` field in the contract and the unit tests leave it zero. Pack commit has `active_generation`. None of these say "this LED record came from the vendor XDC line N."

## CURRENT_IMPORT_PATH

Pack loader can commit a generation into a slot window. The committed bytes in current experiments are hand-solved descriptors. There is no importer from XDC or from canon into that window. Import of a knowledge corpus is `NOT_FOUND`.

## CURRENT_GROUNDING_PATH

§12.7 requires raw event, observation, episode, then ASTRA status, with alias attached later. The code path that exists is ingress into FEM and a feature into Q*. It does not observe LED readback, button level, or DDR contents as named capabilities. `WRITE accepted != effect occurred` is already a law in §05. The executor substitute does not read the board.

## MISSING_BOARD_NATIVE_KNOWLEDGE

A record, per physical thing the current image or the vendor board exposes, with package pin, direction, width, current-top presence, and provenance. Legal operations as data. Expected effect left unknown until readback. Human alias absent unless taught. Semantic role absent unless taught.

## MISSING_EXTERNAL_REFERENCE_KNOWLEDGE

The vendor pin list is on disk and unused. It must stay marked vendor-spec, not runtime-present. No compiled record set exists.

## SCHEMA_GAPS

`CapabilityDescriptor` has no field for source file, source line, or epistemic class of the import. Pack pages used today do not carry that provenance. Fitting a pin list into the current SPEAR payload would drop provenance. Do not do that.

Query status codes must not be reused as action verdicts. Skill lifecycle must not be reused as execution permission.

## RUNTIME_GAPS

No enumerator of installed capabilities. `active_generation` cannot retrieve a board manifest because none is committed. Observed effect is not wired from a pin readback into FEM on the product path.

## CANON_CONFLICTS

No contradiction found between §05 "descriptor must not contain semantic winners" and the empty corpus. The conflict to avoid is treating the synthetic pack subjects or the constant `0xC1` as that manifest.

## Readiness

| Gate | Value | Evidence |
| --- | --- | --- |
| REPRESENTATION_READY | PARTIAL | §05 and §12 name the objects. Live records do not fill them. |
| MEMORY_READY | PARTIAL | Pack slots and FEM T2 ports exist. `mig_ui_bram` is not `mig0`. |
| PROVENANCE_READY | PARTIAL | SHA and generation exist. Source-kind provenance for imports does not. |
| CAPABILITY_MODEL_READY | PARTIAL | One hardcoded descriptor. No manifest. |
| BOARD_SOURCE_READY | PARTIAL | One applied XDC plus a vendor master file. |
| ACTUAL_CORPUS_READY | NO | No board-native record set. |
| RUNTIME_IMPORT_READY | NO | No XDC-to-pack path. |
| GROUNDING_READY | NO | No pin readback as observation. |
| QUERY_USE_READY | NO | Query evidence is not a capability record. `ANSWER` is not emitted. |
| ACTION_USE_READY | PARTIAL | Primitive 0 and 1 bind to `0xC1` in simulation. That is not the board pin set. |

Derived vector or embedding authority is not designed here. Exact records with provenance would be a sufficient base for a later derived form. That base corpus does not exist yet, so a derived form would have nothing trustworthy to project.

`BOARD_KNOWLEDGE_FOUNDATION = PARTIAL`
