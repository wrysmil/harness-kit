---
artifact: spec
title: "Add Harness Coder role (Cursor orchestration)"
date: 2026-05-26
status: draft
platform: cursor
route: cursor-orchestration:dispatcher-workflow
---

## 背景与问题

当前 Cursor 编排中，`Leader` 会将实现工作下发给 `harness-implementer`（有界 Worker）。该角色的设计目标是“窄范围执行”，因此在实际落地时经常出现：

- 子 Agent 只完成指令范围内的一点实现，不会主动补齐工程化要求（日志、单测、验证、自检）。
- 测试与审查被拆成独立角色，但“开发者自检”这一层缺位，导致问题往往到 Reviewer 才暴露，反馈链路长。
- `wu_skills: auto` 能加载 TDD 与验证能力，但只要 Leader 漏传/误传字段（或 `wu_type` 标错），规范链条就会中断。

本 spec 引入一个新的 `Coder` 角色，用于**代码类** WU 的端到端交付质量闭环，同时保留现有 `Implementer` 用于文档/轻量任务。

## 目标

- 为代码类 WU 引入“资深开发者”职责：实现 + 单测（或明确豁免）+ 自测 + 开发者自检（硬门槛）。
- 保持 `Leader` 的定位为“技术主管/编排者”：与用户交互、拆 WU、资料传递、整合与验证。
- 保留现有角色分工：`test-engineer`、`reviewer`、`debugger`、`explorer`。
- 在保证质量的同时提升效率：对低风险“小 WU”允许在满足硬条件时**跳过独立 Reviewer**。
- 让技能（skills）链条更稳定：Leader 指定的 skills 必须由 Coder/Implementer 按需加载使用；`auto` 作为默认底座。

## 非目标

- 不改变 Harness 的阶段门禁（spec/plan 批准后才能进入实现）。
- 不在本 spec 中要求实现者进行 Git 提交或 PR 操作（仍由 Leader 负责）。
- 不将 Coder 设计为二级 dispatcher（不允许 Coder 再派发子 Agent 以避免重复编排链）。

## 角色与职责边界

### Leader（技术主管/编排者）

**做：**
- 与用户交互；路由判定；遵守阶段门禁。
- 从 plan 拆分 WU；为每个 WU 标注 `wu_type`、允许修改文件、done criteria、验证命令。
- 为每个 WU 选择 subagent（Coder / Implementer / Test Engineer / Reviewer / Debugger / Explorer）。
- 在 WU prompt 中显式给出「本 WU Skills」，或写 `auto`。
- 整合结果；执行 `project.verification.md` 的最小验证集；按规则决定是否委派 Reviewer。

**不做：**
- 在实现阶段主线程大规模修改业务代码（routing 为“小改动”例外）。
- 与实现者共用同一 subagent 实例执行独立审查。

### Coder（新角色，资深开发者）

定位：对**代码类** WU 负完整交付责任。

**必须完成的闭环步骤：**
1. 读取本 WU 的 plan/spec 片段与目标文件现状。
2. 仅在允许修改文件范围内实现功能与必要的工程化配套（日志、错误处理、边界处理，按项目既有规范）。
3. 编写/补齐单元测试（或在 plan 明确豁免时写明理由与风险）。
4. 运行验证命令（至少包含 `project.verification.md` 要求的相关命令）并给出真实结果摘要。
5. 填写“开发者自检”（见下文），**自检未通过不得返回完成**。

**禁止：**
- 重规划/扩大 WU；发现 plan 歧义或范围过大必须上报 Leader。
- 派发子 Agent（避免形成二级编排者）。
- Git commit/push（除非 Leader 明确要求）。

### Implementer（现有角色，轻量执行者）

定位：执行文档/模板/纯配置等**不需要 Coder 流程闭环**的 WU。

适用：`docs`、`chore`、`config`（以及明确声明不要求测试/自检的轻量 WU）。

### Reviewer（独立审查者）

定位保持不变：独立实例、怀疑态度、五轴审查。对“大 WU”或高风险 WU 必须介入。

## WU 类型路由（Leader 负责标注）

### `wu_type` → subagent

- `feature`, `bugfix`, `refactor`, `review-fix`, `ui` → `harness-coder`
- `docs`, `chore`, `config` → `harness-implementer`
- `test`, `e2e` → `harness-test-engineer`
- `explore` → `harness-explorer`
- `investigate`, `ui-bug` → `harness-debugger`
- `review` → `harness-reviewer`

## Skills 规则（关键）

### Leader 显式指定 skills 时

