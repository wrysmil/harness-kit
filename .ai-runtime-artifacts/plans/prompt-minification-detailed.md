# Harness-Kit 提示词精简详细对比报告

> 分支: `feat/prompt-minification`
> 分析日期: 2026-08-31

---

## 一、routing.md 精简分析

**文件**: `core/routing.md`
**原始行数**: 320 行
**精简后预估**: 180 行
**精简比例**: ~44%

### 精简点 1：平台原生 plan 工具段落（原 27 行 → 精简 15 行）

**原文 (L22-43):**
```markdown
## 平台原生 plan 工具（禁止使用）

**Claude Code 的 `EnterPlanMode` / `ExitPlanMode`、Cursor 的 Plan 模式** 等**平台原生 plan 工具**会把 plan 写到平台私有目录（`~/.claude/plans/`、Cursor 内部），**完全绕过** Harness 的 stage skill 流程、`plan.harness-overlay.md` 契约与 `.ai-runtime-artifacts/plans/` 落盘规则。一旦走原生工具，本会话**无法**做 plan 门禁拦截、executor 不会把 plan 当 Harness 产物、用户也看不到完整 plan body。

**规则：**

| 任务 | 走 Harness | 禁止 |
| --- | --- | --- |
| 写实施计划 | Load `writing-plans` skill → `artifact-templates/plan.harness-overlay.md` → Write `.ai-runtime-artifacts/plans/YYYY-MM-DD-<topic>-plan.md` | Claude Code `EnterPlanMode` / `ExitPlanMode`、Cursor Plan 模式 |
| 写方案 | Load `brainstorming` skill → `artifact-templates/spec.harness-overlay.md` → Write `.ai-runtime-artifacts/specs/...` | 平台原生 plan/spec 工具 |

**为什么用平台原生工具是 bug：**

1. 产物落到 `~/.claude/plans/` 或 Cursor 内部，**不进 git**、不进 `.ai-runtime-artifacts/` FM 元数据、不被 `harness-check.sh` 扫描、不进 review/verification 链
2. 用户批准时只看到 plan body，**看不到 FM/evidence 段**；与「计划门禁」语义脱节
3. 同名 `plans/` 在两套目录分裂，后续 `harness-kit check` / `git log` / `requesting-code-review` 全部漏抓

**根因与修复（用户在会话中触发时）：**

- 若 agent 已走原生工具 → 立刻 `cat ~/.claude/plans/<name>.md >> .ai-runtime-artifacts/plans/YYYY-MM-DD-<topic>-plan.md`、补 Harness FM（`route: superpowers:writing-plans`、`skills_evidence`、`## Next`），然后从原 native 路径继续；不要把 plan 留在 `~/.claude/plans/`
- 项目级 opt-in 强阻断：见 `core/extensions/hooks/` 下 `PreToolUse` 钩子（默认未启用；启用见 hooks README）
```

**精简后:**
```markdown
## 平台原生 plan 工具（禁止使用）

**Claude Code `EnterPlanMode` / Cursor Plan 模式**会将 plan 写入平台私有目录，绕过 Harness 的 stage skill 流程、门禁拦截与产物落盘规则。

| 任务 | 走 Harness | 禁止 |
| --- | --- | --- |
| 写实施计划 | Load `writing-plans` skill → Write `.ai-runtime-artifacts/plans/` | 原生 plan 工具 |
| 写方案 | Load `brainstorming` skill → Write `.ai-runtime-artifacts/specs/` | 原生 spec 工具 |

**已触发时的修复**: `cat ~/.claude/plans/<name>.md >> .ai-runtime-artifacts/plans/` + 补 Harness FM。详见 `core/extensions/hooks/` 的 PreToolUse 钩子。
```

**精简原因:**
1. **冗余解释删除**: "完全绕过"、"本会话无法"等显而易见的后果无需赘述
2. **路径简化**: `artifact-templates/plan.harness-overlay.md` 等中间路径在表头已说明，表格行内无需重复
3. **"为什么是 bug"并入修复**: 原 3 条 bug 说明本质是"产物路径错误"，用修复动作一句带过
4. **合并修复步骤**: 原 2 段修复步骤都是"迁移产物+补 FM"，合并为一个简洁动作

---

### 精简点 2：路由表合并（原有多个表格 → 精简为索引式）

**原文 (L112-137):** 25 行表格，每行都有详细的 Cursor/Claude 绑定说明

**精简后:**
```markdown
## 路由表（详见 `core/orchestration/dispatcher-workflow.md` 附录 A）

| 任务类型 | Route | 产物 |
| --- | --- | --- |
| 需求澄清 | `interview-me` | `.ai-runtime-artifacts/specs/*-intent.md` |
| 方案设计 | `source-driven-development` + `brainstorming` | `specs/` + `stack/` |
| 实施计划 | `writing-plans` | `plans/` |
| 多 task 编码 | `orchestration` | `execution-logs/` |
| 验证 | `verification-before-completion` | `verifications/` |
| 尾盘审查 | `requesting-code-review` + `code-review-and-quality` | `reviews/` |
| 缺陷调查 | `systematic-debugging` | `specs/` 或 `verifications/` |
| 信息调研 | `web-investigator` | `research/` |
| Ship Gate | `shipping-and-launch` | `ship-check.md` |
| 小改动 | — | 无 FM（回复含验证） |

> 完整平台绑定见各适配器 `bindings.md`。
```

**精简原因:**
1. **平台绑定外置**: Cursor/Claude 平台差异在 `bindings.md` 中详述，路由表只保留核心 Route 信息
2. **列精简**: 原表有 4 列（任务类型、Capability、Cursor、Claude、产物），精简为 3 列
3. **避免重复**: Capability 列与 skills 路由高度重叠，产物列已覆盖关键信息

---

### 精简点 3：按判定加载表格压缩（原 22 行 → 精简 12 行）

**原文 (L138-163):** 详细列出每个判定的加载顺序

**精简后:**
```markdown
## 按判定加载

