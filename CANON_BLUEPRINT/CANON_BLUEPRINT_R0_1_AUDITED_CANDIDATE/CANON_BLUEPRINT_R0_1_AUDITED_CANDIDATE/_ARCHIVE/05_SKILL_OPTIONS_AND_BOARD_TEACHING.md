\# 05 — SKILL OPTIONS AND BOARD TEACHING

&nbsp;

Package: NATIVE\_AI\_DEVELOPMENTAL\_HARDWARE\_R1

Status: Forward design candidate / research architecture

Target: Arty A7-100T / FPGA-native developmental learning

&nbsp;

\#\# 1\. Mục tiêu

&nbsp;

Tài liệu này thiết kế lớp nối giữa primitive capability → learned reusable skill → task behavior, cùng cơ chế dạy trực tiếp trên board bằng button reward/penalty, UART teacher, demonstration và bounded autonomous exploration.

&nbsp;

Nguyên tắc khóa:

&nbsp;

\> Hardware được đúc sẵn primitive và capability; cách phối hợp primitive thành skill phải được học hoặc demonstrated, không viết riêng một FSM cho mỗi semantic task.

&nbsp;

\#\# 2\. Primitive khác Skill

&nbsp;

Primitive là khả năng nền tảng đã có trong substrate:

GPIO\_WRITE, GPIO\_READ, UART\_TX\_BYTE, COMPARE, PACK, UNPACK, MEM\_READ, MEM\_WRITE...

&nbsp;

Skill là behavior tái sử dụng:

SET\_STATUS\_INDICATOR, DISPLAY\_DECIMAL, SEND\_WORD\_OVER\_UART, CHECK\_AND\_REPORT\_SENSOR.

&nbsp;

Task có thể ghép nhiều skill:

READ\_SENSOR → COMPARE\_THRESHOLD → SET\_STATUS\_INDICATOR → SEND\_REPORT.

&nbsp;

\#\# 3\. Không hard-code semantic task vào RTL

&nbsp;

Không làm:

if goal \== HELLO: send H,E,L,L,O

if incomplete: SEARCH

if success: LED3=1

&nbsp;

Thay vào đó:

Goal → Q\* macro action → Skill Engine → SPEAR target selection nếu cần → Primitive Executor → observed effect → reward/ASTRA verification.

&nbsp;

\#\# 4\. Skill Descriptor

&nbsp;

SkillDescriptor {

  skill\_id

  version

  goal\_class

  semantic\_role\_id

  precondition\_mask

  capability\_class\_mask

  entry\_state\_signature

  max\_steps

  policy\_ref

  sequence\_ref

  termination\_schema

  expected\_effect\_schema

  mean\_cost

  mean\_steps

  success\_count

  failure\_count

  regression\_count

  execution\_confidence

  source

  status

  evidence\_generation

  crc

}

&nbsp;

execution\_confidence chỉ nói độ ổn định thi hành, không phải truth confidence.

&nbsp;

\#\# 5\. Skill lifecycle

&nbsp;

CANDIDATE → LEARNED → VERIFIED → STABLE → COMPACTED.

&nbsp;

Nếu regression:

STABLE/COMPACTED → REOPENED.

&nbsp;

\#\# 6\. Option-style design

&nbsp;

Dùng mô hình gần Hierarchical RL Options nhưng tối giản cho FPGA:

I(s) \= initiation/precondition

π \= bounded primitive/sub-skill policy

β(s) \= termination

E \= expected effect schema

C \= expected cost

&nbsp;

Không dùng full Option-Critic trong R1 vì khó audit, tăng learnable degrees of freedom và làm RCA phức tạp.

&nbsp;

\#\# 7\. Skill graph

&nbsp;

Dùng DAG bounded:

primitive → micro skill → device skill → task skill.

&nbsp;

Ví dụ:

UART\_TX\_BYTE → SEND\_ASCII\_CHAR → SEND\_TOKEN\_SEQUENCE → REPORT\_STATUS.

&nbsp;

Hoặc:

GPIO\_WRITE → SET\_OUTPUT\_STATE → SET\_STATUS\_INDICATOR.

&nbsp;

Không cho cycle trong R1. Loader/promotion phải reject A→B→C→A.

&nbsp;

\#\# 8\. Self symbol, human alias, semantic role

