02 — MEMORY ARCHITECTURE: BRAM vs DDR
1. NGUYÊN TẮC
BRAM = hot, bounded, deterministic working state.
DDR = large, cold/warm, long-term evidence/episode/skill/checkpoint.
Không giữ raw history lớn trong BRAM.
2. TÀI NGUYÊN THAM CHIẾU ARTY A7-100T
XC7A100T: 63,400 LUT, 126,800 FF, 240 DSP48E1, 135 BRAM36 ≈ 4,860 Kbit ≈ 607.5 KiB. Board có DDR3 256 MiB-class. Đây là ceiling vật lý; full integration phải chừa margin cho MIG, routing, FIFO, reset/CDC.
3. HOT STATE NÊN Ở BRAM / DISTRIBUTED RAM
- current RSR / active goal / legal mask
- Q* weight bank A/B
- SPEAR weights + small uncertainty/counter stats
- active candidate set
- 16–32 step trajectory
- pending reward identity
- current skill descriptor
- ASTRA proof scratch / Top-K hot cache
- 32–64 recent failure prototypes
- compactor staging
- UART/FIFO buffers
- small GEMINI token/symbol buffer
Q*/SPEAR matrices rất nhỏ; thường chỉ cần distributed RAM hoặc 1–2 BRAM tổng.
4. LONG-TERM NÊN Ở DDR
- ASTRA evidence directory/postings/facts/provenance
- knowledge packs
- full skill library
- episodic journal
- raw failure journal
- compacted failure prototypes
- procedural memory
- lexicon/dictionaries lớn
- policy checkpoints A/B
- experiment snapshots
- cold proof/candidate data
5. BRAM ENGINEERING BUDGET CANDIDATE
ASTRA proof/retrieval hot cache: 18–28 BRAM36
Working memory/RSR/candidate: 4–8
Trajectory/pending/return: 2–4
Skill hot cache: 2–4
Failure hot cache/compactor: 2–4
GEMINI token buffers: 4–8
UART/protocol/FIFO: 2–4
MIG user-side buffering: 8–16
Q*/SPEAR weights/stats: 0–2
Preferred spare/routing relief: >=20
Không coi bảng này là utilization claim. Chỉ OOC/full synth mới chốt.
6. DDR MAP V2 COMPACT CANDIDATE — KHÔNG PHẢI LỆNH MIGRATE V1
0x0000_0000–0x003F_FFFF   4 MiB   system manifests + dual checkpoint headers
0x0040_0000–0x00FF_FFFF  12 MiB   lexicon/codebook/skill metadata
0x0100_0000–0x04FF_FFFF  64 MiB   packed evidence directory + postings
0x0500_0000–0x08FF_FFFF  64 MiB   facts + provenance + semantic packs
0x0900_0000–0x0BFF_FFFF  48 MiB   episodic + raw failure journal
0x0C00_0000–0x0CFF_FFFF  16 MiB   compacted skill/failure/procedural memory
0x0D00_0000–0x0DFF_FFFF  16 MiB   policy checkpoints + experiment scratch
0x0E00_0000–0x0FFF_FFFF  32 MiB   spare / legacy compatibility / growth
Total = 256 MiB.
7. VÌ SAO V2 NÊN EVALUATE PACKED/PAGED POSTINGS
V1 fixed-slot posting reservation cho deterministic addressing nhưng tốn address space. V2 nên benchmark packed/paged postings với invariant:
TOTAL_EVIDENCE tăng nhưng DDR bytes/query, candidate count và proof work vẫn bounded.
Không đổi V1 address ABI trước migration gate riêng.
8. CHECKPOINT ATOMICITY
Dùng slot A/B:
write inactive slot → CRC/SHA → verify → atomically flip active generation pointer.
Không overwrite active checkpoint in place.
Checkpoint tối thiểu:
- Q*/SPEAR weights
- policy versions
- skill-table version
- failure prototype table
- compaction counters
- allocator state
- capability manifest version
- corpus epoch
9. SHARED ARITHMETIC
Q* eval, SPEAR rank, n-step return và weight update không cần chạy đồng thời. Time-multiplex shared sequential MAC để tránh DSP/LUT explosion.
PHASE_Q_EVAL → PHASE_SPEAR → PHASE_EXEC → PHASE_RETURN → PHASE_UPDATE.