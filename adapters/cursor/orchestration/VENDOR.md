# 上游来源

| 字段 | 值 |
| --- | --- |
| 上游 skill | harness-engineer |
| 版本 | 5.3.1 |
| 源路径 | `~/.cursor/skills/harness-engineer-5.3.0/` |
| 改编日期 | 2026-05-24 |
| harness-kit 方案 | CURSOR-HARNESS-INTEGRATION-PLAN.md 方案 B |

## 本目录改编来源

| harness-kit 文件 | 上游文件 |
| --- | --- |
| `platform-adapters.zh.md` | `references/platform-adapters.md` |
| `dispatcher-workflow.md` | `agents/dispatcher.md` |
| `agents/leader.md` | `agents/dispatcher.md`（Leader 摘要） |
| `agents/implementer.md` | `agents/implementer.md` |
| `agents/reviewer.md` | `agents/reviewer.md` |
| `agents/debugger.md` | `agents/debugger.md` |
| `tracking/schema.md` | `runtime/status-management.md` |
| `context-budget.md` | `runtime/context-engineering.md` |
| `model-routing.yaml` | `platform-adapters` + OMX 模型表（手写） |
| `artifact-templates/dispatch-track.md` 等 | 新建（harness-kit 产物契约） |
| `config.defaults.yaml` | `CONFIG.yaml`（简化） |
| `.cursor/rules/cursor-subagent-routing.mdc` | `SKILL.md` Rule 1–15 + platform-adapters |
| `.agents/skills/cursor-orchestration/SKILL.md` | dispatcher + context-engineering 摘要 |

## 未引入的上游模块

- `PLATFORM_REQUIREMENTS.md`（HALT 语义）→ 降级为 `CURSOR-PRECHECK.md`
- `runtime/loop.md` 全文
- `tools/tool-router.md`
- `docs/status/` 目录约定 → 合并至 `.ai-runtime-artifacts/execution-logs/`
