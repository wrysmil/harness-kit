---
artifact: spec
title: "Git Worktree 执行图级隔离"
date: 2026-05-29
status: approved
platform: cursor
route: cursor-orchestration:dispatcher-workflow -> worktree-isolation
related:
  - harness-kit/adapters/cursor/orchestration/dispatcher-workflow.md
  - harness-kit/adapters/cursor/orchestration/tracking/schema.md
  - harness-kit/adapters/cursor/orchestration/agents/leader.md
  - docs/superpowers/specs/2026-05-28-batch-closeout-review-and-collective-test.md
  - harness-kit/core/runbooks.md
  - harness-kit/project.git.md
decisions:
  - 沙箱父目录：仓库外 `<repo-parent>/.harness-worktrees/<repo-basename>/`
  - 沙箱主标识：Git **worktree**（`worktree_id`），非「先拉分支再干活」
  - 交付后 Git：Leader **不**自动 push / 开 PR，须人工确认
assumptions:
  - 默认粒度为「每个已批准 plan 的执行图（dispatch）一个 Git worktree」
  - 编排产物（`.ai-runtime-artifacts/`）留在主仓库 checkout；业务代码变更在 worktree 内完成
  - Git 操作由 Leader 执行；子 Agent 默认不 commit / push（延续 `project.git.md`）
  - 平台优先 Cursor；其他平台路径仅记录差异，本 spec 不强制实现
---

# Git Worktree 执行图级隔离

## 1. 背景与问题

Harness Cursor 编排已有 **逻辑执行图**（`GROUP` / `WU`，写在 `*-dispatch.md`；文档中亦称「Worktree 拆分」），但实现阶段默认在**当前 checkout** 上改代码，导致：

| 现象 | 根因 |
| --- | --- |
| 主工作区被 Agent 弄脏 | 无物理隔离；与用户未提交改动、其他分支工作混在同一树 |
| 并行 WU 偶发文件竞争 | 仅靠 dispatch 文件所有权约束；写错所有权即冲突 |
| 中断恢复路径不清晰 | `HANDOFF.md` / `DISPATCH-TRACK` 无统一「代码沙箱」指针 |
| 尾盘验证与审查范围模糊 | 集体测试/审查的 diff 基线未与执行图绑定 |

**本方案目标：** 在 **不改变现有 GROUP / WU / 尾盘门禁语义** 的前提下，为每个 **执行图（dispatch）** 引入 **Git worktree 物理沙箱**，使实现、集成验证、尾盘测试均在隔离环境中完成，主 checkout 保持可继续对话/编排。

---

## 2. 术语

| 术语 | 定义 |
| --- | --- |
| **逻辑执行图** | `*-dispatch.md` 中的 `GROUP` / `WU` 依赖与派发计划（既有概念） |
| **Git worktree** | `git worktree add` 创建的独立工作目录，与同一仓库共享对象库 |
| **执行图沙箱** | 一个 dispatch 对应 **一个** Git worktree（主标识 `worktree_id`）；分支随 worktree 注册，非独立「拉分支」操作 |
| **worktree_id** | 沙箱逻辑名，用于目录名与追踪；格式见 §5.4 |
| **主 checkout** | 用户/Leader 编排所在目录（通常为仓库根）；**不写业务代码**（routing「小改动」除外） |
| **worktree_path** | 沙箱绝对路径 = 沙箱父目录 + `worktree_id`；子 Agent 的 `working_directory` |
| **WORKTREE-INIT** | Leader **`git worktree add`** 创建沙箱的步骤（可同时 `-b` 注册分支） |
| **WORKTREE-CLOSE** | 交付后移除 worktree、保留或合并分支的步骤 |

**命名约定（消歧）：**

- 文档与对话中的 **「执行图」** = dispatch / GROUP-WU 图
- **「Worktree 拆分」** 在编排文档中仍指逻辑拆分；本 spec 新增 **「Git worktree 沙箱」** 专指物理隔离，避免混用

