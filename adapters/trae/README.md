# Trae 平台适配器

> **状态：** 骨架 — 大部分能力待定义（`degraded`）。

## 目录

- `bindings.md` — 原语 → Trae 绑定映射
- `capability-matrix.yaml` — 26 项能力状态

## 共享层

Trae 引用 `adapters/agents/.agents/` 中的共享 skill 和 agent manifest。

## 待完成

- [ ] 确认 Trae subagent/Task 机制 → 更新 `bindings.md`
- [ ] 确认 Trae skill 发现路径 → 更新 `LoadSkill` 绑定
- [ ] 逐项将 `degraded` → `supported`（按实际能力）
- [ ] 创建 `.trae/` 项目目录结构（如需要）
