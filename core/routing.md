# Harness Routing

## 总原则

- 默认 route 是强制基线。用户指定 skills 或工具时，默认理解为追加要求，不替代本文件的默认 route。
- 只有当用户明确说“不要使用默认 skills / 只使用某个 skill / 禁用某个 route”时，才允许跳过默认 route，并必须在回复或产物 front matter 中说明原因。
- 方案设计优先使用 `superpowers:brainstorming`。
- 已批准设计后的实施计划使用 `superpowers:writing-plans`。
- 多 task 编码、并行执行、复杂审查和验证修复：
  - **Codex CLI**：使用 `oh-my-codex` 的 `omx` 工作流（如 `omx ultrawork`）
  - **Cursor**：使用 `cursor-orchestration:dispatcher-workflow`（`.cursor/agents/` subagent 并行，见 `harness-kit/adapters/cursor/orchestration/`）
- 小改动和单文件机械修改由当前助手直接处理。
- 项目级 skill 优先于通用 skill。
- **Git 协作**：组织级分支、提交、MR、热修、合流默认 invoke **`git-xywh`** skill；本项目差异与 AI 约束见 `harness-kit/project.git.md`（不将 skill 全文复制进仓库）。

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

| 任务类型 | Codex Route | Cursor Route | 产物 |
| --- | --- | --- | --- |
| 需求澄清 / 方案设计 / 行为变更 | `superpowers:brainstorming` | `superpowers:brainstorming` | `.ai-runtime-artifacts/specs/` |
| 实施计划 | `superpowers:writing-plans` | `superpowers:writing-plans` | `.ai-runtime-artifacts/plans/` |
| 多 task 编码 / 并行实现 | `omx ultrawork` 或等价 omx 工作流 | `cursor-orchestration:dispatcher-workflow` | `.ai-runtime-artifacts/execution-logs/` + 代码变更 |
| 代码审查 / 验证 | `superpowers:verification-before-completion` | `superpowers:verification-before-completion` | `.ai-runtime-artifacts/verifications/` |
| 缺陷调查 | `superpowers:systematic-debugging` 或 `omx` debugger 路由 | `superpowers:systematic-debugging` + `harness-debugger` 或 `harness-explorer` | `.ai-runtime-artifacts/specs/` 或 `.ai-runtime-artifacts/verifications/` |
| 验证 / 修复循环 | `omx` verify/fix 或 `superpowers:verification-before-completion` | `superpowers:verification-before-completion` + 独立 `harness-reviewer` | `.ai-runtime-artifacts/verifications/` |
| 架构决策 | architect / critic / planner 组合 | Task `generalPurpose`（只读）× 多轮 + decision 产物 | `.ai-runtime-artifacts/decisions/` |
| 文章 / 知识沉淀 / 对外文档 | `superpowers:brainstorming` + 写作风格 skill + 文档发布 skill | 同左 | `.ai-runtime-artifacts/retros/` 或用户指定位置 |
| 小改动 / 单文件机械修改 | 直接处理 | 直接处理 | 无需产物 |
| 建分支 / 提交 / rebase / 开 MR·PR | `git-xywh` + `project.git.md` | 同左 | 无（或用户要求的 MR 链接） |
| 热修 / 提测线 `test/v*` / 合流 / 打标签 | `git-xywh` + `project.git.md` | 同左 | 无 |
| Harness 脚手架变更提交 | `git-xywh`（类型 `chore`，范围 `harness-kit`） | 同左 | 与业务 commit 分离 |

### "小改动"判定标准

以下情况**不属于**小改动，必须走路由表产出产物：

- 涉及 3 个以上文件的代码审查或 diff 分析
- 用户要求"审核"、"review"、"检查"代码质量或正确性
- 作为实施流程末尾的验证步骤（无论用户是否显式说"验证"）
- 需要跨模块理解才能给出结论的分析

## 阶段门禁

写入下列产物后**须暂停**，等用户在本会话明确继续，再进入下一阶段。此规则优先于 AGENTS.md 自主性指令。

| 阶段 | 产物 | 暂停后用户可说 |
| --- | --- | --- |
| 设计完成 | `.ai-runtime-artifacts/specs/` | 「写计划」「直接实现」或给修改意见 |
| 计划完成 | `.ai-runtime-artifacts/plans/` | 「开始实现」「并行执行」或给修改意见 |
| 决策完成 | `.ai-runtime-artifacts/decisions/` | 「执行」 |

**已批准** = 用户说过上表继续指令，或任务开头一次性授权该跳转（须记录在产物 front matter 或回复中）。

**Cursor 实现阶段：** 用户说「开始实现」后，Leader 须委派 `.cursor/agents/harness-implementer`，不得在主线程直接改业务代码（「小改动」除外）。详见 `.cursor/rules/cursor-subagent-routing.mdc`。

## Git 协作

| 规则 | 说明 |
| --- | --- |
| 组织规范来源 | **`git-xywh` skill**（三主干、五类临时分支、Angular 提交、MR 流程） |
| 项目差异来源 | **`harness-kit/project.git.md`**（MR 平台、commitlint、是否允许 AI push、Harness 独立 commit 等） |
| 谁执行 Git | **Leader / 主 Agent**；`harness-implementer` 等子 Agent 默认不 commit/push |
| 与默认 route 关系 | Git 任务在对应阶段**叠加** `git-xywh`（例如实现完成后的提交不替代 `verification-before-completion`） |
| skill 未安装 | 说明缺失，按 `project.git.md` 与仓库已有配置（`.husky`、`commitlint`、CI）执行；运行 `bash harness-kit/scripts/install-ai-skills.sh` 检查路径 |
| **如何 invoke** | 有 Skill 工具 → 加载 **`git-xywh`**；否则 Read 本机 skill 文件（见 `project.git.md` § 如何调用）。步骤见 `core/runbooks.md` § Git 协作 |

**Harness 声明示例：** `「Harness：git-xywh + project.git.md」`（用户仅说「提交代码」时）

**注意：** 路由表中的 `git-xywh` 指**必须先加载该 skill 正文**再执行 git，不是仅阅读 `project.git.md` 或 `routing.md` 即够。

## 运行约束

- **强制声明（每次任务必须）：** 收到用户任务后，第一句话必须声明 harness 判定结果，格式为 `「Harness：<route 或 "小改动，直接处理">」`。无论任务大小，必须有这一行，证明已经过路由判定。如果判定为小改动，直接打印声明后开始处理。
- **未声明时的用户干预：** 如果 AI 响应第一句不是 `「Harness：...」`，说明规则未被加载或被忽略。用户应发送：`请先读取 CLAUDE.md 和 harness-kit/core/routing.md，按 harness 规范重新处理我的上一个请求。`
- 执行非小型任务前，先在过程产物或回复中声明本次 route、skills 和 source。
- route 必须同时体现默认 skills 和用户指定 skills；如果跳过默认 skills，必须记录用户的明确排除指令。
- **Codex**：调用 `omx` 前写清目标、范围、禁止事项和验收标准；`omx` 输出只作为建议，主执行者必须复核后才能落地。
- **Cursor**：委派 `.cursor/agents/harness-*` subagent 前写清 WU 目标、文件列表、禁止事项与 done criteria；子 Agent 输出须由主 Agent 整合并验证后再落地。
- 任何完成声明前必须有验证证据。
