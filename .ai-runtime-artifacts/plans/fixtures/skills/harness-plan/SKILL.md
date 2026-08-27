---
name: harness-plan; description: 计划阶段产出执行计划; stage: plan; triggers: [user-invocable, model-invocable]; flow_artifact_subdir: '{flow-id}'
---
# Harness Plan (Plan Stage)

## 步骤

1. 基于设计文档拆解实现计划
2. 识别 WU (Work Unit) 单元，定义依赖关系
3. 编写 `plans/<flow-id>-plan.md` 包含里程碑与时间线
4. 编写 `plans/<flow-id>-dispatch.md` 包含调度策略

## FM 必填项

- 必须调用 `harness_artifact_write` 写入 `kind=plan` 到 `plans/<flow-id>-plan.md`
- 必须调用 `harness_artifact_write` 写入 `kind=plan` 到 `plans/<flow-id>-dispatch.md`
