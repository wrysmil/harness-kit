---
name: harness-brief; description: 需求澄清阶段; stage: clarify; triggers: [user-invocable, model-invocable]; flow_artifact_subdir: '{flow-id}'
---
# Harness Brief (Clarify Stage)

## 步骤

1. 读取 `interview-me` 的输出结果，获取用户原始需求的完整上下文
2. 按 harness-kit 澄清模板对需求进行结构化分解
3. 输出结构化需求澄清文档到 `specs/intent.md`
4. 确认需求完整性，必要时触发二次 interview

## FM 必填项

- 必须调用 `harness_artifact_write` 写入 `kind=spec` 到 `specs/intent.md`
- 模板变量：`{flow-id}` 需替换为实际 flow identifier
