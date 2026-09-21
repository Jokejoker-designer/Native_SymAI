# ASK AGENT_D — published_root=0 vs dest[1024] lookup

From: OWNER / CURSOR_OWNER (side watch, chat beside 31dc87bc)
Date: 2026-09-21T11:37+07
LANGUAGE=EN
PROGRAM=NO. PACK_ABI_24_24_PASS=NO. RUNTIME_KNOWLEDGE_BINDING_8_8_PASS=NOT_RUN.
Do not stamp. Do not invent. Measure or say UNKNOWN.

## Already FACT (do not re-argue)

- RKB02_OBS.json: p1/p2 `pub=0000000`; poison dest[0] hit=1 dest_rd=1; poison dest[1024] hit=0 dest_rd=1; `$finish` 2775 ns.
- D V1 20260921T043300Z H4: `published_root==0` means lookup dest[0] = CONTRADICTED. Probe is not SoT. Why probe stays 0 = UNKNOWN.
- `tb_rkb02_reloc.sv` dc1/rkb02 do not AND `root_valid`.
- `pack_runtime_dut` query: `!root_valid` → miss, no dest_rd. Lookup uses `dest_root_cache` `app_addr=pub_root`.

## Questions — answer with a waveform / $display, not inference

Q1. At the **dest_rd_pulse of the query after poison dest[0]**, what are:
    `u_cache.app_addr`, `u_cache.pub_root`, `u_cache.pub_v`/`root_valid`, `u_dest` widx?
    Print them on that cycle. Do not use the `pub2=` sample taken at `load_mem` return.

Q2. After P2 COMMIT (before poison), is `published_root==0` because
    (A) SLOT0 base is actually the published beat, or
    (B) the TB sample is stale/wrong, or
    (C) `pending_root`/`have_wr` never latched `SLOT1_BASE=28'h010_0000`, or
    (D) UNKNOWN until Q1 is measured?
    Pick one. If A, explain poison dest[1024] miss.

Q3. What is `root_valid` at the two TB `pub1`/`pub2` sample points?

Q4. Does any query path walk `u_dest.dest[]` combinationally, or is dest-read of one published beat the only path? Cite the module/line if a second path exists.

Q5. Is `dest_root_cache.published_root` an M1/M3/M4 ASTRA object, or only the CT1 dest-beat pointer? One sentence.

Please reply mailbox OWNER + V1. Do not self-stamp 8/8. PROGRAM=NO.
