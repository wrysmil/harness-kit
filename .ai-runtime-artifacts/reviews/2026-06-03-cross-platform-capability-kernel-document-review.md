---
artifact: document-review
route: superpowers:document-review
skills:
  - document-review
skills_evidence:
  - harness-kit/adapters/cursor/.cursor/skills/document-review/SKILL.md
source:
  - harness-kit/docs/superpowers/specs/2026-06-03-cross-platform-capability-kernel-design.md
created_at: 2026-06-03
topic: cross-platform-capability-kernel
reviewed_doc_status: draft
verdict: conditional-pass
---

# 跨平台 Harness Capability Kernel 设计文档 — 审查报告

## 文档类型

**架构 / 技术设计文档**（关键词：架构、设计、实现、适配器、Core-first、迁移）

## 审查规则加载

- [x] 通用审查流程 — `checklists/review-checklist.md`
- [x] 设计文档特定规则 — `review-rules/design.md`
- [x] 环境准备审查规则（适用：Harness 脚手架 + 多平台运行时依赖）

## 审查结果摘要

| 维度 | 评分 | 说明 |
| --- | --- | --- |
| 文档完整性 | **基本完整** | 背景、架构、能力模型、并行、迁移、验证齐全；registry 全表、路由全表、Claude API 细节待补 |
| 逻辑清晰度 | **清晰** | 分层、依赖方向、逻辑/物理双层编排表述一致；与既有 batch-closeout / worktree spec 引用正确 |
| 环境准备完整性 | **不完整** | 缺可执行的开发/验证环境清单（skill 安装、投影、bootstrap、双平台手工验收入口） |
| 可执行性 | **基本可执行** | P0–P5 可拆 plan；§14 开放问题未闭合前不宜标 `approved: true` |

**总体结论：有条件通过（conditional-pass）** — 可作为 writing-plans 输入，但建议在批准 spec 前补齐环境准备节与 §14 决策。

---

### 1. 文档完整性（对照 checklist）

| 检查项 | 结果 |
| --- | --- |
| 明确标题 / 日期 / front matter | ✅ |
| 结构清晰（§1–15 + Next） | ✅ |
| 背景、目标、非目标 | ✅ §1、§3 |
| 验收标准 | ✅ §3.1（5 条）；§13 测试表 |
| 错误处理 | ✅ §11 |
| 边界条件 | ✅ §3.2 非目标；§6.2 degraded；§11 降级 |
| 架构图 / 组件职责 | ✅ §4、§7 |
| 接口 / 依赖 | ✅ 原语表 §5.2；依赖方向 §4 |
| 与现有 spec 关系 | ✅ related + §15 迁移映射 |
| 能力全量枚举（范围 D） | ⚠️ §5.1 为示例表；承诺 `registry.md` 尚未存在 |
| 路由表完整 | ⚠️ §9 仅一行示例 + `…` |
| API/DB/安全 | N/A（文档型 Harness，无 HTTP API/DB） |

### 2. 逻辑清晰度

**优点：**

- Core-first 与 adapter 边界写死（§4 依赖方向），避免再次 Cursor 耦合。
- 并行模型分层合理：GROUP/WU（逻辑）→ Task/subagent/omx（物理），与现有 `dispatcher-workflow` 一致。
- 完成定义与 batch-closeout spec 对齐（§6.2.4），无「末 WU 即完成」矛盾。
- worktree 复用 `scripts/harness-worktree.sh`，不重复造轮子。
- P3 不阻塞于 P1/P2 完成（§12），降低实施风险。

**需澄清的逻辑点：**

| 项 | 风险 | 建议 |
| --- | --- | --- |
| §9 平台检测：`CLAUDE.md` 会话 + 无 Cursor → claude | Cursor 仓库内同时存在 `CLAUDE.md` 时可能误判 | 检测顺序写死：`.cursor/agents/harness-*` 优先于 `CLAUDE.md` |
| §6.2 Claude `Task` + `subagent_type=generalPurpose` 承载 coder | 与 harness-coder 专角色语义可能弱化 | bindings 中明确「prompt 必须嵌入 `core/orchestration/agents/coder.md` 全文」 |
| `orchestration.continuous-loop` 在 §10.4 出现但未在 §5.1 能力表 | registry 遗漏 | 纳入 §5.1 或从 degraded 表移除 |
| worktree：本 spec 写 batch INIT；worktree isolation spec 有 per-WU 演进 | 两 spec 粒度需交叉引用一句 | 在 §6 或 §11 增加指针：以 `2026-05-29-git-worktree-isolation-design.md` 为准 |

### 3. 环境准备完整性（设计文档重点）

本变更为 **Harness Kit 仓库内文档/投影改造**，非传统 Web 服务，但仍须列出 Agent 实施与验收所需环境。当前文档 **未单独成章**，导致 implementer 易假设「只有改 MD」。

