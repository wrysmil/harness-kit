# Harness Runbooks

## 新功能

1. 使用 `superpowers:brainstorming` 产出 spec。
2. 将 spec 保存到 `.ai-runtime-artifacts/specs/`。
3. **Plan 判定（条件分支）：**
   - spec 涉及多模块协调 / 有先后依赖 / 需要分步编排 → 使用 `superpowers:writing-plans` 产出实施计划
   - spec 已确认后被修改（范围扩大或方向变化）→ 触发 plan（重新编排）
   - 变更范围单一模块内、无依赖序 → 跳过 plan，直接实现（在 spec front matter route 中记录 `skip:plan(reason)`）
   - 用户显式说"不需要计划"/"直接做" → 跳过 plan
4. **编码实现必须使用 `omx ultrawork` 或等价 omx 工作流。** 不允许跳过 omx 直接编码。
5. 编码完成后产出 `execution-log` 到 `.ai-runtime-artifacts/execution-logs/`，记录实际路由、变更文件和待验证项。
6. 验证结果保存到 `.ai-runtime-artifacts/verifications/`。

## 缺陷修复

1. 使用 `superpowers:systematic-debugging` 或 omx debugger 路由复现并定位。
2. 写清根因、影响范围和修复方案。
3. **修复实现必须使用 `omx` 工作流。**
4. 编码完成后产出 `execution-log` 到 `.ai-runtime-artifacts/execution-logs/`。
5. 使用最接近缺陷的命令验证。
6. 验证摘要保存到 `.ai-runtime-artifacts/verifications/`。

## 架构决策

1. 读取 `cow-harness/project.profile.md` 和相关代码。
2. 必要时用 omx architect / critic / planner 组合做对比。
3. 决策写入 `.ai-runtime-artifacts/decisions/`。
4. 决策必须包含接受方案、拒绝方案、约束和风险。

## Harness 迁移到新项目

1. 将 `cow-harness/` 放入新项目。
2. 对 AI 说：

```text
请先读取 cow-harness/README.md 和 cow-harness/init/bootstrap.prompt.md。
这是一个新项目刚接入 Agent Harness，请按 Harness 初始化流程处理：
1. 从 cow-harness/entrypoints/ 投影根目录 AI 入口文件。
2. 从 cow-harness/adapters/ 投影工具适配目录。
3. 创建 .ai-runtime-artifacts/ 及其子目录。
4. 如需安装或检查 AI runtime，请先说明会修改哪些本机环境，然后由你执行 cow-harness/scripts/install-ai-skills.sh。
5. 读取 cow-harness/init/project-profiler.prompt.md。
6. 扫描当前项目，生成或更新 cow-harness/project.profile.md、cow-harness/context-map.md、cow-harness/project.verification.md。
7. 由你运行 cow-harness/scripts/harness-check.sh。
8. 汇总推断项、待确认项和验证结果。
```

3. 人 review `project.profile.md` 中的推断项和待确认项。
