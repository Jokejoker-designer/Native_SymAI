# SINGLE_BOARD_GOAL_PLAN

GOAL_PLAN_PATH: D:/FPGA/Native_SymAI/docs/audits/20260922_astra_discovery/SINGLE_BOARD_GOAL_PLAN.md
STATUS: JA_LOOPBACK_ABA_UART_MATCH
NEXT_CUT: PROOF_R1_XSIM_CANDIDATE_NOT_ON_BOARD
ARCHITECTURE: RESOLVE_THEN_DECIDE. Evidence unit is the T2 EdgeRecord addressed by the posting edge_ref. neighbor_id and end_id are not that record. Walker remains traversal control and reports scope observables. A resolver reads the edge. ASTRA alone emits status. VERIFIED stays on the edge in T2. Provenance is carried as provenance_ref and read only when QueryRecord flags bit1 requires it or an ANSWER proof is being assembled. Completeness is declared scope closed under search_budget, owned by the query scope tracker, consumed by ASTRA. Support-chain-as-edge_ref-list is withdrawn: §2.4.8 edge_ref is a T2 byte address, not edge identity. §2.2 names T2 Proof artifacts and §2.1 places PROOF as T1 scratch and T2 archive, with no binary layout and no required archive lifecycle. Depth 3 is not Canon. ProofHeader and ProofStep widths stay unfrozen. ProofObject is query-lifetime in T1 over persistent T2 evidence. 2026-09-23 owner authorized the workstream. knowledge_state R1 opcodes are 0xC1 CANDIDATE through 0xC4 VERIFIED, 0xC5 REJECTED, 0xC6 CONFLICTED. SupportKey is the semantic tuple, not edge_ref. query_id is the retained 32-byte QueryRecord, not txn_id. proof_ref is a semantic id valid only with a recoverable body. R1 retention is the result payload. VALUE answers are NOT_READY. XSim candidate proof_path_r1 is not on the JA image. G2 stays the action CRC page. No ANSWER. No program.
PROOF_ORIGIN: Audit 2026-09-23. Canon §3.3 names seven ProofObject fields and no binary layout, width, ProofHeader, ProofStep, allocator, or lifetime. T1 names proof scratch without an address. T2 has Node, Edge, Provenance, and Edge.knowledge_state, and no ProofObject record. G2 payload is a 48-byte CRC stimulus: directory, header, spear descriptor. f2a071fe is the solved candidate_ref in that spear word, not a verified answer and not a ProofObject. Live walker outputs are hit, end_id, count, hops. first_edge_ref is dropped inside bounded_walk and no EdgeRecord is read. FE256 gold proof_id 0x060100+i is an oracle integer on an in-memory Edge. FE-DIRECT-001 answer_ref 0x20100 proof_ref 0x60100 has no proof bytes. astra_edge_qeval copies that integer and is XSim-only. ANSWER_PATH_NOT_READY. Do not emit ANSWER. Do not change G2. Do not program.
XSIM_CHAIN_NOTE: CUT12 through CUT26 answered the questions simulation can answer. Do not add another prior-plus-one identity. Do not program arty_a7_g2_closed. CUT27 replaces the switch and the counter with an output pin and a separate input pin. A raw copied 1 is not stored as the effect, because it equals primitive 1. FEM receives event code 4 only after the synchronized input matches the drive and differs from a low baseline. Code 4 is not a pin voltage. The closed arm in that log is a testbench wire. It is not the copper jumper. RTL simulation does not prove the weak pulldown.
PIN_LOCK: CONNECTOR_PIN JA1 = PACKAGE_PIN G13 = RTL_PORT effect_drive. CONNECTOR_PIN JA2 = PACKAGE_PIN B11 = RTL_PORT effect_sense. Module g2_ja_loop_r1. Do not name the physical pin by HDL index ja[0] or ja[1] alone. Local master SHA256 7396974dfcc998d337494c97d4d42bddb45e76090d67ff6463d26deec15d254c. Header says Arty A7-100 Rev. D. Master comment Sch=ja[1] is on G13. Master comment Sch=ja[2] is on B11.
SENSE_BIAS: PULLTYPE PULLDOWN on effect_sense. Deprecated PULLDOWN TRUE is not the lock.
PROGRAM_GATE: PCB silkscreen reads REV E. Owner asked the manufacturer: the schematic revision is E.2. Pin lock stays JA1=G13=effect_drive and JA2=B11=effect_sense. Bit SHA256 e2d971512c519471541ac81e4b83eb41d77cf1b48d79092325e0b3e40b6c9349. WNS=0.279 WHS=0.024. TIMING_PASS=NO. Programmed once, End of startup HIGH, PROGRAM.DONE=NA, PROGRAM_PASS=NO. Open arm UART words f2a071fe 0000c001 00000101 with JA empty. Do not rebuild. Next change is only the JA1-JA2 jumper.
QUERY_STATUS_NOTE: Mux 0x04 on this path is a no-answer placeholder. It is not a Canon search.
ABI_SPLIT: Audit 2026-09-23. Current wire authority is 04_ABI_AND_PROTOCOL.md §4.4 and §4.12, also copied in MASTER_CANON_BLUEPRINT_R0_1.md §4.4: 48 bytes, magic 0x4E52 first. fe256_gold.py packs that order, CRC16 over bytes 0..45. query_result_bind.sv uses the same byte positions but does not fill answer_ref from the walker. The 40-byte list is a HYPOTHESIS in _ARCHIVE/Native Semantic Pulse Fabric….md and a "40 B candidate" in _ARCHIVE/MASTER_BLUEPRINT.md §22.2/§22.4. No 40-byte producer, gold, or board capture was found. Git history in this repo is one snapshot commit 73b3e912… on 2026-09-17; authoring commits and an explicit 40B retirement are UNKNOWN. f2a071fe is fetch_active ram[use_slot][11], debug evidence telemetry, not a legal StructuredResult answer/proof/provenance field while status is not ANSWER. Do not mix layouts. Do not program a new result bit until an XSim emits the 48-byte header with status 0x04, CRC, and reference fields held at 0. JA image e2d97151… stays. sr48_active_ref_r1.sv is not adopted.
SLOT_NOTE: slot_bit selects the window. active_generation does not.
RTL_CUT_1: SHARED_ACTIVE_GENERATION_XSIM log 10085 ns ANSWER_EMITTED=NO
RTL_CUT_2: SKILL_ONLY_IF_RECORD_SAYS_XSIM log 645 ns PROPOSAL_IS_NOT_SKILL_ID
RTL_CUT_4: EXPERIENCE_CHANGES_NEXT_DECISION_XSIM log 4415 ns BOARD_BUILT=NO
OWNER: AGENT_D
BOARD: one Arty A7-100T
CREW: none

