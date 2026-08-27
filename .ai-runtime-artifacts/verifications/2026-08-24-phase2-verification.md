# Phase 2 验证 · L1 引擎

## 验收标准

### Task 6: gate-enforcer（WU-05）
- [x] `gate-enforcer.js` 语法正确 ✅
- [x] 66-case 单测全通过：`66 pass · 0 fail` ✅
  - 13 FLOW_ID_RE cases
  - 48 gate×tool matrix cases (4 gates × 3 lock states × 4 tools)
  - 4 activeFlowId fallback cases
  - 1 structural

### Task 7: 7 个 tool schema（WU-06）
- [x] 7 个 JSON 合法 + 字段完整 ✅
- [x] `harness_artifact_write` 含 `path` 和 `kind` 必填 ✅
- [x] `path must start with` 描述存在 ✅
- [x] 6/7 个 tool 含 `flowId` 必填（`harness_flow` 除外）✅

### Task 8: flow-engine（WU-07）
- [x] `flow-engine.js` 含 v1.7 修正（`activeFlowId`/`approve()`/`advance()` 修正/`load()`/`save()`）✅
- [x] `flow-state-schema.json` 完整 ✅
- [x] 46-case 单测全通过：`46 pass · 0 fail` ✅

### Task 8b: L1 cordis 插件（Task 8b，新增值段）
- [x] `harness-l1-plugin/index.js` 创建 `ctx.harness` 注入点 ✅
- [x] 注册 `7` 个 harness_* tool + `ctx.tools.guard(guard)` ✅

## Git 提交

| WU | Commit | 内容 |
|---|---|---|
| WU-05 | `1a37707` | gate-enforcer.js + test-gate-enforcer.js (66-case) |
| WU-06 | `9f9d0f8` | 7 个 tool schema JSON |
| WU-07 | `b62e3f1` | flow-engine.js + flow-state-schema.json + test-flow-engine.js (46-case) |

## L1 Fixture 清单

```
plans/fixtures/l1/
├── gate-enforcer.js              (1a37707)
├── test-gate-enforcer.js        (1a37707) — 66-case
├── flow-engine.js               (b62e3f1)
├── flow-state-schema.json       (b62e3f1)
├── test-flow-engine.js          (b62e3f1) — 46-case
└── tools/
    ├── harness_route.json        (9f9d0f8)
    ├── harness_artifact_write.json (9f9d0f8)
    ├── harness_check.json       (9f9d0f8)
    ├── harness_advance.json     (9f9d0f8)
    ├── harness_dispatch.json    (9f9d0f8)
    ├── harness_run_test.json    (9f9d0f8)
    └── harness_flow.json        (9f9d0f8)
```

## 下一步

开始 Phase 3（L3 表现）：WU-09..WU-14 并行（conversation 浮徽章 / sidebar footer / settings 资产管理页 / artifact viewer / cordis 客户端插件 / 15 个 slash command）