| 判定 | 必读 |
| --- | --- |
| 小改动/Tier 0 | 无 stage skill |
| Leader 直做/Tier 1 | `source-driven-development` Step 0 → `verification-before-completion` |
| 方案设计 | `source-driven-development` + `brainstorming` + `artifacts.md` |
| 实施计划 | `writing-plans` + `artifacts.md` + `plan.harness-overlay.md` |
| 多 task 编码 | `orchestration` + `dispatcher-workflow.md` |
| 验证/尾盘 | `verification-before-completion` + `requesting-code-review` |
| 缺陷调查 | `systematic-debugging` + `source-driven-development` |
| Ship Gate | `shipping-and-launch` + 全量 references |

> 禁止在未判定 route 前预读 dispatcher-workflow.md 或全套 project.* 文件。
```

**精简原因:**
1. **加载顺序简化**: 原表格详细列出 6 个步骤，精简为"判定 → 必读"两列
2. **重复内容删除**: "① Load → ② artifact → ③ Write"等模式重复出现多次
3. **通用路径提取**: 多个判定都有 `artifacts.md`，在表头统一说明即可

---

### 精简点 4：干预语句精简（原 10 行 → 精简 4 行）

**原文 (L248-251):**
```markdown
- **未声明时的用户干预：** 首句无 `「Harness：…」` → 发送：`请先读取 CLAUDE.md 和 harness-kit/core/routing.md，按 harness 规范重新处理我的上一个请求。`
- **跳过门禁时的干预：** `你跳过了阶段门禁。我只要求写方案/计划，不要改代码。写入 .ai-runtime-artifacts/ 后暂停等我确认。`
- **跳过文档扫描时的干预：** `你没有先扫描 .ai-runtime-artifacts/ 中的相关产物就开始写代码。请先 Load source-driven-development skill → 执行 Step 0（扫描项目文档）→ 找到并阅读相关 specs/plans/decisions，然后再开始实现。`
- **走平台原生 plan 工具时的干预：** `你用了 Claude Code EnterPlanMode / Cursor Plan 模式，绕过了 Harness。撤回该 plan，Load writing-plans skill 重新写 .ai-runtime-artifacts/plans/YYYY-MM-DD-<topic>-plan.md（FM + Next + dispatch）。`
```

**精简后:**
```markdown
## 干预语句

| 场景 | 干预 |
| --- | --- |
| 未声明 Harness | 请先读取 CLAUDE.md 和 routing.md |
| 跳过门禁 | 只要求写方案/计划，写入 .ai-runtime-artifacts/ 后暂停 |
| 跳过文档扫描 | 请先 Load source-driven-development → Step 0 扫描项目文档 |
| 走原生 plan 工具 | 撤回，Load writing-plans skill 重新写入 .ai-runtime-artifacts/plans/ |
```

**精简原因:**
1. **表格化**: 原 4 条长语句改为表格，场景和干预一一对应
2. **路径精简**: 完整的文件路径在干预时不需要重复说明，用户已知道项目结构
3. **动作优先**: 干预本质是"说什么"，精简为"做什么"

---

### routing.md 精简汇总

| 段落 | 原行数 | 精简后 | 节省 |
| --- | --- | --- | --- |
| 平台原生工具说明 | 27 | 12 | 15 |
| 路由表 | 25 | 14 | 11 |
| 按判定加载 | 22 | 12 | 10 |
| 干预语句 | 10 | 4 | 6 |
| 其他冗余描述 | ~20 | ~10 | 10 |
| **总计** | **320** | **~180** | **~140 (44%)** |

---

## 二、verification-before-completion 精简分析

**文件**: `.agents/skills/verification-before-completion/SKILL.md`
**原始行数**: 185 行
**精简后预估**: 120 行
**精简比例**: ~35%

### 精简点 1：Rationalization Prevention 表格精简（原 15 行 → 精简 8 行）

**原文 (L100-113):**
```markdown
## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "Should work now" | RUN the verification |
| "I'm confident" | Confidence ≠ evidence |
| "Just this once" | No exceptions |
| "Linter passed" | Linter ≠ compiler |
| "Agent said success" | Verify independently |
| "I'm tired" | Exhaustion ≠ excuse |
| "Partial check is enough" | Partial proves nothing |
| "Different words so rule doesn't apply" | Spirit over letter |
| "Tests after achieve same goals" | Git log must prove test-first. Tests-after = implementation bias. |
| "Already spent X hours, deleting is wasteful" | Sunk cost. Unverified code is technical debt. |
```

**精简后:**
```markdown
## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "Should work now" / "I'm confident" | RUN the verification; confidence ≠ evidence |
| "Just this once" / "Partial check is enough" | No exceptions; partial proves nothing |
| "Linter passed" / "Agent said success" | Linter ≠ compiler; verify independently |
| "Tests after achieve same goals" | Git log must prove test-first |
| "Already spent X hours, deleting is wasteful" | Sunk cost; unverified code is technical debt |
```

**精简原因:**
1. **相似借口合并**: "Should work now" 和 "I'm confident" 本质相同，合并为一行
2. **等效表达合并**: "Just this once" 和 "Partial check is enough" 都是"降低标准"，合并
3. **行内逻辑清晰**: 左列用 "/" 连接等价表达，右列用 ";" 连接等价理由

---

### 精简点 2：Key Patterns 精简（原 40 行 → 精简 15 行）

**原文 (L115-151):**
```markdown
## Key Patterns

**Tests:**
```
✅ [Run test command] [See: 34/34 pass] "All tests pass"
❌ "Should pass now" / "Looks correct"
```

**Regression tests (TDD Red-Green):**
```
✅ Write → Run (pass) → Revert fix → Run (MUST FAIL) → Restore → Run (pass)
❌ "I've written a regression test" (without red-green verification)
```

**Build:**
```
✅ [Run build] [See: exit 0] "Build passes"
❌ "Linter passed" (linter doesn't check compilation)
```

