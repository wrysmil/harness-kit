# Harness Routing

## 总原则

- 默认 route 是强制基线。用户指定 skills 或工具时，默认理解为追加要求，不替代本文件的默认 route。
- 只有当用户明确说“不要使用默认 skills / 只使用某个 skill / 禁用某个 route”时，才允许跳过默认 route，并必须在回复或产物 front matter 中说明原因。
- 方案设计优先使用 `superpowers:brainstorming`。
- 已批准设计后的实施计划使用 `superpowers:writing-plans`。
- 多 task 编码、并行执行、复杂审查和验证修复使用 `oh-my-codex` 的 `omx` 工作流。
- 小改动和单文件机械修改由当前助手直接处理。
- 项目级 skill 优先于通用 skill。

## 用户指定 Skills 的合并规则

用户在任务中指定 skills 时，按下面规则合并：

| 用户表达 | 执行方式 |
| --- | --- |
| “用 X skill 做这件事” | 先执行默认 route，再叠加 X skill |
| “参考 X 风格 / 用 X 发布” | 先执行默认 route，再在对应阶段使用 X |
| “只用 X / 不要用默认 skill / 禁用 Y” | 按用户排除项执行，并记录跳过默认 route 的原因 |
| 用户指定 skill 与默认 route 冲突 | 先说明冲突，再选择满足用户强约束的最小 route |

示例：用户要求“按 writing-style 写文章并发飞书”，默认 route 仍应是 `superpowers:brainstorming -> writing-style -> lark-doc`，而不是只执行 `writing-style -> lark-doc`。

## 路由表

| 任务类型 | Route | 产物 |
| --- | --- | --- |
| 需求澄清 / 方案设计 / 行为变更 | `superpowers:brainstorming` | `.ai-runtime-artifacts/specs/` |
| 实施计划 | `superpowers:writing-plans` | `.ai-runtime-artifacts/plans/` |
| 多 task 编码 / 并行实现 | `omx ultrawork` 或等价 omx 工作流 | `.ai-runtime-artifacts/execution-logs/` + 代码变更 |
| 代码审查 / 验证 | `superpowers:verification-before-completion` | `.ai-runtime-artifacts/verifications/` |
| 缺陷调查 | `superpowers:systematic-debugging` 或 `omx` debugger 路由 | `.ai-runtime-artifacts/specs/` 或 `.ai-runtime-artifacts/verifications/` |
| 验证 / 修复循环 | `omx` verify/fix 或 `superpowers:verification-before-completion` | `.ai-runtime-artifacts/verifications/` |
| 架构决策 | architect / critic / planner 组合 | `.ai-runtime-artifacts/decisions/` |
| 文章 / 知识沉淀 / 对外文档 | `superpowers:brainstorming` + 写作风格 skill + 文档发布 skill | `.ai-runtime-artifacts/retros/` 或用户指定位置 |
| 小改动 / 单文件机械修改 | 直接处理 | 无需产物 |

### "小改动"判定标准

以下情况**不属于**小改动，必须走路由表产出产物：

- 涉及 3 个以上文件的代码审查或 diff 分析
- 用户要求"审核"、"review"、"检查"代码质量或正确性
- 作为实施流程末尾的验证步骤（无论用户是否显式说"验证"）
- 需要跨模块理解才能给出结论的分析

## 运行约束

- **强制声明（每次任务必须）：** 收到用户任务后，第一句话必须声明 harness 判定结果，格式为 `「Harness：<route 或 "小改动，直接处理">」`。无论任务大小，必须有这一行，证明已经过路由判定。如果判定为小改动，直接打印声明后开始处理。
- **未声明时的用户干预：** 如果 AI 响应第一句不是 `「Harness：...」`，说明规则未被加载或被忽略。用户应发送：`请先读取 CLAUDE.md 和 cow-harness/core/routing.md，按 harness 规范重新处理我的上一个请求。`
- 执行非小型任务前，先在过程产物或回复中声明本次 route、skills 和 source。
- route 必须同时体现默认 skills 和用户指定 skills；如果跳过默认 skills，必须记录用户的明确排除指令。
- 调用 `omx` 前写清目标、范围、禁止事项和验收标准。
- `omx` 输出只作为建议；主执行者必须复核后才能落地。
- 任何完成声明前必须有验证证据。
