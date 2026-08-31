# Harness-Kit 提示词综合分析报告

> 分支: `feat/prompt-minification`
> 分析日期: 2026-08-31
> 分析方法: 并行 4 子 Agent 多维度扫描

---

## 一、精简潜力评估

### 总体预估：可浓缩 **12-19%**

### 可精简内容模式

| 模式 | 涉及文件 | 预估节省 |
|------|---------|---------|
| 过度重复的「Common Rationalizations」表格 | systematic-debugging, verification-before-completion 等 | ~150 行 |
| 过度的代码示例 | security-and-hardening, performance-optimization 等 | ~200 行 |
| 详细的表格和清单 | shipping-and-launch, code-review-and-quality 等 | ~200 行 |
| 冗余的「Red Flags」和「Anti-Patterns」 | 几乎所有 skills | ~100 行 |
| 格式冗余 | routing.md 等核心文件 | ~100 行 |

### 精简优先级

| 优先级 | 文件 | 当前行数 | 可精简% |
|--------|------|---------|---------|
| 高 | `security-and-hardening/SKILL.md` | 363 | 20-25% |
| 高 | `test-driven-development/SKILL.md` | 280 | 15-20% |
| 高 | `code-review-and-quality/SKILL.md` | 279 | 15-20% |
| 中 | `performance-optimization/SKILL.md` | 282 | 20-25% |
| 中 | `shipping-and-launch/SKILL.md` | 241 | 20-25% |
| 中 | `code-simplification/SKILL.md` | 263 | 20-25% |

---

## 二、缺陷设计识别

### 高影响缺陷（12 项）

| 缺陷 | 文件 | 问题 |
|------|------|------|
| Skill 缺失 | `routing.md` L9, L115-137 | 引用 `brainstorming` 和 `writing-plans` 但文件不存在 |
| Adapter 绑定缺失 | `dispatcher-workflow.md` L185 | `adapters/*/bindings.md` 全部缺失 |
| Collective-test 职责不清 | `dispatcher-workflow.md` vs `leader.md` | Leader 亲自跑命令 vs 派发测试任务？ |
| Subagent readonly 无保证 | `claude-continuous-loop.md` L19 | prompt 级无法强制只读 |
| 文件路径引用错误 | `.agents/agents/coder.md` L8 | 相对路径无法解析 |
| Reference 文件缺失 | `routing.md` L259-271 | `references/` 目录不存在 |
| 紧急场景无路由 | `routing.md` 路由表 | "线上挂了"无明确路由 |
| PR Review 场景无路由 | `routing.md` 路由表 | "帮我 review PR" 无明确路由 |
| Tier 边界模糊 | `routing.md` § Tier 0/1 | "写文件"未定义 |
| 同轮时间窗口未定义 | `routing.md` § 同轮禁止 | "同轮"定义不清 |
| 阶段门禁继续条件模糊 | `routing.md` § 阶段门禁 | "已批准"定义不清 |
| Context Pack 执行者不明 | `dispatcher-workflow.md` §0.5 | Tier 1 时谁执行 Self-Context Pack？ |

### 中影响缺陷（20 项）

- `source-driven-development` 与 `dispatcher-workflow.md` 上下文打包定义冲突
- Worktree 初始化条件冲突
- Coder 自我审查范围冲突
- WUU 边界条件模糊
- 混合任务场景无路由
- Skill 禁用列表过于武断

---

## 三、未使用的设计

### 孤立文档

| 文件 | 状态 |
|------|------|
| `docs/superpowers/` | 旧文档，AGENTS.md 已标记禁止使用 |
| `git-xywh/技能审查报告v1.md` | 未被 SKILL.md 引用 |
| `git-xywh/技能审查报告v2.md` | 未被 SKILL.md 引用 |

### 缺失 Skill（被引用但不存在）

| Skill | 引用位置 |
|-------|---------|
| `dispatching-parallel-agents` | 多份文档 |
| `subagent-driven-development` | 多份 plan 文件 |
| `using-superpowers` | `coder.md` 禁止列表 |
| `trae-orchestration` | `.agents/README.md` |

### 未被 routing.md 引用的现有 Skill

| Skill | 现状 |
|-------|------|
| `frontend-design` | 存在于 `.agents/skills/`，但 routing.md 无路由 |
| `github` | 存在于 `.agents/skills/`，但 routing.md 无路由 |

---

## 四、专业性不足的提示词

### 评分分布

| 评分 | 文件数 | 代表文件 |
|------|--------|---------|
| 4.5+ (优秀) | 3 | `systematic-debugging`, `test-driven-development`, `code-review-and-quality` |
| 3.5-4.4 (良好) | 8 | `verification-before-completion`, `source-driven-development` 等 |
| 3.0-3.4 (一般) | 9 | `dispatcher-workflow.md`, `leader.md`, `ai-entry.md` 等 |
| <3.0 (薄弱) | 3 | `implementer.md`(3.0), `test-engineer.md`(2.5), `artifact-templates/plan.md`(2.0) |

### 关键问题

1. **术语不一致**：WU/任务/工作单元混用
2. **上下文分散**：薄文件依赖大量外部引用
3. **可操作性参差**：优秀 skill 4.8 分，薄弱仅 2.5 分
4. **返回格式不统一**：各 Agent 返回格式差异大
5. **缺少错误处理指导**：大多数文件无异常场景说明

### 优先改进目标

| 文件 | 当前 | 目标 | 改进点 |
|------|------|------|--------|
| `test-engineer.md` | 2.5 | 4.0 | 增加测试策略、覆盖率标准 |
| `implementer.md` | 3.0 | 4.0 | 增加具体执行步骤 |
| `artifact-templates/plan.md` | 2.0 | 3.5 | 完全重写或删除 |

---

## 五、建议行动计划

### 第一阶段：立即清理

1. 删除或归档 `docs/superpowers/` 目录
2. 删除 `git-xywh/技能审查报告v*.md`
3. 补充缺失的 `brainstorming` 和 `writing-plans` skill，或从路由表移除引用

### 第二阶段：精简优化

1. `routing.md` 精简为核心决策树 + 附录（目标：300行→150行）
2. 合并重复的 Rationalization 表格到共享参考
3. 代码示例精简：每种语言保留 1-2 个核心示例

### 第三阶段：专业性提升

1. 增强薄弱的 Agent 文件（test-engineer, implementer）
2. 统一术语表和返回格式
3. 增加错误处理指导