**Requirements:**
```
✅ Re-read plan → Create checklist → Verify each → Report gaps or completion
❌ "Tests pass, phase complete"
```

**Agent delegation:**
```
✅ Agent reports success → Check VCS diff → Verify changes → Report actual state
❌ Trust agent report
```

**TDD compliance:**
```
✅ git log --oneline shows: test commit → code commit → verify
❌ git log shows: code commit → test commit (tests after)
```

**精简后:**
```markdown
## Key Patterns

| 场景 | ✅ 正确 | ❌ 错误 |
| --- | --- | --- |
| Tests | Run command → See 0 failures | "Should pass" |
| Build | Run build → exit 0 | Linter passed |
| Regression | Red-green cycle verified | Test passes once |
| Agent | Check VCS diff → Verify | Trust report |
| TDD | git log: test → code commit | Code before test |
| Delegation | Agent success → Check diff | Trust agent |
```

**精简原因:**
1. **代码块转表格**: 原 6 个场景各有代码块，精简为单表格
2. **保留核心区别**: ✅/❌ 两列清晰对比，一眼可辨
3. **删除解释性文本**: "Regression tests (TDD Red-Green)" 等标题解释删除，表格行内已说明

---

### 精简点 3：Why This Matters 整段删除（原 10 行）

**原文 (L153-161):**
```markdown
## Why This Matters

From 24 failure memories:
- your human partner said "I don't believe you" - trust broken
- Undefined functions shipped - would crash
- Missing requirements shipped - incomplete features
- Time wasted on false completion → redirect → rework
- Violates: "Honesty is a core value. If you lie, you'll be replaced."
```

**问题**: 这段是故事性内容，虽然有趣但对于 skill 来说不是必要的操作指导。

**精简后**: 删除

**精简原因:**
1. **故事性内容非必要**: "24 failure memories" 是叙事内容，不影响 skill 执行
2. **未注明来源**: 数据来源不可验证，删去避免误导
3. **核心原则已在上文说明**: Iron Law 已明确验证重要性，无需额外故事佐证

---

### 精简点 4：When To Apply 精简（原 16 行 → 精简 8 行）

**原文 (L162-177):**
```markdown
## When To Apply

**ALWAYS before:**
- ANY variation of success/completion claims
- ANY expression of satisfaction
- ANY positive statement about work state
- Committing, PR creation, task completion
- Moving to next task
- Delegating to agents

**Rule applies to:**
- Exact phrases
- Paraphrases and synonyms
- Implications of success
- ANY communication suggesting completion/correctness
```

**精简后:**
```markdown
## When To Apply

**ALWAYS before:**
- Claiming success/completion (any variation)
- Committing, PR creation, task completion
- Moving to next task
- Delegating to agents

规则适用于：直接表述、同义改写、成功暗示。
```

**精简原因:**
1. **合并同类项**: "ANY variation"、"any expression"、"ANY positive statement" 都是"任何形式"，合并为"任何变体"
2. **删除显而易见**: "Paraphrases and synonyms"是自然语言理解的基本能力，无需列明
3. **保留核心规则**: "ALWAYS before"清单保留，足够了

---

### verification-before-completion 精简汇总

| 段落 | 原行数 | 精简后 | 节省 |
| --- | --- | --- | --- |
| Rationalization Prevention | 15 | 8 | 7 |
| Key Patterns | 40 | 15 | 25 |
| Why This Matters | 10 | 0 | 10 |
| When To Apply | 16 | 8 | 8 |
| **总计** | **185** | **~120** | **~65 (35%)** |

---

## 三、shipping-and-launch 精简分析

**文件**: `.agents/skills/shipping-and-launch/SKILL.md`
**原始行数**: 311 行
**精简后预估**: 180 行
**精简比例**: ~42%

### 精简点 1：Pre-Launch Checklist 精简（原 56 行 → 引用外部 reference）

**原文 (L20-76):** 详细的 Pre-Launch Checklist，包含 6 个子章节（Code Quality、Security、Performance、Accessibility、Infrastructure、Documentation）

**问题**: 这些内容与 `harness-kit/references/` 中的文件大量重复（definition-of-done.md、security-checklist.md、performance-checklist.md、accessibility-checklist.md）

**精简后:**
```markdown
## Pre-Launch Checklist

详见 `harness-kit/references/` 对应文件：

| 类别 | Reference |
| --- | --- |
| 代码质量、测试 | `definition-of-done.md` |
| 安全 | `security-checklist.md` |
| 性能 | `performance-checklist.md` |
| 无障碍 | `accessibility-checklist.md` |
| 可观测性 | `observability-checklist.md` |

必须逐项检查并记录 pass/fail/n/a。
```

**精简原因:**
1. **DRY 原则**: Pre-Launch Checklist 与 `references/` 目录内容高度重复，外置引用避免维护两份
2. **精确定位**: 用户需要安全检查→读 `security-checklist.md`，需要性能检查→读 `performance-checklist.md`
3. **保持一致**: references/ 目录是 Harness 统一的 checklist 来源，ship skill 应引用而非复制

---

### 精简点 2：Feature Flag Strategy 精简（原 35 行 → 精简 15 行）

**原文 (L77-109):** 包含完整的 TypeScript 代码示例和详细的 Feature flag lifecycle

**精简后:**
```markdown
## Feature Flag Strategy

Ship behind feature flags to decouple deployment from release.

**Lifecycle:**
```
DEPLOY (flag OFF) → ENABLE (team/beta) → GRADUAL (5%→25%→50%→100%) → MONITOR → CLEAN UP
```

**Rules:**
- Every flag has owner + expiration date
- Clean up within 2 weeks of full rollout
- Test both flag states in CI
- Don't nest flags (exponential combinations)
```

**精简原因:**
1. **代码示例删除**: TypeScript 示例展示的是"如何写"而非"何时用"，后者才是 skill 的重点
2. **Lifecycle 一行化**: 原文用多行展示流程，精简为单行 pipeline 格式
3. **保留核心规则**: "每个 flag 有 owner + expiration"、"2 周内清理"等关键规则保留

