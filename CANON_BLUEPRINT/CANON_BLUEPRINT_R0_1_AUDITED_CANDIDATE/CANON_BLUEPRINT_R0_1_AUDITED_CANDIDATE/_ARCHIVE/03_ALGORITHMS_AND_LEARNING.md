03 — ALGORITHMS AND LEARNING
1. NATIVE SUBSTRATE ISA
Đây là lớp “body schema” cố định, nói cho hệ thống biết nó có gì và primitive nào hợp lệ. Descriptor nên chứa cap_id, class, instance, width, access flags, primitive mask, ready, safety class, latency/cost bucket, effect schema, precondition mask, executor index, version.
Manifest tuyệt đối không chứa preferred_action, gold_action, winner_candidate, if_incomplete_search hoặc semantic mapping kiểu LED3=SUCCESS.
Primitive nền:
- GPIO_READ/WRITE/TOGGLE, BUTTON_READ, RGB_SET
- UART_TX/RX byte
- MEM_READ/WRITE, FIFO_PUSH/POP, checkpoint I/O
- ADD/SUB/COMPARE, AND/OR/XOR/NOT, SHIFT, MASK, PACK/UNPACK, SATURATE
- binary/int/hex/ASCII/BCD codecs, CRC/checksum
- ENUM_LEGAL, OBSERVE_EFFECT, COMMIT_ACTION, SUBMIT_TO_ASTRA
2. Q* — MACRO PLANNER
Giữ Double Linear-Q + bounded best-first. 32 feature, action set nhỏ, int16 weights, accumulator >=32 bit, shared sequential MAC. Q* học “bước lớn tiếp theo là gì”, không giữ proof authority.
3. SPEAR — MICRO RANKER
Giữ linear contextual scorer + fixed-point SGD + selected-candidate-phi-only update. TRAIN có exploration; EXAM deterministic. SPEAR chỉ sắp target/candidate bên trong action đã chọn.
R3 đã chứng minh ranking có causal value: gold rank 5→1, FIRST_ONLY 0→1, SCAN 40→8, reads-to-gold 5→1. Không được gọi đó là truth confidence.
4. SKILL / OPTIONS
Dùng constrained options/MAXQ-style hierarchy: initiation/precondition, bounded policy/sequence, termination, effect, cost, version. Không dùng Option-Critic ở R1 vì quá nhiều degree of freedom và khó RCA trên FPGA.
5. QP-16 MULTI-STEP EXECUTED-ACTION CREDIT
Chuyển episode 1-step thành trajectory thật:
s0→a0→s1→a1→...→terminal.
Lưu 16 bước trước, stretch 32. Sau terminal tính bounded backward/n-step return. Chỉ action thực sự executed/participated mới được update.
Invariant:
unexecuted action → ΔW=0.
Case PASS bắt buộc:
A. SEARCH đã execute và sau đó ANSWER → SEARCH nhận positive delayed return.
B. SEARCH không execute → ΔW_SEARCH=0.
C. reset W0 trả behavior cũ, restore W1 trả behavior học.
6. EXPLORATION
Ưu tiên epsilon-greedy + count/novelty bonus + diagonal uncertainty nhỏ. Không triển khai full covariance LinUCB/Thompson trong RTL đầu tiên.
7. AFFORDANCE EFFECT STATISTICS
Track theo capability class/primitive/context bucket: success count, failure count, mean latency, mean cost. Đây là execution usefulness, không phải ASTRA truth confidence.
8. FAILURE-DRIVEN CURRICULUM
Training scheduler có thể ưu tiên bằng integer score:
priority = w1*recent_failure_rate + w2*novelty + w3*abs(learning_progress) + w4*regression_flag - w5*stable_success.
Mục đích: skill đã ổn định giảm training bandwidth; repeated failure/regression được ưu tiên.
9. FIXED-POINT GUARDRAILS
Bắt buộc property tests:
phi>0 & delta>0 → dw>=0
phi>0 & delta<0 → dw<=0
phi=0 → dw=0
unexecuted action → no Q update
unselected candidate → no SPEAR credit
Phải kiểm tra positive/negative quantization độc lập để tránh lặp lại lỗi SP-14: positive bị shift về 0 trong khi negative vẫn -1.
10. TRAIN vs EXAM
TRAIN: exploration on, learning on, reward input accepted.
EXAM: exploration off, weights frozen, deterministic tie-break; same initial state must produce bit-identical trajectory.
11. THUẬT TOÁN HOÃN LẠI
- deep world model / Dreamer / MuZero
- DQN + replay buffer
- full Option-Critic
- dense transformer planner
- full Bayesian network
- full covariance Thompson/LinUCB
- RND/ICM neural curiosity
- dynamic partial reconfiguration
Lý do: tăng verification/resource burden nhanh hơn giá trị hiện tại trên A7.