&nbsp;

Mỗi capability/concept có ba lớp định danh:

SELF\_ID

HUMAN\_ALIAS

SEMANTIC\_ROLE

&nbsp;

Ví dụ:

SELF\_ID \= 0b00101101

HUMAN\_ALIAS \= LED3

SEMANTIC\_ROLE \= STATUS\_OUTPUT

&nbsp;

SELF\_ID có thể tồn tại từ substrate. HUMAN\_ALIAS được dạy sau. SEMANTIC\_ROLE phải học/verify từ relation và effect. Tên không tạo meaning; causal relation mới tạo grounding.

&nbsp;

\#\# 9\. Board Teaching Modes

&nbsp;

OBSERVE: chỉ đọc physical state, không learning nếu không có event.

&nbsp;

DEMO: human/teacher trực tiếp chỉ primitive/sequence. Record phải source=HUMAN\_DEMO. Không trộn với autonomous evidence.

&nbsp;

TRAIN: AI tự chọn action dưới exploration policy. Reward accepted, weights/skills có thể update.

&nbsp;

EXAM: exploration off, weights frozen, deterministic tie-break; cùng state/checkpoint phải tái lập cùng trajectory.

&nbsp;

\#\# 10\. Physical reward buttons

&nbsp;

Mapping đề xuất Arty A7:

BTN0 \= REWARD\_POSITIVE

BTN1 \= REWARD\_NEGATIVE

BTN2 \= DEMO/TEACH modifier

BTN3 \= CANCEL/RESERVED

&nbsp;

Path bắt buộc:

pin → 2FF synchronizer → debounce → one-shot → reward event → pending identity checker → commit.

&nbsp;

Một lần nhấn vật lý phải tạo đúng một accepted reward.

&nbsp;

\#\# 11\. UART teacher protocol

&nbsp;

TEACH\_FRAME {

  magic

  type

  session\_id

  txn\_id

  episode\_id

  generation

  payload\_len

  payload

  crc

}

&nbsp;

Type R1:

GOAL, REWARD, DEMO\_BEGIN, DEMO\_PRIMITIVE, DEMO\_END, ALIAS, QUERY\_STATE, CHECKPOINT.

&nbsp;

Teacher được phép cung cấp goal, scalar reward, explicit demo, human alias và task request.

&nbsp;

Teacher không được cung cấp trong autonomous benchmark: winner action, winner candidate, Q/SPEAR weight delta, proof override hoặc hidden label encoded bằng target ID.

&nbsp;

\#\# 12\. Dạy LED theo developmental flow

&nbsp;

Stage A — Capability awareness:

System biết CAP\_03 class=DIGITAL\_OUT, width=1, ops=READBACK/WRITE. Chưa cần biết tên LED.

&nbsp;

Stage B — Effect calibration:

WRITE(CAP\_03,0), WRITE(CAP\_03,1), READBACK.

AI ghi relation WRITE(1)→state1, WRITE(0)→state0.

&nbsp;

Stage C — Human alias:

Teacher gắn CAP\_03 alias=LED3. Đây chỉ là alias.

&nbsp;

Stage D — Goal grounding:

Goal INDICATE\_SUCCESS. AI thử candidate outputs/skills. Khi behavior phù hợp, user BTN+ hoặc UART reward. Qua repeated evidence, skill SET\_STATUS\_INDICATOR(success) có thể hình thành.

&nbsp;

\#\# 13\. Dạy HELLO trên UART

&nbsp;

Substrate đã biết ASCII và UART\_TX\_BYTE. Không dùng RL để rediscover 'H'=0x48.

&nbsp;

Hệ thống phải học symbol sequence, khi nào output sequence, chọn UART hay LCD và mục đích của sequence.

&nbsp;

Demo có thể là:

GOAL=GREET\_USER

DEMO symbols H,E,L,L,O

REWARD \+

&nbsp;

Skill candidate SEND\_GREETING chỉ được promote sau autonomous replay/verification.

&nbsp;

\#\# 14\. Không dạy từng bit

&nbsp;

Đúc cứng deterministic representation:

bit ↔ binary word ↔ signed/unsigned integer ↔ nibble ↔ hex ↔ decimal digit sequence ↔ ASCII byte.

&nbsp;

Học:

