# Cursor Adapter

Cursor 适配分两层：

1. **投影层**（bootstrap 复制到项目根）：`.cursor/rules/`、`.cursor/agents/harness-*`、`.agents/skills/cursor-orchestration/`
2. **编排深读**（留在 `harness-kit/adapters/cursor/orchestration/`，不投影）：`dispatcher-workflow.md`、`agents/`、`tracking/`、`runtime/`

## 投影后应具备

- `.cursor/rules/ai-entry.mdc`、`cursor-subagent-routing.mdc`
- `.cursor/agents/harness-implementer.md`（及 reviewer / explorer / debugger）
- `.agents/skills/cursor-orchestration/SKILL.md`

可选 hooks：见 `orchestration/hooks/README.md`。

## 关键文档

| 文档 | 用途 |
| --- | --- |
| `orchestration/dispatcher-workflow.md` | 并行实现唯一完整步骤 |
| `orchestration/platform-adapters.zh.md` | 平台检测、子 Agent 映射 |
| `orchestration/runtime/plan-progress-sync.md` | plan 内 `- [ ]`→`- [√]` |
| `../../entrypoints/AGENTS.cursor-overlay.md` | Cursor 深读契约 |
| `../../core/routing.md` | 路由与阶段门禁（权威） |

上游改编来源见 `orchestration/VENDOR.md`。

## 接入

与通用 Harness 相同：先 `harness-kit/init/onboarding-handoff.txt`（详版 `init/bootstrap.prompt.md`），再投影 `adapters/cursor/.cursor/` 与 `adapters/agents/.agents/`。
