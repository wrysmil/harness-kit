# dsh-harness-kit · DSH 运行时硬门禁插件

> 把 harness-kit 的 7-stage 流程（markdown 软规范）变成 DSH 里的原生运行时能力。

## 定位

DSH Cordis 插件（Phase 1 L2 + Phase 2 L1 + Phase 3 L3），提供：
- **硬门禁**：flow 未 unlock 时拦截 `write_file` / `edit_file` / `harness_dispatch`
- **多 flow 并存**：每条 flow 独立产物目录，独立 stage，独立 gate
- **AI 产物一等公民**：所有产物写 `.ai-runtime-artifacts/<flow-id>/` 带 front-matter
- **用户可管理 UI**：浮徽章 / sidebar 全局徽章 / settings 资产管理页 / artifact viewer

## 安装

```bash
node install.js
# 或 dry-run
node install.js --dry-run
```

## 卸载

```bash
node install.js --uninstall
```

## 清理 worktree

```bash
node install.js --cleanup-worktrees      # 真实清理
node install.js --cleanup-worktrees --dry-run  # 预览
```

## 回滚

```bash
node install.js --undo
```

## 核心概念

### Flow ID 命名规则

```
^[a-z0-9]([a-z0-9-]{0,62}[a-z0-9])?(\/[a-z0-9]([a-z0-9-]{0,62}[a-z0-9])?)*$
```

- 段内禁 `_`（`__` 是 `/` 的映射符）
- 示例：`feat/rate-limiter` → 目录名 `feat__rate-limiter`
- 禁止：`feat__x/y`（非单射）

### 7 个 harness_* tool

| Tool | 用途 |
|------|------|
| `harness_route` | 查 flow 状态 |
| `harness_artifact_write` | 写产物（强制 .ai-runtime-artifacts/） |
| `harness_check` | 跑 reference checklist |
| `harness_advance` | 推进 stage |
| `harness_dispatch` | 发起 WU fan-out |
| `harness_run_test` | 跑测试 |
| `harness_flow` | 管理 flow（list/switch/create/abort） |

### 15 个 /harness-* 命令

| 命令 | 用途 |
|------|------|
| `/harness` | 打开面板 |
| `/harness feat <flow-id>` | 启动 feat flow |
| `/harness bug <flow-id>` | 启动 bug flow |
| `/harness hotfix <flow-id>` | 启动 hotfix flow |
| `/harness explore <topic>` | 启动 explore flow |
| `/harness verify <target>` | 跑测试 + checklist |
| `/harness refactor <flow-id>` | 启动 refactor flow |
| `/harness approve <flow-id> [<file-index>]` | 批准产物 |
| `/harness switch <flow-id>` | 切换 active flow |
| `/harness abort <flow-id>` | 放弃 flow |
| `/harness continue <flow-id>` | 继续 paused flow |
| `/harness diagnose` | 显示诊断 |
| `/harness check <flow-id>` | 跑 checklist |
| `/harness focus` | 切换 UI 形态 |
| `/harness reload` | 重载 preset |

## UI 形态

| 形态 | 位置 | slot |
|------|------|------|
| **C（默认）** | conversation turnTail 浮徽章 | `conversation.chat.turnTail` |
| B | details 列 view tab | `conversation.view` |
| A | composer 上方 drawer | `conversation.input.dock` |

## 产物目录结构

```
~/.dsh/
├── .agent-presets/harness-kit/   # agent preset
├── skills/harness/              # 8 个 SKILL.md
├── flows/harness-kit.yaml        # flow schema
└── sessions/<sid>/flow-state.json  # 运行时状态
```

## 风险缓解

- **R1**：gate-enforcer 误拦 → `harness_advance` throw 语义明确 + 测试覆盖 66-case
- **R2**：flow-state 损坏 → `load()` 有 try/catch，返回 null 时自动重建
- **R3**：WORKTREE 冲突 → `git worktree add --force` + 清理脚本
- **R4**：DSH 版本不兼容 → `REQUIRED_PACKAGES` 启动检查
- **R5**：preset 重载 → `--undo` 支持 + 备份时间戳

## 视觉稿

- `specs/2026-08-24-dsh-harness-kit-design-mockup.html`
- `plans/fixtures/l3/badge.html`
- `plans/fixtures/l3/sidebar-footer.html`
- `plans/fixtures/l3/settings.html`
- `plans/fixtures/l3/artifact-viewer.html`
