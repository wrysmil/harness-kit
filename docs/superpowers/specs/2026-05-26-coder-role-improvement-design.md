---
artifact: spec
title: "Coder角色改进：自检机制、测试分工与进度管理"
date: 2026-05-26
status: draft
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

**新流程：**
1. Coder/Implementer完成WU，返回完成状态
2. Leader验证完成状态（检查代码、测试结果等）
3. Leader更新plan文件（将对应项`- [ ]`改为`- [√]`）
4. Leader更新tracking文件（append状态行）

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
   - 修改Leader整合流程
   - 增加Leader更新进度文件的步骤

5. **更新`orchestration/runtime/plan-progress-sync.md`**：
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

- 文档明确：Coder自检机制、测试分工、进度管理流程
- 提示词可落地：含Leader→Coder/Implementer标准模板、派发前自检表
- 给出实现需要改动的文件清单（可直接转为实现计划）
- 流程清晰：Coder自检流程、测试分工流程、进度管理流程

## 后续步骤

1. 用户审查本spec
2. 根据反馈修改spec
3. 编写实现计划
4. 实施变更
5. 验证变更效果