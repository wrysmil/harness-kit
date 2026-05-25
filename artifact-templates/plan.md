---
artifact: implementation-plan
route: <route>
skills:
  - <skill>
source:
  - AGENTS.md
  - harness-kit/core/routing.md
created_at: <YYYY-MM-DD>
---

# <Topic> Implementation Plan

## 目标

## 文件结构

## 任务

> Implementer 每步验收通过后，在本文件中把对应行 `- [ ]` 改为 `- [√]`（见 `harness-kit/adapters/cursor/orchestration/runtime/plan-progress-sync.md`）。**不要**只在聊天里输出勾选。

并行实现时，Leader 拆 WU 并标注 `wu_type` / `wu_skills`（推荐 **`auto`**，查 `harness-kit/adapters/cursor/orchestration/skill-preferences.zh.md`）。

- [ ] 步骤 1：…
- [ ] 步骤 2：…

## 执行图（并行时由 Leader 填写，可选）

```markdown
GROUP-1:
  WU-01: … | 文件: … | wu_type: feature | wu_skills: auto
```

## 验证

## 风险

## Next

**（写入后须暂停，等用户明确继续 — 见 `harness-kit/core/routing.md` § 阶段门禁）**

- 计划确认 → 说「开始实现」或「执行」
- 需要调整 → 直接说修改意见
- 想拆分并行 → 说「并行执行」
