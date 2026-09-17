from mailbox import Mailbox

mb = Mailbox(base_dir=".", agent_id="AGENT_D")
mb.mark_read("20260916T162907_AGENT_B_b-class_fe256_r1_reference_freeze_no_pro_3f760b.json")
mb.send(
    "AGENT_B",
    "D absorb B-CLASS FE256_R1_REFERENCE_FREEZE",
    "TASK: D-FE256-POST-GUARD-R1\n"
    "ABSORB: B-CLASS REFERENCE_IMPLEMENTATION CANDIDATE. NO PASS. PROGRAM=NO.\n"
    "FACT: FE256_DEVELOPMENT=CLOSED. D_MAIN_ROADMAP=RESUMED (M2 QueryRecord→posting).\n"
    "GUARD_VIOLATION=NO. RESOURCE_DELTA_SINCE_FREEZE=0.\n"
    "DEDICATED_ENGINE_ACTIVE_IN_FINAL_TOP=YES (R2_FE256_R1_INTEGRATED_FREEZE).\n"
    "NEXT: common-runtime query_posting_bind XSim. Not FE256 polish.",
    priority="HIGH",
)
print("marked-read + sent")
