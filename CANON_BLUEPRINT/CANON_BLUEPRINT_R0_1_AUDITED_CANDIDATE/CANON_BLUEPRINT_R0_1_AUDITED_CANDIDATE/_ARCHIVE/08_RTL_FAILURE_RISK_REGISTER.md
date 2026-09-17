\# 08\_RTL\_FAILURE\_RISK\_REGISTER

&nbsp;

\*\*Project:\*\* NATIVE\_AI\_DEVELOPMENTAL\_HARDWARE\_R1&nbsp;&nbsp;

\*\*Target:\*\* Arty A7-100T / XC7A100T-CSG324-1&nbsp;&nbsp;

\*\*Status:\*\* Forward-design risk register. Không thay đổi evidence R2/R3 hiện hữu.

&nbsp;

\---

&nbsp;

\# 1\. Mục tiêu

&nbsp;

File này liệt kê trước các lỗi RTL/phần cứng có xác suất cao khi triển khai Native AI gồm Native Substrate, Q\*, SPEAR, NCG, Skill Engine, Failure Experience Memory, ASTRA và GEMINI.

&nbsp;

Nguyên tắc:

&nbsp;

\`\`\`text

predictable hardware bug

→ phải có assertion/test trước integration

→ không đợi đến board mới phát hiện

\`\`\`

&nbsp;

Mỗi lỗi được xem theo 4 trường:

&nbsp;

\`\`\`text

SYMPTOM  \= biểu hiện

CAUSE    \= nguyên nhân RTL khả dĩ

DETECT   \= test/assertion cần có

MITIGATE \= cách thiết kế tránh lỗi

\`\`\`

&nbsp;

\---

&nbsp;

\# 2\. Fixed-point / arithmetic / learning-update risks

&nbsp;

\#\# R-ARITH-01 — signed shift bất đối xứng

&nbsp;

SYMPTOM:

\- positive update bị quantize về 0

\- negative update vẫn thành \-1

\- learned μ đi sai hướng dù TD error đúng dấu

&nbsp;

CAUSE:

\- arithmetic shift signed/unsigned không thống nhất

\- rounding âm do two's complement

\- shift quá lớn so với \`td\_error \* phi\`

&nbsp;

DETECT:

&nbsp;

\`\`\`text

phi \> 0 && delta \> 0 → dW \>= 0

phi \> 0 && delta \< 0 → dW \<= 0

phi \= 0              → dW \= 0

\`\`\`

&nbsp;

Phải test riêng positive/negative ở mọi biên.

&nbsp;

MITIGATE:

\- cast signed rõ ràng

\- multiply ở width lớn

\- shift sau multiply

\- saturation cuối cùng

\- không reuse một helper chưa chứng minh sign symmetry.

&nbsp;

\#\# R-ARITH-02 — truncation trước saturation

&nbsp;

SYMPTOM: score hoặc weight wrap từ dương lớn thành âm.

&nbsp;

MITIGATE:

&nbsp;

\`\`\`text

wide accumulator

→ clamp/saturate

→ narrow

\`\`\`

&nbsp;

Không narrow trước clamp.

&nbsp;

\#\# R-ARITH-03 — accumulator không đủ rộng

&nbsp;

Q\*/SPEAR 32 feature × int16 có thể vượt score width nếu accumulate trực tiếp.

&nbsp;

DETECT:

\- max-vector test

\- min-vector test

\- random stress against Python golden

&nbsp;

\#\# R-ARITH-04 — update scale nuốt learning

&nbsp;

SYMPTOM: reward có, TD có, nhưng \`dW=0\` gần như mọi hit.

&nbsp;

DETECT:

\- histogram \`nonzero\_update / accepted\_update\`

\- positive và negative riêng

&nbsp;

FAIL nếu \>90% update bị quantize về 0 mà không prereg.

&nbsp;

\#\# R-ARITH-05 — bank mismatch trong Double-Q

&nbsp;

Nguy cơ:

\- eval dùng trung bình A/B nhưng update chỉ bank A

\- debug nhìn \`Q\_eval\` khác hẳn \`Q\_sa\_online\`

&nbsp;

DETECT: log rõ

&nbsp;

\`\`\`text

Q\_A

Q\_B

Q\_eval

online\_bank

Q\_sa\_update

\`\`\`

&nbsp;

Không so sánh các đại lượng khác nghĩa như một score duy nhất.

&nbsp;

\---

&nbsp;

\# 3\. Action / credit identity risks

&nbsp;

\#\# R-CREDIT-01 — update action chưa thực thi

&nbsp;

Hard invariant:

&nbsp;

\`\`\`text

q\_update → action\_participated \== 1

spear\_update → candidate\_selected \== 1

\`\`\`

&nbsp;

Đây là bài học trực tiếp từ QP-15.

&nbsp;

\#\# R-CREDIT-02 — selected-phi bị thay bằng gold-phi

&nbsp;

SYMPTOM: learner học oracle label dù runtime không chọn candidate đó.

&nbsp;

MITIGATE:

\- latch \`phi\_selected\` đúng tại COMMIT

\- pending identity mang selected candidate id

\- test candidate permutation.

&nbsp;

\#\# R-CREDIT-03 — duplicate reward

&nbsp;

Một nút bấm bounce hoặc UART resend có thể train 2–20 lần cùng một event.

&nbsp;

Phải có:

&nbsp;

\`\`\`text

reward\_seq

session\_id

txn\_id

episode\_id

generation

commit\_bit

\`\`\`

&nbsp;

Một reward identity chỉ commit đúng một lần.

&nbsp;

\#\# R-CREDIT-04 — stale reward

&nbsp;

Reward đến sau reset/checkpoint restore không được phép cập nhật policy mới.

&nbsp;

Reject nếu generation/policy-version mismatch.

&nbsp;

\#\# R-CREDIT-05 — terminal cùng cycle với action commit

&nbsp;

Nếu terminal/reward và action commit cùng cycle, nonblocking assignment có thể dùng \`previous\_action\`.

&nbsp;

Test một-step terminal và multi-step terminal riêng.

&nbsp;

\---

&nbsp;

\# 4\. Failure-memory risks

&nbsp;

\#\# R-FEM-01 — failure context bị gộp quá rộng

&nbsp;

Đây là rủi ro quan trọng nhất với ý tưởng “đã bị phạt thì không làm lại”.

&nbsp;

Sai thiết kế:

&nbsp;

\`\`\`text

ACTION\_X failed once

→ blacklist ACTION\_X globally forever

\`\`\`

&nbsp;

Đúng thiết kế:

&nbsp;

\`\`\`text

failure\_signature \=

  context\_signature

\+ goal\_class

\+ action

\+ target/capability

\+ expected\_effect

\+ relevant state bucket

\`\`\`

&nbsp;

Native AI chỉ nên tránh \*\*hành động đã chứng minh xấu trong cùng context đủ tương đồng\*\*, không cấm một primitive trên mọi context.

&nbsp;

\#\# R-FEM-02 — failure lặp lại nhưng policy vẫn thử y hệt

&nbsp;

Phải có \`Failure Avoidance Prior\`:

&nbsp;

\`\`\`text

repeated verified failure

→ negative prior / penalty grows

→ action rank falls

→ probability of repeating falls sharply

\`\`\`

&nbsp;

Sau ngưỡng causal đủ mạnh có thể chuyển:

&nbsp;

\`\`\`text

SOFT\_AVOID → CONTEXT\_VETO

\`\`\`

&nbsp;

nhưng \`CONTEXT\_VETO\` phải versioned/reopen-able.

&nbsp;

\#\# R-FEM-03 — context veto biến thành hard-coded policy

&nbsp;

Không được biến:

&nbsp;

\`\`\`text

if failure\_count \>= N: illegal forever

\`\`\`

&nbsp;

thành luật semantic cố định.

&nbsp;

Context veto là learned procedural memory, không phải ASTRA truth và không phải safety law.

&nbsp;

\#\# R-FEM-04 — compaction xóa bài học

&nbsp;

Sai:

&nbsp;

\`\`\`text

resolved → delete all failure history

\`\`\`

&nbsp;

Đúng:

&nbsp;

\`\`\`text

raw failures

→ compact prototype

→ retain key \+ counts \+ repair skill \+ exemplars

\`\`\`

&nbsp;

\#\# R-FEM-05 — compactor race với writer

&nbsp;

Nếu journal đang ghi mà compactor retire block cùng lúc → mất episode.

&nbsp;

Cần two-phase:

&nbsp;

\`\`\`text

write compact summary

→ CRC/commit ACK

→ mark raw range retireable

→ reclaim later

\`\`\`

&nbsp;

\#\# R-FEM-06 — regression không reopen

&nbsp;

Nếu skill đã ổn định nhưng lỗi cũ quay lại, prototype phải chuyển:

&nbsp;

\`\`\`text

COMPACTED → REOPENED

\`\`\`

&nbsp;

không được bỏ qua vì historical success cao.

&nbsp;

\---

&nbsp;

\# 5\. NCG — Native Cognitive Graph RTL risks

&nbsp;

\#\# R-NCG-01 — Self-ID reuse

&nbsp;

Node bị xóa/compact rồi allocator tái dùng ID trong khi edge cũ còn sống → graph sai semantics.

&nbsp;

Mitigation:

\- generation/version trong NodeID hoặc object header

\- edge exact version match.

&nbsp;

\#\# R-NCG-02 — alias bị hiểu thành identity

&nbsp;

\`HUMAN\_ALIAS="LED3"\` không được thay \`SELF\_ID\`.

&nbsp;

Alias có thể thay đổi, multilingual, conflict; internal identity phải ổn định.

&nbsp;

\#\# R-NCG-03 — duplicate edge explosion

&nbsp;

Cùng observation lặp 1000 lần không tạo 1000 edge giống nhau.

&nbsp;

Use:

&nbsp;

\`\`\`text

edge\_key \= (src, relation, dst, context\_class)

\`\`\`

&nbsp;

Repeated evidence tăng counters/provenance, không nhân edge vô hạn.

&nbsp;

\#\# R-NCG-04 — relation type corruption

&nbsp;

\`CAUSES\`, \`CORRELATES\_WITH\`, \`NAMED\_AS\`, \`ACHIEVES\` có semantics khác nhau.

&nbsp;

Không merge vì cùng src/dst.

&nbsp;

\#\# R-NCG-05 — correlation promoted thành causation

&nbsp;

NCG có thể đề xuất relation; ASTRA/proof layer phải phân biệt:

&nbsp;

\`\`\`text

CORRELATES\_WITH \!= CAUSES

\`\`\`

&nbsp;

Causal edge chỉ promote sau intervention/effect evidence theo contract.

&nbsp;

\#\# R-NCG-06 — purpose edge bị hiểu như truth

&nbsp;

\`ACTION \--ACHIEVES--\> GOAL\` là procedural/utility relation có context, không phải universal fact.

&nbsp;

\#\# R-NCG-07 — adjacency-list overflow

&nbsp;

Một hub concept có thể vượt edge-per-node bound.

&nbsp;

Mitigation:

\- paged adjacency in DDR

\- bounded hot Top-K in BRAM

\- overflow status visible

\- không silently truncate.

&nbsp;

\#\# R-NCG-08 — graph cycle gây traversal lock

&nbsp;

NCG là graph, cycle hợp lệ. Vì vậy traversal hardware phải có:

\- max depth

\- visited signature / generation bitmap hoặc bounded bloom-like check

\- step budget

&nbsp;

Không giả định DAG toàn cục.

&nbsp;

Skill graph có thể yêu cầu DAG; NCG thì không.

&nbsp;

\#\# R-NCG-09 — hash collision trên context signature

&nbsp;

Hash collision không được biến hai failure/edge thành một truth.

&nbsp;

Hash chỉ dùng index; exact key/header phải verify trước update.

&nbsp;

\#\# R-NCG-10 — stale edge after capability manifest change

&nbsp;

Nếu pin/capability ABI thay đổi, relation gắn old capability version phải bị invalid hoặc migrate rõ.

&nbsp;

\---

&nbsp;

\# 6\. Skill/options risks

&nbsp;

\#\# R-SKILL-01 — recursion/cycle vô hạn

&nbsp;

Skill A gọi B, B gọi A.

&nbsp;

Cần:

\- max call depth

\- active skill bitmap

\- cycle reject at promotion/load.

&nbsp;

\#\# R-SKILL-02 — skill vượt max\_steps

&nbsp;

Must terminate with explicit status:

&nbsp;

\`\`\`text

SKILL\_BUDGET\_EXHAUSTED

\`\`\`

&nbsp;

không giả ANSWER/UNKNOWN.

&nbsp;

\#\# R-SKILL-03 — stale skill version

&nbsp;

Pending episode phải bind exact skill version.

&nbsp;

\#\# R-SKILL-04 — per-ID memorization

&nbsp;

Nếu skill học LED3 bằng ID literal và fail LED2/LED4 cùng class → không chứng minh skill generalization.

&nbsp;

Test index permutation/unseen instance.

&nbsp;

\---

&nbsp;

\# 7\. FSM / handshake / FIFO risks

&nbsp;

\#\# R-PROTO-01 — level dùng như pulse

&nbsp;

Đây là lớp lỗi từng gây duplicate command trong các hệ trước.

&nbsp;

Sai:

&nbsp;

\`\`\`text

go=1 nhiều cycle

write\_enable \= go && \!full

\`\`\`

&nbsp;

Đúng:

\- one-shot edge/accepted handshake

\- sequence id

\- assertion \`one request → one commit\`.

&nbsp;

\#\# R-PROTO-02 — VALID/READY payload thay đổi khi stalled

&nbsp;

Assertion:

&nbsp;

\`\`\`text

valid && \!ready → payload stable

\`\`\`

&nbsp;

\#\# R-PROTO-03 — FIFO overflow bị che

&nbsp;

Overflow phải sticky/export status. Không được trả “empty” khi thực chất dropped data.

&nbsp;

\#\# R-PROTO-04 — FIFO underflow

&nbsp;

No read when empty; flag protocol fault.

&nbsp;

\#\# R-PROTO-05 — nonblocking stale-state

&nbsp;

FSM đọc register vừa assign cùng block có thể lấy cycle cũ.

&nbsp;

Review all state transitions using explicit \`next\_\*\` where data dependency exists.

&nbsp;

\---

&nbsp;

\# 8\. BRAM / memory inference risks

&nbsp;

\#\# R-BRAM-01 — synchronous read latency bị bỏ qua

&nbsp;

Vivado BRAM thường read data trễ 1 cycle hoặc hơn theo config.

&nbsp;

Python/combinational model rất dễ khác RTL.

&nbsp;

\#\# R-BRAM-02 — read-during-write mode mismatch

&nbsp;

WRITE\_FIRST / READ\_FIRST / NO\_CHANGE phải pin rõ trong contract.

&nbsp;

\#\# R-BRAM-03 — dual-port collision

&nbsp;

Q\* update và evaluator đọc cùng weight address có thể tạo nondeterminism.

&nbsp;

Dùng phase ownership hoặc collision assertion.

&nbsp;

\#\# R-BRAM-04 — unintended LUTRAM

&nbsp;

Small arrays có thể infer distributed RAM làm LUT tăng mạnh.

&nbsp;

OOC synthesis kiểm RAM primitive được infer.

&nbsp;

\---

&nbsp;

\# 9\. DDR3 / MIG risks

&nbsp;

\#\# R-DDR-01 — use before \`init\_calib\_complete\`

&nbsp;

Hard block all semantic DDR traffic trước calibration complete.

&nbsp;

\#\# R-DDR-02 — byte address vs beat address

&nbsp;

Centralize address conversion. Không cho từng module tự shift riêng.

&nbsp;

\#\# R-DDR-03 — 128-bit beat packing / endian mismatch

&nbsp;

Golden pack/unpack bắt buộc.

&nbsp;

\#\# R-DDR-04 — command/data handshake assumed simultaneous

&nbsp;

MIG address command và write-data channel phải được xử lý độc lập theo interface thực.

&nbsp;

\#\# R-DDR-05 — burst crosses region/page boundary

&nbsp;

Memory map checker phải xác nhận mọi record không ghi qua vùng khác.

&nbsp;

\#\# R-DDR-06 — region overlap

&nbsp;

Generate memory map from one source-of-truth; CI check no overlaps.

&nbsp;

\#\# R-DDR-07 — compaction copy partial

&nbsp;

Không reclaim source until destination CRC \+ commit pointer complete.

&nbsp;

\---

&nbsp;

\# 10\. CDC / button / UART risks

&nbsp;

\#\# R-CDC-01 — async button metastability

&nbsp;

2FF synchronizer \+ debounce \+ one-shot.

&nbsp;

\#\# R-CDC-02 — button bounce tạo nhiều reward

&nbsp;

Test physical-like bounce waveform, không chỉ clean pulse.

&nbsp;

\#\# R-CDC-03 — pulse crossing lost

&nbsp;

Use toggle/handshake for reward/event across unrelated clocks.

&nbsp;

\#\# R-UART-01 — framing/CRC drift

&nbsp;

Parser cần:

\- magic/version

\- length

\- sequence

\- CRC

\- timeout/recovery.

&nbsp;

\#\# R-UART-02 — teacher authority leak

&nbsp;

UART reward frame không chứa hidden winner trong autonomous lane.

&nbsp;

\---

&nbsp;

\# 11\. Reset / checkpoint / persistence risks

&nbsp;

\#\# R-STATE-01 — reset chỉ xóa bank A, không bank B

&nbsp;

Cold-reset image compare phải cover toàn learner state.

&nbsp;

\#\# R-STATE-02 — partial checkpoint commit

&nbsp;

Use A/B slots:

&nbsp;

\`\`\`text

write inactive

→ verify CRC/hash

→ atomically flip generation pointer

\`\`\`

&nbsp;

\#\# R-STATE-03 — restore policy nhưng không restore FEM/skill versions

&nbsp;

Có thể làm policy tham chiếu memory semantics khác.

&nbsp;

Checkpoint manifest phải bind:

\- Q\* version

\- SPEAR version

\- NCG version

\- skill table version

\- FEM prototype epoch

\- capability manifest version.

&nbsp;

\---

&nbsp;

\# 12\. ASTRA / GEMINI authority risks

&nbsp;

\#\# R-AUTH-01 — learned score override legality

&nbsp;

Assertion:

&nbsp;

\`\`\`text

commit → legal\_mask\[action\] \== 1

\`\`\`

&nbsp;

\#\# R-AUTH-02 — GEMINI output commits actuator

&nbsp;

Forbidden. Language proposal phải quay qua typed command/ASTRA/safety path nếu có action.

&nbsp;

\#\# R-AUTH-03 — failure count becomes truth

&nbsp;

\`100 failures\` không tự chứng minh semantic proposition false.

&nbsp;

FEM \= procedural experience; ASTRA \= truth/proof authority.

&nbsp;

\#\# R-AUTH-04 — purpose explanation invents missing edge

&nbsp;

GEMINI chỉ diễn đạt purpose trace tồn tại trong NCG/goal graph. Không tự bịa WHY.

&nbsp;

\---

&nbsp;

\# 13\. Synthesis / implementation / timing risks

&nbsp;

\#\# R-RES-01 — accidental parallel multiplier replication

&nbsp;

Một \`for\` loop score 32 feature có thể infer 32 multiplier.

&nbsp;

Prefer shared/sequential MAC.

&nbsp;

Gate mỗi module bằng OOC report:

\- LUT

\- FF

\- BRAM

\- DSP

\- inferred multiplier count

\- RAM primitives.

&nbsp;

\#\# R-RES-02 — fanout explosion

&nbsp;

Global legal mask/version/reset may become high fanout. Register replicate deliberately; inspect high-fanout nets.

&nbsp;

\#\# R-TIME-01 — unconstrained CDC gives fake PASS

&nbsp;

Run clock-interaction/CDC audit. Zero unconstrained semantic paths.

&nbsp;

\#\# R-TIME-02 — multicycle exception hides real violation

&nbsp;

Exceptions minimal, documented, reviewed against protocol.

&nbsp;

\#\# R-RESET-01 — async deassert timing

&nbsp;

Synchronize reset release per clock domain.

&nbsp;

\#\# R-IO-01 — actuator glitch during config/reset

&nbsp;

Outputs default safe before learned core enabled.

&nbsp;

\---

&nbsp;

\# 14\. Mandatory assertions

&nbsp;

Minimum assertion set:

&nbsp;

\`\`\`text

assert \!(commit && \!legal);

assert \!(reward\_accept && \!pending\_valid);

assert \!(q\_update && \!action\_participated);

assert \!(spear\_update && \!candidate\_selected);

assert \!(exam\_mode && exploration\_enable);

assert \!(fifo\_wr && fifo\_full);

assert \!(fifo\_rd && fifo\_empty);

assert \!(skill\_call && skill\_cycle\_detected);

assert \!(fem\_retire\_raw && \!compact\_commit\_verified);

assert \!(ncg\_edge\_update && \!exact\_key\_match\_after\_hash\_lookup);

\`\`\`

&nbsp;

Protocol assertions:

&nbsp;

\`\`\`text

valid && \!ready → payload stable

accepted\_request → exactly\_one\_commit

accepted\_reward  → exactly\_one\_update\_event

\`\`\`

&nbsp;

\---

&nbsp;

\# 15\. Failure-avoidance policy — LOCK CANDIDATE

&nbsp;

Ý tưởng quan trọng cần giữ:

&nbsp;

\> Failure không chỉ để phân tích sau này. Một failure đã được xác nhận phải ảnh hưởng trực tiếp đến xác suất lựa chọn hành động tương lai.

&nbsp;

Nhưng phải context-aware.

&nbsp;

Đề xuất ba tầng:

&nbsp;

\`\`\`text

LEVEL 0 — NEW

no avoidance

&nbsp;

LEVEL 1 — SOFT\_AVOID

1–2 verified failures

negative prior added

&nbsp;

LEVEL 2 — STRONG\_AVOID

repeated same-context failures

candidate/action strongly demoted

&nbsp;

LEVEL 3 — CONTEXT\_VETO

high-confidence repeated causal failure

exclude action only for matching context signature

\`\`\`

&nbsp;

Reopen conditions:

&nbsp;

\`\`\`text

context changed materially

capability/skill version changed

explicit relearn mode

controlled sparse re-probe

regression investigation

\`\`\`

&nbsp;

Không bao giờ biến một learned failure thành global permanent blacklist trừ khi đó là deterministic safety rule riêng.

&nbsp;

\---

&nbsp;

\# 16\. Pre-board fail-fast checklist

&nbsp;

Không PROGRAM nếu bất kỳ mục nào sau fail:

&nbsp;

\`\`\`text

\[ \] codec/reference bit-exact

\[ \] signed update property PASS

\[ \] no unexecuted-action credit

\[ \] reward duplicate/stale tests PASS

\[ \] BRAM latency modeled

\[ \] no FIFO hidden overflow

\[ \] DDR map overlap \= 0

\[ \] checkpoint atomicity PASS

\[ \] FEM compaction loss test PASS

\[ \] NCG exact-key/hash-collision tests PASS

\[ \] NCG traversal bounded

\[ \] skill cycle/max-step tests PASS

\[ \] host semantic authority \= 0

\[ \] ASTRA legality veto PASS

\[ \] EXAM deterministic

\[ \] OOC resource shape expected

\[ \] WNS \>= 0, TNS \= 0, hold clean

\`\`\`

&nbsp;

Board là nơi xác nhận silicon, không phải nơi đầu tiên để tìm lỗi logic cơ bản.

&nbsp;