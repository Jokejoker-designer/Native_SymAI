\# 04 — FAILURE EXPERIENCE MEMORY AND COMPACTION

&nbsp;

Package: NATIVE\_AI\_DEVELOPMENTAL\_HARDWARE\_R1

Status: Forward design candidate / research architecture

Target: Arty A7-100T / bounded FPGA-native learning

Historical rule: không ghi đè R2/R3, không reinterpret evidence cũ, không tự tạo BOARD\_PASS.

&nbsp;

\#\# 1\. Mục tiêu

&nbsp;

Failure Experience Memory (FEM) là lớp ghi nhớ kinh nghiệm thất bại có cấu trúc của Native AI. Mục tiêu không phải lưu log vô hạn, mà biến failure lặp lại thành bài học có provenance, sau đó nén lịch sử thô nhưng vẫn giữ đủ thông tin để biết hệ thống đã sai ở đâu, lỗi nào còn mở, lỗi nào đã được sửa, skill/version nào đã sửa, mất bao nhiêu lần mới học được, và lỗi cũ có quay lại hay không.

&nbsp;

Nguyên tắc khóa:

&nbsp;

\> Failure không bị xóa đơn giản. Failure được chuyển từ raw experience thành compacted lesson.

&nbsp;

FEM không có quyền chọn action, override Q\*, override SPEAR, promote semantic truth, sửa ASTRA proof legality hoặc cho host gán winner. FEM chỉ quản lý lifecycle của kinh nghiệm.

&nbsp;

\#\# 2\. Vị trí trong kiến trúc

&nbsp;

PHYSICAL WORLD / BOARD

→ Primitive Executor

→ Observed Effect

→ ASTRA legality/effect verification

→ Episode / Trajectory

→ Reward / Penalty

→ FEM: capture → cluster → resolve → compact → reopen on regression

→ Q\*/SPEAR learning \+ Skill Memory \+ Native Cognitive Graph (NCG)

&nbsp;

FEM có thể tạo typed relations trong NCG, ví dụ:

&nbsp;

FAILURE\_27 \--FAILED\_AT--\> LED\_OUTPUT\_STAGE

FAILURE\_27 \--INVOLVES--\> CAP\_LED\_3

FAILURE\_27 \--RESOLVED\_BY--\> SKILL\_12

&nbsp;

Nhưng NCG/FEM không tự biến relation đó thành ASTRA truth.

&nbsp;

\#\# 3\. Phân loại failure

&nbsp;

Mỗi failure phải có ít nhất hai chiều phân loại.

&nbsp;

Domain ví dụ:

LED, LCD, UART, GPIO, MEMORY, DDR, SEARCH, RANKING, SKILL, PROOF, ENCODING, SENSOR, CHECKPOINT, CONTROL.

&nbsp;

Stage ví dụ:

SELECT, BIND, ENCODE, ISSUE, WRITE, READ, READBACK, VERIFY, COMPARE, TERMINATE, PROMOTE, RESTORE.

&nbsp;

Ví dụ LCD/ENCODING khác bản chất với LCD/DEVICE\_WRITE và không được cluster chung.

&nbsp;

\#\# 4\. Raw Failure Record

&nbsp;

FailureRecord {

  episode\_id

  step\_id

  tick

  domain

  stage

  capability\_id

  capability\_class

  capability\_instance

  macro\_action

  primitive\_action

  candidate\_id

  skill\_id

  skill\_version

  expected\_effect

  observed\_effect

  error\_code

  reward

  state\_signature

  action\_signature

  effect\_signature

  q\_policy\_version

  spear\_policy\_version

  corpus\_epoch

  capability\_manifest\_version

  source

  crc

}

&nbsp;

source phân biệt AUTONOMOUS, HUMAN\_DEMO, UART\_TEACHER, BOARD\_TEST.

reward là scalar evaluation, không phải truth.

&nbsp;

\#\# 5\. Typed Failure Key

&nbsp;

Không cluster bằng raw text hoặc exact ID. Khóa đề xuất:

&nbsp;

prototype\_key \= hash(domain, stage, capability\_class, macro\_action\_class, primitive\_class, effect\_class, context\_bucket)

&nbsp;

context\_bucket không nên chứa exact candidate/episode nếu mục tiêu là transfer.

&nbsp;

Ví dụ tốt:

DIGITAL\_OUT \+ WRITE \+ EXPECT\_ON \+ OBS\_OFF \+ HIGH\_LOAD\_CONTEXT

&nbsp;

Ví dụ xấu:

