# KNOWLEDGE SPECIALIST — OFFLINE BOARD IDENTITY INVENTORY

You are a read-only collector. You do not own Native_SymAI architecture. Agent D does.

Do not edit RTL, XDC, canon, pack memories, or bitstreams. Do not load anything into Pack, T2, or a running image. Do not write query answers, primitive choices, proof paths, or benchmark labels.

## MISSION

Build an offline inventory of physical interfaces for the Arty A7-100T materials already in this repository.

For each interface, record only what a cited source says: package pin, port name, direction if stated, width, IOSTANDARD, and whether a current top actually instantiates that port.

Leave semantic role, human alias, expected effect, and safety meaning as `UNKNOWN` unless a cited source states them. A pin name is not a role. `led[3]` is not `STATUS_OUTPUT`. A write strobe is not an observed effect.

## PROJECT CONTEXT

The product goal is one committed generation causing both a StructuredResult and a later action whose observed effect can change a later decision. That goal is not your job.

Current plan:

`D:/FPGA/Native_SymAI/docs/audits/20260922_astra_discovery/SINGLE_BOARD_GOAL_PLAN.md`

Read it and quote `STATUS` before you write. Do not change the plan. Do not open DDR, skill, or FEM work.

The audit you must stay inside:

`D:/FPGA/Native_SymAI/docs/audits/20260922_astra_discovery/BOARD_KNOWLEDGE_FOUNDATION_AUDIT.md`

`D:/FPGA/Native_SymAI/docs/audits/20260922_astra_discovery/BOARD_KNOWLEDGE_AUTHORITY_MATRIX.md`

There is no board capability corpus yet. Your output is the first offline candidate for D to review. It is not runtime truth.

## EXACT SOURCES TO READ

Read these, in this order:

1. `D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.xdc`
2. `D:/FPGA/arty_d/UART_R2/pack_gen_vis/arty_a7_pack_gen_vis.sv` port list only
3. `D:/FPGA/Native_SymAI/REFERENCE_EXTERNAL/UART_DDR/arty-parrot/common/xdc/Arty-A7-100-Master.xdc`
4. `D:/FPGA/Native_SymAI/CANON_BLUEPRINT/05_CAPABILITY_AND_ACTION_BINDING.md` sections 5.1 through 5.3 only, as schema names
5. `D:/FPGA/Native_SymAI/CANON_BLUEPRINT/12_SKILL_AND_TEACHING.md` section 12.7 only, as grounding order
6. `D:/FPGA/Native_SymAI/CANON_BLUEPRINT/03_ASTRA_AUTHORITY.md` status list `0x01`–`0x06` only, so you do not reuse those codes

If a file is missing, record `UNKNOWN` for that source. Do not replace it with memory.

## SOURCE AUTHORITY ORDER

1. A port that exists on `arty_a7_pack_gen_vis.sv` and a matching XDC line. Class `IMPLEMENTATION_FACT` plus `BOARD_FACT` for the package pin of that top.
2. An XDC line with no matching port. Class `IMPLEMENTATION_FACT` that the constraint file mentions it, and `UNKNOWN` for runtime presence.
3. A commented line in the master XDC. Class `VENDOR_SPEC`. Runtime presence `UNKNOWN` or explicitly not in the current top.
4. Canon prose. Class `DESIGN_CANDIDATE` for schemas. Not a filled record.
5. Anything else. Do not use it.

## WHAT TO EXTRACT

One row per interface token you actually saw: clock, reset, `uart_rx`, `uart_tx`, `led[0]` through `led[3]`, and each commented `sw`, `btn`, RGB LED, and `ck_io` name you choose to include from the master file.

Fields:

```text
interface_token
package_pin
iostandard
width
direction
current_top_has_port   YES or NO
source_path
source_line
epistemic_class
semantic_role          UNKNOWN unless the source states it
human_alias            UNKNOWN unless the source states it
expected_effect        UNKNOWN
readback               UNKNOWN
provenance_note
```

Map classes only as follows.

- `BOARD_FACT`: package pin and IOSTANDARD from an XDC line you read.
- `IMPLEMENTATION_FACT`: a port exists, or does not exist, on the cited top.
- `VENDOR_SPEC`: commented master XDC.
- `DESIGN_CANDIDATE`: a canon field name you are not filling.
- `UNKNOWN`: any role, alias, effect, or safety claim.
- `CONFLICT`: two sources disagree. Keep both rows.
- Do not emit `OBSERVED_EFFECT`, `DEMONSTRATED_RELATION`, or `LEARNED_EXPERIENCE`. You did not run the board.
- Do not emit `ANSWER` or query status `0x01`.

## WHAT NOT TO INFER

Do not infer that an LED displays status, that a button is a command, that UART is a teacher, or that DDR is installed knowledge. Do not infer legality of an operation from the pin name. Do not copy `capability_id 0xC1` or mask `8'h03` into these rows. That constant is a different substitute.

## TARGET KNOWLEDGE MODEL

Write records that could later be compared to a `CapabilityDescriptor`, but do not claim they are one. Leave `capability_class`, `primitive_mask`, and `safety_contract_ref` as `UNKNOWN`.

Do not encode the rows as SPEAR descriptors or Pack pages. The current pack page has no source-line provenance. Dropping provenance to fit that page is forbidden.

## PROVENANCE REQUIREMENTS

Every row must answer, in its own fields: source path, source line, epistemic class, and what would invalidate it. Invalidation for an implementation fact is "the cited file no longer contains that port or pin." Invalidation for a vendor spec is "the master XDC line changed or was never uncommented in a current top."

Generation is `NONE`. These rows are not in an active generation.

## CONFLICT HANDLING

If the master file and the current XDC name the same package pin differently, emit two rows and `CONFLICT`. Do not merge them.

## UNKNOWN HANDLING

Absence of a sentence is `UNKNOWN`, not false. In particular, readback and expected effect stay `UNKNOWN`.

## OUTPUT ARTIFACTS

Write only:

`D:/FPGA/Native_SymAI/docs/audits/20260922_astra_discovery/BOARD_INTERFACE_INVENTORY_CANDIDATE.md`

And a machine-readable twin:

`D:/FPGA/Native_SymAI/docs/audits/20260922_astra_discovery/BOARD_INTERFACE_INVENTORY_CANDIDATE.json`

The JSON is an array of objects with the fields above. No other files.

## VALIDATION CHECKS

Before you finish, check:

- Every `YES` under `current_top_has_port` cites a port in `arty_a7_pack_gen_vis.sv`.
- Every package pin cites an XDC line.
- No row contains a semantic role other than `UNKNOWN` unless a quotation from a source is in `provenance_note`.
- No row tells a query what status to return or a policy what action to pick.
- Commented master pins are not marked as ports of the current top.

## FORBIDDEN CHANGES

No RTL. No XDC edits. No pack memory edits. No bitstream. No canon edits. No plan STATUS edit. No import into FEM, Pack, or T2.

## HANDOFF FORMAT

End the markdown file with:

```text
ROW_COUNT:
CURRENT_TOP_PORT_COUNT:
VENDOR_ONLY_COUNT:
CONFLICT_COUNT:
UNKNOWN_ROLE_COUNT:
READY_FOR_D_REVIEW: YES
RUNTIME_IMPORT: NO
```

D will review schema fit, authority, provenance, duplicates, conflicts, and size before any later import. Your handoff is not that import.
