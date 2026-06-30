# Continuous Loop（Claude Code，HANDOFF 驱动）

长期自治工程循环的 **可选** 模式。Claude Code 平台**没有**原生 continuous loop，所以用 **HANDOFF + DISPATCH-TRACK** 串联多会话。

与 Cursor 版（`continuous-loop.md`）的关系：**并行存在**——同目标、不同物理实现。Cursor 走 `continuous_mode` 配置；Claude 走「写 HANDOFF → 新会话读 HANDOFF + DISPATCH-TRACK 续跑」。

---

## 物理能力诚实声明（2026-06-11）

Claude 平台的「leader + sub-agent 编排」是 **Leader 流程 + 钩子提示 + 文件契约** 的组合，**不存在** 调度器/状态机/自动触发器。

| 维度 | Cursor | Claude Code |
| --- | --- | --- |
| 平台自动注入规则 | ✅ `.cursor/rules/*.mdc` 标 `alwaysApply: true` → **整本** rules 自动拼进 system context | ⚠️ 仅根 `CLAUDE.md` 自动读；其它 `.md` **不**自动注入 |
| 钩子能注入上下文 | 较有限 | ✅ `SessionStart` 用 `additionalContext` 字段可注入任意 markdown（但有 token 上限） |
| 实际注入量 | rules 多文件几十~几百行全在 | `harness-session-init` 注入「最关键规则摘要」（见 `core/extensions/hooks/content/session-init.md`），当前约 20+ 行 |
| 钩子硬阻断 | 较有限 | ✅ `PreToolUse` + `permissionDecision: "deny"` |
| subagent readonly 强制 | prompt 级 | prompt 级（subagent 仍能用 Write 工具） |
| 连续性 | 会话内 `continuous_mode` 可用 | **跨会话**，必须靠 HANDOFF 文件接力——**人工**触发，不是 agent 续命 |

**关键后果：**

- Leader 在 Claude Code 会话里看到的**只是 3 行路由提示 + 极简 `CLAUDE.md` 入口**；整本 `core/orchestration/*` 文档要 Leader **主动 Read**
- 任何"完成 ≠ 末个 WU 返回"、"未生成产物不能声称完成"、"WORKTREE-CLOSE" 等规范文本，**都是 Leader 自律，不是平台门禁**
- `collective-test` / `code-review` 产物**不会**在 WU 返回时自动生成——Leader 必须手动走 A 集体测试 → B 集体审查 → C 关闭
- `claude-continuous` loop 里的"下一周期"完全靠**人工**新开会话并读 HANDOFF，不是 agent 自己续命

下游项目若以 Claude Code 为目标平台，应**不要**把 harness 文档当作"平台会强制遵循的规则"理解；它是"Leader 自觉遵循的纪律"。需要硬门禁的功能（如阻断 EnterPlanMode）必须额外用 `block-native-plan-mode` 等 `PreToolUse` 钩子实现。

---

## 模式对比

| loop_mode | 含义 | 适用 |
| --- | --- | --- |
| `single-pass` | 单会话完成一个可交付单元 | **默认**；日常功能开发 |
| `maintenance` | 仅 bugfix / 安全 / 依赖 | 无新 feature 阶段 |
| `continuous` | 多周期自治循环 | 需人工监督 + 明确 opt-in |

Claude 配置示例（`.harness/settings.local.json` 或项目约定）：

```json
{
  "runtime": {
    "loop_mode": "continuous",
    "max_parallel_agents": 3,
    "handoff_anchor": ".ai-runtime-artifacts/execution-logs/HANDOFF.md"
  }
}
```

**禁止**在未 sandbox 验证前将 `continuous` 设为默认。

---

## Claude 与 Cursor 的关键差异

| 维度 | Cursor | Claude Code |
| --- | --- | --- |
| 物理连续性 | 同一会话内 `continuous_mode` | **跨会话**，需 HANDOFF 文件接力 |
| 任务暂停/恢复 | 后台 Task 轮询 | 新开会话，Leader 重读 HANDOFF + TRACK |
| 状态持久化 | 内存 + `.cursor/` 配置 | 全部落盘到 `.ai-runtime-artifacts/` |
| 周期边界 | session 内「下一步」 | 显式写 `HANDOFF.md`（人类或 Leader 触发） |
| 视觉差异 | Cursor UI 显示 | 仅文件系统 + 新会话 prompt 引用 |

---

## 周期阶段（Claude）

每个 **cycle** 跨**多次会话**，每会话对应一个可交付子集：

