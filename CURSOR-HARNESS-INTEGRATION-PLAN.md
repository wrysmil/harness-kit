# Cursor 子 Agent 编排集成方案 — 深度分析与决策

> **文档性质**：探索性方案（非已落地实现）  
> **分析对象**：`harness-kit`（本仓库） × `harness-engineer-5.3.0`（`~/.cursor/skills/harness-engineer-5.3.0/`）  
> **结论摘要**：**不建议整包直接使用**；推荐 **「分层嫁接 + 选择性改装」** —— 从 harness-engineer 抽取 Cursor 编排层，嵌入 `harness-kit/adapters/cursor/`，并与现有 `harness-kit/core/` 规范对齐。

---

## 1. 背景：上一轮判断需要修正什么

上一轮分析认为 Cursor 项目配置难以对等 OMX 的 6 类「Codex 独有能力」。  
在完整阅读 `harness-engineer-5.3.0` 后，需要修正：**其中约 4/6 已有语义等价物**，只是实现载体不同（prompt 协议 + Task 工具 + 文件状态机，而非 omx CLI）。

| 此前标注「Codex 独有」的能力 | harness-engineer 是否覆盖 | 覆盖方式 | 对等程度 |
|---|---|---|---|
| 15+ 专家角色目录 | ✅ | `agents/*.md`（researcher / planner / dispatcher / implementer / reviewer / debugger / architect …） | **~75%**（无独立 `.codex/agents/` 注册表，靠 Task prompt 模拟） |
| team / swarm / ultrawork 流水线 | ✅（语义） | `runtime/loop.md` + `agents/dispatcher.md` 的 WORKTREE → 并行 ITR 组 | **~70%**（无 tmux 多窗格，靠 Task 并行） |
| 确定性关键词路由 | ⚠️ | `runtime/hook-system.md` + `.cursor/hooks.json`（需项目配置） | **~55%**（非 omx 级 keyword registry） |
| `.omx/` 跨会话状态机 | ✅ | `docs/status/*` + `MEMORY.md` + `HANDOFF.md` | **~80%**（路径与 schema 不同） |
| `omx explore` / sparkshell 快速只读通道 | ✅ | `Task(subagent_type="explore", readonly=true)` | **~85%** |
| 按角色自动选模型 | ⚠️ | `platform-adapters.md` 映射 + prompt 约束 | **~45%**（无 omx setup 自动生成模型表） |

**修正后结论**：harness-engineer **确实**是 Cursor 侧补齐「子 Agent 操作系统」的可行来源；问题不在于「有没有」，而在于 **与 harness-kit 能否无冲突合并**。

---

## 2. 两套系统的定位对比

### 2.1 harness-kit（本仓库）

```
Runtime Layer      → omx / .codex/（Codex 专用，omx setup 生成）
Project Overlay    → harness-kit/core/* + project.profile 等（可迁移、中文、轻量）
Tool Bootstrap     → entrypoints + adapters/cursor（目前极薄：仅 ai-entry.mdc）
```

**设计目标**：可迁移脚手架；一次接入，多工具投影；**不**把完整 runtime 提交进 git。

### 2.2 harness-engineer-5.3.0

```
Skill 入口         → SKILL.md（全局 skill，instruction-only）
编排运行时         → runtime/loop.md（7 阶段自治循环）
角色定义           → agents/*.md（10 个 agent 面）
状态与追踪         → docs/status/*、docs/exec-plans/*、MEMORY.md
配置               → CONFIG.yaml + .harness/settings.json 叠加
平台适配           → references/platform-adapters.md（Cursor 一等公民）
安全与工具         → PLATFORM_REQUIREMENTS.md、tools/tool-router.md
```

**设计目标**：把**单个业务仓库**变成长期自治工程系统（continuous loop、自改进、GC、成本追踪）。

### 2.3 核心差异（决定能否「直接用」）