---

## 3. 方案对比与推荐

### 3.1 三种粒度

| 方案 | 描述 | 优点 | 缺点 | 结论 |
| --- | --- | --- | --- | --- |
| **A. 每 WU 一个 worktree** | 每个 `WU-01`… 独立目录+分支 | 隔离最强；单 WU 回滚简单 | N 次 merge；GROUP 依赖难同步；与尾盘「整批 diff」冲突；开销大 | **不作默认** |
| **B. 每执行图一个 worktree（推荐）** | 每个 `*-dispatch.md` / plan 批次一个沙箱 | 与 GROUP 尾盘、集体测试/审查对齐；生命周期清晰 | 单 WU 失败可能污染沙箱（靠 review-fix WU 修） | **默认** |
| **C. 每 GROUP 一个 worktree** | GROUP-1 一棵树，GROUP-2 再新建 | GROUP 间隔离更强 | GROUP-2 依赖 GROUP-1 时要反复 merge 基线；尾盘要跨树聚合 | **不采用** |

### 3.2 推荐：B + 例外机制

- **默认：** 方案 B（执行图级）
- **例外（per-WU worktree）：** 见 §8.2

---

## 4. 目标与非目标

### 4.1 目标

1. **主 checkout 保护：** 多 task 实现阶段，业务代码变更发生在沙箱 worktree，不污染 Leader 编排目录。
2. **执行图绑定：** 一个已批准 plan 的实现批次 ↔ 一个 `worktree_id` / `worktree_path` ↔ 一份 `DISPATCH-TRACK`。
3. **流程兼容：** 不改动 GROUP 尾盘（先集体测试、后集体审查）、WU 派发、skill 门禁的既有顺序。
4. **可恢复：** `HANDOFF.md` 与 tracking 含 `WorktreePath` / `Branch` / `BaseRef`，新会话可继续同一沙箱。
5. **可审计：** WORKTREE-INIT / CLOSE 写入 append-only tracking；execution-log front matter 记录沙箱元数据。

### 4.2 非目标

- 不替代 dispatch 的「并行 WU 文件所有权」规则（仍必须写清允许修改文件）。
- 不默认让子 Agent 执行 `git commit` / `push`。
- 不在本 spec 实现自动 merge 到 `main` / `develop`（仍走 `git-xywh` + 人工/显式指令）。
- 不强制其他平台路径在本期实现同等 worktree（仅留扩展点）。

---

## 5. 架构

### 5.1 双轨目录模型

```text
<repo-root>/                          ← 主 checkout（Leader）
  .ai-runtime-artifacts/              ← 编排产物（spec/plan/dispatch/track/reviews…）
  harness-kit/
  …（业务源码只读参考，Leader 不改）

<repo-parent>/.harness-worktrees/   ← 沙箱父目录（仓库外，已确认）
  <repo-basename>/
    wt-<YYYY-MM-DD>-<topic>/         ← 一个 Git worktree（子 Agent 写代码）
      …（与主仓库相同结构的业务源码）
```

**为何产物留在主 checkout：**

- Leader 写 `DISPATCH-TRACK`、`collective-test`、`code-review` 不必切换目录
- 与用户对话、读 spec/plan 路径一致
- 避免 worktree 删除后丢失追踪日志

**为何沙箱在仓库外：**

- 避免 `.gitignore` 误提交 worktree 路径
- Windows / 多工具并行时路径稳定
- 默认父路径：与仓库根目录同级

```text
repo_parent    = dirname(repo_root)          # 例：D:\workspace\ai
sandbox_parent = repo_parent / ".harness-worktrees" / basename(repo_root)
worktree_id    = "wt-" + dispatch_stem       # 见 §5.4
worktree_path  = sandbox_parent / worktree_id
```

**示例（本仓库）：**

```text
D:\workspace\ai\.harness-worktrees\harness-kit\wt-2026-05-29-user-auth\
```

### 5.2 角色与职责