- WU prompt 中的「本 WU Skills」对 Coder/Implementer/Test Engineer **是指令**。
- 子 Agent 必须逐项加载并按需使用；若本机不存在则返回中注明 `skipped: <skill> (not found)`。
- 发生冲突时优先级：Leader 显式指定/追加 > `auto` 默认 > 空（无）。

### `wu_skills: auto` 时

- 子 Agent 先按 `agent_role + wu_type` 在 `orchestration/skill-preferences.zh.md` 解析默认 skills 列表，再按需加载。
- `auto` 解析结果可由 Leader 抄入 prompt，也可保留 `auto` 让子 Agent 自查。

### 全局禁止（即使 Leader 误传也必须拒绝并上报）

`brainstorming`, `writing-plans`, `cursor-orchestration`, `using-superpowers`, `git-xywh`, `dispatching-parallel-agents`, `subagent-driven-development`

## Coder 开发者自检（硬门槛）

Coder 在 WU 返回时必须包含：

- `self_check: PASS | FAIL`
- `open_items: 无 | <列表>`（列出未关闭的 Critical/Important）
- `skip_reviewer_eligible: yes | no`（按“小 WU 判定”自填，Leader 复核）

**规则：**
- `self_check: FAIL` 时不得向 Leader 声称“完成”，必须说明阻塞原因与下一步。

建议自检项（最小集合）：
- 对照 spec/plan done criteria 逐项满足
- 错误路径与日志按项目规范处理
- 单测已写/已更新并通过（或明确豁免理由）
- verification 命令已实际运行并通过（附命令与结果摘要）
- 无已知 Critical/Important 遗留

## 小 WU 跳过 Reviewer（效率优化）

本规则结合两点：
- Coder 自检是硬门槛（未通过不能“完成”）。
- 小 WU 在满足硬条件时允许 Leader 跳过 `harness-reviewer`。

### 默认阈值（可覆盖）

**文件数阈值：**允许修改文件数 ≤ 5。

### 必须委派 Reviewer 的硬条件（覆盖一切）

满足任一条即 **必须**委派 `harness-reviewer`：

- 安全敏感（鉴权/权限/密钥/注入面/支付等）
- 公共 API / 协议变更（对外接口、共享库 API、CLI 约定等）
- DB schema / 数据迁移
- 跨模块架构调整（新增跨层依赖、核心模块边界变化）
- 用户或 plan 明确要求审查
- Coder `self_check: FAIL` 或存在未关闭 Important/Critical
- `project.verification.md` 指定的验证未通过

### 可跳过 Reviewer 的条件（全部满足才可）

- 文件数 ≤ 5
- 不触发任何“必须委派 Reviewer 的硬条件”
- Coder `self_check: PASS` 且无 open Important/Critical
- Leader 侧运行的最小验证集通过

## 需要的变更清单（后续实现的范围）

> 本 spec 不实现代码变更，只定义要改动哪些规范文件与模板。

- 新增 `orchestration/agents/coder.md`（Coder 详细参考）
- 新增 `.cursor/agents/harness-coder.md`（Cursor subagent 投影）
- 更新 `orchestration/agents/leader.md`：加入 Coder 路由与 Reviewer 跳过规则
- 更新 `orchestration/dispatcher-workflow.md`：在 WU 映射表中加入 Coder；加入“小 WU 跳过 Reviewer”门禁步骤
- 更新 `orchestration/platform-adapters.zh.md`：在角色映射中加入 Coder
- 更新 `orchestration/skill-preferences.zh.md`：新增 `agent_role: coder` 的 `auto` 路由（至少 TDD + verification）
- 更新 `artifact-templates/wu-checklist.md`：增加 Coder 自检节与字段
- 更新 `orchestration/model-routing.yaml`：加入 coder 条目（如需要）

## 风险与缓解

- **Leader 标注 `wu_type` 错误导致派错人**：在 dispatcher-workflow 中明确路由表；对模糊 WU 要求先 explore 或在 plan 中写清 `wu_type`。
- **Coder 角色过载、影响并行度**：保持 WU 有界（≤5 文件写入）；复杂需求拆 WU，必要时并行多个 Coder。
- **跳过 Reviewer 误放行**：硬条件覆盖 + Coder 自检硬门槛 + Leader 最小验证集三重兜底；保留 Leader 手动 `review: required` 的权力。

## 验收标准（该 spec 的“完成”定义）

- 文档明确：角色职责、路由、skills 规则、Coder 自检、Reviewer 跳过规则与硬条件。
- 给出实现需要改动的文件清单（可直接转为实现计划）。