| 环境准备检查项 | 状态 | 缺失说明 |
| --- | --- | --- |
| 第三方依赖及版本 | ❌ | 未列：`oh-my-codex`/omx（Codex 验收入径）、Claude Code CLI 最低版本、Cursor Agent 模式 |
| 安装命令 | ⚠️ | 仅隐含 `install-ai-skills.sh`、`bootstrap`；未写「审查/实施前必跑」 |
| .env / 密钥 | N/A | 无云服务密钥需求 ✅ |
| 外部服务 | N/A | 无 ✅ |
| 开发环境要求 | ❌ | 未说明：须在**已接入 harness-kit 的样例仓库**或本仓库自举验证 |
| 环境验证命令 | ⚠️ | §13 提到 `harness-check.sh` 扩展，但未列**当前**可通过的命令 |
| 测试环境独立 | ⚠️ | 双平台契约测试应用独立 worktree/分支，未写 |
| bootstrap / 投影步骤 | ❌ | §10.1 列路径但未写「实施 P3 后验收步骤」 |

**建议新增 §3.3 或 §16「环境与验收前置」**，至少包含：

```markdown
- Node/npm：仅 Codex 验收需要（`omx --version`）
- Cursor：Agent 模式 + 项目已投影 `.cursor/agents/harness-*`
- Claude Code：Skill 工具可用 + `bash harness-kit/scripts/install-ai-skills.sh` 对 git-xywh / superpowers 为 ok
- 验证：`bash harness-kit/scripts/harness-check.sh`（实施 P5 后含 matrix）
- 双平台冒烟：同一 `plans/*-dispatch.md` 在 cursor 与 claude 各跑 1 GROUP×2 WU（文档/chore 即可）
```

### 4. 缺失项清单（按优先级）

#### P0 — 批准 spec 前建议补齐

1. **§14 开放问题**（3 条）无默认决策 — 阻塞「范围 D」审计可信度  
   - readonly 审查：建议默认「Task 新实例 + prompt 只读约束 + Leader 落盘」直至平台证实 native readonly  
   - `max_parallel`：建议默认与 Cursor 一致（3，硬顶 5）  
   - bootstrap Claude：建议默认 **opt-in**（`project.profile.md` 开关），避免未使用 CC 的项目多投影  

2. **环境准备专节**（见 §3 上表）— document-review 硬性要求  

3. **平台检测优先级**（§9）— 避免 Cursor 仓库内 Claude 入口误路由  

#### P1 — 可在 writing-plans / P0 实施时补

4. **`core/capabilities/registry.md` 最小骨架** — spec 承诺「单一真相源」但文件不存在；plan Phase 1 应创建并链回 spec  

5. **§9 路由表** — 补全与 `core/routing.md` 现有行一一对应的 Capability 列（至少：设计、计划、多 task、验证、审查、尾盘、Git、调研）  

6. **`orchestration.continuous-loop`** — 与 §5.1 / §10.4 对齐  

7. **冲突处理** — `Integrate` 时两 WU 改同一非声明文件的处理（回滚/worktree 丢弃）仅分散在 worktree spec，本 spec §11 可加一句指针  

#### P2 — 实现阶段可细化

8. **capability-matrix 完整初稿** — 示例仅 3 行；P2 应为 §5.1 每张能力 ID 各平台一行  

9. **stub 重定向格式** — §7 说留 stub 1 个 release，未给 stub 文件模板（一行 redirect MD）  

10. **版本/变更记录** — front matter 可加 `spec_version: 1` 便于后续增量修订  

---

### 5. 改进建议（具体）

1. **新增 §3.3 环境与工具前置** — 列出 install/bootstrap/check 命令与双平台冒烟定义（见上）。  
2. **闭合 §14** — 写入「默认决策」；仍存疑项标 `DECISION-DEFERRED` 并链 issue。  
3. **扩充 §9** — 完整路由 Capability 表 + 检测优先级流程图（3–5 行 text 即可）。  
4. **§5.1 补行** — `orchestration.dispatch`、`orchestration.continuous-loop`、`orchestration.dispatch` 与 routing 一致。  
5. **批准门禁** — front matter：`approved: true` 仅当 P0 缺失项已合入或用户书面确认 §14 默认决策。  
6. **与 writing-plans 衔接** — Phase 1 必须是 P0（registry + capabilities 目录 + harness-check 占位），再 P1 搬迁；符合 document-review「计划 Phase 1 为环境/基础」原则。

---

### 6. 各维度打分（design.md）

| 维度 | 分 | 备注 |
| --- | --- | --- |
| 整体设计 | **4/5** | 架构清晰；adapter 边界明确 |
| 环境准备 | **2/5** | 缺专节与可执行验证清单 |
| 技术细节（契约/API） | **4/5** | 原语 + WU schema 够实施；Claude Task API 仍偏示例 |
| 安全 | **N/A** | 无新鉴权面；Git 仍走 git-xywh ✅ |
| 可扩展性 | **5/5** | matrix + 新 adapter 目录模型合理 |

---

## Next

- **审查结论：有条件通过** — 文档质量足以进入 `writing-plans`，但 **不建议** 在未补环境准备、未闭合 §14 前将 spec 标为 `approved: true`。  
- **建议用户操作：**  
  1. 择一：补 §3.3 + §14 默认决策后回复「批准 spec」；或书面确认接受 §14 建议默认。  
  2. 在本分支提交 spec + 本审查报告（可选）。  
  3.  invoke `writing-plans`，首 Phase = P0（capabilities 目录 + registry 骨架 + harness-check 占位）。  
- **需要修改文档 →** 按上文 P0 清单改 `2026-06-03-cross-platform-capability-kernel-design.md` 后重新 `/document-review` 或快速复检 P0 项。