Đọc full file này trước mọi việc Native_SymAI sau khi hội thoại bị tóm tắt. Không tin bản paraphrase trong summary.

## Goal

Trên một Arty A7-100T, một runtime dùng chung biến một thế hệ tri thức đã commit thành hai kết quả truy được nguyên nhân.

1. Một câu hỏi trả về StructuredResult, và evidence của câu trả lời là bản ghi đang active.
2. Một hành động trả về PrimitiveCommand từ cùng thế hệ đó, có hiệu ứng quan sát được, và kinh nghiệm đó đổi được quyết định lần sau.

Bitstream đã đóng, UART, WNS dương, và End of startup HIGH là bậc thang. Chúng không phải đích.

Một người cầm việc. Không tách agent. Một ảnh trong SRAM tại một thời điểm. Chỉ nạp khi mô phỏng không trả lời được câu hỏi.

## Trần claim

PROGRAM_PASS=NO
BOARD_PASS=NO
TIMING_PASS=NO
MIG_PASS=NO
PACK_ABI_24_24_PASS=NO
ASTRA_PASS=NO
FEM_PERSIST_PASS=NO
FE256_PASS=NO
SKILL_ENGINE_PASS=NO
CHAIN_OF_ACTIONS_PASS=NO

Engine FE256 riêng là bản tham chiếu, không nằm trong goal.

## Không đụng

- fem_lifecycle.v
- spear_rank.v
- qstar_select.v
- Identity đã đóng, gồm 90220cb5, 44546b43, 435bdc88, 1db38691, và các SHA đã freeze trước đó
- gold.py
- SLOT1_BASE

Mỗi nhát mới = nền đã đóng + một biên mới = identity mới.
Nhãn bắt buộc: D_IMPLEMENTED, D_SELF_AUDITED, INDEPENDENT_C_AUDIT=NOT_RUN.
Không viết independently verified.

## Vì sao thứ tự này

Goal đòi cùng một thế hệ gây ra cả câu trả lời và lệnh. Chọn skill trước khi hai làn cùng đọc active_generation sẽ tạo hai bộ nhớ. proposed_action[2:0] là chỉ số primitive, không phải skill_id.

Pack commit -> active_generation -> bản ghi nhìn thấy.
Cùng bản ghi đó đi hai làn.
Làn hỏi: bằng chứng -> phán quyết truy vấn -> StructuredResult.
Làn làm: mô tả -> xếp hạng -> chính sách -> skill nếu bản ghi yêu cầu -> quyền hành động -> PrimitiveCommand -> hiệu ứng -> FEM.
FEM phải đổi lần chọn sau.

Mã hành động B0-B4 không được dùng làm status truy vấn 0x01-0x06.

## Năm nhát

1. SHARED_ACTIVE_GENERATION
QueryRecord và descriptor hành động đọc byte mà commit vừa công bố, cùng active_generation.
Host không chọn thế hệ. QueryRecord không chọn thế hệ.
Chưa commit: cả hai làn miss.
Commit G1: cả câu trả lời và lệnh theo G1.
Commit G2: cả hai đổi theo G2.
Stale không kéo root, không thêm ghi.
Không sửa pack_gen_vis đã đóng ở 90220cb5.
Nền nhiều bản ghi đã có ở D:/FPGA/arty_d/UART_R2/pack_nrec.
Làn hỏi hiện nằm riêng. Nối bằng bản ghi chung, không bằng cách đổi mã verdict.

2. SKILL_ONLY_IF_RECORD_SAYS
Nguồn chọn skill là trường trong bản ghi hoặc thư mục skill.
Không lấy skill_id từ proposed_action.
Không sửa skill_option_integration_r1.sv SHA b645e1f8ae0765182aae4f82c76e22f38df3d370460a54a24ebc51e8fb99c429 để nhét selector vào.
Không viết case(skill_id).
Generation 8 bit của skill không nối vào 16'h0007 của đuôi lệnh.

3. EFFECT_IS_NOT_COMMAND
primitive_executor_r1.sv hiện là bảng thay thế, log 30588990 finish 915 ns.
Nhát sau: cùng một lệnh hợp lệ phải ra được hai hiệu ứng khác nhau.
Lệnh bị từ chối không được đọc hàng SUCCESS.
command_valid=1 không phải SUCCESS.
command_valid=0 không phải FAILURE.
FB_NO_BINDING chưa phân biệt safety với thiếu capability.

4. EXPERIENCE_CHANGES_NEXT_DECISION
Quan sát đi vào FEM bằng cổng sẵn có.
Không sửa fem_lifecycle.v.
Cùng điều kiện, sau một hiệu ứng thì đề xuất Q* đổi. Không có hiệu ứng thì không đổi.
Không build lại bit persist 1db38691.

5. PHYSICAL_DDR
Chỉ khi mig_ui_bram không còn trả lời được câu hỏi.
mig_ui_bram không phải mig0.
Log cửa sổ 6d9b62ab finish 16045 ns giữ nguyên.
Một ảnh trong SRAM.
Không nạp chỉ vì tổng hợp xong hoặc WNS dương.

## Địa chỉ

BYTE_ADDRESS, WORD32_INDEX, MIG_BEAT_INDEX, WINDOW_INDEX phải được gọi đúng tên.
28'h010_0000 là bit 20, giá trị 0x00100000, window 01.
0x01000000 là bit 24. Nếu lấy addr[21:20] thì nó rơi vào window 00 và đè slot 0.
Slot 0 base 0. FEM base 0x00200000 là window 10.
mig_ui32: lane = addr[3:2], beat = addr[27:4] với nibble thấp bằng 0.
mig_ui_bram: window = addr[21:20], beat trong window = addr[13:4].

## Bẫy

- Summary biến candidate thành PASS hoặc quên trần claim.
- Hai nhát trong một test.
- Sửa identity cũ cho kịp tính năng mới.
- Đổi SLOT1_BASE.
- Host hoặc QueryRecord chọn thế hệ.
- Map skill_id từ proposed_action.
- case(skill_id) hoặc FSM theo từng bài semantic.
- Coi origin=8'h01 là chữ ký của skill. Đó là hằng của action tail đã đóng.
- Coi bảng effect là sensor.
- Nới theta, actions, features, K_HARD_MAX, hoặc N_RAW. Vượt ngưỡng thì dừng.
- Sửa gold.py hoặc chạy thêm Pack 24 để cứu comparator cũ.
- Thêm đường FE256 riêng, cache, hoặc đáp án cứng.
- Nạp board khi WNS dương. Nạp hai ảnh. Tách người sửa cùng cây nguồn.
- Viết PASS toàn cục sau XSim.
- Gọi mig_ui_bram là MIG_PASS.

## Bằng chứng đã có, không phải goal