---

### 精简点 3：Staged Rollout 精简（原 60 行 → 精简 25 行）

**原文 (L110-161):** 详细的 Rollout Sequence 树状图、Decision Thresholds 表格、When to Roll Back 列表

**精简后:**
```markdown
## Staged Rollout

**Sequence:** DEPLOY → ENABLE → CANARY (5%) → GRADUAL (25%→50%→100%) → FULL

**Decision Thresholds:**
| Metric | Advance | Hold | Rollback |
| --- | --- | --- | --- |
| Error rate | <10% above baseline | 10-100% above | >2x |
| P95 latency | <20% above | 20-50% above | >50% |
| Client JS errors | None | <0.1%/session | >0.1% |

**Rollback triggers:** >2x error rate, >50% latency spike, data integrity issues, security vulnerability.
```

**精简原因:**
1. **Sequence 一行化**: "Rollout Sequence" 树状图精简为单行 pipeline
2. **合并 Decision Thresholds**: 原文分"Advance/Hold/Rollback"三列，精简为紧凑格式
3. **删除解释性文本**: "CANARY rollout"、"GRADUAL increase"等标题性内容对理解无实质帮助

---

### 精简点 4：Monitoring and Observability 精简（原 65 行 → 精简 20 行）

**原文 (L162-236):** 包含详细的树状 metrics 结构、Error Reporting 代码示例、Post-Launch Verification 步骤

**精简后:**
```markdown
## Monitoring and Observability

**What to monitor:**
- Application: Error rate, response time (p50/p95/p99), volume
- Infrastructure: CPU, memory, disk, network
- Client: Core Web Vitals (LCP, INP, CLS), JS errors

**Post-launch (first hour):**
1. Health check → 200
2. Error monitoring → no new types
3. Latency → no regression
4. Critical user flow works
5. Logs flowing
6. Rollback ready

详见 `observability-checklist.md`
```

**精简原因:**
1. **树状结构转为列表**: "Application metrics"、"Infrastructure metrics"、"Client metrics"三个树节点合并为扁平列表
2. **Error Reporting 代码删除**: React/Node.js 错误边界代码是实现细节，skill 只需说明"配置错误上报"即可
3. **Post-Launch 精简**: 原文 6 步保留核心动作，删除每步的详细说明

---

### shipping-and-launch 精简汇总

| 段落 | 原行数 | 精简后 | 节省 |
| --- | --- | --- | --- |
| Pre-Launch Checklist | 56 | 12 | 44 |
| Feature Flag Strategy | 35 | 15 | 20 |
| Staged Rollout | 60 | 25 | 35 |
| Monitoring | 65 | 20 | 45 |
| Error Reporting 代码示例 | 35 | 0 | 35 |
| **总计** | **311** | **~180** | **~131 (42%)** |

---

## 四、systematic-debugging 精简分析

**文件**: `.agents/skills/systematic-debugging/SKILL.md`
**原始行数**: 297 行
**精简后预估**: 200 行
**精简比例**: ~33%

### 精简点 1：Multi-Component Systems 示例精简（原 40 行 → 精简 15 行）

**原文 (L72-107):** 包含完整的 4 层系统诊断示例和详细的环境变量追踪代码

**精简后:**
```markdown
**Multi-Component 诊断原则:**
```
For EACH component boundary:
  - Log data entering component
  - Log data exiting component
  - Verify env/config propagation
  - Check state at each layer

Run once → gather evidence → identify failing component → investigate that component
```

**Example (CI→build→signing):** 追踪 secrets 从 workflow → build script → signing 的传递，每层加 echo 诊断。
```

**精简原因:**
1. **示例代码删除**: "4 层系统诊断示例"展示的是 bash 命令，skill 是方法论而非命令手册
2. **原则提取**: 原示例体现"每层边界加诊断"原则，保留原则即可
3. **用户可自行查阅**: 具体命令在调试时按需查询，skill 不需要穷举

---

### 精简点 2：Common Rationalizations 精简（原 12 行 → 精简 6 行）

**原文 (L245-256):**
```markdown
## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Issue is simple, don't need process" | Simple issues have root causes too. Process is fast for simple bugs. |
| "Emergency, no time for process" | Systematic debugging is FASTER than guess-and-check thrashing. |
| "Just try this first, then investigate" | First fix sets the pattern. Do it right from the start. |
| "I'll write test after confirming fix works" | Untested fixes don't stick. Test first proves it. |
| "Multiple fixes at once saves time" | Can't isolate what worked. Causes new bugs. |
| "Reference too long, I'll adapt the pattern" | Partial understanding guarantees bugs. Read it completely. |
| "I see the problem, let me fix it" | Seeing symptoms ≠ understanding root cause. |
| "One more fix attempt" (after 2+ failures) | 3+ failures = architectural problem. Question pattern, don't fix again. |
```

**精简后:**
```markdown
## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Simple issue / Emergency / Just try first" | Systematic is FASTER than thrashing; process catches simple bugs too |
| "Write test after fix works" | Untested fixes don't stick |
| "Multiple fixes at once" | Can't isolate; causes new bugs |
| "Reference too long, I'll adapt" | Partial understanding guarantees bugs |
| "I see the problem" | Symptoms ≠ root cause |
| "One more fix" (after 2+ failures) | 3+ = architectural problem |
```

**精简原因:**
1. **合并相似借口**: "Simple issue / Emergency / Just try first" 都是"跳过流程的借口"，合并
2. **右列精简**: "Systematic debugging is FASTER than guess-and-check thrashing; process catches simple bugs too" 合并为"Faster than thrashing"
3. **语义保留**: 合并后仍覆盖原意，只是表达更紧凑

---

### 精简点 3：Supporting Techniques 引用精简（原 12 行 → 精简 5 行）

