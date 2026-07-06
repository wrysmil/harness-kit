---
artifact: implementation-plan
route: superpowers:writing-plans
skills:
  - writing-plans
skills_evidence:
  - ~/.agents/skills/writing-plans/SKILL.md
source:
  - docs/superpowers/specs/2026-05-27-doc-review-and-quality-improvement.md
  - harness-kit/core/routing.md
created_at: 2026-05-27
platform: cursor
status: implemented
---

# 文档审查与质量改进 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 创建 `document-review` skill，系统化文档审查流程（环境准备优先、按文档类型加载规则）；自测和 Leader 审查复用现有 `requesting-code-review` skill。

**Architecture:** 新增 `document-review` skill（主入口 + 按需加载审查规则 + 检查清单），通过 `core/routing.md` 路由表接入。自测和 Leader 审查直接调用已有的 `requesting-code-review`，不重复造轮子。

**Tech Stack:** Markdown SKILL.md + 规则文件 + 检查清单模板；无应用运行时代码变更。

**TDD Required:** YES (每个产出代码的 Task 必须遵循 RED-GREEN-REFACTOR)

**Spec:** `docs/superpowers/specs/2026-05-27-doc-review-and-quality-improvement.md`

---

## 文件结构（锁定）

| 文件 | 动作 | 职责 |
| --- | --- | --- |
| `adapters/cursor/.cursor/skills/document-review/SKILL.md` | 新增 | 文档审查主入口，通用流程 + 文档类型识别 |
| `adapters/cursor/.cursor/skills/document-review/review-rules/spec.md` | 新增 | 规格/需求文档审查规则 |
| `adapters/cursor/.cursor/skills/document-review/review-rules/design.md` | 新增 | 架构/技术设计文档审查规则（含环境准备） |
| `adapters/cursor/.cursor/skills/document-review/review-rules/plan.md` | 新增 | 实施计划审查规则 |
| `adapters/cursor/.cursor/skills/document-review/checklists/review-checklist.md` | 新增 | 通用审查检查清单 |
| `artifact-templates/document-review.md` | 新增 | 文档审查产物模板 |
| `core/routing.md` | 修改 | 路由表新增文档审查路由 |
| `core/artifacts.md` | 修改 | 产物目录确认 reviews/ 说明 |
| `adapters/cursor/.cursor/rules/ai-entry.mdc` | 修改 | 按判定加载表新增文档审查路由 |
| `adapters/cursor/.cursor/rules/cursor-subagent-routing.mdc` | 修改 | Leader 要点新增文档审查说明 |

---

## 执行图

```markdown
GROUP-1（可并行）:
  WU-01: document-review skill（主入口 + 审查规则 + 检查清单）| 5 个文件
  WU-02: writing-plans TDD 强制执行 | 1 个文件
  WU-03: verification-before-completion TDD 合规 gate | 1 个文件

GROUP-2（依赖 GROUP-1）:
  WU-04: 产物模板 + 路由与规则更新 | 5 个文件

GROUP-3（依赖 GROUP-2）:
  WU-05: 全库一致性检查 + spec status
```

---

## 任务

### Task 1: 创建 `document-review` Skill（主入口 + 审查规则 + 检查清单）

**Files:**
- Create: `adapters/cursor/.cursor/skills/document-review/SKILL.md`
- Create: `adapters/cursor/.cursor/skills/document-review/review-rules/spec.md`
- Create: `adapters/cursor/.cursor/skills/document-review/review-rules/design.md`
- Create: `adapters/cursor/.cursor/skills/document-review/review-rules/plan.md`
- Create: `adapters/cursor/.cursor/skills/document-review/checklists/review-checklist.md`

**Spec 来源:** spec S3.1 文档审查Skill设计

- [ ] **Step 1: 创建 `SKILL.md` -- 文档类型识别 + 通用审查流程**

```yaml
---
name: document-review
description: Use when reviewing any document (spec, design, plan) for completeness, clarity, and quality -- especially environment preparation completeness. Triggers: review document, check document, audit spec, audit design, 审查文档, 检查文档, 文档审查
---
```

正文章节：

1. **When to Use** -- 需求文档、架构设计、实施计划、环境配置文档的审查
2. **Document Type Detection** -- 按关键词识别类型并加载规则：

