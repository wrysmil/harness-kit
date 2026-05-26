# CLAUDE.md

项目背景：旅行规划助手（travel-assistant）是基于 AI 的智能旅行规划与推荐系统，正处于架构迁移期：从旧版多 Agent + 独立 MCP 流水线重构为 nanobot 聊天网关、React 地图/聊天双面板、FastAPI 管理后台与 admin SPA。技术栈含 React 19/Vite/Tailwind、Python FastAPI、嵌入 nanobot 与 Docker 全栈部署；仓库以 backend/、frontend/、admin/、nanobot/、harness-kit/ 为主，根 README 仍描述旧架构，实施以 `.ai-runtime-artifacts/` 内已批准 spec/plan 为准。

> 初始化后由 profiler 用 `harness-kit/project.profile.md` 摘要替换上一行占位符。

## Harness（Claude Code）

共享规则正文：**`harness-kit/entrypoints/HARNESS-PLATFORM-ENTRY.md`**（与 `GEMINI.md` 相同）。

1. 读取上述共享入口 + 根目录 `AGENTS.md`（Harness 覆盖层）
2. **Codex / omx** 多 task 实现：`omx ultrawork` 或 `harness-kit/entrypoints/AGENTS.omx.md`

若本文件与 `AGENTS.md` 冲突，以 `AGENTS.md` 为准。