**原文 (L278-289):**
```markdown
## Supporting Techniques

These techniques are part of systematic debugging and available in this directory:

- **`root-cause-tracing.md`** - Trace bugs backward through call stack to find original trigger
- **`defense-in-depth.md`** - Add validation at multiple layers after finding root cause
- **`condition-based-waiting.md`** - Replace arbitrary timeouts with condition polling

**Related skills:**
- **superpowers:test-driven-development** - For creating failing test case (Phase 4, Step 1)
- **superpowers:verification-before-completion** - Verify fix worked before claiming success
```

**精简后:**
```markdown
## Supporting Techniques

详见同目录：
- `root-cause-tracing.md` - 反向追踪调用栈
- `defense-in-depth.md` - 多层验证
- `condition-based-waiting.md` - 条件轮询替代超时

**关联 skill:** `test-driven-development` (Phase 4)、`verification-before-completion`
```

**精简原因:**
1. **"These techniques are part of systematic debugging"删除**: 显而易见，无需说明
2. **文件说明精简**: "Trace bugs backward through call stack to find original trigger" 精简为"反向追踪调用栈"
3. **Related skills 简化**: superpowers 前缀删除，因为 skill 名称已是标准格式

---

### 精简点 4：Real-World Impact 整段删除（原 7 行）

**原文 (L290-296):**
```markdown
## Real-World Impact

From debugging sessions:
- Systematic approach: 15-30 minutes to fix
- Random fixes approach: 2-3 hours of thrashing
- First-time fix rate: 95% vs 40%
- New bugs introduced: Near zero vs common
```

**问题**: 数据未注明来源，且过于绝对

**精简后**: 删除

**精简原因:**
1. **数据来源不明**: "From debugging sessions" 未注明具体来源，数据可信度存疑
2. **过于绝对**: "95% vs 40%" 等数字未注明前提条件，删去避免误导
3. **方法论不需要数据**: 调试方法的有效性由逻辑和实践验证，不需要统计数字背书

---

### systematic-debugging 精简汇总

| 段落 | 原行数 | 精简后 | 节省 |
| --- | --- | --- | --- |
| Multi-Component 示例 | 40 | 15 | 25 |
| Common Rationalizations | 12 | 6 | 6 |
| Supporting Techniques | 12 | 5 | 7 |
| Real-World Impact | 7 | 0 | 7 |
| **总计** | **297** | **~200** | **~97 (33%)** |

---

## 五、code-review-and-quality 精简分析

**文件**: `.agents/skills/code-review-and-quality/SKILL.md`
**原始行数**: 382 行
**精简后预估**: 250 行
**精简比例**: ~35%

### 精简点 1：Review Checklist 精简（原 50 行 → 引用 reference）

**原文 (L292-338):** 完整的 Review Checklist 包含 6 个轴的详细检查项

**问题**: 与 `security-checklist.md`、`performance-checklist.md` 大量重复

**精简后:**
```markdown
## Review Checklist

详见对应 reference 文件：
- Security: `security-checklist.md`
- Performance: `performance-checklist.md`
- General: `definition-of-done.md`

**五轴快速检查:**
| 轴 | 核心问题 |
| --- | --- |
| Correctness | 代码做它声称的事？边缘情况？错误路径？ |
| Readability | 可被他人理解？命名清晰？无死代码？ |
| Architecture | 符合系统设计？依赖方向正确？ |
| Security | 输入验证？无注入？依赖可信？ |
| Performance | 无 N+1？无 unbounded 操作？ |
```

**精简原因:**
1. **外置 reference**: Security/Performance checklist 与 `references/` 目录重复，引用而非复制
2. **五轴快速检查**: 原 Review Checklist 50 行，精简为 5 轴核心问题
3. **保持可用性**: 快速检查后，用户如需详细检查可查阅对应 reference

---

### 精简点 2：Common Rationalizations 精简（原 14 行 → 精简 8 行）

**原文 (L344-355):**
```markdown
## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "It works, that's good enough" | Working code that's unreadable, insecure, or architecturally wrong creates debt that compounds. |
| "I wrote it, so I know it's correct" | Authors are blind to their own assumptions. Every change benefits from another set of eyes. |
| "We'll clean it up later" | Later never comes. The review is the quality gate — use it. Require cleanup before merge, not after. |
| "AI-generated code is probably fine" | AI code needs more scrutiny, not less. It's confident and plausible, even when wrong. |
| "The tests pass, so it's good" | Tests are necessary but not sufficient. They don't catch architecture problems, security issues, or readability concerns. |
| "The refactor makes it cleaner" | Relocating complexity isn't reducing it. If the reader still holds the same number of concepts, the structure didn't improve. |
| "It's only a small addition to this file" | Small diffs still push files past a healthy size and bolt branches onto unrelated flows. |
```

**精简后:**
```markdown
## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "It works / I wrote it / AI is fine" | Works ≠ correct; authors blind to assumptions; AI needs MORE scrutiny |
| "Clean up later / Tests pass, so good" | Later never comes; tests don't catch architecture/security/readability |
| "Refactor makes it cleaner" | Relocating complexity isn't reducing it |
| "Small addition" | Small diffs push files past healthy size; judge resulting structure |
```

**精简原因:**
1. **合并相似观点**: "It works / I wrote it / AI is fine" 都是"低估风险"，合并
2. **长句截断**: "Working code that's unreadable, insecure, or architecturally wrong creates debt that compounds" 精简为"Works ≠ correct"
3. **核心语义保留**: 合并后每行仍表达一个核心观点

---

### 精简点 3：Red Flags 精简（原 15 行 → 精简 8 行）

**原文 (L356-370):**
```markdown
## Red Flags

- PRs merged without any review
- Review that only checks if tests pass (ignoring other axes)
- "LGTM" without evidence of actual review
- Security-sensitive changes without security-focused review
- Large PRs that are "too big to review properly" (split them)
- No regression tests with bug fix PRs
- Review comments without severity labels — makes it unclear what's required vs optional
- Accepting "I'll fix it later" — it never happens
- A refactor that moves code around without reducing the number of concepts a reader must hold
- A change that grows an already-large file instead of decomposing it
- New conditionals scattered into unrelated code paths (a missing abstraction)
- A bespoke helper that duplicates an existing canonical one, or feature logic placed in a shared module
```