| 文档特征 | 类型 | 加载规则 |
|---------|------|---------|
| "需求"、"用户故事"、"功能"、"spec" | 规格/需求文档 | `review-rules/spec.md` |
| "架构"、"设计"、"实现"、"API"、"环境"、"部署" | 架构/技术设计文档 | `review-rules/design.md` |
| "计划"、"plan"、"任务"、"阶段" | 实施计划文档 | `review-rules/plan.md` |

3. **Review Flow** -- 识别类型 -> 加载规则 -> 执行审查 -> 输出报告
4. **Output Format** -- 审查报告格式（文档类型、审查结果、缺失项、改进建议、Next）
5. **Integration** -- 自测和 Leader 审查复用 `requesting-code-review`，本 skill 专注文档审查
6. **Red Flags** -- 跳过环境准备审查、只做表面检查、不输出具体缺失项

- [ ] **Step 2: 创建 `review-rules/spec.md`**

```markdown
# 规格/需求文档审查规则

## 审查维度

### 1. 需求完整性
- 用户故事覆盖所有场景
- 功能点有明确的验收标准
- 非功能需求（性能、安全、可用性）已定义

### 2. 逻辑清晰度
- 需求之间无矛盾
- 优先级明确
- 依赖关系清晰

### 3. 可测试性
- 每个需求可验证
- 验收标准可量化
- 边界条件已定义

## 检查清单
- [ ] 错误处理场景已覆盖
- [ ] 边界条件已定义
- [ ] 并发场景已考虑
- [ ] 安全考虑已记录
- [ ] 性能要求已明确
```

- [ ] **Step 3: 创建 `review-rules/design.md`**

```markdown
# 架构/技术设计文档审查规则

## 审查维度

### 1. 整体设计
- 架构图清晰，组件职责明确
- 接口定义完整，依赖关系清晰
- 设计模式合理，可扩展性好

### 2. 环境准备（重点）
- **依赖管理**：列出所有第三方依赖及版本、安装命令、锁文件
- **环境变量**：列出所有必需变量、提供 .env.example、说明密钥获取方式
- **外部服务**：列出所有服务依赖、提供 Docker Compose 等本地方案
- **开发环境**：明确运行环境要求、提供环境验证命令
- **测试环境**：测试数据库、Mock 服务、测试数据准备

### 3. 技术细节
- API 设计：接口定义、请求/响应格式、错误码
- 数据库设计：表结构、索引、迁移方案
- 安全考虑：认证授权、数据加密、输入验证

## 环境准备检查清单
- [ ] 所有依赖有版本号
- [ ] .env.example 存在且完整
- [ ] 外部服务有本地方案
- [ ] 环境验证命令可执行
- [ ] 测试环境配置独立
```

- [ ] **Step 4: 创建 `review-rules/plan.md`**

```markdown
# 实施计划审查规则

## 审查维度

### 1. 阶段结构
- **第一阶段必须是环境准备**
- 阶段划分清晰，依赖关系明确
- 每个阶段有明确的验证标准

### 2. 任务粒度
- 任务可独立执行（2-5 分钟）
- 有明确的输入输出
- 有验证命令

### 3. 环境准备完整性
- 依赖安装步骤完整
- 环境变量配置步骤完整
- 外部服务配置步骤完整
- 环境验证步骤完整

### 4. 测试计划
- 单元测试覆盖核心逻辑
- 集成测试覆盖关键流程
- 测试数据准备方案

## 检查清单
- [ ] Phase 1 是环境准备
- [ ] 每个 Phase 有验证标准
- [ ] 任务有文件路径和代码
- [ ] 环境验证命令可执行
```

- [ ] **Step 5: 创建 `checklists/review-checklist.md`**

```markdown
# 通用文档审查检查清单

## 基础检查
- [ ] 文档有明确标题
- [ ] 文档有版本/日期信息
- [ ] 文档结构清晰（有目录或章节）
- [ ] 术语使用一致

## 内容完整性
- [ ] 覆盖所有需求/功能点
- [ ] 有明确的验收标准
- [ ] 有错误处理说明
- [ ] 有边界条件说明

## 环境准备
- [ ] 依赖列表完整
- [ ] 环境变量配置完整
- [ ] 外部服务依赖明确
- [ ] 环境验证命令可执行

## 可执行性
- [ ] 步骤可操作
- [ ] 有验证命令
- [ ] 有预期结果
- [ ] 有回滚方案（如适用）
```

