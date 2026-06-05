# Cross-Platform Capability Kernel Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Core-first 能力内核；Cursor/Claude/Codex 各一适配器 + capability-matrix；Claude 可跑通编排主路径。

**Architecture:** 编排语义上提 `core/orchestration/`；`core/capabilities/` 登记 ID 与契约；适配器仅 bindings + matrix + 薄壳 skill/投影。

**Tech Stack:** Markdown/YAML；验证用 `scripts/harness-check.sh`（非 pytest）。

**TDD Required:** N/A（文档型；每 Task 以 harness-check 或 rg 断言替代）

---

## 现状

- 已完成：`core/orchestration/agents/*`、`skill-preferences.md`、`tracking/schema.md`；cursor agents 已 stub 指向 core
- 待办：capabilities、dispatcher-workflow 上提、roles、三平台 bindings/matrix、Claude skill、routing、 harness-check

---

### Task 1: P0 — capabilities 登记

**Files:**
- Create: `core/capabilities/registry.md`, `core/capabilities/primitives.md`

- [x] 从 spec §5.1 + 现有编排反推能力 ID 与契约
- [x] 原语表与禁止项写入 primitives.md
- [x] `bash scripts/harness-check.sh` matrix/stub 段 PASS

### Task 2: P1 — dispatcher + roles 上提

**Files:**
- Create: `core/orchestration/dispatcher-workflow.md`, `core/orchestration/roles.md`
- Modify: `adapters/cursor/orchestration/dispatcher-workflow.md` → stub
- Modify: `core/orchestration/config.defaults.yaml`（平台中立）
- Modify: `core/orchestration/skill-preferences.md`（路径指向 core dispatcher）

- [x] dispatcher 正文平台无关（SpawnWorker/ParallelBatch 原语）
- [x] cursor 旧路径 stub 重定向
- [x] roles.md 索引各 agent

### Task 3: P2 — Cursor 适配器

- [x] bindings 薄映射；matrix 覆盖 registry 全部 ID
- [x] skill 激活后读 core dispatcher

### Task 4: P3 — Claude 适配器（交付重点）

- [x] claude-orchestration skill + routing 四平台列
- [x] entrypoints 更新

### Task 5: P4 — Codex 适配器

- [x] omx 映射 + matrix

### Task 6: P5 — harness-check 扩展

- [x] matrix 覆盖、stub 重定向、routing claude 引用
- [ ] 全量 harness-check（本机无 `rg`，artifact FM 段需安装 ripgrep 或跳过 `.ai-runtime-artifacts/`）