LED3 \+ episode\_918 \+ candidate\_1004

&nbsp;

\#\# 6\. Failure lifecycle

&nbsp;

RAW\_FAILURE

→ repeated / matching signature

CLUSTERED\_FAILURE

→ corrective behavior begins succeeding

RESOLVED\_FAILURE

→ stable success window

COMPACTED\_EXPERIENCE

&nbsp;

Nếu lỗi quay lại:

COMPACTED\_EXPERIENCE → REOPENED\_FAILURE

&nbsp;

\#\# 7\. Failure Prototype

&nbsp;

FailurePrototype {

  prototype\_id

  prototype\_key

  domain

  stage

  capability\_class

  action\_class

  effect\_class

  first\_seen\_episode

  last\_seen\_episode

  last\_failure\_episode

  failure\_total

  failure\_recent

  success\_after\_repair

  regression\_count

  unresolved

  compacted

  repair\_skill\_id

  repair\_skill\_version

  exemplar\_ids\[small\_k\]

  mean\_recovery\_steps

  mean\_failure\_cost

  version

  crc

}

&nbsp;

\#\# 8\. Compaction

&nbsp;

Compaction giảm footprint nhưng không xóa bài học.

&nbsp;

Trước: hàng chục raw failure/success episode.

Sau: một prototype giữ failure\_total, success\_after\_repair, repair skill/version, last failure, regression count, state/effect signature và một vài exemplar IDs.

&nbsp;

Thứ tự commit bắt buộc:

1\. Build prototype summary.

2\. Write prototype vào target DDR region.

3\. Verify CRC.

4\. Mark prototype COMMITTED.

5\. Update index.

6\. Chỉ sau đó mới retire raw records đủ điều kiện.

&nbsp;

Không retire raw record trước khi summary commit thành công.

&nbsp;

\#\# 9\. Thresholds R1 đề xuất

&nbsp;

CLUSTER\_MIN\_FAILURES \= 3 hoặc 4

RESOLVE\_MIN\_SUCCESSES \= 4

COMPACT\_MIN\_SUCCESSES \= 16

REGRESSION\_WINDOW \= 16–64 executions

HOT\_CACHE\_ENTRIES \= 32–64

EXEMPLARS\_PER\_PROTOTYPE \= 2–4

&nbsp;

Đây là engineering defaults, phải versioned, không phải semantic truth.

&nbsp;

\#\# 10\. BRAM / DDR

&nbsp;

BRAM giữ hot state:

\- 32–64 active prototypes;

\- unresolved failure cache;

\- compactor staging;

\- counters;

\- recent exemplar pointers;

\- regression window.

&nbsp;

Budget ban đầu: khoảng 2–4 BRAM36 cho FEM lane.

&nbsp;

DDR giữ:

\- raw failure journal;

\- episode references;

\- compacted prototypes;

\- resolved lessons;

\- repair skill linkage;

\- regression history.

&nbsp;

Forward V2 map candidate:

0x0900\_0000–0x0BFF\_FFFF: episodic \+ raw failure journal

0x0C00\_0000–0x0CFF\_FFFF: compacted skill/failure/procedural memory

&nbsp;

Không áp map này lên V1 frozen nếu chưa có migration gate riêng.

&nbsp;

\#\# 11\. Reward integration

&nbsp;

Penalty/reward có thể đến từ button, UART teacher hoặc ASTRA-verified outcome. FEM phải lưu reward\_source để phân biệt human evaluation, environment reward và benchmark harness.

&nbsp;

Teacher được phép gửi scalar reward nhưng không được gửi winner\_action, winner\_candidate hoặc weight\_delta trong autonomous lane.

&nbsp;

\#\# 12\. Causal failure attribution

&nbsp;

Chỉ attribute điều hardware provenance biết chắc.

&nbsp;

Ví dụ:

Q\*: OUTPUT

SPEAR: CAP\_03

Primitive: WRITE(1)

Readback: 0

&nbsp;

Có thể ghi:

DOMAIN \= DIGITAL\_OUT

STAGE \= WRITE\_OR\_EFFECT

&nbsp;

Không được tự kết luận "LED bị hỏng" nếu chưa có proof. ASTRA có thể giữ fact quan sát: expected 1, observed 0; physical cause vẫn UNKNOWN.

&nbsp;

\#\# 13\. Metrics đo tiến bộ

&nbsp;

failure\_rate \= failures / episodes

repeat\_failure\_rate \= repeated\_failures / failures

recovery\_length \= actions từ failure đến recovery hợp lệ

regression\_rate \= reopened / compacted

