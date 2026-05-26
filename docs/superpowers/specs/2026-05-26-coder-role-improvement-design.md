---
artifact: spec
title: "Coder角色改进：自检机制、测试分工与进度管理"
date: 2026-05-26
status: approved
platform: cursor
route: cursor-orchestration:dispatcher-workflow
---

## 背景与问题

当前Coder角色设计存在以下问题：

1. **自检机制不足**：Coder的自检主要是运行命令和检查清单，缺乏代码审查环节，可能导致代码质量问题在后期才被发现。

2. **测试分工不清晰**：前端自动化测试（如E2E测试）的职责边界不明确，可能导致测试覆盖不足或重复工作。

3. **进度管理流程不清晰**：Coder/Implementer更新plan文件，但Leader负责整合和验证，职责分工不够清晰。

## 目标

- 改进Coder自检机制，引入轻量级代码审查
- 明确测试分工，Coder只负责单元测试，Test Engineer负责所有其他测试
- 优化进度管理流程，Leader统一更新进度文件
- **保留并写清 Leader 收尾步骤**：任务（WU / GROUP）整合验证通过后，由 Leader 协调 `harness-reviewer` 做**集体独立审查**（与 Coder 自检审查分层，不互相替代）

## 非目标

- 不改变Harness的阶段门禁
- 不改变现有角色分工（Leader、Coder、Implementer、Test Engineer、Reviewer等）
- 不引入新的角色或工具（但允许Coder调用现有`harness-reviewer`进行轻量级审查）

## 设计方案

### 1. Coder自检机制改进

**当前设计：**
- Coder自检主要是运行命令和检查清单
- 自检项包括：对照spec/plan done criteria、错误路径与日志、单测、verification命令、无未关闭Critical/Important

**改进设计：**
- 在Coder自检阶段引入`requesting-code-review`技能
- Coder调用独立的reviewer实例进行轻量级审查（使用现有`harness-reviewer`角色，但审查深度为轻量级）
- 审查重点：代码规范、最佳实践、潜在bug（不涉及架构、性能、安全性等深度审查）
- 审查结果作为自检的一部分

**具体实现：**

1. **修改Coder自检流程**：
   - 在Coder自检阶段，调用`requesting-code-review`技能
   - 审查范围：当前WU的代码变更
   - 审查深度：轻量级（代码规范、最佳实践、潜在bug）
   - 审查标准：
     - 代码规范：符合项目编码规范（如有）
     - 最佳实践：遵循语言/框架最佳实践
     - 潜在bug：明显的逻辑错误、空指针、边界条件等
   - 审查结果作为自检的一部分

2. **修改Coder返回格式**：
   - 在"开发者自检"部分增加"代码审查"字段
   - 包含审查结果、发现的问题、修复状态

3. **修改Coder自检项**：
   - 增加"代码审查通过"作为自检项
   - 审查未通过不得报完成

**示例返回格式：**
```markdown
### 开发者自检
- self_check: PASS | FAIL
- open_items: ...
- skip_reviewer_eligible: yes | no
- test_exempt: 无 | <理由>
- code_review: PASS | FAIL
- review_issues: 无 | [Critical/Important] ...
- review_fix_status: 已修复 | 未修复 | 部分修复
```

### 2. 测试分工明确化

**当前设计：**
- Coder负责单测和自测（运行verification命令）
- Test Engineer负责测试/E2E测试
- Leader运行最小验证集

**改进设计：**
- Coder只负责单元测试
- Test Engineer负责所有其他测试（E2E、集成测试、前端组件测试）
- 边界情况由Leader在派发时指定

**具体实现：**

1. **明确Coder职责**：
   - Coder只负责单元测试
   - 不负责E2E测试、集成测试、前端组件测试
   - 自测仅限于运行verification命令（单元测试相关）

2. **明确Test Engineer职责**：
   - 负责所有其他测试（E2E、集成测试、前端组件测试）
   - 包括前端自动化测试
   - 负责测试环境搭建和维护

3. **边界情况处理**：
   - Leader在派发时明确指定测试类型
   - 如果测试类型不明确，Leader应先澄清
   - 对于混合类型测试，由Leader决定由谁负责

