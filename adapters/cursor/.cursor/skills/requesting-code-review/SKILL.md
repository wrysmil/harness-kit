---
name: requesting-code-review
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements
---

# Requesting Code Review

Dispatch a code reviewer subagent to catch issues before they cascade. The reviewer gets precisely crafted context for evaluation — never your session's history. This keeps the reviewer focused on the work product, not your thought process, and preserves your own context for continued work.

**Core principle:** Review early, review often.

## When to Request Review

**Mandatory:**
- After each task in subagent-driven development
- After completing major feature
- Before merge to main

**Optional but valuable:**
- When stuck (fresh perspective)
- Before refactoring (baseline check)
- After fixing complex bug

## How to Request

**1. Get git SHAs:**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. Dispatch code reviewer subagent:**

Use Task tool with `general-purpose` type, fill template at `code-reviewer.md`

**Placeholders:**
- `{DESCRIPTION}` - Brief summary of what you built
- `{PLAN_OR_REQUIREMENTS}` - What it should do
- `{BASE_SHA}` - Starting commit
- `{HEAD_SHA}` - Ending commit

**3. Act on feedback:**
- Fix Critical issues immediately
- Fix Important issues before proceeding
- Note Minor issues for later
- Push back if reviewer is wrong (with reasoning)

## Example

```
[Just completed Task 2: Add verification function]

You: Let me request code review before proceeding.

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[Dispatch code reviewer subagent]
  DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types
  PLAN_OR_REQUIREMENTS: Task 2 from docs/superpowers/plans/deployment-plan.md
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661

[Subagent returns]:
  Strengths: Clean architecture, real tests
  Issues:
    Important: Missing progress indicators
    Minor: Magic number (100) for reporting interval
  Assessment: Ready to proceed

You: [Fix progress indicators]
[Continue to Task 3]
```

## Integration with Workflows

**Subagent-Driven Development:**
- Review after EACH task
- Catch issues before they compound
- Fix before moving to next task

**Executing Plans:**
- Review after each task or at natural checkpoints
- Get feedback, apply, continue

**Ad-Hoc Development:**
- Review before merge
- Review when stuck

## Red Flags

**Never:**
- Skip review because "it's simple"
- Ignore Critical issues
- Proceed with unfixed Important issues
- Argue with valid technical feedback

**If reviewer wrong:**
- Push back with technical reasoning
- Show code/tests that prove it works
- Request clarification

See template at: requesting-code-review/code-reviewer.md

---

## Harness / Cursor 覆盖（强制）

在 **Harness Kit + Cursor** 下，本节优先于上文「Task general-purpose」：

### 委派谁

| 场景 | 机制 |
| --- | --- |
| WU 轻量审查 | Coder Load 本 skill → 委派 **`harness-reviewer`**（与实现 **不同实例**） |
| 尾盘集体审查 | Leader Load 本 skill → 委派 **`harness-reviewer`** |
| **禁止** | 无 `harness-reviewer` 约束的裸 `generalPurpose` Task |

Prompt 正文：`harness-kit/adapters/cursor/orchestration/agents/reviewer.md`；可选占位符见同目录 `code-reviewer.md`。

### 落盘（禁止仅对话输出）

| 角色 | 职责 |
| --- | --- |
| `harness-reviewer` | readonly；**只返回** `APPROVE` \| `BLOCK` + Findings |
| **Leader** | 收到返回后 **Write** `.ai-runtime-artifacts/reviews/YYYY-MM-DD-<topic>-code-review.md`（`artifact-templates/code-review.md`） |

### 与尾盘集体测试的顺序

GROUP 收尾：**先**集体测试（`collective-test.md`）**再**本 skill 集体审查。细则：`docs/superpowers/specs/2026-05-28-batch-closeout-review-and-collective-test.md`。
