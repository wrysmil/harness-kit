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
- [改造 Harness Kit（编排 / Agent）](#改造-harness-kit编排--agent)
- [接入方式建议](#接入方式建议)
- [技术负责人沟通模板](#技术负责人沟通模板)
- [更多文档](#更多文档)

---

## 什么是 Harness Engineering

**Harness Engineering** 是围绕 AI Coding Agent 设计约束机制、反馈回路、工作流控制与持续改进的系统工程实践。核心问题是：当 Agent 具备强代码生成能力后，如何保证输出的**可靠性、一致性与长期可维护性**。

**Harness** 本义是马具——用缰绳与鞍具把马力引到正确方向。LLM 像一匹劲大但易跑偏的马；Harness 负责**定向、限速、验货与交接**，而不是限制能力本身。

---

## 解决什么问题

Harness 工程化常卡在「起步」：规则散落、各工具各一套、验证标准不统一。Harness Kit 的目标是：

1. **降低接入成本** — 将 `harness-kit/` 放入项目，把初始化话术交给 AI 即可。
2. **统一多工具入口** — 同一套规范投影到 Cursor、Claude Code 等环境。
3. **可迁移、可沉淀** — 规范在 `harness-kit/` 中迭代，团队可逐步优化为自有资产。

---

## 与单纯使用 Skill 的区别

许多团队从 **harness-engineer**、**superpowers** 等 Agent Skill 起步：能力装在 Skill 里，主要靠对话里临时提醒 AI「按某 skill 做」。  
**Harness Kit** 把「这个项目怎么干」写进仓库里的 `harness-kit/`，换电脑、换同事、换 Cursor/Claude Code，拉同一份代码就能沿用同一套规则。

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
| `core/capabilities/` | 抽象原语（DetectPlatform / SpawnWorker / EmitHook / …） |
| `core/orchestration/` | 编排核心（dispatcher / agents / roles / continuous-loop） |
| `core/extensions/` | 平台无关扩展抽象（hooks 统一内容 + spec；MCP 模板） |
| `core/artifacts.md` | `.ai-runtime-artifacts/` 命名与 front matter |
| `entrypoints/` | 投影到根目录的 `AGENTS.md`、`CLAUDE.md` 等 |
| `adapters/agents/` | 共享层（`.agents/skills/` + `.agents/agents/`，所有平台共用） |
| `adapters/cursor/` | Cursor 平台 binding |
| `adapters/claude/` | Claude Code 平台 binding |
| `init/` | 接入与 bootstrap 话术 |
| `artifact-templates/` | 编排模板 + `*-harness-overlay.md`（stage skill 契约）；`spec.md`/`plan.md` 为 stub |

---

## Cursor 编程协作模式

Cursor 上把「谁来做、做到哪一步、什么时候必须等你点头」固定下来：**Leader 统筹 + 子 Agent 分工 + 有界 WU**。

### 总览

```text
┌─────────┐     需求澄清 / 方案 / 计划      ┌──────────────────────────────────┐
│  你     │ ◄──── Leader 汇报、门禁确认 ────│  Leader（主 Agent / 技术主管）    │
│ （甲方）│                                 │  拆 WU · 派发 · 整合 · 验证       │
└─────────┘                                 └───────────────┬──────────────────┘
                                                            │
                    ┌───────────────────────────────────────┼───────────────────────┐
                    ▼                   ▼                   ▼                       ▼
              coder            implementer         test-engineer        reviewer
              （写业务代码）      （文档/chore/配置）     （测试/E2E）            （独立审查，可选）
```

每个任务 Leader 首句：`「Harness：<route 或 "小改动，直接处理">」`；将用到 skill 时次行 `Skills:`。

### 阶段怎么走

| 顺序 | 阶段 | 谁 | 你要做什么 | 产物 |
|:---:|------|-----|------------|------|
| 1 | 需求与设计 | Leader | 确认范围与验收标准 | `brainstorming` → `.ai-runtime-artifacts/specs/` |
| 2 | 实施计划（可选） | Leader | 大改动时确认步骤 | `writing-plans` → `plans/` + 并行时 `*-dispatch.md` |
| 3 | 编码 | Leader 派子 Agent | 说「开始实现」 | 代码 + `execution-logs/` |
| 4 | 收尾验证 | Leader | 看验收结论 | 验证通过 / execution-log |

**门禁：** 写完 spec（以及 plan，若有）后 AI **必须停下**，等你明确说「写计划 / 开始实现」等再继续。

**需求澄清：** Leader 优先用 **Ask 类工具**（如 Cursor `AskQuestion`）让你点选；没有则用对话，**一次只问一个关键问题**。

### 六个角色各干什么

| 角色 | 对应 Subagent | 干什么 | 不干什么 |
|------|---------------|--------|----------|
| **Leader** | 主会话 | 和你对接、拆任务、派活、整合结果、**对甲方汇报**、Git 提交 | 大规模亲自写业务代码 |
| **Coder** | `coder` | 写代码 + **单测** + 轻量审查 + 自检 | E2E/集成测试、改 plan、终审 |
| **Implementer** | `implementer` | 文档 / 配置 / chore | 代码闭环、改 plan |
| **Test Engineer** | `test-engineer` | 集成 / E2E / 前端自动化（`e2e` 必读 `agent-browser`） | 改业务实现 |
| **Reviewer** | `reviewer` | 独立 code review（只读） | 与写代码的 Agent 同一实例 |
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
| 自测 | 跑 Leader 指定的**单测/lint** 命令（非 E2E） |
| 轻量审查 | `requesting-code-review` + 独立 reviewer；`code_review: PASS` |
| 开发者自检 | `self_check: PASS` 才能报完成 |

返回含 `wu_status`；**plan 勾选由 Leader 写**。末个 WU 返回 **≠ 批次完成**，须走 **尾盘**（见下）。

### GROUP 尾盘（集体测试 → 集体审查）

本 GROUP 全部 WU 返回后，Leader **必须**（细则 `docs/superpowers/specs/2026-05-28-batch-closeout-review-and-collective-test.md`）：

| 顺序 | 动作 | 落盘 |
| --- | --- | --- |
| 1 | 按 `project.verification.md` 跑本批次验证（先测后审） | `verifications/*-collective-test.md` |
| 2 | 委派 **reviewer**（独立实例）；Reviewer 只返回，Leader Write | `reviews/*-code-review.md` |
| 3 | 更新 execution-log § 尾盘门禁 | 两产物链接 + 结论 |

**完成** = 上表 1–3 通过，不是末个 Coder 报 `done`。

### 还要不要集体 Reviewer？（尾盘 B）

| 情况 | 尾盘 `reviewer` |
|------|-------------------------|
| 改文件 >5，或动到安全/鉴权/支付 | **必须** |
| 公共 API、DB 迁移、跨模块架构 | **必须** |
| 你明确要求审查 | **必须** |
| Coder 自检 FAIL 或有未关 Important | **必须** |
| 改文件 ≤5、无上面风险、自检 PASS、集体测试 PASS | **可 SKIPPED**（写入 `code-review` 产物 + 依据） |

WU 内 **轻量审查**（Coder + 独立 reviewer）**不替代** 上表尾盘 B。

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
| Claude Code | `CLAUDE.md`、`.claude/rules/ai-entry.md`（always-loaded）、`.claude/skills/`（共享 skill 镜像）、`.claude/hooks/` + `content/` + `settings.json.example`（opt-in hooks） |
| Cursor | `.cursor/rules/`、`.agents/agents/`（共享 subagent）、`.cursor/hooks.json`（opt-in） |
| Cursor 编排深读 | `harness-kit/core/orchestration/`（不投影，供 AI 读取） |
| Agents / Skills | `.agents/`（含 `orchestration`） |
| Hooks 扩展 | `.cursor/hooks/` 或 `.claude/hooks/` + `content/*.md`（来自 `core/extensions/hooks/`，opt-in） |
| MCP | `.mcp.json`（来自 `core/extensions/mcp/`，按需编辑 server） |

适配器说明：`adapters/cursor/README.md` / `adapters/claude/README.md`。统一扩展：[core/extensions/README.md](core/extensions/README.md)。

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
│   ├── capabilities/          # 抽象原语（DetectPlatform / SpawnWorker / EmitHook …）
│   ├── orchestration/         # 编排核心（dispatcher / agents / roles）
│   └── extensions/            # 平台无关扩展（hooks / MCP）
├── init/
├── entrypoints/
├── adapters/
│   ├── cursor/                # Cursor 平台 binding
│   ├── claude/                # Claude Code 平台 binding
│   ├── trae/                  # Trae 骨架
│   └── agents/                # 共享层（.agents/skills + .agents/agents）
├── scripts/
└── artifact-templates/
```

| 目录 | 职责 |
|------|------|
| `core/` | 通用规则，不随业务重写 |
| `core/capabilities/` | 抽象原语（DetectPlatform / SpawnWorker / EmitHook 等）+ 降级协议 |
| `core/orchestration/` | dispatcher-workflow、roles、agent manifest、continuous-loop |
| `core/extensions/` | 平台无关扩展抽象（hooks 统一内容、spec、wrapper；MCP 模板） |
| `adapters/agents/` | 共享层（`.agents/skills/` + `.agents/agents/`，所有平台共用） |
| `adapters/cursor/` | Cursor 平台 binding（rules / agents manifest / config defaults） |
| `adapters/claude/` | Claude Code 平台 binding（capability matrix / bindings） |
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
0. 先问我：「你当前使用哪个 AI 编程工具？」（Cursor / Claude Code / Trae / 其他）。根据我的回答确定平台适配层投影范围，后续步骤仅投影对应平台。
1. 清理 harness-kit/ 随仓库携带的 git 元数据，并更新项目根 .gitignore：
   - 删除 harness-kit/.git/（harness-kit 源仓库的 .git；不要动到项目自身的 .git/）
   - 如存在 harness-kit/.gitignore、harness-kit/.gitattributes、harness-kit/.gitmodules，一并删除
   - 在项目根 .gitignore 追加（保留已有内容；不存在则创建）：
     ```
     # Agent Harness
     harness-kit/*
     .ai-runtime-artifacts/
     ```
2. 从 harness-kit/entrypoints/ 投影根目录 AI 入口文件（AGENTS.md、CLAUDE.md 等）。
3. 运行 `bash harness-kit/scripts/harness-project.sh project`，自动检测平台并投影共享层（.agents/）与平台适配层（.cursor/、.claude/、.trae/ 等）。
4. 如需安装或检查 AI runtime，请先说明会修改哪些本机环境，然后执行 harness-kit/scripts/install-ai-skills.sh。
5. 创建 .ai-runtime-artifacts/ 及其子目录（含 execution-logs/ 与 execution-logs/tracking/）。
6. 读取并执行 harness-kit/init/project-profiler.prompt.md（以 harness-kit/init/templates/ 为章节骨架，更新四份 project.*，用 project.profile 摘要替换 CLAUDE.md 与 harness-kit/entrypoints/HARNESS-PLATFORM-ENTRY.md 中的 {{PROJECT_BACKGROUND}}，并运行 harness-kit/scripts/harness-check.sh）。
7. 汇总推断项、待确认项和验证结果。

详版步骤见 harness-kit/init/bootstrap.prompt.md。
```

初始化完成后应生成或更新四份 `project.*`，并在回复中说明检查结果与待确认项。

**Claude 平台层预期文件（运行 `harness-project.sh project` 后必须全部出现）：**

| 路径 | 性质 | 作用 |
|------|------|------|
| `.claude/rules/ai-entry.md` | 必生成 | always-loaded：强制声明 `「Harness：…」`、写文件纪律、同轮禁止 |
| `.claude/skills/<slug>/SKILL.md` | 必生成 | 共享层 skill 镜像（从 `.agents/skills/` 自动投影） |
| `.claude/hooks/harness-session-init.sh` | opt-in | SessionStart 钩子脚本 |
| `.claude/hooks/harness-subagent-stop.sh` | opt-in | SubagentStop 钩子脚本 |
| `.claude/hooks/content/*.md` | opt-in | 钩子提示词内容 |
| `.claude/settings.json.example` | opt-in | hooks 配置示例（默认不启用；启用需 `cp settings.json.example settings.json` 并合并到 `permissions`） |

任一缺失 → 跑 `bash harness-kit/scripts/harness-project.sh project --platform claude --force` 补投影。

---

## 改造 Harness Kit（编排 / Agent）

当你要**完善编排**、**改路由/门禁/派发流程**，或**新增/调整子 Agent** 时，把下面话术发给 AI（在 `harness-kit/` 仓库内操作，或在已接入项目的 `harness-kit/` 目录下操作）。  
大改动建议先在 `docs/superpowers/specs/` 写 spec，再改实现。

### 通用话术（编排 + Agent 均可）

```text
请先读取 harness-kit/README.md § Cursor 编程协作模式，以及：
- harness-kit/core/harness.md
- harness-kit/core/routing.md（路由表、阶段门禁、wu_type → subagent）
- harness-kit/adapters/cursor/README.md
- harness-kit/core/orchestration/dispatcher-workflow.md
- harness-kit/core/orchestration/platform-adapters.zh.md
- harness-kit/adapters/cursor/.cursor/rules/cursor-subagent-routing.mdc

我要改造 Harness Kit，目标如下（请据此实现，不要擅自扩大范围）：
【在此填写：例如「新增 harness-security 角色」「Coder 自检未通过时自动派 Reviewer」「调整并行 WU 上限」等】

约束与交付要求：
1. 先输出简短方案（改哪些文件、是否动 routing / 门禁 / 投影层），等我确认后再改文件；若我已在开头说「直接做」，可跳过确认。
2. 遵守 Harness 双层结构：
   - 编排深读：`harness-kit/core/orchestration/`（不投影）
   - 投影层：`harness-kit/.agents/agents/` → bootstrap 后到项目根 `.agents/agents/`
   - 深读与投影须一致；改 agent 时同步 `orchestration/agents/<role>.md` 与 `.agents/agents/<role>.md`。
3. 凡影响「谁来做、何时停、派谁」的变更，必须同步：
   - `harness-kit/core/routing.md`（Cursor / Claude 并列列）
   - `harness-kit/entrypoints/AGENTS.md` 路由摘要（如需要）
   - `harness-kit/adapters/cursor/.cursor/rules/cursor-subagent-routing.mdc`
   - 本 README § Cursor 编程协作模式（角色表、WU 表、Reviewer 规则等）
4. 不改 `core/` 里与本次目标无关的文件；不删除阶段门禁，除非我明确要求。
5. 完成后运行 `bash harness-kit/scripts/harness-check.sh`，在回复中列出：变更文件清单、行为差异、已接入项目是否需要重新投影 `.cursor/`、待我确认项。
6. 若改动涉及 Git 提交，单独 `chore(harness-kit): ...` 说明，不与业务代码混提。
```

### 话术 A：新增一个子 Agent

在通用话术后追加（或单独使用）：

```text
【角色定义】
- 角色英文名 / 文件名：例如 security-auditor
- 触发场景与 wu_type（若有）：例如 wu_type: security-review
- 职责（做 / 不做）：...
- readonly：true | false
- 与 Leader / Coder / Reviewer 的边界：...

请按现有 coder 模式落地：
1. 新增 `harness-kit/core/orchestration/agents/<role>.md`（详细 prompt、返回字段、禁止项）
2. 新增 `harness-kit/.agents/agents/<role>.md`（front matter：name、description、model、readonly）
3. 更新 `platform-adapters.zh.md` 角色映射表
4. 更新 `dispatcher-workflow.md` 步骤 2 派发表与委派 prompt 必填项
5. 更新 `cursor-subagent-routing.mdc` 与 `core/routing.md`（若新任务类型进路由表）
6. 更新 `skill-preferences.zh.md`（若该角色有默认 skill 链）
7. 更新本 README「六个角色」表

参考实现：`coder`（`orchestration/agents/coder.md` + `.agents/agents/coder.md` + `docs/superpowers/specs/2026-05-26-coder-role-design.md`）。
```

### 话术 B：修改工作编排（派发 / 并行 / 整合）

```text
【编排变更】
- 要改的流程：例如 dispatcher 步骤 3 整合规则、GROUP 并行上限、plan 勾选同步、Reviewer 跳过条件、Leader 汇报格式
- 期望行为（改前 → 改后）：...
- 是否影响阶段门禁（spec/plan 暂停）：是 / 否

请优先改：
- `harness-kit/core/orchestration/dispatcher-workflow.md`
- `harness-kit/.agents/skills/orchestration/SKILL.md`（与 dispatcher 一致）
- 若改路由或门禁：`harness-kit/core/routing.md`
- 若改 Leader 行为：`orchestration/agents/leader.md`
- 同步 README § Cursor 编程协作模式 中相关表格

```

### 话术 C：调整现有 Agent（不改名、不新增文件）

```text
【调整对象】：coder | implementer | reviewer | test-engineer | explorer | debugger | Leader

【变更内容】：例如 Coder 返回字段、自检门槛、禁止加载的 skill 列表、Implementer 适用 wu_type

请只改对应 `orchestration/agents/<role>.md` 与 `.agents/agents/<role>.md`，并检查 dispatcher / routing / README 是否有硬编码引用需要同步。
```

### 改造后：已接入项目如何生效

| 变更位置 | 业务项目要做的 |
|----------|----------------|
| 仅 `orchestration/`、`core/` | 拉取最新 `harness-kit/` 即可；AI 深读路径自动更新 |
| `.agents/agents/`、`.cursor/rules/` | 重新投影：运行 `bash harness-kit/scripts/harness-project.sh project --force`（或重跑 bootstrap 投影步骤） |
| `entrypoints/` | 重新投影 `AGENTS.md` 等根入口（合并时保留项目自有段落） |

投影命令可参考 `harness-kit/init/bootstrap.prompt.md` § 投影工具适配。

---

## 接入方式建议

| 方式 | 适用场景 |
|------|----------|
| **Git Submodule** | 多项目共用 harness-kit，升级与业务提交分离 |
| **目录拷贝** | 单项目快速接入；Harness 变更建议独立 commit（`chore(harness-kit): ...`） |

---

## 技术负责人沟通模板

向技术负责人派发任务时，按以下模板填写，避免模糊表述：

```
WU-<id>：<名称>
类型：bugfix | feature | refactor | docs | chore | config | test | e2e
目标：<一句话，可验证>
验收标准：
- [ ] ...
- [ ] ...
允许修改：`path/to/file1.ts`, `path/to/file2.ts`
禁止：修改范围外文件 / 新增依赖 / git commit
验证命令：`npm test -- ...`
```

---

## 更多文档

| 文档 | 说明 |
|------|------|
| `adapters/cursor/README.md` | Cursor 投影与编排 |
| `core/orchestration/dispatcher-workflow.md` | 派发与整合步骤（AI 深读） |
| `init/bootstrap.prompt.md` | 新项目接入详版 |
| `core/artifacts.md` | 过程产物规范 |
| `docs/communication-templates.md` | 完整沟通话术模板集 |
