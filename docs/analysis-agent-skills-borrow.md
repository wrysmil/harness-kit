# Agent-Skills → Harness-Kit 能力借鉴分析

> 分析日期: 2026-06-29
> 分析范围: agent-skills (addyosmani/agent-skills) 24 skills + 4 agents vs harness-kit 现有能力

---

## 一、总览：差距热力图

| 能力域 | harness-kit 现状 | agent-skills 现状 | 差距 | 优先级 |
|--------|-----------------|-------------------|------|--------|
| **代码审查** | 五轴审查 + 双层体系 | 五轴审查 + 严重级标签 + 变更尺寸 + 结构疗法 + 死代码卫生 | 中 | 🔴 高 |
| **代码简化** | 无 | 专用技能，Chesterton's Fence，Rule of 500 | 大 | 🟡 中 |
| **对抗性审查** | 无 | doubt-driven-development，跨模型升级 | 大 | 🔴 高 |
| **安全审查** | Reviewer 五轴之一 | 独立技能 + 独立 agent + OWASP全量 + LLM Top 10 | 大 | 🔴 高 |
| **测试策略** | TDD + test-engineer agent | TDD + Prove-It + browser-devtools + testing-patterns参考 | 中 | 🟡 中 |
| **调试方法** | systematic-debugging skill | debugging-and-error-recovery + Stop-the-Line | 小 | 🟢 低 |
| **浏览器测试** | browser-testing-with-devtools skill | browser-testing-with-devtools + DevTools MCP 全量（已替代 agent-browser） | 中 | 🟢 低 |
| **完成定义** | verification-before-completion | definition-of-done.md (5段20+检查项) | 中 | 🔴 高 |
| **反合理化表** | 无 | 每个 skill 内建防跳过机制 | 大 | 🔴 高 |
| **编排模式** | dispatch + parallel + collective | parallel fan-out + merge + 模式/反模式文档 | 小 | 🟡 中 |
| **规约驱动** | brainstorming + writing-plans | spec-driven-development 四阶段门控 | 中 | 🟡 中 |
| **任务拆解** | plan 模板 | planning-and-task-breakdown (XS-XL尺寸+垂直切片) | 中 | 🟡 中 |
| **可观测性** | 无 | observability-and-instrumentation (RED/USE/症状告警) | 大 | 🟢 低 |
| **CI/CD** | 无 | ci-cd-and-automation (质量门+GH Actions+CI反馈) | 大 | 🟢 低 |
| **发布上线** | 无 | shipping-and-launch (特性开关+阶段铺开+回滚) | 大 | 🟢 低 |
| **上下文工程** | context-budget.md (40%规则) | context-engineering (结构化上下文管理) | 中 | 🟡 中 |
| **Skill 结构标准化** | 不一致 | Skill Anatomy 标准格式 + 退出条件检查表 | 大 | 🔴 高 |

---

## 二、审查能力：最值得借鉴的 5 项

### 2.1 严重级标签体系 (agent-skills → harness-kit Reviewer)

**现状对比：**

| 维度 | harness-kit Reviewer | agent-skills code-review-and-quality |
|------|---------------------|--------------------------------------|
| 严重级 | Critical / Important / Suggestion / Nit | (无前缀)=必须 / **Critical:**=阻断合并 / **Nit:** / **Optional:** / **FYI** |
| 变更尺寸 | 无 | ~100行理想，~300可接受，~1000+必须拆分 |
| 结构疗法 | 无 | 命名重构模式（替换条件式、折叠分支、分离编排与逻辑...） |
| 死代码卫生 | 无 | 重构后强制识别孤儿代码 |

**建议借鉴：**
1. 在 `core/orchestration/agents/reviewer.md` 中引入标签式严重级（`Critical:` / `Nit:` / `Optional:`）
2. 在 Reviewer 提示中增加变更尺寸意识 — 超过 ~300 行时主动建议拆分
3. 增加"结构疗法"清单：Reviewer 不仅发现问题，还应给出可操作的重构模式名称
4. 重构后自动触发孤儿代码检查

