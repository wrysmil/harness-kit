# Dispatcher 工作流（平台无关）

将已批准 plan 转为并行 worker 执行。物理绑定见 `adapters/<platform>/bindings.md`。

**触发：** `core/routing.md` 判定「多 task 编码 / 并行实现」。

---

## 输入

- `.ai-runtime-artifacts/plans/` 已批准 plan，或
- spec `skip:plan(reason)` 且仍属多 task

## 输出

- 代码变更
- `.ai-runtime-artifacts/execution-logs/YYYY-MM-DD-<topic>-execution-log.md`
- 可选：`tracking/DISPATCH-TRACK-<date>.md`

---

## 步骤 0：`WorktreeInit`

**做：** 将委派写代码类 worker（有 `*-dispatch.md` / DISPATCH-TRACK）时，GROUP-1 派发前。

**跳过：** routing 小改动；Leader 主线程直接实现；只读探查不改代码。

权威：`docs/superpowers/specs/2026-05-29-git-worktree-isolation-design.md` §5.4。

1. `worktree_id` = `wt-{dispatch_stem}` → `worktree_path` = `<repo-parent>/.harness-worktrees/<repo-basename>/{worktree_id}/`
2. `git worktree add -b harness/{worktree_id} <worktree_path> <base>`（可复用）
3. tracking 记 `WORKTREE-INIT`；更新 HANDOFF § Git 沙箱

**门禁：** 将委派写代码 WU 时，未完成步骤 0 **不得**派发。

## 步骤 1：执行图

从 plan 提取 WU（有界 / 可验证 / 文件不相交）。写入 `*-dispatch.md`（模板 `dispatch.harness-overlay.md`）：

```markdown
## 执行图

GROUP-1（并行）:
  WU-01: <描述> | 文件: a.ts | 依赖: 无 | wu_type: feature | agent_role: coder | wu_skills: auto
```

`wu_skills: auto` → `core/orchestration/skill-preferences.md` § 默认路由表。

## 步骤 2：`ParallelBatch` / `SpawnWorker`

对 GROUP 内无未完成依赖的 WU，**并行** `SpawnWorker(agent_role, wu)`（文件不相交；≤ `max_parallel`，硬顶 5）。

| agent_role | 说明 |
| --- | --- |
| coder | 实现+单测+轻量审查+自检 |
| implementer | docs/chore/config |
| test-engineer | 测试/E2e 资产 |
| web-investigator | 调研取证 |
| explorer | 只读探查 |

**禁止** Leader 主线程改业务代码（小改动除外）。

**委派 prompt（中文、简练）：**

| 项 | 内容 |
| --- | --- |
| 身份 | `WU-<id>` + `agent_role` / `wu_type` + `agents/<role>.md` |
| 目标/Done | 各 1–3 句 |
| 范围 | 允许文件；禁止项一句 |
| Skills | slug → 路径（禁只写 `auto`） |
| 验证 | 命令 |
| cwd | 沙箱批次：`worktree_path: <abs>` |
| 返回 | `wu_status`、`### Skills 使用`（coder 含 `code_review`/`self_check`） |

Leader 解析 `auto` → 抄 slug+路径入 prompt；无 `### Skills 使用` **不整合**。

**禁传 worker：** `brainstorming`、`writing-plans`、平台编排 skill、`git-xywh`。

## 步骤 3：整合与尾盘

单 WU 返回：验证字段 → Leader 更新 plan/tracking。**不写批次完成态。**

GROUP 收尾（`docs/superpowers/specs/2026-05-28-batch-closeout-review-and-collective-test.md` §4）：

1. **A 集体测试** — Load `verification-before-completion`；cwd=`worktree_path`；Write `*-collective-test.md`；FAIL → STOP
2. **B 集体审查** — Load `requesting-code-review`；`SpawnWorker(reviewer)` **新实例**；Leader Write `*-code-review.md`
3. **C 关闭** — execution-log 链接两产物；APPROVE/SKIPPED + 测试 PASS 方可声称完成

## 步骤 4：追踪

1. 创建 `DISPATCH-TRACK-<date>-<topic>.md`
2. 每 WU append（`tracking/schema.md`）
3. 可选 CHECKLIST；上下文重置写 HANDOFF

## 步骤 5：WORKTREE-CLOSE

曾 INIT 且批次完成、用户确认 Git 后：`git worktree remove`；tracking 记 `WORKTREE-CLOSE`。

---

## 角色索引

见 `roles.md`。平台 SpawnWorker 映射见 `adapters/*/bindings.md`。

## Superpowers 衔接

| 阶段 | Skill |
| --- | --- |
| 设计 | `brainstorming` |
| 计划 | `writing-plans` |
| 实现 | 平台编排 skill（`orchestration.dispatch`） |
| 尾盘测试 | `verification-before-completion` |
| 尾盘审查 | `requesting-code-review` |

## 反模式

- 未读 plan 派发；单 worker 包整个 epic
- 实现与审查同实例；跳过 execution-log / 尾盘产物
- 有委派无 WORKTREE-INIT；无委派仍 INIT
- Leader 自动 push
