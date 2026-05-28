# Cursor Dispatcher 工作流（ultrawork 等价）

将已批准的实施计划转为并行 Task 执行。改编自 harness-engineer `agents/dispatcher.md`。

**触发条件：** `harness-kit/core/routing.md` 判定为「多 task 编码 / 并行实现」，且平台为 Cursor。

---

## 输入

- `.ai-runtime-artifacts/plans/` 中已批准 plan，或
- spec front matter 中 `skip:plan(reason)` 且范围仍属多 task（需说明）

## 输出

- 代码变更
- `.ai-runtime-artifacts/execution-logs/YYYY-MM-DD-<topic>-execution-log.md`
- 可选：`.ai-runtime-artifacts/execution-logs/tracking/DISPATCH-TRACK-<date>.md`

---

## 步骤 1：Worktree 拆分（主 Agent）

从 plan 提取 work unit（WU），每个 WU 须满足：

- **有界**：明确文件列表（通常 ≤5 个写文件）
- **可验证**：有 done criteria（测试、lint 或手工检查点）
- **所有权清晰**：并行 WU 不修改同一文件

产出简易 worktree（写入与 plan 同 stem 的 `*-dispatch.md`，模板 `artifact-templates/dispatch.harness-overlay.md`；亦可摘要到 tracking）：

```markdown
## 执行图

GROUP-1（并行）:
  WU-01: <描述> | 文件: a.ts, b.ts | 依赖: 无 | wu_type: feature | wu_skills: auto
  WU-02: <描述> | 文件: c.ts | 依赖: 无 | wu_type: chore | wu_skills: 无

GROUP-2（依赖 GROUP-1）:
  WU-03: <描述> | 文件: d.ts | 依赖: WU-01 接口 | wu_type: bugfix | wu_skills: auto
  WU-04: API 集成测试 | 文件: tests/api/*.ts | 依赖: WU-01 | wu_type: test | wu_skills: auto
```

`wu_skills: auto` → 查 **`orchestration/skill-preferences.zh.md`** § 默认路由表。也可手写 slug 覆盖。

## 步骤 2：并行派发（Subagent）

对当前 GROUP 内无未完成依赖的 WU，**并行**委派 `.cursor/agents/` 中的 subagent：

| WU 类型 | Subagent | 说明 |
| --- | --- | --- |
| 只读探查 | `harness-explorer` 或 Task `explore` | readonly |
| 代码实现（feature/bugfix/refactor/ui/review-fix） | **`harness-coder`** | 实现+单测+轻量审查+自检；见 `agents/coder.md` |
| 轻量（docs/chore/config） | **`harness-implementer`** | 见 `agents/implementer.md` |
| 测试 / E2E | **`harness-test-engineer`** | 只改测试资产；见 `agents/test-engineer.md` |
| 信息调研 / 网页搜索 | **`harness-web-investigator`** | 搜索、浏览、截图取证 |
| 单次构建命令 | Task `shell` | 无测试设计时使用 |

**禁止** Leader 在主线程直接修改业务代码（routing「小改动」除外）。

**每个委派 prompt 必须包含：**

0. **语言：** prompt 正文与要求返回的 prose 使用**中文**（路径、命令、固定段键名除外；见 `core/routing.md` § 沟通语言）
1. WU 目标与 done criteria
2. 允许修改的文件列表
3. 禁止事项（不改哪些文件、不新增依赖等）
4. **本 WU Skills**：Leader 解析 `auto` 后**抄 SKILL 路径**（派发 prompt 禁只写 `auto`）；纯 chore 写 `无`。含 `agent_role` + `wu_type`
5. 必须返回：变更摘要、**`wu_status`**、**Skills 使用**、阻塞项
6. **Coder** 还须：`self_check`、`code_review`、测试资产摘要
7. **子 Agent 不改 plan**；Leader 验证后写 plan / tracking（`runtime/plan-progress-sync.md`）

Coder 派发 prompt 模板：`docs/superpowers/specs/2026-05-26-coder-role-design.md` § 提示词规范，或 `agents/coder.md` § Task Prompt 前缀。

### Leader 为 WU 选配 Skills

1. plan 可写 `wu_skills: auto`；派发前 Read **`skill-preferences.zh.md`**，将 **slug + SKILL 路径** 抄入 prompt
2. 子 Agent 无 `### Skills 使用` → Leader **不整合**
3. 能力副本：`.cursor/skills/`；升级：`bash harness-kit/scripts/sync-cursor-skills.sh`

**不要**传给子 Agent：`brainstorming`、`writing-plans`、`cursor-orchestration`、`git-xywh`。

## 步骤 3：整合与尾盘门禁