### 2.2 反合理化表 (Anti-Rationalization Table) — 全 Skill 通用

这是 agent-skills **最独特的设计模式**。每个 SKILL.md 包含一张表：

```markdown
| Rationalization | Reality |
|----------------|---------|
| "This is too small to need a test" | Small changes cause the most regressions |
| "I'll add tests later" | Later never comes |
| "The tests pass, so it's done" | Passing tests != correct tests |
```

**harness-kit 应该做的事：**
- 在每个 Reviewer/TestEngineer/Coder 代理定义中嵌入反合理化表
- 在 `verification-before-completion` skill 中增加防跳过检查表
- Leader 关闭阶段应检查常见合理化借口

### 2.3 退出条件检查表 (Verification Checklist as Exit Criteria)

agent-skills 的每个 skill 末尾都有具体证据清单：
```markdown
## Verification
- [ ] All new functions/types have JSDoc comments
- [ ] Test coverage ≥ 80% on changed files
- [ ] No console errors in browser DevTools
- [ ] CI pipeline is green
```

**harness-kit 应该做的事：**
- 将 `verification-before-completion` 从笼统原则升级为分角色检查表
- Coder 完成时：单元测试通过 + 自检通过 + Reviewer PASS
- TestEngineer 完成时：集成/E2E 命令实际执行通过
- Leader 关闭时：集体测试 PASS + 集体审查 APPROVE/SKIPPED + execution-log 完整

### 2.4 代码简化 Skill (code-simplification)

harness-kit 完全没有这个能力。agent-skills 提供了：

- **Chesterton's Fence**: 不理解为什么存在就不要删除
- **Rule of 500**: 超过500行的重构必须用自动化工具
- **增量应用**: 一次一个简化，每次改后测试
- **语言特定指导**: TS/JS, Python, React/JSX 的具体模式

**建议：** 创建 `code-simplification` skill 和 `/code-simplify` 命令

### 2.5 对抗性怀疑驱动开发 (Doubt-Driven Development)

这是 agent-skills 最创新的能力之一，harness-kit 完全没有：

```
CLAIM → EXTRACT (artifact + contract) → DOUBT (fresh-context adversarial reviewer) → RECONCILE (classify findings) → STOP (max 3 cycles)
```

核心特点：
- **非事后审查** — 在决策当下就进行对抗性审查
- **跨模型升级** — 总是提供不同模型的第二意见
- **反怀疑表演检测** — 2+ 轮中 reviewer 提出实质性发现但零个被分类为可操作 → 你是在验证不是怀疑，停止并升级

**建议：** 这对 harness-kit 的编排模型是**自然增强** — Leader 可以在关键决策点触发 Doubt 循环

---

## 三、测试能力：最值得借鉴的 4 项

### 3.1 Prove-It Pattern（证明模式）

agent-skills 版本比 harness-kit 的 TDD 更严格：

```
harness-kit TDD: 写测试 → 写代码 → 重构
agent-skills Prove-It: 复现Bug → 写失败测试 → 确认失败 → 修复 → 确认通过
```

**建议：** 在 `test-driven-development` skill 中显式增加 Prove-It 子流程

### 3.2 Browser-Testing-with-DevTools

harness-kit 已用 `browser-testing-with-devtools` 替代 `agent-browser`：

| 能力 | harness-kit browser-testing-with-devtools | agent-skills browser-testing-with-devtools |
|------|--------------------------|-------------------------------------------|
| 截图 | ✓ | ✓ |
| DOM 检查 | - | ✓ |
| 控制台日志 | - | ✓ (零错误标准) |
| 网络监控 | - | ✓ |
| 性能追踪 | - | ✓ |
| 无障碍树 | - | ✓ |
| 安全边界 | 无 | 严格（浏览器内容=不信任数据） |
| Profile 隔离 | 无 | 独立 Chrome Profile |

**已完成：** `agent-browser` 已被 `browser-testing-with-devtools` 完整替代，含 DevTools 深度集成和安全边界模型

### 3.3 Testing Patterns 参考文档

