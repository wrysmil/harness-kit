# Harness Platform Entry（Claude / Gemini 共享）

项目背景：旅行规划助手（travel-assistant）正在重构为基于 nanobot 的聊天式旅游推荐系统：用户端为 React 地图+聊天双面板，管理链路为 FastAPI + admin SPA，聊天链路经 nanobot WebSocket 与 MCP（高德/Unsplash）。仓库含 backend/、frontend/、admin/、nanobot/ 与 harness-kit/；当前分支 feature/architecture-to-chat，根 README 仍描述旧多 Agent 架构。

> 初始化后由 profiler 用 `harness-kit/project.profile.md` 摘要替换 `{{PROJECT_BACKGROUND}}`。Claude/Gemini 会话仍须读根目录 **`AGENTS.md`**（Harness 覆盖层优先）。

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
