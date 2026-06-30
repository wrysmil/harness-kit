---
name: document-review
description: Use when reviewing any document (spec, design, plan) for completeness, clarity, and quality — especially environment preparation completeness. Triggers: review document, check document, audit spec, audit design, 审查文档, 检查文档, 文档审查
---

# Document Review

Systematic document review with type-specific rules. **Environment preparation** is a first-class check for design and plan documents.

**Core principle:** Missing environment setup causes more rework than missing features.

## When to Use

**Always:**
- Before approving a spec, design, or implementation plan
- When user asks to review, audit, or check a document
- After brainstorming, before writing-plans (optional gate on design docs)

**Document types:**
- Requirements / spec documents
- Architecture / technical design documents
- Implementation plans
- Environment / deployment configuration docs

## Document Type Detection

Read the document, then match keywords (first match wins; if multiple match, prefer design > plan > spec):

| Document signals | Type | Load rule file |
| --- | --- | --- |
| 需求, 用户故事, 功能, spec, requirement | Spec / requirements | `review-rules/spec.md` |
| 架构, 设计, 实现, API, 环境, 部署, design | Architecture / technical design | `review-rules/design.md` |
| 计划, plan, 任务, 阶段, Phase, Task | Implementation plan | `review-rules/plan.md` |

After detection, **Read** the matching rule file and `checklists/review-checklist.md`.

## Review Flow

```
1. DETECT document type
2. LOAD review-rules/<type>.md + checklists/review-checklist.md
3. REVIEW against rules (score each dimension)
4. OUTPUT report (use artifact-templates/document-review.md)
5. NEXT: pass → continue; fail → list missing items by priority
```

## Output Format

Write to `.ai-runtime-artifacts/reviews/YYYY-MM-DD-<topic>-document-review.md` using `artifact-templates/document-review.md`.

Required sections:
- Document type
- Rules loaded
- Scores: completeness, clarity, environment prep (if applicable)
- Missing items (priority ordered)
- Concrete improvement suggestions
- Next steps

## Integration

| Stage | Skill |
| --- | --- |
| Code self-test / Leader review | `requesting-code-review` (not this skill) |
| Implementation | `test-driven-development` + `writing-plans` (plans must have Phase 1 env prep) |
| Claiming done | `verification-before-completion` |

This skill reviews **documents only**, not source code.

## Red Flags — STOP

- Skipping environment preparation review on design/plan docs
- Surface-level review without listing specific missing items
- Approving a plan whose Phase 1 is not environment setup
- Reviewing code with this skill (use `requesting-code-review`)

## Rationalization Prevention

| Excuse | Reality |
| --- | --- |
| "Env setup is obvious" | List deps, env vars, services explicitly or fail |
| "We'll add tests later" | Plan must include test strategy now |
| "Doc is mostly complete" | Score each dimension; list gaps |