agent-skills 有 `references/testing-patterns.md`，包含：
- Arrange-Act-Assert 示例
- 命名约定
- Mock 层次（真实实现 > Fake > Stub > Mock）
- React 组件测试模式
- 反模式表（10种）

**建议：** 在 harness-kit 中创建 `references/testing-patterns.md`

### 3.4 Definition of Done (完成定义)

agent-skills 区分了：
- **Acceptance Criteria**（每任务）：我们造对东西了吗？
- **Definition of Done**（常设标准）：这东西准备好了吗？

5段20+检查项：正确性 → 质量 → 集成 → 文档 → 发布就绪

**建议：** 将 `verification-before-completion` 升级为包含 DoD 检查表

---

## 四、编排能力：最值得借鉴的 4 项

### 4.1 Parallel Fan-Out with Merge（并行扇出合并）

agent-skills 的 `/ship` 命令模式：

```
/ship → spawn code-reviewer ─┐
       → spawn security-auditor ├→ merge reports → go/no-go
       → spawn test-engineer  ─┘
```

harness-kit 的 `collective-closeout` 是两阶段串行（先 collective-test 再 collective-review）。agent-skills 的 merge 模式可以让审查 + 安全 + 测试同时跑。

**建议：** 增加并行扇出 + 合并阶段，允许 Leader 同时发起多个独立审查

### 4.2 编排模式文档化

agent-skills 有 `references/orchestration-patterns.md`：
- 5 种认可模式：直接调用、单角色命令、并行扇出合并、顺序流水线、研究隔离
- 4 种反模式：路由角色、角色调角色、顺序编排者复述、深层角色树
- 决策流程图

**建议：** 创建 `references/orchestration-patterns.md` 记录 harness-kit 自身的编排模式与反模式

### 4.3 规约驱动开发 (Spec-Driven Development)

agent-skills 的四阶段门控：

```
Specify → [人工审查] → Plan → [人工审查] → Tasks → [人工审查] → Implement
```

- 6 个核心规约区：目标、命令、项目结构、代码风格、测试策略、边界
- 三级边界系统：始终做 / 先问 / 永远不做
- 将模糊指令重构为成功标准
- 立即表面假设

harness-kit 有 `brainstorming` + `writing-plans` 但缺少中间规约层。**规约是比计划更高层的"为什么"和"边界是什么"**。

**建议：** 在 brainstorming 和 writing-plans 之间增加 `spec-driven-development` 门控

### 4.4 任务尺寸和垂直切片

agent-skills 的 `planning-and-task-breakdown`:
- XS (1文件) → S (2-3) → M (4-5) → L (6-7) → XL (8+必须拆分)
- 垂直切片：一次构建一条完整的特性路径
- 每 2-3 个任务设置检查点
- 计划文档模板：概览 → 架构决策 → 按阶段的任务列表 → 风险/缓解 → 开放问题

**建议：** 增强 harness-kit 的 plan 模板，加入任务尺寸量化和垂直切片指导

---

## 五、安全能力：一个重大缺口

harness-kit 的 Reviewer 将安全作为五轴之一，但 agent-skills 有：

1. **独立 security-auditor agent** — 专注安全的独立角色
2. **security-and-hardening skill** — 完整的安全强化工作流
3. **OWASP Top 10 全覆盖** (Web + LLM)
4. **威胁建模** — STRIDE per trust boundary
5. **SSRF 防御代码** — DNS解析 + IP范围检查
6. **npm audit 分类决策树**
7. **供应链卫生** — lockfile, npm ci, typosquat
8. **密钥管理** — .env 文件层次, pre-commit 扫描
9. **三级边界系统** — 始终做(10项) / 先问(8项) / 永不做(7项)

**建议：**
- 将 security-auditor 升级为独立 agent（当前只是 reviewer 的一个方面）
- 创建 `security-and-hardening` skill
- 在 collective-closeout 中增加安全审计阶段

---

## 六、Skill 结构标准化：最根本的改进

agent-skills 有明确的 **Skill Anatomy** 规范（`docs/skill-anatomy.md`）：

