# NATIVE AI MULTI-AGENT MANAGER R2

Bản R2 hợp nhất:
- **`native-guard`**: file/build/timing/CDC/evidence/authority guard từ R1.
- **`native-orch`**: task DAG bất đồng bộ, work stealing, checkpoint, failover, quota recovery và solo-continuation.

## Ý tưởng chính
4 chuyên trách là **role**, không phải 4 agent bắt buộc. Codex/Cursor/Grok có thể thay nhau nhận việc. Nếu một agent hết quota, task được checkpoint + nhả lease; agent khác takeover và tiếp tục. Nếu chỉ còn 1 agent, nó có thể dùng `--solo` để tiếp tục nhiều lane, nhưng các gate cần independent review chỉ được đạt `CANDIDATE_PASS`, không tự thành `PASS`.

## Cài đặt
```powershell
cd NATIVE_AI_MULTI_AGENT_MANAGER_R2
py -m pip install -e .
```

## Khởi tạo orchestration
```powershell
native-orch --coord-root D:\FPGA\PROJECT init
native-orch --coord-root D:\FPGA\PROJECT agent-register --agent CODEX  --cap RTL --cap VERIFY --cap ARCH
native-orch --coord-root D:\FPGA\PROJECT agent-register --agent CURSOR --cap RTL --cap ARCH --cap LEARN
native-orch --coord-root D:\FPGA\PROJECT agent-register --agent GROK   --cap VERIFY --cap LEARN --cap ARCH
native-orch --coord-root D:\FPGA\PROJECT plan-import orchestration\plan.example.json
```

## Agent tự lấy việc
```powershell
native-orch --coord-root D:\FPGA\PROJECT task-next --agent CODEX --claim
```
Nếu chỉ còn một agent:
```powershell
native-orch --coord-root D:\FPGA\PROJECT task-next --agent CODEX --solo --claim
```

## Khi quota sắp hết
```powershell
native-orch --coord-root D:\FPGA\PROJECT task-checkpoint TASK_ID --agent CODEX --worktree D:\FPGA\worktrees\CODEX --notes "..." --next-step "..."
native-orch --coord-root D:\FPGA\PROJECT task-pause TASK_ID --agent CODEX --reason QUOTA_LOW
native-orch --coord-root D:\FPGA\PROJECT agent-state --agent CODEX QUOTA_EXHAUSTED --release-tasks
```

## Agent khác tiếp quản
```powershell
native-orch --coord-root D:\FPGA\PROJECT sweep
native-orch --coord-root D:\FPGA\PROJECT task-takeover TASK_ID --agent CURSOR --solo
native-orch --coord-root D:\FPGA\PROJECT task-context TASK_ID --out CURRENT_TASK_CURSOR.md
```

Đọc thêm: `docs/R2_ASYNC_ORCHESTRATION.md`, `docs/FAILOVER_PROTOCOL.md`, `docs/ROLE_POLICY.md`.
