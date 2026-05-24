# Codex / OMX Adapter

Codex 适配分两层：

1. `oh-my-codex` / `omx` runtime：由 `npm install -g oh-my-codex` 和 `omx setup` 生成 `.codex/`。
2. Harness overlay：由 `AGENTS.md` 入口和 `cow-harness/` 规则提供。

不要把完整 `.codex/` 作为手写脚手架源头提交。`.codex/agents/`、`.codex/prompts/`、`.codex/skills/` 可由 `omx setup` 生成或刷新；`cow-harness/` 只负责说明如何接入和校验。

新项目接入时，AI 应：

1. 先读取 `cow-harness/init/bootstrap.prompt.md`。
2. 如需安装或检查 Codex runtime，说明全局 npm 安装和 `omx setup` 的影响。
3. 执行 `cow-harness/scripts/install-ai-skills.sh`。
4. 确认根目录 `AGENTS.md` 包含 Harness overlay，并指向 `cow-harness/core/`。