```markdown
---
name: skill-name
description: 何时使用的触发描述
---

## Overview
## When to Use
## Core Process
### Step 1: ...
### Step 2: ...
## Common Rationalizations (反合理化表)
## Red Flags
## Verification (退出条件检查表)
```

harness-kit 的 skills 格式不统一。**建议：** 制定 harness-kit 的 Skill Anatomy 标准并迁移现有 skills。

---

## 七、优先级实施路线图

### 🔴 Phase 1 — 立即高收益（1-2周）

| 改动 | 借鉴来源 | 影响范围 |
|------|---------|---------|
| 1. 审查严重级标签 + 变更尺寸意识 | code-review-and-quality | `reviewer.md` agent |
| 2. 反合理化表嵌入核心 agents | 所有 agent-skills | coder, reviewer, test-engineer, leader |
| 3. 退出条件检查表升级 | 所有 agent-skills | `verification-before-completion` skill |
| 4. Definition of Done 检查表 | definition-of-done.md | `verification-before-completion` skill |
| 5. Skill 结构标准化 | skill-anatomy.md | 全局 skills |

### 🟡 Phase 2 — 中期增强（2-4周）

| 改动 | 借鉴来源 | 影响范围 |
|------|---------|---------|
| 6. 独立 security-auditor agent | security-and-hardening + security-auditor | 新 agent + skill |
| 7. Doubt-Driven Development 集成 | doubt-driven-development | Leader 编排逻辑 |
| 8. Spec-Driven Development 门控 | spec-driven-development | brainstorming → plan 之间 |
| 9. 任务尺寸量化 + 垂直切片 | planning-and-task-breakdown | plan 模板 |
| 10. 并行扇出合并模式 | /ship command pattern | collective-closeout 逻辑 |

### 🟢 Phase 3 — 长期完善（4-8周）

| 改动 | 借鉴来源 | 影响范围 |
|------|---------|---------|
| 11. Code Simplification skill | code-simplification | 新 skill + 命令 |
| 12. 浏览器测试 DevTools 深度集成 | browser-testing-with-devtools | 已完成（替换 agent-browser） |
| 13. Testing Patterns 参考文档 | testing-patterns.md | 新 references/ |
| 14. 编排模式/反模式文档 | orchestration-patterns.md | 新 references/ |
| 15. 可观测性 instrumentation | observability-and-instrumentation | 新 skill |
| 16. CI/CD 质量门 | ci-cd-and-automation | 新 skill |

---

## 八、关键设计决策建议

### 决策 1：agent-skills 是直接引用还是重新实现？

**建议：重新实现**，原因：
- harness-kit 有自己的编排模型（Leader/WU/worktree），不能直接套用 agent-skills 的命令体系
- agent-skills 的 Skill 是面向"单个 Agent 内执行"的，harness-kit 的 Skill 是面向"多 Agent 编排"的
- 但可以**大量借鉴内容和结构**

### 决策 2：反合理化表如何嵌入？

**建议：** 在每个 agent 定义文件中嵌入角色特定的反合理化表，而非创建独立 skill。例如 `reviewer.md` 应有审查特定的合理化借口及反驳。

### 决策 3：Doubt-Driven Development 如何适配？

agent-skills 明确说 Doubt 是编排者 skill，"不能在子代理角色内运行"。这与 harness-kit 的 Leader 角色天然对齐 — Leader 在关键决策点（plan 生成后、重大重构前）启动 Doubt 循环。

---

## 九、总结

agent-skills 对 harness-kit 最大的价值不在于具体代码或命令，而在于**三个设计模式 + 两个内容资产**：

**三个设计模式：**
1. **反合理化表** — 防止 Agent 跳过关键步骤的最有效机制
2. **退出条件检查表** — 将"看起来对了"变成"有证据证明对了"
3. **怀疑驱动开发** — 将对抗性审查从事后移到事中

**两个内容资产：**
1. **安全审查的完整深度** — OWASP + LLM Top 10 + 威胁建模 + SSRF防御代码
2. **审查的严重级标签 + 变更尺寸 + 结构疗法** — 让审查从"发现问题"升级到"给出可操作的改进路径"