| 维度 | harness-kit | harness-engineer |
|---|---|---|
| 语言 | 中文 | 英文 |
| 产物目录 | `.ai-runtime-artifacts/{specs,plans,...}` | `docs/status/`、`docs/exec-plans/`、`docs/specs/` |
| 路由入口 | `harness-kit/core/routing.md` + `「Harness：…」` 强制声明 | `runtime/loop.md` 阶段机 + 多个人类 Gate |
| 计划/设计 skill | superpowers（brainstorming / writing-plans） | 内置 researcher + planner 三阶段 |
| 并行实现 | `omx ultrawork`（Codex CLI） | dispatcher + Task 并行 ITR |
| 安装形态 | 复制 `harness-kit/` 到目标项目 | 全局 Cursor skill（`~/.cursor/skills/`） |
| 平台前置条件 | 低（读 md + 可选 omx） | 高（PLATFORM_REQUIREMENTS 多项 HALT 检查） |
| 适用场景 | 任意仓库快速接入规范 | 单仓库长期自治循环 |

**结论**：二者是 **互补关系**，不是 **替代关系**；整包直接替换 harness-kit 的 Cursor 路径会引入大量结构性冲突。

---

## 3. harness-engineer 能力全景（与 Cursor 子 Agent 相关部分）

### 3.1 可直接服务于 Cursor 的核心资产

| 文件/目录 | 作用 | 对 Cursor 子 Agent 的价值 |
|---|---|---|
| `references/platform-adapters.md` | Cursor Task 角色映射 | **高** — 现成的 OMX 角色 → Task 对照 |
| `agents/dispatcher.md` | WORKTREE + 并行 ITR 调度 | **高** — ultrawork 语义等价 |
| `agents/researcher.md` | Q/R-Agent 并行调研 | **高** — explore 子 Agent 编排协议 |
| `agents/planner.md` | 三阶段计划 + gap 分析 | **中高** — 可替代或补充 writing-plans |
| `agents/implementer.md` | 有界实现 + 40% 上下文纪律 | **高** |
| `agents/reviewer.md` | 独立审查（生成≠审查） | **高** — P3 验证机制 |
| `runtime/context-engineering.md` | 上下文预算、拆分规则 | **高** |
| `runtime/status-management.md` | HANDOFF / 追踪日志恢复 | **高** |
| `runtime/hook-system.md` | Cursor hooks 接入说明 | **中** — 需额外写 hooks.json |
| `SKILL.md` Rule 8–14 | 并行上限、 stuck kill、追踪 | **高** — 可直接写进 Cursor rule |
| `CONFIG.yaml` | loop_mode、并行度默认值 | **中** — 需路径中文化/简化 |

### 3.2 不建议原样引入的部分

| 文件/目录 | 不原样引入的原因 |
|---|---|
| `PLATFORM_REQUIREMENTS.md` 全文 | 假设 MCP tool router、容器级读阻断；多数 Cursor 项目不具备，会导致 Phase 0 HALT |
| `runtime/loop.md` 完整 7 阶段 | 与 harness-kit runbook（brainstorming → plan → omx）双轨冲突；过重 |
| `templates/AGENTS.template.md` | 与现有 OMX 版 `entrypoints/AGENTS.md`（393 行）冲突 |
| `docs/status/` 目录约定 | 与 `.ai-runtime-artifacts/` 重复，应合并而非并存 |
| `tools/tool-router.md` | 依赖不存在的中央 router；Cursor 靠 sandbox + rule 即可 |
| `agents/garbage-collector.md`、`runtime/cost-tracking.md` | 自治循环高级特性；Phase 3+ 再考虑 |
| 全局 skill 安装方式 | harness-kit 目标是**项目内可迁移**；不应依赖 `~/.cursor/skills/` 单点 |

---

## 4. 三种集成策略评估

### 方案 A：整包直接使用 harness-engineer

