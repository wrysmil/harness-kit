# Code Reviewer Prompt Template（Harness）

**用途：** 填充 **harness-reviewer** 委派 prompt。集体审查由 Leader 落盘；WU 轻审由 Coder 整合返回。

## Cursor 委派

```text
Use the harness-reviewer subagent to review <WU-id | GROUP batch>.
Follow harness-kit/core/orchestration/agents/reviewer.md.
You did not implement this code. Readonly. Do not modify files.
```

## Prompt body（Leader / Coder 填入）

```markdown
## What Was Implemented
{DESCRIPTION}

## Requirements / Plan
{PLAN_OR_REQUIREMENTS}

## Scope（优先于 SHA）
- 文件：{FILE_LIST}
- diff 摘要：{DIFF_SUMMARY}

## Git Range（可选）
Base: {BASE_SHA}  Head: {HEAD_SHA}

## Output Format（required）
## 审查结论: APPROVE | BLOCK
### Findings
### 证据
### 未验证项
### Skills 使用
```

**Leader：** 集体审查返回 → Write `artifact-templates/code-review.md` 路径。
