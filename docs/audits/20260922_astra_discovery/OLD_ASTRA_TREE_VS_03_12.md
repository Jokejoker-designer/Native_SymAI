# Old ASTRA tree versus Canon §03.12

LANGUAGE=EN
RUN_ID: 20260922T072600Z
TREE: D:/FPGA/FPGG_ART_Y_ASTRA_NATIVE_V1_RESEARCH
RTL_COPIED=NO

Verdict for action-precheck reuse: NOT_RELEVANT

No `a7ng_astra_*` module emits `ASTRA_DENY`, `SAFETY_VETO`, `STALE_DESCRIPTOR`, `NO_BINDING`, or `BOUND`. Search of those names and of `ACTION_INTENT` / `safety_contract` in `rtl/**/a7ng_astra_c*.sv` found no such ports.

C3 status in `a7ng_astra_c3_held_out.svh` is a local 4-bit query code: ANSWER=0, UNKNOWN=1, CONFLICT=5, INCOMP=6. That is not Canon query `0x01–0x06` and not an action verdict.

`a7ng_astra_c4_answer_gate_v1` outputs `answer_allowed_o` from C3 status, path count, and `proof_ok`. That is a query-answer gate.

C4/C5 production wrappers bind that gate to alias and materializer logic. C6 canonical query is retrieval, typed proof, reward, and pending. C6 UART/DDR files are transport. C2 is persist. No `a7ng_astra_c7*.sv` module was found under `rtl/`.

`astra_walk_qeval.sv` was not found under `D:/FPGA`. Current query RTL remains `astra_qeval.sv` and `astra_edge_qeval.sv`, both Q-eval, neither an action precheck.

Do not import this tree as the §03.12 machine.