**做法**：在目标项目激活全局 skill；按 SKILL.md 阅读顺序执行 loop。

| 优点 | 缺点 |
|---|---|
| 零改造，编排最完整 | 与 harness-kit 路由/产物 **双轨并行** |
| Cursor Task 映射现成 | AGENTS.md 仍指向 OMX，Cursor 会话混乱 |
| 角色/agent 定义齐全 | 英文 + docs/ 结构 vs 中文 + `.ai-runtime-artifacts/` |
| | PLATFORM_REQUIREMENTS 可能阻塞启动 |
| | Codex 用户失去 omx 原生路径的统一叙事 |

**评分**：Cursor 单工具 deep loop **7/10**；harness-kit 多工具可迁移 **3/10**  
** verdict**：❌ **不推荐作为 harness-kit 的官方 Cursor 路径**

---

### 方案 B：选择性改装 + 分层嫁接（推荐）

**做法**：从 harness-engineer **抽取 Cursor 编排层**，写入 `harness-kit/adapters/cursor/`，通过 rule/skill 投影；**保留** harness-kit 的 Project Overlay 为唯一规范源。

```
harness-kit/core/*          ← 唯一路由 / 产物 / 验证规范（中文）
harness-kit/adapters/cursor/
  ├── .cursor/rules/
  │     ├── ai-entry.mdc              （已有，增强）
  │     └── cursor-subagent-routing.mdc （新增：Task 映射 + Leader 协议）
  └── orchestration/                  （新增：从 harness-engineer 改装）
        ├── platform-adapters.zh.md
        ├── agents/                   （精简版 agent 面，中文）
        ├── dispatcher-workflow.md
        └── context-budget.md
.agents/skills/cursor-orchestration/  （新增 skill，触发 ultrawork 等价流程）
```

| 优点 | 缺点 |
|---|---|
| 保留 harness-kit 可迁移性 | 需要一次性改装工作量（约 1–2 天） |
| Codex / Cursor 双轨清晰 | 模型 per-role 路由仍弱于 omx |
| 中文、路径统一 | hooks 需可选单独配置 |
| 可渐进启用（single-pass 默认） | |

**评分**：Cursor 编排 **8/10**；harness-kit 一致性 **9/10**  
**verdict**：✅ **推荐**

---

### 方案 C：双轨并存（harness-kit 规范 + harness-engineer 自治模式）

**做法**：日常任务走 harness-kit；开启「自治循环」时额外激活 harness-engineer。

| 优点 | 缺点 |
|---|---|
| 各取所长 | 维护两套产物目录映射 |
| 自治模式能力最全 | 团队认知成本高 |
| | 需维护 bridge 文档 |

**评分**：能力 **9/10**；维护成本 **5/10**  
**verdict**：⚠️ **仅适合已有成熟业务仓 + 专人维护 harness 的团队**；不适合作为 harness-kit 默认模板。

---

## 5. 最终推荐：方案 B 的具体设计

### 5.1 原则

1. **规范单一来源**：`harness-kit/core/*` 优先；harness-engineer 内容降级为「Cursor 执行手册」。
2. **产物单一目录**：统一 `.ai-runtime-artifacts/`；harness-engineer 的 `docs/status/` 映射为 execution-log / tracking 子结构。
3. **路由表扩展，不替换**：在 `routing.md` 增加 Cursor 等价列，而非删除 omx 列。
4. **默认 single-pass**：`CONFIG.yaml` 简化为 `harness-kit/adapters/cursor/orchestration/config.defaults.yaml`；continuous 模式显式 opt-in。
5. **PLATFORM_REQUIREMENTS 降级为「建议清单」**：去掉 HALT 语义，改为 Cursor 可执行的自检项。

### 5.2 OMX 能力 → Cursor（改装后）映射表

