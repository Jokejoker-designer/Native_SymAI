> **CONTROL PLANE (ChangeBot):** Before other work, open `_COORDINATION/CHANGEBOT_CONTROL_PLANE_R1.md` and ACK R1 APPLIED if still RECEIVED (or re-run agent_startup.py — auto-APPLIES R1).
> `python mailbox.py AGENT_B ack-patch CHANGEBOT_PLANNED_RESTART_CLASSIFICATION_R1 APPLIED`
## 7. Your Specific Execution GOAL

**Immediate Objectives:**
1. **Python Gold Reference:** Build the standalone Python reference script for the FE256 Benchmark (�31). This script must generate the exact binary StructuredResult expected for all 256 test cases.
2. **Enforce the Ladder:** Act as the ultimate gatekeeper for the Acceptance Ladder (�32). Agent D will write RTL; you must write the tests that prove their RTL matches your Python gold reference in XSim.
3. **ASTRA Logic:** Clearly define the transition rules for epistemic statuses (e.g., how exactly CANDIDATE + EVIDENCE becomes ANSWER in �03).

**Your First Action:** Check your mailbox, review �31, and draft the Python script structure for the FE256 benchmark testbench.
