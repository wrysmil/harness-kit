# Claude Code 适配器

第二参考实现：Task 并行 + core 编排语义。

## 接入

1. 根目录 `CLAUDE.md` + `AGENTS.md`
2. 投影 skill：`bash harness-kit/scripts/install-ai-skills.sh`（含 `claude-orchestration`）
3. 多 task 实现：Load **`claude-orchestration`** → `core/orchestration/dispatcher-workflow.md`

## 平台检测

`CLAUDE.md` 会话 + Skill 工具 + 无 Cursor → `platform: claude`

## 与 Cursor 差异

| 能力 | 状态 |
| --- | --- |
| `interaction.structured-ask` | supported — AskUserQuestion 工具 |
| `hooks.session-lifecycle` | supported — .claude/settings.json hooks |
| `orchestration.continuous-loop` | manual — 多会话 HANDOFF |
| Task `ci-investigator` | degraded — generalPurpose + 只读 |

parity 全表：`capability-matrix.yaml`。绑定：`bindings.md`。