| OMX / Codex 概念 | harness-engineer 来源 | harness-kit 改装落点 |
|---|---|---|
| `explore` 角色 | platform-adapters + researcher Q-Agent | `cursor-subagent-routing.mdc` → Task explore readonly |
| `executor` | implementer.md | `.agents/skills/cursor-orchestration/` + implementer 精简版 |
| `architect` / `critic` | planner Phase 1 + reviewer | planning 阶段 Task generalPurpose（只读） |
| `debugger` | debugger.md | routing.md 缺陷路由 + Task generalPurpose |
| `ultrawork` | dispatcher.md WORKTREE+ITR | skill 触发：并行 Task + execution-log |
| `team` 流水线 | dispatcher GROUP 执行 | 同上（无 tmux，Task 批次模拟） |
| keyword 路由 | hook-system.md | 可选 `.cursor/hooks.json` 模板 |
| `.omx/state/` | status-management.md | `.ai-runtime-artifacts/execution-logs/tracking/` |
| 模型能力表 | platform-adapters（弱） | `orchestration/model-routing.yaml`（手写维护） |

### 5.3 routing.md 拟增行（示例）

| 任务类型 | Codex Route | **Cursor 等价 Route** | 产物 |
|---|---|---|---|
| 多 task 编码 / 并行实现 | `omx ultrawork` | `cursor-orchestration:dispatcher-workflow`（Task 并行 ITR） | `.ai-runtime-artifacts/execution-logs/` |
| 缺陷调查 | `omx` debugger | Task explore + systematic-debugging | `.ai-runtime-artifacts/verifications/` |
| 架构决策 | architect / critic / planner | Task 只读 generalPurpose × 2 + decision 产物 | `.ai-runtime-artifacts/decisions/` |

### 5.4 AGENTS.md 拆分策略

当前 `entrypoints/AGENTS.md` 混合 Harness 覆盖层（25 行）+ OMX 全文（368 行）。

**改装建议**：

```
entrypoints/AGENTS.md              → 仅保留 Harness 覆盖层 + 工具中立路由摘要
entrypoints/AGENTS.omx.md          → OMX 专章（omx setup 后可 merge 或引用）
adapters/cursor/CURSOR.md          → Cursor 专章（投影可选，或通过 rule 加载）
```

Cursor 会话：**不**应加载 OMX tmux / spawn_agent / omx question 段落。

---

## 6. 文件级取舍矩阵（从 harness-engineer 拿什么）

| 源文件 | 决策 | 改装要点 |
|---|---|---|
| `SKILL.md` | **抽取** Rule 1–15 | 压缩为 `cursor-subagent-routing.mdc`；去掉 spawn 命令硬编码 |
| `references/platform-adapters.md` | **改编** | 译中 + 并入 adapters/cursor/orchestration/ |
| `agents/dispatcher.md` | **改编** | 路径改为 `.ai-runtime-artifacts/`；中文；Task 示例 |
| `agents/researcher.md` | **改编** | 与 superpowers:brainstorming 边界写清；20 文件规则保留 |
| `agents/planner.md` | **部分抽取** | Phase 2–3 与 writing-plans 二选一或串联 |
| `agents/implementer.md` | **改编** | 工具名改为 Cursor 内置工具 |
| `agents/reviewer.md` | **改编** | 与 verification-before-completion 对齐 |
| `agents/debugger.md` | **改编** | 并入 runbooks 缺陷流 |
| `agents/architect.md` | **保留摘要** | 决策阶段 prompt 模板 |
| `runtime/context-engineering.md` | **改编** | 40% 规则 + 拆分策略 |
| `runtime/status-management.md` | **改编** | 追踪日志迁入 execution-logs/tracking/ |
| `runtime/loop.md` | **不整包** | 仅抽取 Phase 0 init + Phase 5 dispatch 摘要 |
| `runtime/hook-system.md` | **模板化** | 提供可选 hooks.json 示例 |
| `CONFIG.yaml` | **简化** | max_parallel_agents + loop_mode 两字段为主 |
| `PLATFORM_REQUIREMENTS.md` | **降级** | 改为 CURSOR-PRECHECK.md 自检清单 |
| `templates/*` | **对齐** | 与 harness-kit/artifact-templates/ 合并，不 duplicate |
| `tools/*` | **不引入** | Cursor sandbox 足够；避免虚假 router 期望 |
| `MEMORY.md` | **可选** | 与 memory-bank 技能共存时需写优先级 |

