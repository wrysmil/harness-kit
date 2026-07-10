# Skill 使用偏好说明（WU 级，按需加载）

> **范围：** 本文档仅 **子 Agent / WU**（`wu_skills: auto`）。**Leader 阶段 skill**（`brainstorming`、`writing-plans`、`verification-before-completion`、`git-xywh`）见 `harness-kit/core/routing.md` § 阶段指定 skill 必用 — **必 Load**，不适用下文「按需」。

本文档是 Harness **子 Agent 应加载哪些 skill** 的**唯一维护入口**（文档维护，**不是** skill 文件）。

- Skill 定义文件在 `.agents/skills/`，由适配器发现与加载；见适配器 `bindings.md`。
- **编排步骤**见 `core/orchestration/dispatcher-workflow.md`。

---

## `wu_skills: auto` 解析流程

1. 从 prompt 读取 `agent_role`、`wu_type`（及可选 `overrides` / `exclude`）
2. 查下方 § Coder 或 § 其他角色，按 `agent_role` + `wu_type` 匹配
3. 得到 skill slug 列表（顺序即加载顺序）
4. 应用 `overrides` 追加、`exclude` 删除
5. 剔除 § 全局禁止中的 skill
6. 按需加载 `<slug>/SKILL.md`，不存在则 `skipped`（路径见适配器 `bindings.md`）

**Leader 派发时：** 必须将解析出的 slug + 路径写入 prompt，禁止只写 `auto`。子 Agent 返回时须包含 `### Skills 使用`。

---

## 全局禁止

以下 skill 只给 Leader 用，禁止传给子 Agent：

`brainstorming`, `writing-plans`, `interview-me`, `context-engineering`, `orchestration`, `git-xywh`, `shipping-and-launch`, `document-review`, `github`, `using-superpowers`, `dispatching-parallel-agents`, `subagent-driven-development`

---

## Coder：写代码

Coder 是主力角色，承担 feature、bugfix、refactor、ui、api 五类任务。技能按工作阶段加载：

### 动手前的准备

| 阶段 | skill | 解决什么问题 |
| --- | --- | --- |
| 查文档 | `source-driven-development` | 涉及框架 API 时，别凭记忆写，先查官方文档确认用法 |
| 审决策 | `doubt-driven-development` | 有重要设计决策（选型、架构、边界划分）时，拉新上下文做对抗审查，避免"以为是事实的假设" |

### 写代码的过程

| 阶段 | skill | 解决什么问题 |
| --- | --- | --- |
| 分步实现 | `incremental-implementation` | 多文件改动时分步来，每步可运行、可测试，不一把梭写完再调 |
| 边写边埋 | `observability-and-instrumentation` | 生产功能必须可观测，日志、指标、追踪跟代码一起写，别事后补 |

### 验证和收尾

| 阶段 | skill | 解决什么问题 |
| --- | --- | --- |
| 先写测试 | `test-driven-development` | 先写测试 → 看失败 → 写最小代码通过。不写测试的代码等于没写 |
| 运行证据 | `verification-before-completion` | 声称"做好了"之前，跑一遍验证命令，有输出才算数 |
| 提交审查 | `requesting-code-review` | 完成后触发 WU 轻量审查，检查通过才能收工 |

### 特殊场景

| wu_type | 额外加载 | 说明 |
| --- | --- | --- |
| `ui` | `ui-ux-pro-max`, `frontend-design`, `frontend-ui-engineering` | UI 工作需要在动手前多三步：查设计库 → 定视觉方向 → 工程化落地（a11y、性能） |
| `api` | `api-and-interface-design` | API 工作先定契约，再写实现 |
| `review-fix` | `receiving-code-review` | 被打回的代码，按审查意见改，先理解再动手，别盲目改 |

### 完整加载顺序

```
source-driven-development → doubt-driven-development → incremental-implementation
→ observability-and-instrumentation → test-driven-development
→ verification-before-completion → requesting-code-review
```

UI 场景在前面加上：`ui-ux-pro-max → frontend-design → frontend-ui-engineering`

API 场景在前面加上：`api-and-interface-design`

review-fix 场景只加载：`receiving-code-review → test-driven-development → verification-before-completion`

---

## 其他角色

角色简单，直接走对应 skill：

| 角色 | agent_role | wu_type | 加载 | 说明 |
| --- | --- | --- | --- | --- |
| 轻量执行 | implementer | docs, config, chore | 无 | 纯体力活，不加载 skill |
| 探查 | explorer | explore, * | 无 | 只读摸底，不加载 skill |
| 探查 | explorer | investigate | `systematic-debugging` | 需要调查问题时，先定位根因 |
| 调试 | debugger | bugfix, * | `systematic-debugging`, `source-driven-development`, `verification-before-completion` | 根因 → 文档 → 证据 |
| 调试 | debugger | ui-bug | 同上 + `browser-testing-with-devtools` | UI bug 需要浏览器实时验证 |
| 审查 | reviewer | review, * | `requesting-code-review`, `code-review-and-quality`, `verification-before-completion` | 五轴审查 + 验证 |
| 安全审查 | security-auditor | review, * | `security-and-hardening`, `verification-before-completion` | OWASP + 验证 |
| 性能审查 | perf-auditor | review, * | `performance-optimization`, `verification-before-completion` | 测量 → 优化 → 验证 |
| 代码简化 | code-simplifier | simplify, * | `code-simplification`, `verification-before-completion` | 降复杂度 + 验证 |
| 测试 | test-engineer | test | `test-driven-development`, `verification-before-completion` | 写测试 + 验证 |
| 测试 | test-engineer | e2e | `browser-testing-with-devtools`, `verification-before-completion` | 浏览器验收 |
| 网页探查 | web-investigator | research, * | `agent-browser` | 浏览器自动化 |

