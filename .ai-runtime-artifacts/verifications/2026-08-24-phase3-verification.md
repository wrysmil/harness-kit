# Phase 3 验证 · L3 表现

## 验收标准（spec §8 Phase 3）

### WU-09: conversation 浮徽章 + popover（form C）
- [x] `badge.css` — 浮徽章 fixed right:18px top:74px + popover + locked/unlocked 双态 + pulse 动画 ✅
- [x] `badge.html` — 完整 demo，模拟 DSH conversation 区 ✅
- [x] commit `6a2f599` ✅

### WU-10: sidebar footer 全局徽章
- [x] `sidebar-footer.html` — 3 态切换（🟡 3 active / 🟢 all open / 🔴 1 rejected）✅
- [x] commit `a75a74c` ✅

### WU-11: settings 资产管理页
- [x] `settings.html` — DSH shell + 4 type tabs + 6 行 agent 表格 + 4 种状态视觉 ✅
- [x] commit `ced2383` ✅

### WU-12: artifact viewer（视觉参考）
- [x] `artifact-viewer.html` — 7 type tabs + 文件树 + FM 块 + diff 高亮 ✅
- [x] commit `6a69a7f` ✅

### WU-12b: cordis 客户端插件（v1.7 B7 修正）
- [x] `client-plugin/index.tsx` — 4 个 slot 成对调用模式（`ctx.slots.inject` + `ctx.slots.register`）✅
- [x] `BadgePopover.tsx` — C 形态浮徽章组件 ✅
- [x] `SidebarFooter.tsx` — 全局徽章组件 ✅
- [x] `SettingsSection.tsx` — 设置页 section 组件 ✅
- [x] `ArtifactViewer.tsx` — artifact viewer 组件 ✅
- [x] 4 个真实 slot：`conversation.chat.turnTail` / `sidebar.footer.action` / `settings.section` / `conversation.view` ✅
- [x] commit `5ff113a` ✅

### WU-13: 15 个 slash command
- [x] `harness-commands.json` — 15 条命令（6 builtin + 9 management）✅
- [x] 含新增 6 条：`approve` / `switch` / `abort` / `continue` / `diagnose` / `reload` ✅
- [x] commit `4849439` ✅

## Git 提交

| WU | Commit | 产物 |
|---|---|---|
| WU-09 | `6a2f599` | badge.css + badge.html |
| WU-10 | `a75a74c` | sidebar-footer.html |
| WU-11 | `ced2383` | settings.html |
| WU-12 | `6a69a7f` | artifact-viewer.html |
| WU-12b | `5ff113a` | client-plugin (5 files) |
| WU-13 | `4849439` | harness-commands.json |

## L3 Fixture 清单（11 个文件）

```
plans/fixtures/l3/
├── badge.css + badge.html                   (6a2f599)
├── sidebar-footer.html                       (a75a74c)
├── settings.html                            (ced2383)
├── artifact-viewer.html                      (6a69a7f)
└── client-plugin/
    ├── index.tsx                            (5ff113a)
    ├── BadgePopover.tsx                     (5ff113a)
    ├── SidebarFooter.tsx                    (5ff113a)
    ├── SettingsSection.tsx                  (5ff113a)
    └── ArtifactViewer.tsx                   (5ff113a)

plans/fixtures/commands/
└── harness-commands.json                    (4849439)
```

## 下一步

Phase 4（文档与发布）：WU-15(install.js) → WU-16(README) → WU-17(Plan 自检)
