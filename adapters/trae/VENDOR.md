# 上游来源

| 字段 | 值 |
| --- | --- |
| 上游 skill | orchestration |
| 版本 | 1.0.0 |
| 源路径 | `harness-kit` |
| 改编日期 | 2026-06-16 |

## 版本策略

基于 harness-kit 自身架构设计，参考 Claude Code 和 Cursor 的适配模式。

## 本目录改编来源

| harness-kit 文件 | 上游文件 |
| --- | --- |
| `platform-adapters.zh.md` | 平台适配参考 |
| `dispatcher-workflow.md` | `core/orchestration/dispatcher-workflow.md` |
| `agents/leader.md` | `core/orchestration/agents/leader.md` |
| `agents/coder.md` | `core/orchestration/agents/coder.md` |
| `agents/reviewer.md` | `core/orchestration/agents/reviewer.md` |
| `agents/debugger.md` | `core/orchestration/agents/debugger.md` |
| `tracking/schema.md` | `tracking/schema.md` |
| `artifact-templates/dispatch-track.md` 等 | 新建（harness-kit 产物契约） |
| `.trae/rules/ai-entry.md` | 自 `adapters/cursor/.cursor/rules/ai-entry.mdc` 改编 |
| `.trae/rules/trae-subagent-routing.md` | 自 `adapters/cursor/.cursor/rules/cursor-subagent-routing.mdc` 改编 |
| `config.defaults.yaml` | 自 `core/orchestration/config.defaults.yaml` 简化 |
| `bindings.md` | 自 `adapters/claude/bindings.md` 和 `adapters/cursor/bindings.md` 改编 |
| `.trae/TRAE-PRECHECK.md` | 自 `adapters/cursor/.cursor/CURSOR-PRECHECK.md` 改编 |

## 平台特性

- **Agent 模式**：自主规划+执行，作为编排 Leader
- **规则文件**：`.trae/rules/` 支持项目级规则
- **Structured Ask**：原生提问机制（通过 Task 工具）
- **Hooks**：类似 hooks 的扩展机制