---

## 7. 分阶段实施路线图

### Phase 0 — 决策冻结（当前阶段）

- [√] 完成本分析文档
- [√] 团队确认：方案 B（选择性改装 + 分层嫁接）
- [√] 产物目录统一为 `.ai-runtime-artifacts/execution-logs/`（不引入第二套 `docs/status/`）

### Phase 1 — 最小可用 Cursor 编排（MVP，1–2 天）

**目标**：Cursor 上「多 task 并行实现」有明确等价路径，不再误读 OMX 段落。

| 交付物 | 路径 | 状态 |
|---|---|---|
| Cursor 子 Agent 路由 rule | `adapters/cursor/.cursor/rules/cursor-subagent-routing.mdc` | [√] |
| 编排 skill | `adapters/agents/.agents/skills/cursor-orchestration/SKILL.md` | [√] |
| 中文平台适配 | `adapters/cursor/orchestration/platform-adapters.zh.md` | [√] |
| routing.md Cursor 列 | `core/routing.md` | [√] |
| AGENTS.md 拆分草案 | `entrypoints/AGENTS.cursor-overlay.md` | [√] |
| bootstrap 投影更新 | `init/bootstrap.prompt.md` | [√] |
| dispatcher 工作流 | `adapters/cursor/orchestration/dispatcher-workflow.md` | [√] |
| Cursor 适配 README | `adapters/cursor/README.md` | [√] |

**验收**：

1. Cursor 会话首句出现 `「Harness：cursor-orchestration:…」` 或等价声明  
2. 多文件实现任务触发 Task 并行，产出 execution-log  
3. harness-check.sh 通过  
4. 无 omx / spawn_agent / tmux 指令出现在 Cursor rule 中  

### Phase 2 — 角色面与追踪

| 交付物 | 路径 | 状态 |
|---|---|---|
| Leader / Implementer / Reviewer / Debugger | `adapters/cursor/orchestration/agents/*.md` | [√] |
| 追踪 schema | `adapters/cursor/orchestration/tracking/schema.md` | [√] |
| 产物模板 | `artifact-templates/dispatch-track.md`、`handoff.md`、`wu-checklist.md` | [√] |
| runbooks Cursor 分支 | `core/runbooks.md` § Cursor 编排 Runbook | [√] |
| model-routing.yaml | `adapters/cursor/orchestration/model-routing.yaml` | [√] |
| context-budget | `adapters/cursor/orchestration/context-budget.md` | [√] |
| artifacts.md 更新 | `core/artifacts.md` execution-logs/tracking | [√] |

**验收**：中断后可从 tracking 日志恢复；implementer 与 reviewer 非同一会话。 — **已写入规范**

### Phase 3 — 可选增强

| 交付物 | 路径 | 状态 |
|---|---|---|
| hooks.json 示例 | `adapters/cursor/.cursor/hooks.json.example` | [√] |
| hook 脚本 | `adapters/cursor/.cursor/hooks/*.sh` | [√] |
| hooks 说明 | `adapters/cursor/orchestration/hooks/README.md` | [√] |
| continuous loop | `adapters/cursor/orchestration/continuous-loop.md` | [√] |
| AGENTS 拆分 | `entrypoints/AGENTS.md` + `AGENTS.omx.md` | [√] |
| VENDOR 版本钉扎 | `orchestration/VENDOR.md` | [√] |

---

## 8. 风险与缓解

