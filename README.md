# Harness Kit

可迁移的 Agent Harness 脚手架：把项目规则、工作流路由、过程产物、验证门禁和工具适配打包成一套标准，接入任意代码仓库即可使用。

本仓库（`harness-kit`）是**迁移源头**。接入目标项目后，将其放入项目根目录的 `harness-kit/` 下；AI 会据此投影根目录入口文件与工具适配目录，并生成项目画像。

---

## 二次开发说明

本项目基于原作者 **[WxqKb/cow-harness](https://github.com/WxqKb/cow-harness)** 进行二次开发，在保留原有 Harness 工程化理念与 OMX 编排能力的基础上，**增强了对 Cursor 的适配与开箱即用体验**。

| 维度 | 说明 |
|------|------|
| **上游项目** | [WxqKb/cow-harness](https://github.com/WxqKb/cow-harness) |
| **本仓库定位** | 二开版本，项目名 `harness-kit` |
| **主要增强** | Cursor 统一入口、Rules 自动加载、与 `AGENTS.md` / `harness-kit/` 的衔接 |

### 相对上游的 Cursor 增强

- **统一入口规则**：`adapters/cursor/.cursor/rules/ai-entry.mdc` 设为 `alwaysApply: true`，Cursor 会话自动加载项目 AI 契约。
- **契约优先级明确**：Cursor 以根目录 `AGENTS.md` 为执行契约；项目级路由、产物与验证以 `harness-kit/` 为准，避免 Rules 与 Harness 规范脱节。
- **一键投影**：初始化流程会将 Cursor 适配目录投影到项目根 `.cursor/`，与 `entrypoints/`、`adapters/agents/` 等保持同一套 Harness 语义。
- **与 `.agents/` 协同**：项目级 skills 放 `.agents/skills/`，与 Cursor Rules、Harness 路由分层清晰，减少多工具并存时的规则冲突。

感谢上游作者的开源贡献。使用或再分发时，请保留对本仓库及上游项目的适当署名。

---

## 它解决什么问题

Harness 工程化的难点往往在「起步」：规则散落、各工具各一套、验证标准不统一。Harness Kit 的目标是：

1. **降低接入成本** — 复制 `harness-kit/` 到项目，把初始化话术交给 AI 即可。
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
| Cursor | `.cursor/rules/ai-entry.mdc` |
| Agents / Skills | `.agents/` |
| Codex / OMX | `.codex/`（主要由 `omx setup` 生成） |

---

## 核心能力

- **superpowers** — 结构化思考、计划、调试、TDD、完成前验证等技能链。
- **oh-my-codex / omx** — 多 Agent 运行时编排与高级角色路由。
- **Harness 路由** — 默认 route 为强制基线；用户指定 skills 时，按「默认 route + 用户 skills」合并执行，除非明确要求跳过默认 route。

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
├── adapters/                  # 各工具适配（含 Cursor / Agents / Codex）
├── scripts/                   # Harness 内部脚本
└── artifact-templates/        # 过程产物模板
```

### 目录职责

- `core/` — 通用 Harness 规则，不随业务重写。
- `init/` — 新项目初始化 prompt 与画像模板。
- `entrypoints/` — 投影到根目录的 AI 入口模板。
- `adapters/` — 各编程工具的目录模板（**含 Cursor 增强**）。
- `scripts/` — 安装、初始化、检查脚本（不投影到根目录）。
- `artifact-templates/` — spec / plan / verification 等产物模板。
- `project.profile.md`、`context-map.md`、`project.verification.md` — 初始化后由 AI 生成或更新。

---

## 新项目接入

将本仓库内容放入目标项目的 `harness-kit/` 目录后，**无需手工逐步执行**；把下面这段话发给 AI 即可：

```text
请先读取 harness-kit/README.md 和 harness-kit/init/bootstrap.prompt.md。
这是一个新项目刚接入 Agent Harness，请按 Harness 初始化流程处理：
1. 从 harness-kit/entrypoints/ 投影根目录 AI 入口文件。
2. 从 harness-kit/adapters/ 投影工具适配目录（含 .cursor/）。
3. 创建 .ai-runtime-artifacts/ 及其子目录。
4. 如需安装或检查 AI runtime，请先说明会修改哪些本机环境，然后由你执行 harness-kit/scripts/install-ai-skills.sh。
5. 读取 harness-kit/init/project-profiler.prompt.md。
6. 扫描当前项目，生成或更新 harness-kit/project.profile.md、harness-kit/context-map.md、harness-kit/project.verification.md。
7. 由你运行 harness-kit/scripts/harness-check.sh。
8. 汇总推断项、待确认项和验证结果。
```

初始化完成后，AI 应生成或更新：

- `harness-kit/project.profile.md`
- `harness-kit/context-map.md`
- `harness-kit/project.verification.md`

并在回复中说明 Harness 检查结果、推断项与待确认项。

---

## 相关链接

- **本仓库（二开）**：`harness-kit`
- **上游项目**：[github.com/WxqKb/cow-harness](https://github.com/WxqKb/cow-harness)