**职责划分表：**

| 测试类型 | 负责角色 | 说明 |
|---------|---------|------|
| 单元测试 | Coder | 代码级别的测试 |
| E2E测试 | Test Engineer | 端到端测试 |
| 集成测试 | Test Engineer | 模块间集成测试 |
| 前端组件测试 | Test Engineer | 前端组件的测试 |
| 性能测试 | Test Engineer | 性能相关测试 |
| 安全测试 | Test Engineer | 安全相关测试 |

### 3. 进度管理流程优化

**当前设计：**
- Coder/Implementer在plan文件中将对应项`- [ ]`改为`- [√]`
- Leader整合WU结果时对照plan文件
- 文档明确禁止：仅在Agent回复里列出`[√]`充当"已完成"记录

**改进设计：**
- Coder/Implementer只报告完成状态（不更新plan文件）
- Leader统一更新plan文件（打勾）和tracking文件
- 流程：Coder报告完成 → Leader验证 → Leader更新进度

**具体实现：**

1. **修改Coder/Implementer返回格式**：
   - 移除"计划勾选同步"部分
   - 增加"完成状态"字段
   - 明确报告WU是否完成

2. **修改Leader整合流程**：
   - Leader在整合WU结果时，更新plan文件（打勾）
   - Leader更新tracking文件
   - Leader验证Coder/Implementer的完成状态

3. **修改进度管理流程**：
   - Coder/Implementer返回完成状态
   - Leader验证完成状态
   - Leader更新plan文件（打勾）
   - Leader更新tracking文件

**单 WU 进度（Leader 写入）：**
1. Coder/Implementer 完成 WU，返回完成状态（**不**改 plan）
2. Leader 验证该 WU（代码、单测/验证摘要、Coder 轻量审查结果）
3. Leader 将 plan 中**本 WU 对应项** `- [ ]` → `- [√]`，并 append `tracking/DISPATCH-TRACK-*.md`

**GROUP / 交付批次收尾（须含集体审查，见 §4）：** plan 勾选与 tracking 可在单 WU 验证后逐步更新，但**不得**在集体审查未通过（或未合法跳过）前对外声称本 GROUP / 本批次交付完成。

### 4. Leader 收尾：整合验证与 Reviewer 集体审查

**有，且必须保留。** 本改进**不取消**原 `2026-05-26-coder-role-design.md` 与 `dispatcher-workflow.md` 中的审查门禁；仅与 Coder 轻量自检**分层**。

| 层级 | 时机 | 执行方 | 深度 | 作用 |
| --- | --- | --- | --- | --- |
| **WU 自检审查** | 单 WU 完成前 | Coder（`requesting-code-review` + 独立 reviewer 实例） | 轻量：规范、最佳实践、明显 bug | 开发者自检硬门槛；**不能**替代终审 |
| **集体独立审查** | WU 整合 + 最小验证集之后 | Leader 委派 **`harness-reviewer`**（与实现 Coder **不同实例**） | 五轴 / spec+plan done criteria | 交付前质量门禁；`APPROVE` \| `BLOCK` |

**Leader 在任务（通常为一个 GROUP 或 plan 中一批相关 WU）完成后的顺序：**

1. **收集** 本批次所有 WU 返回（含 Coder `self_check`、`code_review`、Test Engineer 验证摘要）。
2. **整合**：处理文件冲突；对照 plan 与实现是否一致。
3. **验证**：运行 `harness-kit/project.verification.md` 最小验证集；若 plan 要求集成/E2E，先完成或委派 `harness-test-engineer` 对应 WU，再进入审查。
4. **审查门禁**（Leader 协调 Reviewer）：
   - 满足「小 WU 跳过 Reviewer」**全部**条件时，Leader 可跳过 `harness-reviewer`，须在 execution-log 记录理由与依据（沿用原 spec）。
   - 否则 Leader **必须**委派 `harness-reviewer`，prompt 覆盖**本批次整合后的变更面**（非仅最后一个 WU），对照 spec/plan done criteria + 各 WU 验证摘要；结论仅 `APPROVE` \| `BLOCK`。
