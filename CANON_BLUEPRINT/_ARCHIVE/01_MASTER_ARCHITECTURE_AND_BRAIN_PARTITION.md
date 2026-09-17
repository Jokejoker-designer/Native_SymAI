01 — MASTER ARCHITECTURE AND BRAIN PARTITION
1. MỤC TIÊU KIẾN TRÚC
Native AI R1 không được xây như một LLM nhỏ. Nó là bounded developmental controller chạy native trên FPGA: có primitive/capability nền tảng, học cách phối hợp chúng thành skill, học strategy từ reward thực, lưu history failure/skill, nhưng truth/proof authority vẫn tách khỏi learned preference.
2. PHÂN VÙNG BỘ NÃO
ZONE 0 — NATIVE SUBSTRATE / REFLEX
- capability inventory
- primitive opcode
- type/width/range
- arithmetic/logic/codecs
- legality/safety veto
- deterministic, không học
ZONE 1 — PHYSICAL / PRIMITIVE EXECUTOR
- GPIO, LED, button, UART, memory, LCD bridge, SPI/I2C nếu có
- commit action và quan sát effect thật
ZONE 2 — WORKING MIND
- current Reasoning State Record
- active goal
- legal mask
- candidate set
- pending identity
- 16–32 step trajectory
- current proof scratch
- recent failure prototypes
- active skill descriptor
ZONE 3A — Q* MACRO PLANNER
- quyết định “bước lớn tiếp theo là gì?”
- SEARCH, READ, FOLLOW, COMPARE, SUBMIT, OUTPUT, STOP...
- Double Linear-Q + bounded best-first
ZONE 3B — SPEAR MICRO RANKER
- quyết định “trong action đó, target/candidate nào đáng chọn trước?”
- linear contextual ranker + fixed-point SGD
ZONE 4 — SKILL / OPTION ENGINE
- composition primitive thành skill kéo dài nhiều bước
- precondition, termination, expected effect, cost, version
ZONE 5 — ASTRA
- legality
- proof
- conflict
- completeness
- status
- knowledge promotion
ZONE 6 — GEMINI
- symbol/language proposal
- expression/output wording
- không override ASTRA
- không lái actuator trực tiếp
PARALLEL MEMORY PLANE
Episode → Failure Experience Memory → resolve → compact → procedural memory.
3. BẨM SINH VS HỌC ĐƯỢC
ĐÚC CỨNG:
- hardware inventory format
- primitive vocabulary
- bitwise logic
- add/sub/compare/shift/mask
- bit/byte/nibble packing
- binary↔integer
- nibble↔HEX character
- integer↔decimal digit sequence
- ASCII encode/decode như representation ABI
- CRC/checksum
- physical legality/safety
- ASTRA proof/status laws
- identity/version/checkpoint contract
HỌC:
- LED3 mang ý nghĩa gì
- output nào hợp với goal
- chuỗi primitive nào tạo thành skill
- khi nào search/read/follow/stop
- candidate nào ưu tiên
- expected utility/cost
- semantic association
- failure pattern/recovery
- transfer giữa capability cùng class
Nguyên tắc: hard-code physics/types/codecs/legality; learn semantics/goals/strategy/utility.
4. DATAFLOW CHÍNH
goal/input
→ capability + current state
→ ASTRA legality mask
→ Q* chooses macro action
→ Skill Engine expands action / candidate set
→ SPEAR ranks target/candidate
→ Primitive Executor commits
→ physical effect
→ ASTRA observes/verifies effect
→ new state
→ continue or terminal
Learning loop:
executed trajectory + terminal/local reward
→ split credit
→ Q* update only executed macro action
→ SPEAR update only selected candidate
→ Failure Experience Memory
→ resolve/compact/reopen on regression.
5. AUTHORITY BUS
Every active record should carry:
session_id, txn_id, generation, episode_id, step_id, q_policy_version, spear_policy_version, capability_manifest_version, skill_version, corpus_epoch.
Stale/malformed/mismatched identity must never update learned state.
6. EXAMPLE LED
System knows CAP_LED_3 is DIGITAL_OUT, width=1, ops=WRITE/READBACK/TOGGLE. It does NOT know LED3 means SUCCESS.
The latter must come from teaching/experience and later be reused as learned semantics or skill mapping.
7. EXAMPLE HELLO
System may be born with UART_TX_BYTE and ASCII codec. It does not need to rediscover that H=0x48 by reinforcement learning. It must learn/receive the symbol sequence, choose the output device and learn when/how to use the primitive sequence.
8. CORE RULE
Do not create one new RTL FSM per semantic task.
Build fixed primitive vocabulary + typed capability descriptors + learned skill composition + learned macro/micro policy + deterministic truth/safety boundary.