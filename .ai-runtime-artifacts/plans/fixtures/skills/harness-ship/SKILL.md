---
name: harness-ship; description: 发布阶段执行最终检查; stage: ship; triggers: [user-invocable, model-invocable]; flow_artifact_subdir: '{flow-id}'
---
# Harness Ship (Ship Stage)

## 步骤

1. 执行发布前最终检查清单
2. 验证环境配置与敏感信息隔离
3. 执行灰度发布或全量发布流程
4. 编写 `execution-logs/<flow-id>-ship.md` 记录发布日志

## FM 必填项

- 必须调用 `harness_artifact_write` 写入 `kind=execution` 到 `execution-logs/<flow-id>-ship.md`
- 模板变量：`{flow-id}` 需替换为实际 flow identifier