- [ ] **Step 6: 验证**

```bash
test -d adapters/cursor/.cursor/skills/document-review
ls adapters/cursor/.cursor/skills/document-review/
# 预期: SKILL.md, review-rules/, checklists/

rg -n "Document Type Detection|review-rules" adapters/cursor/.cursor/skills/document-review/SKILL.md
rg -n "环境准备|依赖管理" adapters/cursor/.cursor/skills/document-review/review-rules/design.md
rg -c "\- \[" adapters/cursor/.cursor/skills/document-review/checklists/review-checklist.md
# 预期: 16 个检查项
```

- [ ] **Step 7: Commit**

```bash
git add adapters/cursor/.cursor/skills/document-review/
git commit -m "feat(harness-kit): 新增 document-review skill（主入口 + 审查规则 + 检查清单）"
```

---

### Task 2: 创建产物模板 + 更新路由与规则

**Files:**
- Create: `artifact-templates/document-review.md`
- Modify: `core/routing.md`
- Modify: `core/artifacts.md`
- Modify: `adapters/cursor/.cursor/rules/ai-entry.mdc`
- Modify: `adapters/cursor/.cursor/rules/cursor-subagent-routing.mdc`

**Spec 来源:** spec S4 路由表更新、spec S5.1 产物模板

- [ ] **Step 1: 创建 `artifact-templates/document-review.md`**

```yaml
---
artifact: document-review
route: superpowers:document-review
skills:
  - document-review
skills_evidence:
  - ~/.cursor/skills/document-review/SKILL.md
source:
  - 用户提供的文档
created_at: <YYYY-MM-DD>
---
```

```markdown
# <文档名称> 审查报告

## 文档类型
[架构文档/技术实现文档/需求文档/环境配置文档]

## 审查规则加载
- [x] 通用审查流程
- [x] 文档类型特定规则
- [x] 环境准备审查规则

## 审查结果

### 1. 文档完整性
[评分：完整/基本完整/不完整]

### 2. 逻辑清晰度
[评分：清晰/基本清晰/不清晰]

### 3. 环境准备完整性
[评分：完整/基本完整/不完整]

### 4. 缺失项清单
[按优先级列出缺失内容]

### 5. 改进建议
[具体改进建议]

## Next
- 审查通过 -> 继续下一阶段
- 需要补充 -> 返回修改文档
- 需要讨论 -> 组织评审会议
```

- [ ] **Step 2: 更新 `core/routing.md` 路由表**

在路由表新增一行：

| 任务类型 | Cursor Route | 产物 |
|---------|--------------|------|
| 文档审查 | `superpowers:document-review` | `.ai-runtime-artifacts/reviews/` |

在「按判定加载」表新增：

| 判定 | 再读 |
|------|------|
| 文档审查 | **1** Load `document-review` -> **2** 根据文档类型加载对应规则 |

- [ ] **Step 3: 更新 `ai-entry.mdc`**

在按判定加载表新增文档审查路由（同 routing.md）。

- [ ] **Step 4: 更新 `cursor-subagent-routing.mdc`**

在 Leader 要点新增：文档审查调用 `document-review` skill。

- [ ] **Step 5: 确认 `core/artifacts.md` 中 `reviews/` 目录已存在**

```bash
rg "reviews" core/artifacts.md
```

- [ ] **Step 6: 验证**

```bash
test -f artifact-templates/document-review.md
rg "document-review" core/routing.md
rg "document-review" adapters/cursor/.cursor/rules/ai-entry.mdc
```

- [ ] **Step 7: Commit**

```bash
git add artifact-templates/document-review.md core/routing.md core/artifacts.md adapters/cursor/.cursor/rules/ai-entry.mdc adapters/cursor/.cursor/rules/cursor-subagent-routing.mdc
git commit -m "feat(harness-kit): 路由表和规则支持 document-review，新增产物模板"
```

---

### Task 3: 全库一致性检查与收尾

**Files:**
- Modify: `docs/superpowers/specs/2026-05-27-doc-review-and-quality-improvement.md`（status: approved）

