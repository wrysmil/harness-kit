# Harness Platform Entry（Claude Code）

项目背景：{{PROJECT_BACKGROUND}}

> Claude Code 会话须同时读根目录 **`AGENTS.md`**（Harness 覆盖层优先）。

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
- **未声明时：** 读取根目录 `CLAUDE.md` 与 `harness-kit/core/routing.md` 后重试
- 非琐碎任务前声明路由、技能与来源；完成声明须附验证证据
- 用户指定 skill 为附加项，不替代默认 route（除非用户明确排除）

若与根目录 `AGENTS.md` 冲突，以 `AGENTS.md` 为准。

### Claude Code 专章

多 task 并行实现：`adapters/claude/README.md`、`adapters/claude/bindings.md`；skill：`orchestration`。

## 参考资料索引

以下参考资料统一存放在 `harness-kit/references/`（集中式），供各 skill 在对应路由阶段按需加载：

| 文件 | 用途 | 被引用的 skill |
|------|------|---------------|
| `harness-kit/references/definition-of-done.md` | 项目级完成定义（20+ 检查项） | `verification-before-completion`, `incremental-implementation`, `shipping-and-launch` |
| `harness-kit/references/testing-patterns.md` | 测试模式（AAA、Mock 层次、反模式） | `test-driven-development`, `debugging-and-error-recovery` |
| `harness-kit/references/security-checklist.md` | Web 安全 + OWASP/LLM Top 10 | `security-and-hardening`, `code-review-and-quality`, `shipping-and-launch` |
| `harness-kit/references/performance-checklist.md` | Web 性能（CWV、前后端清单） | `performance-optimization`, `code-review-and-quality`, `shipping-and-launch` |
| `harness-kit/references/orchestration-patterns.md` | 编排模式 + 反模式 + 决策流 | `orchestration`, `doubt-driven-development` |
| `harness-kit/references/observability-checklist.md` | 可观测性（RED/USE、日志/指标/告警） | `observability-and-instrumentation` |
| `harness-kit/references/accessibility-checklist.md` | WCAG 2.1 AA 无障碍检查 | `frontend-ui-engineering`, `shipping-and-launch` |

> 来源：[agent-skills](https://github.com/addyosmani/agent-skills) `references/` 目录，保持同步。
