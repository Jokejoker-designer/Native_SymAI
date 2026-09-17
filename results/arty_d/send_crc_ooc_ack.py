import sys
from pathlib import Path

sys.path.insert(0, str(Path(r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\_COORDINATION")))
from mailbox import Mailbox

base = r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001\CANON_BLUEPRINT\_COORDINATION"
mb = Mailbox(base, "AGENT_D")

body = """ACK CRC pipeline 091830. STATUS: CANDIDATE. PROGRAM=NO.

Consumed PACKAGE fem_lifecycle.v sha256 45b9b93073e3e08a2525a3fc1a96573d750bedcd26570cebefba5fa9514779ed (matches worktree).

FEM_MEDIA_SYS_XSIM_PASS still holds after the CRC register (dest-complete + fifo-empty guard).

OOC fem_media_sys xc7a100t (the number that counts for the bind):
  BEFORE: LUT=885 FF=1257 WNS=-1.213 TNS=-11.461  crit rd_w0->rec_crc_valid->txn_step CE
  AFTER:  LUT=875 FF=1289 DSP=0 BRAM=0 WNS=+3.754 TNS=0.000 @100 MHz
  crit: u_fem/key_reg -> crc_p_r (6 LUT), same family as your fem_lifecycle-only +3.669.

Pre-place OOC. Not TIMING_PASS. OOC != integrated (keep-hierarchy top still has Q* WNS=-10.174).

MIG app_* still unbound. Next on D: point fem_media_bridge/pack_loader at mig_ui32 app_*.

NOT_CLAIMED: FEM_PERSIST_PASS, MIG_PASS, BOARD_PASS, TIMING_PASS."""

print(mb.send("AGENT_C", "ACK CRC pipeline: fem_media_sys OOC WNS +3.754", body))
print(mb.send("AGENT_B", "D OOC fem_media_sys WNS +3.754 after C CRC pipe (not status)", "CANDIDATE. integrity_fault contract unchanged. fem_media_sys OOC WNS +3.754 @100 MHz post-synth. Not BOARD_PASS."))
print(mb.send("AGENT_A", "D OOC fem_media_sys WNS recovered after C CRC pipe", "CANDIDATE. No architecture conflict. fem_media_sys OOC WNS -1.213 -> +3.754 after C registered CRC16. Integrated Q* path still WNS=-10.174. MIG unbound. Not TIMING_PASS."))

for item in mb.check_inbox():
    sub = str((item.get("message") or {}).get("subject") or "")
    if "CRC pipelined" in sub or "CRC pipeline" in sub or "fem files republished" in sub:
        mb.mark_read(item["file"])
        print("read", sub)
