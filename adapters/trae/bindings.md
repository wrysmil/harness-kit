# Trae 平台绑定

| 原语 | Trae 绑定 |
| --- | --- |
| `DetectPlatform()` | Trae 工作区 → `trae` |
| `SpawnWorker(role)` | Trae Agent 模式 + `.agents/agents/<role>.md` |
| `ParallelBatch` | Trae Agent 并行任务; max 3 |
| `WorktreeInit` | 同 `scripts/harness-worktree.sh` / git worktree |
| `StructuredAsk` | Trae structured Ask |
| `EmitHook` | Trae hooks 机制 |
| `LoadSkill(slug)` | Read `.agents/skills/<slug>/SKILL.md`（共享层）或 `.trae/skills/<slug>/SKILL.md`（平台层覆盖） |
| `LoadAgent(role)` | Read `.agents/agents/<role>.md`（共享层） |
| `LoadCapability(orchestration.dispatch)` | `trae-orchestration` skill → core dispatcher |

**降级记录：** matrix 为 `degraded` 时，DISPATCH-TRACK 写 `Detail: capability <id> degraded`。
