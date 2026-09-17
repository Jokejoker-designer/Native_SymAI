from pathlib import Path

p = Path(
    r"d:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\verification\fe256\out\fe256_gold_results.hex"
)
q = Path(
    r"d:\FPGA\NATIVE_AI_DEVELOPMENTAL_HARDWARE_R1_PACKAGE_20260914-20260914T045403Z-1-001"
    r"\CANON_BLUEPRINT\verification\fe256\out\fe256_queries.hex"
)
lines = p.read_text().splitlines()
qlines = q.read_text().splitlines()


def u32(b, o):
    return int.from_bytes(b[o : o + 4], "little")


def u16(b, o):
    return int.from_bytes(b[o : o + 2], "little")


def show(i, label):
    b = bytes.fromhex(lines[i].strip())
    qb = bytes.fromhex(qlines[i].strip())
    print(f"--- {label} idx={i}")
    print(
        f"  st={b[3]:02x} rc={b[4]:02x} ak={b[5]:02x} cm={b[6]:02x} flags={b[7]:02x}"
    )
    print(
        f"  txn={u32(b, 8):08x} gen={u16(b, 12):04x} ns={u16(b, 14):04x}"
    )
    print(
        f"  answer_ref={u32(b, 16):08x} vlo={u32(b, 20):08x} vhi={u32(b, 24):08x}"
    )
    print(
        f"  proof={u32(b, 28):08x} prov={u32(b, 32):08x} ctx={u32(b, 36):08x} conf={u32(b, 40):08x}"
    )
    print(f"  acnt={b[44]:02x} plen={b[45]:02x} crc={b[47]:02x}{b[46]:02x}")
    print(f"  q_txn={u32(qb, 4):08x} q_bytes4_11={qb[4:12].hex()}")
    print(f"  q[12:20]={qb[12:20].hex()}")


show(0, "first FAIL gold ANSWER")
show(200, "PASS gold INCOMPLETE")
show(201, "PASS gold INCOMPLETE")
show(32, "sample mid")

nz = z = 0
ans_zero_proof = []
for i, line in enumerate(lines):
    b = bytes.fromhex(line.strip())
    if b[3] == 1:
        pr = u32(b, 28)
        if pr:
            nz += 1
        else:
            z += 1
            ans_zero_proof.append(i)
print("ANSWER proof_ref nonzero", nz, "zero", z)
print("ANSWER zero-proof idx sample", ans_zero_proof[:8])
