---
name: cursor-orchestration
description: Cursor 多 subagent 并行编排，等价于 omx ultrawork。在用户已批准 plan 并说「开始实现」后，通过 harness-implementer 并行派发 WU。触发词：并行实现、多 task、开始实现、cursor 编排、dispatcher。
---

# Cursor Orchestration

Cursor 平台的 **omx ultrawork 语义等价** skill。通过 `.cursor/agents/harness-implementer` 并行派发有界 work unit（WU）。

**前置：** 用户已批准 plan（说过「开始实现」或等价指令）。未批准前**不得**激活本 skill。

**平台：** 仅 Cursor。Codex 走 `omx ultrawork`（见 `harness-kit/core/routing.md`）。

---

## 何时使用

- 路由判定为「多 task 编码 / 并行实现」
- 已有 `.ai-runtime-artifacts/plans/` 中**已批准** plan，或 spec 中合法 `skip:plan` 且用户已说「直接实现」
- **不要用：** 单文件小改动、未过 plan 门禁、Codex 环境

---

## 执行前读取（按序）

1. `harness-kit/adapters/cursor/orchestration/dispatcher-workflow.md` — **唯一完整步骤**
2. `harness-kit/adapters/cursor/orchestration/runtime/plan-progress-sync.md` — plan 内 `- [ ]`→`- [√]`，禁止仅在回复里勾选
3. `harness-kit/adapters/cursor/orchestration/tracking/schema.md`
4. 已批准 plan + `harness-kit/project.verification.md`

---

## 激活后

声明 `「Harness：cursor-orchestration:dispatcher-workflow」`，然后**按序读完** `dispatcher-workflow.md` 再派发 WU。未读 dispatcher 不得并行 implementer。

---

## 禁止

- 未过 plan 门禁开始实现
- 主 Agent 直接改业务代码（非小改动）
- 实现与审查同一 subagent 实例
- `omx` CLI；无 tracking 的并行 WU；无 execution-log 完成声明
- 仅在聊天回复里输出 `[√]` 而不改 plan / CHECKLIST 文件
