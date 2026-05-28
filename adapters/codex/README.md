# Codex / OMX Adapter

Codex 适配分两层：

1. `oh-my-codex` / `omx` runtime：由 `npm install -g oh-my-codex` 和 `omx setup` 生成 `.codex/`。
2. Harness overlay：由 `AGENTS.md` 入口和 `harness-kit/` 规则提供。

不要把完整 `.codex/` 作为手写脚手架源头提交。`.codex/agents/`、`.codex/prompts/`、`.codex/skills/` 可由 `omx setup` 生成或刷新；`harness-kit/` 只负责说明如何接入和校验。

**批次收尾（尾盘）：** Cursor 侧见 `docs/superpowers/specs/2026-05-28-batch-closeout-review-and-collective-test.md`（集体测试 + 集体审查产物）。Codex/OMX 用 `omx` verify/fix 与 reviewer 路由时，同样须在声称批次完成前保留验证证据与审查记录（`verifications/`、`reviews/`）。

新项目接入时，AI 应：

1. 先发送 `harness-kit/init/onboarding-handoff.txt` 全文（或 `bash harness-kit/scripts/harness-init.sh`）；详版见 `harness-kit/init/bootstrap.prompt.md`。
2. 如需安装或检查 Codex runtime，说明全局 npm 安装和 `omx setup` 的影响。
3. 执行 `harness-kit/scripts/install-ai-skills.sh`。
4. 确认根目录 `AGENTS.md` 包含 Harness overlay，并指向 `harness-kit/core/`。
