# Cursor 平台绑定

逻辑原语 → Cursor API。语义以 `core/capabilities/` 与 `core/orchestration/` 为准。

| 原语 | Cursor 绑定 |
| --- | --- |
| `DetectPlatform()` | `.cursor/` + subagent 可委派 → `cursor` |
| `SpawnWorker(coder)` | `Use coder subagent` + `.agents/agents/coder.md` |
| `SpawnWorker(implementer)` | `implementer` subagent |
| `SpawnWorker(reviewer)` | `reviewer` subagent（readonly） |
| `SpawnWorker(test-engineer)` | `test-engineer` subagent |
| `SpawnWorker(explorer)` | `explorer` subagent 或 Task `explore` |
| `SpawnWorker(debugger)` | `debugger` subagent |
| `SpawnWorker(web-investigator)` | `web-investigator` subagent |
| `ParallelBatch` | 并行 Task/subagent，≤5 |
| `WorktreeInit` | `scripts/harness-worktree.sh` 或 git worktree 步骤 |
| `StructuredAsk` | `AskQuestion` |
| `EmitHook` | `.cursor/hooks.json` |
| `LoadSkill(slug)` | Read `.agents/skills/<slug>/SKILL.md`（共享层）或 `.cursor/skills/<slug>/SKILL.md`（平台层覆盖） |
| `LoadAgent(role)` | Read `.agents/agents/<role>.md`（共享层） |
| `LoadCapability(orchestration.dispatch)` | `cursor-orchestration` skill → core dispatcher |

**Skill 路径：** 共享 `.agents/skills/`；平台特有 `.cursor/skills/`（如 `git-xywh`）。

**降级：** 见 `capability-matrix.yaml`。
