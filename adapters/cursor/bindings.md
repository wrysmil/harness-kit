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
| `EmitHook` | `sessionStart` / `subagentStop`（来自 `core/extensions/hooks/`，写入 `.cursor/hooks.json`） |
| `LoadSkill(slug)` | Read `.agents/skills/<slug>/SKILL.md`（共享层）或 `.cursor/skills/<slug>/SKILL.md`（平台层覆盖） |
| `LoadAgent(role)` | Read `.agents/agents/<role>.md`（共享层） |
| `LoadCapability(orchestration.dispatch)` | `orchestration` skill → core dispatcher |
| `LoadExtension(hooks.<name>)` | 读 `core/extensions/hooks/hooks.spec.yaml` `bindings.cursor` 段，复制 wrapper 脚本到 `.cursor/hooks/`，生成 `.cursor/hooks.json.example` |
| `LoadExtension(mcp.servers)` | 读 `core/extensions/mcp/mcp.servers.template.json`，复制到项目根 `.mcp.json`（已存在则跳过） |

**Skill 路径：** 共享 `.agents/skills/`（含 `git-xywh` 等通用 skill）；平台特有 `.cursor/skills/`。

**Hooks 与 MCP：** 见 [core/extensions/README.md](../../core/extensions/README.md)；spec 源 [core/extensions/hooks/hooks.spec.yaml](../../core/extensions/hooks/hooks.spec.yaml) / [core/extensions/mcp/mcp.servers.template.json](../../core/extensions/mcp/mcp.servers.template.json)。

**降级：** 见 `capability-matrix.yaml`。
