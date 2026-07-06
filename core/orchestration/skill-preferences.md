# Skill 使用偏好说明（WU 级，按需加载）

> **范围：** 本文档仅 **子 Agent / WU**（`wu_skills: auto`）。**Leader 阶段 skill**（`brainstorming`、`writing-plans`、`verification-before-completion`、`git-xywh`）见 `harness-kit/core/routing.md` § 阶段指定 skill 必用 — **必 Load**，不适用下文「按需」。

本文档是 Harness **子 Agent 应加载哪些 skill** 的**唯一维护入口**（文档维护，**不是** skill 文件）。

- 项目内置**能力副本**（TDD、verification 等），由适配器发现与加载；见适配器 `bindings.md` 中 skill 加载绑定。
- **编排步骤**见 `core/orchestration/dispatcher-workflow.md`。

---

## `wu_skills: auto` 怎么解析

Leader 或子 Agent 看到 **`auto`** 时：

1. 从 prompt 读取 **`agent_role`**、**`wu_type`**（及可选 `overrides` / `exclude`）
2. 查下文 **§ 默认路由表**：同一 `agent_role` 下优先匹配**最具体**的 `wu_type` 行（如 `ui-bug` 优于 `*`）；无精确匹配时用含 `*` 的行
3. 得到 skill slug 列表（顺序即加载顺序）
4. 应用 `overrides` 追加、`exclude` 删除
5. 剔除 **§ 全局禁止**
6. 对列表中每一项 **按需** invoke / Read `<skill-slug>/SKILL.md`（不存在则 `skipped`，不硬套；实际路径见适配器 bindings）

**Leader 派发：** 将解析出的 **slug + 路径** 抄入 prompt（**禁**只写 `auto`）。子 Agent 须返回 `### Skills 使用`。

---

## 默认路由表

| agent_role | wu_type | 建议加载的 skill（按序） |
| --- | --- | --- |
| coder | feature, bugfix, refactor | test-driven-development, source-driven-development, incremental-implementation, verification-before-completion, requesting-code-review |
| coder | ui | ui-ux-pro-max, frontend-design, test-driven-development, source-driven-development, incremental-implementation, verification-before-completion, requesting-code-review |
| coder | api | api-and-interface-design, test-driven-development, source-driven-development, incremental-implementation, verification-before-completion |
| coder | review-fix | receiving-code-review, test-driven-development, verification-before-completion |
| implementer | docs, config, chore | **无** |
| explorer | explore, * | **无** |
| explorer | investigate | systematic-debugging |
| debugger | bugfix, * | systematic-debugging, source-driven-development, verification-before-completion |
| debugger | ui-bug | systematic-debugging, source-driven-development, verification-before-completion, browser-testing-with-devtools |
| web-investigator | research, * | browser-testing-with-devtools |
| reviewer | review, * | requesting-code-review, code-review-and-quality, verification-before-completion |
| security-auditor | review, * | security-and-hardening, verification-before-completion |
| perf-auditor | review, * | performance-optimization, verification-before-completion |
| code-simplifier | simplify, * | code-simplification, verification-before-completion |
| test-engineer | test | test-driven-development, verification-before-completion |
| test-engineer | e2e | browser-testing-with-devtools, verification-before-completion |

---

## 全局禁止（不得传给子 Agent）

`brainstorming`, `writing-plans`, `interview-me`, `context-engineering`, `orchestration`, `using-superpowers`, `git-xywh`, `dispatching-parallel-agents`, `subagent-driven-development`

---

## 内置能力副本

| slug | 用途 | 来源 |
| --- | --- | --- |
| test-driven-development | 先测后实现 | superpowers（副本）+ agent-skills 增强 |
| verification-before-completion | 完成前须有命令证据 | superpowers（副本） |
| systematic-debugging | 根因调查 | superpowers（副本）+ agent-skills 增强 |
| requesting-code-review | 独立审查流程纪律 | superpowers（副本） |
| receiving-code-review | 按审查意见改代码 | superpowers（副本） |
| code-review-and-quality | 五轴框架 + 8 种重构模式 | agent-skills（副本） |
| source-driven-development | 源码驱动：DETECT→FETCH→IMPLEMENT→CITE | agent-skills（副本） |
| incremental-implementation | WU 内部增量切片 | agent-skills（副本） |
| doubt-driven-development | 决策时对抗审查（CLAIM→DOUBT→RECONCILE） | agent-skills（副本） |
| api-and-interface-design | 接口契约定义（Contract First） | agent-skills（副本） |
| security-and-hardening | OWASP Top 10 + LLM 安全审查 | agent-skills（副本） |
| performance-optimization | CWV / N+1 / Bundle 性能审查 | agent-skills（副本） |
| code-simplification | Chesterton's Fence → 逐个简化 | agent-skills（副本） |
| observability-and-instrumentation | 结构化日志 + RED 指标 + 分布式追踪 | agent-skills（副本） |
| shipping-and-launch | 发布 Checklist + 回滚方案 | agent-skills（副本） |
| ui-ux-pro-max | UI/UX 设计系统与可检索设计库 | Trae skills（整目录副本） |
| frontend-design | UI 实现审美 | 全局复制 |
| frontend-ui-engineering | a11y / 状态 / 性能工程 | agent-skills（副本） |
| browser-testing-with-devtools | 浏览器测试与 DevTools 调试（需 chrome-devtools MCP） | agent-skills |