**精简后:**
```markdown
## Red Flags

- No review merged
- Only checking tests pass
- "LGTM" without evidence
- Security changes without security review
- Large PRs not split
- No regression tests with bug fix
- Comments without severity labels
- "Fix it later" accepted
- Refactor that relocates, not reduces complexity
```

**精简原因:**
1. **删除括号解释**: "PRs merged without any review" 等行末的括号说明删除
2. **合并相似项**: "Large PRs not split" 和 "No regression tests with bug fix" 都是"流程问题"，可精简
3. **保留关键词**: 每条只保留核心问题，如"no review"、"tests only"、"LGTM without evidence"

---

### code-review-and-quality 精简汇总

| 段落 | 原行数 | 精简后 | 节省 |
| --- | --- | --- | --- |
| Review Checklist | 50 | 15 | 35 |
| Common Rationalizations | 14 | 8 | 6 |
| Red Flags | 15 | 8 | 7 |
| Structural Remedies | 15 | 0 | 15（合并到五轴） |
| **总计** | **382** | **~250** | **~132 (35%)** |

---

## 六、test-driven-development 精简分析

**文件**: `.agents/skills/test-driven-development/SKILL.md`
**原始行数**: 374 行
**精简后预估**: 280 行
**精简比例**: ~25%

### 精简点 1：DOT 图转换为 ASCII 流程图（原 25 行 → 精简 12 行）

**原文 (L50-71):** 包含完整的 DOT 语言流程图

**精简后:**
```markdown
## Red-Green-Refactor

```
RED (write failing test) → Verify fails → GREEN (minimal code) → Verify passes → REFACTOR → repeat
                    ↑                          ↓
                    └──── wrong failure ───────┘
```

**核心:** 没看到测试失败就不要写代码。
```

**精简原因:**
1. **DOT 图格式依赖**: 原 DOT 语言需要特定工具渲染，ASCII 流程图纯文本即可理解
2. **核心循环保留**: "RED → Verify → GREEN → Verify → REFACTOR → repeat" 是唯一必要的流程
3. **边角情况精简**: "wrong failure" 分支保留，但用箭头表示而非完整 DOT

---

### 精简点 2：Why Order Matters 段落精简（原 50 行 → 精简 20 行）

**原文 (L208-256):** 详细反驳各种"测试可以后写"的理由

**精简后:**
```markdown
## Why Order Matters

| 借口 | 现实 |
| --- | --- |
| "测试后写也一样" | Tests-after 回答"这做什么"，Tests-first 回答"这应该做什么" |
| "手动测试过了" | 手动测试是 ad-hoc；无记录；无法重跑 |
| "删掉 X 小时工作浪费" | 沉没成本谬误；未验证代码是技术债 |
| "TDD 是教条" | TDD 就是实用的：更早发现 bug、防止回归、记录行为、支撑重构 |

Tests-first 强制在实现前发现边缘情况。Tests-after 验证你记住了什么（你没记住）。
```

**精简原因:**
1. **论点精简**: "30 minutes of tests after ≠ TDD. You get coverage, lose proof tests work" 等论证性内容精简
2. **保留核心对比**: "Tests-after 回答'这做什么'，Tests-first 回答'这应该做什么'"是核心观点，保留
3. **表格化**: 多个借口→现实对应关系用表格简洁呈现

---

### 精简点 3：Common Rationalizations 精简（原 15 行 → 精简 8 行）

**原文 (L258-272):**
```markdown
## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple code breaks. Test takes 30 seconds. |
| "I'll test after" | Tests passing immediately prove nothing. |
| "Tests after achieve same goals" | Tests-after = "what does this do?" Tests-first = "what should this do?" |
| "Already manually tested" | Ad-hoc ≠ systematic. No record, can't re-run. |
| "Deleting X hours is wasteful" | Sunk cost fallacy. Keeping unverified code is technical debt. |
| "Keep as reference, write tests first" | You'll adapt it. That's testing after. Delete means delete. |
| "Need to explore first" | Fine. Throw away exploration, start with TDD. |
| "Test hard = design unclear" | Listen to test. Hard to test = hard to use. |
| "TDD will slow me down" | TDD faster than debugging. Pragmatic = test-first. |
| "Manual test faster" | Manual doesn't prove edge cases. You'll re-test every change. |
| "Existing code has no tests" | You're improving it. Add tests for existing code. |
```

**精简后:**
```markdown
## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Too simple / Manual faster" | 简单代码也崩；手动不能证明边缘情况 |
| "Test after / Same goals" | Tests-after 证明不了什么；tests-first 强制先发现边缘情况 |
| "Keep as reference" | 你会 adaptation；delete means delete |
| "Explore first" | 探索可以，然后扔掉，从 TDD 开始 |
| "Test hard = design unclear" | 听测试的；难测试 = 难使用 |
| "Sunk cost" | 未验证代码是技术债 |
```

**精简原因:**
1. **中英混合精简**: 原英文借口→英文现实，精简为英文借口→中文现实
2. **合并相似项**: "Too simple / Manual faster" 都是"认为不需要测试"，合并
3. **保留核心**: 每个借口只需保留最关键的反驳理由

---

### test-driven-development 精简汇总

| 段落 | 原行数 | 精简后 | 节省 |
| --- | --- | --- | --- |
| DOT 图 | 25 | 12 | 13 |
| Why Order Matters | 50 | 20 | 30 |
| Common Rationalizations | 15 | 8 | 7 |
| Example: Bug Fix | 35 | 20 | 15 |
| **总计** | **374** | **~280** | **~94 (25%)** |

---

## 七、精简汇总表

