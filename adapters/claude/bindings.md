# Claude Code 平台绑定

| 原语 | Claude 绑定 |
| --- | --- |
| `DetectPlatform()` | CLAUDE.md 会话 + Skill 工具 → `claude` |
| `SpawnWorker(role)` | Task(subagent_type=generalPurpose) + `.agents/agents/<role>.md` 作 prompt 正文 |
| `SpawnWorker(reviewer)` | 新 Task 实例 + readonly 约束 |
| `ParallelBatch` | 并行 Task（对齐 `dispatching-parallel-agents`）；不传 Leader 全历史 |
| `WorktreeInit` | 同 `scripts/harness-worktree.sh` / git worktree |
| `StructuredAsk` | `AskUserQuestion` 工具（单选/多选 + preview） |
| `EmitHook` | `SessionStart` / `SubagentStop`（来自 `core/extensions/hooks/`，写入 `.claude/settings.json`） |
| `LoadSkill(slug)` | Read `.agents/skills/<slug>/SKILL.md`；或 `Skill("<slug>")` 若已注册 |
| `LoadAgent(role)` | Read `.agents/agents/<role>.md` 作 Task prompt |
| `LoadCapability(orchestration.dispatch)` | `claude-orchestration` skill → core dispatcher |
| `LoadExtension(hooks.<name>)` | 读 `core/extensions/hooks/hooks.spec.yaml` `bindings.claude` 段，复制 wrapper 脚本到 `.claude/hooks/`，合并到 `.claude/settings.json` |
| `LoadExtension(mcp.servers)` | 读 `core/extensions/mcp/mcp.servers.template.json`，复制到项目根 `.mcp.json`（已存在则跳过） |

**委派 prompt 必含：** WU id、wu_type、agent_role、允许文件、禁止项、done criteria、worktree_path（若启用）、本 WU Skills、返回格式。

**降级记录：** matrix 为 `degraded` 时，DISPATCH-TRACK 写 `Detail: capability <id> degraded`。

**Hooks 与 MCP：** 见 [core/extensions/README.md](../../core/extensions/README.md)；spec 源 [core/extensions/hooks/hooks.spec.yaml](../../core/extensions/hooks/hooks.spec.yaml) / [core/extensions/mcp/mcp.servers.template.json](../../core/extensions/mcp/mcp.servers.template.json)。
