---
name: harness-verify; description: 验证阶段执行测试套件; stage: verify; triggers: [user-invocable, model-invocable]; flow_artifact_subdir: '{flow-id}'
---
# Harness Verify (Verify Stage)

## 步骤

1. 读取 WU 实现的产出物，确认测试就绪
2. 执行单元测试、集成测试、端到端测试
3. 对照 definition-of-done 检查清单逐项验证
4. 编写 `verifications/<flow-id>-verification.md` 记录验证结果

## FM 必填项

- 必须调用 `harness_artifact_write` 写入 `kind=verification` 到 `verifications/<flow-id>-verification.md`
- 模板变量：`{flow-id}` 需替换为实际 flow identifier
