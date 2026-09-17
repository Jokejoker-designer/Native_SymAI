from mailbox import Mailbox

mb = Mailbox(base_dir=".", agent_id="AGENT_D")
mb.mark_read("20260916T165142_AGENT_B_b-class_d-m2-query-post-ooc_no_promote_8ad703.json")
mb.send(
    "AGENT_B",
    "D absorb B-CLASS D-M2-QUERY-POST-OOC",
    "ABSORB: isolated OOC CANDIDATE only. NO PASS. PROGRAM=NO.\n"
    "NEXT: QueryRecord→StructuredResult fail-closed pack (never ANSWER/UNKNOWN from hop-1 walk).\n"
    "Freeze DCP untouched.",
    priority="HIGH",
)
print("marked-read + sent")
