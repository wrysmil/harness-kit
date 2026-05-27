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

## 步骤 3：整合与门禁

**单 WU 返回后：** 验证 → plan / tracking 由 Leader 更新（`plan-progress-sync.md`）。

**GROUP 收尾：**

1. 收集 WU 结果；处理冲突
2. 跑 `project.verification.md`；plan 要集成/E2E 时先完成 `harness-test-engineer` WU
3. **审查门禁**：委派 `harness-reviewer` 审**本批次整合面**（与任一实现 Coder **不同实例**）；`code_review: PASS` 不替代本步。可跳过条件见 `docs/superpowers/specs/2026-05-26-coder-role-design.md` § 小 WU 跳过 Reviewer
4. `BLOCK` → `review-fix` WU 派 Coder；`APPROVE` 或合法跳过 → execution-log（跳过记理由）
5. 未过步骤 3 不得声称 GROUP 交付完成

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
| 完成前验证 | `superpowers:verification-before-completion` |

---

## 反模式

- 未读 plan 直接开 Task
- 一个 Task 包整个 epic（范围过大 → 超时/ killed）
- 实现与审查同一 Task
- 跳过 execution-log 声称完成
