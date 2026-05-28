---
artifact: spec
title: "在 Cursor 编排中引入 Git worktree 隔离（子 Agent 可回滚）"
date: 2026-05-28
status: draft
platform: cursor
route: superpowers:brainstorming
related:
  - harness-kit/adapters/cursor/orchestration/dispatcher-workflow.md
  - harness-kit/adapters/cursor/orchestration/tracking/schema.md
  - harness-kit/core/routing.md
---

# 在 Cursor 编排中引入 Git worktree 隔离（子 Agent 可回滚）

## 1. 背景与问题

当前 Cursor 编排（`cursor-orchestration:dispatcher-workflow`）以 WU（Work Unit）拆分实现并行，但子 Agent 默认直接在主工作区写文件：

- 并行时依赖「文件所有权不重叠」来降低冲突
- 一旦某个子 Agent 写坏或跑偏，回滚通常依赖手工 `git restore` / `git checkout`，容易误伤其它 WU 的改动
- “无法回滚”在并行场景是高风险问题：成本高、可审计性差、容易造成主分支工作区污染

**目标**：把“可回滚”变成编排流程的默认能力，使 Leader 能以 WU 为粒度创建/丢弃隔离工区，做到 **A 单 WU 可丢弃**、并在并行时自然覆盖 **B 整组可丢弃** 与 **C 整次会话可丢弃**（通过批量删除 worktree 实现）。

## 2. 目标与非目标

### 2.1 目标

1. **默认隔离粒度 = WU**：每个需要隔离的 WU 使用独立 Git worktree + 独立分支。
2. **命名可读**：
   - 路径/分支使用 **英文 slug**，避免 shell/跨平台字符坑
   - 在 `*-dispatch.md` / `DISPATCH-TRACK` / 元数据中使用 **中文标题**，确保人类可一眼看懂
3. **何时启用清晰可判定**：
   - 默认仅 `coder` WU 启用 worktree
   - Leader 一次派发 **2 个及以上** `coder` WU（同一 GROUP/同一轮派发）时强制启用
   - 单一 `coder` WU 默认不启用（除非显式覆盖）
4. **失败可回滚**：WU FAIL/偏离时可直接丢弃该 WU worktree（不影响其它 WU）。
5. **与现有尾盘门禁兼容**：不改变既有“集体测试 → 集体审查 → 关闭 execution-log”的门禁链条。

### 2.2 非目标

- 不要求 Reviewer/Explorer/Web-investigator 使用 worktree（readonly 场景无必要）。
- 不在本 spec 中强制引入“自动整合/自动合并”机器人；整合由 Leader 按既有 Git 协作规则执行。
- 不要求在 worktree 内做 commit/push（组织流程由 `git-xywh` + `project.git.md` 约束）。

## 3. 核心方案（方案一）：每个 WU 一个 worktree

### 3.1 WU 的隔离对象

当 WU 需要隔离时，Leader 为该 WU 创建：

- **worktree 目录**：一个独立的工作区路径
- **worktree 分支**：`wu/...` 命名空间下的独立分支

子 Agent 的所有写操作都发生在该 worktree 目录中；Leader 负责把分支整合回集成分支/主线。

### 3.2 命名规范（英文本体 + 中文展示）

#### 3.2.1 Worktree 目录命名（英文本体）

worktree 根目录（建议）放在仓库根下的 `.worktrees/`（必须在 `.gitignore` 忽略）：

` .worktrees/<YYYY-MM-DD>--<topic-slug>__WU-<id>__<wu_type>__<agent_role> `

示例：

- `.worktrees/2026-05-28--worktree-sandbox__WU-03__bugfix__coder`

字段说明：

- `<topic-slug>`：来自 plan/spec 的 topic（Leader 生成稳定 slug）
- `WU-<id>`：执行图中的 WU 编号
- `<wu_type>`：`feature|bugfix|refactor|test|chore|docs|config|review-fix|ui`
- `<agent_role>`：`coder|implementer|test-engineer|debugger|web-investigator|reviewer`

#### 3.2.2 分支命名（英文本体）

`wu/<YYYY-MM-DD>/<topic-slug>/WU-<id>-<wu_type>`

示例：

- `wu/2026-05-28/worktree-sandbox/WU-03-bugfix`

#### 3.2.3 中文标题（展示层）

为保证“清楚知道 worktree 在做什么”，在以下位置写入中文信息：

- `*-dispatch.md` 的 WU 行增加：
  - `wu_title_zh`：短标题（10–20 字）
  - `wu_desc_zh`：一句话描述（可选）
- `DISPATCH-TRACK` 追加条目 Detail 中带 `WU 标题（中文）` 与 `worktree_path`
- worktree 内写一个极小元数据文件（见 3.3）

### 3.3 WU 元数据文件（防止只靠命名丢信息）

在每个 worktree 根写入 `.harness-wu.json`（文件名固定，便于脚本扫描）：

