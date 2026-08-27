---
name: harness-coda; description: 收尾阶段进行项目复盘; stage: coda; triggers: [user-invocable, model-invocable]; flow_artifact_subdir: '{flow-id}'
---
# Harness Coda (Coda Stage)

## 步骤

1. 收集各阶段产出与执行数据
2. 复盘整个流程：效率、阻塞点、改进机会
3. 总结最佳实践与踩坑记录
4. 编写 `retros/<flow-id>-retro.md` 记录复盘结果

## FM 必填项

- 必须调用 `harness_artifact_write` 写入 `kind=retro` 到 `retros/<flow-id>-retro.md`
- 模板变量：`{flow-id}` 需替换为实际 flow identifier
