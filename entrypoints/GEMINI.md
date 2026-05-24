# GEMINI.md

项目背景：{{PROJECT_BACKGROUND}}

---

## Harness 规则（强制）

本项目使用 `cow-harness/` 工程标准。以下规则在每个会话中自动生效。

### 任务前检查清单

在任何**非琐碎**任务之前，你必须：

1. 阅读 `cow-harness/project.profile.md` 与 `cow-harness/context-map.md`
2. 使用下表为任务路由，并声明所选路由
3. 遵循对应 runbook，将产物写入 `.ai-runtime-artifacts/`

### 路由表

| 任务类型 | 路由 | 产物目录 |
|-----------|-------|--------------|
| 需求 / 设计 / 行为变更 | `superpowers:brainstorming` | `.ai-runtime-artifacts/specs/` |
| 实现计划 | `superpowers:writing-plans` | `.ai-runtime-artifacts/plans/` |
| 多任务编码 / 并行实现 | `omx ultrawork` 或等价工作流 | `.ai-runtime-artifacts/execution-logs/` + 代码变更 |
| 代码审查 / 验证 | `superpowers:verification-before-completion` | `.ai-runtime-artifacts/verifications/` |
| 缺陷调查 | `superpowers:systematic-debugging` | `.ai-runtime-artifacts/verifications/` |
| 架构决策 | architect / critic / planner | `.ai-runtime-artifacts/decisions/` |
| 小改动 / 单文件机械编辑 | 直接处理 | 无需产物 |

### 「小改动」判定标准

以下情况**不属于**小改动 — 必须产出产物：

- 涉及 3 个及以上文件的代码审查或 diff 分析
- 用户明确要求「审核」「review」或「check」代码质量
- 实现流程末尾的验证步骤（即使用户未说「verify」）
- 需要跨模块理解的分析

### Runbook 摘要

**新功能：** spec（specs/）→ 计划决策（复杂则写计划，否则跳过）→ 编码（**必须**使用 `omx ultrawork` 或等价 omx 工作流）→ execution-log（execution-logs/）→ 验证（verifications/）

**缺陷修复：** 根因 → 修复（**必须**使用 `omx` 工作流）→ execution-log（execution-logs/）→ 验证（verifications/）

**架构决策：** 比较选项 → 决策记录（decisions/），**必须**包含采纳/拒绝方案、约束与风险

### 产物格式

每个产物文件**必须**以 YAML front matter 开头，包含：`artifact`、`route`、`skills`、`source`、`created_at`。详见 `cow-harness/core/artifacts.md`。

### 约束

- **强制声明（每个任务）：** 回复第一行**必须**为 `「Harness：<路由或「小改动，直接处理」>」`。这证明已评估路由。对小改动任务，打印声明后直接继续。
- **未声明时用户干预：** 若 AI 回复未以 `「Harness：...」` 开头，说明规则未加载。用户应发送：`请先读取 CLAUDE.md 和 cow-harness/core/routing.md，按 harness 规范重新处理我的上一个请求。`
- 非琐碎任务前，声明路由、技能与来源
- 任何完成声明**必须**附带验证证据
- 默认路由是强制基线；用户指定技能为附加项，而非替代项

---

详细规范参见：`cow-harness/core/routing.md`、`cow-harness/core/artifacts.md`、`cow-harness/core/runbooks.md`、`cow-harness/core/verification.md`。

若本文件与 `AGENTS.md` 有冲突，以 `AGENTS.md` 为准。
