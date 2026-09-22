# OWNER OPERATING LOCK 2026-09-22

Owner: one Arty A7-100T. Do not split implementation across agents.
AGENT_D owns the product path. Agent C is not a work queue.
Frozen C RTL stays unedited: fem_lifecycle.v, spear_rank.v, qstar_select.v.
Frozen board identities stay immutable.

## Project goal

On this one board, one common runtime must make a committed generation the cause of both:

1. A StructuredResult whose evidence was read from that active generation.
2. A PrimitiveCommand whose primitive was authorized from that same generation, whose ObservedEffect is not the command bit, and whose experience can change a later decision.

A step is outside the goal while a testbench substitute still causes the output.
Dedicated FE256 silicon is a reference, not the goal.
A supported candidate, a positive WNS, End of startup HIGH, or a UART frame is not the goal.

## Claim ceilings

PROGRAM_PASS=NO
BOARD_PASS=NO
TIMING_PASS=NO
MIG_PASS=NO
PACK_ABI_24_24_PASS=NO
ASTRA_PASS=NO
FEM_PERSIST_PASS=NO
FE256_PASS=NO
SKILL_ENGINE_PASS=NO
CHAIN_OF_ACTIONS_PASS=NO
