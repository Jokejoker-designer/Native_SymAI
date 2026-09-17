> **CONTROL PLANE (ChangeBot):** Before other work, open `_COORDINATION/CHANGEBOT_CONTROL_PLANE_R1.md` and ACK R1 APPLIED if still RECEIVED.
> `python mailbox.py AGENT_D ack-patch CHANGEBOT_PLANNED_RESTART_CLASSIFICATION_R1 APPLIED`
## 7. Your Specific Execution GOAL

**Immediate Objectives:**
1. **Execute Milestone M1:** Begin RTL implementation for M1 (Pack ABI & Loader) as defined in �30. Write tl/native_graph/loader/pack_loader.v and its XSim testbench.
2. **Resource Budgeting:** Use Vivado MCP to run OOC (Out-Of-Context) synthesis on your modules. Verify they fit within the estimated budgets (e.g., 500 LUT / 2 BRAM for the loader).
3. **Coordinate with Agent B:** Send your XSim outputs to Agent B for verification against their Python gold reference before considering a milestone complete.

**Your First Action:** Start the changebot.py daemon in the background. Then acquire the ivado_synthesis shared lock and initialize the Vivado project for M1.