| 文件 | 原行数 | 精简后 | 节省行数 | 精简比例 |
| --- | --- | --- | --- | --- |
| `routing.md` | 320 | ~180 | ~140 | 44% |
| `verification-before-completion/SKILL.md` | 185 | ~120 | ~65 | 35% |
| `shipping-and-launch/SKILL.md` | 311 | ~180 | ~131 | 42% |
| `systematic-debugging/SKILL.md` | 297 | ~200 | ~97 | 33% |
| `code-review-and-quality/SKILL.md` | 382 | ~250 | ~132 | 35% |
| `test-driven-development/SKILL.md` | 374 | ~280 | ~94 | 25% |
| **总计** | **1869** | **~1210** | **~659** | **~35%** |

---

## 八、精简策略总结

### 1. 重复内容外置
- Pre-Launch Checklist → 引用 `references/` 目录
- Review Checklist → 引用 `references/` 目录
- 多个 safety checklist → 合并到统一表格

### 2. 代码示例精简
- 保留核心模式，删除完整实现代码
- 用表格替代冗长的代码块
- 示例只保留 1-2 个代表性场景

### 3. Rationalization 表格合并
- 多个相似的借口合并为一行
- 使用 `/` 表示多个等价表达

### 4. 故事性内容删除
- "Why This Matters" 类段落
- "Real-World Impact" 数据
- 过于冗长的背景说明

### 5. 格式规范化
- 用表格替代冗长列表
- 用流程图替代详细步骤说明
- 用引用替代重复内容

---

## 九、完整精简版文件

以下为推荐的精简版文件内容（可直接替换）：

### 精简版 routing.md（180行版本）

[见下一节：精简版完整内容]

---

## 十、精简版完整内容

### 精简版 verification-before-completion/SKILL.md

```markdown
---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing - evidence before assertions always
---

# Verification Before Completion

## Overview

**Core principle:** Evidence before claims, always.

**Iron Law:** NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE

If you haven't run the verification command in this message, you cannot claim it passes.

## The Gate Function

```
BEFORE claiming any status:
1. IDENTIFY: What command proves this claim?
2. RUN: Execute the FULL command (fresh, complete)
3. READ: Full output, check exit code, count failures
4. VERIFY: Does output confirm the claim?
   - If NO: State actual status with evidence
   - If YES: State claim WITH evidence
5. ONLY THEN: Make the claim
Skip any step = lying, not verifying
```

## TDD Compliance Gate (MANDATORY)

**When production code was written**, prove TDD compliance before claiming done:

1. **IDENTIFY** files with production code changes
2. **CHECK** git history for test-first pattern:
   - Test commit hash: `[hash]`
   - Code commit hash: `[hash]`
   - Test commit is **before** code commit: YES/NO
3. **VERIFY** test quality:
   - Happy path covered: YES/NO
   - Edge cases: YES/NO
   - Error cases: YES/NO
4. **RUN** full test suite; confirm 0 failures

**If ANY check fails:** State `TDD compliance FAILED` with evidence. DO NOT claim completion.

**Evidence format:**
```
TDD Compliance:
- Test commit: abc1234
- Code commit: def5678
- Test-first: YES
- All tests pass: YES (42/42)
```

**Docs-only/chore-only:** State `TDD gate: N/A (no production code)`.

## Common Failures

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| Tests pass | Test output: 0 failures | Previous run |
| Build succeeds | Build: exit 0 | Linter passing |
| Bug fixed | Test original symptom: passes | Code changed |
| TDD compliance | Git log: test → code commit | Tests after |

## Red Flags - STOP

- Using "should", "probably", "seems to"
- Expressing satisfaction before verification
- About to commit without verification
- Trusting agent success reports
- Tired and wanting work over
- Git log shows code before tests

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "Should work now" / "I'm confident" | RUN the verification; confidence ≠ evidence |
| "Just this once" / "Partial check" | No exceptions; partial proves nothing |
| "Linter passed" / "Agent said success" | Linter ≠ compiler; verify independently |
| "Tests after achieve same goals" | Git log must prove test-first |
| "Already spent X hours" | Sunk cost; unverified code is technical debt |

## Key Patterns

| 场景 | ✅ 正确 | ❌ 错误 |
| --- | --- | --- |
| Tests | Run command → 0 failures | "Should pass" |
| Build | Run build → exit 0 | Linter passed |
| Regression | Red-green verified | Test passes once |
| Agent | Check VCS diff | Trust report |
| TDD | git log: test → code | Code before test |

## When To Apply

**ALWAYS before:**
- Claiming success/completion (any variation)
- Committing, PR creation, task completion
- Moving to next task
- Delegating to agents

## Bottom Line

**No shortcuts for verification.**

Run the command. Read the output. THEN claim the result.

This is non-negotiable.
```

---

### 精简版 systematic-debugging/SKILL.md（200行版本）

