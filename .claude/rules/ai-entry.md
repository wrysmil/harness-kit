# Claude Harness 入口

> 本规则在所有 Claude Code 会话开始时自动加载（无 `paths` → always-loaded）。
> 作用：引导 Claude 读 harness 入口、按 harness 流程执行。

## 项目使用 harness-kit 工程标准

**必读（按序）：**

1. `harness-kit/entrypoints/HARNESS-PLATFORM-ENTRY.md` — 项目背景 + Harness 规则（强制）+ Claude Code 专章
2. 根目录 `AGENTS.md` — Harness 覆盖层；与 `HARNESS-PLATFORM-ENTRY.md` 冲突时以 `AGENTS.md` 为准
3. `harness-kit/core/routing.md` — 路由、阶段门禁、按判定加载

**按需读（先 Load 再交付，勿在会话开始预读）：**

| 判定 | 加载 |
| --- | --- |
| 设计 / spec | `brainstorming` skill → `core/artifacts.md` |
| 计划 | `writing-plans` skill → `artifacts.md` + `artifact-templates/plan.harness-overlay.md` |
| 验证 / 跑命令 | `verification-before-completion` skill → `project.verification.md` |
| 尾盘 / GROUP 收尾 | `verification-before-completion` → `requesting-code-review` |
| Git 任务 / 提交 / MR | `git-xywh` skill + `project.git.md` + `core/runbooks.md` § Git 协作 |
| 多 task 实现 | `orchestration` skill → `core/orchestration/dispatcher-workflow.md` |
| 文档审查 | `document-review` skill → `artifact-templates/document-review.md` |
| 改代码 / 验证（实现阶段） | `project.profile.md`、`context-map.md`（涉及模块时） |

## 执行约定

- **首行声明：** `「Harness：<route 或 "Tier 0 小改动" | "Tier 1 Leader 直做">」`
- **stage skill / Tier 1+ 次行：** `Skills: <slug>@<path> loaded|skipped`（**先 Load 再交付**）
- **沟通语言：** 对用户回复、子 Agent 派发 prompt、整合反馈使用**中文**（`core/routing.md` § 沟通语言）
- **文件写入与阶段门禁：** 见 `HARNESS-PLATFORM-ENTRY.md` § 阶段门禁 + `core/routing.md` § 阶段门禁

## 文件写入（强制）

- 改仓库内文本（源码、配置、`.ai-runtime-artifacts/`）**只用** `Write` / `Edit`；改前先 `Read`
- **Shell 仅用于** 测试、lint、构建、git、只读查询
- **禁止** Shell 写文本（`Set-Content`、`Out-File`、`echo … >`、`type … >`、无 `encoding='utf-8'` 的 Python/Node 一行写文件）
- 默认 **UTF-8 无 BOM**（含中文）

## 产物落盘（强制）

**所有 AI 过程产物必须写入 `.ai-runtime-artifacts/` 对应子目录，禁止写入其他位置。**

| 产物类型 | 目录 |
| --- | --- |
| spec / 方案 | `.ai-runtime-artifacts/specs/` |
| plan / 计划 | `.ai-runtime-artifacts/plans/` |
| dispatch / 调度 | `.ai-runtime-artifacts/plans/`（同 stem 的 `*-dispatch.md`） |
| verification / 验证 | `.ai-runtime-artifacts/verifications/` |
| collective-test / 集体测试 | `.ai-runtime-artifacts/verifications/*-collective-test.md` |
| review / 审查 | `.ai-runtime-artifacts/reviews/` |
| code-review / 代码审查 | `.ai-runtime-artifacts/reviews/*-code-review.md` |
| execution-log / 执行日志 | `.ai-runtime-artifacts/execution-logs/` |
| dispatch-track / 追踪 | `.ai-runtime-artifacts/execution-logs/tracking/` |
| decision / 决策 | `.ai-runtime-artifacts/decisions/` |
| retro / 复盘 | `.ai-runtime-artifacts/retros/` |
| research / 调研 | `.ai-runtime-artifacts/research/` |

**禁止：**
- 把产物写到 `docs/`、`项目根目录`、或其他任意位置
- 把 plan 写到平台私有目录（如 `~/.claude/plans/`）
- 使用 `EnterPlanMode` / `ExitPlanMode`（会绕过 `.ai-runtime-artifacts/plans/` 落盘）
- 用 `docs/superpowers/` 代替 `.ai-runtime-artifacts/`

**例外：** harness-kit 仓库自身（`.gitignore` 排除 `.ai-runtime-artifacts/`）的 closeout 示例可放 `docs/runtime/closeouts/`。

## 同轮禁止

- Write 了 `specs/` / `plans/` / `decisions/` → **结束本轮**；不得同轮改业务代码、派发、WORKTREE-INIT
- 用户说「写计划然后执行 / 出方案并直接做」→ 仅 `writing-plans` 或 `brainstorming`，禁止同轮实现

## 子 Agent（Claude Task 工具）

通过 Task 工具委派。共享 subagent 位于 `.agents/agents/`（薄壳）→ `core/orchestration/agents/`（正文）：

- `coder` — 代码类 WU（plan 批准后）
- `implementer` — 轻量 WU（docs/chore/config）
- `reviewer` — 独立审查（readonly）
- `explorer` — 只读探查
- `debugger` — 缺陷调查
- `test-engineer` — 测试 / E2E
- `web-investigator` — 信息调研

委派细则与 Leader 职责：见 `core/orchestration/agents/leader.md` 与 `HARNESS-PLATFORM-ENTRY.md` § Claude Code 专章。

## 平台映射

`adapters/claude/README.md` + `adapters/claude/bindings.md`。`AGENTS.md` 中的 omx/tmux/spawn 段落在 Claude 中**忽略**。
