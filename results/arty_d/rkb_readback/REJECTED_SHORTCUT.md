# REJECTED_SHORTCUT — first COMMIT→T1 RTL

**Status:** REJECTED. Not the locked candidate. PROGRAM=NO.

Files:

- `pack_t1_install.sv`
- first-cut `runtime_t1.sv` / `pack_runtime_dut.sv` (query T1 after dest-copy, no UNSET gate)

Why they fail the owner lock:

```text
T1 became the query source of truth after a one-shot dest copy.
Query did not fail-closed on active_generation=UNSET.
saw_wr / ack_seen stuck → second COMMIT cannot republish root.
No flush/rebuild-from-T2 path (CT1-05).
```

That is close to **host-equivalent T1 SoT** even if the bytes came from dest once.

Locked repair: `pack_runtime_dut.sv` + `dest_root_cache.sv` (dest/T2 SoT, generation publish, T1 cache refill only). Gate: CT1-01..05.
