---
name: harness-spec; description: 设计阶段产出技术规格; stage: design; triggers: [user-invocable, model-invocable]; flow_artifact_subdir: '{flow-id}'
---
# Harness Spec (Design Stage)

## 步骤

1. 基于需求澄清文档进行技术方案设计
2. 定义系统架构、模块边界与核心接口契约
3. 编写详细技术规格文档到 `specs/<flow-id>-design.md`
4. 组织设计评审，收集反馈并迭代

## FM 必填项

- 必须调用 `harness_artifact_write` 写入 `kind=spec` 到 `specs/<flow-id>-design.md`
- 模板变量：`{flow-id}` 需替换为实际 flow identifier
