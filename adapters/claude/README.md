# Claude Code 适配器

第二参考实现：Task 并行 + core 编排语义 + extensions 扩展（hooks / MCP）。

## 接入

1. 根目录 `CLAUDE.md` + `AGENTS.md`
2. 投影 skill + extensions：`bash harness-kit/scripts/harness-project.sh project`（含 `orchestration` skill、hooks 脚本与配置示例、`.mcp.json`）
3. 多 task 实现：Load **`orchestration`** → `core/orchestration/dispatcher-workflow.md`

## 平台检测

`CLAUDE.md` 会话 + Skill 工具 + 无 Cursor → `platform: claude`

## 与 Cursor 差异

| 能力 | 状态 |
| --- | --- |
| `interaction.structured-ask` | supported — AskUserQuestion 工具 |
| `hooks.session-lifecycle` | supported — `.claude/settings.json` hooks（`harness-project.sh` 自动生成 `.example`） |
| `extensions.mcp.servers` | supported — 项目根 `.mcp.json`（事实标准，无需 adapter 翻译） |
| `orchestration.continuous-loop` | manual — 多会话 HANDOFF |
| Task `ci-investigator` | degraded — generalPurpose + 只读 |

parity 全表：`capability-matrix.yaml`。绑定：`bindings.md`。

## Hooks（opt-in）

`harness-project.sh project` 会复制 hooks 脚本到 `.claude/hooks/` 并生成 `.claude/settings.json.example`，**默认不启用**。启用步骤：

```bash
ls .claude/hooks/harness-*.sh           # 确认脚本已投影
# 把 .claude/settings.json.example 的 hooks 段合并到 .claude/settings.json
# （harness-project.sh 不覆盖用户已有 settings.json）
chmod +x .claude/hooks/*.sh
```

Hook 内容与 Cursor 完全共享（来自 `core/extensions/hooks/content/`），仅 wrapper 脚本的 JSON wire format 不同。详见 [core/extensions/hooks/README.md](../../core/extensions/hooks/README.md)。

## MCP

`harness-project.sh project` 会把 `core/extensions/mcp/mcp.servers.template.json` 复制到项目根 `.mcp.json`（**仅在文件不存在时**，避免覆盖用户配置）。详见 [core/extensions/mcp/README.md](../../core/extensions/mcp/README.md)。
