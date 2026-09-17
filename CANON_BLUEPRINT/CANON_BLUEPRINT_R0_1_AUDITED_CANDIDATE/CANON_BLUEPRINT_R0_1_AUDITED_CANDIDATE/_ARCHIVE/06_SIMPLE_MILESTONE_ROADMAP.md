\# 06\_SIMPLE\_MILESTONE\_ROADMAP

&nbsp;

\#\# NATIVE AI DEVELOPMENTAL HARDWARE R1

&nbsp;

Status: RESEARCH / FORWARD DESIGN

Target: Arty A7-100T / XC7A100T-CSG324-1

&nbsp;

\---

&nbsp;

\#\# 1\. Mục tiêu của roadmap

&nbsp;

Roadmap này cố ý ngắn hơn quy trình ASTRA hiện tại. Mục tiêu là tránh tình trạng dự án bị chậm do quá nhiều gate, bag, tài liệu trùng lặp và test không trả lời một câu hỏi causal cụ thể.

&nbsp;

Nguyên tắc vận hành:

&nbsp;

\`\`\`text

ONE MILESTONE \= ONE PRIMARY CAUSAL QUESTION

\`\`\`

&nbsp;

Mỗi milestone chỉ bắt buộc 4 artifact:

&nbsp;

\`\`\`text

CONTRACT.md

RESULT.json

EVIDENCE.md

SHA256SUMS.txt

\`\`\`

&nbsp;

Chỉ tạo thêm artifact khi thật sự cần cho reproduce/debug.

&nbsp;

Pipeline chuẩn duy nhất:

&nbsp;

\`\`\`text

SPEC

→ Python/reference gold

→ RTL unit

→ XSim integration

→ OOC synth/timing

→ BOARD only when silicon evidence is required

\`\`\`

&nbsp;

Không tạo milestone mới chỉ để “quản lý tiến độ”. Chỉ tách milestone khi xuất hiện một uncertainty kiến trúc mới.

&nbsp;

\---

&nbsp;

\# M0 — FREEZE CURRENT AUTHORITY \+ ISOLATED RESEARCH LANE

&nbsp;

\#\# Câu hỏi causal

&nbsp;

Ta có thể mở lane Native AI mới mà không làm thay đổi evidence/history R2/R3 hiện tại không?

&nbsp;

\#\# Việc phải làm

&nbsp;

\- Freeze toàn bộ R2/R3 checkpoints và reports.

\- Ghi SHA của W0/W1, test outputs và source authority.

\- Tạo worktree/branch độc lập, ví dụ:

&nbsp;

\`\`\`text

research/native-developmental-r1

\`\`\`

&nbsp;

\- \`PROGRAM=NO\`.

\- Không sửa interface hiện có nếu chưa có adapter versioned.

&nbsp;

\#\# PASS

&nbsp;

\- Hash historical artifacts không đổi.

\- New lane build/test độc lập.

\- Không có file mới ghi đè vào thư mục R2/R3.

&nbsp;

\#\# STOP condition

&nbsp;

Nếu bất kỳ evidence cũ nào bị đổi hash → dừng và phục hồi trước khi làm M1.

&nbsp;

\---

&nbsp;

\# M1 — NATIVE SUBSTRATE ISA \+ CAPABILITY INVENTORY

&nbsp;

\#\# Câu hỏi causal

&nbsp;

Hệ thống có thể “biết mình có gì trong tay” bằng một manifest typed mà không nhúng policy/task semantics vào phần cứng không?

&nbsp;

\#\# Implement

&nbsp;

\#\#\# Capability Registry

&nbsp;

Mỗi capability có:

&nbsp;

\`\`\`text

cap\_id

class

instance

width

access\_flags

primitive\_mask

ready

safety\_class

latency\_bucket

cost\_bucket

effect\_schema

executor\_index

version

\`\`\`

&nbsp;

\#\#\# Primitive ISA

&nbsp;

Tối thiểu:

&nbsp;

\`\`\`text

READ

WRITE

COMPARE

ADD

SUB

SHIFT

MASK

PACK

UNPACK

ENUM\_LEGAL

OBSERVE\_EFFECT

COMMIT\_ACTION

\`\`\`

&nbsp;

\#\#\# Deterministic codecs

&nbsp;

Hard/frozen substrate:

&nbsp;

\`\`\`text

bit ↔ word

binary ↔ unsigned/signed integer

nibble ↔ hex

integer ↔ decimal digits

byte ↔ ASCII

CRC/checksum

\`\`\`

&nbsp;

Không học lại toán/encoding bằng reward.

&nbsp;

\#\# Không được chứa

&nbsp;

\`\`\`text

preferred\_action

gold\_action

success\_led

if\_incomplete\_then\_search

winner\_candidate

\`\`\`

&nbsp;

\#\# Tests

&nbsp;

\- Exhaustive nibble↔HEX.

\- U8/U16 pack/unpack roundtrip.

\- ASCII valid/invalid.

\- decimal conversion boundary.

\- illegal operation rejected.

\- unavailable capability rejected.

&nbsp;

\#\# PASS

&nbsp;

\- Python/reference và RTL bit-exact.

\- capability manifest không chứa field policy.

\- same manifest → same legal primitive set.

&nbsp;

\#\# Board

&nbsp;

Không cần board.

&nbsp;

\---

&nbsp;

\# M2 — PHYSICAL TEACHING LOOP

&nbsp;

\#\# Câu hỏi causal

&nbsp;

Có thể nhận reward/penalty thật từ người dùng hoặc UART teacher và bind chính xác nó vào episode/action đã thực thi không?

&nbsp;

\#\# Implement

&nbsp;

\#\#\# Button reward path

&nbsp;

\`\`\`text

BTN

→ synchronizer

→ debounce

→ one-shot

→ reward event

→ pending identity check

→ commit

\`\`\`

&nbsp;

Candidate mapping đầu tiên:

&nbsp;

\`\`\`text

BTN0 \= \+ reward

BTN1 \= \- penalty

BTN2 \= demonstration modifier

BTN3 \= cancel/reserved

\`\`\`

&nbsp;

\#\#\# UART reward frame

&nbsp;

\`\`\`text

session\_id

txn\_id

episode\_id

step\_id/generation

reward\_value

crc

\`\`\`

&nbsp;

Teacher chỉ gửi scalar reward hoặc explicit demonstration event.

&nbsp;

Teacher không được gửi:

&nbsp;

\`\`\`text

weight delta

winner action

winner candidate

proof override

\`\`\`

&nbsp;

\#\# Tests

&nbsp;

\- Một lần nhấn \= một reward commit.

\- Bounce không nhân reward.

\- duplicate UART reward rejected.

\- stale txn rejected.

\- wrong generation rejected.

\- no pending → no update.

&nbsp;

\#\# PASS

&nbsp;

Reward path đúng identity 100% trong test matrix.

&nbsp;

\#\# Board

&nbsp;

Đây là milestone đầu tiên có thể dùng board cho một smoke test nhỏ vì mục tiêu là physical interaction.

&nbsp;

Không dùng board để debug learner.

&nbsp;

\---

&nbsp;

\# M3 — QP-16 BOUNDED MULTI-STEP EXECUTED-ACTION CREDIT

&nbsp;

\#\# Câu hỏi causal

&nbsp;

Reward terminal có thể truyền ngược qua trajectory thật mà tuyệt đối không credit action chưa thực thi không?

&nbsp;

\#\# Implement

&nbsp;

Bound đầu tiên:

&nbsp;

\`\`\`text

MAX\_STEPS \= 16

one active episode

backward return after terminal

\`\`\`

&nbsp;

Trajectory entry giữ:

&nbsp;

\`\`\`text

state identity

phi

executed action

selected candidate if any

policy versions

local reward

effect

next state

terminal status

\`\`\`

&nbsp;

Primary rule:

&nbsp;

\`\`\`text

UNEXECUTED ACTION → ΔW \= 0

\`\`\`

&nbsp;

\#\# Required cases

&nbsp;

\#\#\# A. SEARCH executed and later succeeds

&nbsp;

\`\`\`text

FOLLOW → SEARCH → READ → ANSWER

\`\`\`

&nbsp;

SEARCH phải nhận positive delayed return.

&nbsp;

\#\#\# B. SEARCH never executed

&nbsp;

\`\`\`text

FOLLOW → FOLLOW → FAIL

\`\`\`

&nbsp;

SEARCH delta phải bằng 0\.

&nbsp;

\#\#\# C. Reset/restore

&nbsp;

\`\`\`text

W0 → behavior A

train → W1 → behavior B

reset W0 → A

restore W1 → B

\`\`\`

&nbsp;

\#\# PASS

&nbsp;

\- case A/B/C đều pass.

\- stale/duplicate reward không cập nhật.

\- sign/saturation tests pass.

&nbsp;

\#\# Không làm

&nbsp;

\- không mở R4 trước khi M3 pass.

\- không thêm feature mới để cứu H2.

\- không hard-code incomplete→SEARCH.

&nbsp;

\---

&nbsp;

\# M4 — FAILURE EXPERIENCE MEMORY \+ COMPACTION

&nbsp;

\#\# Câu hỏi causal

&nbsp;

Hệ thống có thể biến failure lặp lại thành experience có cấu trúc, sau đó compact khi đã học mà không đánh mất khả năng phát hiện regression không?

&nbsp;

\#\# Implement

&nbsp;

Lifecycle:

&nbsp;

\`\`\`text

RAW\_FAILURE

→ CLUSTERED\_FAILURE

→ RESOLVED\_FAILURE

→ COMPACTED\_EXPERIENCE

\`\`\`

&nbsp;

Regression:

&nbsp;

\`\`\`text

COMPACTED\_EXPERIENCE

→ REOPENED\_FAILURE

\`\`\`

&nbsp;

Typed failure key:

&nbsp;

\`\`\`text

domain

stage

capability class

action class

effect class

context signature

\`\`\`

&nbsp;

BRAM:

\- hot prototypes

\- unresolved failures

\- compactor staging

&nbsp;

DDR:

\- raw failure ring

\- compacted prototypes

\- exemplars

&nbsp;

\#\# Tests

&nbsp;

\- same failure clusters.

\- different stage does not falsely cluster.

\- stable success resolves cluster.

\- compaction reduces raw bytes.

\- regression reopens prototype.

\- no raw records retired before compact summary checkpoint commits.

&nbsp;

\#\# PASS

&nbsp;

Compaction giảm memory footprint nhưng vẫn reconstruct được:

&nbsp;

\`\`\`text

what failed

where

how many times

what repaired it

whether it regressed

\`\`\`

&nbsp;

\---

&nbsp;

\# M5 — SKILL/OPTION ENGINE \+ NATIVE COGNITIVE GRAPH

&nbsp;

\#\# Câu hỏi causal

&nbsp;

Hệ thống có thể chuyển primitive đã biết thành skill tái sử dụng và hình thành concept/relationship mà không cần per-task FSM hay host gán winner không?

&nbsp;

\#\# Part A — Skill/Option

&nbsp;

Skill descriptor:

&nbsp;

\`\`\`text

skill\_id

version

goal\_class

preconditions

capability\_class\_mask

max\_steps

policy/sequence ref

termination

expected\_effect

cost

success\_count

failure\_count

status

\`\`\`

&nbsp;

Lifecycle:

&nbsp;

\`\`\`text

CANDIDATE

→ LEARNED

→ VERIFIED

→ STABLE

→ COMPACTED

\`\`\`

&nbsp;

Regression → REOPENED.

&nbsp;

\#\# Part B — NCG: Native Cognitive Graph

&nbsp;

Node types đầu tiên:

&nbsp;

\`\`\`text

CAPABILITY

STATE

ACTION

EFFECT

ENTITY

PROPERTY

SKILL

GOAL

FAILURE

SYMBOL

PROOF\_REF

\`\`\`

&nbsp;

Edge types:

&nbsp;

\`\`\`text

IS\_A

PART\_OF

CAN\_DO

ACTS\_ON

CAUSES

CHANGES

OBSERVED\_BY

ACHIEVES

FAILED\_AT

NAMED\_AS

COMPOSES

\`\`\`

&nbsp;

Mỗi object có thể có:

&nbsp;

\`\`\`text

SELF\_ID

HUMAN\_ALIAS optional

SEMANTIC\_ROLE learned

\`\`\`

&nbsp;

Binary/internal ID là representation, không tự động là semantics.

&nbsp;

\#\# Key experiment

&nbsp;

Cho một capability mới chưa có human name.

&nbsp;

System được phép:

\- observe state

\- execute legal primitives

\- receive reward

\- create stable SELF\_ID

\- learn action→effect relations

&nbsp;

Sau đó human mới gắn alias.

&nbsp;

PASS mạnh khi alias mới không làm thay đổi learned relation/skill.

&nbsp;

\#\# Skill transfer test

&nbsp;

Học trên LED/index A, test trên unseen instance B cùng capability class.

&nbsp;

Fail claim nếu behavior chỉ hoạt động với hard-coded ID.

&nbsp;

\---

&nbsp;

\# M6 — Q\* \+ SPEAR ADAPTIVE COORDINATION

&nbsp;

\#\# Câu hỏi causal

&nbsp;

Macro learning và micro ranking có tạo lợi ích độc lập và phối hợp được trong task thực không?

&nbsp;

\#\# Keep authority

&nbsp;

\`\`\`text

Q\*    \= what macro action next

SPEAR \= which legal candidate/target first

\`\`\`

&nbsp;

No authority merge.

&nbsp;

\#\# Required ablation

&nbsp;

\`\`\`text

Q0S0

Q1S0

Q0S1

Q1S1

B1 fixed control

\`\`\`

&nbsp;

Metrics:

&nbsp;

\`\`\`text

success/proof validity

actions/query

reads-to-useful-effect

scan cost

DDR ops

cycles

\`\`\`

&nbsp;

Target:

\- Q\* correct macro behavior trên holdout.

\- SPEAR giảm cost khi macro đúng.

\- joint không được tệ hơn Q-only về correctness.

&nbsp;

Nếu B1 vẫn Pareto tốt hơn, giữ \`useful\_learned\_planner=false\`.

&nbsp;

\---

&nbsp;

\# M7 — ASTRA \+ GEMINI COMPLETE BOUNDED LOOP

&nbsp;

\#\# Câu hỏi causal

&nbsp;

System có thể đi từ observation→reasoning→physical/semantic action→proof/status→explanation mà không phá authority boundary không?

&nbsp;

\#\# Integrate

&nbsp;

\`\`\`text

Substrate

→ NCG/working state

→ Q\*

→ SPEAR

→ Skill

→ Primitive execution

→ physical/evidence effect

→ ASTRA verification/status

→ FEM/episode

→ GEMINI expression

\`\`\`

&nbsp;

ASTRA vẫn giữ:

\- legality

\- proof

\- conflict

\- completeness

\- promotion

&nbsp;

GEMINI chỉ:

\- expression

\- alias/language proposal

\- explanation rendering

&nbsp;

\#\# End-to-end example

&nbsp;

System gặp unknown capability X.

&nbsp;

Nó học:

\- X writable

\- state binary

\- WRITE(1) causes visible effect

\- effect helps goal G

&nbsp;

Human sau đó gắn alias “LED3”.

&nbsp;

GEMINI có thể diễn giải:

&nbsp;

\`\`\`text

Tôi dùng LED3 vì action này tạo effect E,

E thỏa goal G, dựa trên N successful interactions.

\`\`\`

&nbsp;

Explanation phải trace từ provenance; không generate lý do tự do.

&nbsp;

\#\# PASS

&nbsp;

\- illegal high-score action vetoed.

\- fake proof rejected.

\- GEMINI cannot override ASTRA status.

\- concept/skill explanation has traceable IDs.

\- host semantic authority remains zero.

&nbsp;

\---

&nbsp;

\# M8 — SILICON / TRANSFER / LONG-RUN CONTINUAL LEARNING

&nbsp;

\#\# Câu hỏi causal

&nbsp;

Toàn bộ architecture có giữ causal behavior và persistence trên silicon, với workload dài và transfer không?

&nbsp;

\#\# Precondition

&nbsp;

Không vào M8 nếu:

\- full top timing chưa clean

\- resource budget chưa rõ

\- checkpoint reset/restore chưa pass

\- M3–M7 còn ambiguity causal

&nbsp;

\#\# Board campaign

&nbsp;

\- exact bitstream SHA.

\- exact policy/checkpoint SHA.

\- UART raw capture.

\- no hidden host route/winner.

\- BTN reward physical test.

\- power/reset replay.

\- DDR checkpoint persistence.

\- long-run failure compaction.

\- regression reopen.

\- unseen capability instance.

\- unseen task composition.

&nbsp;

\#\# Hardware acceptance

&nbsp;

\`\`\`text

WNS \>= 0

TNS \= 0

hold clean

no critical DRC

no hidden CDC violations

\`\`\`

&nbsp;

Preferred pre-board margin: WNS \>= \+0.2 ns.

&nbsp;

\#\# Final research claim ceiling

&nbsp;

Chỉ owner mới nâng claim.

&nbsp;

Một claim phù hợp nếu evidence đủ:

&nbsp;

\> FPGA-native bounded developmental controller learns reusable investigation/interaction skills and evidence priorities from grounded experience while proof/truth authority remains deterministic and separate.

&nbsp;

Không claim AGI, consciousness hoặc human-level intelligence.

&nbsp;

\---

&nbsp;

\# 10\. Scheduling rule

&nbsp;

Không cần gắn ngày cố định vào architecture. Dùng effort buckets:

&nbsp;

\`\`\`text

S \= 1–3 ngày kỹ thuật

M \= 3–7 ngày

L \= 1–3 tuần

\`\`\`

&nbsp;

Ước lượng ban đầu:

&nbsp;

\`\`\`text

M0  S

M1  M

M2  M

M3  M–L

M4  M

M5  L

M6  M–L

M7  L

M8  L

\`\`\`

&nbsp;

Nếu một M kéo dài hơn 2× estimate, không mở thêm scope. Chạy RCA xem milestone đang trả lời nhiều hơn một causal question hay không.

&nbsp;

\---

&nbsp;

\# 11\. Definition of Done cho mỗi milestone

&nbsp;

Một milestone chỉ DONE khi có đủ:

&nbsp;

\`\`\`text

1\. Contract trước khi test

2\. Reference/golden behavior

3\. Result máy đọc được

4\. Evidence con người đọc được

5\. Hash/seal

6\. Known limitations

7\. Next pointer duy nhất

\`\`\`

&nbsp;

Không được DONE chỉ vì “simulation chạy”.

&nbsp;

Không được FAIL rồi thêm module mới ngay. Trước tiên phải xác định failure thuộc:

&nbsp;

\`\`\`text

representation

credit

protocol

identity

arithmetic

memory

consumer path

hardware timing

\`\`\`

&nbsp;

\---

&nbsp;

\# 12\. Anti-complexity rules

&nbsp;

1\. Không hơn 8–9 milestone chính trong R1.

2\. Không quá một correction prereg cho một replay.

3\. Không nhân đôi module chỉ để debug.

4\. Không dùng board làm debugger đầu tiên.

5\. Không tạo FSM semantic cho từng task.

6\. Không thêm feature nếu RCA chưa chứng minh representation thiếu.

7\. Không đổi action ABI giữa một replay.

8\. Không overwrite negative evidence.

9\. Không biến dashboard/visualization thành acceptance evidence.

10\. Mọi module mới phải trả lời rõ: “nó loại bỏ uncertainty nào?”.

&nbsp;

\---

&nbsp;

\# 13\. Thứ tự build khuyến nghị

&nbsp;

\`\`\`text

M0

 ↓

M1

 ↓

M2

 ↓

M3  ← critical credit foundation

 ↓

M4

 ↓

M5  ← skill \+ concept formation

 ↓

M6

 ↓

M7

 ↓

M8

\`\`\`

&nbsp;

Không nên làm NCG/skill learning trước khi M3 executed-action credit ổn định, vì nếu credit sai thì concept/skill statistics sẽ bị nhiễm ngay từ gốc.

&nbsp;

\---

&nbsp;

\# 14\. Milestone stop philosophy

&nbsp;

Nếu milestone trả lời được câu hỏi causal thì freeze và đi tiếp.

&nbsp;

Không tiếp tục “làm đẹp” module đó trong cùng lane.

&nbsp;

Optimization chỉ mở khi một benchmark sau này chứng minh bottleneck thật.

&nbsp;

Đây là bài học chính để Native AI không lặp lại tình trạng ASTRA phát triển đúng nhưng bị chậm vì verification/process mở rộng nhanh hơn capability thực.

&nbsp;