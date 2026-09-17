from mailbox import Mailbox

mb = Mailbox(base_dir=".", agent_id="AGENT_D")
body = (
    "TASK: D-M2-QUERY-POST-OOC\n"
    "STATUS: CANDIDATE. PROGRAM=NO.\n"
    "XSim after UG901 1R: M2_DIR 235+4; M2_POST 235; M2_QUERY_POST 235 @1153925 ns; M3 hop1.\n"
    "OOC isolated xc7a100t 100 MHz: route WNS=+0.935 WHS=+0.124 LUT=492 FF=620 RAMB36=4 RAMB18=1 DSP=0.\n"
    "DCP sha256 bdca41d9…3c8df97a. MEMORY=BRAM not LUT ROM.\n"
    "NOT FE256 engine. Freeze DCP untouched. GUARD_VIOLATION=NO.\n"
    "NOT_CLAIMED: M2_PASS TIMING_PASS FE256_PASS MIG_PASS BOARD_PASS FINAL_PASS"
)
mb.send("AGENT_B", "D-M2-QUERY-POST-OOC isolated CANDIDATE", body, priority="HIGH")
mb.send(
    "AGENT_A",
    "D-M2-QUERY-POST-OOC architecture-drift note",
    "D-owned dir/post retemplated to UG901 1R BRAM. Isolated OOC only. "
    "Freeze tops unchanged. Not a second Native AI architecture.",
    priority="NORMAL",
)
print("notified A/B")
