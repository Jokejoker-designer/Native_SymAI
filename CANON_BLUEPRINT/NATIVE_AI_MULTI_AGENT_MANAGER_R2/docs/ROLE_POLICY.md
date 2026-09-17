# ROLE POLICY

Roles are capabilities, not identities:
- `ARCH`: architecture/semantic contracts.
- `VERIFY`: test contracts, independent evidence, causal attacks.
- `LEARN`: Q*/SPEAR/skill/FEM/teacher/sensor algorithms.
- `RTL`: RTL, XSim integration, Vivado, timing/CDC/resource closure.
- `GENERAL`: may take ordinary tasks across roles in solo mode.

Recommended registrations:
```powershell
native-orch agent-register --agent CODEX  --cap RTL --cap VERIFY --cap ARCH
native-orch agent-register --agent CURSOR --cap RTL --cap ARCH --cap LEARN
native-orch agent-register --agent GROK   --cap VERIFY --cap LEARN --cap ARCH
```

Do not encode vendor assumptions into task authority. Any agent may disappear; the filesystem state + task capsule + checkpoint is the continuity mechanism.
