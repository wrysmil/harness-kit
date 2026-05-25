---
artifact: runbook
route: harness-bootstrap
skills:
  - planner
source:
  - harness-kit/README.md
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

如果目标文件已存在，先读取现有内容，只合并 Harness 入口，不删除项目已有约束。

## 投影工具适配

从 `harness-kit/adapters/` 投影到项目根目录：

- `harness-kit/adapters/agents/.agents/` -> `.agents/`
- `harness-kit/adapters/cursor/.cursor/` -> `.cursor/`

`harness-kit/adapters/cursor/orchestration/` **不投影**，保留在 harness-kit 内供 AI 读取。

Codex / OMX 适配遵循 `harness-kit/adapters/codex/README.md`。不要把 `.codex/` 当作纯手写模板；它主要由 `omx setup` 生成。

Cursor 编排适配见 `harness-kit/adapters/cursor/README.md`。投影后应存在：

- `.cursor/rules/cursor-subagent-routing.mdc`
- `.cursor/agents/harness-implementer.md`（及 reviewer / explorer / debugger）
- `.agents/skills/cursor-orchestration/SKILL.md`

可选启用 Cursor hooks：

```bash
cp harness-kit/adapters/cursor/.cursor/hooks.json.example .cursor/hooks.json
chmod +x .cursor/hooks/*.sh
```

见 `harness-kit/adapters/cursor/orchestration/hooks/README.md`。

## 初始化项目画像

创建 AI 运行时产物目录：

- `.ai-runtime-artifacts/specs/`
- `.ai-runtime-artifacts/plans/`
- `.ai-runtime-artifacts/reviews/`
- `.ai-runtime-artifacts/verifications/`
- `.ai-runtime-artifacts/decisions/`
- `.ai-runtime-artifacts/retros/`
- `.ai-runtime-artifacts/execution-logs/`
- `.ai-runtime-artifacts/execution-logs/tracking/`（Cursor 并行追踪，可选目录）

产物模板位于 `harness-kit/artifact-templates/`（含 `dispatch-track.md`、`handoff.md`、`wu-checklist.md`）。

完成入口和工具适配投影后，读取 `harness-kit/init/project-profiler.prompt.md`，生成或更新：

- `harness-kit/project.profile.md`
- `harness-kit/context-map.md`
- `harness-kit/project.verification.md`
- `harness-kit/project.git.md`

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
