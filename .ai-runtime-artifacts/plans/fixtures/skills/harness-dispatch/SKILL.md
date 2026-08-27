---
name: harness-dispatch; description: 执行阶段编排多 WU 并行; stage: implement; triggers: [user-invocable, model-invocable]; flow_artifact_subdir: '{flow-id}'
---
# Harness Dispatch (Implement Stage)

## 步骤

1. 读取 `plans/<flow-id>-dispatch.md` 获取调度策略
2. 按依赖关系并行派发多个 WU 任务
3. 监控各 WU 执行状态，处理完成与异常
4. 汇总 WU 产出，更新 dispatch 文档中的执行记录

## FM 必填项

- 必须调用 `harness_artifact_write` 写入 `kind=plan` 到 `plans/<flow-id>-dispatch.md`
- 模板变量：`{flow-id}` 需替换为实际 flow identifier
