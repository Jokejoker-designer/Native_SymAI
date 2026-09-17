"""Declared 256x256 vs live payload vs likely BRAM compression. PROGRAM=NO."""
from pathlib import Path

mem = Path(
    r"D:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\rtl\native_ai\fe256\fe256_store.mem"
)
words = []
for line in mem.read_text(encoding="ascii").splitlines():
    s = line.strip()
    if not s:
        continue
    words.append(int(s, 16))

n = len(words)
print(f"FACT n_lines={n} declared_depth=256 declared_width=256")
print(f"FACT bits_declared={256*256} bits_live_words={n*256}")

# RTL read map from fe256_query_path.sv
used = set()
for lo, hi in (
    (32, 63),
    (64, 95),
    (96, 127),
    (128, 159),
    (160, 191),
    (192, 223),
    (224, 239),
    (240, 247),
    (248, 251),
    (252, 252),
    (253, 253),
    (254, 254),
    (255, 255),
):
    for b in range(lo, hi + 1):
        used.add(b)

unread = sorted(set(range(256)) - used)
print(f"FACT rtl_unread_bits={unread} count={len(unread)}  # edge_id[31:0]")

const0 = []
const1 = []
varying = []
for b in range(256):
    vals = {(w >> b) & 1 for w in words}
    if vals == {0}:
        const0.append(b)
    elif vals == {1}:
        const1.append(b)
    else:
        varying.append(b)

print(f"FACT bits_const0={len(const0)} bits_const1={len(const1)} bits_varying={len(varying)}")
print(f"FACT varying_and_read={len([b for b in varying if b in used])}")
print(f"FACT varying_unread={len([b for b in varying if b not in used])}")
print(f"INFERENCE one_ramb36_budget_bits=36864 (36Kb). varying*n={len(varying)*n}")
print(f"INFERENCE if_only_varying_packed={len(varying)} width at depth {n}")

fields = {
    "edge_id": (0, 31),
    "sub": (32, 63),
    "obj": (64, 95),
    "prov": (96, 127),
    "proof": (128, 159),
    "vlo": (160, 191),
    "vhi": (192, 223),
    "rel": (224, 239),
    "ctx": (240, 247),
    "kind": (248, 251),
    "ver": (252, 252),
    "live_a": (253, 253),
    "live_b": (254, 254),
    "provok_b": (255, 255),
}
print("FIELD unique_values / bits_varying")
for name, (lo, hi) in fields.items():
    uniq = set()
    nv = 0
    for w in words:
        v = (w >> lo) & ((1 << (hi - lo + 1)) - 1)
        uniq.add(v)
    for b in range(lo, hi + 1):
        vals = {(w >> b) & 1 for w in words}
        if len(vals) > 1:
            nv += 1
    print(f"  {name:8s} unique={len(uniq):4d} bits_varying={nv:2d} rtl_read={lo in used or hi in used}")
