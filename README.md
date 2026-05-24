# Harness Kit

可迁移的 Agent Harness 脚手架：把项目规则、工作流路由、过程产物、验证门禁和工具适配打包成一套标准，接入任意代码仓库即可使用。

本仓库是 **Harness 迁移源头**。接入目标项目后，将其放入项目根目录的 `harness-kit/` 下；AI 会据此投影根目录入口文件与工具适配目录，并生成项目画像。

---

## 它解决什么问题

Harness 工程化的难点往往在「起步」：规则散落、各工具各一套、验证标准不统一。Harness Kit 的目标是：

1. **降低接入成本** — 将 `harness-kit/` 放入项目，把初始化话术交给 AI 即可。
2. **统一多工具入口** — 同一套规范投影到 Cursor、Codex、Claude Code、Gemini 等环境。
3. **可迁移、可沉淀** — 规范在 `harness-kit/` 中迭代，团队可逐步优化为自有资产。

---

## 支持的工具

接入完成后，项目根目录会出现（或更新）以下入口与适配：

| 类型 | 路径 |
|------|------|
| 顶层契约 | `AGENTS.md` |
| Claude Code | `CLAUDE.md` |
| Gemini | `GEMINI.md` |
| Cursor | `.cursor/rules/`、`.cursor/agents/`（harness-* subagent） |
| Cursor 编排文档 | `harness-kit/adapters/cursor/orchestration/`（不投影，供 AI 读取） |
| Agents / Skills | `.agents/`（含 `cursor-orchestration`） |
| Codex / OMX | `.codex/`（主要由 `omx setup` 生成） |

---

## 核心能力

- **Harness 路由** — 默认 route 为强制基线；`core/routing.md` 提供 Codex 与 Cursor 并列路由表。
- **Cursor 子 Agent 编排** — `.cursor/agents/harness-*` + `cursor-orchestration` skill，语义等价于 Codex 的 `omx ultrawork`（见 `adapters/cursor/`）。
- **oh-my-codex / omx** — Codex CLI 多 Agent 运行时编排与高级角色路由。
- **superpowers** — 结构化思考、计划、调试、TDD、完成前验证等技能链。

更多 Cursor 集成说明见 `adapters/cursor/README.md`。

---

## 推荐阅读顺序

1. `AGENTS.md`（投影后的根目录入口）
2. `harness-kit/project.profile.md`
3. `harness-kit/context-map.md`
4. `harness-kit/core/routing.md`
5. `harness-kit/core/artifacts.md`
6. `harness-kit/project.verification.md`
7. `harness-kit/core/verification.md`
8. `harness-kit/core/runbooks.md`
9. 与任务相关的 `.agents/skills/` 或 `.codex/skills/`

---

## 目录结构

```
harness-kit/
├── README.md                  # 本文件
├── project.profile.md         # AI 生成的项目画像
├── context-map.md             # 模块与上下文边界
├── project.verification.md    # 项目级验证规则
├── core/                      # 通用 Harness 规则（不随业务重写）
│   ├── harness.md
│   ├── routing.md
│   ├── artifacts.md
│   ├── verification.md
│   └── runbooks.md
├── init/                      # 初始化 prompt 与模板
├── entrypoints/               # 根目录 AI 入口模板
├── adapters/                  # 各工具适配（Cursor / Agents / Codex）
├── scripts/                   # Harness 内部脚本
└── artifact-templates/        # 过程产物模板
```

### 目录职责

- `core/` — 通用 Harness 规则，不随业务重写。
- `init/` — 新项目初始化 prompt 与画像模板。
- `entrypoints/` — 投影到根目录的 AI 入口模板（含工具中立的 `AGENTS.md` 与 `AGENTS.omx.md` 等）。
- `adapters/` — 各编程工具的目录模板与编排文档。
- `scripts/` — 安装、初始化、检查脚本（不投影到根目录）。
- `artifact-templates/` — spec / plan / verification / execution-log 等产物模板。
- `project.profile.md`、`context-map.md`、`project.verification.md` — 初始化后由 AI 生成或更新。

---

## 新项目接入

将本仓库内容放入目标项目的 `harness-kit/` 目录后，**无需手工逐步执行**；把下面这段话发给 AI 即可：

```text
请先读取 harness-kit/README.md 和 harness-kit/init/bootstrap.prompt.md。
这是一个新项目刚接入 Agent Harness，请按 Harness 初始化流程处理：
1. 从 harness-kit/entrypoints/ 投影根目录 AI 入口文件。
2. 从 harness-kit/adapters/ 投影工具适配目录（含 .cursor/agents/、.cursor/rules/ 与 cursor-orchestration skill）。
3. 创建 .ai-runtime-artifacts/ 及其子目录（含 execution-logs/ 与 execution-logs/tracking/）。
4. 如需安装或检查 AI runtime，请先说明会修改哪些本机环境，然后由你执行 harness-kit/scripts/install-ai-skills.sh。
5. 读取 harness-kit/init/project-profiler.prompt.md。
6. 扫描当前项目，生成或更新 harness-kit/project.profile.md、harness-kit/context-map.md、harness-kit/project.verification.md。
7. 由你运行 harness-kit/scripts/harness-check.sh。
8. 汇总推断项、待确认项和验证结果。
```

详细步骤（含可选 Cursor hooks、AGENTS 拆分说明）以 `harness-kit/init/bootstrap.prompt.md` 为准。

初始化完成后，AI 应生成或更新：

- `harness-kit/project.profile.md`
- `harness-kit/context-map.md`
- `harness-kit/project.verification.md`

并在回复中说明 Harness 检查结果、推断项与待确认项。

---

## 接入方式建议

| 方式 | 适用场景 |
|------|----------|
| **Git Submodule** | 多项目共用同一份 harness-kit，升级与业务提交分离 |
| **目录拷贝** | 单项目快速接入；Harness 变更请使用独立 commit（如 `chore(harness-kit): ...`） |

无论哪种方式，`harness-kit/` 内的规范迭代与业务代码提交建议分开，便于 review 与回滚。

---

## 更多文档

- Cursor 适配：`adapters/cursor/README.md`
- Bootstrap 详版：`init/bootstrap.prompt.md`
