# Harness Engineering

本文件描述可迁移 Agent Harness 的通用架构。它不包含具体项目业务背景；项目业务画像放在 `cow-harness/project.profile.md`。

## 三层架构

### Runtime Layer

由 `oh-my-codex` / `omx` 和 AI 工具运行时管理：

- `AGENTS.md`
- `.codex/`
- omx skills、prompts、agents、hooks

这层负责多 Agent 编排、workflow 调度和运行时能力。

### Project Overlay Layer

由 `cow-harness/` 管理：

- `project.profile.md`：当前项目画像，迁移到新项目后必须重新生成。
- `context-map.md`：目录、模块和关键入口地图，初始化后由 AI 生成。
- `project.verification.md`：当前项目验证命令，初始化后由 AI 生成。
- `core/routing.md`：任务路由。
- `core/artifacts.md`：过程产物规范。
- `core/verification.md`：通用验证门禁。
- `core/runbooks.md`：常见任务流程。
- `entrypoints/`：根目录 AI 入口文件模板。
- `adapters/`：编程工具适配目录模板。
- `scripts/`：Harness 内部脚本。
- `artifact-templates/`：过程产物模板。

这层负责项目边界、产物协议、验证门禁和可迁移约束。

### Tool Bootstrap Layer

由根目录投影和 Harness 内部脚本组成：

- `CLAUDE.md`
- `GEMINI.md`
- `.cursor/rules/ai-entry.mdc`
- `cow-harness/scripts/install-ai-skills.sh`
- `cow-harness/scripts/harness-init.sh`
- `cow-harness/scripts/harness-check.sh`

这层负责让不同工具进入同一套 Harness。根目录入口和工具目录从 `cow-harness/entrypoints/`、`cow-harness/adapters/` 投影；脚本直接在 `cow-harness/scripts/` 内执行，不投影到根目录。

## 新项目初始化顺序

1. 将 `cow-harness/` 放入新项目。
2. 对 AI 说：

```text
请先读取 cow-harness/README.md 和 cow-harness/init/bootstrap.prompt.md。
这是一个新项目刚接入 Agent Harness，请按 Harness 初始化流程处理。
请先投影入口文件和工具适配目录。
如需安装或检查 AI runtime，请先说明会修改哪些本机环境，然后由你执行 cow-harness/scripts/install-ai-skills.sh。
请读取 cow-harness/init/project-profiler.prompt.md，扫描当前项目并生成项目画像、上下文地图和验证画像。
最后由你运行 Harness 检查，并汇总推断项、待确认项和验证结果。
```

3. AI 生成或更新：
   - `cow-harness/project.profile.md`
   - `cow-harness/context-map.md`
   - `cow-harness/project.verification.md`
4. 人 review `project.profile.md` 中的推断项和待确认项。
