# Harness Platform Entry（Claude / Gemini 共享）

项目背景：{{PROJECT_BACKGROUND}}

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

- **强制声明：** 首行 `「Harness：<route 或 Tier 0/1>」`；stage skill / Tier 1+ 次行 `Skills: slug@path loaded|skipped`
- **未声明时：** 读取根目录 `CLAUDE.md` 或 `GEMINI.md` 与 `harness-kit/core/routing.md` 后重试
- 非琐碎任务前声明路由、技能与来源；完成声明须附验证证据
- 用户指定 skill 为附加项，不替代默认 route（除非用户明确排除）

若与根目录 `AGENTS.md` 冲突，以 `AGENTS.md` 为准。

### Claude Code 专章

多 task 并行实现：`adapters/claude/README.md`、`adapters/claude/bindings.md`；skill：`claude-orchestration`。