```json
{
  "topic_slug": "worktree-sandbox",
  "wu_id": "WU-03",
  "wu_type": "bugfix",
  "agent_role": "coder",
  "wu_title_zh": "修复子 Agent 改动可回滚",
  "wu_desc_zh": "将 coder WU 默认放入独立 git worktree，坏了直接丢弃。",
  "created_at": "2026-05-28T15:00:00+08:00",
  "base_ref": "main",
  "base_sha": "<sha>",
  "branch": "wu/2026-05-28/worktree-sandbox/WU-03-bugfix",
  "worktree_path": ".worktrees/2026-05-28--worktree-sandbox__WU-03__bugfix__coder"
}
```

说明：

- 该文件是 **可选但强烈建议** 的“人类可读 + 机器可解析”锚点
- 任何时候即便目录被移动/重命名，也能追溯 WU 的真实用途

## 4. 启用判定（你提出的规则，写成可执行的决策表）

### 4.1 默认规则（无需额外标注）

- **仅 `coder` 默认启用** worktree 隔离
- `implementer`（docs/chore/config）、`reviewer`、`explorer`、`web-investigator` 默认 **不启用**
- `test-engineer` 默认不启用；仅当测试改动面大且风险高时由 Leader 显式开启

### 4.2 “2 个及以上 WU”强制规则（Leader 派发轮次）

定义 `dispatch_batch`：Leader 在同一 GROUP 内、同一轮并行派发的 WU 集合。

- 当 `dispatch_batch` 中 **`coder` WU 数量 ≥ 2**：
  - 这些 `coder` WU **必须**使用独立 worktree
- 当 `dispatch_batch` 中 **`coder` WU 数量 = 1**：
  - 默认不创建 worktree（直接在主工作区执行），除非 Leader 显式覆盖

### 4.3 显式覆盖（让规则不僵化）

在执行图（`*-dispatch.md`）允许对单个 WU 写：

- `workspace_scope: wu`：强制该 WU worktree
- `workspace_scope: none`：强制不使用 worktree（仅允许在明确“低风险单次任务”且不并行时使用）

## 5. 编排流程改造点（不改变 WU 拆分，只增加“工区”概念）

### 5.1 `dispatcher-workflow.md` 的增强点

在「步骤 1：Worktree 拆分（主 Agent）」中补充一段：

- 这里的 “Worktree” 既可以指逻辑 WU 执行图，也可以指 **Git worktree（物理隔离）**
- Leader 在写 `*-dispatch.md` 时，按第 4 节规则为需要隔离的 WU 分配 `worktree_path` 与 `branch`

### 5.2 `*-dispatch.md`（执行图）增加字段（建议）

对每个 WU 增加：

- `wu_title_zh`
- `worktree_path`（若启用）
- `branch`（若启用）
- `workspace_scope`（可选覆盖）

### 5.3 子 Agent 派发 prompt 的硬约束（关键）

当 WU 启用 worktree 时，Leader 派发 prompt 必须包含：

- `worktree_path`（要求在该目录内读写与执行命令）
- 禁止在 worktree 外修改文件
- 若需运行命令，必须在 worktree 目录执行

> 这条把“回滚能力”从习惯/人肉约束变成“路径即边界”的流程约束。

## 6. 整合与回滚（Leader 责任）

### 6.1 回滚策略（WU 粒度）

当 WU 失败、跑偏、或需要从头重做：

- 直接删除该 worktree（并记录在 `DISPATCH-TRACK`）
- 可选：保留分支用于复盘；若明确无用则删除分支

### 6.2 整合策略（WU → 集成分支）

Leader 在整合时选择其一（项目 Git 规范由 `git-xywh` + `project.git.md` 决定）：

- **merge**：保留分支上下文，适合 WU 较大、需要审计
- **cherry-pick**：让集成分支历史更线性，适合 WU 较小、彼此独立

本 spec 不强制二选一，但要求：

- 整合后进入尾盘（集体测试/审查）前，集成分支必须处于可验证状态

## 7. 安全与仓库卫生

### 7.1 `.worktrees/` 必须被忽略

在仓库根 `.gitignore` 增加：

- `.worktrees/`

原因：避免 worktree 内容被误加入版本控制，污染 PR/提交。

### 7.2 追踪与可审计性

`DISPATCH-TRACK` 应记录：

- 哪些 WU 使用了 worktree、路径与分支
- worktree 创建/删除（回滚）动作
- WU 完成后的整合动作（merge/cherry-pick 的事实记录）

## 8. 验收标准

满足以下条件即认为本设计落地成功：

1. Leader 一次派发 2+ 个 `coder` WU 时，每个 WU 都有独立 worktree（目录/分支命名符合本 spec）
2. 任一 WU 失败时，Leader 可以不影响其它 WU 地丢弃该 worktree，且主工作区不被污染
3. `*-dispatch.md`/`DISPATCH-TRACK` 中能用中文清晰表达每个 worktree 的用途（`wu_title_zh` 至少存在）
4. `.worktrees/` 不出现在 `git status` 的未跟踪/待提交列表中

## 9. Next

- 你确认本 spec 内容后，我会进入 `writing-plans`，把改造拆成可执行的 WU（包括：更新 `.gitignore`、更新 `dispatcher-workflow.md`、更新 `dispatch.harness-overlay.md` / `dispatch-track` 模板、以及 Leader 派发 prompt 模板的约束字段）。

