---
artifact: implementation-plan
route: superpowers:writing-plans
skills:
  - writing-plans
skills_evidence:
  - ~/.agents/skills/writing-plans/SKILL.md
dispatch: .ai-runtime-artifacts/plans/YYYY-MM-DD-<topic>-dispatch.md
source:
  - AGENTS.md
  - harness-kit/core/routing.md
created_at: <YYYY-MM-DD>
status: draft
approved: false
---

# Harness overlay（非正文模板）

> **正文：** 按已 Load 的 **writing-plans** skill 撰写（Goal / Architecture / Tech Stack、Task 细步、Plan 自检等）。
> **禁止**用 `artifact-templates/plan.md` 历史短提纲替代 skill 流程。
> **路径：** `.ai-runtime-artifacts/plans/YYYY-MM-DD-<topic>-plan.md`
> **并行编排：** 另写同 stem 的 `*-dispatch.md`（模板 `dispatch.harness-overlay.md`）；单 WU / Tier 0 可在 FM 写 `dispatch: n/a`。
> **Cursor 执行：** 用户**单独**确认 plan（「开始实现」）后走 `cursor-orchestration` — **非** writing-plans 内的 executing-plans / subagent-driven-development。
> **禁止：** plan 写入同 session 内继续实现；同句「写计划然后执行」仅写 plan 并暂停（`routing.md` § 组合指令）。

## Next

**（写入后须暂停 — 即使用户句末含「然后执行」）**

- 计划确认 → 说「开始实现」或「执行」
- 需要调整 → 直接说修改意见
- 想拆分并行 → 审 `*-dispatch.md` 后说「开始实现」或「并行执行」
