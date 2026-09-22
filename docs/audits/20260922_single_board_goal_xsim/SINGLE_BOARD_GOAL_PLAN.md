# SINGLE_BOARD_GOAL_PLAN

GOAL_PLAN_PATH: D:/FPGA/Native_SymAI/docs/audits/20260922_astra_discovery/SINGLE_BOARD_GOAL_PLAN.md
STATUS: CUT16_G2_PLANT_XSIM_SUPPORTED
NEXT_CUT: PHYSICAL_DDR_ONLY_IF_SIM_CANNOT_ANSWER
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

## Việc được phép ngay sau khi đọc file này

Không chạy lại các nhát đã hỗ trợ. Board đang cắm không phải lý do nạp. Nhát DDR chỉ mở khi mig_ui_bram không còn trả lời được câu hỏi. Không nạp identity đã đóng.
Nếu summary không dẫn được dòng STATUS từ chính file này thì dừng, đọc lại file, không viết RTL.
