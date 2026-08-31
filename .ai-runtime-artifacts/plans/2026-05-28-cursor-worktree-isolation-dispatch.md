---
artifact: implementation-dispatch
route: cursor-orchestration:dispatcher-workflow
plan: .ai-runtime-artifacts/plans/2026-05-28-cursor-worktree-isolation-plan.md
skills:
  - writing-plans
  - cursor-orchestration
skills_evidence:
  - ~/.agents/skills/writing-plans/SKILL.md
source:
  - harness-kit/adapters/cursor/orchestration/dispatcher-workflow.md
  - docs/superpowers/specs/2026-05-28-cursor-git-worktree-isolation-for-subagents-design.md
created_at: 2026-05-28
platform: cursor
---

# Cursor worktree isolation — Harness 执行图

> 本文件描述并行 GROUP/WU 与 worktree 分配；实施细步以 plan 为准。

## 执行图

```markdown
GROUP-1（并行，满足 2+ coder WU ⇒ 强制 worktree）:
  WU-01: 定义执行图与追踪字段（文档/模板） | 标题: 为 dispatch/track 增加 worktree 字段 | 文件: artifact-templates/dispatch.harness-overlay.md, adapters/cursor/orchestration/dispatcher-workflow.md, adapters/cursor/orchestration/tracking/schema.md, artifact-templates/dispatch-track.md | wu_type: chore | agent_role: implementer | workspace_scope: none | worktree_path: n/a | branch: n/a
  WU-02: 实现 worktree 管理脚本 | 标题: 新增 harness-worktree.sh | 文件: scripts/harness-worktree.sh, scripts/harness-worktree.test.sh | wu_type: feature | agent_role: coder | workspace_scope: wu | worktree_path: .worktrees/2026-05-28--cursor-worktree-isolation__WU-02__feature__coder | branch: wu/2026-05-28/cursor-worktree-isolation/WU-02-feature
  WU-03: 写入“2+ coder WU 强制 worktree”规则 | 标题: 强化 dispatcher-workflow 规则 | 文件: adapters/cursor/orchestration/dispatcher-workflow.md, adapters/cursor/orchestration/agents/leader.md, scripts/harness-worktree.test.sh | wu_type: chore | agent_role: coder | workspace_scope: wu | worktree_path: .worktrees/2026-05-28--cursor-worktree-isolation__WU-03__chore__coder | branch: wu/2026-05-28/cursor-worktree-isolation/WU-03-chore
```

## worktree 命名说明（英文主键 + 中文展示）

- worktree 路径格式：
  - `.worktrees/<YYYY-MM-DD>--<topic-slug>__WU-<id>__<wu_type>__<agent_role>`
- 分支格式：
  - `wu/<YYYY-MM-DD>/<topic-slug>/WU-<id>-<wu_type>`
- 中文可读：
  - 执行图 WU 行的 `标题:` 字段（对应 spec 的 `wu_title_zh`）

## Next

- 你确认 plan/dispatch 后，对我说「开始实现」或「并行执行」。

