# Independent ASTRA discovery audit

LANGUAGE=EN
RUN_ID: 20260922T071900Z
RTL_EDIT=NO
BITSTREAM=NO
PROGRAM=NO

Live sources: `Native_SymAI/CANON_BLUEPRINT/`. Not an ASTRA_PASS.

## Canon

§03 opening: ASTRA is the deterministic authority for legality, proof validity, provenance, conflict, completeness, epistemic status, and knowledge promotion. It is not an omniscient oracle.

§03.1 questions it owns include legality, evidence adequacy, conflict, emitted epistemic status, promotion, and whether intent+descriptor+safety may bind. It does not own next-action (Q*), first-candidate (SPEAR), pin execution, or human wording.

§03.7: Q* creates strategy, not truth. SPEAR creates rank, not truth, proof, or a legality override. FEM creates failure records, not FACT promotion.

§03.8 places ASTRA verification after Top-K on the query/evidence path. §03.9 splits K-promote from Q-eval. §03.12 is a second machine: action-precheck of `ACTION_INTENT` + `CapabilityDescriptor` + `safety_contract`, with results `ASTRA_DENY` / `SAFETY_VETO` / `BOUND` that must not reuse query status `0x01–0x06`.

Glossary line: `ASTRA_QUERY_STATUS != ASTRA_ACTION_VERDICT`. §20.5.1 repeats that actuation statuses are not query encodings.

Master §Physical Action Authority Path and §Runtime Reasoning Path keep those as two diagrams, not one box after Q*.

## RTL

`astra_qeval.sv`: pre-search candidate. Inputs are QueryRecord bytes plus CRC/magic fails. Outputs are status/reason/completeness. Header says it never emits ANSWER, UNKNOWN, or CONFLICT. Caller: `query_result_bind.sv`. No SPEAR or Q* port.

`astra_edge_qeval.sv`: common-runtime Q-eval over an edge ROM. Can emit ANSWER, CONFLICT, UNKNOWN, SEARCH_INCOMPLETE, UNSUPPORTED, DATA_INTEGRITY_FAIL. Caller found: `tb_common_runtime_fe256_xsim_compare.sv` only. No SPEAR, Q*, or walker port. `COMMON_RUNTIME_FE256_STATUS` remains NOT_RUN in project law.

`verification/astra_adv/astra_adv_dut.sv`: fail-closed shell. `q_ready` and `s_ready` tied 0. Header says not production RTL. Gold is `astra_adv_gold.py`, expectation only.

No module emits `ASTRA_DENY` or `SAFETY_VETO`.

`ACTION_VERDICT_IMPLEMENTATION_NOT_FOUND`

## Verification and history

`verification_r1/05_FE256_AND_ASTRA_R1.md` §4 requires the adversarial suite to separate ANSWER, UNKNOWN, CONFLICT, SEARCH_INCOMPLETE, UNSUPPORTED_QUERY, and DATA_INTEGRITY_FAIL. The XSim compare is bound to the stub, so those laws are gold/expectation, not a passing DUT.

Roadmap M4 asks whether ASTRA maps evidence to proof/status without utility override. Recorded M4 XSim names are candidates and explicitly not `ASTRA_PASS`. Board UART smoke of the M4 path was fail-closed `SEARCH_INCOMPLETE` / reason `0x20`. That is a query-status observation, not an action verdict.

Localized drift: `astra_qeval` maps CRC/magic failure to reason `0x55`. §03.9.2 Q-INT names `PACK_CRC` / `STALE_GENERATION` for integrity failure. `astra_edge_qeval` does carry separate CRC and stale reason constants.

## Integration answer

The FEM→SPEAR→Q* board chain is utility/strategy. Current ASTRA RTL does not consume its rank or its action. Putting query-status RTL after Q* would mix the two machines §03.9 and §03.12 forbid.

`READY_FOR_FEM_SPEAR_QSTAR_INTEGRATION = NO`
