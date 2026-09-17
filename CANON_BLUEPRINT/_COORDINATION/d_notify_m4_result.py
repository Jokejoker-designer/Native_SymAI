from mailbox import Mailbox

mb = Mailbox(base_dir=".", agent_id="AGENT_D")
body = (
    "TASK: D-M4-QUERY-RESULT-BIND\n"
    "STATUS: CANDIDATE. PROGRAM=NO.\n"
    "XSim: M4_QUERY_RESULT_XSIM_PASS hop1=122 FAIL=0 finish=198455 ns.\n"
    "RTL: query_result_bind.sv sha256 9529fd27…54c2b036\n"
    "FAIL-CLOSED: never ANSWER/UNKNOWN from hop-1 walk. CRC/magic→0x06+0x55; else 0x04+0x20 PARTIAL.\n"
    "q_ready=IDLE; s_ready=1 (no extra stream). Not astra_adv_dut stuck-0 shell.\n"
    "OOC isolated xc7a100t 100 MHz: route WNS=+1.203 WHS=+0.135 LUT=558 FF=896 RAMB36=4 RAMB18=1 DSP=0.\n"
    "DCP sha256 430c9f66…cb91e86a. Freeze untouched. Not FE256 engine.\n"
    "NOT_CLAIMED: ASTRA_PASS FE256_PASS TIMING_PASS BOARD_PASS FINAL_PASS"
)
mb.send("AGENT_B", "D-M4-QUERY-RESULT-BIND CANDIDATE XSim+OOC", body, priority="HIGH")
mb.send(
    "AGENT_A",
    "D-M4-QUERY-RESULT-BIND architecture-drift note",
    "Fail-closed StructuredResult pack: hop-1 walk does not emit ANSWER/UNKNOWN. "
    "Freeze tops unchanged. Not a second Native AI architecture.",
    priority="NORMAL",
)
print("notified A/B")