- [ ] **Step 1: 检查所有新文件存在**

```bash
cd /Users/mima0000/Downloads/harness-kit

test -f adapters/cursor/.cursor/skills/document-review/SKILL.md
test -f adapters/cursor/.cursor/skills/document-review/review-rules/spec.md
test -f adapters/cursor/.cursor/skills/document-review/review-rules/design.md
test -f adapters/cursor/.cursor/skills/document-review/review-rules/plan.md
test -f adapters/cursor/.cursor/skills/document-review/checklists/review-checklist.md
test -f artifact-templates/document-review.md

echo "All files exist"
```

- [ ] **Step 2: 检查路由一致性**

```bash
rg "document-review" core/routing.md adapters/cursor/.cursor/rules/*.mdc
```

- [ ] **Step 3: 确认 spec 与 plan 对齐**

核心需求覆盖：
- [x] 文档审查 skill -> Task 1
- [x] 环境准备审查规则 -> Task 1 (design.md)
- [x] 路由表更新 -> Task 2
- [x] 产物模板 -> Task 2
- [ ] 自测和 Leader 审查 -> 复用 `requesting-code-review`，无需额外 skill

- [ ] **Step 4: 更新 spec status**

将 `status: proposed` 改为 `status: approved`

- [ ] **Step 5: Commit**

```bash
git add docs/superpowers/specs/2026-05-27-doc-review-and-quality-improvement.md
git commit -m "chore(harness-kit): 文档审查与质量改进实现完成，spec 标记 approved"
```

---

### Task 4: 加固 writing-plans -- 强制 TDD 结构

**Files:**
- Modify: `~/.agents/skills/writing-plans/SKILL.md`

**Spec 来源:** 附录 A. 加固 writing-plans

- [ ] **Step 1: 新增 "TDD Enforcement (MANDATORY)" 章节**

在 Overview 和 Scope Check 之间插入：

```markdown
## TDD Enforcement (MANDATORY)

**Every plan MUST follow TDD structure. No exceptions.**

### Rule: Test Before Code

Every task that produces production code MUST follow this exact order:

1. **Step 1: Write the failing test** (this is ALWAYS step 1)
2. **Step 2: Run test to verify it fails** (MANDATORY verification)
3. **Step 3: Write minimal implementation**
4. **Step 4: Run test to verify it passes**
5. **Step 5: Commit**

**Forbidden patterns:**
- Task starts with implementation code (MUST start with test)
- Task has "Write tests for the above" as a later step
- Task mixes test and implementation in one step
- Task has no verification step after test/implementation

### Quality Requirements for Tests

Each test MUST cover:

1. **Happy path** - normal expected behavior
2. **Edge cases** - null, empty, boundary values
3. **Error cases** - invalid input, permission errors, network failures

Bad test:
\`\`\`python
test('user exists')  # Tests nothing useful
\`\`\`

Good test:
\`\`\`python
test('returns user when found')
test('returns None when user does not exist')
test('raises ValueError when user_id is None')
test('raises PermissionError when not authorized')
\`\`\`
```

- [ ] **Step 2: 修改 Plan Document Header**

在 Tech Stack 行后新增：

```markdown
**TDD Required:** YES (every task follows RED-GREEN-REFACTOR)
```

- [ ] **Step 3: 修改 No Placeholders 章节**

新增两项禁止模式：

```markdown
- **Implementation code as Step 1** (MUST be test first)
- **Test after implementation** (violates TDD Iron Law)
```

- [ ] **Step 4: 修改 Remember 章节**

新增一行：

```markdown
- **Every task starts with test, ends with verify**
```

- [ ] **Step 5: 修改 Self-Review 章节**

在 Type consistency 之后新增：

```markdown
**4. TDD compliance scan:** For EVERY task that produces production code:
- [ ] Step 1 is "Write the failing test"
- [ ] Step 2 is "Run test to verify it fails"
- [ ] Step 3 is "Write minimal implementation"
- [ ] Step 4 is "Run test to verify it passes"
- [ ] Tests cover happy path, edge cases, and error cases
- [ ] No task starts with implementation code
```

- [ ] **Step 6: 验证**

```bash
rg "TDD Enforcement" ~/.agents/skills/writing-plans/SKILL.md
rg "TDD compliance scan" ~/.agents/skills/writing-plans/SKILL.md
rg "TDD Required" ~/.agents/skills/writing-plans/SKILL.md
```

