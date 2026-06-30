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
| coder | feature, bugfix, refactor | test-driven-development, verification-before-completion, requesting-code-review |
| coder | ui | ui-ux-pro-max, frontend-design, test-driven-development, verification-before-completion, requesting-code-review |
| coder | review-fix | receiving-code-review, test-driven-development, verification-before-completion, requesting-code-review |
| implementer | docs, config, chore | **无** |
| explorer | explore, * | **无** |
| explorer | investigate | systematic-debugging |
| debugger | bugfix, * | systematic-debugging, verification-before-completion |
| debugger | ui-bug | systematic-debugging, verification-before-completion, agent-browser |
| web-investigator | research, * | agent-browser |
| reviewer | review, * | requesting-code-review, verification-before-completion |
| test-engineer | test | test-driven-development, verification-before-completion |
| test-engineer | e2e | agent-browser, verification-before-completion |

---

## 全局禁止（不得传给子 Agent）

`brainstorming`, `writing-plans`, `cursor-orchestration`, `claude-orchestration`, `using-superpowers`, `git-xywh`, `dispatching-parallel-agents`, `subagent-driven-development`

---

## 内置能力副本

| slug | 用途 | 来源 |
| --- | --- | --- |
| test-driven-development | 先测后实现 | superpowers（副本） |
| verification-before-completion | 完成前须有命令证据 | superpowers（副本） |
| systematic-debugging | 根因调查 | superpowers（副本） |
| requesting-code-review | 独立审查 | superpowers（副本） |
| receiving-code-review | 按审查意见改代码 | superpowers（副本） |
| ui-ux-pro-max | UI/UX 设计系统与可检索设计库 | Trae skills（整目录副本） |
| frontend-design | UI 实现审美 | 全局复制 |
| agent-browser | 浏览器自动化（需 `infsh`） | 全局复制 |

副本来源登记：见 `adapters/agents/.agents/skills/_vendor-sources.yaml`。

### 仅 Leader / 不在子 Agent 列表

| slug | 说明 |
| --- | --- |
| 编排调度 skill | 见适配器 `bindings.md`（cursor-orchestration / claude-orchestration 等） |
| brainstorming, writing-plans, git-xywh | 用户全局 |

---

## 按 Harness 角色（速查）

| 角色 | agent_role | 典型 wu_type | auto 默认 |
| --- | --- | --- | --- |
| Coder | coder | feature / bugfix / refactor | TDD + verification + requesting-code-review |
| Coder | coder | ui | ui-ux-pro-max + frontend-design + TDD + verification + requesting-code-review |
| Coder | coder | review-fix | receiving-code-review + TDD + verification + requesting-code-review |
| 轻量执行 | implementer | docs / chore / config | 无 |
| 探查者 | explorer | explore | 无 |
| 调试者 | debugger | bugfix | systematic-debugging + verification |
| 审查者 | reviewer | review | requesting-code-review + verification |
| 测试工程师 | test-engineer | test | TDD + verification |
| 测试工程师 | test-engineer | e2e | agent-browser + verification |
| 网探 | web-investigator | research | agent-browser |

---

## 测试工程师 E2E

`wu_type: e2e` 且 `auto` 时：**必须先 Read** `agent-browser/SKILL.md`（路径见适配器 bindings；再按 skill 执行）。

执行优先级：Playwright MCP → `agent-browser`（`infsh`）→ 项目 CLI。返回 `e2e_via: playwright-mcp | agent-browser | cli | n/a`。

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
| wu_type | feature \| bugfix \| ui \| chore \| refactor \| **review-fix** \| docs \| config \| test \| e2e \| explore \| review \| investigate \| ui-bug \| **research** |
| wu_skills | 逗号分隔 slug，或 **`auto`**（查本文档 § 默认路由表） |
| agent_role | coder \| implementer \| explorer \| debugger \| reviewer \| test-engineer \| **web-investigator** |

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