| 风险 | 缓解 |
|---|---|
| 双规范并存导致 AI 混淆 | AGENTS.md 拆分；rule 显式声明优先级 |
| harness-engineer 升级 drift | VENDOR.md + 仅 fork 必要文件，不全量 copy |
| Task 并行导致文件冲突 | dispatcher WORKTREE 强调文件所有权；参考 Rule 8 |
| 中文翻译丢失 nuance | 关键协议保留中英对照术语表（Leader/Worker/ITR） |
| Codex 用户回归 | omx 路径不动；routing.md 双列并存 |
| PLATFORM 检查过严 | 降级为 PRECHECK，不 HALT |

---

## 9. 决策问答（FAQ）

### Q1：能否不改装，只在项目里 `@harness-engineer-5.3.0` 技能？

可以作**个人增强**，但不适合作为 harness-kit 官方 Cursor 适配：  
全局 skill 不可随 `harness-kit/` 迁移；产物与路由与脚手架不一致。

### Q2：harness-engineer 能否替代 omx？

**在 Cursor 上**：编排语义可替代 ultrawork/team 的**大部分**；  
**在 Codex CLI 上**：不能替代 omx hooks、tmux、omx explore 命令与 `.codex/` 生态。

### Q3：最小投入路径是什么？

只做 Phase 1 四项：`cursor-subagent-routing.mdc` + `cursor-orchestration` skill + routing.md 一行 + AGENTS 拆分。  
约可覆盖 **60–70%** 体感差距。

### Q4：与 superpowers 技能链关系？

| 阶段 | 保留 superpowers | 用 harness-engineer 改编 |
|---|---|---|
| 需求澄清 | brainstorming | — |
| 实施计划 | writing-plans | 或 planner 三阶段（二选一，写进 routing） |
| 并行实现 | — | dispatcher-workflow |
| 完成验证 | verification-before-completion | reviewer 五轴审查 |

**推荐串联**：`brainstorming → writing-plans → cursor-orchestration → verification-before-completion`

---

## 10. 最终结论

| 问题 | 答案 |
|---|---|
| 能否直接用 harness-engineer-5.3.0？ | **不建议**作为 harness-kit 的 Cursor 官方路径 |
| 能否用它补齐 Codex 独有能力 gap？ | **能**，约 **70–85%** 编排语义可通过改装达到 |
| 推荐怎么做？ | **方案 B：选择性改装 + 分层嫁接** |
| 优先拿哪些文件？ | `platform-adapters`、`dispatcher`、`implementer`、`reviewer`、`context-engineering`、`status-management`、SKILL Rule 8–14 |
| 下一步 | 执行 Phase 1 MVP（见第 7 节） |

---

## 附录 A：架构示意（推荐态）

```
                    ┌─────────────────────────────────────┐
                    │     harness-kit/core/（规范层）      │
                    │  routing · artifacts · verification │
                    └──────────────┬──────────────────────┘
                                   │
              ┌────────────────────┼────────────────────┐
              ▼                    ▼                    ▼
     ┌────────────────┐  ┌────────────────┐  ┌────────────────┐
     │ Codex / omx    │  │ Cursor 编排层   │  │ Claude/Gemini  │
     │ .codex/        │  │ adapters/cursor│  │ entrypoints    │
     │ omx ultrawork  │  │ Task + skill   │  │ 精简 harness   │
     └────────────────┘  └────────────────┘  └────────────────┘
              │                    │
              └────────┬───────────┘
                       ▼
            .ai-runtime-artifacts/（统一产物）
```

## 附录 B：harness-engineer 版本信息

- **slug**：harness-engineer  
- **version**：5.3.1（`_meta.json`）  
- **路径**：`~/.cursor/skills/harness-engineer-5.3.0/`  
- **分析日期**：2026-05-24  

---

*本文档由 harness-kit 集成探索生成。Phase 1 实施完成后，应在本文件或 `harness-kit/adapters/cursor/README.md` 中更新落地状态。*