| 角色 | 工作目录 | Git 操作 | 写业务代码 |
| --- | --- | --- | --- |
| **Leader** | 主 checkout | WORKTREE-INIT / CLOSE；交付时 PR（`git-xywh`） | 否（小改动除外） |
| **Coder / Implementer / Test Engineer** | 沙箱 worktree | 否（默认） | 是（仅允许文件列表内） |
| **Reviewer** | 只读；审查上下文含 `BaseRef`/`HeadRef` 或文件列表 | 否 | 否 |

### 5.3 WORKTREE-INIT：以 worktree 为主，分支为附带注册

**概念：** 每个大任务创建的是 **一棵 Git worktree**（独立工作目录）。分支不是单独 checkout 出来的「另一个入口」，而是 `git worktree add` 时可选 `-b` **在该树上注册**的 HEAD，便于 `git log` / PR 对照。

Leader 在 WORKTREE-INIT 时声明 `「Harness：git-xywh + project.git.md」` 后：

| 项 | 规则 |
| --- | --- |
| **基线** | `project.git.md` 指定主干；未写明时默认 `main` 或当前默认分支 |
| **主操作** | `git worktree add -b <branch> <worktree_path> <base>`（路径不存在时创建） |
| **已存在** | 若 `worktree_path` 已存在且 `HANDOFF` / tracking 的 `worktree_id` 一致 → **复用**，不重复 `add` |
| **仅分支存在、无 worktree** | `git worktree add <worktree_path> <branch>`（路径须符合 §5.4） |

**禁止表述：** 「为执行图拉一条功能分支」——对外统一说 **「创建/复用 worktree `<worktree_id>`」**。

### 5.4 Worktree 命名规范（`worktree_id`）

#### 5.4.1 默认：一个 dispatch 执行图 → 一个 worktree

| 字段 | 规则 | 示例 |
| --- | --- | --- |
| **dispatch_stem** | `*-dispatch.md` 文件名去掉后缀 `-dispatch` | 文件 `2026-05-29-user-auth-dispatch.md` → `2026-05-29-user-auth` |
| **worktree_id** | `wt-` + `dispatch_stem` | `wt-2026-05-29-user-auth` |
| **worktree_path** | `sandbox_parent` + `/` + `worktree_id` | `…/harness-kit/wt-2026-05-29-user-auth` |
| **branch**（附带） | `harness/` + `worktree_id`（与目录名一致，便于对照） | `harness/wt-2026-05-29-user-auth` |

`dispatch_stem` 须与 `DISPATCH-TRACK-YYYY-MM-DD-<topic>.md` 中的日期+topic 一致（同一执行图唯一）。

#### 5.4.2 `dispatch_stem` / topic 字符集

- 仅小写字母、数字、连字符 `[a-z0-9-]`
- 日期段：`YYYY-MM-DD`（与 artifact 命名一致）
- topic：kebab-case，建议 ≤40 字符
- **禁止**：空格、中文路径段、`_`（统一用 `-`）

若 plan/dispatch 文件名不符合，Leader 在 WORKTREE-INIT 前**规范化** stem 并写入 tracking `Detail:`。

#### 5.4.3 同日同 topic 二次执行（少见）

若同一 `dispatch_stem` 需**新沙箱**（旧树已 CLOSE 或废弃）：

- `worktree_id` = `wt-{dispatch_stem}--r2`（第三次 `--r3`…）
- tracking / HANDOFF 必须写清 `revision: r2`，避免与旧日志混淆

默认仍**优先复用**未 CLOSE 的同名 worktree。

#### 5.4.4 例外：临时 WU worktree

| 字段 | 规则 | 示例 |
| --- | --- | --- |
| **worktree_id** | `{父 worktree_id}--wu-{wu-id}` | `wt-2026-05-29-user-auth--wu-03` |
| **branch** | `harness/{worktree_id}` | `harness/wt-2026-05-29-user-auth--wu-03` |
| **生命周期** | WU 完成 → merge 回父 worktree → `git worktree remove` 临时树 | — |

