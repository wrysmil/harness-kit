---
artifact: runbook
route: harness-bootstrap
skills:
  - planner
source:
  - cow-harness/README.md
  - cow-harness/entrypoints/
  - cow-harness/adapters/
created_at: 2026-05-14
---

# Harness Bootstrap Prompt

你正在把 Agent Harness 脚手架接入当前项目。`cow-harness/` 是源头，根目录入口和工具目录都是投影。

## 投影入口文件

从 `cow-harness/entrypoints/` 投影到项目根目录：

- `cow-harness/entrypoints/AGENTS.md` -> `AGENTS.md`
- `cow-harness/entrypoints/CLAUDE.md` -> `CLAUDE.md`
- `cow-harness/entrypoints/GEMINI.md` -> `GEMINI.md`

如果目标文件已存在，先读取现有内容，只合并 Harness 入口，不删除项目已有约束。

## 投影工具适配

从 `cow-harness/adapters/` 投影到项目根目录：

- `cow-harness/adapters/agents/.agents/` -> `.agents/`
- `cow-harness/adapters/cursor/.cursor/` -> `.cursor/`

Codex / OMX 适配遵循 `cow-harness/adapters/codex/README.md`。不要把 `.codex/` 当作纯手写模板；它主要由 `omx setup` 生成。

## 初始化项目画像

创建 AI 运行时产物目录：

- `.ai-runtime-artifacts/specs/`
- `.ai-runtime-artifacts/plans/`
- `.ai-runtime-artifacts/reviews/`
- `.ai-runtime-artifacts/verifications/`
- `.ai-runtime-artifacts/decisions/`
- `.ai-runtime-artifacts/retros/`

完成入口和工具适配投影后，读取 `cow-harness/init/project-profiler.prompt.md`，生成或更新：

- `cow-harness/project.profile.md`
- `cow-harness/context-map.md`
- `cow-harness/project.verification.md`

## 验证

最后运行：

```bash
bash cow-harness/scripts/harness-check.sh
```

回复中说明：

- 投影了哪些入口和适配目录。
- 是否创建了 `.ai-runtime-artifacts/`。
- 是否执行了 AI runtime 安装或检查。
- 生成或更新了哪些项目画像文件。
- Harness 检查是否通过。
