---
artifact: spec
title: "阶段指定 Skill 必用（Stage Skill Binding）"
date: 2026-05-27
status: approved
platform: cursor
route: harness-kit:internal
---

> **部分条款已由下文覆盖（实施以新 spec 为准，本文 status 保持 approved）：**  
> [`2026-05-27-skill-native-artifacts-and-routing-alignment.md`](./2026-05-27-skill-native-artifacts-and-routing-alignment.md) — Skill 原生产物、按判定加载顺序、`*-dispatch.md`、`artifact-templates` stub，**禁止**用短模板代替 skill 正文。

# 阶段指定 Skill 必用 — 完整方案

## 1. 背景与问题

### 1.1 现象

- Leader 声明 `「Harness：superpowers:brainstorming」`，但未 Read / invoke `brainstorming`，直接读 `routing.md`、~~`artifact-templates/spec.md`~~（已废弃为正文模板，见 skill-native-artifacts spec）后写 spec。
- 产物 front matter 中 `skills:` 为空，与 `route` 不一致。
- 子 Agent 收到 `wu_skills: auto` 后未查 `skill-preferences.zh.md`，或未在返回中报告 `Skills 使用`。

### 1.2 根因

| 原因 | 说明 |
| --- | --- |
| 语义模糊 | 「invoke / Read」被理解为可选；模型用自身经验替代 skill 流程 |
| 无验收 | `harness-check` 只检查 `skills:` 键存在，不检查非空或与 route 一致 |
| 派发松散 | `wu_skills: auto` 留给子 Agent 自查，Leader 未抄路径 |
| 提示过载 | 长文规则被忽略；缺少**短、可执行**的绑定句 |

### 1.3 设计立场（与用户共识）

- **写了就必须用**：路由表 / WU prompt **写明**的 skill，本阶段 / 本 WU **必须** Load 并按流程执行。
- **不写的不强加**：无全局「未 Load 禁止一切」；小改动、无 skill 的 WU 不受影响。
- **子 Agent 同等**：Leader 在 prompt 中指定的 skill，子 Agent **必须**使用并回报。

---

## 2. 目标与非目标

### 2.1 目标

1. 路由表 **Route 列** 与 **本阶段交付物** 绑定：指定 skill 未执行则阶段交付无效。
2. 子 Agent **WU 级** skill 可追踪：派发清单 + 返回 `Skills 使用` + Leader 整合门禁。
3. 产物 `skills` 与 `route` 一致、非空（有 skill 的阶段）。
4. 规则与提示**短**，可放进 `routing.md` 与各 agent 文件，不另起长篇手册。

### 2.2 非目标

- 不要求所有任务在任意工具调用前 Load 全量 skill。
- 不替代各 skill 内部流程（brainstorming 怎么问、TDD 怎么写测仍由 skill 正文定义）。
- 不在本方案中实现 LLM 无法绕过的硬拦截（可选 Hooks 仅作提醒，见 §8）。

---

## 3. 核心概念

### 3.1 术语

| 术语 | 含义 |
| --- | --- |
| **阶段 skill** | `harness-kit/core/routing.md` 路由表 **Route 列** 解析出的 slug（`+` 分隔多个） |
| **WU skill** | Leader 派发 prompt 中「本 WU Skills」列出的 slug（含 Leader 将 `auto` 解析后的列表） |
| **Load** | Read `SKILL.md`（路径见 §3.3）或使用环境原生 Skill 工具；二者择一，**须在本阶段/WU 内发生** |
| **阶段交付** | 该阶段要求的产物或用户可见结论（spec、plan、verification、execution-log 等） |

### 3.2 绑定规则（唯一原则）

```text
路由或 WU 写明的 skill → 必 Load、必按 skill 做、必在 skills / Skills 使用 中体现。
未写明的 skill → 不强制。
```

### 3.3 Skill 路径解析（与现网一致）

按 slug 依次查找（与 `skill-preferences.zh.md` § 加载顺序一致）：