WU id 使用 dispatch 中编号（如 `WU-03` → 段 `wu-03`）。

#### 5.4.5 追踪字段（主标识用 id，执行用 path）

```text
WorktreeId: wt-2026-05-29-user-auth
WorktreePath: D:/workspace/ai/.harness-worktrees/harness-kit/wt-2026-05-29-user-auth
Branch: harness/wt-2026-05-29-user-auth
Base: <sha>
```

派发子 Agent 时抄 **WorktreePath**；汇报与 `git worktree list` 对照时用 **WorktreeId**。

---

## 6. 生命周期（接入 dispatcher-workflow）

在 `dispatcher-workflow.md` 中插入 **步骤 0** 与 **步骤 5**（命名可并入现有步骤编号，以下用逻辑名）。

### 6.1 步骤 0 — WORKTREE-INIT（「开始实现」之后、GROUP-1 派发之前）

**触发：** 用户确认 plan + dispatch，并说「开始实现」/「并行执行」。

**Leader 动作：**

1. 从 `*-dispatch.md` 推导 `dispatch_stem` → `worktree_id` / `worktree_path` / `branch`（§5.4）
2. Load `git-xywh` + Read `project.git.md`
3. 若 `worktree_path` 不存在 → `git worktree add -b <branch> <worktree_path> <base>`；已存在且 id 一致 → **复用**
4. 创建/更新 `DISPATCH-TRACK-*.md`，追加：

```text
[YYYY-MM-DD HH:MM] WORKTREE-INIT | Leader | Status: completed
Detail: WorktreeId=<id> WorktreePath=<abs-path> Branch=harness/<id> Base=<sha>
Output: <worktree_path>
Next: GROUP-1 派发
```

5. 更新 `HANDOFF.md` § Git 沙箱（见 §7.2）

6. 对甲方汇报：**worktree_id**、**worktree_path**、基线 SHA（分支仅作 Git 对照，不作为沙箱主名）

**门禁：** 未完成 WORKTREE-INIT **不得**向子 Agent 派发写代码类 WU。

### 6.2 步骤 1–3 — 既有逻辑（在沙箱内执行）

| 既有步骤 | 变更 |
| --- | --- |
| Worktree 拆分（逻辑） | 不变；仍写 `*-dispatch.md` |
| 并行派发 | 每个子 Agent prompt **必须**含 `工作目录: <worktree_path>`（绝对路径） |
| 单 WU 整合 | Leader 在主 checkout 更新 plan/tracking；代码已在沙箱 |
| GROUP 尾盘 A 集体测试 | Leader 在 **沙箱 worktree** 下跑 `project.verification.md` 命令 |
| GROUP 尾盘 B 集体审查 | Reviewer 上下文含 `BASE_SHA`（init 基线或分支点）与 `HEAD_SHA`（沙箱当前 HEAD） |

**子 Agent prompt（沙箱批次，一行即可）：** `worktree_path: <abs>`；禁改主 checkout 业务文件；禁 commit/push（除非授权）。勿重复 agent 正文纪律。

### 6.3 步骤 4 — 追踪（扩展字段）

`tracking/schema.md` DISPATCH 专用字段追加：

```text
WorktreeId: <id> | WorktreePath: <abs-path> | Branch: harness/<id> | Base: <sha>
```

每条 WU 派发建议带 `Worktree:` 重复一次，便于日志自检。

### 6.4 步骤 5 — WORKTREE-CLOSE（批次交付完成后）

**触发：** execution-log 已写「批次交付完成」且 collective-test PASS + code-review APPROVE/SKIPPED。

**Leader 动作（顺序）：**

1. **人工确认后** 再按 `git-xywh` 从沙箱对应分支 push / 开 PR（Leader **不得**自动 push）
2. 用户确认合并或放弃后：
   - `git worktree remove <worktree_path>`（必要时 `--force` 需用户确认）
   - tracking 追加 `WORKTREE-CLOSE | completed`
