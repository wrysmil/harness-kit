# Trae 平台适配器

> **状态：** 完整适配 — 所有核心能力已绑定。

## 目录

- `bindings.md` — 原语 → Trae 绑定映射
- `capability-matrix.yaml` — 26 项能力状态
- `.trae/rules/` — 平台规则文件

## 共享层

Trae 引用 `adapters/agents/.agents/` 中的共享 skill 和 agent manifest。

## 平台特性

- **Agent 模式**：自主规划+执行，作为编排 Leader
- **规则文件**：`.trae/rules/` 支持项目级规则
- **Structured Ask**：原生提问机制
- **Hooks**：类似 hooks 的扩展机制

## 编排

使用 `trae-orchestration` skill → `core/orchestration/dispatcher-workflow.md`
