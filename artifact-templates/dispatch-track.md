---
artifact: dispatch-track
route: cursor-orchestration:dispatcher-workflow
skills:
  - cursor-orchestration
source:
  - harness-kit/adapters/cursor/orchestration/tracking/schema.md
  - .ai-runtime-artifacts/plans/<plan-file>.md
created_at: YYYY-MM-DD
platform: cursor
topic: <topic>
---

# DISPATCH-TRACK — <topic>

Leader 维护。条目 **append-only**。

## 执行图

（从 plan 复制或链接 worktree）

## 日志

<!-- 在此追加条目，格式见 tracking/schema.md -->

```text
[YYYY-MM-DD HH:MM] DISPATCH-INIT | Leader | Status: started
Detail: 创建 track，plan=<path>
Sub-agents: 0
Output: none
Next: GROUP-1 派发
```

```text
[YYYY-MM-DD HH:MM] WU-02-worktree | Leader | Status: started
Detail: 创建 WU-02 worktree（<wu_title_zh>）
Output: .worktrees/<...>
Next: 派发 WU-02（worktree_path=<...> branch=<...>）
```
