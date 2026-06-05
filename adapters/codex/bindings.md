# Codex / OMX 平台绑定

| 原语 | Codex 绑定 |
| --- | --- |
| `DetectPlatform()` | Codex CLI + `omx` in PATH → `codex` |
| `SpawnWorker(role)` | omx worker / 角色路由 |
| `ParallelBatch` | `omx ultrawork` |
| `WorktreeInit` | git worktree 或 routing 跳过（**degraded**） |
| `StructuredAsk` | 对话（**degraded**） |
| `EmitHook` | manual |
| `LoadCapability(orchestration.dispatch)` | `AGENTS.omx.md` + omx ultrawork |
| `SpawnWorker(web-investigator)` | general research 路由（**degraded**，无专用 omx 角色） |
| `git.worktree-script` | manual git worktree（**degraded**） |

详见 `entrypoints/AGENTS.omx.md`、`README.md`。