5. **`BLOCK`**：开 `review-fix` WU 派 Coder 修复，修复后回到步骤 1–4（无需重复已通过 WU 的实现，除非冲突）。
6. **`APPROVE` 或合法跳过**：Leader 确认 plan / CHECKLIST 与验收一致；写 execution-log；对甲方汇报（含是否经 Reviewer、跳过理由）。

**与 Coder 轻量审查的关系：**

- Coder `code_review: PASS` **不**等于可跳过步骤 4 的集体审查（除非同时满足原 spec 全部「可跳过 Reviewer」条件）。
- 集体审查实例**不得**与执行该批次任一 Coder WU 的 subagent 为同一实例。

**集体审查 Prompt 要点（Leader 派发，摘要）：**

- 声明：未参与本批次实现；只读。
- 范围：本 GROUP / 批次涉及的文件与 done criteria（可附 git 范围或文件列表）。
- 输入：spec/plan 摘录、各 WU 返回、最小验证集结果、Test Engineer 摘要（如有）。
- 输出：`APPROVE` \| `BLOCK`；BLOCK 须列未关闭 Critical/Important。

## 需要的变更清单

### 文档变更

1. **更新`orchestration/agents/coder.md`**：
   - 修改Coder自检流程，引入代码审查
   - 修改Coder返回格式，增加代码审查字段
   - 移除"计划勾选同步"部分
   - 增加"完成状态"字段

2. **更新`docs/superpowers/specs/2026-05-26-coder-role-design.md`**：
   - 修改Coder自检机制描述
   - 修改测试分工描述
   - 修改进度管理流程描述

3. **更新`orchestration/agents/test-engineer.md`**：
   - 明确Test Engineer职责范围
   - 增加前端组件测试等职责

4. **更新`orchestration/dispatcher-workflow.md`**：
   - 修改 Leader 整合流程（单 WU 进度由 Leader 写 plan / tracking）
   - **显式保留**步骤 3 审查门禁与 Leader 委派 `harness-reviewer` 集体审查（与 Coder 轻量自检分层说明）

5. **更新`orchestration/agents/leader.md`**：
   - 增加收尾链：整合 → 验证 →（可选 Test Engineer）→ Reviewer 集体审查 → 更新 execution-log / 对甲方汇报

6. **更新`orchestration/runtime/plan-progress-sync.md`**：
   - 修改进度同步流程
   - 明确Leader的职责

### 投影文件变更

1. **更新`.cursor/agents/harness-coder.md`**：
   - 同步Coder角色变更

2. **更新`.cursor/agents/harness-test-engineer.md`**：
   - 同步Test Engineer角色变更

### 其他变更

1. **更新README.md**：
   - 更新角色职责表
   - 更新测试分工说明

## 风险与缓解

### 风险1：Coder自检引入代码审查可能影响效率
**缓解措施：**
- 审查深度为轻量级，主要检查代码规范、最佳实践、潜在bug
- 审查时间控制在合理范围内
- 如果审查时间过长，可以调整审查范围

### 风险2：测试分工调整可能导致测试覆盖不足
**缓解措施：**
- 明确Test Engineer职责范围
- Leader在派发时明确指定测试类型
- 增加测试验证环节

### 风险3：进度管理流程调整可能增加Leader工作量
**缓解措施：**
- 优化Leader整合流程
- 提供自动化工具支持（如脚本更新plan文件）
- 增加Leader的职责说明和培训

## 验收标准

- 文档明确：Coder自检机制、测试分工、进度管理流程、**Leader 收尾集体审查门禁**（含与 Coder 轻量审查的分层、跳过规则、BLOCK 后 review-fix 回路）
- 提示词可落地：含 Leader→Coder/Implementer 标准模板、Leader→Reviewer 集体审查要点、派发前自检表
- 给出实现需要改动的文件清单（可直接转为实现计划）
- 流程清晰：Coder 自检审查 → 单 WU Leader 写进度 → 批次整合验证 → Reviewer 集体审查 → 交付

## 后续步骤

1. 用户审查本spec
2. 根据反馈修改spec
3. 编写实现计划
4. 实施变更
5. 验证变更效果