compaction\_ratio \= raw\_bytes / compacted\_bytes

failure\_entropy \= diversity của prototype

stable\_skill\_coverage \= stable\_skills / learned\_skills

&nbsp;

Các metric này cho phép vẽ learning curve thực từ hardware, không chỉ dashboard trang trí.

&nbsp;

\#\# 14\. Failure-aware curriculum

&nbsp;

Training scheduler có thể dùng summary từ FEM:

&nbsp;

priority \= w1\*recent\_failure\_rate \+ w2\*unresolved\_count \+ w3\*novelty \+ w4\*regression\_flag \+ w5\*learning\_progress \- w6\*stable\_success

&nbsp;

Tất cả dùng integer bounded. FEM không tự chọn macro action; nó chỉ cung cấp summary feature/curriculum signal.

&nbsp;

\#\# 15\. Interaction với NCG

&nbsp;

NCG có thể lưu:

CAP\_17 \--HAS\_FAILURE\_PATTERN--\> FP\_4

FP\_4 \--RESOLVED\_BY--\> SKILL\_9

SKILL\_9 \--ACHIEVES--\> EFFECT\_2

&nbsp;

Mỗi relation phải có provenance/state như OBSERVED, INFERRED, VERIFIED. ASTRA quyết định promotion.

&nbsp;

\#\# 16\. RTL architecture

&nbsp;

failure\_event\_ingress

→ key\_builder

→ hot\_prototype\_cache

→ prototype\_update

→ compaction\_controller

→ DDR journal/index writer

&nbsp;

Chỉ một owner được sửa một prototype tại một thời điểm. Pha đề xuất:

CAPTURE → UPDATE\_CACHE → OPTIONAL\_FLUSH → COMPACT → RETIRE.

&nbsp;

\#\# 17\. RTL risks FEM

&nbsp;

Phải test trước:

\- lost failure event do FIFO full;

\- duplicate event do pulse kéo dài;

\- key collision;

\- counter wrap;

\- BRAM read-after-write hazard;

\- retire raw trước summary commit;

\- stale repair\_skill\_version;

\- regression reopen sai prototype;

\- journal wrap overwrite unresolved;

\- endian mismatch pack/unpack;

\- CRC mismatch bị bỏ qua;

\- reset mất unresolved cache chưa flush.

&nbsp;

Counters nên saturate thay vì wrap.

&nbsp;

\#\# 18\. Verification plan

&nbsp;

FEM-01 Capture: một failure → đúng một record.

FEM-02 Cluster: 4 failure cùng typed key → một prototype, failure\_total=4.

FEM-03 Separation: khác stage không cluster chung.

FEM-04 Resolve: sau repair và stable success → RESOLVED.

FEM-05 Compact: raw N records → compact representation nhỏ hơn, không mất provenance thiết yếu.

FEM-06 Regression: failure cũ quay lại → REOPENED, regression\_count tăng.

FEM-07 Power-loss simulation: cắt transaction ở mọi bước compaction; không mất cả raw lẫn prototype.

FEM-08 Authority: FEM count cao không được override ASTRA UNKNOWN/CONFLICT.

&nbsp;

\#\# 19\. Acceptance gate

&nbsp;

FEM\_R1\_PASS chỉ khi:

CAPTURE\_CAUSAL \= PASS

CLUSTER\_TYPED \= PASS

COMPACTION\_NO\_DATA\_LOSS \= PASS

REGRESSION\_REOPEN \= PASS

ASTRA\_AUTHORITY\_PRESERVED \= PASS

HOST\_SEMANTIC\_AUTHORITY \= 0

DDR\_PERSISTENCE \= PASS

RESET\_RESTORE \= PASS

&nbsp;

\#\# 20\. Claim được phép

&nbsp;

Nếu gate đạt, claim cho phép:

&nbsp;

"Native AI stores typed failure experience, consolidates repeated failures into compact procedural prototypes, preserves causal provenance, and can reopen resolved failures on regression."

&nbsp;

Không claim self-awareness, emotion, human memory, autonomous truth discovery hoặc AGI.

&nbsp;

\#\# 21\. Kết luận

&nbsp;

FAIL → remember → repeat → cluster → learn → succeed → resolve → compact → reuse lesson → reopen if regression.

&nbsp;

FEM biến continual learning thành quá trình có thể audit bằng số liệu phần cứng: hệ thống đã sai gì, mất bao nhiêu lần để học, skill nào sửa lỗi, memory đã nén bao nhiêu và lỗi cũ có tái diễn hay không.

&nbsp;