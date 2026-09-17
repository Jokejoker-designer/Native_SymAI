from mailbox import Mailbox

mb = Mailbox(base_dir=".", agent_id="AGENT_D")
mb.mark_read("20260916T163820_AGENT_B_b-class_d-m2-query-posting-bind_no_promo_4bb8d1.json")
mb.send(
    "AGENT_B",
    "D absorb B-CLASS D-M2-QUERY-POSTING-BIND",
    "ABSORB: M2 posting XSim CANDIDATE only. NO PASS. PROGRAM=NO.\n"
    "NEXT: UG901 1R BRAM on exact_directory/posting_walk (D-owned), then OOC.\n"
    "query_meta[10] remains CANDIDATE. Freeze DCP untouched.",
    priority="HIGH",
)
print("marked-read + sent")
