# Skill 使用偏好说明（按需加载）

本文档是 Harness **子 Agent 应加载哪些 skill** 的**唯一维护入口**（文档维护，**不是** skill 文件）。

- 项目内置**能力副本**在 `.cursor/skills/`（TDD、verification 等），由 Cursor 发现；升级用 `bash harness-kit/scripts/sync-cursor-skills.sh`。
- **编排步骤**见 `dispatcher-workflow.md`。

---

## `wu_skills: auto` 怎么解析

Leader 或子 Agent 看到 **`auto`** 时：

1. 从 prompt 读取 **`agent_role`**、**`wu_type`**（及可选 `overrides` / `exclude`）
2. 查下文 **§ 默认路由表**：同一 `agent_role` 下优先匹配**最具体**的 `wu_type` 行（如 `ui-bug` 优于 `*`）；无精确匹配时用含 `*` 的行
3. 得到 skill slug 列表（顺序即加载顺序）
4. 应用 `overrides` 追加、`exclude` 删除
5. 剔除 **§ 全局禁止**
6. 对列表中每一项 **按需** invoke / Read `.cursor/skills/<slug>/SKILL.md`（不存在则 `skipped`，不硬套）

Leader 可将解析结果抄进派发 prompt，或保留 `auto` 让子 Agent 自查本文档。

---

## 默认路由表

| agent_role | wu_type | 建议加载的 skill（按序） |
| --- | --- | --- |
| implementer | feature, bugfix, refactor | test-driven-development, verification-before-completion |
| implementer | ui | ui-ux-pro-max, frontend-design, test-driven-development, verification-before-completion |
| implementer | chore | **无** |
| implementer | review-fix | receiving-code-review, test-driven-development, verification-before-completion |
| explorer | explore, * | **无** |
| explorer | investigate | systematic-debugging |
| debugger | bugfix, * | systematic-debugging, verification-before-completion |
| debugger | ui-bug | systematic-debugging, verification-before-completion, agent-browser |
| reviewer | review, * | requesting-code-review, verification-before-completion |
| test-engineer | test | test-driven-development, verification-before-completion |
| test-engineer | e2e | verification-before-completion；（浏览器见 § 测试工程师 E2E） |

---

## 全局禁止（不得传给子 Agent）

`brainstorming`, `writing-plans`, `cursor-orchestration`, `using-superpowers`, `git-xywh`, `dispatching-parallel-agents`, `subagent-driven-development`

---

## 内置能力副本（`.cursor/skills/`）

| slug | 用途 | 来源 |
| --- | --- | --- |
| test-driven-development | 先测后实现 | superpowers（副本） |
| verification-before-completion | 完成前须有命令证据 | superpowers（副本） |
| systematic-debugging | 根因调查 | superpowers（副本） |
| requesting-code-review | 独立审查 | superpowers（副本） |
| receiving-code-review | 按审查意见改代码 | superpowers（副本） |
| ui-ux-pro-max | UI/UX 设计系统与可检索设计库 | ~/.trae/skills（整目录副本） |
| frontend-design | UI 实现审美 | 全局复制 |
| agent-browser | 浏览器自动化（需 `infsh`） | 全局复制 |

副本来源登记：`adapters/cursor/.cursor/skills/_vendor-sources.yaml`。

### 仅 Leader / 不在子 Agent 列表

| slug | 位置 |
| --- | --- |
| cursor-orchestration | `.agents/skills/` |
| brainstorming, writing-plans, git-xywh | 用户全局 |

---

## 按 Harness 角色（速查）

| 角色 | Subagent | 典型 wu_type | auto 默认 |
| --- | --- | --- | --- |
| 实现者 | harness-implementer | feature / bugfix / refactor | TDD + verification |
| 实现者 | harness-implementer | ui | ui-ux-pro-max + frontend-design + TDD + verification |
| 实现者 | harness-implementer | chore | 无 |
| 实现者 | harness-implementer | review-fix | receiving-code-review + TDD + verification |
| 探查者 | harness-explorer | explore | 无 |
| 调试者 | harness-debugger | bugfix | systematic-debugging + verification |
| 审查者 | harness-reviewer | review | requesting-code-review + verification |
| 测试工程师 | harness-test-engineer | test | TDD + verification |
| 测试工程师 | harness-test-engineer | e2e | verification + § E2E |

---

## 测试工程师 E2E（文档约定，非单独 skill）

`harness-test-engineer` 只改测试资产；E2E 浏览器优先级：

1. **Playwright MCP**（Cursor 已启用时）
2. **`agent-browser`**（`.cursor/skills/agent-browser/`，需 `infsh`）
3. **项目 CLI**（`npm run e2e`、`npx playwright test` 等）

返回摘要注明 `e2e_via: playwright-mcp | agent-browser | cli | n/a`。

---

## 按任务类型（用户话术）

| 任务 | Subagent | auto 查表 |
| --- | --- | --- |
| 并行写业务代码 | harness-implementer | implementer + wu_type |
| 审查 BLOCK 后按意见改代码 | harness-implementer | implementer + **review-fix** |
| 只读摸底 | harness-explorer | explorer |
| 调查 bug | harness-debugger | debugger |
| 实现后审查 | harness-reviewer | reviewer |
| 补测试 / 集成测试 | harness-test-engineer | test-engineer + test |
| E2E 验收 | harness-test-engineer | test-engineer + e2e |
| 只跑一条命令 | Task shell | 无 |
| 提交 / MR | Leader | git-xywh（禁止子 Agent） |

---

## 派发字段

| 字段 | 含义 |
| --- | --- |
| wu_type | feature \| bugfix \| ui \| chore \| refactor \| **review-fix** \| test \| e2e \| explore \| review \| investigate \| ui-bug |
| wu_skills | 逗号分隔 slug，或 **`auto`**（查本文档 § 默认路由表） |
| agent_role | implementer \| explorer \| debugger \| reviewer \| test-engineer |

---

## 加载顺序（路径）

1. `.cursor/skills/<slug>/SKILL.md`
2. `~/.cursor/skills/<slug>/SKILL.md`
3. `~/.agents/skills/<slug>/SKILL.md`

---

## 维护

- 改路由：**只改本文档** § 默认路由表，并同步 `artifact-templates/plan.md` 示例（如有）。
- 升级能力副本：`bash harness-kit/scripts/sync-cursor-skills.sh`。
- 项目专有 skill：放在 `.cursor/skills/<name>/`，在 plan 的 `wu_skills` 手写或 `overrides` 追加。