3. 若 **中断但未交付**：保留 worktree；`HANDOFF` 保留路径供恢复

---

## 7. 产物契约变更

### 7.1 `execution-log` front matter 追加

```yaml
worktree:
  id: wt-<dispatch-stem>
  path: <abs-path>
  branch: harness/wt-<dispatch-stem>
  base_ref: <sha>
  head_ref: <sha>   # 关闭时填写
```

### 7.2 `handoff.md` 模板追加 § Git 沙箱

```markdown
## Git 沙箱
- worktree_id: 
- worktree_path: 
- branch: 
- base_ref: 
- head_ref: 
```

### 7.3 `dispatch-track.md` 模板 § 执行图 下追加

```markdown
## Git 沙箱
- worktree_id: 
- worktree_path: 
- branch: 
- base_ref: 
```

### 7.4 `collective-test.md` / `code-review.md`

front matter 可选：

```yaml
worktree_id: wt-<dispatch-stem>
worktree_path: <abs-path>
branch: harness/wt-<dispatch-stem>
base_sha: <sha>
head_sha: <sha>
```

---

## 8. 边界情况

### 8.1 复用与冲突

| 情况 | 处理 |
| --- | --- |
| 同一 `worktree_id` 路径已存在 | 读 `HANDOFF` + tracking；与当前 dispatch 一致则复用 |
| 分支已存在但无 worktree | `git worktree add <worktree_path> <branch>`（path 须符合 §5.4） |
| worktree 存在但 `worktree_id` 与 dispatch 不一致 | **blocked**；Leader 汇报用户，禁止静默覆盖 |
| 用户主 checkout 有未提交改动 | WORKTREE-INIT 不受影响（沙箱独立）；提醒用户主树仍脏 |

### 8.2 例外：per-WU worktree

仅在 Leader 判定以下条件 **之一** 成立时，可为单个 WU 建临时 worktree（从当前沙箱分支拉出）：

- dispatch 无法避免两 WU 修改同一文件
- best-of-n / 实验性方案并行
- `review-fix` 改动面大，需独立回滚且不想污染主沙箱

临时 **worktree_id**：`{父 worktree_id}--wu-{wu-id}`（§5.4.4）。WU 完成后 merge 回父 worktree，再 `git worktree remove` 临时树；tracking 记录 `WORKTREE-SPAWN-WU` / `WORKTREE-MERGE-WU`。

### 8.3 跳过 WORKTREE-INIT

以下 **不** 创建 Git worktree（在主 checkout 改代码）：

- routing「小改动」
- Leader **不拆 WU、不委派** harness-* 子 Agent 的简单实现
- 仅只读探查、无业务代码变更

以下 **必须** 沙箱：将委派 harness-* 写代码类 WU 的 `cursor-orchestration` 批次（见 `dispatcher-workflow.md` §0）。

### 8.4 Windows

- 路径统一使用绝对路径；派发 prompt 用正斜杠或转义反斜杠
- `git worktree add` 使用不含尾部分隔符的目录名
- Leader 用 `git worktree list` 验证注册成功

---

## 9. 与现有规范的关系

| 文档 | 变更类型 |
| --- | --- |
| `dispatcher-workflow.md` | 增步骤 0/5、子 Agent prompt 块、尾盘命令 cwd |
| `tracking/schema.md` | 增 Worktree 字段、恢复协议 |
| `agents/leader.md` | 增 WORKTREE-INIT/CLOSE 职责 |
| `artifact-templates/handoff.md` | 增 Git 沙箱节 |
| `artifact-templates/dispatch-track.md` | 增 Git 沙箱节 |
| `artifact-templates/execution-log.md` | front matter worktree |
| `core/runbooks.md` § Cursor 编排 | 增沙箱一句 |
| `core/routing.md` | 可选增「WORKTREE-INIT」判定行 |
| `project.git.md` | 增 delta：仓库外 `.harness-worktrees`、`harness/wt-*` 分支命名 |