Expected: 三个匹配

- [ ] **Step 7: Commit**

```bash
cd ~/.agents && git add skills/writing-plans/SKILL.md
git commit -m "feat: writing-plans 强制 TDD 结构"
```

---

### Task 5: 加固 verification-before-completion -- TDD 合规 Gate

**Files:**
- Modify: `adapters/cursor/.cursor/skills/verification-before-completion/SKILL.md`

**Spec 来源:** 附录 B. 加固 verification-before-completion

- [ ] **Step 1: 新增 "TDD Compliance Gate (MANDATORY)" 章节**

在 The Iron Law 之后插入：

```markdown
## TDD Compliance Gate (MANDATORY)

**BEFORE claiming "done" or "complete", you MUST prove TDD compliance:**

1. **IDENTIFY** what production code was written (files changed)
2. **CHECK** git log for test-first commit pattern:
   - Test commit hash: [hash]
   - Code commit hash: [hash]
   - Test commit is BEFORE code commit: YES/NO
3. **VERIFY** test quality:
   - Happy path covered: YES/NO
   - Edge cases covered (null/empty/boundary): YES/NO
   - Error cases covered: YES/NO
4. **RUN** full test suite to confirm all pass

**If ANY check fails:**
- State "TDD compliance FAILED" with evidence
- DO NOT claim completion
- Fix the issue first

**Evidence format:**
```
TDD Compliance:
- Test commit: abc1234
- Code commit: def5678
- Test-first: YES
- Happy path: YES
- Edge cases: YES
- Error cases: YES
- All tests pass: YES (42/42)
```
```

- [ ] **Step 2: 修改 Common Failures 表格**

新增一行：

```markdown
| TDD compliance | Git log shows test-first commit pattern | Code commit without test commit |
```

- [ ] **Step 3: 修改 Red Flags 章节**

新增一项：

```markdown
- Git log shows code before tests (TDD violation)
```

- [ ] **Step 4: 修改 Key Patterns 章节**

在 Agent delegation 之后新增：

```markdown
**TDD compliance:**
\`\`\`
✅ git log --oneline shows: test commit -> code commit -> verify commit
❌ git log --oneline shows: code commit -> test commit (tests after)
\`\`\`
```

- [ ] **Step 5: 修改 Rationalization Prevention 表格**

新增两行：

```markdown
| "Tests after achieve same goals" | Git log proves test-first. Tests-after = bias. |
| "Already spent X hours, deleting is wasteful" | Sunk cost. Unverified code is debt. |
```

- [ ] **Step 6: 验证**

```bash
rg "TDD Compliance Gate" adapters/cursor/.cursor/skills/verification-before-completion/SKILL.md
rg "git log" adapters/cursor/.cursor/skills/verification-before-completion/SKILL.md
rg "TDD compliance FAILED" adapters/cursor/.cursor/skills/verification-before-completion/SKILL.md
```

Expected: 三个匹配

- [ ] **Step 7: Commit**

```bash
git add adapters/cursor/.cursor/skills/verification-before-completion/SKILL.md
git commit -m "feat(harness-kit): verification-before-completion 增加 TDD 合规 gate"
```

---

## 验收（整体）

| # | 检查 | 命令 |
| --- | --- | --- |
| 1 | skill 目录完整 | `ls adapters/cursor/.cursor/skills/document-review/` |
| 2 | 审查规则包含环境准备 | `rg "环境准备|依赖管理|环境变量" adapters/cursor/.cursor/skills/document-review/review-rules/design.md` |
| 3 | 路由表更新 | `rg "document-review" core/routing.md` |
| 4 | 产物模板存在 | `test -f artifact-templates/document-review.md` |
| 5 | writing-plans TDD Enforcement | `rg "TDD Enforcement" ~/.agents/skills/writing-plans/SKILL.md` |
| 6 | verification TDD Compliance Gate | `rg "TDD Compliance Gate" adapters/cursor/.cursor/skills/verification-before-completion/SKILL.md` |

---

## 附录：TDD 强制执行方案

**背景：** Agent 经常忽略 TDD skill，先写代码再补测试，或者写完代码才"补"测试。根因是 TDD 是"建议"不是"门禁"，缺乏强制执行机制。

