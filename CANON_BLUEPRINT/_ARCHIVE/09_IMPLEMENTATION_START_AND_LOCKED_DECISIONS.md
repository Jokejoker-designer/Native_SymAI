\# 09\_IMPLEMENTATION\_START\_AND\_LOCKED\_DECISIONS

&nbsp;

\*\*Project:\*\* NATIVE\_AI\_DEVELOPMENTAL\_HARDWARE\_R1&nbsp;&nbsp;

\*\*Target:\*\* Arty A7-100T / XC7A100T-CSG324-1&nbsp;&nbsp;

\*\*Status:\*\* Forward implementation contract. Không thay đổi R2/R3 frozen evidence.

&nbsp;

\---

&nbsp;

\# 1\. Mục tiêu cuối của lane này

&nbsp;

Xây dựng một bounded FPGA-native developmental controller có thể:

&nbsp;

\`\`\`text

biết capability/primitive nền tảng mình đang có

→ quan sát state/effect thật

→ thử hành động

→ nhận reward/penalty thật

→ ghi episode/failure

→ học policy/skill

→ tạo liên kết khái niệm

→ tránh lặp lại failure đã biết

→ compact kinh nghiệm ổn định

→ giải thích state / action / purpose bằng provenance

\`\`\`

&nbsp;

Không yêu cầu AGI, consciousness, human-level reasoning hoặc large-language-model behavior.

&nbsp;

\---

&nbsp;

\# 2\. Locked architecture

&nbsp;

\`\`\`text

PHYSICAL WORLD / BOARD

        ↓

NATIVE SUBSTRATE ISA

        ↓

OBSERVATION \+ EFFECT BUS

        ↓

NCG — NATIVE COGNITIVE GRAPH

   ↙        ↓         ↘

FEM       Q\* / SPEAR   SKILL MEMORY

   \\        ↓          /

    \\---- WORKING MIND

            ↓

          ASTRA

            ↓

          GEMINI

\`\`\`

&nbsp;

Authority:

&nbsp;

\`\`\`text

Substrate \= what can physically be done

NCG       \= structured learned relations / concepts / purpose graph

Q\*        \= macro action preference

SPEAR     \= micro target/candidate priority

Skill     \= reusable procedural behavior

FEM       \= failure/success experience lifecycle

ASTRA     \= legality/proof/truth/status/promotion

GEMINI    \= expression/language proposal

Host      \= transport / explicit teaching / scalar reward / logging

\`\`\`

&nbsp;

Host semantic authority \= 0\.

&nbsp;

\---

&nbsp;

\# 3\. NCG — Native Cognitive Graph

&nbsp;

\#\# 3.1 Why NCG exists

&nbsp;

NCG là lớp nối giữa bit-level capability và khái niệm cao hơn.

&nbsp;

Mục tiêu không phải tạo một neural network giả lập bằng graph. Mục tiêu là một sparse typed graph có provenance để hệ thống có thể nói:

&nbsp;

\`\`\`text

Tôi đang quan sát cái gì?

Tôi có thể làm gì với nó?

Tôi đã thấy hành động nào gây hiệu ứng nào?

Cái này liên hệ với mục tiêu nào?

Tôi đã từng thất bại ở đâu?

Tên nội bộ của nó là gì?

Tên con người gán cho nó là gì?

Tại sao tôi chọn hành động này?

\`\`\`

&nbsp;

\#\# 3.2 Node types

&nbsp;

R1 dùng enum cố định:

&nbsp;

\`\`\`text

PHYSICAL\_RESOURCE

CAPABILITY

SENSOR

STATE

ENTITY

PROPERTY

ACTION

EFFECT

CONCEPT

SYMBOL

GOAL

SKILL

FAILURE

PROOF\_REF

HUMAN\_ALIAS

\`\`\`

&nbsp;

Không cần tất cả node type ngay M1. Khởi đầu chỉ cần:

&nbsp;

\`\`\`text

CAPABILITY

STATE

ACTION

EFFECT

SYMBOL

GOAL

FAILURE

\`\`\`

&nbsp;

sau đó mở rộng.

&nbsp;

\#\# 3.3 Edge types

&nbsp;

R1 core relation set:

&nbsp;

\`\`\`text

IS\_A

PART\_OF

HAS\_STATE

OBSERVED\_BY

CAN\_DO

ACTS\_ON

CAUSES

CORRELATES\_WITH

CHANGES

SUPPORTS

CONTRADICTS

COMPOSES

ACHIEVES

FAILED\_AT

AVOID\_UNDER

RECOVERED\_BY

NAMED\_AS

INSTANCE\_OF

\`\`\`

&nbsp;

Rất quan trọng:

&nbsp;

\`\`\`text

CORRELATES\_WITH \!= CAUSES

NAMED\_AS          \!= IS\_A

ACHIEVES          \!= PROVES

FAILED\_AT         \!= ILLEGAL

\`\`\`

&nbsp;

\#\# 3.4 Internal identity and self naming

&nbsp;

Mỗi concept/resource có:

&nbsp;

\`\`\`text

SELF\_ID

HUMAN\_ALIAS optional

SEMANTIC\_ROLE learned

\`\`\`

&nbsp;

Ví dụ:

&nbsp;

\`\`\`text

SELF\_ID       \= 0b001011010101

HUMAN\_ALIAS   \= "LED3"

SEMANTIC\_ROLE \= STATUS\_OUTPUT

\`\`\`

&nbsp;

SELF\_ID không đổi khi alias thay đổi.

&nbsp;

Nếu AI gặp capability chưa có tên:

&nbsp;

\`\`\`text

CAP\_X

→ allocate SELF\_ID

→ observe state/effect

→ build relations

→ later attach human alias

\`\`\`

&nbsp;

Như vậy knowledge tồn tại trước language label.

&nbsp;

\#\# 3.5 Node record candidate

&nbsp;

Packed fixed-width candidate:

&nbsp;

\`\`\`text

NodeRecord {

  node\_id         32b

  generation       8b

  node\_type         8b

  flags             8b

  class\_id         16b

  capability\_id    16b

  state\_bucket     16b

  first\_edge\_ptr   32b

  edge\_count       16b

  alias\_ptr        32b

  provenance\_ptr   32b

  version          16b

}

\`\`\`

&nbsp;

Khoảng 28–32 byte/node là hợp lý cho DDR.

&nbsp;

\#\# 3.6 Edge record candidate

&nbsp;

\`\`\`text

EdgeRecord {

  src\_id           32b

  dst\_id           32b

  relation\_type     8b

  flags             8b

  context\_class    16b

  support\_count    16b

  oppose\_count     16b

  utility\_signed   16b

  first\_seen       32b

  last\_seen        32b

  evidence\_ptr     32b

  next\_edge\_ptr    32b

}

\`\`\`

&nbsp;

Khoảng 36–40 byte/edge tùy packing.

&nbsp;

Counters là experience/support metadata, không tự động là ASTRA truth confidence.

&nbsp;

\#\# 3.7 BRAM vs DDR for NCG

&nbsp;

BRAM hot cache:

&nbsp;

\`\`\`text

64 hot nodes

128–256 hot edges

active goal neighborhood

active failure neighborhood

alias/self-id cache

traversal queue

\`\`\`

&nbsp;

DDR:

&nbsp;

\`\`\`text

full node table

full edge pool

adjacency pages

alias dictionary

provenance lists

historical relation evidence

compacted concept summaries

\`\`\`

&nbsp;

R1 không cần graph toàn bộ nằm BRAM.

&nbsp;

\#\# 3.8 NCG datapath

&nbsp;

Observation path:

&nbsp;

\`\`\`text

physical event

→ typed ObservationRecord

→ exact object/capability resolve

→ lookup/create node

→ lookup edge key

→ update relation counters/evidence

→ mark candidate relation

→ ASTRA verification when truth-relevant

\`\`\`

&nbsp;

Action/effect path:

&nbsp;

\`\`\`text

Q\*/Skill chooses action

→ primitive commit

→ physical readback/effect

→ EffectRecord

→ NCG updates ACTION \--CAUSES/CHANGES--\> EFFECT

→ FEM updates if penalized

\`\`\`

&nbsp;

Goal path:

&nbsp;

\`\`\`text

rewarded outcome

→ ACTION/EFFECT \--ACHIEVES--\> GOAL context relation

\`\`\`

&nbsp;

Nhưng \`ACHIEVES\` phải context-scoped.

&nbsp;

\#\# 3.9 Purpose trace

&nbsp;

Purpose explanation phải đi theo real graph path:

&nbsp;

\`\`\`text

ACTION

→ CAUSES EFFECT

→ CHANGES STATE

→ ACHIEVES GOAL

\`\`\`

&nbsp;

GEMINI chỉ dịch path đó.

&nbsp;

Ví dụ:

&nbsp;

\`\`\`text

WRITE LED3=1

→ causes LED3\_ON

→ changes STATUS\_VISIBLE

→ achieves GOAL\_SUCCESS\_SIGNAL

\`\`\`

&nbsp;

Khi hỏi “tại sao bật LED3?”, output phải có provenance path; nếu path thiếu thì trả \`purpose\_not\_established\`, không bịa.

&nbsp;

\#\# 3.10 NCG traversal engine

&nbsp;

R1 bounded BFS/best-first:

&nbsp;

\`\`\`text

max\_depth \= 4–6

frontier \<= 16/32

visited cache bounded

relation mask

cost budget

\`\`\`

&nbsp;

Không làm graph neural network.

&nbsp;

Q\* có thể dùng NCG summaries làm feature:

&nbsp;

\`\`\`text

known\_effect\_count

known\_failure\_count

support\_path\_exists

conflict\_path\_exists

goal\_distance\_bucket

novelty\_count

\`\`\`

&nbsp;

SPEAR có thể rank edge/candidate trong neighborhood đã chọn.

&nbsp;

\#\# 3.11 NCG creation rules

&nbsp;

New node only if:

\- physical/capability identity mới

\- stable repeated observation pattern

\- explicit user alias/goal concept

\- skill/failure prototype promoted by its own contract

&nbsp;

Không tạo node mới cho mọi cycle/event.

&nbsp;

New edge:

&nbsp;

\`\`\`text

exact key absent

→ create

exact key present

→ update counters/provenance

\`\`\`

&nbsp;

\#\# 3.12 Causal relation promotion

&nbsp;

\`CAUSES\` không được sinh chỉ từ co-occurrence.

&nbsp;

Recommended ladder:

&nbsp;

\`\`\`text

OBSERVED\_TOGETHER

→ CORRELATES\_WITH

→ intervention/action executed

→ effect repeatedly follows

→ candidate CAUSES

→ ASTRA/proof gate

→ verified causal relation

\`\`\`

&nbsp;

\---

&nbsp;

\# 4\. Failure as active knowledge, not passive log

&nbsp;

Ý tưởng khóa mới:

&nbsp;

\> Failure đã bị phạt phải làm thay đổi hành vi tương lai; nếu cùng failure lặp lại nhiều lần trong cùng context thì Native AI phải ngày càng ít chọn lại hành động đó.

&nbsp;

Đây là một trong những memory loops quan trọng nhất của R1.

&nbsp;

\#\# 4.1 Failure edge in NCG

&nbsp;

Khi một action bị phạt:

&nbsp;

\`\`\`text

ACTION\_X

\--FAILED\_AT(context C)--\> EFFECT\_BAD

\`\`\`

&nbsp;

và có thể thêm:

&nbsp;

\`\`\`text

ACTION\_X

\--AVOID\_UNDER(context C)--\> GOAL/STATE\_C

\`\`\`

&nbsp;

\`AVOID\_UNDER\` là learned procedural relation, không phải safety hard-rule.

&nbsp;

\#\# 4.2 Failure-Avoidance Score

&nbsp;

Trước Q\*/SPEAR selection, derive one bounded numeric penalty:

&nbsp;

\`\`\`text

failure\_penalty \= f(

  same\_context\_fail\_count,

  recent\_fail\_count,

  severity,

  unresolved\_flag,

  regression\_flag,

  success\_after\_repair

)

\`\`\`

&nbsp;

Simple fixed-point candidate:

&nbsp;

\`\`\`text

P\_fail \= min(

  MAX\_P,

  8\*recent\_fail

\+ 4\*same\_context\_fail

\+ 16\*regression

\- 2\*success\_after\_repair

)

\`\`\`

&nbsp;

Chỉ là engineering starting point; phải prereg trước benchmark.

&nbsp;

Q\*/SPEAR effective value:

&nbsp;

\`\`\`text

score\_eff \= learned\_score \- P\_fail

\`\`\`

&nbsp;

Không thay ASTRA legality.

&nbsp;

\#\# 4.3 Four avoidance states

&nbsp;

\`\`\`text

NEW

→ SOFT\_AVOID

→ STRONG\_AVOID

→ CONTEXT\_VETO

\`\`\`

&nbsp;

Transition theo repeated verified failure.

&nbsp;

\`CONTEXT\_VETO\` có nghĩa:

&nbsp;

\`\`\`text

matching context

→ action excluded from learned candidate set

\`\`\`

&nbsp;

Không có nghĩa action illegal toàn hệ thống.

&nbsp;

\#\# 4.4 Why not “never forever”

&nbsp;

Nếu LED3 ON bị phạt trong goal A nhưng lại đúng trong goal B, global blacklist sẽ phá transfer.

&nbsp;

Do đó failure memory phải bind:

&nbsp;

\`\`\`text

goal class

state signature

capability/target

expected effect

action

relevant environment version

\`\`\`

&nbsp;

Native AI nên “nhớ để tránh” chứ không “mù quáng cấm vĩnh viễn”.

&nbsp;

\#\# 4.5 Sparse re-probe

&nbsp;

Nếu action đã STRONG\_AVOID nhưng context hoặc skill version đổi, TRAIN mode có thể cho controlled sparse re-probe.

&nbsp;

EXAM mode không re-probe ngẫu nhiên.

&nbsp;

\#\# 4.6 Failure compaction

&nbsp;

Sau repair ổn định:

&nbsp;

\`\`\`text

many raw failure episodes

→ one compact prototype

\`\`\`

&nbsp;

Prototype giữ:

\- failure signature

\- counts

\- last seen

\- repair skill/version

\- success after repair

\- avoidance state

\- exemplar pointers

&nbsp;

Nếu failure quay lại:

&nbsp;

\`\`\`text

COMPACTED → REOPENED

\`\`\`

&nbsp;

\---

&nbsp;

\# 5\. Interaction between NCG, FEM, Q\*, SPEAR and Skill

&nbsp;

\`\`\`text

NCG says:

  what is known / related / named / goal-connected

&nbsp;

FEM says:

  what failed, where, how often, whether resolved

&nbsp;

Q\* says:

  which macro action to try next

&nbsp;

SPEAR says:

  which target/candidate inside that action

&nbsp;

Skill says:

  reusable multi-step procedure

&nbsp;

ASTRA says:

  legal/proved/complete/conflicted or not

\`\`\`

&nbsp;

Example:

&nbsp;

\`\`\`text

Goal G7

↓

NCG: LED3 linked to STATUS\_SIGNAL

↓

FEM: LED2 path repeatedly failed in same context

↓

Q\*: chooses OUTPUT\_SIGNAL

↓

SPEAR: LED3 outranks LED2

↓

Skill: SET\_STATUS\_INDICATOR executes

↓

ASTRA verifies physical effect/status

↓

reward

↓

NCG/FEM/weights update

\`\`\`

&nbsp;

\---

&nbsp;

\# 6\. Minimal implementation order for NCG

&nbsp;

Do not implement full graph at once.

&nbsp;

\#\# NCG-0 — identity \+ capability graph

&nbsp;

Implement only:

&nbsp;

\`\`\`text

CAPABILITY

STATE

ACTION

EFFECT

SELF\_ID

\`\`\`

&nbsp;

Edges:

&nbsp;

\`\`\`text

HAS\_STATE

CAN\_DO

ACTS\_ON

CHANGES

\`\`\`

&nbsp;

PASS:

\- enumerate board resources

\- stable SELF\_ID

\- exact readback effect

&nbsp;

\#\# NCG-1 — failure relations

&nbsp;

Add:

&nbsp;

\`\`\`text

FAILURE

FAILED\_AT

AVOID\_UNDER

RECOVERED\_BY

\`\`\`

&nbsp;

PASS:

\- repeated same-context penalty lowers reselection probability/rank

\- different context not globally blocked

\- reset/restore reproduces avoidance memory

&nbsp;

\#\# NCG-2 — symbol \+ alias

&nbsp;

Add:

&nbsp;

\`\`\`text

SYMBOL

HUMAN\_ALIAS

NAMED\_AS

\`\`\`

&nbsp;

PASS:

\- internal concept works before human name

\- attach alias without retraining procedural knowledge

&nbsp;

\#\# NCG-3 — goal/purpose

&nbsp;

Add:

&nbsp;

\`\`\`text

GOAL

ACHIEVES

\`\`\`

&nbsp;

PASS:

\- purpose trace exists

\- GEMINI can explain from trace

\- removing edge removes explanation

&nbsp;

\#\# NCG-4 — concept composition

&nbsp;

Add:

&nbsp;

\`\`\`text

CONCEPT

IS\_A

PART\_OF

COMPOSES

\`\`\`

&nbsp;

PASS:

\- unseen capability instance joins known class by features/effects

\- no per-ID memorization claim.

&nbsp;

\---

&nbsp;

\# 7\. RTL modules candidate

&nbsp;

\`\`\`text

native\_capability\_rom.sv

native\_observation\_ingress.sv

native\_effect\_capture.sv

native\_ncg\_node\_cache.sv

native\_ncg\_edge\_cache.sv

native\_ncg\_lookup.sv

native\_ncg\_traversal.sv

native\_ncg\_update.sv

native\_failure\_prior.sv

native\_failure\_compactor.sv

native\_skill\_engine.sv

native\_trajectory\_buffer.sv

native\_return\_engine.sv

native\_reward\_capture.sv

\`\`\`

&nbsp;

Do not create all modules in one commit.

&nbsp;

One milestone \= only modules required by its causal question.

&nbsp;

\---

&nbsp;

\# 8\. Suggested BRAM budget for NCG/FEM lane

&nbsp;

Engineering candidate only:

&nbsp;

\`\`\`text

NCG node hot cache       1–2 BRAM36

NCG edge hot cache       2–4

Traversal queue/visited  1–2

FEM hot prototypes       2–4

Trajectory/return        1–3

Skill hot table          2–4

\`\`\`

&nbsp;

Target incremental total:

&nbsp;

\`\`\`text

\~9–19 BRAM36

\`\`\`

&nbsp;

Actual budget determined by OOC synthesis, not this document.

&nbsp;

Full graph lives DDR.

&nbsp;

\---

&nbsp;

\# 9\. DDR organization candidate for NCG/FEM

&nbsp;

Within forward V2 memory region:

&nbsp;

\`\`\`text

NCG\_NODE\_TABLE

NCG\_EDGE\_POOL

NCG\_ADJ\_PAGE\_TABLE

NCG\_ALIAS\_TABLE

NCG\_PROVENANCE

FEM\_RAW\_RING

FEM\_PROTOTYPE\_TABLE

SKILL\_LIBRARY

CHECKPOINT\_A/B

\`\`\`

&nbsp;

Prefer append/journal \+ compact rather than random rewriting large regions.

&nbsp;

\---

&nbsp;

\# 10\. Acceptance tests specific to NCG

&nbsp;

\#\# NCG-T1 — unnamed resource grounding

&nbsp;

Present CAP\_X without human alias.

&nbsp;

Expected after exploration/teaching:

&nbsp;

\`\`\`text

stable SELF\_ID

state range learned/known

legal actions known

observed effects linked

\`\`\`

&nbsp;

\#\# NCG-T2 — alias after knowledge

&nbsp;

After CAP\_X knowledge is stable:

&nbsp;

\`\`\`text

attach HUMAN\_ALIAS="LED3"

\`\`\`

&nbsp;

All prior knowledge remains valid without relearn.

&nbsp;

\#\# NCG-T3 — failure avoidance

&nbsp;

Same context/action punished repeatedly:

&nbsp;

\`\`\`text

selection frequency/rank decreases monotonically enough to meet prereg target

\`\`\`

&nbsp;

Different context:

&nbsp;

\`\`\`text

action remains available

\`\`\`

&nbsp;

\#\# NCG-T4 — failure repair

&nbsp;

Train alternative path:

&nbsp;

\`\`\`text

old failure prototype

→ RECOVERED\_BY skill S

→ stable success

→ compact

\`\`\`

&nbsp;

Regression later must reopen.

&nbsp;

\#\# NCG-T5 — purpose trace

&nbsp;

Goal reached by action-effect chain.

&nbsp;

Explain must enumerate exact graph path.

&nbsp;

Delete/disable one edge → explanation must become incomplete, not hallucinated.

&nbsp;

\#\# NCG-T6 — transfer

&nbsp;

Swap LED/resource instance IDs but preserve capability class/effect schema.

&nbsp;

A useful concept/skill should transfer better than per-ID baseline.

&nbsp;

\---

&nbsp;

\# 11\. Simplified implementation discipline

&nbsp;

Do not repeat ASTRA process explosion.

&nbsp;

Per milestone only:

&nbsp;

\`\`\`text

CONTRACT.md

RESULT.json

EVIDENCE.md

SHA256SUMS.txt

\`\`\`

&nbsp;

Execution:

&nbsp;

\`\`\`text

reference model

→ RTL unit

→ XSim integration

→ OOC

→ board only if silicon evidence needed

\`\`\`

&nbsp;

Stop on first causal failure.

&nbsp;

Do not add another algorithm while current causal question remains unresolved.

&nbsp;

\---

&nbsp;

\# 12\. Locked decisions

&nbsp;

1\. Native AI is not a small LLM.

2\. No AGI claim.

3\. Binary/internal IDs are representation, not semantics by themselves.

4\. Deterministic math/codecs stay substrate; do not relearn exact arithmetic.

5\. Capability manifest says what exists/can execute, not what action is best.

6\. NCG is sparse typed cognitive graph, not neural network replacement claim.

7\. SELF\_ID is stable internal identity; human alias is optional metadata.

8\. NCG edges are typed; correlation never silently becomes causation.

9\. Purpose must be traceable through stored relation path.

10\. Q\* remains macro decision learner.

11\. SPEAR remains micro candidate/target ranker.

12\. ASTRA remains legality/proof/truth/status authority.

13\. GEMINI may explain but not invent missing semantic/proof relations.

14\. FEM is active learning memory, not passive logging.

15\. Verified repeated failure must lower probability/rank of repeating same action in same context.

16\. Learned failure avoidance is context-conditioned, not global permanent blacklist.

17\. Safety hard veto is deterministic and separate from learned avoidance.

18\. Failure memory is compacted, not erased.

19\. Regression reopens compacted failure knowledge.

20\. First delayed-credit implementation is bounded executed-action multi-step return.

21\. Unexecuted action receives no positive credit in the first causal lane.

22\. Skill/options layer begins simple; no Option-Critic in R1.

23\. Shared/sequential arithmetic preferred over parallel multiplier arrays.

24\. BRAM \= hot bounded state; DDR \= long-term graph/episode/skill/evidence memory.

25\. Checkpoints are atomic A/B and bind all semantic/learner versions.

26\. TRAIN may explore; EXAM is deterministic.

27\. Host does not select winner/proof/action in autonomous benchmark.

28\. Historical R2/R3 evidence remains immutable.

29\. No board programming merely to debug basic RTL logic.

30\. No new sub-gate unless there is a distinct causal uncertainty.

&nbsp;

\---

&nbsp;

\# 13\. Implementation start prompt

&nbsp;

\`\`\`text

You are implementing NATIVE\_AI\_DEVELOPMENTAL\_HARDWARE\_R1 in an isolated worktree.

&nbsp;

DO NOT modify frozen R2/R3 artifacts.

DO NOT program the board until the milestone explicitly allows it.

DO NOT add semantic hard rules to rescue a benchmark.

DO NOT let host select semantic winners.

&nbsp;

Implement in order:

&nbsp;

M0 freeze \+ isolated lane

M1 Native Substrate ISA

M2 physical teaching/reward loop

M3 bounded multi-step executed-action credit

M4 Failure Experience Memory \+ failure avoidance

M5 NCG-0/1 grounding \+ failure relations

M6 Skill/options composition

M7 Q\* \+ SPEAR \+ NCG coordination

M8 NCG alias/purpose \+ ASTRA/GEMINI explanation

M9 full silicon/transfer/continual-learning campaign

&nbsp;

For every milestone:

1\. write one causal question

2\. create Python/reference gold

3\. implement minimal RTL

4\. XSim

5\. OOC synth/timing/resource

6\. board only if required

7\. freeze evidence

&nbsp;

When a test fails, diagnose first divergence before adding a correction.

\`\`\`

&nbsp;

\---

&nbsp;

\# 14\. Final research claim this architecture is allowed to pursue

&nbsp;

If all major gates eventually pass, a defensible claim is:

&nbsp;

\> A bounded FPGA-native cognitive controller can ground physical capabilities into stable internal symbols and typed relations, learn reusable skills and investigation/evidence policies from real interaction and scalar feedback, retain context-specific failure knowledge that alters future behavior, compact resolved experience, and provide provenance-backed state/purpose explanations while deterministic proof and legality remain independently enforced.

&nbsp;

Không claim consciousness, emotion, AGI hoặc human-equivalent cognition.

&nbsp;