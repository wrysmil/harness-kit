# Cursor Adapter

Cursor 适配分两层：

1. **投影层**（bootstrap 复制到项目根）：`.cursor/rules/`、`.cursor/agents/harness-*`、`.cursor/skills/`、`.agents/skills/cursor-orchestration/`
2. **绑定层**（留在 `harness-kit/adapters/cursor/`）：`bindings.md`、`capability-matrix.yaml`；编排 stub 重定向至 `core/orchestration/`

## 投影后应具备

- `.cursor/rules/ai-entry.mdc`、`cursor-subagent-routing.mdc`
- `.cursor/agents/harness-*.md`（薄壳 → `core/orchestration/agents/`）
- `.cursor/skills/` 能力副本；WU skill 偏好 → `core/orchestration/skill-preferences.md`
- `.agents/skills/cursor-orchestration/SKILL.md`

## 关键文档

| 文档 | 用途 |
| --- | --- |
| `../../core/orchestration/dispatcher-workflow.md` | 编排唯一步骤源 |
| `bindings.md` | Cursor 原语映射 |
| `capability-matrix.yaml` | parity 审计 |
| `orchestration/platform-adapters.zh.md` | 平台检测（历史） |
| `../../entrypoints/AGENTS.cursor-overlay.md` | Cursor 契约 |
| `../../core/routing.md` | 路由权威 |

上游改编来源见 `orchestration/VENDOR.md`。

## 接入

先 `init/onboarding-handoff.txt`，再投影 `adapters/cursor/.cursor/` 与 `adapters/agents/.agents/`。
