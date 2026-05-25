# Harness Platform Entry（Claude / Gemini 共享）

项目背景：{{PROJECT_BACKGROUND}}

---

## Harness 规则（强制）

本项目使用 `harness-kit/` 工程标准。

### 任务前

1. 阅读 `harness-kit/project.profile.md` 与 `harness-kit/context-map.md`
2. 路由、阶段门禁、小改动判定：**`harness-kit/core/routing.md`**（权威路由表）
3. Runbook / 产物 / 验证：`harness-kit/core/runbooks.md`、`artifacts.md`、`verification.md`

### 约束

- **强制声明：** 回复第一行须为 `「Harness：<route 或 "小改动，直接处理">」`
- **未声明时：** 读取本仓库 `CLAUDE.md` 或 `GEMINI.md` 与 `harness-kit/core/routing.md` 后重试
- 非琐碎任务前声明路由、技能与来源；完成声明须附验证证据
- 用户指定 skill 为附加项，不替代默认 route（除非用户明确排除）

若与根目录 `AGENTS.md` 冲突，以 `AGENTS.md` 为准。