**不变：**

- GROUP 尾盘顺序（`2026-05-28-batch-closeout-review-and-collective-test.md`）
- 子 Agent 默认不 commit
- plan / dispatch 阶段门禁

---

## 10. 验收标准

### 10.1 文档与模板

- [x] 本 spec `status: approved`
- [x] `dispatcher-workflow.md` 含 WORKTREE-INIT/CLOSE 与 prompt 块
- [x] tracking / handoff / execution-log 模板含沙箱字段

### 10.2 运行时（真实多 WU 批次）

- [ ] 用户说「开始实现」后，存在注册成功的 worktree（`git worktree list` 可见）
- [ ] 主 checkout 业务文件无 Agent 写入（对比 `git status`）
- [ ] 子 Agent 变更仅出现在沙箱路径
- [ ] GROUP 尾盘集体测试在沙箱内执行且 `collective-test.md` 含 `worktree_path`
- [ ] `HANDOFF` 可从沙箱路径恢复下一 GROUP
- [ ] 批次完成后 `WORKTREE-CLOSE` 写入 tracking

### 10.3 失败路径

- [ ] 集体测试 FAIL → 开 bugfix WU，仍在同一沙箱，不新建执行图沙箱
- [ ] 审查 BLOCK → `review-fix` WU 在同一沙箱修复

---

## 11. 实施顺序建议（供 writing-plans 使用）

1. **P0 — 契约：** 更新 tracking / handoff / execution-log 模板与 schema
2. **P0 — 编排：** `dispatcher-workflow.md` + `leader.md` WORKTREE-INIT/CLOSE
3. **P1 — 子 Agent 薄壳：** `.cursor/agents/harness-*.md` 引用工作目录块
4. **P1 — routing / runbooks：** 入口加载与一句话指引
5. **P2 — `project.git.md` delta + harness-check 警告**（沙箱未关闭）
6. **P2 — per-WU 例外流程**（文档即可，工具化可后做）

---

## 12. 风险与缓解

| 风险 | 缓解 |
| --- | --- |
| 磁盘占用（多 worktree） | 执行图级单沙箱；CLOSE 及时 remove |
| Leader 忘记在沙箱跑测试 | 尾盘 A 明确写「cwd = worktree_path」；collective-test 记录路径 |
| 路径泄露/复制错误 | 派发 prompt 只抄 tracking 中 `Output:` 绝对路径 |
| 与 git-xywh 分支规范冲突 | INIT 前强制 Load skill；分支名写入 `project.git.md` delta |
| 产物与代码分离困惑 | 本 spec §5.1 双轨模型；HANDOFF 同时链 plan 与 worktree |

---

## 13. 已确认决策（2026-05-29）

| 项 | 决策 |
| --- | --- |
| 沙箱位置 | **仓库外** `<repo-parent>/.harness-worktrees/<repo-basename>/` |
| 沙箱主标识 | **worktree**（`worktree_id` + `worktree_path`），见 §5.4 |
| 交付后 Git | **人工确认**后再 push / 开 PR；Leader 不自动 push |

---

## 14. 决策记录

| 日期 | 决策 | 理由 |
| --- | --- | --- |
| 2026-05-29 | 默认执行图级 worktree，非 per-WU | 与 GROUP 尾盘、集体测试整批 diff 对齐；降低 merge 成本 |
| 2026-05-29 | 编排产物留主 checkout | 追踪与审查产物不随沙箱删除 |
| 2026-05-29 | WORKTREE-INIT 在「开始实现」后 | 与阶段门禁一致；避免 spec/plan 阶段创建无用沙箱 |
| 2026-05-29 | 沙箱在仓库外 `.harness-worktrees` | 用户确认；不污染主 checkout `git status` |
| 2026-05-29 | 命名以 worktree_id 为准；分支 `harness/wt-…` | 用户澄清：创建 worktree 而非单独「拉分支」 |
| 2026-05-29 | push/PR 须人工确认 | 用户确认 |
