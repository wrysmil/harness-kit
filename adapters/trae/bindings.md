# Trae 平台绑定

| 原语 | Trae 绑定 |
| --- | --- |
| `DetectPlatform()` | Trae 工作区 → `trae` |
| `SpawnWorker(role)` | 待定义 — Trae subagent 或 Task 机制 |
| `ParallelBatch` | 待定义 |
| `WorktreeInit` | 同 `scripts/harness-worktree.sh` / git worktree |
| `StructuredAsk` | 待定义 |
| `EmitHook` | 待定义 |
| `LoadSkill(slug)` | Read `.agents/skills/<slug>/SKILL.md`（共享层）或 `.trae/skills/<slug>/SKILL.md`（平台层覆盖） |
| `LoadAgent(role)` | Read `.agents/agents/<role>.md`（共享层） |

**降级记录：** matrix 为 `degraded` 时，DISPATCH-TRACK 写 `Detail: capability <id> degraded`。
