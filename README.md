# Harness

`cow-harness/` 是任何项目的 Agent Harness 脚手架源头：
它描述项目规则、工作流路由、过程产物、验证门禁、入口模板、工具适配和脚本。

会在你的项目根目录中，对如下文件/目录生成当前项目的投影或运行态：
`AGENTS.md`、`CLAUDE.md`、`GEMINI.md`、`.agents/`、`.cursor/` 和 `.codex/`

迁移源头在 `cow-harness/`。

## 重点关注

这套工程的唯一目的：让你轻松用上 Harness 工程化，解决“万事开头难”的哲学问题。
然后在实施过程中，你一定会用 AI 对这套 Harness 规范不断的优化，沉淀出属于你们团队的资产，让团队 100% AI 化

## 核心能力集

- `superpowers` 负责全面的思考
- `oh-my-codex` / `omx` 负责运行时编排，同时自动选择内置的高级角色，去处理对应的任务
- 用户指定 skills 时，默认按“默认 route + 用户指定 skills”合并执行；只有用户明确要求跳过默认 route 时，才允许不使用默认 skills。

## 读取顺序

1. `AGENTS.md`
2. `cow-harness/project.profile.md`
3. `cow-harness/context-map.md`
4. `cow-harness/core/routing.md`
5. `cow-harness/core/artifacts.md`
6. `cow-harness/project.verification.md`
7. `cow-harness/core/verification.md`
8. `cow-harness/core/runbooks.md`
9. 与任务相关的 `.agents/skills/` 或 `.codex/skills/`

## 目录结构

```
cow-harness/
├── README.md                  # 本文件，脚手架总览
├── project.profile.md         # AI 生成的项目画像
├── context-map.md             # 模块/上下文边界地图
├── project.verification.md   # 项目级验证规则
├── core/                      # 通用 Harness 规则（不随业务重写）
│   ├── harness.md             # Harness 核心理念与总体约束
│   ├── routing.md             # 任务路由表与分发规则
│   ├── artifacts.md           # 过程产物格式与存放规范
│   ├── verification.md        # 验证门禁与完成标准
│   └── runbooks.md            # 各类任务的标准操作手册
├── init/                      # 新项目初始化 prompt 和模板
├── entrypoints/               # 根目录 AI 入口文件模板（CLAUDE.md 等）
├── adapters/                  # 各编程工具适配目录模板（.cursor/ 等）
├── scripts/                   # Harness 内部脚本
└── artifact-templates/        # 过程产物模板
```

## 目录边界

- `core/`：通用 Harness 规则，不随项目业务重写。
- `init/`：新项目初始化 prompt 和项目画像模板。
- `entrypoints/`：根目录 AI 入口文件模板。
- `adapters/`：各编程工具需要识别的目录模板。
- `scripts/`：Harness 内部脚本，不投影到根目录。
- `artifact-templates/`：过程产物模板。
- `project.profile.md`、`context-map.md`、`project.verification.md`：AI 初始化后生成或更新的项目画像。

## 新项目接入

把 `cow-harness/` 放入目标项目后，不要求用户手工阅读和执行每一步，请相信 AI 比我们做的好。

请直接把下面这段话发给 AI：

```text
请先读取 cow-harness/README.md 和 cow-harness/init/bootstrap.prompt.md。
这是一个新项目刚接入 Agent Harness，请按 Harness 初始化流程处理：
1. 从 cow-harness/entrypoints/ 投影根目录 AI 入口文件。
2. 从 cow-harness/adapters/ 投影工具适配目录。
3. 创建 .ai-runtime-artifacts/ 及其子目录。
4. 如需安装或检查 AI runtime，请先说明会修改哪些本机环境，然后由你执行 cow-harness/scripts/install-ai-skills.sh。
5. 读取 cow-harness/init/project-profiler.prompt.md。
6. 扫描当前项目，生成或更新 cow-harness/project.profile.md、cow-harness/context-map.md、cow-harness/project.verification.md。
7. 由你运行 cow-harness/scripts/harness-check.sh。
8. 汇总推断项、待确认项和验证结果。
```

AI 初始化完成后，应生成或更新：

- `cow-harness/project.profile.md`
- `cow-harness/context-map.md`
- `cow-harness/project.verification.md`

AI 应完成 Harness 检查，并在回复中说明检查结果、推断项和待确认项。
