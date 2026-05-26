# Harness Platform Entry（Claude / Gemini 共享）

项目背景：旅行规划助手（travel-assistant）是基于 AI 的智能旅行规划与推荐系统，正处于架构迁移期：从旧版多 Agent + 独立 MCP 流水线重构为 nanobot 聊天网关、React 地图/聊天双面板、FastAPI 管理后台与 admin SPA。技术栈含 React 19/Vite/Tailwind、Python FastAPI、嵌入 nanobot 与 Docker 全栈部署；仓库以 backend/、frontend/、admin/、nanobot/、harness-kit/ 为主，根 README 仍描述旧架构，实施以 `.ai-runtime-artifacts/` 内已批准 spec/plan 为准。

> Claude/Gemini 会话须同时读根目录 **`AGENTS.md`**（Harness 覆盖层优先）。

---

## Harness 规则（强制）

本项目使用 `harness-kit/` 工程标准。

### 任务前（与 `AGENTS.md` 覆盖层对齐）

1. `harness-kit/core/harness.md`
2. `harness-kit/project.profile.md`
3. `harness-kit/context-map.md`
4. `harness-kit/project.git.md`（Git 任务或用户要求提交 / 开 MR 时）
5. `harness-kit/core/routing.md`（路由、阶段门禁、小改动判定）
6. `harness-kit/core/artifacts.md`
7. `harness-kit/project.verification.md`
8. `harness-kit/core/verification.md`
9. 任务匹配时：`harness-kit/core/runbooks.md`

### 约束

- **强制声明：** 回复第一行须为 `「Harness：<route 或 "小改动，直接处理">」`
- **未声明时：** 读取根目录 `CLAUDE.md` 或 `GEMINI.md` 与 `harness-kit/core/routing.md` 后重试
- 非琐碎任务前声明路由、技能与来源；完成声明须附验证证据
- 用户指定 skill 为附加项，不替代默认 route（除非用户明确排除）

若与根目录 `AGENTS.md` 冲突，以 `AGENTS.md` 为准。
