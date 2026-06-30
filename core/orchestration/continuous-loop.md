# Continuous Loop（Cursor，Opt-in）

长期自治工程循环的 **可选** 模式。默认使用 `config.defaults.yaml` 中的 `loop_mode: single-pass`。

改编自 harness-engineer `runtime/loop.md` 摘要，并映射到 harness-kit 产物目录。

---

## 模式对比

| loop_mode | 含义 | 适用 |
| --- | --- | --- |
| `single-pass` | 单会话完成一个可交付单元 | **默认**；日常功能开发 |
| `maintenance` | 仅 bugfix / 安全 / 依赖 | 无新 feature 阶段 |
| `continuous` | 多周期自治循环 | 需人工监督 + 明确 opt-in |

在 `.harness/settings.local.json` 或项目约定中覆盖（Phase 3 可选目录）：

```json
{
  "runtime": {
    "loop_mode": "single-pass",
    "max_parallel_agents": 3
  }
}
```

**禁止**在未 sandbox 验证前将 `continuous` 设为默认。

---

## single-pass 标准路径（Cursor）

与 `harness-kit/core/runbooks.md` § Cursor 编排 Runbook 一致：

```text
brainstorming → writing-plans → orchestration → verification-before-completion
```

每步产物写入 `.ai-runtime-artifacts/`。并行编排维护 `execution-logs/tracking/`。

---

## continuous 循环摘要（opt-in）

每个 **cycle** 顺序执行（跨多会话，用 HANDOFF 链接）：

| 阶段 | Cursor 映射 | 产物 |
| --- | --- | --- |
| 0 初始化 | Leader 读 routing + PROGRESS | `execution-logs/PROGRESS.md`（可选） |
| 1 需求/设计 | Load **brainstorming** → spec（勿仅用 Task explore 代替） | `specs/` 或 research 摘要 |
| 2 计划 | writing-plans | `plans/` |
| 3 实现 | orchestration | `execution-logs/` + 代码 |
| 4 验证 | verification + reviewer Task | `verifications/` |
| 5 反思 | Leader 摘要 | `retros/` |

### 与 harness-engineer 全量 loop 的差异

| harness-engineer | harness-kit Cursor 版 |
| --- | --- |
| Phase 0 HALT 平台检查 | `CURSOR-PRECHECK.md`（非阻塞） |
| `docs/status/*` | `.ai-runtime-artifacts/execution-logs/tracking/` |
| 7+ 阶段自治 | 简化为 5 阶段 + superpowers 链 |
| 内置 MCP router | Cursor sandbox + 项目规则 |

---

## 跨会话恢复

1. 写 `execution-logs/HANDOFF.md`（模板 `artifact-templates/handoff.md`）
2. 写 `tracking/DISPATCH-TRACK-*.md` 最后状态
3. 新会话：Leader 读 HANDOFF + track → 从 `Next` 继续

---

## 启用 continuous 前检查清单

- [ ] 至少完成 2 次 clean single-pass cycle
- [ ] `feature` 分支工作，main 受保护
- [ ] tracking + handoff 模板已使用熟练
- [ ] 人工门禁：plan 批准、PR 审查（无 auto-merge）
- [ ] 可选：启用 `hooks.json` 辅助 subagentStop 提醒

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
- continuous 模式下跳过 verification
- 同一 Task 既实现又审查
