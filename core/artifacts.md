# Artifact Contract

## 目录

AI 过程产物统一放在项目根目录 `.ai-runtime-artifacts/`：

| 目录 | 用途 |
| --- | --- |
| `.ai-runtime-artifacts/specs/` | 需求理解、方案设计、设计说明 |
| `.ai-runtime-artifacts/plans/` | 实施计划、任务拆解 |
| `.ai-runtime-artifacts/reviews/` | 代码审查、方案审查 |
| `.ai-runtime-artifacts/verifications/` | 验证报告、doctor 输出摘要、测试结果 |
| `.ai-runtime-artifacts/decisions/` | 架构决策、技术取舍 |
| `.ai-runtime-artifacts/retros/` | 复盘、阶段总结 |

## 文件命名

```text
YYYY-MM-DD-<topic>-<artifact>.md
```

示例：

```text
2026-05-14-ai-agent-harness-spec.md
2026-05-14-ai-agent-harness-plan.md
2026-05-14-ai-agent-harness-verification.md
```

## Front Matter

每个过程产物必须以 YAML front matter 开头：

```yaml
---
artifact: implementation-plan
route: superpowers:brainstorming -> superpowers:writing-plans
skills:
  - superpowers:brainstorming
  - superpowers:writing-plans
source:
  - AGENTS.md
  - cow-harness/core/routing.md
created_at: 2026-05-14
---
```

必填字段：

| 字段 | 说明 |
| --- | --- |
| `artifact` | 产物类型 |
| `route` | 本次任务经过的路由 |
| `skills` | 实际使用的 skills 或工具能力 |
| `source` | 产物依据的入口、规则、需求或上下文 |
| `created_at` | 创建日期，格式 `YYYY-MM-DD` |

## Artifact 类型

- `spec`
- `implementation-plan`
- `review`
- `verification`
- `execution-log`
- `decision-record`
- `retro`
- `article`
- `runbook`
- `project-profile`
- `context-map`

## 规则

- 过程产物必须写清 route 和 skills。
- 如果用户指定了额外 skills，route 和 skills 必须同时包含默认 route 与用户指定 skills。
- 如果跳过默认 skills，source 或正文必须记录用户明确要求跳过的原因。
- 过程产物必须写清 source 和 created_at。
- 验证类产物必须写清命令、结果和未验证项。
- 架构决策必须写清接受方案、拒绝方案和原因。
- 不在过程产物里记录 secret 或 provider 配置。
