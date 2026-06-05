# Cursor 平台绑定

逻辑原语 → Cursor API。语义以 `core/capabilities/` 与 `core/orchestration/` 为准。

| 原语 | Cursor 绑定 |
| --- | --- |
| `DetectPlatform()` | `.cursor/` + harness-* subagent 可委派 → `cursor` |
| `SpawnWorker(coder)` | `Use harness-coder subagent` + `core/orchestration/agents/coder.md` |
| `SpawnWorker(implementer)` | `harness-implementer` |
| `SpawnWorker(reviewer)` | `harness-reviewer`（readonly） |
| `SpawnWorker(test-engineer)` | `harness-test-engineer` |
| `SpawnWorker(explorer)` | `harness-explorer` 或 Task `explore` |
| `SpawnWorker(debugger)` | `harness-debugger` |
| `SpawnWorker(web-investigator)` | `harness-web-investigator` |
| `ParallelBatch` | 并行 Task/subagent，≤5 |
| `WorktreeInit` | `scripts/harness-worktree.sh` 或 git worktree 步骤 |
| `StructuredAsk` | `AskQuestion` |
| `EmitHook` | `.cursor/hooks.json` |
| `LoadCapability(orchestration.dispatch)` | `cursor-orchestration` skill → core dispatcher |

**Skill 路径：** `.agents/skills/cursor-orchestration/`；WU skill 副本 `.cursor/skills/`。

**降级：** 见 `capability-matrix.yaml`。