**单 WU 返回后：** 验证返回字段 → plan / tracking 由 Leader 更新（`plan-progress-sync.md`）。**不在此写批次完成态。**

**GROUP 收尾（先测后审，Leader 落盘）：** 细则 `docs/superpowers/specs/2026-05-28-batch-closeout-review-and-collective-test.md` §4。

1. 收集 WU 结果；处理冲突
2. **步骤 A — 集体测试**
   - Leader Load `verification-before-completion` + `project.verification.md`
   - 按本批次 diff 跑最小验证集；plan 要集成/E2E 时先完成 `harness-test-engineer` WU
   - **Write** `.ai-runtime-artifacts/verifications/YYYY-MM-DD-<topic>-collective-test.md`（模板 `artifact-templates/collective-test.md`）
   - 任一必跑项 **FAIL** → STOP，开 bugfix WU；**不得**进入步骤 B
3. **步骤 B — 集体代码审查**
   - Leader Load `requesting-code-review`；委派 **`harness-reviewer`**（与所有 Coder/Implementer **不同实例**；禁无约束 `generalPurpose`）
   - Reviewer **只返回**（readonly，不 Write）；`code_review: PASS` **不替代**本步
   - Leader 将返回 **Write** `.ai-runtime-artifacts/reviews/YYYY-MM-DD-<topic>-code-review.md`（模板 `artifact-templates/code-review.md`）
   - 可跳过条件：`docs/superpowers/specs/2026-05-26-coder-role-design.md` § 小 WU 跳过 Reviewer → `verdict: SKIPPED` + 依据写入 review 产物
4. **步骤 C — 批次关闭**
   - 更新 execution-log § 尾盘门禁（链接上述两产物路径）
   - `BLOCK` → `review-fix` WU → 回到步骤 A（至少重跑受影响验证）
   - `APPROVE` 或合法 `SKIPPED` 且集体测试 PASS → 方可声称 GROUP 交付完成
5. 未过步骤 A+B（及 C 落盘）**不得**声称 GROUP 交付完成

## 步骤 4：追踪（并行编排时**必须**）

1. 从 `artifact-templates/dispatch-track.md` 创建 `tracking/DISPATCH-TRACK-<date>-<topic>.md`
2. 每 WU 派发/完成时 **append** 条目（格式见 `tracking/schema.md`）
3. 每 WU 可选 `CHECKLIST-<topic>-WU-<id>.md`（模板 `artifact-templates/wu-checklist.md`）
4. 上下文重置时覆盖写 `execution-logs/HANDOFF.md`（模板 `artifact-templates/handoff.md`）

中断恢复：见 `tracking/schema.md` § 中断恢复协议。

---

## Agent 面索引

| 角色 | 文件 | Cursor 机制 |
| --- | --- | --- |
| Leader | `agents/leader.md` | 主 Agent |
| Coder | `agents/coder.md` | `.cursor/agents/harness-coder.md` |
| Implementer | `agents/implementer.md` | `.cursor/agents/harness-implementer.md` |
| Reviewer | `agents/reviewer.md` | `.cursor/agents/harness-reviewer.md` |
| Debugger | `agents/debugger.md` | `.cursor/agents/harness-debugger.md` |
| Test engineer | `agents/test-engineer.md` | `.cursor/agents/harness-test-engineer.md` |
| Web investigator | `agents/web-investigator.md` | `.cursor/agents/harness-web-investigator.md` |

上下文纪律：`context-budget.md`。模型建议：`model-routing.yaml`。

---

## 与 superpowers 的衔接

| 阶段 | Skill |
| --- | --- |
| 需求 / 设计 | `superpowers:brainstorming` |
| 计划 | `superpowers:writing-plans` |
| **本工作流** | `cursor-orchestration` |
| 尾盘集体测试 | `superpowers:verification-before-completion` |
| 尾盘集体审查 | `requesting-code-review` |
| 单点验证（非尾盘） | `superpowers:verification-before-completion` |

---

## 反模式

- 未读 plan 直接开 Task
- 一个 Task 包整个 epic（范围过大 → 超时/ killed）
- 实现与审查同一 Task
- 跳过 execution-log 声称完成
- 末个 WU 返回后直接「批次 / GROUP 完成」（须先尾盘 A 集体测试 + B 集体审查）
- 跳过集体测试或未 Write `*-collective-test.md` 即进入审查或声称完成
- 仅以 Coder `code_review: PASS` 替代尾盘 `harness-reviewer` 集体审查
- 未 Write `*-code-review.md` 即在 execution-log 写批次交付完成
- Reviewer 会话内 Write `.ai-runtime-artifacts/`（应由 Leader 落盘）
