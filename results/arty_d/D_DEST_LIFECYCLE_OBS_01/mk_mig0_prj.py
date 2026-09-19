from pathlib import Path

rtl = Path(r"D:\FPGA\miggen\p\mig0.gen\sources_1\ip\mig0\mig0\user_design\rtl")
out = Path(r"D:\FPGA\arty_d\D_DEST_LIFECYCLE_OBS_01\mig0_rtl.f")
files = sorted(p for p in rtl.rglob("*.v") if p.name != "mig0_mig.v")
# mig0.v once; mig0_mig_sim.v once
out.write_text("\n".join(str(p) for p in files) + "\n", encoding="utf-8")
names = [p.name for p in files]
print("count", len(files))
print("has mig0.v", names.count("mig0.v"))
print("has mig0_mig.v", names.count("mig0_mig.v"))
print("has mig0_mig_sim.v", names.count("mig0_mig_sim.v"))
