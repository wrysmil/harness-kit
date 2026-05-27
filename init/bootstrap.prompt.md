---
artifact: runbook
route: harness-bootstrap
skills:
  - planner
source:
  - harness-kit/README.md
  - harness-kit/init/onboarding-handoff.txt
  - harness-kit/entrypoints/
  - harness-kit/adapters/
created_at: 2026-05-14
---

# Harness Bootstrap Prompt

你正在把 Agent Harness 脚手架接入当前项目。`harness-kit/` 是源头，根目录入口和工具目录都是投影。

## 投影入口文件

从 `harness-kit/entrypoints/` 投影到项目根目录：

- `harness-kit/entrypoints/AGENTS.md` -> `AGENTS.md`
- `harness-kit/entrypoints/AGENTS.omx.md` -> 保留在 harness-kit 内，或 Codex 项目合并进 `AGENTS.md`
- `harness-kit/entrypoints/AGENTS.cursor-overlay.md` -> 保留在 harness-kit 内（Cursor 深读）
- `harness-kit/entrypoints/CLAUDE.md` -> `CLAUDE.md`
- `harness-kit/entrypoints/GEMINI.md` -> `GEMINI.md`

`harness-kit/entrypoints/HARNESS-PLATFORM-ENTRY.md` 为 Claude/Gemini **共享正文**（不单独投影到根目录）。

如果目标文件已存在，先读取现有内容，只合并 Harness 入口，不删除项目已有约束。

## 投影工具适配

从 `harness-kit/adapters/` 投影到项目根目录：

- `harness-kit/adapters/agents/.agents/` -> `.agents/`
- `harness-kit/adapters/cursor/.cursor/` -> `.cursor/`

`harness-kit/adapters/cursor/orchestration/` **不投影**，保留在 harness-kit 内供 AI 读取。

Codex / OMX 适配遵循 `harness-kit/adapters/codex/README.md`。不要把 `.codex/` 当作纯手写模板；它主要由 `omx setup` 生成。

Cursor 编排适配见 `harness-kit/adapters/cursor/README.md`。投影后应存在：

- `.cursor/rules/cursor-subagent-routing.mdc`
- `.cursor/agents/harness-coder.md`（及 implementer / reviewer / explorer / debugger / test-engineer / web-investigator）
- `.cursor/skills/`（能力副本；偏好见 `adapters/cursor/orchestration/skill-preferences.zh.md`）
- `.agents/skills/cursor-orchestration/SKILL.md`

可选启用 Cursor hooks：

```bash
cp harness-kit/adapters/cursor/.cursor/hooks.json.example .cursor/hooks.json
chmod +x .cursor/hooks/*.sh
```

见 `harness-kit/adapters/cursor/orchestration/hooks/README.md`。

## AI runtime（可选）

如需安装或检查 AI runtime（`oh-my-codex` / `omx`、superpowers、组织 skill `git-xywh` 等），先说明会修改哪些本机环境，再由你执行：

```bash
bash harness-kit/scripts/install-ai-skills.sh
```

见 `harness-kit/adapters/agents/.agents/README.md`。

## 初始化项目画像

创建 AI 运行时产物目录：

- `.ai-runtime-artifacts/specs/`
- `.ai-runtime-artifacts/plans/`
- `.ai-runtime-artifacts/reviews/`
- `.ai-runtime-artifacts/verifications/`
- `.ai-runtime-artifacts/decisions/`
- `.ai-runtime-artifacts/retros/`
- `.ai-runtime-artifacts/research/`
- `.ai-runtime-artifacts/research/screenshots/`（网探截图，可选）
- `.ai-runtime-artifacts/execution-logs/`
- `.ai-runtime-artifacts/execution-logs/tracking/`（Cursor 并行追踪，可选目录）

产物模板位于 `harness-kit/artifact-templates/`：**编排类**（`dispatch-track.md`、`handoff.md`、`progress.md`、`wu-checklist.md`、`research-report.md`）；**stage skill 契约**（`spec.harness-overlay.md`、`plan.harness-overlay.md`、`dispatch.harness-overlay.md`）；`spec.md`/`plan.md` 仅为 redirect stub。

完成入口和工具适配投影后，读取 `harness-kit/init/project-profiler.prompt.md`。

以 `harness-kit/init/templates/` 下对应文件为**章节骨架**，扫描当前仓库后生成或更新：

- `harness-kit/project.profile.md`
- `harness-kit/context-map.md`
- `harness-kit/project.verification.md`
- `harness-kit/project.git.md`

## 填充平台入口背景

用 `project.profile.md` 的「项目身份」与「技术栈」写成 2–4 句摘要，替换下列文件中的 `{{PROJECT_BACKGROUND}}`（勿删除 Harness 规则段落）：

- 根目录 `CLAUDE.md`、`GEMINI.md`（若已投影）
- `harness-kit/entrypoints/HARNESS-PLATFORM-ENTRY.md`（共享正文，供 Claude/Gemini 深读）

## 验证

最后运行：

```bash
bash harness-kit/scripts/harness-check.sh
```

回复中说明：

- 投影了哪些入口和适配目录。
- 是否创建了 `.ai-runtime-artifacts/`。
- 是否执行了 AI runtime 安装或检查。
- 生成或更新了哪些项目画像文件。
- Harness 检查是否通过。
- **推断项**与**待确认项**（摘自 `project.profile.md`、`project.git.md` 等，供负责人 review）。
