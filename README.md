# Harness Kit

**可迁移的 Agent Harness 脚手架**：把项目规则、工作流路由、过程产物、验证门禁和工具适配打包成一套标准，接入任意代码仓库即可使用。

> **核心价值**：解决 LLM 代码生成"可靠性、一致性与长期可维护性"问题。Harness 像马具——用缰绳与鞍具把马力引到正确方向，而不是限制能力本身。

---

## 目录

- [架构设计](#架构设计)
  - [双层结构：深读层 vs 投影层](#双层结构深读层-vs-投影层)
  - [平台适配机制](#平台适配机制)
  - [目录结构](#目录结构)
- [Agent Team](#agent-team)
  - [角色体系](#角色体系)
  - [Leader 职责](#leader-职责)
  - [Worker 分工](#worker-分工)
  - [协作模式](#协作模式)
- [软件工程方法论](#软件工程方法论)
  - [阶段门禁链](#阶段门禁链)
  - [Tier 分级体系](#tier-分级体系)
  - [文档驱动开发](#文档驱动开发)
  - [References 强制检查](#references-强制检查)
- [快速接入](#快速接入)
- [核心文件索引](#核心文件索引)

---

# 架构设计

## 双层结构：深读层 vs 投影层

Harness 采用**双层架构**，分离"AI 详细规则"与"平台入口文件"：

```
┌─────────────────────────────────────────────────────────────────┐
│                     接入项目（根目录）                            │
├─────────────────────────────────────────────────────────────────┤
│  AGENTS.md          ← 平台入口（投影层：精简，指针）             │
│  CLAUDE.md          ← Claude Code 入口                          │
│  .cursor/rules/     ← Cursor 入口                               │
│  .agents/agents/    ← 共享 subagent（投影层）                  │
│  .claude/skills/    ← 共享 skill（投影层）                     │
└─────────────────────────────────────────────────────────────────┘
                              ↑
                         脚本投影
                              ↑
┌─────────────────────────────────────────────────────────────────┐
│                   harness-kit/（脚手架仓库）                      │
├─────────────────────────────────────────────────────────────────┤
│  core/orchestration/  ← 深读层：详细规则（不投影）               │
│  core/routing.md      ← 路由判定 + 阶段门禁                      │
│  core/capabilities/   ← 抽象原语                                │
│  adapters/            ← 平台适配（cursor / claude / trae）       │
│  .agents/agents/      ← 投影层：subagent stub                   │
│  entrypoints/         ← 入口文件模板                             │
└─────────────────────────────────────────────────────────────────┘
```

| 层级 | 路径 | 作用 | 迁移行为 |
|------|------|------|----------|
| **深读层** | `core/orchestration/`、`core/capabilities/` | AI 按需读取的详细规则 | 随 harness-kit 拉取，不投影 |
| **投影层** | `entrypoints/` → 根目录 | 平台入口（精简） | 初始化时投影到项目根目录 |

**原则**：
- 深读层与投影层**内容必须一致**；改 agent 时同步两边
- 投影层文件仅含 front matter + 指针，保持精简
- 深读层含详细 prompt、返回格式、禁止项

## 平台适配机制

```
┌──────────────────────────────────────────────┐
│  routing.md（路由判定，平台无关）             │
└─────────────────┬────────────────────────────┘
                  │ 平台特定绑定
    ┌─────────────┼─────────────┬─────────────┐
    ▼             ▼             ▼             ▼
adapters/     adapters/    adapters/    adapters/
cursor/       claude/      trae/        agents/  ← 共享层
bindings.md   bindings.md  (骨架)       (stub)
```

| 适配器 | 绑定内容 |
|--------|----------|
| `adapters/cursor/` | Cursor 编排、spawn、hooks |
| `adapters/claude/` | Claude Code bindings、能力矩阵 |
| `adapters/agents/` | 共享 subagent（所有平台共用） |

**平台能力矩阵**：

| Capability | Cursor | Claude Code |
|------------|--------|-------------|
| `SpawnWorker` | `Task` 工具 | `Task` 工具 |
| `StructuredAsk` | `AskQuestion` | `AskUserQuestion` |
| `GitWorktree` | 原生支持 | 原生支持 |
| `CollectiveReview` | 并行 Task | 并行 Task |

## 目录结构

```
harness-kit/
├── README.md                    # 本文件
│
├── core/                        # 通用规则（不随业务重写）
│   ├── harness.md               # 总契约
│   ├── routing.md               # 路由判定 + 阶段门禁 + Tier 分级
│   ├── artifacts.md            # 产物规范
│   ├── verification.md          # 验证规范
│   │
│   ├── capabilities/            # 抽象原语
│   │   ├── DetectPlatform.md   # 平台检测
│   │   ├── SpawnWorker.md      # Worker 派生
│   │   └── EmitHook.md         # Hook 机制
│   │
│   ├── orchestration/           # 编排核心（深读层）
│   │   ├── dispatcher-workflow.md  # 派发 + 整合步骤
│   │   ├── agents/                 # 详细 agent prompt
│   │   ├── roles/                  # 角色定义
│   │   └── tracking/               # 追踪 schema
│   │
│   └── extensions/             # 平台无关扩展
│       ├── hooks/              # Hook 抽象
│       └── mcp/                # MCP 模板
│
├── adapters/                   # 平台适配
│   ├── cursor/                 # Cursor binding
│   ├── claude/                 # Claude Code binding
│   ├── trae/                   # Trae 骨架
│   └── agents/                 # 共享层（投影用）
│
├── entrypoints/                # 投影到根目录的模板
│   ├── AGENTS.md
│   ├── CLAUDE.md
│   └── HARNESS-PLATFORM-ENTRY.md
│
├── init/                       # 接入脚本 + 话术
│   ├── bootstrap.prompt.md
│   └── project-profiler.prompt.md
│
├── scripts/                    # 工具脚本
│   ├── harness-project.sh     # 投影脚本
│   └── install-ai-skills.sh   # 安装脚本
│
├── references/                 # 强制检查清单
│   ├── definition-of-done.md
│   ├── security-checklist.md
│   ├── performance-checklist.md
│   └── ...
│
├── artifact-templates/         # 产物模板
│   ├── spec.harness-overlay.md
│   ├── plan.harness-overlay.md
│   └── collective-test.md
│
├── project.profile.md          # 项目画像（接入后生成）
├── context-map.md              # 上下文地图（接入后生成）
├── project.verification.md     # 验证命令（接入后生成）
└── project.git.md             # Git 差异（接入后生成）
```

---

# Agent Team

## 角色体系

```
┌─────────────────────────────────────────────────────────────────┐
│                         你（甲方）                               │
│                    确认范围 / 审批门禁                            │
└─────────────────────────────┬───────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                         Leader                                   │
│         路由判定 · 拆 WU · 派发 · 整合 · 汇报                    │
└───────────┬───────────┬───────────┬───────────┬────────────────┘
            │           │           │           │
            ▼           ▼           ▼           ▼
        Coder    Implementer  Test-Engineer  Reviewer
     （写代码）   （文档/配置）   （E2E/测试）  （独立审查）
            │           │           │
            └───────────┴───────────┘
                        │
                        ▼
               Git Worktree（隔离）
```

## Leader 职责

**Leader** 是主 Agent / 技术主管，不亲自写大规模业务代码（Tier 1 简单实现除外）。

| 职责 | 说明 |
|------|------|
| **路由判定** | 首句 `「Harness：<route>」` |
| **阶段门禁** | spec/plan 写完后暂停，等用户确认 |
| **拆 WU** | 从 plan 提取 Work Unit，写执行图 |
| **派发** | 按 `wu_type` 委派给对应 Worker |
| **整合** | 验证 Worker 返回，更新 tracking |
| **尾盘** | 集体测试 → 集体审查 → 落盘两产物 |
| **汇报** | 对甲方输出状态 · 风险 · 验收口径 |

**禁止**：
- 与 Worker 共用同一 subagent 实例做审查
- 未写 tracking 就并行派发多个 WU
- 末个 WU 返回后直接"完成"（须先尾盘）

## Worker 分工

| 角色 | `wu_type` | 职责 | 禁止 |
|------|-----------|------|------|
| **Coder** | `feature` `bugfix` `refactor` `ui` `review-fix` | 实现 + 单测 + 自测 + 轻量审查 + self_check | E2E/集成测试、改 plan |
| **Implementer** | `docs` `chore` `config` | 文档 / 配置 / 轻量变更 | 代码闭环、改 plan |
| **Test Engineer** | `test` `e2e` | 集成/E2E/前端自动化 | 改业务实现 |
| **Reviewer** | — | 独立 code review（只读） | 与写代码同一实例 |
| **Explorer/Debugger** | — | 摸底、查 bug | — |
| **Web Investigator** | — | 信息调研/网页搜索 | — |

### Coder 交付清单

| 项 | 要求 |
|----|------|
| 实现 | 只改 Leader 允许的文件（通常 ≤5 个） |
| 单测 | 有新增逻辑就要测；豁免须说明 |
| 自测 | 跑 Leader 指定的**单测/lint** 命令 |
| 轻量审查 | `requesting-code-review` + 独立 reviewer |
| 开发者自检 | `self_check: PASS` 才能报完成 |

## 协作模式

### 阶段链

```
brainstorming → [门禁：用户确认 spec]
→ writing-plans → [门禁：用户确认 plan]
→ 派发 WU（并行 ≤5）
→ 尾盘 A：集体测试（Leader 落盘）
→ 尾盘 B：集体审查（独立 reviewer）
→ execution-log 关闭
```

### 尾盘规则

| 情况 | 尾盘 Reviewer |
|------|----------------|
| 改文件 >5，或动到安全/鉴权/支付 | **必须** |
| 公共 API、DB 迁移、跨模块架构 | **必须** |
| 改文件 ≤5、无风险、自检 PASS、集体测试 PASS | **可 SKIPPED** |

---

# 软件工程方法论

## 阶段门禁链

| 阶段 | 产物 | 门禁动作 |
|------|------|----------|
| 方案设计 | `.ai-runtime-artifacts/specs/` | **写入后暂停**，等你确认 |
| 实施计划 | `.ai-runtime-artifacts/plans/` | **写入后暂停**，等你确认 |
| 实现 | WU 执行 | 仅当 spec/plan 已批准或属小改动 |
| 尾盘 | collective-test + code-review | WU 全返后**默认进入** |

**同轮禁止**：Write `specs/` / `plans/` / `decisions/` 后，同轮不得改业务代码、派子 Agent、WORKTREE-INIT。

## Tier 分级体系

| Tier | 名称 | 场景 | 产物 |
|------|------|------|------|
| **0** | 机械小改 | 单文件 typo、改常量 | 无 FM；回复含验证摘要 |
| **1** | Leader 直做 | ≥2 写文件、bugfix、小 feature | `verification-lite.md` |
| **2+** | 编排交付 | 多 task、并行 WU、批次尾盘 | spec/plan/dispatch + 完整产物链 |

**Tier 升级**：执行中发现 Tier 估低 → 立即补 Tier 1 产物或暂停升级。

## 文档驱动开发

### 五级上下文层级

```
L1: Rules Files (project.profile.md, CLAUDE.md)  ← 始终加载
L2: Spec / Architecture Docs                      ← 按 Feature 加载
L3: Relevant Source Files (≤5 个)               ← 按 Task 加载
L4: Contract / Interface Definitions              ← 跨 WU 时加载
L5: Error Output / Test Results                  ← 按 Iteration 加载
```

### Self-Context Pack（Tier 1 必须）

Leader 在开始写代码前必须执行上下文打包：

1. **扫描** `.ai-runtime-artifacts/` 中相关产物
2. **读取** project.profile.md（L1）、相关 spec 章节（L2）
3. **定位** 目标源文件 ≤5 个（L3）
4. **打包** WU Context Block → 随派发 prompt 传递

## References 强制检查

### 7 个强制 Reference

| # | Reference | 用途 | 触发路由 |
|---|-----------|------|----------|
| 1 | `definition-of-done.md` | 完成定义（20+ 检查项） | 所有编码任务 |
| 2 | `testing-patterns.md` | AAA / Mock / 反模式 | 含测试 WU |
| 3 | `security-checklist.md` | OWASP Top 10 + LLM 安全 | API/数据变更 |
| 4 | `performance-checklist.md` | CWV + N+1 + Bundle | UI 变更 |
| 5 | `observability-checklist.md` | 日志/指标/告警 | Ship Gate |
| 6 | `accessibility-checklist.md` | WCAG 2.1 AA | 前端 Ship |
| 7 | `orchestration-patterns.md` | 编排反模式自检 | 并行 WU |

### 尾盘全量检查

GROUP 收尾 / Ship Gate 必须对照全部 7 个 reference，逐项给出 `pass/fail/n/a`。

**违规**：未 Read 即声称完成 → 无效；产物无 `### References 检查` → 退回。

---

# 快速接入

## 新项目接入

将 harness-kit 放入目标项目的 `harness-kit/` 后：

```text
请先读取 harness-kit/README.md 和 harness-kit/init/bootstrap.prompt.md。
这是一个新项目刚接入 Agent Harness，请按 Harness 初始化流程处理：
0. 询问平台（Cursor / Claude Code / Trae）
1. 清理 git 元数据，更新 .gitignore
2. 从 entrypoints/ 投影根目录 AI 入口文件
3. 运行 `bash harness-kit/scripts/harness-project.sh project`
4. 创建 .ai-runtime-artifacts/ 及其子目录
5. 读取并执行 project-profiler.prompt.md
6. 汇总检查结果与待确认项
```

## 接入方式

| 方式 | 适用场景 |
|------|----------|
| **Git Submodule** | 多项目共用，升级与业务提交分离 |
| **目录拷贝** | 单项目快速接入 |

## 改造 Harness Kit

```text
我要改造 Harness Kit，目标如下：
【填写：新增角色 / 修改派发规则 / 调整门禁等】

约束：
1. 先输出方案，等我确认后再改
2. 遵守双层结构：深读层 + 投影层同步
3. 影响「谁来做、何时停」的变更必须同步 routing.md
4. 完成后运行 harness-check.sh
```

---

# 核心文件索引

| 文件 | 说明 |
|------|------|
| `core/routing.md` | 路由判定 + 阶段门禁 + Tier 分级（**必读**） |
| `core/orchestration/dispatcher-workflow.md` | 派发 + 整合步骤 |
| `core/orchestration/agents/leader.md` | Leader 详细 prompt |
| `core/orchestration/agents/coder.md` | Coder 详细 prompt |
| `adapters/claude/bindings.md` | Claude Code 平台绑定 |
| `adapters/cursor/README.md` | Cursor 投影与编排 |
| `init/bootstrap.prompt.md` | 新项目接入详版 |
| `references/definition-of-done.md` | 完成定义（强制检查） |

---

## 更多文档

| 文档 | 说明 |
|------|------|
| `adapters/cursor/README.md` | Cursor 投影与编排 |
| `core/orchestration/dispatcher-workflow.md` | 派发与整合步骤（AI 深读） |
| `init/bootstrap.prompt.md` | 新项目接入详版 |
| `core/artifacts.md` | 过程产物规范 |
| `docs/communication-templates.md` | 完整沟通话术模板集 |