what representation to use, when to use it, symbol/sequence có meaning gì trong task context.

&nbsp;

\#\# 15\. Skill discovery R1

&nbsp;

Không bắt đầu bằng deep unsupervised skill discovery.

&nbsp;

R1 dùng:

Repeated successful trajectory fragment → fragment miner → Candidate Skill → replay dưới varied initial states → verify → promote.

&nbsp;

Một fragment chỉ đủ điều kiện nếu:

\- lặp lại;

\- termination/effect ổn định;

\- reuse giảm cost/action count hoặc tăng reliability;

\- không chứa forbidden action;

\- không phụ thuộc exact episode ID;

\- length \<= bound.

&nbsp;

Ví dụ READ→COMPARE→WRITE lặp lại với same effect class có thể thành candidate skill.

&nbsp;

\#\# 16\. Skill promotion

&nbsp;

Không promote sau một reward dương.

&nbsp;

Tối thiểu phải test:

\- nhiều initial states;

\- unseen capability instance nếu cùng class;

\- deterministic legality;

\- expected physical effect thật sự xảy ra;

\- reset/restore;

\- không hidden host winner;

\- không lệ thuộc candidate ordering cụ thể.

&nbsp;

ASTRA giữ quyền xác nhận effect/proof; Skill Engine không tự chứng nhận.

&nbsp;

\#\# 17\. Multi-step credit cho skill

&nbsp;

Skill có thể dài nhiều primitive:

READ\_SENSOR → COMPARE → WRITE\_LED → terminal reward \+64.

&nbsp;

Executed-action-only credit: primitive/sub-skill nào thực sự chạy mới có eligibility.

&nbsp;

Tách credit:

Q\* học macro decision.

SPEAR học target priority.

Skill layer học/reuse procedural composition.

&nbsp;

\#\# 18\. Skill complexity

&nbsp;

Metric đề xuất:

complexity\_score \= primitive\_count \+ branch\_count\*B \+ capability\_count\*C \+ normalized\_failure\_entropy \+ normalized\_recovery\_cost.

&nbsp;

Dùng để biểu diễn progress, curriculum, resource/cycle planning và regression analysis. Không dùng làm thước đo intelligence tổng quát.

&nbsp;

\#\# 19\. Skill memory BRAM / DDR

&nbsp;

BRAM giữ current skill, 16–32 hot descriptors, precondition/effect cache, current execution stack và sequence pointers. Budget đầu: 2–4 BRAM36.

&nbsp;

DDR giữ full skill library, historical versions, candidate fragments, verification evidence, compacted procedural memory và skill graph.

&nbsp;

\#\# 20\. Execution stack

&nbsp;

Skill gọi sub-skill cần bounded stack.

MAX\_SKILL\_DEPTH đề xuất: 4 hoặc 6\.

&nbsp;

Entry:

skill\_id, version, return\_step, remaining\_budget.

&nbsp;

Nếu vượt depth/budget: status SKILL\_BUDGET\_EXCEEDED. Không recursion không giới hạn.

&nbsp;

\#\# 21\. Interaction với Q\*

&nbsp;

Q\* không cần biết từng primitive chi tiết ở mọi bước. Q\* có thể chọn macro như REPORT\_RESULT; Skill Engine resolve SEND\_STATUS\_UART; SPEAR chọn UART target nếu có nhiều candidate; Primitive Executor phát bytes.

&nbsp;

Q\* giữ macro authority.

&nbsp;

\#\# 22\. Interaction với SPEAR

&nbsp;

SPEAR dùng khi có nhiều target hợp lệ. Ví dụ skill SET\_INDICATOR có CAP\_LED\_0..3. SPEAR rank; ASTRA/safety quyết định legal; score không phải truth.

&nbsp;

\#\# 23\. Interaction với NCG

&nbsp;

NCG lưu relation giữa CAPABILITY, ACTION, EFFECT, SKILL, GOAL, SYMBOL, PURPOSE.

&nbsp;

Ví dụ:

CAP\_03 \--CAN\_DO--\> WRITE

WRITE\_1 \--CAUSES--\> STATE\_1

STATE\_1 \--CONTRIBUTES\_TO--\> GOAL\_SUCCESS

SKILL\_7 \--USES--\> CAP\_03

SKILL\_7 \--ACHIEVES--\> STATUS\_VISIBLE

