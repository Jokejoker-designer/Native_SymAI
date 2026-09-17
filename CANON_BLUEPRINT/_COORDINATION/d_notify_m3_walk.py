from mailbox import Mailbox

mb = Mailbox(base_dir=".", agent_id="AGENT_D")
body = (
    "TASK: D-M3-QUERY-WALK-BIND\n"
    "STATUS: CANDIDATE. PROGRAM=NO.\n"
    "XSim: M3_QUERY_WALK_XSIM_PASS hop1=122 FAIL=0 finish=194855 ns.\n"
    "RTL: query_walk_bind.sv sha256 3972af8b…e746a3aa\n"
    "OOC isolated xc7a100t 100 MHz: route WNS=+1.899 WHS=+0.132 LUT=500 FF=629 RAMB36=4 RAMB18=1 DSP=0.\n"
    "DCP sha256 d9a85433…532386c0. Not FE256 engine. Freeze DCP untouched.\n"
    "query_meta[8:5]=hops [10]=reverse CANDIDATE. incomplete ≠ ASTRA.\n"
    "NOT_CLAIMED: M3_PASS M2_PASS FE256_PASS TIMING_PASS MIG_PASS BOARD_PASS FINAL_PASS"
)
mb.send("AGENT_B", "D-M3-QUERY-WALK-BIND CANDIDATE XSim+OOC", body, priority="HIGH")
mb.send(
    "AGENT_A",
    "D-M3-QUERY-WALK-BIND architecture-drift note",
    "Isolated QueryRecord→bounded_walk. incomplete is walker observable, not ASTRA. "
    "Freeze tops unchanged. Not a second Native AI architecture.",
    priority="NORMAL",
)
print("notified A/B")