- 90220cb5: commit đổi active_generation và lệnh. Không phải Pack 24/24, không phải MIG, không phải BOARD_PASS.
- Nhiều bản ghi XSim b4c6c822: một thế hệ, hai subject, cùng cửa sổ. Không có board.
- Cửa sổ MIG XSim 6d9b62ab: cùng discriminator qua mig_ui_bram. MIG_PASS=NO.
- Skill unit và adapter b645e1f8: primitive bước thành lệnh. Testbench vẫn khởi động skill.
- Effect 30588990: bảng chọn SUCCESS hoặc FAILURE. Chưa phải sensor. Chưa vào FEM.
- Shared generation XSim log 4f053828a806473ea74d56e9bddb8e4ce6f5f4ea7e1ea2b4c55db47625d95dd7 finish 10085 ns. QueryRecord generation 0x00AB không chọn bản ghi. Evidence gen và ref đi theo G1 rồi G2 cùng lệnh. Status 0x02 khi chưa commit, 0x04/0x20 khi có bản ghi. ANSWER không được phát. Đây là chiếu từ cùng descriptor, chưa phải walker truy vấn riêng. ASTRA_PASS=NO.
- Skill từ bản ghi, log 41035b832d1a3d8119d7dad7ab74f4631f7c8d422f5449c68b43ca03080f011b finish 645 ns. Proposal 7 vẫn chạy skill 0x20, primitive 1 rồi 0. Bản ghi max_steps 0 không phát bước dù proposal là 1. Adapter b645e1f8 không đổi. Thư mục bản ghi vẫn do testbench đưa, chưa phải Pack. SKILL_ENGINE_PASS=NO.
- Kinh nghiệm đổi đề xuất, log e3f45e077900eb7cde395a26e2e0322dea8c51d3baffe2e30fe43cea8221c26d finish 4415 ns. command_valid=1 mà chưa ingress thì đề xuất 0 và fem_feat 0. Ingress effect 3 được nhận, fem_feat 1, đề xuất sau là 1. Đề xuất tiếp theo không đổi khi không có ingress mới. t2_ready buộc 1, không phải DDR. Map feat là wrapper. FEM_PERSIST_PASS=NO. Không nạp board.
- Quan sát sau lệnh của thế hệ đã commit, log c8d53ddcbfc017a349f183e77909977f8b6fa5a7b35e26c8560efbde2de704a7 finish 8125 ns. Trước lệnh, effect 3 không vào FEM. Commit G1 phát primitive 0 id C001. Bit lệnh không đổi đề xuất sau. Sau lệnh, effect 3 được nhận, fem_feat 1, đề xuất sau là 1. Q* sau là instance kinh nghiệm, không phải Q* bên trong pack. FEM_PERSIST_PASS=NO. MIG_PASS=NO.
- Board interface inventory 61 rows reviewed. RUNTIME_IMPORT=NO. Offline only. UART token conflict on A9 and D10 is unmerged. Roles stay UNKNOWN. Not a Pack generation.
- Một commit gây evidence và cổng kinh nghiệm, log 4dcf42753993cf3af2c74bb514246bc239bb701ecfcffa3aeb48fa0c63b06f31 finish 6755 ns. Chưa commit: status 0x02, không lệnh, effect không vào. G1: query gen 0x00AB, evidence gen 1 ref 025bb7b4, status 0x04, verdict B0, primitive 0. Bit lệnh không đổi đề xuất sau. Effect 3 sau lệnh đưa fem_feat 1 và đề xuất sau thành 1. ANSWER không phát. Q* sau vẫn là instance kinh nghiệm. ASTRA_PASS=NO.
- Một Q* đếm lệnh và đề xuất sau, log 0f4bc81cbf419fdb24f82536c19a2af304d7ea45b6eed66c8d2ae3d153aadf8d finish 8205 ns. Không có bản ghi thì decision không phát lệnh. G1 ref 025bb7b4, proposal 0 thành lệnh C001. Effect 3 sau lệnh đó, proposal 1 của cùng instance. Q* bên trong pack_vis không nối vào lệnh này. Effect vẫn là hằng. FEM_PERSIST_PASS=NO. MIG_PASS=NO.
- Mẫu đọc lại không phải lệnh, log 983249e58c1b08de46b64e5baa2c9010ed59604c8daf1ec997ababe440aaf7c8 finish 8045 ns. Lệnh primitive 0 vẫn valid. Mẫu 0 trùng primitive thì không vào FEM, đề xuất sau vẫn 0. Mẫu A khác lệnh thì được nhận, fem_feat 1, đề xuất sau thành 1, command_valid vẫn 1. Mẫu không phải chân pin. FEM_PERSIST_PASS=NO. BOARD_PASS=NO.
- Mẫu đi qua uart_rx 115200, log ad481a21970023a932e446b3aa4c252c88a81df1d734b2817632dfd223905e18 finish 782225 ns. Byte 0 không vào FEM. Byte 0x0A vào, nibble A, fem_feat 1, đề xuất sau thành 1, command_valid vẫn 1. Không gán vai ngữ nghĩa. Không phải đọc lại LED. FEM_PERSIST_PASS=NO. BOARD_PASS=NO.
- Một log cho cả hai kết quả, log b41e4d7ab7969c286c841d0e15fb1178ba69fcef01455dcdce9ec299e4d9f6ea finish 722275 ns. Chưa commit: status 0x02, không lệnh. G1: query gen 0x00AB, evidence gen 1 ref 025bb7b4, status 0x04 không phải 0x01. Lệnh C001 primitive 0 từ Q* đếm. Byte uart 0 không đổi đề xuất. Byte 0x0A đổi đề xuất thành 1 trong khi command_valid vẫn 1. ANSWER không phát. Q* trong pack_vis vẫn không phải đường đếm. Không phải board.
- Một Q* trong thiết kế, log 8ed8c0ab8c222d304b154ac523e14b5c84634a454c03c35bfec4f3da05cf6542 finish 730075 ns. Không biên dịch pack_vis và spear_rank. Commit G1 ack, 12 lần ghi, ref 025bb7b4, status 0x04, lệnh C001 primitive 0. UART 0x00 không đổi đề xuất. UART 0x0A đổi đề xuất thành 1. ANSWER không phát. Không phải board. fetch_only_r1 trong identity đó chỉ đọc ram cửa sổ 0.
- Cửa sổ theo active generation, log b49b9f04467a56652c27b9d7d5a46fa7438a4dbcf953a8be1dc6a077a8fcd1c8 finish 3165 ns. G1 slot 0 ref 025bb7b4. G2 slot 1 ref f2a071fe, 24 lần ghi. Stale G1 reason 0x0E, root vẫn 2, query vẫn ref G2. fetch_only_r1 không bị sửa. Chưa gắn vào single_policy. MIG_PASS=NO. Không nạp board.
- Cùng cửa sổ đó là evidence và lệnh, log a1fba9dbe37baaa8e9aff9429e98f0760638a25ee3c07c03460fc6ae37c7a162 finish 11905 ns. Một qstar_select. Không pack_vis, không spear, không UART. Chưa commit: status 0x02, không lệnh. G1 slot 0 ref 025bb7b4, lệnh C001 primitive 0. G2 slot 1 ref f2a071fe, lệnh C002 primitive 1. Query gen 0x00AB. command_generation vẫn 16'h0007. Bit lệnh không đổi đề xuất sau. Stale G1 reason 0x0E, root 2, query và đề xuất vẫn G2. ANSWER không phát. Map feature và theta là substitute. single_policy_r1 không bị sửa. ASTRA_PASS=NO. Không nạp board.
- Quan sát sau lệnh của thế hệ 2, log b2da5485a1783ee62db450063eff983217a2693f0b6c6fb182add6674c0cf4dc finish 1519865 ns. G2 slot 1 ref f2a071fe, status 0x04, lệnh C001 primitive 1. Mẫu trước lệnh không vào FEM. Mẫu nibble 1 trùng primitive thì đề xuất vẫn 1. Mẫu 0x0A vào, fem_feat 1, đề xuất sau thành 0 trong khi command_valid vẫn 1 và primitive lệnh vẫn 1. Query sau đó vẫn ref f2a071fe. command_generation vẫn 16'h0007. UART không có vai ngữ nghĩa. t2_ready buộc 1. Map feature và theta là substitute. ANSWER không phát. FEM_PERSIST_PASS=NO. Không nạp board.
- Cùng command id hai hiệu ứng, log af36b339d6e4ff39ab26b15225f53c6b5d32c4fa61fbe7653ffa2670598f7dcb finish 9935 ns. Trước lệnh, bảng SUCCESS vẫn trả FB_NO_BINDING. G2 slot 1 ref f2a071fe, lệnh C001 primitive 1. Mã 1 trùng primitive, cùng id C001, không vào FEM, đề xuất vẫn 1. Mã 4 cùng id C001 thì vào, fem_feat 1, đề xuất thành 0, primitive lệnh vẫn 1. Query sau vẫn ref f2a071fe. Bảng là substitute, không phải sensor. primitive_executor_r1 không bị sửa. FEM_PERSIST_PASS=NO. Không nạp board.
- Plant tự tính hiệu ứng, log f66a75fbd86918b4f87af866655edab1e683f9e19b5cad68885c5df1338e8ebd finish 9865 ns. Testbench không ghi mã hiệu ứng. Trước lệnh: plant 0, mã FB_NO_BINDING. G2 slot 1 ref f2a071fe, lệnh C001 primitive 1. Lần tác động đầu: state 0+1=1, trùng primitive, không vào FEM, đề xuất vẫn 1. Lần sau: state 1+1=2, vào FEM, đề xuất thành 0, id vẫn C001. Query sau vẫn ref f2a071fe. Plant là substitute, không phải chân pin. FEM_PERSIST_PASS=NO. Không nạp board.
- Đọc lại chân ngoài module cộng, log eb67217748f81687242050ac78d08a5a7ff695969709d81289599dc2bdd932e4 finish 9975 ns. drive_pin và sense_pin không nối trong DUT. Trước lệnh, sense=2 vẫn là FB_NO_BINDING. Dây kín: drive 1, sense 1, không vào FEM. Dây hở: drive đã là 2 nhưng sense giữ 1, đề xuất vẫn 1. Dây kín lại: sense 2, fem_feat 1, đề xuất thành 0, id vẫn C001, query vẫn ref f2a071fe. Dây nằm trong testbench, không phải chân board. Không nạp board.
- Plant ngoài DUT, log bb9d388d806fafaea0d019bfa37efadca56b60cc1d7a06b670cd2eefbc2e8257 finish 9865 ns. g2_pin_r1 không bị sửa. Testbench không gán sense. Sau phép cộng: drive 1, sense vẫn 1, mẫu mã 1, đề xuất vẫn 1. Plant ngoài đổi sense thành 2 trong khi drive giữ 1. Mẫu mã 2 vào FEM, đề xuất thành 0, id vẫn C001, query vẫn ref f2a071fe. Luật plant là world+1 khi drive đổi, không phải chân pin. FEM_PERSIST_PASS=NO. Không nạp board.
- Protocol cổng, không xung sideband, log f3716bd734001a6795ce02ca76ecf3c51cd36a317d95dbf953c965abe6fb2e52 finish 5085 ns. Host chỉ đưa pack và một query. Theta, proposal, decision, exec và sample nằm trong g2_proto_r1. Kết thúc: ref f2a071fe, slot 1, status 0x04, lệnh C001 primitive 1, drive 1, sense 2, fem_feat 1, đề xuất 0. Đã thấy khoảng drive 1 sense 1 khi feat còn 0. Chưa có khung UART. Plant vẫn là bộ đếm. Không nạp board.
- Gắn chân package, log 962af4b9b59c5156cd547efb2a4fc10a9263ed52f069ea1cfaacdd27cbcf7907 finish 5095 ns. Sense là sw[2:0] trên A8 C11 C10. Drive là led[2:0] trên H5 J5 T9. Trong top không có phép gán giữa sw và led. Kết thúc led=1 sw=2, ref f2a071fe, đề xuất 0. Vai ngữ nghĩa UNKNOWN. Cổng pack và query chưa có package pin. XDC chưa được implementation. Không đo điện áp. Không nạp board.
- Pack và query vào bằng uart_rx 115200, log 45d71d467ef3aafc1b50b3ec727b0a33da5dfc130cf73a7699047487b16066de finish 44442105 ns. Không có cổng s_data hay mảng query. G1 12 lần ghi, G2 24 lần ghi. Kết thúc ref f2a071fe, slot 1, status 0x04, query gen 0x00AB, lệnh C001 primitive 1, drive 1, sense 2, fem_feat 1, đề xuất 0. Đã thấy nhịp drive 1 sense 1 khi feat còn 0. Vai UART UNKNOWN. Sense vẫn là bộ đếm ngoài. Không có XDC cho identity này. Không nạp board.
- Hai prior ngoài DUT, log b3246a5b39d516884b85d3c0bd49ebd237eb252a996aea15b5736390ebd1b025 finish 10175 ns. Cùng pack, cùng query, cùng lệnh C001 primitive 1, drive giữ 1, ref f2a071fe. Prior 1 cho sense 2. Prior 3 cho sense 4. Trước tác động, sense còn bằng prior và fem_feat còn 0. Luật vẫn là prior+1. Không phải chân pin. Không nạp board.
- Key FEM chứa primitive của lệnh, log 0c2e9b7bf9a515d21f2ec0767301c35efc06378a55e0f162cd5492b72c883110 finish 5995 ns. Sense bị giữ ở 2. G1 primitive 0, lệnh C001, key dead, fem_feat 1, mismatch 0. G2 cùng mã sense, primitive 1 vì feature của FEM chứ không phải ref G2, lệnh C002, mismatch 1, fem_feat giữ 1, không có cạnh lên ing_accepted. g2_pin_r1 vẫn buộc ing_prim bằng 0. Không nạp board.
- Kết quả ra uart_tx 115200, log c0a28c4f094e1dfaa11188c8fa1e5191393a2e7513e81c712bfc83fe84669d68 finish 1043655 ns. Ba word nhận được: ref f2a071fe, lệnh C001, word 01020001 nghĩa là fem_feat 1, sense 2, đề xuất 0, primitive 1. Phán quyết lấy từ word UART, không lấy từ net nội bộ. Sense vẫn là prior+1. Không nạp board.
- Một module cho cả uart_rx và uart_tx, log a2740dec2aa925a1dac447c9065cc1e169ba400ecaa0411f820d4d36740f069f finish 45583415 ns. Pack và query vào rx. Ba word ra tx: f2a071fe, C001, 01020001. Không có cổng pack song song. Sense vẫn là prior+1. Không có XDC. Không nạp board.
- Top chỉ còn chân package, log 252a0c1f71b9bc0572e38cb1f667f79cc6f451a8e2827a486be1af56e87e6db6 finish 45579415 ns. Cổng là CLK100MHZ, ck_rst, uart_rx A9, uart_tx D10, sw A8 C11 C10, led H5 J5 T9. XDC hash 439b59cc9f7611662227786308f50e8f189d715c135734d2f4561ba07789164c. Ba word tx vẫn f2a071fe, C001, 01020001. led=1 sw=2. XDC chưa implementation. Sense vẫn là prior+1. Vai UNKNOWN. Không đo điện áp. Không nạp board.
- JA hở và JA kín trong XSim, log bb79156a3dcae8841812a90ed6c14d712c729e7f0dbf4c77bb3da33d20ff796f finish 10595 ns. Cùng ref f2a071fe, cùng lệnh C001 primitive 1, drive=1. Arm hở: sync=0, không qualify, fem_feat 0, đề xuất 1. Arm kín của testbench: sync=1, qualify, fem_feat 1, đề xuất 0. FEM nhận mã 4, không nhận bit 1 thô. Dây kín nằm trong testbench. Master XDC local ghi Rev. D, G13 là ja[1], B11 là ja[2]. XDC ef0c8848 chưa implementation. Không đo điện áp. Không nạp board.
- Khóa chân JA trước bitstream. Không có XSim mới. Master local SHA256 7396974dfcc998d337494c97d4d42bddb45e76090d67ff6463d26deec15d254c, header Rev. D. HDL ja[0] là G13, comment Sch=ja[1]. HDL ja[1] là B11, comment Sch=ja[2]. Khóa: JA1 = G13 = effect_drive, JA2 = B11 = effect_sense. Constraint mới SHA256 5b61e10d838f8421348bac57df427ae695c0c25d9a940702e027d6ceab3da10c dùng PULLTYPE PULLDOWN. File ef0c8848 có PULLDOWN TRUE và cổng CLK100MHZ không có trên module hiện tại. XSim không chứng minh pull-down. Mã 4 là event, không phải điện áp. Silkscreen chưa đọc. Không implementation. Không bitstream.
- Ảnh mặt trên board đang cắm, SHA256 1540d4c517150bddfc7f3266a626767b4d6fc860504ebc94e456aaf18e2ef86f. Đọc được ARTY A7, Digilent, Avnet, ARTIX-7 100T CSG324, MAC 00183E04E0D4, tem QC.OK 2. Không đọc được Rev D, Rev E, hay E.2 trên mặt này. Mặt dưới chưa có ảnh. Không suy revision từ tên sản phẩm. Không bitstream.
- Silkscreen dưới barcode đọc REV E. Ảnh SHA256 8138b0807f30bb61b1888291a9cb7768acb27e64f9ffcf1914019d40dac67d98. Không phải Rev. D, không phải E.2. Master Digilent hiện tại ghi header Rev. D and Rev. E. Dòng JA vẫn là G13 Sch=ja[1] và B11 Sch=ja[2]. Bản local 7396974d có cùng hai dòng JA nhưng header chỉ ghi Rev. D. Khóa chân giữ JA1=G13=effect_drive, JA2=B11=effect_sense. Constraint 77128d4d79f341dea8ebb3732f22595180b5198c4a498db42591e641fb1e27fe. Không bitstream.
- Ảnh IC4 SHA256 d92e37599bf755a0a9b568ba8c1398735f672146e54585d4ea538f2aafbb1618. Nắp flash đọc S25FL128SAG, silk IC4. Header cạnh nút DONE là JA, các chân để trống. Ảnh IC7 SHA256 a15b334d9920fee27e78cf7932362f7e86e7272a51e122f1a6bf6ec3266e9665. Nắp DRAM đọc IS43TR16128D-125KBL, silk IC7, date 2404. Shunt xanh nằm trên J6 cạnh CK_RST, không nằm trên JA. Flash 128S khớp hàng load của manual cho board tới REV E khi không có sticker 127S. Không tách E.0 với E.2. Không bitstream.
- Top đóng JA, log 0a7053130a4cc4a5249e5ce1db077fa2d5758c7dc7ab953e17679622d3428fdf finish 45583775 ns. Cổng là CLK100MHZ, ck_rst, uart_rx, uart_tx, effect_drive, effect_sense, led0. Cùng ref f2a071fe, cùng lệnh C001. Arm hở: word 00000101, nghĩa là fem 0, sense 0, đề xuất 1, primitive 1. Arm kín của testbench: word 01010001, nghĩa là fem 1, sense 1, đề xuất 0, primitive 1. led0 đi theo drive. Quan sát lấy từ effect_sense. Dây kín không phải jumper đồng. XDC e935b3078c37d7af9f5c7ff73e7c73b35db9e1c51c7dac01be17e7f7106dcfad. WNS dương không phải TIMING_PASS.
- Bit JA e2d971512c519471541ac81e4b83eb41d77cf1b48d79092325e0b3e40b6c9349. WNS=0.279 WHS=0.024. TIMING_PASS=NO. Nạp một lần JTAG 210319BE776EA, End of startup HIGH, PROGRAM.DONE=NA, PROGRAM_PASS=NO. Chủ xác nhận schematic E.2 với hãng. Silkscreen vẫn REV E. Không build lại. Arm hở, JA trống, UART COM12 đọc f2a071fe 0000c001 00000101. Khớp XSim arm hở. Chưa có jumper. BOARD_PASS=NO.
- Chủ cắm lại JP2 trên CK_RST. Không nạp lại. JA vẫn trống. UART lại đọc f2a071fe 0000c001 00000101. File UART_OPEN_JP2_RESTORED.txt. Bitstream không đổi. Bước kế tiếp chỉ là jumper JA1–JA2.
- Chủ xác nhận shunt đang cắm trên header JP1 và trên header JP2. JP1 là mode QSPI. JP2 là CK_RST. Không có dây nối từ JP1 sang JP2. Chưa có dây JA chân 1 sang chân 2. LED4 sáng là witness H5 của effect_drive. Không nạp lại.
- Host arm kín đã sẵn, chưa chạy. Kỳ vọng khi JA chân 1 nối chân 2 trên cùng bit e2d97151… là word 01010001. Không nạp lại.
- Ảnh board lúc JP1 và JP2 đã có shunt. Header JA cạnh DONE chưa có dây. Manual Digilent: JA pin 1 = G13, pin 2 = B11. JA là standard Pmod, điện trở nối tiếp 200 ohm. Schematic E.2 cùng đánh số chân. Arm kín chưa chạy.
- Rút nguồn làm DONE=0. Nạp lại cùng bit e2d97151…, End of startup HIGH, không build mới. Dây đỏ trên JA sát PROG. UART đọc f2a071fe 0000c001 00000101, trùng arm hở, không phải 01010001. Sense vẫn 0. Ảnh phóng cho thấy dây ở cặp chân sát góc nút PROG. Chưa chứng minh đó là chân 1 nối chân 2 cùng hàng. BOARD_PASS=NO. PROGRAM_PASS=NO.
- Chủ chuyển dây JA1–JA2 kề nhau cùng hàng. DONE lại bằng 0. Nạp lại cùng SHA e2d97151…, End of startup HIGH, không build mới. UART file UART_CLOSED_ADJACENT.txt đọc f2a071fe 0000c001 01010001. Fem 1, sense 1, đề xuất 0, primitive 1. Arm hở trước đó cùng SHA là 00000101. JA_EXTERNAL_LOOPBACK_BOARD_CANDIDATE=SUPPORTED ở lớp UART. Không đo volt kế. PROGRAM_PASS=NO. BOARD_PASS=NO. TIMING_PASS=NO. ASTRA_PASS=NO.
- Chủ tháo dây JA1–JA2. Không nạp lại. UART file UART_OPEN_AFTER_REMOVE.txt đọc f2a071fe 0000c001 00000101. Sense về 0, đề xuất về 1. Cùng lệnh C001 và ref f2a071fe. Ba bước trên một SHA: hở 00000101, kề 01010001, tháo 00000101. BOARD_PASS=NO.
- Khung host trong XSim, log dec850cc21d519e9367ce96e61622d1b8596bc1ebc9c419072714172c5219763 finish 10595 ns. Word 04004e52 là magic 4E52 và status 04. Ref f2a071fe và lệnh C001 đi cùng. Arm hở word cuối 00000101, arm kín testbench 01010001. Không phải khung 48 byte. ANSWER không phát. Không nạp. Ảnh SRAM e2d97151… không đổi.
- Audit ABI, không sửa RTL. Authority hiện tại là 04_ABI_AND_PROTOCOL.md §4.4: 48 byte, magic đứng đầu. 40 byte là hypothesis/candidate trong _ARCHIVE, không có producer. query_result_bind không ghi w_end vào answer_ref. f2a071fe là ram word 11 của fetch, không nhét vào answer_ref. Git chỉ có snapshot 73b3e912 ngày 2026-09-17. Board 48 byte cũ là UART smoke f6a6091f, CRC 0x36F0, không phải ANSWER. NEXT_CUT là XSim header 48 byte status 0x04, ref fields bằng 0. Không nạp.
- Header §4.4 trong XSim, log 333336601d9eb50a74c376d92b56edb4e6f2ea7628a25b07ab92f139d3015a98 finish 1 ns. Byte 0–1 là 52 4E, abi 01, status 04, CRC b2c0 khớp. Byte 12–45 bằng 0, gồm answer_ref. f2a071fe không nằm trong header. Status do testbench đưa vào, chưa nối từ runtime JA. ANSWER không phát. Không nạp. Ảnh e2d97151… không đổi.
- Đối chiếu nhánh D:/NATIVEAI_FULL_EVIDENCE, không merge. Packer board là query_result_bind_t1cache.sv. Khi hit, end_id ghi vào byte 16–19 và last_count/hops ghi vào byte 20–23 trong lúc verified=0 và proof_ref=0. Top arty_a7_r2_top_m2_t2_candidate.sv không instantiate astra_edge_qeval. UART M4 answer_ref=2 với status 0x04, answer_count=0. Đó là candidate walk, không phải ANSWER. Không copy packer đó. Không nạp.
- Header 48 byte lấy status từ g2_ja_loop, log 3073f641a453ae0d092fb5c8128ef064d1f5ce254c9ed1fd7a7c9dc700a73466 finish 10595 ns. Cả hai arm: byte 52 4E, status 04, answer_ref 00 trong khi evidence_ref vẫn f2a071fe ngoài header. Word telemetry hở 00000101, kín testbench 01010001. Không copy end_id. ANSWER không phát. Không nạp. Ảnh e2d97151… không đổi.
- astra_qeval trên đúng byte query của đường JA, log a0223821cc6c9f9ad61604f82553f93c15d0c2bc64d42092b31c2ffe2c2e75e3 finish 1 ns. Status 04, reason 20, completeness 02, không phải 01. Lý do là search_budget bằng 0. Mux JA chỉ có status 04, không mang reason 20. Hai nguồn status chưa nối. ASTRA_PASS=NO. Không nạp.
- Header 48 byte lấy status, reason và completeness từ astra_qeval trên cùng query với g2_ja_loop, log 796d4e716e03da0b8f458db5e807abc96a2ce4498a5976f435fc8a10692993d8 finish 10595 ns. Byte 3 là 04, byte 4 là 20, byte 6 là 02. answer_ref vẫn 00 trong khi evidence_ref f2a071fe nằm ngoài header. Mux JA vẫn 04. ANSWER không phát. Không nạp. Ảnh e2d97151… không đổi. ASTRA_PASS=NO.
- Chặn tiếp theo là proof. astra_walk_qeval chỉ phát ANSWER khi verified và proof_ref khác 0. Đường này không có proof object. f2a071fe không được ghi vào answer_ref. Không nạp.
- Audit nguồn ProofObject, không sửa RTL. Canon §3.3 yêu cầu bảy trường và không khóa layout nhị phân, ProofHeader, ProofStep, nơi cấp proof_ref, hay lifetime. T1 chỉ gọi tên proof scratch. T2 không có record ProofObject. G2 trong solve_payload.py là 48 byte directory+header+spear để CRC trang bằng 0x785BB750. f2a071fe là candidate_ref nằm ở word 11, không phải EdgeRecord và không có knowledge_state. bounded_walk bỏ first_edge_ref, không đọc EdgeRecord. Walker chỉ còn hit, end_id, count, hops, nên không dựng được support_chain. Gold FE-DIRECT-001 cho proof_ref 0x060100 mà không có byte ProofObject. astra_edge_qeval chỉ có trong TB XSim, không nằm trên top JA. G2_CAN_FORM_VALID_PROOFOBJECT=NO. NEXT_CUT là SUPPORT_RECORD_BEFORE_PROOF_BUILDER. Không phát ANSWER. Không đổi G2. Không nạp. ASTRA_PASS=NO. BOARD_PASS=NO. PROGRAM_PASS=NO.
- Quan sát walker, không đổi RTL walker. Log 4b0a610cfabaf0c8d3ec52b4a71275d0f7ea4f030a97a39e7e7cd1bb7fec80fc finish 265 ns. Posting edge_ref 00000020. Walker nội bộ cũng thấy 00000020. end_id là 00020100. Cổng bounded_walk không có edge_ref. ANSWER không phát. Đây là mất thông tin, không phải quyết định kiến trúc.
- Quyết định kiến trúc RESOLVE_THEN_DECIDE, không sửa RTL. Đơn vị bằng chứng là EdgeRecord. end_id không phải support. ProofObject là đời của query trong T1, evidence nằm T2. proof_ref giữ 0 cho đến khi có contract semantic id gắn txn và generation. Nhát sau là hai edge cùng neighbor khác knowledge_state: end_id trùng, field record khác, vẫn không ANSWER. G2 không đổi. Không nạp. ASTRA_PASS=NO. BOARD_PASS=NO. PROGRAM_PASS=NO.
- Alias neighbor, log 2e84ea436dd631a55aa9cbd7917ba5e2051f0fa6a1eb3dcd7a2700b32bc42838 finish 225 ns. Walker end_id 00020100, last_count 2. Hai edge trong cùng posting ROM: ref 00000020 state byte 11, ref 00000040 state byte 22, cùng dst 00020100. Byte state là fixture, không phải enum Canon. Walker không có cổng knowledge_state. ANSWER không phát. proof_ref 0. bounded_walk không sửa. G2 không đổi. Không nạp. PASS_XSIM của phép alias, không phải ASTRA_PASS. NEXT_CUT là contract proof_ref trước khi có ANSWER.
- Contract ứng viên proof_ref, không phải Canon, không phải RTL. File arty_d/UART_R2/proof_ref_contract_r1/proof_ref_contract_r1.py. proof_ref 0 không được kèm body. proof_ref khác 0 phải có support, answer_ref, tick, đúng txn và generation, và không được trùng địa chỉ edge. Provenance bắt buộc khi cờ yêu cầu. Mọi case ANSWER_ALLOWED=NO vì enum knowledge_state chưa khóa. PROOF_REF_CONTRACT_R1=PASS_CHECK. Không nạp. ASTRA_PASS=NO.
- Luật chọn theo nhãn verified, log 04d8a59d72c5dd2a1437626b2f2b5c244d3047101570d671504d03a7d8f5d796 finish 95 ns. Module eligible_edge_r1 không có cổng StructuredResult. Nhãn không phải decode byte Canon. Một nhãn verified thì eligible_dst theo edge đó: 00020100 rồi 00020101. Cả hai nhãn thì count 2 và eligible_dst 0. Không nhãn thì count 0. ANSWER không phát. proof_ref 0. Enum vẫn chưa khóa. Không nạp.
- Rà contract proof, không sửa Canon, không sửa RTL. §2.4.8 khóa edge_ref là địa chỉ byte T2, không phải identity. EdgeRecord §2.4.4 không có edge_id và không có generation. §2.2 có dòng Proof artifacts ở T2. §2.1 đặt PROOF ở scratch T1 và archive T2. Không có layout và không có lifecycle bắt buộc. support_chain bằng danh sách edge_ref bị rút. txn_id không được đặt bằng query_id. Enum knowledge_state vẫn phải khóa trước RTL so sánh VERIFIED. Không nạp.
- Relocation tuple, log 8f401e2ffb394c7c5b85f7ba4998f8afa7010ccbfe709df30d9f9f2e9c8be95b finish 75 ns. Cùng src dst relation context value provenance và tick, địa chỉ 20 khác 80: tuple khớp, địa chỉ không khớp. Cùng địa chỉ, provenance khác: tuple không khớp. ANSWER không phát. proof_ref 0. Enum chưa khóa. Không sửa Canon. Không nạp.
- Scope closed, log 072868e9d68ce2d780c5a5b5f2d6103328b45cdacf5b0ab8f2d85ccb21ecdfe9 finish 115 ns. Budget 0 thì scope_closed 0. Một hop xét hết entry thì 1, kể cả entry bị context loại sau khi đã thấy. Còn entry mà budget đã hết thì 0. Multi-hop còn frontier thì 0. Frontier hết trong budget thì 1. Module không phát ANSWER. Số đếm do testbench đưa, chưa phải walker thật. Enum chưa khóa. Không nạp.
- Rà identity, không sửa Canon, không sửa RTL. Hai EdgeRecord giống byte nằm ở hai địa chỉ: Canon không nói cùng instance, không nói hai instance, không cấm trùng. Không có edge_id. Dereference hiện tại là node, directory, posting, edge_ref. Không có lookup theo tuple. edge_ref trong proof chỉ là hint; hint cũ không được làm proof fail nếu tuple còn resolve. Enum số không khóa. FE256 bit 252 không phải field 8 bit của EdgeRecord. Layout ProofObject chưa sẵn sàng. Không nạp.
- Stale hint, log 4adf2b2d59524146587993c15da94d8c52d9b210cc7c8a7e12198cad4d8a66b4 finish 95 ns. Hint đúng địa chỉ thì resolve. Hint cũ mà tuple còn ở địa chỉ khác thì resolve bằng replay. Tuple khác thì không resolve. Hai bản giống nhau đếm tuple_hits 2. ANSWER không phát. proof_ref 0. Đây là luật ứng viên, chưa phải Canon. Không nạp.
- Replay từ bộ nhớ, log ef8cb92aec9bc736a1816062324b29cf8b4d312f7d80aa4a9f0f8bc5ac59ab18 finish 185 ns. Posting giữ hint 20. Word tại 20 có provenance khác. Tuple khớp nằm tại 80. hint_hit 0, replay 1, found 80. answer_ref 0, proof_ref 0. Tuple mong muốn là hằng trong module, chưa phải QueryRecord. Layout word không phải Canon EdgeRecord. Enum chưa khóa. Không nạp.
- Canon R1 2026-09-23: knowledge_state 0xC1–0xC6 trong §2.4.4.1. support_chain là SupportKey, không phải edge_ref. query_id là QueryRecord 32 byte giữ trong proof. proof_ref là semantic id, body nằm payload. VALUE chưa sẵn sàng. Không đụng G2 và e2d97151.
- proof_emit_r1, log 3c53069fe65241824d4f6d4d7c44a56a2c5e7a32041296a1da1d5c1da6d2ae0b finish 275 ns. ANSWER giữ body 90 byte, proof_id D1000001, QueryRecord magic 4E51, CRC đọc lại khớp. Budget 0 thì body_n 0 và byte proof_ref bằng 0. Không nạp. ASTRA_PASS=NO. BOARD_PASS=NO.
- Cùng generation trên proof_path_r1, log 798283fecbbfb24b6196630111652c778c036b6358c53b1aa743fd1977e1de4a finish 275 ns. Answer 20100 đi với command C0000100. Đổi edge VERIFIED thì answer 20101 và command C0000101. sub_gen lệch thì status 06 và command 0. Đây chưa phải lệnh JA và chưa phải hiệu ứng chân. Ảnh e2d97151 không đổi. Không nạp. ASTRA_PASS=NO. BOARD_PASS=NO.
- gen_cause_r1, log 0cd0b139324b8fdb75cd5e1027882915d481d3f2f2a7b2eb89abc29227ee1d44 finish 85 ns. Generation khớp: answer 20100, primitive 1 khác các bit thấp của answer, effect 0, proposal 1. Sau admit, effect code 4 và proposal 0. Generation lệch: không ANSWER, primitive 0, effect 0. Admit là đầu vào testbench, không phải chân JA. Ảnh e2d97151 không đổi. Không nạp. ASTRA_PASS=NO. BOARD_PASS=NO.
- gen_cause sense ngoài DUT, log f2a5c80a8214e92f9979090678c68d1ccc3de621eefd5313a05011e6bca5e569 finish 115 ns. Trước jumper: answer 20100, primitive 1, effect 0, proposal 1. Testbench nối sense vào drive. Sau đó effect 4, proposal 0. Module không gán sense từ drive. Generation lệch: không ANSWER, primitive 0, effect 0. Dây nằm trong testbench, không phải JA đồng. Ảnh e2d97151 không đổi. Không nạp. ASTRA_PASS=NO. BOARD_PASS=NO.
- Câu sau cùng generation, log 7ff7a41570856828ed39206bf8d54d1009ae10e83615d47ba848ecbaddafac52 finish 135 ns. Sau effect 4, query lại vẫn answer 20100 và proposal giữ 0. Không có effect thì proposal đã là 1. Ảnh JA e2d97151 vẫn là runtime khác, không chứa proof body này. Không nạp. ASTRA_PASS=NO. BOARD_PASS=NO.
- proof_image_r1 giữ generation trong DUT, log 18bbe8ce2ba1b1b207455988b15fbc002544af4eb82653f7b31f66fbfc07d334 finish 96 ns. Sense hở: answer 20100, primitive 1, effect 0, proposal 1. Testbench nối sense với drive: effect 4, proposal 0. Query sau vẫn answer 20100 và proposal 0. Không phải bitstream e2d97151. Không nạp. ASTRA_PASS=NO. BOARD_PASS=NO.
- Top arty_a7_proof_image, log 44937ba28e248f01403f9e0f4f1444061356f9da3cbb9f3103dbed99a8fc71d9 finish 415 ns. Cổng CLK100MHZ, ck_rst, uart_tx, effect_drive, effect_sense, led0. Sense hở: answer 20100, effect 0. Testbench nối sense với drive: effect 4, proposal 0. led0 bằng drive. Byte UART chưa đọc ở lần đó. Không có bitstream. Ảnh e2d97151 không đổi. Không nạp. ASTRA_PASS=NO. BOARD_PASS=NO. PROGRAM_PASS=NO.
- UART trên top, log e7cc9f37aa844eda15991a3e326a2671191a4607ab418b04da6e935f3deba386 finish 62035 ns. Baud mô phỏng 5000000, không phải 115200 của board. Sense hở đọc 00020100 D1000001 00000041. Sau jumper testbench đọc answer 00020100, primitive 1, effect 4, proposal 0. led0 bằng drive. Không nạp. ASTRA_PASS=NO. BOARD_PASS=NO. PROGRAM_PASS=NO.
- Bit mới arty_a7_proof_image.bit SHA256 45cd72131400aeb99a1fb36dd6bb125ac271725d6692c5ebc5ebf0df904540fb. WNS=5.765 WHS=0.177. TIMING_PASS=NO. PROGRAM=NO lúc build. File e2d97151 trên đĩa không bị xóa.
- Nạp SHA 45cd7213… JTAG 210319BE776EA. End of startup HIGH. PROGRAM.DONE=NA. PROGRAM_PASS=NO. SRAM giờ là ảnh này, không còn ảnh JA đang chạy. File bit JA vẫn còn trên đĩa.
- UART COM12 115200 arm hở, file UART_OPEN.txt. Khung thẳng hàng 00020100 d1000001 00000041. Answer, proof id, primitive 1, effect 0, proposal 1. Chưa có jumper JA. Không phải BOARD_PASS. ASTRA_PASS=NO.
- proof_path_r1 XSim log 1158037cd076467095f85af24343955968cb0704feb1cb98e5ba88c12d715916 finish 275 ns. Đổi byte VERIFIED giữa hai edge thì answer_ref đổi 20100 và 20101, cùng RTL. Cả hai CANDIDATE thì không ANSWER. Generation lệch thì 06/54. Thiếu provenance thì 02/61. Budget 0 thì 04/20. Hai VERIFIED khác dst thì 03/30. Không giữ body thì không ANSWER. Hint cũ replay vẫn ANSWER. Đổi provenance thì SupportKey cũ không còn khớp. Hai edge cùng dst khác knowledge_state: end_id một giá trị, hai byte state khác nhau. Multi-hop hai bước answer 20111. proof_id D1000001. Không nạp. ASTRA_PASS=NO. BOARD_PASS=NO. PROGRAM_PASS=NO.

## Việc được phép ngay sau khi đọc file này

Không chạy lại các nhát đã hỗ trợ. Board đang cắm không phải lý do nạp. Nhát DDR chỉ mở khi mig_ui_bram không còn trả lời được câu hỏi. Không nạp identity đã đóng.
Nếu summary không dẫn được dòng STATUS từ chính file này thì dừng, đọc lại file, không viết RTL.