1. `.cursor/skills/<slug>/SKILL.md`
2. `~/.cursor/skills/<slug>/SKILL.md`
3. `~/.agents/skills/<slug>/SKILL.md`

`superpowers:brainstorming` → slug `brainstorming`。  
未找到 → `skipped: <slug> (not found)`，并在 `install-ai-skills.sh` 指引中说明；**仍须在回复中声明**，不得静默省略。

### 3.4 Route 列 → 阶段 skill 映射

| 路由表任务类型 | 阶段 skill（必用） | 阶段交付 |
| --- | --- | --- |
| 需求澄清 / 方案设计 / 行为变更 | `brainstorming` | `specs/*.md` |
| 实施计划 | `writing-plans` | `plans/*.md` |
| 多 task 编码（Cursor） | `cursor-orchestration` | execution-log + 代码 |
| 代码审查 / 验证 | `verification-before-completion` | `verifications/*.md` |
| 缺陷调查 | `systematic-debugging`（+ 委派子 Agent 时另见 WU skill） | spec 或 verification |
| 验证 / 修复循环 | `verification-before-completion`（+ 可选 reviewer） | verification |
| 信息调研 | 委派 `harness-web-investigator`（子 Agent 见 skill-preferences） | `research/*.md` |
| 文章 / 对外文档 | `brainstorming` + 用户指定写作/发布 skill | retro 或指定路径 |
| Git | `git-xywh` | MR 链接 / 无产物 |
| 小改动 | **无** | 无产物 |

**复合 route：** `route` 含 `A -> B` 时，**写 A 阶段产物前**须已完成 A 对应 skill；进入 B 阶段再 Load B。

---

## 4. Leader 行为规范

### 4.1 每任务开头（短）

```text
「Harness：<route>」
Skills: <slug>@<path> loaded | <slug> skipped (not found)
```

- 第二行仅列**本阶段**路由表要求的 skill。
- 本阶段有阶段 skill 时，**先 Load 再**做该阶段工作（读模板、写产物、提问等顺序服从 skill 正文）。
- **沟通语言：** 对用户回复与子 Agent 派发/整合均使用**中文**（见 `core/routing.md` § 沟通语言；固定段键名、路径、命令除外）。

### 4.2 阶段交付门禁

| 条件 | 结果 |
| --- | --- |
| 本阶段路由表有阶段 skill，且未 Load（无 loaded/skipped 声明） | **不得**提交该阶段产物 |
| 产物 `skills:` 为空或与 route 阶段 skill 不一致 | 产物无效，须补写 |
| 用户明确要求跳过某 skill | 须在 `source` 或正文记录原因；`skills` 中标注 `skipped-by-user: <slug>` |

### 4.3 与「按判定加载」表的关系

`routing.md` § 按判定加载 列出的是 **Harness 文档**（`artifacts.md`、模板等），不是 skill 替代品。  
**顺序：** 判定 route → Load **阶段 skill** → 按 skill 流程 → 再读 Harness 文档 / 写产物。

### 4.4 阶段切换

用户说「写计划」「开始实现」等 → Leader **重新声明** Harness route 与 **新阶段** Skills 行，并 Load 新阶段 skill（如 `writing-plans`、`cursor-orchestration`）。

---

## 5. 子 Agent（WU）行为规范

### 5.1 派发前（Leader）

1. 确定 `agent_role`、`wu_type`。
2. 若 `wu_skills: auto` → Leader Read `skill-preferences.zh.md`，解析 slug 列表。
3. 派发 prompt **必须**包含解析后的路径列表（**禁止**仅写 `auto` 让子 Agent 自查）。

**派发块模板（短）：**

```markdown
## 本 WU Skills（必 Load）
- test-driven-development → .cursor/skills/test-driven-development/SKILL.md
- verification-before-completion → .cursor/skills/verification-before-completion/SKILL.md
```

`wu_skills: 无` → 不写本块；子 Agent 不强制 skill。

### 5.2 执行中（子 Agent）

