# Harness Kit

可迁移的 **Agent Harness** 脚手架：把项目规则、工作流路由、过程产物、验证门禁和工具适配打包成一套标准，接入任意代码仓库即可使用。

本仓库是 **Harness 迁移源头**。接入目标项目后，将其放入项目根目录的 `harness-kit/`；AI 会据此投影根目录入口文件与工具适配，并生成项目画像。

---

## 目录

- [什么是 Harness Engineering](#什么是-harness-engineering)
- [解决什么问题](#解决什么问题)
- [与单纯使用 Skill 的区别](#与单纯使用-skill-的区别)
- [Cursor 编程协作模式](#cursor-编程协作模式)
- [支持的工具](#支持的工具)
- [目录结构](#目录结构)
- [推荐阅读顺序](#推荐阅读顺序)
- [新项目接入](#新项目接入)
- [接入方式建议](#接入方式建议)
- [更多文档](#更多文档)

---

## 什么是 Harness Engineering

**Harness Engineering** 是围绕 AI Coding Agent 设计约束机制、反馈回路、工作流控制与持续改进的系统工程实践。核心问题是：当 Agent 具备强代码生成能力后，如何保证输出的**可靠性、一致性与长期可维护性**。

**Harness** 本义是马具——用缰绳与鞍具把马力引到正确方向。LLM 像一匹劲大但易跑偏的马；Harness 负责**定向、限速、验货与交接**，而不是限制能力本身。

---

## 解决什么问题

Harness 工程化常卡在「起步」：规则散落、各工具各一套、验证标准不统一。Harness Kit 的目标是：

1. **降低接入成本** — 将 `harness-kit/` 放入项目，把初始化话术交给 AI 即可。
2. **统一多工具入口** — 同一套规范投影到 Cursor、Codex、Claude Code、Gemini 等环境。
3. **可迁移、可沉淀** — 规范在 `harness-kit/` 中迭代，团队可逐步优化为自有资产。

---

## 与单纯使用 Skill 的区别

许多团队从 **harness-engineer**、**superpowers** 等 Agent Skill 起步：能力装在 Skill 里，主要靠对话里临时提醒 AI「按某 skill 做」。  
**Harness Kit** 把「这个项目怎么干」写进仓库里的 `harness-kit/`，换电脑、换同事、换 Cursor/Codex，拉同一份代码就能沿用同一套规则。

| 维度 | 仅使用 Skill | Harness Kit |
|------|-------------|-------------|
| **交付物与可追溯性** | 方案和结论多在聊天记录里，关掉窗口就难找 | 重要步骤落成 `.ai-runtime-artifacts/` 下的 Markdown（spec、plan、验证报告等），带日期与 route，便于 review 与接力 |
| **多 Agent 协同** | 一个大对话里又设计又写代码又自审，易前后矛盾 | **Leader** 协调；**Coder** / **Implementer** / **Reviewer** 等分工；可并行 WU，减少「自己审自己」 |
| **迁移与配置** | Skill 常装在本机；项目间难统一 | **`harness-kit/` 随 Git 走**；`project.profile.md`、`context-map.md` 等由初始化生成；`adapters/` 投影各工具配置 |
| **软件工程工作流** | 每次口头说「先方案再代码」 | **默认阶段链 + 门禁**：spec/plan 写入后须暂停等人确认；小改动可走快捷路由 |

**一句话：** Skill 教 AI **会哪些招**；Harness Kit 规定 **在这个仓库里、按什么顺序、留下什么文件、谁来做哪一步**。

### 迁移与配置：主要文件

| 路径 | 说明 |
|------|------|
| `harness-kit/` | 脚手架根目录；可与业务代码 submodule 或同仓 |
| `project.profile.md` | 项目画像：技术栈、目录职责、禁区 |
| `context-map.md` | 上下文地图：模块边界与读码优先级 |
| `project.verification.md` | 验证命令与最小验证策略 |
| `project.git.md` | 相对组织 `git-xywh` 的本项目 Git 差异 |
| `core/routing.md` | 默认路由表、阶段门禁 |
| `core/harness.md` | 总契约与阅读顺序 |
| `core/artifacts.md` | `.ai-runtime-artifacts/` 命名与 front matter |
| `entrypoints/` | 投影到根目录的 `AGENTS.md`、`CLAUDE.md` 等 |
| `adapters/cursor/` | Cursor：rules、agents、orchestration |
| `adapters/codex/` | Codex / OMX 适配 |
| `adapters/agents/` | 通用 `.agents/skills/`（如 `cursor-orchestration`） |
| `init/` | 接入与 bootstrap 话术 |
| `artifact-templates/` | spec / plan / execution-log 等模板 |

---

## Cursor 编程协作模式

Cursor 上把「谁来做、做到哪一步、什么时候必须等你点头」固定下来：**Leader 统筹 + 子 Agent 分工 + 有界 WU**。  
（Codex 上等价编排为 `omx ultrawork`。）

### 总览

```text
┌─────────┐     需求澄清 / 方案 / 计划      ┌──────────────────────────────────┐
│  你     │ ◄──── Leader 汇报、门禁确认 ────│  Leader（主 Agent / 技术主管）    │
│ （甲方）│                                 │  拆 WU · 派发 · 整合 · 验证       │
└─────────┘                                 └───────────────┬──────────────────┘
                                                            │
                    ┌───────────────────────────────────────┼───────────────────────┐
                    ▼                   ▼                   ▼                       ▼
              harness-coder      harness-implementer   harness-test-engineer   harness-reviewer
              （写业务代码）      （文档/chore/配置）     （测试/E2E）            （独立审查，可选）
```

每个任务 Leader 首句：`「Harness：<route>」`（极小改动可用 `「Harness：小改动，直接处理」`）。

### 阶段怎么走

| 顺序 | 阶段 | 谁 | 你要做什么 | 产物 |
|:---:|------|-----|------------|------|
| 1 | 需求与设计 | Leader | 确认范围与验收标准 | `.ai-runtime-artifacts/specs/` |
| 2 | 实施计划（可选） | Leader | 大改动时确认步骤 | `.ai-runtime-artifacts/plans/` |
| 3 | 编码 | Leader 派子 Agent | 说「开始实现」 | 代码 + `execution-logs/` |
| 4 | 收尾验证 | Leader | 看验收结论 | 验证通过 / execution-log |

**门禁：** 写完 spec（以及 plan，若有）后 AI **必须停下**，等你明确说「写计划 / 开始实现」等再继续。

**需求澄清：** Leader 优先用 **Ask 类工具**（如 Cursor `AskQuestion`）让你点选；没有则用对话，**一次只问一个关键问题**。

### 六个角色各干什么

| 角色 | 对应 Subagent | 干什么 | 不干什么 |
|------|---------------|--------|----------|
| **Leader** | 主会话 | 和你对接、拆任务、派活、整合结果、**对甲方汇报**、Git 提交 | 大规模亲自写业务代码 |
| **Coder** | `harness-coder` | 写代码 + 单测 + 跑验证 + **开发者自检** | 扩需求、派子 Agent、自己当终审 |
| **Implementer** | `harness-implementer` | 改文档、配置、chore 类小活 | 承担完整「资深开发」闭环 |
| **Test Engineer** | `harness-test-engineer` | 补测试 / E2E | 改业务实现 |
| **Reviewer** | `harness-reviewer` | 独立 code review（只读） | 与写代码的 Agent 同一实例 |
| **Explorer / Debugger** | 探查 / 排障 | 摸底、查 bug | — |

**Leader 汇报（给你看）：** 状态 · 本轮做/不做什么 · 风险 · 怎么验收 · 下一步（是否还要审查）。

### 什么活派 Coder，什么活派 Implementer

| 任务类型 `wu_type` | 派谁 | Coder 额外要求 |
|-------------------|------|----------------|
| `feature` `bugfix` `refactor` `ui` | **Coder** | 见下表「交付清单」 |
| `review-fix`（审查打回） | **Coder** | 按 Reviewer 意见改，再自检 |
| `docs` `chore` `config` | **Implementer** | 按 WU 完成即可 |
| `test` `e2e` | **Test Engineer** | — |
| 实现后审查 | **Reviewer** | 与 Coder **不同实例** |

### Coder 交付清单（缺一不可）

| 项 | 要求 |
|----|------|
| 实现 | 只改 Leader 允许的文件（通常 ≤5 个） |
| 日志 / 错误处理 | 按项目既有规范 |
| 单测 | 有新增逻辑就要测；豁免须在返回里说明 |
| 自测 | **真实运行**验证命令，不能口头说 pass |
| 开发者自检 | `self_check: PASS` 才能报完成；否则 `FAIL` + 阻塞说明 |

自检返回字段：`self_check` · `open_items` · `skip_reviewer_eligible`（Leader 决定是否可免审查）。

### 还要不要 Reviewer？

| 情况 | 要不要派 `harness-reviewer` |
|------|---------------------------|
| 改文件 >5，或动到安全/鉴权/支付 | **必须** |
| 公共 API、DB 迁移、跨模块架构 | **必须** |
| 你明确要求审查 | **必须** |
| Coder 自检 FAIL 或有未关 Important | **必须** |
| 改文件 ≤5、无上面风险、自检 PASS、验证过 | **可跳过**（Leader 在 log 里记原因） |

### 并行：WU 怎么拆

**WU（Work Unit）** = 从已批准 plan 切出的一小块：文件列表清晰、有 done criteria、并行时不抢同一文件。

| 字段 | 含义 |
|------|------|
| `wu_type` | 决定派 Coder 还是 Implementer（见上表） |
| `wu_skills` | 推荐 `auto`；Leader 手写列表则子 Agent **必须照做** |
| `agent_role` | `coder` / `implementer` / `test-engineer` 等 |

示例（同一 GROUP 可并行）：

| WU | 派谁 | 改什么 |
|----|------|--------|
| WU-01 `feature` | Coder | `api/users.ts` + 单测 |
| WU-02 `docs` | Implementer | `README.md` |
| WU-03 `feature`（依赖 01） | Coder | `hooks/useUsers.ts` |

---

## 支持的工具

接入完成后，项目根目录通常具备：

| 类型 | 路径 |
|------|------|
| 顶层契约 | `AGENTS.md` |
| Claude Code | `CLAUDE.md` |
| Gemini | `GEMINI.md` |
| Cursor | `.cursor/rules/`、`.cursor/agents/harness-*`（**含 harness-coder**） |
| Cursor 编排深读 | `harness-kit/adapters/cursor/orchestration/`（不投影，供 AI 读取） |
| Agents / Skills | `.agents/`（含 `cursor-orchestration`） |
| Codex / OMX | `.codex/`（主要由 `omx setup` 生成） |

Cursor 适配说明：`adapters/cursor/README.md`。

---

## 目录结构

```
harness-kit/
├── README.md
├── project.profile.md
├── context-map.md
├── project.verification.md
├── project.git.md
├── core/
│   ├── harness.md
│   ├── routing.md
│   ├── artifacts.md
│   ├── verification.md
│   └── runbooks.md
├── init/
├── entrypoints/
├── adapters/
│   ├── cursor/
│   │   ├── .cursor/agents/    # harness-coder, harness-implementer, …
│   │   └── orchestration/
│   ├── codex/
│   └── agents/
├── scripts/
└── artifact-templates/
```

| 目录 | 职责 |
|------|------|
| `core/` | 通用规则，不随业务重写 |
| `adapters/cursor/` | Cursor rules、六套 subagent、dispatcher 工作流 |
| `artifact-templates/` | spec / plan / wu-checklist 等模板 |

---

## 推荐阅读顺序

1. 本 README § [Cursor 编程协作模式](#cursor-编程协作模式)
2. `core/routing.md`（路由与门禁细则）
3. `project.profile.md`、`project.verification.md`（按任务）

---

## 新项目接入

将本仓库放入目标项目的 `harness-kit/` 后，把以下内容发给 AI：

```text
请先读取 harness-kit/README.md 和 harness-kit/init/bootstrap.prompt.md。
这是一个新项目刚接入 Agent Harness，请按 Harness 初始化流程处理：
1. 从 harness-kit/entrypoints/ 投影根目录 AI 入口文件。
2. 从 harness-kit/adapters/ 投影工具适配目录（含 .cursor/agents/、.cursor/rules/ 与 cursor-orchestration skill）。
3. 如需安装或检查 AI runtime，请先说明会修改哪些本机环境，然后执行 harness-kit/scripts/install-ai-skills.sh。
4. 创建 .ai-runtime-artifacts/ 及其子目录（含 execution-logs/ 与 execution-logs/tracking/）。
5. 读取并执行 harness-kit/init/project-profiler.prompt.md（以 harness-kit/init/templates/ 为章节骨架，更新四份 project.*，用 project.profile 摘要替换 CLAUDE.md、GEMINI.md 与 harness-kit/entrypoints/HARNESS-PLATFORM-ENTRY.md 中的 {{PROJECT_BACKGROUND}}，并运行 harness-kit/scripts/harness-check.sh）。
6. 汇总推断项、待确认项和验证结果。

详版步骤见 harness-kit/init/bootstrap.prompt.md。
```

初始化完成后应生成或更新四份 `project.*`，并在回复中说明检查结果与待确认项。

---

## 接入方式建议

| 方式 | 适用场景 |
|------|----------|
| **Git Submodule** | 多项目共用 harness-kit，升级与业务提交分离 |
| **目录拷贝** | 单项目快速接入；Harness 变更建议独立 commit（`chore(harness-kit): ...`） |

---

## 更多文档

| 文档 | 说明 |
|------|------|
| `adapters/cursor/README.md` | Cursor 投影与编排 |
| `adapters/cursor/orchestration/dispatcher-workflow.md` | 派发与整合步骤（AI 深读） |
| `init/bootstrap.prompt.md` | 新项目接入详版 |
| `core/artifacts.md` | 过程产物规范 |
