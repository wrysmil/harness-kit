# Code Reviewer Prompt Template

Use when filling the **harness-reviewer** dispatch prompt (Harness / Cursor).  
Generic superpowers flow may use Task `general-purpose`; **Harness 下必须用 `harness-reviewer`**（见 `SKILL.md` § Harness / Cursor 覆盖）。

**Purpose:** Review completed work against requirements and code quality standards before it cascades.

## Harness 委派（Cursor）

```text
Use the harness-reviewer subagent to review <WU-id | GROUP batch>.
Follow harness-kit/adapters/cursor/orchestration/agents/reviewer.md.
You did not implement this code. Readonly. Do not modify files.
```

## Prompt body（Leader / Coder 填入）

```
## What Was Implemented

{DESCRIPTION}

## Requirements / Plan

{PLAN_OR_REQUIREMENTS}

## Git Range to Review

**Base:** {BASE_SHA}
**Head:** {HEAD_SHA}

## What to Check

**Plan alignment:** match plan/spec; justified deviations only.

**Code quality:** separation of concerns, error handling, edge cases.

**Architecture / security / performance:** per reviewer.md 五轴.

**Testing:** what is covered; gaps.

## Output Format (required)

## 审查结论: APPROVE | BLOCK

### Findings
- [Critical] ...
- [Important] ...

### 证据
- 已运行/已读: ...

### 未验证项
- ...

### Skills 使用
- 已加载: requesting-code-review | 无
```

**Placeholders:** `{DESCRIPTION}`, `{PLAN_OR_REQUIREMENTS}`, `{BASE_SHA}`, `{HEAD_SHA}`

**Leader:** 将 Reviewer 返回写入 `artifact-templates/code-review.md` 路径；Reviewer 不 Write 文件。
