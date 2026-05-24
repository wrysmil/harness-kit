---
generated_at: 2026-05-14
generator: harness-init
---

# Project Profile — lightapp-meeting-summary

## 基本信息

| 字段 | 值 |
|------|-----|
| 名称 | lightapp-meeting-summary |
| 版本 | 1.14.0 |
| 描述 | AI 会议纪要 — 会议实时记录、实时字幕、实时总结 |
| 平台 | LastOS 轻应用 (Electron-like) |
| 包管理 | yarn (workspaces) |
| 语言 | TypeScript |

## 技术栈

- **渲染进程**: React 18 + Vite 6 + Ant Design 5 + Zustand 4 + react-router-dom 6
- **主进程**: Node.js (LastOS main process)，`main/main.ts`
- **预加载**: `preload/index.ts`，bridge renderer ↔ main
- **样式**: Less + postcss-pxtorem
- **国际化**: react-intl
- **视频**: xgplayer + hls.js
- **音频**: @whiteboard/audiokit-wasm
- **状态管理**: Zustand (多 store 拆分)
- **网络**: axios + got-cjs
- **Markdown**: @uiw/react-markdown-preview
- **监控**: Sentry
- **加密**: jsencrypt + @isp/kms

## 进程架构

```
┌─ LastOS Shell ──────────────────────────┐
│  main/main.ts          (主进程)          │
│    ├─ UploadProcessManager (fork screenUpload/transferChild)
│    └─ ControlProcessManager (fork controlProcess)
│                                         │
│  preload/index.ts      (预加载桥接)      │
│                                         │
│  src/main.tsx          (渲染进程入口)     │
│    └─ React App (Vite dev / build)      │
└─────────────────────────────────────────┘
```

## 子模块

| 模块 | 路径 | 说明 |
|------|------|------|
| screenUpload | `screenUpload/` | 录屏上传子进程，独立 workspace 包 |
| controlProcess | `controlProcess/` | 控制进程 |

## 构建脚本

| 命令 | 说明 |
|------|------|
| `yarn start` | Vite dev server |
| `yarn build` | 生产构建 (tsc + vite) |
| `yarn build:processes` | 构建 main + preload |
| `yarn build:subprojects` | 构建 screenUpload + controlProcess |
| `yarn build:all` | 全量构建 |
| `yarn pack` | 全量构建 + setup 打包 |
| `yarn lastos:start` | 本地 LastOS 调试启动 |

## 代码质量

- ESLint + Prettier + Stylelint
- commitlint (conventional)
- husky + lint-staged
- TypeScript strict (tsc)

## 推断项

- 【推断】无单元测试框架配置（package.json 中未发现 jest/vitest/mocha）
- 【推断】无 CI/CD 配置文件（未发现 .gitlab-ci.yml / .github/workflows）；README 中引用了 Jenkins 构建地址
- 【推断】`controlProcess/` 为独立子进程模块，与 screenUpload 类似架构

## 待确认项

- 【待确认】是否有独立的测试套件或 E2E 测试
- 【待确认】CI/CD 是否仅通过 Jenkins 管理
- 【待确认】controlProcess 的具体职责和通信协议
