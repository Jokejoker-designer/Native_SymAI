NATIVE AI DEVELOPMENTAL HARDWARE R1
STATUS: RESEARCH / FORWARD DESIGN CANDIDATE
Target: Digilent Arty A7-100T / XC7A100T-CSG324-1
Date: 2026-09-14
MỤC TIÊU
Package này gom toàn bộ hướng kiến trúc “innate substrate + learned skills” cho Native AI. Hệ thống sinh ra đã biết nó có những capability/primitive nào, biết kiểu dữ liệu, phép toán, codec và legality cơ bản; còn ý nghĩa, skill, strategy và cách phối hợp primitive phải được học từ tương tác thật, demonstration và reward.
Kiến trúc đích:
Native Substrate / Affordance Fabric
→ Primitive Executor
→ Skill / Option Layer
→ Q* macro planner
→ SPEAR micro ranker
→ ASTRA proof / legality / truth authority
→ GEMINI expression / language
Song song:
physical effect
→ reward/penalty từ button hoặc UART teacher
→ trajectory
→ Q*/SPEAR update
→ Failure Experience Memory
→ resolve → compact → procedural memory
RANH GIỚI AUTHORITY
- Host semantic authority = 0.
- Q* chọn macro action.
- SPEAR xếp hạng target/candidate trong action đã chọn.
- ASTRA giữ legality/proof/truth/status/promotion.
- GEMINI chỉ diễn đạt; không tự tạo truth và không lái actuator trực tiếp.
- Reward có thể đến từ nút bấm hoặc UART teacher nhưng teacher không ghi weight trực tiếp.
- Action chưa thực thi không nhận credit trong causal lane đầu tiên.
- SEARCH_INCOMPLETE != UNKNOWN.
- Score không override proof legality.
- Candidate, episode và failure memory không tự trở thành promoted fact.
BÀI HỌC QUY TRÌNH
ASTRA hiện tại bị chậm một phần vì số lượng gate/bag/process quá nhiều. R1 rút gọn mỗi milestone còn một pipeline duy nhất:
SPEC → Python/reference gold → RTL unit → XSim integration → OOC synth/timing → BOARD chỉ khi silicon evidence thật sự cần.
Mỗi milestone chỉ bắt buộc bốn artifact:
1. CONTRACT.md
2. RESULT.json
3. EVIDENCE.md
4. SHA256SUMS.txt
Không tạo sub-gate mới nếu không có một câu hỏi causal mới.
CẤU TRÚC TÀI LIỆU
01_MASTER_ARCHITECTURE — phân vùng bộ não, authority, dataflow.
02_MEMORY_BRAM_DDR — bố trí hot/cold memory và DDR map candidate.
03_ALGORITHMS — Q*, SPEAR, options/skill, n-step credit, affordance, curriculum.
04_FAILURE_MEMORY — Failure Experience Memory, compaction, regression reopen.
05_SKILL_AND_TEACHING — skill descriptor, button/UART teaching, primitive vs semantics.
06_MILESTONES — roadmap 8 giai đoạn, rút gọn process.
07_TEST_AND_CAUSAL_BENCH — test matrix và generalization/anti-memorization.
08_RTL_RISK_REGISTER — lỗi RTL dự trù trước khi lên board.
09_IMPLEMENTATION_START — prompt thực thi cho agent/Cursor.
HISTORY POLICY
Package này không thay thế R2/R3, không ghi đè historical evidence, không tự stamp BOARD_PASS. V1/V2 frozen evidence vẫn là nguồn sự thật cho các claim đã chứng minh.