CAP\_03 \--NAMED\_AS--\> LED3

&nbsp;

Human alias không làm thay đổi causal knowledge cũ.

&nbsp;

\#\# 24\. Board teaching causal tests

&nbsp;

SKILL-01 Capability awareness: enumerate manifest đúng, không semantic winner encoded.

&nbsp;

SKILL-02 LED effect calibration: WRITE 0/1 → readback; record đúng effect mapping.

&nbsp;

SKILL-03 Alias attachment: thêm LED3 nhưng causal relation cũ giữ nguyên.

&nbsp;

SKILL-04 Reward grounding: teacher chỉ scalar reward; policy/skill sau train phải chọn behavior mà host không gửi winner.

&nbsp;

SKILL-05 Unseen index transfer: train LED1/LED2, exam LED3/LED4 cùng class; PASS nếu transfer dựa trên class/features chứ không exact ID.

&nbsp;

SKILL-06 Sequence composition: task cần \>=2–3 primitives. Ablate một primitive → task fail; tránh direct hard-coded shortcut.

&nbsp;

SKILL-07 Reset/restore: W0/skill0→A; train→skill1→B; reset→A; restore→B.

&nbsp;

SKILL-08 Host-zero-authority: UART hint winner ngoài protocol phải bị ignore/reject.

&nbsp;

\#\# 25\. Board teaching RTL risks

&nbsp;

Phải kiểm trước:

\- button bounce;

\- metastability;

\- reward đến sau pending clear;

\- duplicate UART frame;

\- stale txn/generation;

\- malformed CRC;

\- demo/autonomous provenance trộn nhau;

\- stale skill version;

\- sequence pointer overflow;

\- execution stack overflow;

\- termination đọc stale BRAM data;

\- same-cycle effect observation sai;

\- aborted skill vẫn nhận success reward;

\- candidate selected nhưng primitive chưa commit;

\- EXAM còn exploration;

\- reset không clear stack;

\- actuator glitch khi reset.

&nbsp;

\#\# 26\. Safe physical scope R1

&nbsp;

R1 giới hạn ở LED, RGB LED, buttons, switches, UART, LCD/display bridge nếu có, benign sensors và memory-local virtual actuators.

&nbsp;

Nếu sau này có motor/relay/high-power output:

learned intent → ASTRA legality → deterministic safety veto → physical commit.

&nbsp;

Safety không được learn away.

&nbsp;

\#\# 27\. Acceptance gate

&nbsp;

SKILL\_BOARD\_TEACHING\_R1\_PASS chỉ khi:

CAPABILITY\_INVENTORY \= PASS

PHYSICAL\_REWARD\_ONE\_SHOT \= PASS

UART\_REWARD\_IDENTITY \= PASS

DEMO\_PROVENANCE \= PASS

SKILL\_COMPOSITION\_CAUSAL \= PASS

UNSEEN\_INSTANCE\_TRANSFER \= PASS

RESET\_RESTORE \= PASS

ASTRA\_LEGALITY\_PRESERVED \= PASS

HOST\_SEMANTIC\_AUTHORITY \= 0

&nbsp;

\#\# 28\. Claim được phép

&nbsp;

Nếu gate đạt:

&nbsp;

"Native AI can acquire and reuse bounded procedural skills from primitive hardware capabilities through demonstrations and scalar rewards, while preserving causal provenance and deterministic safety/proof authority."

&nbsp;

Không claim human motor learning, consciousness, human-like language acquisition hoặc general autonomy ngoài bounded domain.

&nbsp;

\#\# 29\. Kết luận

&nbsp;

Chuỗi phải chứng minh:

I HAVE A CAPABILITY

→ I CAN ACT ON IT

→ I CAN OBSERVE THE EFFECT

→ I CAN RECEIVE REWARD/PENALTY

→ I CAN REUSE A SUCCESSFUL SEQUENCE

→ I CAN FORM A SKILL

→ I CAN TRANSFER THE SKILL

→ I CAN EXPLAIN ITS PURPOSE THROUGH PROVENANCE.

&nbsp;

Đây là cầu nối từ "phần cứng biết mình có gì" sang "hệ thống học cách dùng những gì nó có" mà không biến dự án thành tập hợp FSM viết tay.

&nbsp;