- prompt 所列每一项：先 Load，再改文件 / 跑命令。
- 禁止用「我记得 TDD」跳过 Read（与 `using-superpowers` 红标一致；子 Agent **不**加载 `using-superpowers`，由本契约覆盖）。
- 向 Leader 的返回正文（变更摘要、阻塞说明等）使用**中文**；`### Skills 使用` 等固定段标题可保留英文键名。

### 5.3 返回（子 Agent）

所有 `harness-*` 返回格式增加固定段（无 skill 时可写 `无`）：

```markdown
### Skills 使用
- loaded: <slug> @ <path>
- skipped: <slug> (not found)
- violated: 无 | <说明>
```

### 5.4 整合（Leader）

| 子 Agent 返回 | Leader 动作 |
| --- | --- |
| 有 WU skill 列表但无 `### Skills 使用` | **不整合**，要求重跑或补报 |
| `violated` 非无 | 不视为 WU 完成 |
| 全部 skipped 且 WU 依赖这些 skill | blocked，上报用户 |

---

## 6. 产物与校验

### 6.1 Front matter（扩展）

在 `core/artifacts.md` 中增加推荐字段：

```yaml
skills:
  - brainstorming
skills_evidence:
  - .cursor/skills/brainstorming/SKILL.md
```

| 字段 | 必填条件 |
| --- | --- |
| `skills` | 有阶段 skill 的产物：**非空**，且覆盖本阶段 route 要求的 slug |
| `skills_evidence` | 同上：**至少一条** path 或 `skipped: <slug> (not found)` |

### 6.2 模板

- `artifact-templates/spec.md`：`skills` 示例改为 `brainstorming`；注释「须与 route 一致，禁止留空占位」。
- `plan.md`、`verification.md`、`decision.md`：同步。

### 6.3 `harness-check.sh`

| 检查 | 逻辑 |
| --- | --- |
| `skills` 键存在 | 保持现状 |
| `skills` 非空 | 当 `route` 匹配 `brainstorming|writing-plans|verification|git-xywh|cursor-orchestration` 时，列表不得为空或仅含 `<skill>` 占位 |
| 占位符 | front matter 含 `<skill>`、`- <skill>` 视为失败 |

### 6.4 追踪（可选增强）

`DISPATCH-TRACK` 条目 Detail 可增加：`Skills: loaded=...`（P1）。

---

## 7. 需改动的文件清单

### 7.1 P0 — 堵住「声明了 brainstorming、skills 为空」

| 文件 | 改动要点 |
| --- | --- |
| `core/routing.md` | 新 §「阶段指定 skill 必用」：§3.2 原则 + §3.4 表 + §4.1–4.2 短约定 |
| `core/artifacts.md` | `skills_evidence`；有阶段 skill 时 `skills` 非空 |
| `artifact-templates/spec.md` 等 | 示例与一行注释 |
| `scripts/harness-check.sh` | §6.3 校验 |
| `entrypoints/AGENTS.cursor-overlay.md` | 3–5 行 Skill 绑定 |
| `adapters/cursor/.cursor/rules/ai-entry.mdc` | 同上 |
| `entrypoints/AGENTS.md` | 路由摘要下加一句「Route 列 skill 必用」 |

### 7.2 P1 — 子 Agent 链

| 文件 | 改动要点 |
| --- | --- |
| `adapters/cursor/orchestration/dispatcher-workflow.md` | 禁裸 `auto`；必抄路径；无 Skills 使用不整合 |
| `adapters/cursor/orchestration/skill-preferences.zh.md` | § auto 解析：Leader 负责抄路径 |
| `adapters/cursor/orchestration/agents/coder.md` 等 | 返回 § Skills 使用 |
| `adapters/cursor/.cursor/agents/harness-*.md` | 一句「prompt 所列 skill 必 Load」 |
| `docs/communication-templates.md` | WU 模板加 Skills 块 |

### 7.3 P2 — 可选

| 文件 | 改动要点 |
| --- | --- |
| `adapters/cursor/.cursor/hooks/harness-session-init.sh` | 注入一句阶段 skill 提醒 |
| `adapters/cursor/orchestration/hooks/README.md` | 说明与 P2 关系 |