副本来源登记：见 `.agents/skills/_vendor-sources.yaml`。

### 仅 Leader / 不在子 Agent 列表

| slug | 说明 |
| --- | --- |
| 编排调度 skill | `orchestration`（统一编排，平台无关）→ `adapters/<platform>/bindings.md` |
| brainstorming, writing-plans, git-xywh | 用户全局 |

---

## 按 Harness 角色（速查）

| 角色 | agent_role | 典型 wu_type | auto 默认 |
| --- | --- | --- | --- |
| Coder | coder | feature / bugfix / refactor | TDD + source-driven + incremental + verification + code-review |
| Coder | coder | ui | ui-ux-pro-max + frontend-design + TDD + source-driven + incremental + verification + code-review |
| Coder | coder | api | api-and-interface-design + TDD + source-driven + incremental + verification |
| Coder | coder | review-fix | receiving-code-review + TDD + verification |
| 轻量执行 | implementer | docs / chore / config | 无 |
| 探查者 | explorer | explore | 无 |
| 调试者 | debugger | bugfix | systematic-debugging + source-driven + verification |
| 审查者 | reviewer | review | code-review + code-review-and-quality + verification |
| 安全审查 | security-auditor | review | security-and-hardening + verification |
| 性能审查 | perf-auditor | review | performance-optimization + verification |
| 代码简化 | code-simplifier | simplify | code-simplification + verification |
| 测试工程师 | test-engineer | test | TDD + verification |
| 测试工程师 | test-engineer | e2e | browser-testing-with-devtools + verification |
| 网探 | web-investigator | research | browser-testing-with-devtools |

---

## 测试工程师 E2E

`wu_type: e2e` 且 `auto` 时：**必须先 Read** `browser-testing-with-devtools/SKILL.md`（路径见适配器 bindings；再按 skill 执行）。

执行优先级：Playwright MCP → `browser-testing-with-devtools`（chrome-devtools MCP）→ 项目 CLI。返回 `e2e_via: playwright-mcp | browser-testing-with-devtools | cli | n/a`。

---

## 按任务类型（用户话术）

| 任务 | Subagent | auto 查表 |
| --- | --- | --- |
| 并行写业务代码 | coder | coder + wu_type |
| 审查 BLOCK 后按意见改代码 | coder | coder + **review-fix** |
| 文档 / 配置 / chore | implementer | implementer + docs/chore/config |
| 只读摸底 | explorer | explorer |
| 调查 bug | debugger | debugger |
| 实现后审查 | reviewer | reviewer |
| 补测试 / 集成测试 | test-engineer | test-engineer + test |
| E2E 验收 | test-engineer | test-engineer + e2e |
| 信息调研 / 网页搜索 | web-investigator | web-investigator + research |
| 只跑一条命令 | shell Task | 无 |
| 提交 / MR | Leader | git-xywh（禁止子 Agent） |

---

## 派发字段

| 字段 | 含义 |
| --- | --- |
| wu_type | feature \| bugfix \| ui \| chore \| refactor \| **review-fix** \| **api** \| docs \| config \| test \| e2e \| explore \| review \| **simplify** \| investigate \| ui-bug \| **research** |
| wu_skills | 逗号分隔 slug，或 **`auto`**（查本文档 § 默认路由表） |
| agent_role | coder \| implementer \| explorer \| debugger \| reviewer \| **security-auditor** \| **perf-auditor** \| **code-simplifier** \| test-engineer \| **web-investigator** |

---

## 加载顺序（路径）

实际路径因平台而异，见适配器 `bindings.md` 中 `LoadSkill` 绑定。通用搜索顺序：

1. `.agents/skills/<slug>/SKILL.md`（项目共享层 — 首选）
2. `.cursor/skills/<slug>/SKILL.md`、`.claude/skills/<slug>/SKILL.md` 或 `.trae/skills/<slug>/SKILL.md`（平台层覆盖）
3. `~/.agents/skills/<slug>/SKILL.md`（用户全局）

共享层 `.agents/skills/` 包含所有平台通用 skill（TDD、verification、code-review 等）；平台层仅放平台特有 skill。

---

## 维护

- 改路由：**只改本文档** § 默认路由表；plan 执行图见 `artifact-templates/dispatch.harness-overlay.md`。
- 升级能力副本：见适配器 README 中 skill 同步说明。
- 项目专有 skill：放在适配器 skill 目录，在 plan 的 `wu_skills` 手写或 `overrides` 追加。