**解决方案：** 在 writing-plans 和 verification-before-completion 两个 skill 中加入硬性 gate。

### A. 加固 writing-plans（计划阶段强制 TDD）

**目标：** 计划中的每个任务必须是 TDD 结构，禁止先写代码后写测试。

**修改点：**

1. **新增 "TDD Enforcement" 章节**（Overview 之后）
   - 明确规则：每个任务 Step 1 必须是 "Write the failing test"
   - 禁止模式：Task 以实现代码开始、测试作为后续步骤、混合测试和实现
   - 测试质量要求：必须覆盖 happy path、edge cases、error cases

2. **修改 Plan Document Header**
   - 新增字段：`**TDD Required:** YES (every task follows RED-GREEN-REFACTOR)`

3. **修改 Task Structure 示例**
   - 强化说明：Step 1 永远是写失败的测试

4. **修改 No Placeholders 章节**
   - 新增禁止：Implementation code as Step 1、Test after implementation

5. **修改 Self-Review 章节**
   - 新增检查项 4：TDD compliance scan（检查每个任务的步骤顺序）

**文件：** `~/.agents/skills/writing-plans/SKILL.md`

### B. 加固 verification-before-completion（验证阶段 TDD 合规）

**目标：** 声称"完成"之前，必须证明走了 TDD 流程。不合规就拒绝声称完成。

**修改点：**

1. **新增 "TDD Compliance Gate" 章节**

```
TDD COMPLIANCE GATE (MANDATORY)
==============================

BEFORE claiming "done" or "complete", you MUST prove TDD compliance:

1. IDENTIFY what production code was written
2. CHECK git log for test-first commit pattern:
   - Test commit hash: [hash]
   - Code commit hash: [hash]  
   - Test commit is BEFORE code commit: YES/NO
3. VERIFY test quality:
   - Happy path covered: YES/NO
   - Edge cases covered (null/empty/boundary): YES/NO
   - Error cases covered: YES/NO
4. RUN full test suite to confirm all pass

If ANY check fails:
- State "TDD compliance FAILED" with evidence
- DO NOT claim completion
- Fix the issue first
```

2. **修改 Common Failures 表格**
   - 新增行：TDD 合规需要证明测试 commit 在代码 commit 之前

3. **修改 Red Flags 章节**
   - 新增：Git log shows code before tests

4. **修改 Key Patterns 章节**
   - 新增 TDD 合规验证模式：
     ```
     ✅ git log --oneline shows: test commit -> code commit -> verify commit
     ❌ git log --oneline shows: code commit -> test commit (tests after)
     ```

5. **修改 Rationalization Prevention 表格**
   - 新增行：
     | "Tests after achieve same goals" | Git log proves test-first. Tests-after = bias. |
     | "Already spent X hours, deleting is wasteful" | Sunk cost. Unverified code is debt. |

**文件：** `adapters/cursor/.cursor/skills/verification-before-completion/SKILL.md`

### C. 执行顺序

1. 先修改 writing-plans（计划阶段强制）
2. 再修改 verification-before-completion（验证阶段强制）
3. 两个 skill 配合形成闭环

### D. 验收标准

| # | 检查 | 命令 |
| --- | --- | --- |
| 1 | writing-plans 包含 TDD Enforcement 章节 | `rg "TDD Enforcement" ~/.agents/skills/writing-plans/SKILL.md` |
| 2 | writing-plans Self-Review 包含 TDD compliance scan | `rg "TDD compliance scan" ~/.agents/skills/writing-plans/SKILL.md` |
| 3 | verification-before-completion 包含 TDD Compliance Gate | `rg "TDD Compliance Gate" adapters/cursor/.cursor/skills/verification-before-completion/SKILL.md` |
| 4 | verification-before-completion 包含 git log 检查 | `rg "git log" adapters/cursor/.cursor/skills/verification-before-completion/SKILL.md` |

---

## Next

**（写入后须暂停，等用户明确继续 -- 见 `harness-kit/core/routing.md` S 阶段门禁）**

- 计划确认 -> 说「**开始实现**」或「**执行**」
- 需要调整 -> 直接说修改意见
- 想拆分并行 -> 说「**并行执行**」
