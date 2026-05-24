---
generated_at: 2026-05-14
generator: harness-init
---

# Context Map — lightapp-meeting-summary

## 目录结构概览

```
lightapp-meeting-summary/
├── src/                    # 渲染进程 (React)
│   ├── App.tsx             # 应用根组件
│   ├── main.tsx            # 入口
│   ├── views/              # 页面视图 (Home, Meeting, TranslateSubtitlePage)
│   ├── components/         # 公共组件
│   ├── store/              # Zustand stores
│   ├── service/            # API 服务层
│   ├── hooks/              # 自定义 hooks
│   ├── utils/              # 工具函数
│   ├── lib/                # 第三方库封装
│   ├── i18n/               # 国际化资源
│   ├── routes/             # 路由配置
│   ├── handlers/           # 事件处理器
│   ├── widgets/            # 小部件
│   ├── windows/            # 窗口相关
│   ├── module/             # 业务模块 (AppStartPipeline, RecordServer)
│   ├── types/              # 类型定义
│   ├── constants/          # 常量
│   └── assets/             # 静态资源
├── main/                   # 主进程
│   ├── main.ts             # 主进程入口
│   ├── handlers.ts         # IPC 事件处理
│   ├── config.ts           # 配置
│   ├── UploadProcessManager.ts  # 上传子进程管理
│   └── ControlProcessManager.ts # 控制子进程管理
├── preload/                # 预加载脚本
│   ├── index.ts            # 预加载入口
│   ├── preload.ts          # preload bridge
│   └── udi/                # UDI 接口封装
├── screenUpload/           # 录屏上传子进程 (workspace)
├── controlProcess/         # 控制进程
├── configs/                # 应用配置
├── setup/                  # 构建打包脚本
├── share/                  # 共享代码
├── public/                 # 静态公共资源
└── docs/                   # 项目文档
```

## 数据流

```
用户操作 (渲染进程)
  → preload bridge (IPC)
    → main 主进程
      → UDI 接口 / LastOS API
      → fork screenUpload 子进程 (录屏)
      → fork controlProcess 子进程 (控制)
    → 后端 API (axios)
```

## 状态管理 (Zustand Stores)

| Store | 职责 |
|-------|------|
| appStore | 应用全局状态 |
| configStore | 配置管理 |
| dialogStore | 弹窗状态 |
| layoutStore | 布局状态 |
| recordTimingStore | 录制计时 |
| rightsStore | 权益管理 |
| routeStore | 路由状态 |
| screenStatusStore | 录屏状态 |
| shareStore | 分享状态 |
| summaryStore | 会议总结 |
| translateStore | 翻译/字幕 |

## 关键页面

| 页面 | 路径 | 说明 |
|------|------|------|
| Home | `src/views/Home/` | 首页 |
| Meeting | `src/views/Meeting/` | 会议主界面（录制、字幕、总结） |
| TranslateSubtitlePage | `src/views/TranslateSubtitlePage/` | 翻译字幕页 |

## 外部依赖关系

- **LastOS SDK**: @lastos/cli, @lastos/types, @lastos/virtual-window 等
- **后端 API**: 通过 axios 调用
- **UDI**: LastOS 设备接口
- **对象存储**: 录屏切片上传