```markdown
---
name: systematic-debugging
description: Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes
---

# Systematic Debugging

## Overview

**Core principle:** ALWAYS find root cause before attempting fixes. Symptom fixes are failure.

**Iron Law:** NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST

If you haven't completed Phase 1, you cannot propose fixes.

## When to Use

Use for ANY technical issue:
- Test failures, Bugs in production
- Unexpected behavior, Performance problems
- Build failures, Integration issues

**Use ESPECIALLY when:**
- Under time pressure (emergencies make guessing tempting)
- "Just one quick fix" seems obvious
- You've already tried multiple fixes
- Previous fix didn't work
- You don't fully understand the issue

## The Four Phases

### Phase 1: Root Cause Investigation

**BEFORE attempting ANY fix:**

1. **Read Error Messages Carefully**
   - Don't skip past errors or warnings
   - Read stack traces completely
   - Note line numbers, file paths, error codes

2. **Reproduce Consistently**
   - Can you trigger it reliably?
   - What are the exact steps?

3. **Check Recent Changes**
   - Git diff, recent commits
   - New dependencies, config changes

4. **Multi-Component 诊断原则:**
   ```
   For EACH component boundary:
     - Log data entering
     - Log data exiting
     - Verify env/config propagation
     - Run once → identify failing component → investigate that component
   ```

5. **Trace Data Flow**
   - Where does bad value originate?
   - What called this with bad value?
   - Fix at source, not at symptom

### Phase 2: Pattern Analysis

1. **Find Working Examples** - Locate similar working code
2. **Compare Against References** - Read reference implementation COMPLETELY
3. **Identify Differences** - List every difference
4. **Understand Dependencies** - What does this need?

### Phase 3: Hypothesis and Testing

1. **Form Single Hypothesis** - "I think X is the root cause because Y"
2. **Test Minimally** - ONE variable at a time
3. **Verify Before Continuing** - Yes → Phase 4, No → NEW hypothesis
4. **When You Don't Know** - Say "I don't understand X", research more

### Phase 4: Implementation

1. **Create Failing Test Case** - Use `test-driven-development` skill
2. **Implement Single Fix** - ONE change at a time, no "while I'm here"
3. **Verify Fix** - Test passes? No other tests broken?
4. **If Fix Doesn't Work:**
   - < 3 fixes: Return to Phase 1
   - ≥ 3 fixes: **STOP and question the architecture**

### Phase 4.5: Question Architecture

**Pattern indicating architectural problem:**
- Each fix reveals new problem in different place
- Fixes require "massive refactoring"
- Each fix creates new symptoms elsewhere

**STOP and discuss with human partner.**

## Red Flags - STOP

- "Quick fix for now, investigate later"
- "Just try changing X"
- Proposing solutions before tracing data flow
- **"One more fix attempt" (when already tried 2+)**

**ALL mean: Return to Phase 1.**

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Simple issue / Emergency / Just try first" | Systematic is FASTER than thrashing |
| "Write test after fix works" | Untested fixes don't stick |
| "Multiple fixes at once" | Can't isolate; causes new bugs |
| "Reference too long, I'll adapt" | Partial understanding guarantees bugs |
| "I see the problem" | Symptoms ≠ root cause |
| "One more fix" (after 2+ failures) | 3+ = architectural problem |

## Quick Reference

| Phase | Key Activities | Success Criteria |
|-------|---------------|------------------|
| **1. Root Cause** | Read errors, reproduce, check changes | Understand WHAT and WHY |
| **2. Pattern** | Find working examples, compare | Identify differences |
| **3. Hypothesis** | Form theory, test minimally | Confirmed or new hypothesis |
| **4. Implementation** | Create test, fix, verify | Bug resolved, tests pass |

## Supporting Techniques

详见同目录：
- `root-cause-tracing.md` - 反向追踪调用栈
- `defense-in-depth.md` - 多层验证
- `condition-based-waiting.md` - 条件轮询替代超时

**关联 skill:** `test-driven-development` (Phase 4)、`verification-before-completion`
```

---

### 精简版 shipping-and-launch/SKILL.md（180行版本）

```markdown
---
name: shipping-and-launch
description: Prepares production launches. Use when deploying to production, setting up monitoring, planning staged rollout, or needing rollback strategy.
---

# Shipping and Launch

## Overview

Ship with confidence. The goal is not just to deploy — it's to deploy safely, with monitoring in place, a rollback plan ready, and a clear understanding of what success looks like.

## Pre-Launch Checklist

详见 `harness-kit/references/` 对应文件：

| 类别 | Reference |
| --- | --- |
| 代码质量、测试 | `definition-of-done.md` |
| 安全 | `security-checklist.md` |
| 性能 | `performance-checklist.md` |
| 无障碍 | `accessibility-checklist.md` |
| 可观测性 | `observability-checklist.md` |

必须逐项检查并记录 pass/fail/n/a。

## Feature Flag Strategy

Ship behind feature flags to decouple deployment from release.

**Lifecycle:**
```
DEPLOY (flag OFF) → ENABLE (team/beta) → GRADUAL (5%→25%→50%→100%) → MONITOR → CLEAN UP
```

**Rules:**
- Every flag has owner + expiration date
- Clean up within 2 weeks of full rollout
- Test both flag states in CI
- Don't nest flags (exponential combinations)

## Staged Rollout

**Sequence:** DEPLOY → ENABLE → CANARY (5%) → GRADUAL (25%→50%→100%) → FULL

**Decision Thresholds:**
| Metric | Advance | Hold | Rollback |
| --- | --- | --- | --- |
| Error rate | <10% above baseline | 10-100% above | >2x |
| P95 latency | <20% above | 20-50% above | >50% |
| Client JS errors | None | <0.1%/session | >0.1% |

**Rollback triggers:** >2x error rate, >50% latency spike, data integrity issues, security vulnerability.

## Monitoring and Observability

**What to monitor:**
- Application: Error rate, response time (p50/p95/p99), volume
- Infrastructure: CPU, memory, disk, network
- Client: Core Web Vitals (LCP, INP, CLS), JS errors

**Post-launch (first hour):**
1. Health check → 200
2. Error monitoring → no new types
3. Latency → no regression
4. Critical user flow works
5. Logs flowing
6. Rollback ready

详见 `observability-checklist.md`

## Rollback Strategy

Every deployment needs a rollback plan before it happens:

```
## Rollback Plan for [Feature/Release]

### Trigger Conditions
- Error rate > 2x baseline
- P95 latency > [X]ms

### Rollback Steps
1. Disable feature flag (if applicable)
   OR
1. Deploy previous version: git revert <commit> && git push
2. Verify: health check, error monitoring
3. Communicate: notify team

### Time to Rollback
- Feature flag: < 1 minute
- Redeploy: < 5 minutes
- Database rollback: < 15 minutes
```

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Works in staging, works in prod" | Prod has different data, traffic, edge cases |
| "Don't need feature flags" | Every feature benefits from kill switch |
| "Monitoring is overhead" | No monitoring = discover from complaints |
| "We'll add monitoring later" | Add before launch; can't debug unseen |
| "Rolling back is failure" | Rolling back is responsible engineering |

## Red Flags

- Deploying without rollback plan
- No monitoring in production
- Big-bang releases (no staging)
- Feature flags with no owner/expiration
- No one monitoring first hour
- "It's Friday afternoon, let's ship it"
