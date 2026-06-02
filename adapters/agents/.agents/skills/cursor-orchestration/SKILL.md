---
name: cursor-orchestration
description: Cursor 多 subagent 并行编排，等价于 omx ultrawork。在用户已批准 plan 并说「开始实现」后，通过 harness-coder（代码）、harness-implementer（轻量）、harness-test-engineer、harness-web-investigator（research）等并行派发 WU。触发词：并行实现、多 task、开始实现、cursor 编排、dispatcher。
---

# Cursor Orchestration

Cursor 平台的 **omx ultrawork 语义等价** skill。代码类 WU 委派 `harness-coder`；轻量 WU 委派 `harness-implementer`。

**前置：** 用户已批准 plan（说过「开始实现」或等价指令）。未批准前**不得**激活本 skill。

**平台：** 仅 Cursor。Codex 走 `omx ultrawork`（见 `harness-kit/core/routing.md`）。

---

## 何时使用

- 路由判定为「多 task 编码 / 并行实现」
- 已有 `.ai-runtime-artifacts/plans/` 中**已批准** plan，或 spec 中合法 `skip:plan` 且用户已说「直接实现」
- **不要用：** 单文件小改动、Leader 直接实现且不派子 Agent、未过 plan 门禁、Codex 环境

---

## 执行前读取（按序）

1. `harness-kit/adapters/cursor/orchestration/dispatcher-workflow.md` — **唯一完整步骤**
2. `plan-progress-sync.md` — **Leader** 写 plan/tracking；子 Agent 返回 `wu_status`
3. `harness-kit/adapters/cursor/orchestration/tracking/schema.md`
4. 已批准 plan + `harness-kit/project.verification.md`

---

## 激活后

声明 `「Harness：cursor-orchestration:dispatcher-workflow」`，读完 `dispatcher-workflow.md`。将委派 harness-* 时：**§0 WORKTREE-INIT** → 派发 WU（prompt 简练，沙箱批次含 `worktree_path`）。不派子 Agent 则勿激活本 skill，走 routing「小改动」或主线程直接实现。

派发子 Agent 时须含 **「本 WU Skills」**（推荐 `auto`）、`agent_role`、`wu_type`。偏好表：`harness-kit/adapters/cursor/orchestration/skill-preferences.zh.md`。代码 WU → `harness-coder`；测试 WU → `harness-test-engineer`。

**GROUP 全部 WU 返回后：** 进入 **尾盘**（先集体测试 → 再集体审查 → Leader 落盘两产物 → 更新 execution-log）。见 `dispatcher-workflow.md` § 步骤 3 与 `docs/superpowers/specs/2026-05-28-batch-closeout-review-and-collective-test.md`。

---

## 禁止

- 未过 plan 门禁开始实现
- 主 Agent 直接改业务代码（非小改动）
- 实现与审查同一 subagent 实例
- `omx` CLI；无 tracking 的并行 WU；无 execution-log 完成声明
- 仅在聊天回复里输出 `[√]` 而不改 plan / CHECKLIST 文件
- 末个 WU 完成即停（须尾盘 collective-test + code-review 落盘）
- 跳过集体测试或未 Write `*-collective-test.md` 即派集体审查或声称 GROUP 完成
- 未 Write `*-code-review.md` 即在 execution-log 声称批次交付完成
- 无子 Agent 委派仍 WORKTREE-INIT；有委派却跳过 INIT 或在主 checkout 改业务代码；Leader 自动 push
