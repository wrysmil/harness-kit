# Cursor Adapter

Cursor 适配分两层：

1. **投影层**（bootstrap 复制到项目根）：`.cursor/rules/`、`.agents/agents/`（共享子 Agent）、`.agents/skills/`（共享能力副本）、`.cursor/hooks/`（来自 extensions）
2. **绑定层**（留在 `harness-kit/adapters/cursor/`）：`bindings.md`、`capability-matrix.yaml`；编排 stub 重定向至 `core/orchestration/`

## 投影后应具备

- `.cursor/rules/ai-entry.mdc`、`cursor-subagent-routing.mdc`
- `.agents/agents/<role>.md`（共享层 agent manifest → `core/orchestration/agents/`）
- `.agents/skills/` 能力副本；WU skill 偏好 → `core/orchestration/skill-preferences.md`
- `.agents/skills/orchestration/SKILL.md`
- `.cursor/hooks/harness-*.sh` + `content/*.md` + `.cursor/hooks.json.example`（来自 [core/extensions/hooks](../../core/extensions/hooks/README.md)，**opt-in**：手动 `cp hooks.json.example hooks.json` 启用）

## 关键文档

| 文档 | 用途 |
| --- | --- |
| `../../core/orchestration/dispatcher-workflow.md` | 编排唯一步骤源 |
| `bindings.md` | Cursor 原语映射 |
| `capability-matrix.yaml` | parity 审计 |
| `../../core/orchestration/platform-adapters.zh.md` | 平台检测与角色映射 |
| `../../entrypoints/AGENTS.cursor-overlay.md` | Cursor 契约 |
| `../../core/routing.md` | 路由权威 |

上游改编来源见 `VENDOR.md`。

## 接入

先 `init/onboarding-handoff.txt`，再 `bash harness-kit/scripts/harness-project.sh project`（一次性投影 `.cursor/`、`.agents/`、`.mcp.json`、hooks 扩展）。

## Hooks（opt-in）

详见 [core/extensions/hooks/README.md](../../core/extensions/hooks/README.md)。`harness-project.sh project` 自动复制脚本与 `.example`，**默认不启用**；手动 `cp .cursor/hooks.json.example .cursor/hooks.json && chmod +x .cursor/hooks/*.sh` 启用。
