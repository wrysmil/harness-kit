# Harness 编排角色索引

逻辑角色定义在 `agents/`；物理绑定见各平台 `adapters/*/bindings.md`。

| 能力 ID | agent_role | 正文 | 典型 wu_type |
| --- | --- | --- | --- |
| `roles.coder` | coder | `agents/coder.md` | feature, bugfix, refactor, ui, review-fix |
| `roles.implementer` | implementer | `agents/implementer.md` | docs, chore, config |
| `roles.reviewer` | reviewer | `agents/reviewer.md` | review |
| `roles.test-engineer` | test-engineer | `agents/test-engineer.md` | test, e2e |
| `roles.explorer` | explorer | —（只读探查，无独立正文） | explore |
| `roles.debugger` | debugger | `agents/debugger.md` | bugfix, investigate, ui-bug |
| `roles.web-investigator` | web-investigator | `agents/web-investigator.md` | research |
| `roles.security-auditor` | security-auditor | `agents/security-auditor.md` | security-review |
| `roles.perf-auditor` | perf-auditor | `agents/perf-auditor.md` | perf-review |
| `roles.code-simplifier` | code-simplifier | `agents/code-simplifier.md` | simplify |
| `orchestration.leader` | leader | `agents/leader.md` | — |

**SpawnWorker 映射：** Leader 按上表 `agent_role` 派发；`wu_type` 决定 skill 路由（`skill-preferences.md` § 默认路由表）。
