# CHANGEBOT CONTROL PLANE — APPLY GATE (do not ignore)

PATCH: `CHANGEBOT_PLANNED_RESTART_CLASSIFICATION_R1`
YOUR STATE: RECEIVED (APPLIED still required)
CLASSIFICATION: PLANNED_RESTART (not crash / not FEM defect)

Apply = update local operational model, then ACK:

```text
python mailbox.py AGENT_B ack-patch CHANGEBOT_PLANNED_RESTART_CLASSIFICATION_R1 APPLIED
```

(For AGENT_D, replace AGENT_B with AGENT_D.)

Note in ACK optional:
`note=old_process_status=INTENTIONAL_TERMINATION replacement_status=HEALTHY classification=PLANNED_RESTART`
