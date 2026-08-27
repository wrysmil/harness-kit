---
name: harness-review; description: 审查阶段进行代码审查; stage: review; triggers: [user-invocable, model-invocable]; flow_artifact_subdir: '{flow-id}'
---
# Harness Review (Review Stage)

## 步骤

1. 按 security-checklist 进行安全审查
2. 按 performance-checklist 进行性能审查
3. 执行代码规范与可维护性评审
4. 编写 `reviews/<flow-id>-review.md` 记录审查结论

## FM 必填项

- 必须调用 `harness_artifact_write` 写入 `kind=review` 到 `reviews/<flow-id>-review.md`
- 模板变量：`{flow-id}` 需替换为实际 flow identifier