---

## 8. 短提示汇编（写入规则时照抄）

### 8.1 `routing.md` 正文块（建议 ≤12 行）

```markdown
## 阶段指定 skill 必用

- 路由表 **Route 列**写明的 skill，本阶段**必须** Load（Read SKILL.md 或 Skill 工具）并按其流程执行。
- 未在路由表 / WU prompt 写明的 skill，**不**强制。
- 本阶段有阶段 skill 时：先 Load，再交付该阶段产物；产物 `skills` 须列出已用 slug，**禁止空**。
- 子 Agent：prompt「本 WU Skills」所列**必须** Load；返回须含 `### Skills 使用`；否则 Leader 不整合。
- 会话：`「Harness：…」` 后一行 `Skills: …`（loaded / skipped）。
```

### 8.2 用户纠偏（一句）

```text
阶段 skill 未执行：请先 Load 本 route 要求的 SKILL.md，补全 spec 的 skills 与 Skills 行，再继续。
```

---

## 9. 与现有机制的关系

| 现有 | 本方案 |
| --- | --- |
| 阶段门禁（spec 后暂停） | 不变；增加「spec 有效」前提含 skills 非空 |
| `using-superpowers` | Leader 仍可用；子 Agent 用 §5 契约，不依赖该 skill |
| skill-preferences 全局禁止列表 | 不变；禁止的是**不该传给子 Agent 的** skill，不是 WU 必用 skill |
| Git `git-xywh` | 仍为阶段 skill；须 Load 后再 `project.git.md` |

---

## 10. 验收标准

### 10.1 Leader / 设计阶段

- [ ] 首句含 `「Harness：superpowers:brainstorming」`（或等价）
- [ ] 次行 `Skills: brainstorming@… loaded`（或 skipped 有原因）
- [ ] 对话中可见 Read `brainstorming/.../SKILL.md`（或 Skill 工具）**早于** spec 文件创建
- [ ] spec front matter `skills` 含 `brainstorming`，非空
- [ ] `bash harness-kit/scripts/harness-check.sh` 通过

### 10.2 子 Agent / 实现阶段

- [ ] 派发 prompt 含具体 SKILL 路径，无裸 `auto`
- [ ] Coder 返回含 `### Skills 使用`
- [ ] Leader 在无 Skills 使用时不整合

### 10.3 负例（应判失败）

- [ ] 仅声明 Harness，未 Load，直接写 spec，`skills: []`
- [ ] 子 Agent 改代码但未报 Skills 使用，Leader 仍声称 GROUP 完成

---

## 11. 实施分期

| 阶段 | 范围 | 产出 |
| --- | --- | --- |
| **P0** | §7.1 | 路由契约 + 产物校验 + 短 overlay |
| **P1** | §7.2 | 派发与 subagent 返回闭环 |
| **P2** | §7.3 | Hooks 提醒 |

**建议：** P0 单独 commit `feat(harness-kit): stage skill binding (P0)`；P1 跟进。

---

## 12. 风险与缓解

| 风险 | 缓解 |
| --- | --- |
| 本机未安装 superpowers，全 skipped | `install-ai-skills.sh` + 产物记录 skipped；用户知悉降级 |
| 模型仍跳过 Read | `harness-check` + Leader 不整合 + 用户纠偏句 |
| 提示变长 | 仅用 §8 短块，细节留在本 spec 不深拷进 rules |


---

## 13. 开放问题（实现前可确认）

1. **P2 Hooks** 是否启用 fail-closed？（默认：仅 fail-open 提醒）
2. **`skills_evidence` 是否 P0 必填**，还是 P1 再强制？

---

## 14. 参考

- `harness-kit/core/routing.md` — 路由表单一真相源
- `harness-kit/adapters/cursor/orchestration/skill-preferences.zh.md` — WU skill 解析
- `~/.agents/skills/using-superpowers/SKILL.md` — Load 纪律（Leader）
- `docs/superpowers/specs/2026-05-26-coder-role-design.md` — Coder 与 WU Skills 先例