---

## Skill 清单

定义文件：`.agents/skills/<slug>/SKILL.md`

| slug | 用途 |
| --- | --- |
| `source-driven-development` | 每个框架决策必须有官方文档依据 |
| `doubt-driven-development` | 对重要决策做新上下文对抗审查 |
| `incremental-implementation` | 薄垂直切片，每步可运行可测试 |
| `observability-and-instrumentation` | 结构化日志 + RED 指标 + 分布式追踪 |
| `test-driven-development` | 先写测试，再看失败，写最小代码通过 |
| `verification-before-completion` | 完成前必须有运行证据 |
| `requesting-code-review` | WU 轻量审查 + GROUP 集体审查流程 |
| `receiving-code-review` | 按审查意见改代码，先验证再实施 |
| `code-review-and-quality` | 五轴审查：正确性、可读性、架构、安全、性能 |
| `systematic-debugging` | 先定位根因再修复，禁止猜测试错 |
| `security-and-hardening` | OWASP Top 10 + LLM 安全审查 |
| `performance-optimization` | 先测量再优化，CWV / N+1 / Bundle |
| `code-simplification` | 降低复杂度，保持行为不变 |
| `api-and-interface-design` | 契约优先，设计稳定不易误用的接口 |
| `ui-ux-pro-max` | UI/UX 设计系统与可检索设计库 |
| `frontend-design` | 高质量前端视觉设计 |
| `frontend-ui-engineering` | 可访问性 + 状态管理 + 性能工程 |
| `agent-browser` | 浏览器自动化，Playwright 驱动 |
| `browser-testing-with-devtools` | Chrome DevTools 实时测试，DOM/网络/性能 |

**Leader 专用（不在此路由表）：** `orchestration`、`brainstorming`、`writing-plans`、`git-xywh`、`interview-me`、`context-engineering`、`shipping-and-launch`、`document-review`、`github`

---

## E2E 测试

`wu_type: e2e` + `auto` 时，先加载 `browser-testing-with-devtools`，按 skill 执行。

优先级：Chrome DevTools MCP → `agent-browser`（Playwright 后备）→ 项目 CLI。返回 `e2e_via: chrome-devtools-mcp | playwright-mcp | agent-browser | cli | n/a`。

---

## 按任务类型

| 任务 | 用哪个 Agent | 查哪条路由 |
| --- | --- | --- |
| 写业务代码 | coder | coder + wu_type |
| 审查被打回后改代码 | coder | coder + **review-fix** |
| 文档 / 配置 / 杂项 | implementer | implementer + docs/chore/config |
| 只读摸底 | explorer | explorer |
| 调查 bug | debugger | debugger |
| 实现后审查 | reviewer | reviewer |
| 补测试 | test-engineer | test-engineer + test |
| E2E 验收 | test-engineer | test-engineer + e2e |
| 网页搜索/调研 | web-investigator | web-investigator + research |
| 跑一条命令 | shell Task | 无 |
| 提交 / MR | Leader | git-xywh（Leader 专用） |

---

## 派发字段

| 字段 | 含义 |
| --- | --- |
| wu_type | feature \| bugfix \| ui \| chore \| refactor \| **review-fix** \| **api** \| docs \| config \| test \| e2e \| explore \| review \| **simplify** \| investigate \| ui-bug \| **research** |
| wu_skills | 逗号分隔 slug，或 **`auto`**（查本文档 § 默认路由表） |
| agent_role | coder \| implementer \| explorer \| debugger \| reviewer \| **security-auditor** \| **perf-auditor** \| **code-simplifier** \| test-engineer \| **web-investigator** |

---

## 加载路径

平台差异见适配器 `bindings.md`。通用查找顺序：

1. `.agents/skills/<slug>/SKILL.md`（项目共享层，优先）
2. 平台层：`.cursor/skills/`、`.claude/skills/`、`.trae/skills/`
3. `~/.agents/skills/<slug>/SKILL.md`（用户全局）

---

## References 纪律

Leader 派发 WU 时，必须将关联 references 的 checklist 条目注入 Context Block。WU 返回时：

- 产物中包含 `### References 检查`
- 逐条标注 `pass / fail / n/a`
- 任一 `fail` → `wu_status: blocked`，Leader 不得整合

Leader 尾盘 / Ship Gate：全量 references 自检，写入 collective-test.md 或 ship-check.md。

---

## 维护

- 改路由：只改本文档 Coder / 其他角色 两节
- 项目专有 skill：放在适配器 skill 目录，通过 `wu_skills` 手写或 `overrides` 追加
