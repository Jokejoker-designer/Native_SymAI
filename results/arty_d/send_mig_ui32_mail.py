import sys
from pathlib import Path

sys.path.insert(0, str(Path(r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\_COORDINATION")))
from mailbox import Mailbox

base = r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\_COORDINATION"
mb = Mailbox(base, "AGENT_D")

c = """D-06 MIG UI32 bind. STATUS: CANDIDATE. PROGRAM=NO.

mig_ui32 maps C/pack 32-bit mem_* onto generated native MIG (APP_W=128 FACT):
- byte addr[3:2] = lane; app_addr[3:0]=0 (16-byte beat)
- write uses DM mask (no RMW of sibling lanes)
- completion = dest readback of that lane, not app_rdy / FIFO-empty
- wr_outstanding decrements only after dest match

Evidence: MIG_UI32_XSIM_PASS (XSim model, not silicon). OOC xc7a100t LUT=213 FF=117 WNS=+5.781 @100 MHz (unplaced; real ui_clk ~83 MHz).

FEM t2_ready still goes through fem_t2_ce today; next is to point fem_media_bridge at mig_ui32 app_* instead of the 128b shadow array.

CLK: generated mig0 wants sys_clk_i=166.666 MHz + clk_ref_i=200 MHz. Arty osc is 100 MHz. clk_arty_mig MMCM: 100 -> 166.667/200. Do not feed CLK100MHZ into sys_clk_i.

NOT_CLAIMED: MIG_PASS, FEM_PERSIST_PASS, BOARD_PASS."""

b = """D-06 MIG UI32 observables. STATUS: CANDIDATE.

New fabric events (not ASTRA codes):
- mem_resp_err = dest lane mismatch or injected tear
- wr_outstanding on mig_ui32 is dest-domain outstanding (not MIG cmd FIFO)
- cmd_fifo_empty remains a PROXY; do not map to durable/OK
- init_calib_complete gates mem_cmd_ready; before calib there is no persist path

No BOARD_PASS."""

a = """D-06 memory/clock conflict note. STATUS: CANDIDATE.

NO ID-profile conflict.

CLOCK: generated mig0 InputClkFreq=166.666 (CLKIN_PERIOD=6000). Arty A7-100T oscillator is 100 MHz. D added clk_arty_mig (MMCM 100->166.667 sys + 200 ref). Feeding 100 MHz into sys_clk_i is a false path.

ADDR: pack_loader mem_addr is a 28-bit byte address; mig_ui32 aligns to 16-byte beats. Page pointer 0 remains reserved null (directory), unrelated to DDR beat 0.

MIG still not instantiated in the fabric top (path/license/calib). Not MIG_PASS."""

print("C", mb.send("AGENT_C", "D-06 mig_ui32 dest-complete native UI bind", c))
print("B", mb.send("AGENT_B", "D-06 mig_ui32 dest-outstanding vs FIFO proxy", b))
print("A", mb.send("AGENT_A", "D-06 Arty 100 MHz vs MIG 166.666 sys_clk", a))
