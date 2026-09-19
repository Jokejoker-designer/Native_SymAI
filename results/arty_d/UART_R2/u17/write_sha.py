from pathlib import Path
import hashlib

root = Path(r"D:\FPGA")
files = [
    r"arty_d/UART_R2/u11/uart_rx_word.sv",
    r"arty_d/UART_R2/u14/uart_tx_word.sv",
    r"arty_d/UART_R2/u17/pack_debug_clear.sv",
    r"arty_d/UART_R2/u17/arty_a7_r2_top_m4_mig_candidate.sv",
    r"arty_d/UART_R2/u17/pack_uart_dualclk_harness.sv",
    r"arty_d/UART_R2/u17/u17_campaign.py",
    r"NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT/rtl/native_ai/board/arty_a7_r2_top_m4_mig_candidate.sv",
    r"NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT/rtl/native_ai/board/word_cdc32.sv",
    r"NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT/rtl/native_ai/loader/pack_loader.sv",
    r"NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001/CANON_BLUEPRINT/verification/pack_abi24/pack_abi24_gold.py",
    r"arty_d/UART_R2/build_u16/uart_r2_u16_candidate.bit",
]
out = Path(r"D:\FPGA\arty_d\UART_R2\results\PACK24_U17\SHA256SUMS.txt")
lines = []
for f in files:
    p = root / f
    h = hashlib.sha256(p.read_bytes()).hexdigest()
    lines.append(f"{h}  {f}")
out.write_text("\n".join(lines) + "\n", encoding="utf-8")
print("\n".join(lines))