| 阶段 | Leader 动作 | 产物 |
| --- | --- | --- |
| 0 初始化 | 新会话首句：读 `HANDOFF.md` + `DISPATCH-TRACK-*.md` 末段 | 状态恢复 |
| 1 需求/设计 | Load **`brainstorming`** → spec | `specs/` |
| 2 计划 | Load **`writing-plans`** | `plans/` |
| 3 实现 | Load **`orchestration`** → dispatcher | `execution-logs/` + 代码 |
| 4 验证 | Load **`verification-before-completion`** → reviewer Task | `verifications/` + `reviews/` |
| 5 反思 | Leader 摘要 | `retros/` |
| **6 接力（HANDOFF）** | Leader 写 `HANDOFF.md` 末段 `## Next` + 更新 `PROGRESS.md` | `HANDOFF.md` + `PROGRESS.md` |
| 7 收工 | 关闭当前会话 | — |
| 8 续跑（下次会话） | 步骤 0 | — |

> 与 Cursor 版（`continuous-loop.md`）的 5 阶段相比，Claude 增加 6/7 显式写盘 + 8 显式恢复。

---

## HANDOFF 协议

**写时机：**

- 本 cycle 所有 WU 返回后、集体测试 PASS 前，**不**写 HANDOFF（避免半成品接力）
- 集体测试 + 集体审查都通过、execution-log 关闭后 → **必须**写 HANDOFF
- 用户明确说「暂停」「明天继续」 → 立即写 HANDOFF（不待批次结束）
- 上下文预算 >80%（见 `core/orchestration/context-budget.md`）→ 主动写 HANDOFF

**写什么（按 `artifact-templates/handoff.md` 模板）：**

| 段 | 内容 |
| --- | --- |
| 周期 ID | `cycle-<N>-<topic>` |
| 阶段 | spec / plan / dispatch / verify / done / pause |
| 当前 GROUP / WU 状态 | 链接到 `DISPATCH-TRACK-*.md` 末行 |
| 阻塞 | 文件路径 + 原因 + 解锁条件 |
| 已批准但未执行的 plan | plan 路径 + 状态 |
| `## Next` | 下次会话首动作（3–5 步，可执行） |
| 入口 | 「新会话首句：读 HANDOFF + DISPATCH-TRACK → 接续 `## Next`」 |

**DISPATCH-TRACK 协同：**

- HANDOFF 不复制 plan 全文，只**链接**到 `DISPATCH-TRACK-*.md` 末行
- 计划勾选、WU 状态变更**全部** append-only 写到 TRACK（单一真相源）
- HANDOFF 是给**人**看的导航；TRACK 是给**机器**执行的状态

---

## 续跑流程

新会话首句建议：

```text
Harness：continuous-loop (claude) — 接续 HANDOFF
读：.ai-runtime-artifacts/execution-logs/HANDOFF.md
读：.ai-runtime-artifacts/execution-logs/tracking/DISPATCH-TRACK-<date>-<topic>.md
按 HANDOFF `## Next` 继续
```

Leader 动作：

1. 读 `HANDOFF.md` → 取周期 ID、阶段、`## Next`
2. 读 `DISPATCH-TRACK-*.md` 末段 → 确认 WU 实际状态
3. 读 `execution-log` 末段 → 确认尾盘门禁状态
4. 比对：HANDOFF 描述 vs TRACK 实际 → 不一致先与用户对账
5. 按 `## Next` 执行第一步；执行完**append**到 TRACK，**不**改 HANDOFF
6. 完成本 cycle 全部步骤后 → 回到「HANDOFF 协议」写下一轮

---

## 启用 continuous 前检查清单

- [ ] 至少完成 2 次 clean single-pass cycle
- [ ] `feature` 分支工作，main 受保护
- [ ] `handoff.md` + `progress.md` 模板已使用熟练
- [ ] 人工门禁：plan 批准、PR 审查（无 auto-merge）
- [ ] 可选：`.claude/settings.json` 启用 hooks 辅助 `SubagentStop` 提醒
- [ ] 可选：启用 `block-native-plan-mode` 钩子（避免 plan 写到 `~/.claude/plans/`）

---

##  graduation 路径

```text
single-pass  →  maintenance  →  continuous
     ↑              ↑                  ↑
   默认         无新 feature        显式 opt-in + 人工监督
```

---

## 禁止

- 未 opt-in 默认 continuous
- continuous 模式下跳过 verification / collective-review
- 同一 Task 既实现又审查
- 写 HANDOFF 不 append TRACK（或反之）
- 跨会话「凭印象」继续，不读 HANDOFF / TRACK
- HANDOFF `## Next` 留空或写「按需继续」（不可执行）
