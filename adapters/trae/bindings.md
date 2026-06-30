# Trae 平台绑定

逻辑原语 → Trae API。语义以 `core/capabilities/` 与 `core/orchestration/` 为准。

| 原语 | Trae 绑定 |
| --- | --- |
| `DetectPlatform()` | Trae 工作区 → `trae` |
| `SpawnWorker(coder)` | Trae Agent 模式 + `.agents/agents/coder.md` |
| `SpawnWorker(implementer)` | Trae Agent 模式 + `.agents/agents/implementer.md` |
| `SpawnWorker(reviewer)` | Trae Agent readonly + `.agents/agents/reviewer.md` |
| `SpawnWorker(test-engineer)` | Trae Agent 模式 + `.agents/agents/test-engineer.md` |
| `SpawnWorker(explorer)` | Trae Agent readonly + `.agents/agents/explorer.md` |
| `SpawnWorker(debugger)` | Trae Agent 模式 + `.agents/agents/debugger.md` |
| `SpawnWorker(web-investigator)` | Trae Agent 模式 + `.agents/agents/web-investigator.md` |
| `ParallelBatch` | Trae Agent 并行任务; max 3 |
| `WorktreeInit` | 同 `scripts/harness-worktree.sh` / git worktree |
| `StructuredAsk` | Trae structured Ask（通过 Task 工具） |
| `EmitHook` | Trae hooks 机制（来自 `core/extensions/hooks/`，写入 `.trae/settings.json`） |
| `LoadSkill(slug)` | Read `.agents/skills/<slug>/SKILL.md`（共享层）或 `.trae/skills/<slug>/SKILL.md`（平台层覆盖） |
| `LoadAgent(role)` | Read `.agents/agents/<role>.md`（共享层） |
| `LoadCapability(orchestration.dispatch)` | `orchestration` skill → core dispatcher |
| `LoadExtension(hooks.<name>)` | 读 `core/extensions/hooks/hooks.spec.yaml` `bindings.trae` 段，复制 wrapper 脚本到 `.trae/hooks/`，合并到 `.trae/settings.json` |
| `LoadExtension(mcp.servers)` | 读 `core/extensions/mcp/mcp.servers.template.json`，复制到项目根 `.mcp.json`（已存在则跳过） |

**SpawnWorker 委派 prompt 必含：** WU id、wu_type、agent_role、允许文件、禁止项、done criteria、worktree_path（若启用）、本 WU Skills、返回格式。

**降级记录：** matrix 为 `degraded` 时，DISPATCH-TRACK 写 `Detail: capability <id> degraded`。

**Skill 路径：** 共享 `.agents/skills/`（含 `git-xywh`、`orchestration` 等通用 skill）；平台特有 `.trae/skills/`。

**Hooks 与 MCP：** 见 [core/extensions/README.md](../../core/extensions/README.md)；spec 源 [core/extensions/hooks/hooks.spec.yaml](../../core/extensions/hooks/hooks.spec.yaml) / [core/extensions/mcp/mcp.servers.template.json](../../core/extensions/mcp/mcp.servers.template.json)。
