# Claude Code 平台绑定

| 原语 | Claude 绑定 |
| --- | --- |
| `DetectPlatform()` | CLAUDE.md 会话 + Skill 工具 → `claude` |
| `SpawnWorker(role)` | Task(subagent_type=generalPurpose) + `.agents/agents/<role>.md` 作 prompt 正文 |
| `SpawnWorker(reviewer)` | 新 Task 实例 + readonly 约束（**prompt 级约束**；subagent 仍能用 Write 工具——通过"独立实例 + prompt 纪律"维持，**不**是平台门禁） |
| `ParallelBatch` | 并行 Task（对齐 `dispatching-parallel-agents`）；不传 Leader 全历史 |
| `WorktreeInit` | 同 `scripts/harness-worktree.sh` / git worktree |
| `StructuredAsk` | `AskUserQuestion` 工具（单选/多选 + preview） |
| `EmitHook` | `SessionStart` / `SubagentStop`（来自 `core/extensions/hooks/`，写入 `.claude/settings.json`） |
| `LoadSkill(slug)` | Read `.agents/skills/<slug>/SKILL.md`；或 `Skill("<slug>")` 若已注册 |
| `LoadAgent(role)` | Read `.agents/agents/<role>.md` 作 Task prompt |
| `LoadCapability(orchestration.dispatch)` | `orchestration` skill → core dispatcher |
| `LoadExtension(hooks.<name>)` | 读 `core/extensions/hooks/hooks.spec.yaml` `bindings.claude` 段，复制 wrapper 脚本到 `.claude/hooks/`，合并到 `.claude/settings.json` |
| `LoadExtension(mcp.servers)` | 读 `core/extensions/mcp/mcp.servers.template.json`，复制到项目根 `.mcp.json`（已存在则跳过） |

**Claude Code 原生 plan 工具（必读）：**

- **禁止**调用 `EnterPlanMode` / `ExitPlanMode`。这两个工具会把 plan 落到 `~/.claude/plans/<auto-name>.md`，**绕开** Harness stage skill 流程、`plan.harness-overlay.md` FM/Next 契约与 `.ai-runtime-artifacts/plans/` 落盘规则，本会话**无门禁拦截**且产物不进 git / FM / `harness-check` 扫描。
- 写实施计划：Load `superpowers:writing-plans` skill → `artifact-templates/plan.harness-overlay.md` → `Write .ai-runtime-artifacts/plans/YYYY-MM-DD-<topic>-plan.md`（并行时另写同 stem `*-dispatch.md`）。
- 写方案：Load `superpowers:brainstorming` skill → `artifact-templates/spec.harness-overlay.md` → `Write .ai-runtime-artifacts/specs/...`。
- 强阻断（opt-in）：`core/extensions/hooks/` 提供 PreToolUse 钩子，匹配 `EnterPlanMode|ExitPlanMode` 直接 deny。默认未启用，启用见 hooks README 与 `.claude/settings.json.example`。
- 误用时回滚：把 `~/.claude/plans/<name>.md` 内容搬到 `.ai-runtime-artifacts/plans/<harness-name>.md` 并补 Harness FM（`route: superpowers:writing-plans`、`skills_evidence`、`## Next`）。

**产物落盘（强制）：**

所有 AI 过程产物必须写入 `.ai-runtime-artifacts/` 对应子目录。**禁止**写到 `docs/`、`项目根目录`、或其他位置。详见 `.claude/rules/ai-entry.md` § 产物落盘（强制）。

**委派 prompt 必含：** WU id、wu_type、agent_role、允许文件、禁止项、done criteria、worktree_path（若启用）、本 WU Skills、返回格式。

**降级记录：** matrix 为 `degraded` 时，DISPATCH-TRACK 写 `Detail: capability <id> degraded`。

**Hooks 与 MCP：** 见 [core/extensions/README.md](../../core/extensions/README.md)；spec 源 [core/extensions/hooks/hooks.spec.yaml](../../core/extensions/hooks/hooks.spec.yaml) / [core/extensions/mcp/mcp.servers.template.json](../../core/extensions/mcp/mcp.servers.template.json)。
